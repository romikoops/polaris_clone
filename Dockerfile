FROM ruby:2.6-alpine AS builder

ARG BUNDLE_WITHOUT="development test"

ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

# Minimal requirements to run a Rails app
RUN apk add --no-cache \
  automake \
  build-base \
  cmake \
  geos-dev \
  git \
  nodejs \
  npm \
  postgresql-dev \
  tzdata
# Install MJML
RUN npm install -g 'mjml@4.3.1'

WORKDIR /app

COPY Gemfile Gemfile.lock .build/docker/ .

RUN \
  bundle config --local build.sassc --disable-march-tune-native \
  && bundle install --frozen --without=development test --retry 3 \
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
FROM ruby:2.6-alpine AS app

ENV MALLOC_ARENA_MAX 2

# Minimal requirements to run a Rails app
RUN apk add --no-cache \
  font-noto \
  geos \
  less \
  libpq \
  nodejs \
  npm \
  tzdata \
  wkhtmltopdf

# Install MJML
RUN npm install -g 'mjml@4.3.1'

WORKDIR /app

# Add user
RUN addgroup -g 1000 app && adduser -D -h /app/tmp -s /sbin/nologin -G app -u 1000 app
USER app

# Copy app with gems from former build stage
COPY --from=builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_ENV review

EXPOSE 3000

CMD ["bin/rails", "server", "puma", "-b", "0.0.0.0", "-p", "3000"]
