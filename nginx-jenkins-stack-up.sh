#!/bin/bash

###########################################################

###########################################################
# Jenkins building
# Attach the jenkins container to the network
docker stop jenkins-master
docker rm jenkins-master

source ./jenkins/package-and-run-jenkins.sh

###########################################################
# NGINX
docker stop nginx-proxy
docker rm nginx-proxy
docker build -t nginx-proxy ./nginx

# Custom nginx configuration is already loaded from the Dockerfile
docker run -d --name=nginx-proxy --network jenkins-net -p 80:80 nginx

###########################################################
# Firewall
# sudo firewall-cmd --zone=public --add-port=80/tcp --permanent 
# sudo firewall-cmd --reload 

###########################################################
# TEST
# Change the password
docker exec nginx-proxy curl -I -stderr --user admin:admin http://jenkins-master:8080 