FROM node:8-alpine

LABEL maintainer="AndrÃ© KÃ¶nig <andre.koenig@gmail.com>"

RUN apk add --update curl iptables sudo && \
    addgroup -S app && adduser -S -g app app

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "--"]
