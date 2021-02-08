#!/bin/bash


docker build -t nginx-proxy .

# Custom nginx configuration is already loaded from the Dockerfile
docker run -d --name=nginx-proxy -p 80:80 nginx
