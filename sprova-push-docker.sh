#!/bin/bash
echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin
sudo docker push $DOCKER_USERNAME/sprova
