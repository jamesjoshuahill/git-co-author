FROM alpine:latest

RUN apk --no-cache add \
  bats \
  git \
  util-linux

WORKDIR /git-co-author

COPY . /git-co-author

CMD [ "./test/git-co-author.bats" ]
