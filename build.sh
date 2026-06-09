#!/bin/bash
export DOCKER_BUILDKIT=0
echo "Building image with tag: latest"
docker build -t nginx-app:latest .
echo "Docker build completed"
