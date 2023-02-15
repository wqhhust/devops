#!/bin/bash
apt update
apt install -y openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update
apt install -y jenkins
apt install -y git
apt install -y python3-pip
apt-get purge aws
pip install awscli	
cat <<EOT >> /tmp/git_init.sh
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
git config --global user.email "wuqihua_it@163.com"
git config --global user.name "Daniel Wu"
cd /tmp;git clone https://git-codecommit.us-east-2.amazonaws.com/v1/repos/jenkins_config
# sh -x /tmp/git_init.sh
EOT
apt-add-repository ppa:ansible/ansible
apt update
apt install -y ansible
