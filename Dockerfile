FROM alpine:3.15 AS BUILD

RUN apk update && \
  apk upgrade && \
  apk add git go make
RUN git clone --depth=1 https://github.com/cli/cli.git /tmp/gh-cli && \
  cd /tmp/gh-cli && \
  make

FROM alpine:3.15

RUN apk update && \
  apk upgrade && \
  apk add bash git jq rsync

COPY --from=BUILD /tmp/gh-cli/bin/gh /usr/local/bin
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
