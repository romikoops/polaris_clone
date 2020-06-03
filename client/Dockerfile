# Builder Image
FROM node:12-slim@sha256:ed98dc40adb46c2e23e9583f879fd16f39ea284e2f6c27ec1c6030e5452c0c02 AS builder
LABEL maintainer="development@itsmycargo.com"

RUN apt-get update && apt-get install -y --allow-unauthenticated \
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

RUN mkdir -p /src
WORKDIR /src

COPY package.json package-lock.json ./
RUN npm install --no-progress --production

COPY *config.js ./
COPY locales/ ./locales/
COPY app/ ./app/

ARG RELEASE=""
ENV RELEASE $RELEASE
RUN npm run build

# Deployment Image
FROM nginx:alpine@sha256:ee5a9b68e8d4a4b8b48318ff08ad5489bd1ce52b357bf48c511968a302bc347b AS app

ENV DOCKERIZE_VERSION v0.6.1
RUN wget -q https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY nginx/nginx.tmpl /etc/nginx/

COPY --from=builder --chown=nginx:nginx /src/dist /usr/share/nginx/html

CMD ["dockerize", "-template", "/etc/nginx/nginx.tmpl:/etc/nginx/nginx.conf", "nginx", "-g", "daemon off;"]
