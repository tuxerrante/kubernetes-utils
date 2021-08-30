#!/bin/bash

# Update your dns based on your laptop network
sudo tee /etc/resolv.conf <<EOF
nameserver 10.34.168.6
nameserver 8.8.8.8
EOF

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl

sudo apt-get remove docker docker-engine docker.io containerd runc

#--- Install Docker ---
curl -fsSL https://get.docker.com -o get-docker.sh \
    && sudo sh get-docker.sh \
    && sudo groupadd docker \
    && sudo usermod -aG docker $USER \
    && newgrp docker \
    && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R \
    && sudo chmod g+rwx "$HOME/.docker" -R
  
#--- Add Repo to the list and install Kubeadm
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
  && sudo apt-get update  \
  && sudo apt-get install -qy kubelet kubeadm kubectl

sudo swapoff -a

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#--- Flannel CNI
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

