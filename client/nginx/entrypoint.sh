#!/bin/sh

envsubst < /etc/nginx/nginx.tmpl > /etc/nginx/nginx.conf

exec "$@"
