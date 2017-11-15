FROM jenkins/jenkins:lts

COPY jenkins_home/ /jenkins_tmp/
USER root
RUN ls -alh /jenkins_tmp/*
RUN chown -R jenkins:jenkins "/jenkins_tmp" && mv -v /jenkins_tmp/* /usr/share/jenkins/ref/
RUN ls -alh /usr/share/jenkins/ref/secrets || echo 'No secrets!'
RUN ls -alh /var/jenkins_home/
USER jenkins
