# Action pull request another repository

This GitHub Action copies a folder from the current repository to a location in
another repository and create a pull request

## Example Workflow

```yaml
name: Push File
on: push
env:
  GITHUB_TOKEN: ${{ secrets.YOUR-TOKEN }}
jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Create pull request
      uses: car-on-sale/action-pull-request-another-repo@version
      env:
        API_TOKEN_GITHUB: ${{ env.GITHUB_TOKEN }}
      with:
        source_folder: 'source-folder'
        destination_repo: 'user-name/repository-name'
        destination_folder: 'folder-name'
        destination_base_branch: 'branch-name'
        destination_head_branch: 'branch-name'
        user_email: 'user-name@paygo.com.br'
        user_name: 'user-name'
        pull_request_reviewers: 'reviewers'
        pr_title: 'feat: the pr title'
```

## Variables

* `source_folder`: The folder to be moved. Uses the same syntax as the `cp`
  command. Incude the path for any files not in the repositories root directory.
* `destination_repo`: The repository to place the file or directory in.
* `destination_folder` *optional*: The folder in the destination repository to
  place the file in, if not the root directory.
* `user_email`: The GitHub user email associated with the API token secret.
* `user_name`: The GitHub username associated with the API token secret.
* `pr_title`: The pull request title
* `destination_base_branch` *optional*: The branch into which you want your code
  merged. Default is `main`.
* `destination_head_branch`: The branch to create to push the changes. Cannot be
  `master` or `main`.
* `pull_request_reviewers` *optional*: The pull request reviewers. It can be only
  one (just like 'reviewer') or many (just like 'reviewer1,reviewer2,...')
* `commit_msg` *optional*: The commit message which will be used. **default**
  `Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA`

## Environment variables

* `API_TOKEN_GITHUB`: You must create a personal access token in you account.
  Follow the link: [Personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

> You must select the scopes: 'repo = Full control of private repositories',
> 'admin:org = read:org' and 'write:discussion = Read:discussion';

## Behavior Notes

The action will create any destination paths if they don't exist. It will also
overwrite existing files if they already exist in the locations being copied to.
It will not delete the entire destination repository.
