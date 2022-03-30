#!/bin/bash

docker_version=20.10.12-3.el7
k8s_version=1.22.6

cat <<EOF | tee /etc/modules-load.d/containerd.conf
br_netfilter
EOF

modprobe br_netfilter

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh

lsmod | grep -e ip_vs

yum clean all && yum makecache faste
yum install -y yum-utils device-mapper-persistent-data lvm2
yum install -y docker-ce-${docker_version} docker-ce-cli-${docker_version} containerd.io

# 便于查看 ipvs 的代理规则
yum install -y ipset ipvsadm

yum install -y kubeadm-${k8s_version} kubectl-${k8s_version} kubelet-${k8s_version}
systemctl enable kubelet.service
systemctl enable docker.service
