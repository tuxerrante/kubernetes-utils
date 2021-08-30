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

"""
# Update your dns based on your laptop network
sudo tee /etc/resolv.conf <<EOF
nameserver 10.34.168.6
nameserver 8.8.8.8
EOF
"""
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

# https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
cat > kubeadm-config.yaml <<EOF 
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.22.1
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
podCIDR: 10.244.0.0/16
EOF

# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 
sudo kubeadm init --config kubeadm-config.yaml

mkdir -p $HOME/.kube
sudo cp --force /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#--- Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# https://github.com/flannel-io/flannel/issues/1344#issuecomment-867265435
kubectl patch node $(hostname) -p '{"spec":{"podCIDR":"10.244.0.0/16"}}'
kubectl delete pod -n kube-system -l app=flannel

############################
#### RESET 
# kubectl config delete-cluster kubernetes && sudo kubeadm reset && kubectl delete node master-k8s && sudo rm -rf /etc/cni/net.d