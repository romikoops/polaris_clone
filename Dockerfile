FROM ruby:2.6@sha256:51ffdb09a2769cf3635fdf3838a501d737c42612ae8930ab7739c109f011cf59 AS builder
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
  libssl-dev \
  locales \
  tzdata \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL C.UTF-8

# Add user
RUN groupadd -r app && useradd -r -d /app/tmp -s /sbin/nologin -g app app

# Install Node
ARG NODE_VERSION=node_10.x
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo "deb https://deb.nodesource.com/$NODE_VERSION stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g 'mjml@4.3.1'

WORKDIR /app

COPY --chown=app:app Gemfile Gemfile.lock .build/docker/ .

RUN bundle config --global frozen 1 \
    && bundle install -j4 --retry 3 \
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

RUN chown -R app:app /app/

ARG RELEASE=""
RUN echo "$RELEASE" > ./REVISION

COPY --chown=app:app . ./

USER app

RUN RAILS_ENV=production bin/rails assets:precompile

#
#
# PRODUCTION TARGET
#
#
#
FROM ruby:2.6-slim@sha256:d5216b4a814d0565d16df7d1409f9684de55c271045e1373f163920ada09584f AS app
LABEL maintainer="development@itsmycargo.com"

ENV MALLOC_ARENA_MAX 2

# Minimal requirements to run a Rails app
RUN apt-get update && apt-get install -y \
  apt-transport-https \
  fonts-noto \
  gnupg \
  libfontconfig1 \
  libfreetype6 \
  libgeos-c1v5 \
  libpq5 \
  libssl1.1 \
  libx11-6 \
  libxext6 \
  libxrender1 \
  locales \
  tzdata \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

ARG NODE_VERSION=node_10.x
ADD https://deb.nodesource.com/gpgkey/nodesource.gpg.key /root
RUN apt-key add /root/nodesource.gpg.key \
  && echo "deb https://deb.nodesource.com/$NODE_VERSION stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y \
    nodejs \
  && rm -rf /var/lib/apt/lists/* /root/nodesource.gpg.key

RUN npm install -g 'mjml@4.3.1'

# Add user
RUN groupadd -r -g 1000 app && useradd -r -d /app/tmp -s /sbin/nologin -g app -u 1000 app

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
