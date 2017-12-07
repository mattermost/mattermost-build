.PHONY: install clean

DOCKER_TARGET := mmjenkins.azurecr.io/jenkins-master
BUILD_PRIVATE_DIR ?= ../mattermost-build-private

HAS_PRIVATE = false
ifneq ($(wildcard $(BUILD_PRIVATE_DIR)/.),)
	HAS_PRIVATE = true
endif

help:            ## Show this help.
	@egrep '^(.+)\:\ +##(.+)' ${MAKEFILE_LIST} | column -t -c 2 -s '#'

all:             ## Add secrets from private dir, build docker image and chart archive
	cd mattermost-jenkins && helm dependency update
	cd mattermost-jenkins && helm package .

deploy:          ## install + Rebuild pods
deploy: all
	helm upgrade --recreate-pods build-mattermost-com ./mattermost-jenkins/mattermost-jenkins-*.tgz
	cd aws && ./updateip.sh

deploy-local:    ## Deploy locally without pushing to Docker repo
deploy-local: DOCKER_TARGET := local/jenkins-master
deploy-local: all
	helm upgrade --install --recreate-pods build-mattermost-com --values ./mattermost-jenkins/values.minikube.yaml ./mattermost-jenkins/mattermost-jenkins-*.tgz

redeploy:        ## install + delete releases and redeploy
redeploy: all
	helm delete --purge build-mattermost-com || echo notfound
	cd mattermost-jenkins && helm install mattermost-jenkins-*.tgz -n build-mattermost-com
	cd aws && ./updateip.sh

redeploy-local: ## Delete releases and redeploy locally wihtout pushing to Docker repo
redeploy-local: DOCKER_TARGET := local/jenkins-master
redeploy-local: all
	helm delete --purge build-mattermost-com || echo notfound
	cd mattermost-jenkins && helm install --values values.minikube.yaml mattermost-jenkins-*.tgz -n build-mattermost-com

clean:           ## Remove chart archives and secrets
	rm -f mattermost-jenkins/mattermost-jenkins*.tgz
	rm -f mattermost-jenkins/charts/*.tgz
	rm -f docker/jenkins-master/jenkins_home/credentials.xml
	rm -f docker/jenkins-master/jenkins_home/hudson.plugins.s3.S3BucketPublisher.xml
	rm -f docker/jenkins-master/jenkins_home/secret.key*
	rm -rf docker/jenkins-master/jenkins_home/secrets

install-persistent-volume:           ## Install persistent volume
	kubectl create -f ./task-pv-claim.yaml

delete:          ## clean and delete releases
delete: clean
	helm delete --purge build-mattermost-com || echo notfound
	kubectl delete pods --all

nuke:            ## Delete all VMs and run clean
nuke: clean
	minikube delete
