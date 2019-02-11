FROM ruby:2.6 AS builder
LABEL maintainer="development@itsmycargo.com"

ARG BUNDLE_WITHOUT="development test"

ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

# Minimal requirements to run a Rails app
RUN apt-get update && apt-get install -y \
  apt-transport-https \
  automake \
  build-essential \
  cmake \
  git \
  libgeos-dev \
  libpq-dev \
  locales \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL C.UTF-8

# Install Node
ARG NODE_VERSION=node_10.x
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo "deb https://deb.nodesource.com/$NODE_VERSION stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g 'mjml@4.3.1'

WORKDIR /app

COPY .build/ ./
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 \
    && bundle install -j4 --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY . ./
ARG RELEASE=""
RUN echo "$RELEASE" > ./REVISION

# Add user
RUN groupadd -r app && useradd -r -d /app/tmp -s /sbin/nologin -g app app
RUN chown -R app:app /app/
USER app

RUN RAILS_ENV=production bin/rails assets:precompile

FROM ruby:2.6 AS app
LABEL maintainer="development@itsmycargo.com"

ENV MALLOC_ARENA_MAX 2

# Minimal requirements to run a Rails app
RUN apt-get update && apt-get install -y \
  apt-transport-https \
  libgeos-c1v5 \
  libpq5 \
  locales \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

ARG NODE_VERSION=node_10.x
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo "deb https://deb.nodesource.com/$NODE_VERSION stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g 'mjml@4.3.1'

ARG DOCKERIZE_VERSION=v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Add user
RUN groupadd -r app && useradd -r -d /app/tmp -s /sbin/nologin -g app app

# Copy app with gems from former build stage
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

RUN chown -R app:app /app/
USER app

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_ENV review

WORKDIR /app

EXPOSE 3000

CMD ["bin/rails", "server", "puma", "-b", "0.0.0.0", "-p", "3000"]
