#!/bin/bash

set -e

echo "Deploying the application..."

docker pull arasakumar786/dev:latest

docker compose down || true
docker compose up -d

echo "Deployment completed!"
echo "App running at http://localhost:3000 "
