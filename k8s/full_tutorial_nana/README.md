# Kubernetes crash course with Nana

## Youtube URL
https://youtu.be/X48VuDVv0do?si=ciQiZ8ric9mCq64Z

## Commands

### cluster deployment steps
1. kind create cluster --config kind-config.yaml
2. kubectl create nginx-depl --image=nginx
3. kubectl create mongo-depl --image=mongo

### kubectl discovery
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/kubectl.md

1. kubectl get pod
2. kubectl get node -o wide
3. kubectl get replicaset
4. kubectl logs <pod_name>
5. kubectl exec -it <pod_name> -- /bin/bash
6. kubectl describe pod <pod_name>
7. kubectl apply -f <file_name.yaml>

### cluster delete
1. kubectl delete -f <file_name.yaml>
2. kubectl delete deployment <deployment_name>
3. kind delete cluster
