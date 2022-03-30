#!/bin/bash

# Configure the network with a static IP on eno1
# 192.168.2.x, then:
# Configure the network with a static IP on eno2
# 192.168.20.x, then:
sudo yum -y update
sudo yum -y groupinstall "Development Tools"
sudo yum -y install mesa-libGL-17.2.3-8.20171019.el7
sudo yum -y install epel-release
sudo yum repolist
sudo yum -y install dkms
sudo yum -y install kernel-devel
sudo yum -y install mlocate
sudo yum -y install screen
sudo yum -y install net-tools
sudo yum -y install valgrind
sudo yum -y install mediainfo
sudo yum -y install sysstat
sudo yum -y install tcpdump
sudo yum -y install json-c
sudo yum -y install wget lm_sensors pciutils
sudo updatedb

sudo systemctl enable sysstat
sudo systemctl start sysstat

