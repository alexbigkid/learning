# Kubernetes crash course with Nana

<b>NOT WORKING YET</b>

## Youtube URL
https://www.youtube.com/watch?v=X48VuDVv0do&list=PLJSyNCHeOq4b0QzjTbr1VALFnj0TbxuiE&index=35&t=7312s

## INgress Controllers
https://bit.ly/32dfHe3

## Commands

### cluster deployment steps
1. kind create cluster --config kind-config.yaml
2. ./kind-ingress-start.sh


### kubectl discovery
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/kubectl.md


## helm installation
Helm is a package manager for Kubernetes, similar to how apt works for Ubuntu or yum for CentOS. It simplifies the deployment and management of applications on Kubernetes by allowing you to define, install, and upgrade applications using Helm charts.
<code>brew install helm</code>


### cluster delete
1. ./kind-ingress-stop.sh
4. kind delete cluster
