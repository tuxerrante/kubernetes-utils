####
# References
# https://github.com/tuxerrante/kubernetes-utils/blob/main/deploy-and-expose-app.sh
# https://docs.cilium.io/en/v1.8/gettingstarted/minikube/
# https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/cilium-network-policy/

#### Install minikube and enable CNI
#   starts directly with Cilium if minikube>=1.12
#   otherwise
# https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/cilium-network-policy/
# kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml
minikube start --cni=cilium --memory=4096

minikube ssh -- sudo mount bpffs -t bpf /sys/fs/bpf
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml

kubectl get pods --namespace=kube-system

####
# kubectl create deployment echo --image=gcr.io/google-containers/echoserver:1.10 -o yaml --dry-run=client > echo-deployment.yaml
kubectl apply -f echo-deployment.yaml

####
kubectl expose deployment echo --port=8080 --name=echo-cluster --type=NodePort

export ECHO_SERVICE_NODEPORT=$(kubectl get service echo-cluster -o=jsonpath='{.spec.ports[0].nodePort}')
curl -i http://$(minikube ip):${ECHO_SERVICE_NODEPORT}

####
kubectl get pods --show-labels

kubectl edit pod CHOOSE_ONE_POD
# change the label 
# testing=false --> true

####
kubectl get pods -l 'testing in (true, false)'

### Apply network policy
# check the CIDR to exclude before applying the resource!
# example on mac > 
#   $ ip addr show bridge100 |grep "inet "

kubectl apply -f echo-network-policy.yaml

### Test
curl -i --stderr - http://$(minikube ip):${ECHO_SERVICE_NODEPORT} |grep "pod name:"

# Not having a routing, calls going to the other pods will just end in time-out
