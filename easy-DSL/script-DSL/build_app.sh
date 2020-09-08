#!/bin/bash
sudo chmod 666 /var/run/docker.sock
[ ! -d "${WORKSPACE}/.m2" ]  && mkdir -p ${WORKSPACE}/.m2
# ============== COPY DEPENDENCIES ==============
aws s3 sync  s3://${BUCKET}/.m2 ${WORKSPACE}/.m2/
# =========== BUILD ===============
DOCKER_BUILDKIT=1 docker build . -t petclinic-app:${BUILD_NUMBER} -f docker/docker_APP/Dockerfile --progress=plain
aws s3 sync ${WORKSPACE}/.m2/ s3://${BUCKET}/.m2
