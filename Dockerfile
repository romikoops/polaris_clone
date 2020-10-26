FROM ruby:2.6-slim AS base

# Upgrade bundler
RUN gem install bundler -v1.17.3

# Minimal requirements to run a Rails app
RUN apt-get update \
  && apt-get install -y \
  awscli \
  build-essential \
  cmake \
  curl \
  git \
  gnupg2 \
  graphicsmagick \
  libgeos-dev \
  nodejs \
  npm \
  pv \
  tzdata \
  wkhtmltopdf

# Install Postgresql 12
RUN \
  curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | \
    tee /etc/apt/sources.list.d/pgdg.list \
  && apt-get update \
  && apt-get install -y libpq-dev postgresql-client-12

# Install MJML
RUN npm install -g 'mjml@4.3.1'

WORKDIR /app

# Collect all internal gems and engines
FROM busybox AS dependencies

COPY . /app
RUN find /app -type f ! -name "Gemfile*" ! -name "*.gemspec" ! -name "gemhelper.rb" -delete

# Build production image
FROM base AS builder

COPY --from=dependencies /app ./

RUN \
  bundle config set frozen 'true' \
  && bundle install --without=development test --retry 3 \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY . ./

RUN RAILS_ENV=production bin/rails assets:precompile

#
#
# PRODUCTION TARGET
#
#
#
FROM ruby:2.6-slim AS app

RUN gem install bundler -v1.17.3

# Minimal requirements to run a Rails app
RUN apt-get update \
  && apt-get install -y \
    curl \
    fonts-noto \
    gnupg2 \
    graphicsmagick \
    less \
    libgeos-3.7.1 \
    libgeos-dev \
    nodejs \
    npm \
    tzdata \
    wkhtmltopdf

# Install Postgresql 12
RUN \
  curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | \
    tee /etc/apt/sources.list.d/pgdg.list \
  && apt-get update \
  && apt-get install -y libpq5

# Install MJML
RUN npm install -g 'mjml@4.3.1'

WORKDIR /app

# Add user
RUN addgroup --gid 1000 app \
  && adduser --home /app/tmp \
    --shell /sbin/nologin \
    --no-create-home \
    --uid 1000 \
    --gid 1000 \
    app
USER app

# Copy app with gems from former build stage
COPY --from=builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_ENV review
ENV MALLOC_ARENA_MAX 2

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
