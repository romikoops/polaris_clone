FROM ruby:2.5-alpine AS builder
LABEL maintainer="development@itsmycargo.com"

ARG BUNDLE_WITHOUT="development test"

ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update \
  build-base \
  cmake \
  git \
  linux-headers \
  nodejs \
  npm \
  postgresql-dev \
  tzdata
RUN npm install -g 'mjml@4.2.0'

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 \
    && bundle install -j4 --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY . ./

RUN RAILS_ENV=production bin/rails assets:precompile

FROM ruby:2.5-alpine AS app
LABEL maintainer="development@itsmycargo.com"

ENV MALLOC_ARENA_MAX 2

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update \
  nodejs \
  npm \
  postgresql-client \
  tzdata

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN npm install -g 'mjml@4.2.0'

# Add user
RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app
USER app

# Copy app with gems from former build stage
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

WORKDIR /app

EXPOSE 3000

CMD ["bin/rails", "server", "puma", "-b", "0.0.0.0", "-p", "3000"]
