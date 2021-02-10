#!/bin/bash
###########################################################

###########################################################
# Jenkins building
# Attach the jenkins container to the network
docker stop jenkins-master
docker rm jenkins-master
# Delete all your data!
# docker volume rm jenkins-data jenkins-log 

source ./jenkins/package-and-run-jenkins.sh

###########################################################
# NGINX
source nginx/clean-nginx.sh
source nginx/package-nginx.sh

###########################################################
# Firewall
# sudo firewall-cmd --zone=public --add-port=80/tcp --permanent 
# sudo firewall-cmd --reload 

###########################################################
# TEST
# Change the password
echo "=> Testing connectivity from nginx-proxy container to jenkins-master.."
sleep 2
docker exec nginx-proxy curl -I -stderr --user admin:admin --retry 2 --retry-delay 2 http://jenkins-master:8080 