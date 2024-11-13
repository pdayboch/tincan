#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | xargs)
else
  echo ".env file not found. Please create one with DOCKER_HUB_USERNAME set."
  exit 1
fi

# Variables
IMAGE_NAME="tincan-backend"
TAG="latest"

# Check if the Docker Hub username is set
if [ -z "$DOCKER_HUB_USERNAME" ]; then
  echo "DOCKER_HUB_USERNAME is not set. Please add it to the .env file."
  exit 1
fi

docker build -t $DOCKER_HUB_USERNAME/$IMAGE_NAME:$TAG .

docker push $DOCKER_HUB_USERNAME/$IMAGE_NAME:$TAG