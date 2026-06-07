#!/bin/bash

set -e

echo "Deploying PROD application..."

docker pull arasakumar786/prod:latest

docker compose down || true
docker compose up -d

echo "Deployment completed!"
echo "App running at http://localhost:3000"
