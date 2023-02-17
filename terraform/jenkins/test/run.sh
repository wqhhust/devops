#!/usr/bin/env sh

cd /tmp
git checkout https://github.com/wqhhust/devops.git
cd /tmp/devops/terraform/jenkins
alias t=terraform
# need to first run aws configure
t init
t plan
t apply
# need to install ansible
ansible-playbook jenkins_plugin.yml
