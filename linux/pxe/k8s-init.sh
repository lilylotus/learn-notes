#!/bin/bash

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
yum install -y docker-ce-20.10.12-3.el7 docker-ce-cli-20.10.12-3.el7 containerd.io

# 便于查看 ipvs 的代理规则
yum install -y ipset ipvsadm

yum install -y kubeadm-1.22.6 kubectl-1.22.6 kubelet-1.22.6
systemctl enable kubelet.service