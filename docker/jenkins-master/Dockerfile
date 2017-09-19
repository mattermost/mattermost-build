FROM jenkinsci/jenkins:lts

COPY jenkins_home/ /jenkins_tmp/
USER root
RUN ls -alh /jenkins_tmp/
RUN ls -alh /jenkins_tmp/secrets
RUN chown -R jenkins:jenkins "/jenkins_tmp" && mv -v /jenkins_tmp/* /usr/share/jenkins/ref/
RUN ls -alh /usr/share/jenkins/ref/secrets
RUN ls -alh /var/jenkins_home/
USER jenkins
