# Builder Image
FROM node:12-slim AS builder
LABEL maintainer="development@itsmycargo.com"

RUN apt-get update && apt-get install -y \
  build-essential \
  gifsicle \
  libgl1-mesa-glx \
  libjpeg62-turbo-dev \
  liblcms2-dev \
  libpng-dev \
  libwebp-dev \
  libxi6 \
  optipng \
  pngquant

COPY package.json package-lock.json ./
RUN npm install --no-progress --production

COPY . .

ARG RELEASE=""
ENV RELEASE $RELEASE
RUN npm run build

# Sentry Uploader
FROM getsentry/sentry-cli AS sentry

ARG SENTRY_AUTH_TOKEN=""
ARG SENTRY_URL=https://sentry.itsmycargo.tech
ARG SENTRY_ORG=itsmycargo
ARG SENTRY_PROJECT=frontend

ENV SENTRY_URL $SENTRY_URL
ENV SENTRY_ORG $SENTRY_ORG
ENV SENTRY_PROJECT $SENTRY_PROJECT
ENV SENTRY_AUTH_TOKEN $SENTRY_AUTH_TOKEN

COPY --from=builder /dist /work
ARG RELEASE=""
ENV RELEASE $RELEASE

RUN sentry-cli releases files $RELEASE upload-sourcemaps --rewrite --validate /work/ || true

# Deployment Image
FROM nginx:alpine AS app

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY nginx/nginx.tmpl /etc/nginx/

COPY --from=builder --chown=nginx:nginx /dist /usr/share/nginx/html

CMD ["dockerize", "-template", "/etc/nginx/nginx.tmpl:/etc/nginx/nginx.conf", "nginx", "-g", "daemon off;"]
