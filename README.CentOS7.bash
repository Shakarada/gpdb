#!/bin/bash

# Install needed packages. Please add to this list if you discover additional prerequisites
sudo yum groupinstall -y "Development Tools"
INSTALL_PKGS="wget epel-release libffi-devel apr-devel bison bzip2-devel cmake3 flex gcc gcc-c++ krb5-devel libcurl-devel libevent-devel libkadm5 libxml2-devel libzstd-devel openssl-devel perl-ExtUtils-MakeMaker.noarch perl-ExtUtils-Embed.noarch readline-devel rsync xerces-c-devel zlib-devel"

for i in $INSTALL_PKGS; do
  sudo yum install -y $i
done

# Needed for pygresql, or you can source greenplum_path.sh after compiling database and installing python-dependencies then
sudo yum install -y postgresql
sudo yum install -y postgresql-devel

# install python 3.9
wget https://www.python.org/ftp/python/3.9.16/Python-3.9.16.tgz
tar xvf Python-3.9.16.tgz
cd Python-3.9*/
./configure --enable-optimizations
sudo make altinstall
cd -
sudo rm -rf Python-3.9*

sudo ln -sf /usr/local/bin/python3.9 /usr/bin/python3
sudo ln -sf /usr/local/bin/pip3.9 /usr/bin/pip3
sudo python3 -m pip install --upgrade pip
sudo pip3 install pygresql
sudo pip3 install pgdb
sudo pip3 install -r python-dependencies.txt

sudo yum -y install centos-release-scl
sudo yum -y install devtoolset-7
scl enable devtoolset-7 bash

sudo tee -a /etc/sysctl.conf << EOF
kernel.shmmax = 5000000000000
kernel.shmmni = 32768
kernel.shmall = 40000000000
kernel.sem = 1000 32768000 1000 32768
kernel.msgmnb = 1048576
kernel.msgmax = 1048576
kernel.msgmni = 32768

net.core.netdev_max_backlog = 80000
net.core.rmem_default = 2097152
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

vm.overcommit_memory = 2
vm.overcommit_ratio = 95
EOF

sudo sysctl -p

sudo mkdir -p /etc/security/limits.d
sudo tee -a /etc/security/limits.d/90-greenplum.conf << EOF
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 1048576
* hard nproc 1048576
EOF

ulimit -n 65536 65536
