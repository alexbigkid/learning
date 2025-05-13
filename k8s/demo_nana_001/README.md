# Kubernetes crash course with Nana

## Youtube URL
https://youtu.be/s_o8dwzRlu4?si=3uvagjDP8hzng7o6

## Commands

### cluster deployment steps
1. kind create cluster --config kind-config.yaml
2. kubectl apply -f mongo-config.yaml
3. kubectl apply -f mongo-secret.yaml
4. kubectl apply -f mongo.yaml
5. kubectl apply -f webapp.yaml

### kubectl discovery
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/kubectl.md

1. kubectl get pod
2. kubectl get node -o wide
3. kubectl get svc
4. kubectl get service
5. kubectl get configmap
6. kubectl get secret


### cluster delete
1. kubectl delete all --all
2. kind delete cluster
