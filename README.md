# kubernetes-utils
This is a raw collection of repos and scripts to simplify kubernetes administration or learning.

This repo has submodules, so to clone it all use --recursive arg:  
`git clone --recursive https://github.com/tuxerrante/kubernetes-utils`

- https://github.com/tuxerrante/ckad-crash-course
- https://github.com/tuxerrante/CKA-practice-exercises
- https://github.com/tuxerrante/ckad
- minikube scripts
- trainings (below)

## Online best free trainings
- https://learnk8s.io/troubleshooting-deployments
- https://cloud.google.com/kubernetes-engine/docs/tutorials
- https://kodekloud.com/courses/certified-kubernetes-administrator-with-practice-tests/lectures/9808161
- https://github.com/kodekloudhub/certified-kubernetes-administrator-course
- https://www.edx.org/course/introduction-to-kubernetes
- https://learning.oreilly.com/videos/certified-kubernetes-administrator
- https://killer.sh/

## Init commands to memorize
`alias k=kubectl`
`export do="-o yaml --dry-run=client"`  

```
$ vim ~/.vimrc
set nu
set ic
set expandtab
set shiftwidth=2
set tabstop=2
set list
```

`kubectl config set-context <context-of-question> --namespace=<namespace-of-question>`
  
