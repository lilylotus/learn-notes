#!/bin/bash

# 1. config remote reposity as aliyun
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

yum clean all && yum makecache

# 2. shutdown firewalld and configure selinux
setenforce 0
sed -ri 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

systemctl stop firewalld && systemctl disable firewalld

# 3. install necessary software
yum install -y yum-utils wget curl vim tree net-tools git lrzsz
yum install -y iptables iptables-services iptables-utils firewalld
yum install -y epel-release && yum install -y htop

cat <<EOF > ~/.vimrc
syntax on
set tabstop=4
set autoindent
EOF

systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

# 4. config ssh, add public key
if [[ ! -e /root/.ssh ]]; then
	echo "create folder /root/.ssh"
	mkdir -p /root/.ssh
fi

# id_rsa_2048.pub
public_key="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq4y0aaPw+y9th5S6K0VZEUs2ZSMtWhkHnz0VlhNQJF47DDK39FYPMwb+7psuG3aFmgg70sCfWF7hSNF7R1E9ARTm+x95J/bGbtriA7E7bbzpdfpdhgUR0lmtsNBWQK6ETIaGCvJZLd5bFk/HU7XyYW/kw/60BkblR1yLrMNUi5chiZMvC8mvcxKIVMLPPPbUrswULcyTBRd8ESJgronhtAv0UgoJCCSCPIHVtBZGUQ5oROfaoMpSuR40lYMIbFmZ34cZ0ZGqwurno7NTOanuHMr5sQhe7yvMeVq5j1h1J78FsV/fbzBSbYQPiHGuqwxhmEr2nl8zspxq1Ww/VoTwhQ=="
if [[ -e /root/.ssh/authorized_keys ]]; then
	echo "$public_key" >> /root/.ssh/authorized_keys
else
	echo "$public_key" > /root/.ssh/authorized_keys
fi