
Download Multipass for Win https://multipass.run/.  

POWERSHELL
```
multipass launch --name master-k8s --cpus 2 --mem 2048M --disk 5G
multipass launch --name worker-1-k8s --cpus 2 --mem 2048M --disk 5G
multipass launch --name worker-2-k8s --cpus 2 --mem 2048M --disk 5G
```

While on VPN
```
multipass launch --name worker-1-k8s --cpus 2 --mem 2048M --disk 5G --network
```

Exec init commands
```
multipass exec master-k8s
```
Not working:
  Get-Content .\multipass-init-masterk8s.sh | multipass transfer -v - master-k8s:$HOME/init-masterk8s.sh
  multipass exec master-k8s multipass-init-masterk8s.sh


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