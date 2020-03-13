#!/bin/bash

# format partation
parted -s /dev/sda 'mkpart primary xfs 13.2GB -1s'
mkfs.xfs -f /dev/sda2

mkdir -p /data
sda_line=$(blkid /dev/sda2 | sed 's/"//g' | awk '{print $2"\t/data\txfs\tdefaults\t0 0"}')
#echo "/dev/sda2	/data	xfs	defaults	0	0" >> /etc/fstab
echo $sda_line >> /etc/fstab
mount -a

if [[ $? -eq "0" ]]; then
	echo "format disk success"
else
	echo "format disk failure"
	exit 1
fi

mkdir -p /data/docker

#blkid /dev/sda3 | sed 's/"//g' | awk '{print $2"\t/data\txfs\tdefaults\t0 0"}'