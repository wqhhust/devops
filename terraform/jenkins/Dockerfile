FROM ubuntu:20.04
RUN mkdir -p /var/run/sshd
RUN apt -y update
RUN apt install -y openjdk-11-jdk
RUN apt install -y openssh-server
RUN ssh-keygen -A
ADD ./sshd_config /etc/ssh/sshd_config
RUN echo root:jenkins | chpasswd
CMD ["/usr/sbin/sshd", "-D"]
# image is wqhhust1/docker-slave:1.0 on docker hub, just run docker pull wqhhust1/docker-slave:1.0 to pull it
