
FROM jenkins/jenkins:2.263.3
LABEL maintainer=”aaffinito”

USER root
RUN mkdir /var/log/jenkins \
   && chown -R jenkins:jenkins /var/log/jenkins \
   && mkdir /var/cache/jenkins \
   && chown -R jenkins:jenkins /var/cache/jenkins \
   && useradd --no-create-home -G jenkins nginx \
   && rm -rf /var/jenkins_home/war
USER jenkins

ENV JAVA_OPTS="-Xmx8192m"
ENV JENKINS_OPTS="--handlerCountMax=300 --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"


