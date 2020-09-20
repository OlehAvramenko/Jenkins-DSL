#!/bin/bash
GIT_TAG=`git tag --points-at HEAD`
# CHECK TAG FOR IMAGE
[ -z "${GIT_TAG}" ] && TAG=${BUILD_NUMBER} || TAG=${GIT_TAG}_${BUILD_NUMBER}
aws ecr get-login-password --region=${REGION} | docker login --username AWS --password-stdin ${REGISTRY}
docker tag petclinic-app:${BUILD_NUMBER} ${REGISTRY}:${TAG}
docker push ${REGISTRY}:$TAG
docker tag petclinic-app:${BUILD_NUMBER} ${REGISTRY}:latest
docker push ${REGISTRY}:latest
