
Download Multipass for Win https://multipass.run/.  

POWERSHELL
```
multipass launch --name master-k8s --cpus 2 --mem 2048M --disk 5G
multipass launch --name worker-1-k8s --cpus 2 --mem 2048M --disk 5G
multipass launch --name worker-2-k8s --cpus 2 --mem 2048M --disk 5G
```


Exec init commands
10.34.168.6 Will be my DNS for my VPN connection
It can be used also "multipass transfer .\multipass-init-masterk8s.sh master-k8s:init-masterk8s.sh"
```
multipass exec master-k8s -- bash -c "echo nameserver 10.34.168.6 | sudo tee /etc/resolv.conf  && curl -sO https://raw.githubusercontent.com/tuxerrante/kubernetes-utils/main/local-install/multipass/multipass-init-masterk8s.sh  && chmod +x multipass-init-masterk8s.sh  && ./multipass-init-masterk8s.sh"

```

Add workers to the cluster
```
multipass launch --name worker-1 --cpus 2 --mem 1000M --disk 5G

--first worker node --
multipass exec worker-1 -- bash -c "echo nameserver 10.34.168.6 | sudo tee /etc/resolv.conf  && curl -sO https://raw.githubusercontent.com/tuxerrante/kubernetes-utils/main/local-install/multipass/multipass-init-worker.sh  && chmod +x multipass-init-worker.sh  && ./multipass-init-worker.sh"

multipass shell worker-1-k8s

-- Generate a new token:
multipass exec master-k8s -- sudo kubeadm token generate
uklc8y.z2eiylcmg8oo4c5u

-- Print join command to use for all other workers:
kubeadm token create uklc8y.z2eiylcmg8oo4c5u --print-join-command --ttl=0
```

Take the kubeconfig and put it on your local Windows machine: 
multipass shell master-k8s
cat .kube/config

On WSL:
  kubectl config --kubeconfig=/mnt/c/Users/affinito/.kube/multipass-local.kubeconfig cluster-info

PowerShell:
  kubectl --kubeconfig=C:\Users\affinito\.kube\multipass-local.kubeconfig cluster-info

