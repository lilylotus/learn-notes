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

public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgWvYwOXUSsEE7eU2ubLStlfJcsAt2EYXmkljHmgQR8DKrwW3GnK74AdV+WiVHiCHQ2u7NxNLhsHr5Vy2vJHrQezRAOV5Pra26fGJHlOQb/bGn+UJWDjAtaKymLuEaSZenYS5scu9NuGy7AwXAUQjg7LIgXklugTRb0dORqosC2zZQ/OrZgTpNeipp8X5luWRd15Yjzf1fdvL9GsvU3avBHy2Xr6WmlkquAUnSt95DVKftrO3mMRGslWcOexJP5xSnZj9wXfx1EL9nRC2KC34m3kg2jhk2VxrFCk8nBinkTTcK96ZtOXHRxkMQbylB3ITnAHRebhz4ZTptyfZU+yAoKR5T/97yJgMznr17INK9W2HFeHup3AGjvlbWnANhXvYZby9Y6kYBswhbnzrkrH2Kk7MN9EmvPc6dEewmUVNakzjQQgtSJjWXcPB+NLpIMJTCsnS+FraKZ9zxbF4PlmlPy+Q5MPc4lJiDIH5JqaYXbWmyI1XLWsOYCW2MjD/aVgc= clover@DESKTOP-URDQHEM"
if [[ -e /root/.ssh/authorized_keys ]]; then
	echo "$public_key" >> /root/.ssh/authorized_keys
else
	echo "$public_key" > /root/.ssh/authorized_keys
fi