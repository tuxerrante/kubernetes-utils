#!/bin/bash
#====================================

echo "=> Creating jenkins volumes.."
docker volume create jenkins-log
docker volume create jenkins-data

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "=> Building Jenkins image in $DIR"
docker build -t jenkins-master $DIR/.

###########################################################
# Connect to a given network
echo "=> Creating a network for proxying jenkins"
network_result=$(docker network create --driver bridge jenkins-net 2>&1)
if grep "already exists" <<< "$network_result"; then 
    echo "=> Network already created"
fi

###########################################################
# RUN
# port 8080 exposes the UI, remind to forward it to access from you browser
# port 50000 is to handle connections from JNLP based build workers.
# -v mounts a docker volume under the container path specified
# we give two jvm parameters to increase the memory heap maximum and to log on file
# increases the number of possible connections
# gives the container a name
# uses only long time support jenkins releases (in Dockerfile)
echo "=> Run Jenkins container"
docker run -p 8080:8080 -p 50000:50000 \
   -v jenkins-data:/var/jenkins_home \
   -v jenkins-log:/var/log/jenkins   \
   --network jenkins-net \
   --name jenkins-master \
   -d jenkins-master

###########################################################
# Save the startup password to login as admin
MAX_RETRIES=2
counter=0
while ! docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword; do
    if [[ $counter -le $MAX_RETRIES ]]; then
        echo "=> [#${counter}] Waiting for Jenkins admin psw.. "
        ((counter += 1))
        sleep 4
    else
        break
    fi
done

###########################################################
# MONITORING
# docker exec jenkins-master tail -f /var/jenkins_home/log/jenkins.log
# docker cp jenkins-master:/var/jenkins_home/log/jenkins.log jenkins.log


######################################################
# CREATE ADMIN USER
# CREATE YOUR FIRST JOB 
# docker stop jenkins-master && docker rm jenkins-master 
# DOCKER RUN ...
# ENJOY YOUR DATA COMING FROM THE PERSISTENT VOLUME :)


######################################################
### Triggering ArgoCD to deploy to Kubernetes with a Jenkins Pipeline
# https://yetiops.net/posts/argocd-jenkins-pipeline/
# https://github.com/argoproj/argo-cd/releases/download/v1.8.3/argocd-linux-amd64
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.8.3/manifests/ha/install.yaml


