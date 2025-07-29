# Kubernetes crash course with Nana

Helm is a package manager for Kubernetes, similar to how apt works for Ubuntu or yum for CentOS. It simplifies the deployment and management of applications on Kubernetes by allowing you to define, install, and upgrade applications using Helm charts.

## Youtube URL
https://www.youtube.com/watch?v=X48VuDVv0do&list=PLJSyNCHeOq4b0QzjTbr1VALFnj0TbxuiE&index=35&t=8657s


## helm features
* Package manager and helm charts
* Templating Engine
* Use Cases for helm
* Helm chart structure
* Values injection into template files
* Release management / Tiller (helm version 2, in v3 removed)


## helm cheat-sheets
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/helm.md


## helm links
| URL                                | description                |
| :--------------------------------- | :------------------------- |
| https://hub.helm.sh                | helm hub                   |
| https://github.com/helm/charts     | helm charts GitHub project |
| https://helm.sh/docs/intro/install | helm install               |




## Commands

### helm installation
| command                                             | OS           |
| :-------------------------------------------------- | :----------- |
| <code>brew install helm</code>                      | MacOS        |
| <code>sudo apt update; sudo apt install helm</code> | Linux Ubuntu |
| <code>choco install kubernetes-helm</code>          | Windows      |


### cluster deployment steps
1. kind create cluster --config kind-config.yaml


### cluster delete
4. kind delete cluster
