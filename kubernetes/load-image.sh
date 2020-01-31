#!/bin/bash

# 加载镜像，不在从 google 下载

ls /root/sh/kubeadm-basic.images > /tmp/images-list.txt

cd /root/sh/kubeadm-basic.images

for i in $( cat /tmp/images-list.txt )
do
        echo "load iamge $i"
        docker load -i $i
done

rm -rf /tmp/images-list.txt