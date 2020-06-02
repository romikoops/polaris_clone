# Builder Image
FROM node:12-slim@sha256:f1208deafabe0185d1d5d6d595ec7a3443d4686f45c81a58c22b26ca47fdf238 AS builder
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
FROM nginx:alpine@sha256:678fd4ece211f3cadea51b1e768e4955bd4a948c684d02ad766054934c4f3b26 AS app

ENV DOCKERIZE_VERSION v0.6.1
RUN wget -q https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY nginx/nginx.tmpl /etc/nginx/

COPY --from=builder --chown=nginx:nginx /src/dist /usr/share/nginx/html

CMD ["dockerize", "-template", "/etc/nginx/nginx.tmpl:/etc/nginx/nginx.conf", "nginx", "-g", "daemon off;"]
