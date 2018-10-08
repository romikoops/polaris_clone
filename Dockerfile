FROM ruby:2.5-alpine
MAINTAINER mikko.kokkonen@itsmycargo.com

ENV MALLOC_ARENA_MAX 2

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update \
  build-base \
  cmake \
  git \
  linux-headers \
  nodejs \
  postgresql-dev \
  tzdata

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN npm install -g 'mjml@4.1.2'

RUN mkdir -p /app
WORKDIR /app

ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

ENV BUNDLE_PATH=/app/vendor/bundle
ENV BUNDLE_WITHOUT="development test"

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment --retry 3

COPY . ./

RUN RAILS_ENV=production bin/rails assets:precompile

EXPOSE 3000

CMD ["bin/rails", "server", "puma", "-b", "0.0.0.0", "-p", "3000"]
