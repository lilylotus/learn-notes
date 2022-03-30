#!/bin/bash

k8s_version=1.22.6
images_dir=images

rm -rf $images_dir
mkdir -p $images_dir

k8s_images=`kubeadm config images list --kubernetes-version ${k8s_version}`

for image in ${k8s_images[@]}
do
	echo "pull image [${image}]"
	docker pull ${image}
	bi=${images_dir}/$(echo $image | cut -d'/' -f2 | cut -d':' -f1).tar
	echo "docker save -o ${bi} ${image}"
	docker save -o ${bi} ${image}
done

# k8s images package
cd $images_dir
tar czvf k8s-images-${k8s_version}.tar.gz *.tar