FROM nginx:stable

RUN  apt -y update && apt -y install vim procps
# COPY nginx.conf /etc/nginx/nginx.conf
COPY jenkins.conf /etc/nginx/conf.d/jenkins.conf
