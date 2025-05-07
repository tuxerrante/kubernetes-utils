FROM nginx:1.28.0-alpine3.21-slim

RUN  apt -y update && apt -y install vim procps
# COPY nginx.conf /etc/nginx/nginx.conf
COPY jenkins.conf /etc/nginx/conf.d/jenkins.conf
