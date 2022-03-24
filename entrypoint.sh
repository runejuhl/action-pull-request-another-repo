#!/bin/bash
set -euo pipefail

if ! [ "${INPUT_SOURCE_FOLDER}" ]; then
  echo "Source folder must be defined"
  exit 1
fi

if ! [ "${INPUT_PR_TITLE}" ]; then
  echo "pr_title must be defined"
  exit 1
fi

if ! [ "${INPUT_COMMIT_MSG}" ]; then
  echo "commit_msg must be defined"
  exit 1
fi

if [ "${INPUT_DESTINATION_HEAD_BRANCH}" == "main" ] || [ "${INPUT_DESTINATION_HEAD_BRANCH}" == "master" ]; then
  echo "Destination head branch cannot be 'main' nor 'master'"
  exit 1
fi

if ! [[ "${API_TOKEN_GITHUB}" =~ ^ghp_ ]]; then
  echo "Personal access token doens't have the right prefix."
  exit 1
fi

declare -a GH_PR_ARGS=()

if [ "${INPUT_PULL_REQUEST_REVIEWERS}" ]; then
  GH_PR_ARGS+=('-r' "${INPUT_PULL_REQUEST_REVIEWERS}")
fi

HOME_DIR=$PWD
CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
git config --global user.email "${INPUT_USER_EMAIL}"
git config --global user.name "${INPUT_USER_NAME}"

echo "Cloning destination git repository"
git clone "https://${API_TOKEN_GITHUB}@github.com/${INPUT_DESTINATION_REPO}.git" "${CLONE_DIR}"

echo "Creating folder"
mkdir -p "${CLONE_DIR}/${INPUT_DESTINATION_FOLDER}/"
cd "${CLONE_DIR}"

# shellcheck disable=SC2155
declare -ri BRANCH_EXISTS=$(git show-ref -q "${INPUT_DESTINATION_HEAD_BRANCH}"; echo $?)

echo "Checking if branch already exists"
if ! (( BRANCH_EXISTS )); then
  git checkout "${INPUT_DESTINATION_HEAD_BRANCH}"
else
  git checkout -b "${INPUT_DESTINATION_HEAD_BRANCH}"
fi

echo "Copying files"
rsync -a --delete "${HOME_DIR}/${INPUT_SOURCE_FOLDER}" "${CLONE_DIR}/${INPUT_DESTINATION_FOLDER}/"
git add .

if git diff -q; then
  echo "No changes detected"
  exit 0
fi

git commit --message "${INPUT_COMMIT_MSG}"

echo "Pushing git commit"
git push -u origin "HEAD:${INPUT_DESTINATION_HEAD_BRANCH}"

if (( BRANCH_EXISTS )); then
  echo "Updating pull request"
  CURRENT_BODY=$(gh pr view "${INPUT_DESTINATION_HEAD_BRANCH}" --json body | jq '.body')
  CURRENT_BODY=${CURRENT_BODY:1:${#CURRENT_BODY} - 2}

  gh pr edit "${INPUT_DESTINATION_HEAD_BRANCH}" -b "${CURRENT_BODY}
    - https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
else
  echo "Creating a pull request"
  gh pr create -t "$INPUT_PR_TITLE"                                            \
     -b "Commit(s) from:
                 - https://github.com/$GITHUB_REPOSITORY/commit/${GITHUB_SHA}" \
                   -B "${INPUT_DESTINATION_BASE_BRANCH}"                       \
                   -H "${INPUT_DESTINATION_HEAD_BRANCH}"                       \
                   "${GH_PR_ARGS[@]}"
fi
