#!/bin/bash

function install_docker() {

# config kernel parameters
cat <<EOF > /etc/sysctl.d/docker.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.ipv4.ip_forward = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv6.conf.all.disable_ipv6 = 1
vm.swappiness = 0
vm.overcommit_memory = 1
vm.panic_on_oom = 0
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576
fs.file-max = 52706963
fs.nr_open = 52706963
EOF

sysctl -p /etc/sysctl.d/docker.conf

# update system
yum clean all && yum makecache

# preinstall sofrware
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# install docker, kubenetes version is 1.15.1
yum install -y docker-ce-18.09.9-3.el7 docker-ce-cli-18.09.9-3.el7 containerd.io

# 配置 docker 文件
if [[ ! -e /etc/docker ]]; then
	echo "mkdir folder /etc/docker"
	mkdir -p /etc/docker
fi

if [[ -e /etc/docker/daemon.json ]]; then
	echo "backup /etc/dcoker/daemon.json"
	cp -f /etc/docker/daemon.json /etc/docker/daemon.json.bak
fi

cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": ["https://9ebf40sv.mirror.aliyuncs.com","https://registry.docker-cn.com","http://hub-mirror.c.163.com"],
    "graph": "/data/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {"max-size": "100m"}
}
EOF
# "insecure-registries": ["https://hub.nihility.cn"]

# config docker
systemctl enable docker && systemctl daemon-reload && systemctl restart docker

}

docker=$( rpm -qa | grep docker )
container=$( rpm -qa | grep 'containerd.io' )
echo "docker version $docker"
echo "containerd version $container"

if [[ "$container" != "" ]]; then
	echo "remove $container"
	yum remove -y $container
fi

if [[ "$docker" != "" ]]; then
	for i in $docker
	do
		echo "remove $i"
		yum remove -y $i
	done
	
	install_docker
else
	echo "install docker-ce-18.09.9-3.el7"
	install_docker
fi
