# Builder Image
FROM node:8 AS builder
MAINTAINER mikko.kokkonen@itsmycargo.com

RUN set -ex \
  \
  && apt-get update \
  \
  && apt-get update \
  && apt-get install -y \
    libpng-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY package.json package-lock.json ./
RUN npm install

COPY . .

ARG SENTRY_AUTH_TOKEN=""
ARG SENTRY_URL=https://sentry.itsmycargo.tech
ARG SENTRY_ORG=itsmycargo
ARG SENTRY_PROJECT=frontend
ARG RELEASE=""

RUN \
    SENTRY_URL=$SENTRY_URL \
    SENTRY_ORG=$SENTRY_ORG \
    SENTRY_PROJECT=$SENTRY_PROJECT \
    SENTRY_AUTH_TOKEN=$SENTRY_AUTH_TOKEN \
    RELEASE=$RELEASE \
    npm run build
# Clear out source-maps
RUN rm -v dist/*.js.map

# Deployment Image
FROM nginx:alpine

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --from=builder --chown=nginx:nginx ./dist/ /usr/share/nginx/html/
COPY nginx/nginx.tmpl /etc/nginx/

CMD ["dockerize", "-template", "/etc/nginx/nginx.tmpl:/etc/nginx/nginx.conf", "nginx", "-g", "daemon off;"]
