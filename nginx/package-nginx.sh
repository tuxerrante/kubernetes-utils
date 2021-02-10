#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "=> Building nginx-proxy image in $DIR"
docker build -t nginx-proxy $DIR/.

# Custom nginx configuration is already loaded from the Dockerfile
echo "=> Run nginx-proxy image"
docker run -d --name=nginx-proxy --network jenkins-net -p 80:80 nginx-proxy

docker logs nginx-proxy