.PNONY: install clean

BUILD_PRIVATE_DIR ?= ../mattermost-build-private

HAS_PRIVATE = false
ifneq ($(wildcard $(BUILD_PRIVATE_DIR)/.),)
	HAS_PRIVATE = true
endif

all:
ifeq ($(HAS_PRIVATE),true)
	cp -r $(BUILD_PRIVATE_DIR)/jenkins_home/* docker/jenkins-master/jenkins_home/
endif
	docker build ./docker/jenkins-master/ -t mmjenkins.azurecr.io/jenkins-master

	rm -f mattermost-jenkins/mattermost-jenkins*.tgz
	cd mattermost-jenkins && helm package .

install: all
	docker push mmjenkins.azurecr.io/jenkins-master

deploy: install
	helm upgrade --recreate-pods build-mattermost-com ./mattermost-jenkins/mattermost-jenkins-*.tgz
	cd aws && ./updateip.sh

redeploy: install
	helm delete --purge build-mattermost-com || echo notfound
	cd mattermost-jenkins && helm install mattermost-jenkins-*.tgz -n build-mattermost-com

clean:
	rm -f mattermost-jenkins/mattermost-jenkins*.tgz
	rm -f docker/jenkins-master/jenkins_home/credentials.xml
	rm -f docker/jenkins-master/jenkins_home/hudson.plugins.s3.S3BucketPublisher.xml
	rm -f docker/jenkins-master/jenkins_home/secret.key*
	rm -rf docker/jenkins-master/jenkins_home/secrets

install-persistant-volume:
	kubectl create -f ./task-pv-claim.yaml
