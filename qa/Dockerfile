FROM ruby:2.5.1-alpine

RUN apk add --no-cache --update \
  build-base

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle check --path vendor/bundle || bundle install --path vendor/bundle -j $(nproc)

COPY . ./

USER nobody
