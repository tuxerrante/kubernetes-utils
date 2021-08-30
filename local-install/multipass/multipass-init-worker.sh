#!/bin/bash

# https://askubuntu.com/a/974482
sudo tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=10.34.168.6
#FallbackDNS=
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#DNSOverTLS=no
#Cache=no-negative
#DNSStubListener=yes
#ReadEtcHosts=yes
EOF

sudo rm -f /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved.service

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl

sudo apt remove docker docker-engine docker.io containerd runc

#--- Install Docker ---
echo "> Installing Docker"

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

curl -fsSL https://get.docker.com -o get-docker.sh \
    && sudo sh get-docker.sh \
    && sudo groupadd docker \
    && sudo usermod -aG docker $USER \
    && newgrp docker \
    && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R \
    && sudo chmod g+rwx "$HOME/.docker" -R


#--- Add Repo to the list and install Kubeadm
echo "> Installing kubelet kubeadm kubectl"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
  && sudo apt-get update  \
  && sudo apt-get install -qy kubelet kubeadm kubectl

sudo swapoff -a

