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

Get credentials for Jenkins
```
kubectl get secret build-mattermost-com-jenkins -o yaml
```
```yaml
apiVersion: v1
data:
  jenkins-admin-password: ZG9ZcDJ0QzZXZg==
  jenkins-admin-user: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: 2017-11-04T14:12:40Z
  labels:
    app: build-mattermost-com-jenkins
    chart: jenkins-0.8.9
    heritage: Tiller
    release: build-mattermost-com
  name: build-mattermost-com-jenkins
  namespace: default
  resourceVersion: "15793"
  selfLink: /api/v1/namespaces/default/secrets/build-mattermost-com-jenkins
  uid: 38049232-c16a-11e7-bb92-080027fb5028
type: Opaque
```

Decode password
```
echo "ZG9ZcDJ0QzZXZg==" | base64 --decode
```

Get service URL to login to Jenkins
```
minikube service list
```

## Run build jobs

Builds start running as soon as Jenkins is up. The current config pulls all branches from https://github.com/mattermost/mattermost-webapp and runs `build/Jenkinsfile`

## Cleanup

Delete all pods but leave `minikube` up for a new deployment
```
make delete
```

Delete everything and shutdown minikube
```
make nuke
```
 
## Issues

- Currently bypassing the ingress controller. Should either adjust to use the ingress, or just remove it from local builds.
- Change build job to stop it pulling all branches from github. Instead, it should pull from user-specified branch/location.
