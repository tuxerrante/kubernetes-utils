#!/bin/bash
########################################################
#### INSTALL MINIKUBE IN A CENTOS 7 VIRTUAL MACHINE


########################################################
####  UPDATE OS
sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install conntrack socat bash-completion


########################################################
#### DOCKER
# sudo echo nothing 2>/dev/null 1>/dev/null || alias sudo='$@'

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF' 
[docker-ce-edge]
name=Docker CE Edge - $basearch
baseurl=https://download.docker.com/linux/centos/7/$basearch/edge
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF

sudo yum install -y docker-ce 

# Add the current user to the group docker
sudo usermod -a -G docker "$(whoami)"

# Don't use multiple resource managers, only systemd
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

########################################################
####  MINIKUBE

sudo systemctl enable --now libvirtd
sudo usermod -a -G libvirt "$(whoami)"

sudo systemctl enable kubelet

### reload groups
sudo su - "$(whoami)"

### now you can start Docker
sudo systemctl enable --now docker

# vi /etc/libvirt/libvirtd.conf
sudo sed -i	's|#unix_sock_group = "libvirt"|unix_sock_group = "libvirt"|'  /etc/libvirt/libvirtd.conf
sudo sed -i	's|#unix_sock_rw_perms = "0770"|unix_sock_rw_perms = "0770"|' /etc/libvirt/libvirtd.conf

sudo systemctl restart libvirtd

wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

minikube version

########################################################
#### KUBECTL
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s  https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl  /usr/local/bin/
kubectl version --client -o json

########################################################
####  MINIKUBE START
# localip=$(hostname -I |awk '{print $1}' |tr -d ' ')

# minikube start
## To delete old configurations: minikube delete --all

# Disable SWAP
sudo swapoff -a
sed -i 's/^\(.*swap.*\)$/#\1/' /etc/fstab 

# Enable IP Forwarding
# echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#### Enable auto completion
echo '
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
' >> ~/.bashrc

#### Alternative 
# sudo su
# /usr/local/bin/kubectl completion bash | tee - > /etc/bash_completion.d/kubectl
# exit

source ~/.bashrc

# minikube start --vm-driver=none
minikube start --vm-driver=docker



########################################################
#### LOW LEVEL API SERVER CHECK
API_SERVER_SECURE_PORT=$(kubectl describe pod -n kube-system kube-apiserver-centos7 |grep -- "--secure-port" |sed 's/.*=//')

curl -i https://127.0.0.1:${API_SERVER_SECURE_PORT}/readyz --cacert /var/lib/minikube/certs/ca.crt 

#### HIGH LEVEL 
kubectl cluster-info



####################################
## ERRORS AND WARNINGS
:'
[WARNING Firewalld]: firewalld is active, please ensure ports [8443 10250] are open or your cluster may not function correctly
	minikube start --apiserver-port


[WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'

[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	>> https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
	>> native.cgroupdriver=systemd


[WARNING Swap]: running with swap on is not supported. Please disable swap
	> sudo swapoff -a

[WARNING FileExisting-socat]: socat not found in system path

[WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'

'

## If you want to install directly kubernetes look at this article
#  https://medium.com/platformer-blog/kubernetes-on-centos-7-with-firewalld-e7b53c1316af