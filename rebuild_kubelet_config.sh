#!/bin/bash
########################################################
# For minikube you can change the node port range with a parameter
# minikube start --extra-config=apiserver.service-node-port-range=20000-22767

# For kubernetes
#	http://www.thinkcode.se/blog/2019/02/20/kubernetes-service-node-port-range
vim /etc/kubernetes/manifests/kube-apiserver.yaml 
# add under spec/container/command:
# 	--service-node-port-range=20000-22767

# You can use the port-forward command in kubectl to connect to the Service and test the connection.
#     kubectl port-forward service/<service name> 3000:80


kubectl proxy --port=8001 &

# NODE_NAME=$(kubectl get nodes -o custom-columns=:.metadata.name --no-headers|tr -d '\n')
NODE_NAME=$(kubectl get nodes |grep master |awk '{print $1}' |tr -d '\n')

# Retrieve config from api
curl -sSL "http://localhost:8001/api/v1/nodes/${NODE_NAME}/proxy/configz" | jq '.kubeletconfig|.kind="KubeletConfiguration"|.apiVersion="kubelet.config.k8s.io/v1beta1"' > kubelet_configz_${NODE_NAME}.json

# Example
# http://127.0.0.1:8001/api/v1/nodes/centos7/proxy/configz


########################################################
#### BUILD NEW CONFIG
NEW_CONFIG="custom_config"

# yq is a yaml wrapper for jq
sudo yum install -y python3-pip
pip3 install --user yq

# Add kind and api version to the new YAML
echo "
apiVersion: v1
kind: ConfigMap
" > kubelet_configz_${NODE_NAME}.yml

# Append original kubelet configurations
cat kubelet_configz_centos7.json | yq --yaml-output >> kubelet_configz_${NODE_NAME}.yml

## EDIT the file
# 	do your customizations..
# 	For minikube you can test switching the kubelet port from 10250 to 10255
# 	Remember to check if that port is free on the node/your system
# sed -i 's/port: 10250/port: 10255/' kubelet_configz_centos7.yml 

## Push the file as a new configMap
kubectl -n kube-system create configmap $NEW_CONFIG --from-file=kubelet=kubelet_configz_${NODE_NAME}.yml --append-hash -o yaml

## Get the resource assigned name (eg: custom-config-f7td6hh66g)
#	This command gives an error if you have multiple configmap names starting with $NEW_CONFIG
NEW_CONFIG_RESOURCE=$(k get configmap -n kube-system -o custom-columns=:.metadata.name --no-headers |grep $NEW_CONFIG |tr -d '\n')

kubectl edit node ${NODE_NAME}
# add the following YAML under 'spec':
# AND REPLACE THE NAME
:'
  configSource:
    configMap:
      name: $NEW_CONFIG_RESOURCE
      namespace: kube-system
      kubeletConfigKey: kubelet

'

kubectl get nodes $NODE_NAME -o yaml |less

sudo ss -plnt |grep kubelet


########################################################
#### ETCD
MY_IP=$(hostname -I |awk '{print $1}'|tr -d ' ')

ETCDCTL_API=3;

#### Get all keys
sudo -E etcdctl --endpoints ${MY_IP}:2379 \
	--cacert='/var/lib/minikube/certs/etcd/ca.crt' \
	--cert='/var/lib/minikube/certs/etcd/peer.crt' \
	--key='/var/lib/minikube/certs/etcd/peer.key' \
	get / --prefix --keys-only

#### Save alias
alias etcdctl_mini="MY_IP=$(hostname -I |awk '{print $1}'|tr -d ' '); \
	ETCDCTL_API=3; \
	sudo -E etcdctl --endpoints ${MY_IP}:2379 \
	--cacert='/var/lib/minikube/certs/etcd/ca.crt' \
	--cert='/var/lib/minikube/certs/etcd/peer.crt' \
	--key='/var/lib/minikube/certs/etcd/peer.key'"





