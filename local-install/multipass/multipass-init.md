
Download Multipass for Win https://multipass.run/.  

POWERSHELL
```
multipass launch --name master-k8s --cpus 2 --mem 2048M --disk 5G
multipass launch --name worker-1-k8s --cpus 2 --mem 2048M --disk 5G
multipass launch --name worker-2-k8s --cpus 2 --mem 2048M --disk 5G
```


Exec init commands
10.34.168.6 Will be my DNS for my VPN connection
```
multipass exec master-k8s -- bash -c "echo nameserver 10.34.168.6 | sudo tee /etc/resolv.conf  && curl -sO https://raw.githubusercontent.com/tuxerrante/kubernetes-utils/main/local-install/multipass/multipass-init-masterk8s.sh  && chmod +x multipass-init-masterk8s.sh  && ./multipass-init-masterk8s.sh"

```

Add workers to the cluster
```
--first worker node --
multipass shell worker-1-k8s
sudo kubeadm join 10.158.117.108:6443 --token 1liumq.jz56jwd81qqxfplb \
    --discovery-token-ca-cert-hash sha256:<TOKEN-YOU-HAVE-FROM-ABOVE>
exit

--second worker node  --
multipass shell worker-2-k8s
sudo kubeadm join 10.158.117.108:6443 --token 1liumq.jz56jwd81qqxfplb \
    --discovery-token-ca-cert-hash sha256:<TOKEN-YOU-HAVE-FROM-ABOVE>
exit
```