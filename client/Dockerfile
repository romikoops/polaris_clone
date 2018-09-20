FROM node:8 AS build

ARG SENTRY_AUTH_TOKEN=""
ARG RELEASE=""

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

ENV SENTRY_URL=https://sentry.itsmycargo.tech
ENV SENTRY_ORG=itsmycargo
ENV SENTRY_PROJECT=imc-frontend
RUN SENTRY_AUTH_TOKEN=$SENTRY_AUTH_TOKEN RELEASE=$RELEASE npm run build

FROM nginx:alpine

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --from=0 ./dist/ /usr/share/nginx/html/
COPY nginx/nginx.tmpl /etc/nginx/
RUN chown -R nginx:nginx /usr/share/nginx/html/

CMD ["dockerize", "-template", "/etc/nginx/nginx.tmpl:/etc/nginx/nginx.conf", "nginx", "-g", "daemon off;"]
