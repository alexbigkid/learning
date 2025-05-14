# Kubernetes crash course with Nana

## Youtube URL
https://www.youtube.com/watch?v=X48VuDVv0do&list=PLJSyNCHeOq4b0QzjTbr1VALFnj0TbxuiE&index=35&t=4576s

## Commands

### cluster deployment steps
1. kind create cluster --config kind-config.yaml
2. kubectl apply -f mongo-secret.yaml
3. kubectl apply -f mongo-config.yaml
4. kubectl apply -f mongo.yaml
5. kubectl apply -f mongo-express.yaml

### kubectl discovery
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/kubectl.md

1. kubectl get pod
2. kubectl get node -o wide
3. kubectl get replicaset
4. kubectl logs <pod_name>
5. kubectl exec -it <pod_name> -- /bin/bash
6. kubectl describe pod <pod_name>
7. kubectl apply -f <file_name.yaml>
8. kubectl port-forward service/mongo-express-service 8081:8081
9. open http://localhost:8081

### cluster delete
1. kubectl delete -f <file_name.yaml>
2. kubectl delete deployment <deployment_name>
3. kubectl delete all --all
4. kind delete cluster
