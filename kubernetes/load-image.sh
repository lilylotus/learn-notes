#!/bin/bash

# 加载镜像，不在从 google 下载

ls images/*.tar > /tmp/images-list.txt

for i in $( cat /tmp/images-list.txt )
do
        echo "load iamge $i"
        docker load -i $i
done

rm -f /tmp/images-list.txt