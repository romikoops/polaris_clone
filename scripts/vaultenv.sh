#!/bin/sh

set -ex

: ${VAULT_TOKEN_FILE:=/var/run/secrets/vault/token}
: ${CONSUL_CONFIG:=/etc/vault/consul-template-config.hcl}

# Check if running inside Vault Environment
if [ -e ${VAULT_TOKEN_FILE} ]; then
  exec env VAULT_TOKEN=$(cat ${VAULT_TOKEN_FILE}) /bin/envconsul -config="${CONSUL_CONFIG}" "$@"
else
  exec "$@"
fi
