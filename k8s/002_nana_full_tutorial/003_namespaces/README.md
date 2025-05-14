# Kubernetes crash course with Nana

## Youtube URL
https://www.youtube.com/watch?v=X48VuDVv0do&list=PLJSyNCHeOq4b0QzjTbr1VALFnj0TbxuiE&index=35&t=6376s

## Commands

### cluster deployment steps
1. kind create cluster --config kind-config.yaml


### kubectl discovery
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/kubectl.md

1. kubectl cluster-info
2. kubectl create namespace <namespace_name>
3. kubectl get namespace
4. kubectl --namespace <namespace_name> get pod

## sticky context/namespace switching
using always --namespace <namespace_name> is a pain. In order to avoid this a extra tool can be installed: <code>kubectx</code>
<code>brew install kubectx</code>


### context

| context command       | explanation              |
| :-------------------- | :----------------------- |
| kubectx               | view all contexts        |
| kubectx cname1        | switch context to cname1 |
| kubectx cname1=cname2 | rename cname1 to cname2  |
| kubectx -d cname2     | delete context cname2    |


### namespace

| namespace command      | explanation                         |
| :--------------------- | :---------------------------------- |
| kubens                 | view all namespace                  |
| kubens namespace_name1 | switch namespace to namespace_name1 |


### cluster delete
1. kubectl delete -f <file_name.yaml>
2. kubectl delete deployment <deployment_name>
3. kubectl delete all --all
4. kind delete cluster
