#!/bin/bash
####====================================
####  exposition of an echo app

### Our development team relase a new image!
# docker run -p 5678:5678 hashicorp/http-echo -text="hello world"

### Create a new namespace to be clean
kubectl create ns echo-test

kubectl create deployment -n test echo --image=gcr.io/google-containers/echoserver:1.10 --port=8080 -o yaml --dry-run=client > echo-deployment.yaml


vim echo-deployment.yaml
# Don't use tabs!
# Under container name add:
:'
env:
  - name: NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: POD_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
'

kubectl apply -f echo-deployment.yaml

###  ! Relaunch these two commands every time you restart or delete the deployment !
export ECHO_POD_NAME=$(kubectl -n test get pods |grep echo |awk '{print $1}')
export ECHO_POD_IP=$(kubectl -n test get pod $ECHO_POD_NAME --no-headers -o custom-columns=:.status.podIPs[0].ip)


###  1. test from inside the POD
kubectl -n test exec $ECHO_POD_NAME -- curl -sI http://127.0.0.1:8080

###  Or from a new debug container
# kubectl debug -n echo-test -it busybox_debug --image=busybox --target=$ECHO_POD_NAME


##################################################
###  2. Cluster-IP Service
# if no port is specified via --port and the exposed resource has multiple ports, 
# 	all will be re-used by the new service. Also if no labels are specified, 
# 	the new service will re-use the labels from the resource it exposes.
kubectl expose -n test deployment echo --name=echo-cluster

export ECHO_SVC_IP=$(kubectl -n test get svc echo-cluster --no-headers -o custom-columns=:.spec.clusterIP)
echo  $ECHO_SVC_IP 	# 10.102.165.49


###  test from inside the NODE CLUSTER
# kubectl run alpine -it --image=alpine --rm --restart=Never -- sh
kubectl run busybox -it --image=busybox --rm --restart=Never -- sh   
# wget -q0- 172.17.0.3:8080 		# POD
# wget -q0- 10.102.165.49:8080		# SERVICE


###  You can do it also from the API server if you start a proxy
kubectl proxy &
sudo ss -plnt |grep 8001
curl -si http://127.0.0.1:8001/api/v1/namespaces/echo-test/pods/${ECHO_POD_NAME}/proxy/
curl -si http://127.0.0.1:8001/api/v1/namespaces/echo-test/services/echo-cluster/proxy/



##################################################
### NodePort Service
kubectl expose -n test service echo-cluster --type=NodePort --name=echo-np

kubectl exec -n test $ECHO_POD_NAME env
kubectl exec -n test $ECHO_POD_NAME -- wget localhost:8080

## From outside the cluster
export ECHO_NODE_PORT=$(kubectl -n test get services/echo-np -o go-template='{{(index .spec.ports 0).nodePort}}')

# It should be not needed
# sudo firewall-cmd --zone=public --permanent --add-port=$ECHO_NODE_PORT/tcp
# sudo firewall-cmd --reload 
# You should see kube-proxy listening on the node
sudo ss -plnt |grep 22
#LISTEN     0      128          *:21222                    *:*                   users:(("kube-proxy",pid=19491,fd=10))


# Replace 'minikube ip' with your exteranl master node IP, if you have one
curl $(minikube ip):${ECHO_NODE_PORT}

###====================================