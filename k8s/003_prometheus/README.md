# Prometheus with Nana

Prometheus is an open-source monitoring and alerting system designed for cloud-native applications, especially those running on Kubernetes.
It collects metrics from configured targets (like applications, servers, or services), stores them in a time-series database, and allows powerful querying and visualization.

## Youtube URL
https://youtu.be/QoDqxm7ybLc?si=oubYaIDGgEOtDUSK


## helm features
* Package manager and helm charts
* Templating Engine
* Use Cases for helm
* Helm chart structure
* Values injection into template files
* Release management / Tiller (helm version 2, in v3 removed)


## GitHub Prometheus-operator
https://github.com/prometheus-community/helm-charts
https://github.com/ChristianLempa/cheat-sheets/blob/main/tools/helm.md


## helm links
| URL                                | description                |
| :--------------------------------- | :------------------------- |
| https://hub.helm.sh                | helm hub                   |
| https://github.com/helm/charts     | helm charts GitHub project |
| https://helm.sh/docs/intro/install | helm install               |




## Commands

### cluster deployment steps
1. brew install helm
2. kind create cluster --config kind-config.yaml
3. helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
4. helm repo update
5. helm install prometheus prometheus-community/kube-prometheus-stack
6. kubectl get pod
7. kubectl get all


### cluster delete
1. kind delete cluster
