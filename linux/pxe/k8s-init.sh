#!/bin/bash

# kubeadm config print init-defaults > kubeadm-init.yaml

k8s_version=1.22.6
k8s_master_ip=192.168.110.30
k8s_master_hostname=k8s-master2
pod_subnet=10.244.0.0/16

cat <<EOF > kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${k8s_master_ip}
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  imagePullPolicy: IfNotPresent
  name: ${k8s_master_hostname}
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: ${k8s_version}
networking:
  dnsDomain: cluster.local
  podSubnet: "${pod_subnet}"
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
ipvs:
  strictARP: true
EOF

# sudo kubeadm init --pod-network-cidr=192.168.0.0/16
kubeadm init --config=kubeadm-init.yaml --upload-certs | tee kubeadm-init.log

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
# https://kubernetes.io/docs/concepts/cluster-administration/addons/

# kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# install calico
# kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
# cidr: 10.244.0.0/16
# kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml

# watch kubectl get pods -n calico-system