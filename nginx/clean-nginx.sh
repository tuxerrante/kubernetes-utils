#!/bin/bash
echo "> Removing nginx-proxy image"
docker stop nginx-proxy
docker rm nginx-proxy
# docker network rm jenkins-net

