#!/bin/bash

IMAGE_NAME="nginx-app"
IMAGE_TAG="latest"

echo "Building image with tag: $IMAGE_TAG"

docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest

echo "Build completed: ${IMAGE_NAME}:${IMAGE_TAG}"
