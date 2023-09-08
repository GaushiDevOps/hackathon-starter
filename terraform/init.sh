#!/usr/bin/bash

sudo apt install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo apt install ansible -y
cd /home/ubuntu/mongodb-ansible
ansible-playbook -b mongo.yml

