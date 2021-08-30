#!/bin/bash

# Update your dns based on your laptop network
sudo tee /etc/resolv.conf <<EOF
nameserver 10.34.168.6
nameserver 8.8.8.8
EOF

sudo apt update

#--- Install Docker ---
curl -fsSL https://get.docker.com -o get-docker.sh \
    sudo sh get-docker.sh \
    sudo usermod $USER -aG docker
  
#--- Add Repo to the list and install Kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubeadm

sudo swapoff -a

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#--- Flannel CNI
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

