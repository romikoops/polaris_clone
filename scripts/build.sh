#!/bin/sh

set -e

: ${DOCKER_REGISTRY}
: ${CI_COMMIT_REF_SLUG}
: ${CI_COMMIT_SHA}

# Build api
echo '--> Building API'
date
docker pull ${DOCKER_REGISTRY}/ci/imc-api-builder:${CI_COMMIT_REF_SLUG} || true
docker pull ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_REF_SLUG} || true

docker build \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-api-builder:${CI_COMMIT_REF_SLUG} \
  --tag ${DOCKER_REGISTRY}/ci/imc-api-builder:${CI_COMMIT_REF_SLUG} \
  --target builder \
  .

docker build \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-api-builder:${CI_COMMIT_REF_SLUG} \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_REF_SLUG} \
  --tag ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_SHA} \
  --tag ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_REF_SLUG} \
  .
date

# Build client
echo '--> Building Client'
date
docker pull ${DOCKER_REGISTRY}/ci/imc-client-builder:${CI_COMMIT_REF_SLUG} || true
docker pull ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_REF_SLUG} || true
docker build \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-client-builder:${CI_COMMIT_REF_SLUG} \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_REF_SLUG} \
  --tag ${DOCKER_REGISTRY}/ci/imc-client-builder:${CI_COMMIT_REF_SLUG} \
  --build-arg RELEASE=${CI_COMMIT_SHA} \
  --build-arg SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN} \
  --target builder \
  client/
docker build \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-client-builder:${CI_COMMIT_REF_SLUG} \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_REF_SLUG} \
  --tag ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_SHA} \
  --tag ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_REF_SLUG} \
  --build-arg RELEASE=${CI_COMMIT_SHA} \
  --build-arg SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN} \
  client/
date

# Build QA
echo '--> Building QA'
date
docker pull ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_REF_SLUG} || true
docker build \
  --cache-from ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_REF_SLUG} \
  --tag ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_SHA} \
  --tag ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_REF_SLUG} \
  qa/
date

# Push images
docker push ${DOCKER_REGISTRY}/ci/imc-api-builder:${CI_COMMIT_REF_SLUG}
docker push ${DOCKER_REGISTRY}/ci/imc-client-builder:${CI_COMMIT_REF_SLUG}
docker push ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_SHA}
docker push ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_REF_SLUG}
docker push ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_SHA}
docker push ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_REF_SLUG}
docker push ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_SHA}
docker push ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_REF_SLUG}
