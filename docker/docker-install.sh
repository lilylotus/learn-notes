#!/bin/bash

sd=/dev/sda

parted $sd print
parted $sd "mkpart primary 13.2GB -1s"
mkfs.xfs /dev/sda4
parted $sd print

if [[ $? -eq "0" ]];
then
    mkdir /data
    cp /etc/fstab /etc/fstab.bak
    blkid /dev/sda4 | awk -F = '{print $2}' | awk -F '"' '{print "UUID="$2"\t/data\txfs\tdefaults 0 0"}' >> /etc/fstab
else
    exit -1
fi

echo "install docker-ce"
# step 1: install tools
yum install -y yum-utils device-mapper-persistent-data lvm2 tree
# step 2: add software repo
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# step 3: update repos
yum clean all && yum makecache
# step 4: install docker-ce
yum install -y docker-ce

# configuration kernel parameters
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF

sysctl --system

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4

# yum install -y ipset ipvsadm


if [[ -e /data/docker ]]
then
        echo "/data/docker dir exist"
else
        echo "mkdir /data/docker"
        mkdir -p /data/docker
fi

systemctl enable docker

# config docker
if [[ -e /etc/docker ]]
then
        echo "/etc/docker dir exist"
else
        echo "mkdir /etc/docker"
        mkdir /etc/docker
fi

if [[ -e /etc/docker/daemon.json ]]
then
        echo "daemon.json file exit, will backup"
        cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
fi

cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": ["https://registry.docker-cn.com","http://hub-mirror.c.163.com"],
    "graph": "/data/docker",
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload && systemctl restart docker

docker run hello-world
if [[ $? -eq "0" ]];
then
        docker pull centos:7.7.1908
        docker pull ubuntu:18.04
        docker pull mysql:5.7.20
else
        echo "docker configuration error"
fi