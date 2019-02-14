#!/bin/sh

set -eu

: ${DOCKER_REGISTRY}
: ${CI_COMMIT_REF_SLUG}
: ${CI_COMMIT_SHA}

# Build api
echo '--> Building API'
date
docker run \
    -v ${GOOGLE_APPLICATION_CREDENTIALS}:/${GOOGLE_APPLICATION_CREDENTIALS} \
    -v ${CI_PROJECT_DIR}:/workspace \
    -e GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} \
    gcr.io/kaniko-project/executor:latest \
    --cache \
    --dockerfile Dockerfile \
    --destination ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_REF_SLUG} \
    --destination ${DOCKER_REGISTRY}/ci/imc-api:${CI_COMMIT_SHA}
date

echo '--> Building Client'
date
docker run \
    -v ${GOOGLE_APPLICATION_CREDENTIALS}:/${GOOGLE_APPLICATION_CREDENTIALS} \
    -v ${CI_PROJECT_DIR}/client:/workspace \
    -e GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} \
    gcr.io/kaniko-project/executor:latest \
    --build-arg RELEASE=${CI_COMMIT_SHA} \
    --build-arg SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN} \
    --cache \
    --dockerfile Dockerfile \
    --destination ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_REF_SLUG} \
    --destination ${DOCKER_REGISTRY}/ci/imc-client:${CI_COMMIT_SHA}
date

# # Build QA
echo '--> Building QA'
date
docker run \
    -v ${GOOGLE_APPLICATION_CREDENTIALS}:/${GOOGLE_APPLICATION_CREDENTIALS} \
    -v ${CI_PROJECT_DIR}/qa:/workspace \
    -e GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} \
    gcr.io/kaniko-project/executor:latest \
    --build-arg RELEASE=${CI_COMMIT_SHA} \
    --build-arg SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN} \
    --cache \
    --dockerfile Dockerfile \
    --destination ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_REF_SLUG} \
    --destination ${DOCKER_REGISTRY}/ci/imc-qa:${CI_COMMIT_SHA}
date

echo 'All done.'
exit 0
