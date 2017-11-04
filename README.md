# Mattermost build

Jenkins automation for building mattermost

### Command to hook up new kuberntes cluster to docker repository

```
kubectl create secret docker-registry myregistrykey --docker-server=mmjenkins.azurecr.io --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=dev-ops@mattermost.com
```

# Deploying the build server locally

## Prerequisites
- virtualization platform
- docker
- install `minikube`, `kubectl`, `helm` by following instructions here:
  - [minikube](https://github.com/kubernetes/minikube/releases)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - [helm](https://docs.helm.sh/helm/#helm-install)

## Overview

- startup minikube cluster
- deploy mattermost-build (Jenkins)
- run builds
- destroy minikube cluster

## Setup

```
minikube start
```
This will start a `minikube` environment with a default of 2GB and 2 cpus. These values can be set like this:
```
minikube start --memory 8192 --cpus 4 --mount
```
Config is stored in `~/.minikube`

enable ingress
```
minikube addons enable ingress
```

Add `helm` repos
```

```

Add `tiller` to the Kube cluster
```
helm init
```

Clone repo
```
git clone https://github.com/mattermost/mattermost-build.git
cd mattermost-build
```

Pull dependent charts
```
cd mattermost-jenkins
helm dep update
```

Looks like `mattermost-jenkins/charts/jenkins` & `mattermost-jenkins/requirements.lock` can be removed

## Deploy build server

Reuse the Docker daemon: [https://github.com/kubernetes/minikube](https://github.com/kubernetes/minikube/blob/0c616a6b42b28a1aab8397f5a9061f8ebbd9f3d9/README.md#reusing-the-docker-daemon)
```
eval $(minikube docker-env)
```

Now all `docker` commands on the host will actually run inside the `minikube` VM.

### Build the server in k8s
```
make deploy-local
```

Login to Jenkins using service URL
```
minikube service list
```

Launch the `minikube` dashboard
```
minikube dashboard
```

## Run build jobs

TBD

## Cleanup

```
make nuke
```

## Issues

- `build-mattermost-com-nginx-ingress-controller` service in pending state 

