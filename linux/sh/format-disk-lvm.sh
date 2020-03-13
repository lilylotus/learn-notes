#!/bin/bash

# format partation
parted -s /dev/sda 'mkpart primary xfs 13.2GB -1s'

# pv create
pvcreate /dev/sda3

# vg create
vgcreate lvm /dev/sda3

# lv create
lvcreate -l 1970 --name=data lvm

# format xfs to lvm-data
mkfs.xfs /dev/mapper/lvm-data

sda3_line=$(blkid /dev/mapper/lvm-data | sed 's/"//g' | awk '{print $2"\t/data\txfs\tdefaults\t0 0"}')
if [[ "$sda3_line" == "" ]];
then
	echo "lvm-data partation can not find"
	exit 1
fi

#echo "/dev/sda2	/data	xfs	defaults	0	0" >> /etc/fstab
echo $sda3_line >> /etc/fstab

mkdir -p /data
mount -a

if [[ $? -eq "0" ]]; then
	echo "format disk success"
else
	echo "format disk failure"
	exit 1
fi

mkdir -p /data/docker

#blkid /dev/sda3 | sed 's/"//g' | awk '{print $2"\t/data\txfs\tdefaults\t0 0"}'