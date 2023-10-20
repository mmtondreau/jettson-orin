# jettson-orin


## K8 Setup

### Install k3s 
Setup k3s, use the --docker option

```
curl -sfL https://get.k3s.io | K3S_URL=https://<master>:6443 K3S_TOKEN=<token>  sh -s - --docker
```

https://docs.k3s.io/quick-start

### Install nginx

From manifest 
https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
https://github.com/nginxinc/kubernetes-ingress/

Install fullchain and private keys as secrets. See https://github.com/nginxinc/kubernetes-ingress/blob/main/examples/shared-examples/default-server-secret/default-server-secret.yaml
Note: get certificates from letsencypt.

### Build 

#### Configure password 
TODO: automate
jupyter notebook password
Copy ~/.jupyter/jupyter_server_config.json to checkout directory

#### Docker build
docker build -t registry.tonberry.org/pytorch:1.0 . 

Note: this assumes a local docker registry is deployed already at registry.tonberry.org

### Deploy
kubectl apply -f k8s
