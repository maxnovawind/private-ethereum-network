# Private Ethereum Network

## Prerequisites

```
- docker
- kind
- kubectl
- helm
- terraform
```
## Setup

```
├── LICENSE
├── README.md
├── argo-apps
│   └── local
│   	├── admin-apps
│   	├── monitoring-apps
│   	└── ethereum-apps
├── docs
│   ├── Architcture-blockchain.md
│   ├── Architecture-monitoring.md
│   ├── Setup-blockchain.md
│   ├── Setup-monitoring.md
│   └── images
├── helm-charts
│   ├── argocd
│   ├── ethereum
│   ├── external-secrets
│   ├── gateway
│   └── monitoring
└── terraform
    ├── local
    └── modules
```

The structure of the infrastructure is divided into 4 directories:
- `argo-apps`: Argo CD applications which stores the argocd applications/applicationsets : theses applications will be synced into the cluster by using gitops approach. 
- `helm-charts`: Helm charts which declare the k8s resources/deployments/services/... that compose the infrastructure.
- `terraform`: it seperate into multiple directories to install multiple infrastructure in different environnements (i.e. local/dev/staging/prod). Modules directory contains reusable terraform code that can be used across different environments.
- `docs`: documentation/setup guide of the project


## Deploy the infrastructure

Select the environment you want to deploy. In our case we will focus on `local` inside terraform directory: 

```
cd terraform/local

terraform init
terraform apply
```

The infrastructure will deploy the following services:
- kind cluster
- argocd with 3 entries points of app of applications:
	- admin-apps
	- monitoring-apps
	- ethereum-apps

Theses app of applications will be synchronized into the cluster by using gitops approach.

## Connect to argocd ui

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```
kubectl port-forward -n argocd svc/argocd-server 8080:80
```

Open http://localhost:8080 and use the credentials retrieved in the previous step to login.


## Deploy the monitoring/logging stack

Read the [Architecture-monitoring.md](./docs/Architecture-monitoring.md) and [Setup-monitoring.md](./docs/Setup-monitoring.md) documentation.

## Deploy the private ethereum network

Read the [Architecture-blockchain.md](./docs/Architecture-blockchain.md) and [Setup-blockchain.md](./docs/Setup-blockchain.md) documentation.

## Destroy the infrastructure


**Warning**: Be careful, you have to make sure that no argocd application is running before destroying the infrastructure.

```
cd terraform/local
terraform destroy
```

## Extend the infrastructure

### Add a new environment

In this example we will add a new staging environment.

Create a new directory in the terraform/staging directory:
```
mkdir -p terraform/staging
```

Create a new directory in the argocd/staging directory:

```
mkdir -p argocd/staging/admin-apps
mkdir -p argocd/staging/monitoring-apps
mkdir -p argocd/staging/ethereum-apps
```

**Warning**: It is important to create new values.staging.yaml file for each application that will be deployed in the staging environment.

### Add a new app of applications

Update the helm-charts/argocd/values.local.yaml file to add the new application:

```
app_of_apps:
  - name: <application-name>
    project: default
    source:
      repoURL: <repository-url>
      targetRevision: <branch-name>
      path: <application-path>
    destination:
      namespace: argocd
      name: in-cluster
```
