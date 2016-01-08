#!/usr/bin/env bash

# Install Ansible
apt-get -y update
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get -y update
apt-get -y install ansible

# Install Docker
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
mkdir -p /etc/apt/sources.list.d
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get -y purge lxc-docker
apt-cache -y policy docker-engine
apt-get -y upgrade
apt-get -y install linux-image-extra-$(uname -r)
apt-get -y install docker-engine
service docker start

usermod -aG docker ubuntu

# Install apache 
apt-get -y install apache2
service apache2 start
