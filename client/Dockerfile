FROM nginx:alpine

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ./dist/ /usr/share/nginx/html/
COPY nginx/nginx.tmpl /etc/nginx/
RUN chown -R nginx:nginx /usr/share/nginx/html/

CMD ["dockerize", "-template", "/etc/nginx/nginx.tmpl:/etc/nginx/nginx.conf", "nginx", "-g", "daemon off;"]
