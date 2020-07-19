```bash
#!/bin/bash
servers=(master node01 node02 node03)
for server in ${servers[@]}; do {
    echo "server $server"
    ssh root@${server} "${command}"
}&
done
wait

# 并发执行
```

#### 1. 配置主机名 和 关闭服务 和 安装工具

```bash
hostnamectl set-hostname --static k8s-master
```

```bash
#!/bin/bash
yum clean all && yum makecache
yum install -y friewalld iptables iptables-services vim net-tools curl wget tree
yum install -y sysstat ntpdate rsyslog conntrack libseccomp

# 关闭服务
systemctl stop firewalld && systemctl disable firewalld && iptables -F
systemctl restart rsyslog && systemctl restart crond
systemctl stop postfix && systemctl disable postfix

# 关闭 selinux / swap
sed -ri '/^SELINUX=/s/^.*$/SELINUX=disabled/' /etc/selinux/config
sed -ri '/swap/s/^.*(\/dev.*)/#\1/' /etc/fstab
swapoff -a

```

#### 2. 升级内核

```bash
#!/bin/bash
# 启用 ELRepo 仓库
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y yum-plugin-fastestmirror yum-utils
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm

# 安装 kernel 版本 (ml - mainline stable, lt - long term support)
yum --enablerepo=elrepo-kernel install -y kernel-lt

# 设置新的内核为 grub2 的默认版本
grub2-set-default 0

# 重建 kernel 配置
grub2-mkconfig -o /boot/grub2/grub.cfg
```

#### 3. 配置内核参数 和 日志参数

> - vm.swappiness = 0
>   swappiness 的值越大，表示越积极使用 swap 分区，越小表示越积极使用物理内存
>   默认值 swappiness = 60
> - vm.overcommit_memory = 1
>   内存分配策略，可选值 0,1,2
>   0：表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
>   1：表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
>   2：表示内核允许分配超过所有物理内存和交换空间总和的内存
>   Linux 对大部分申请内存的请求都回复 "yes"，以便能跑更多更大的程序。因为申请内存后，并不会马上使用内存。这种技术叫做 **Overcommit**。当 linux 发现内存不足时，会发生 OOM killer(OOM=out-of-memory)。它会选择杀死一些进程(用户态进程，不是内核线程)，以便释放内存。
> - fs.inotify.max_user_instances = 8192
>   fs.inotify.max_user_watches 默认值太小，导致 too many open files
>   fs.inotify.max_user_instances：表示每一个 real user ID 可创建的 inotify instatnces 的数量上限，默认 128.
>   fs.inotify.max_user_watches：表示同一用户同时可以添加的 watch 数目（watch一般是针对目录，决定了同时同一用户可以监控的目录数量）
>   注意：max_queued_events 是 inotify 管理的队列的最大长度，文件系统变化越频繁，这个值就应该越大。如果你在日志中看到Event Queue Overflow，说明max_queued_events太小需要调整参数后再次使用。

```bash
#!/bin/bash
cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1

net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_timestamps = 1
vm.swappiness = 0
vm.overcommit_memory = 1

fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 8192

fs.file-max = 6553560
fs.nr_open = 6553560
EOF

sysctl -p /etc/sysctl.d/kubernetes.conf
sysctl --system

# 设置 rsyslogd 和 systemd journald
mkdir -p /var/log/journal /etc/systemd/journald.conf.d

cat <<EOF > /etc/systemd/journald.conf.d/99-prophet.conf
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
# 最大占用空间 10G
SystemMaxUse=10G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间 2 周
MaxRetentionSec=2week
# 不将日志转发到 syslog
ForwardToSyslog=no
EOF

systemctl restart systemd-journald
```

#### 4. docker 安装

On each of your machines, install Docker. Version 19.03.11 is recommended, but 1.13.1, 17.03, 17.06, 17.09, 18.06 and 18.09 are known to work as well. Keep track of the latest verified Docker version in the Kubernetes release notes.

```bash
#!/bin/bash
# Install required packages
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# show docker verseion
# yum list docker-ce.x86_64  --showduplicates | sort -r
# Install Docker CE
yum install -y containerd.io-1.2.13-3.2.el7 \
docker-ce-19.03.11-3.el7 \
docker-ce-cli-19.03.11-3.el7

# 配置 docker 文件
if [[ ! -d /etc/docker ]]; then
	echo "mkdir folder /etc/docker"
	mkdir -p /etc/docker
fi
if [[ ! -d /etc/systemd/system/docker.service.d ]]; then
	echo "mkdir /etc/systemd/system/docker.service.d"
	mkdir -p /etc/systemd/system/docker.service.d
fi
# Configure containerd
if [[ ! -d /etc/containerd ]]; then
	echo "mkdir /etc/containerd"
	mkdir -p /etc/containerd
fi
if [[ -e /etc/docker/daemon.json ]]; then
	echo "backup /etc/dcoker/daemon.json"
	cp -f /etc/docker/daemon.json /etc/docker/daemon.json.bak
fi

# Set up the Docker daemon
cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": ["https://9ebf40sv.mirror.aliyuncs.com","https://registry.docker-cn.com","http://hub-mirror.c.163.com"],
    "graph": "/data/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {"max-size": "100m"},
    "storage-driver": "overlay2",
    "storage-opts": ["overlay2.override_kernel_check=true"]
}
EOF

# Restart Docker
systemctl daemon-reload && systemctl enable docker && systemctl restart docker
# Configure containerd
containerd config default > /etc/containerd/config.toml
# using systemd
sed -ri '/systemd_cgroup/s/false/true/' /etc/containerd/config.toml
# Restart containerd
systemctl restart containerd

```

#### 5. kubenetes 安装

- `kubeadm`: the command to bootstrap the cluster.
- `kubelet`: the component that runs on all of the machines in your cluster and does things like starting pods and containers.
- `kubectl`: the command line util to talk to your cluster.

```bash
#!/bin/bash
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# config environment
modprobe overlay
modprobe br_netfilter
# IPVS needs module - package ipset
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

K8SVERSION=1.18.6
yum clean all && yum makecache
yum install -y kubelet-${K8SVERSION} kubeadm-${K8SVERSION} kubectl-${K8SVERSION}
yum install -y ipset ipvsadm
systemctl enable kubelet

# kubelet 与 docker cri 交互创建容器
# kubeadm 初始化工具
# kubectl 命令行工具
# yum remove -y kubernetes-cni kubeadm kubelet kubectl
```

```bash
#!/bin/bash
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
sudo firewall-cmd --reload
```

##### 5.1 kubenetes 需要的 images 和 kubeadm config

```bash
# k8s 1.18.5-0 需要 version >= 1.17.0
kubeadm config images list --kubernetes-version 'v1.18.6'
--image-repository string
--kubernetes-version string

k8s.gcr.io/kube-apiserver:v1.18.6
k8s.gcr.io/kube-controller-manager:v1.18.6
k8s.gcr.io/kube-scheduler:v1.18.6
k8s.gcr.io/kube-proxy:v1.18.6
k8s.gcr.io/pause:3.2
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.7

################################
# kubeadm config view
kubeadm config view [flags]
--kubeconfig string     Default: "/etc/kubernetes/admin.conf"

# kubeadm config print init-defaults
kubeadm config print init-defaults [flags]
--kubeconfig string     Default: "/etc/kubernetes/admin.conf"

sudo kubeadm config print init-defaults > kubeadm-config.yml

# kubeadm config print join-defaults
kubeadm config print join-defaults [flags]
--kubeconfig string     Default: "/etc/kubernetes/admin.conf"

# kubeadm config images list
kubeadm config images list [flags]
--image-repository string     Default: "k8s.gcr.io"
--kubernetes-version string     Default: "stable-1"
--kubeconfig string     Default: "/etc/kubernetes/admin.conf"

# kubeadm config images pull
kubeadm config images pull [flags]
--image-repository   string     Default: "k8s.gcr.io"
--kubernetes-version string     Default: "stable-1"
```

kubernetes 所需的 images 打包

```bash
#!/bin/bash
# kubernetes images use docker download
DIR=/data/k8s-images
if [[ ! -d $DIR ]]; then
	echo "mkdir $DIR"
	mkdir -p $DIR
fi

K8SVERSION=1.18.6
#IMAGES=('k8s.gcr.io/kube-apiserver:v1.18.6' 'k8s.gcr.io/kube-controller-manager:v1.18.6' 'k8s.gcr.io/kube-scheduler:v1.18.6' 'k8s.gcr.io/kube-proxy:v1.18.6' 'k8s.gcr.io/pause:3.2' 'k8s.gcr.io/etcd:3.4.3-0' 'k8s.gcr.io/coredns:1.6.7')
IMAGES=`kubeadm config images list --kubernetes-version ${K8SVERSION}`
echo "IMAGES ${IMAGES}"
for image in ${IMAGES[@]}
do
	echo "pull image [${image}]"
	echo "docker pull ${image}"
	docker pull ${image}
	bi=${DIR}/$(echo $image | cut -d'/' -f2 | cut -d':' -f1).tar
	echo "docker save -o ${bi} ${image}"
	docker save -o ${bi} ${image}
done

# k8s images package
cd $DIR
K8SI=k8s-images-${K8SVERSION}.tar.gz
tar czvf ${K8SI} *.tar

```

docker 引入 kubernetes 所需的 images

```bash
#!/bin/bash

K8SVERSION=v1.18.6
DIR=/data/k8s-images
K8SI=k8s-images-${K8SVERSION}.tar.gz

cd $DIR
tar -zxf ${K8SI}
ls *.tar > /tmp/images-list.txt
for image in $(cat /tmp/images-list.txt)
do
	echo "load image ${image}"
	docker load -i $image
done

rm -f /tmp/images-list.txt
rm -f *.tar
```

##### 5.2 kubenetes 初始化 kubeadm init

```bash
kubeadm init [flags]
kubeadm init --kubernetes-version stable-1.18 --pod-network-cidr=192.168.0.0/16--token-ttl 0

--token-ttl duration     Default: 24h0m0s
--image-repository   string     Default: "k8s.gcr.io"
--kubernetes-version string     Default: "stable-1"
--pod-network-cidr string
```

#### 6. kubernetes 初始化

```bash
kubeadm init [flags]
--config string
--kubernetes-version string     Default: "stable-1"
--pod-network-cidr   string
--service-cidr       string     Default: "10.96.0.0/12"
--service-dns-domain string     Default: "cluster.local"
--token-ttl duration     Default: 24h0m0s

# 获取默认初始化模板
kubeadm config print init-defaults > kubeadm-config.yaml
kubeadm init --config=kubeadm-config.yaml | tee kubeadm-init.log

# 初始化成功
kubelet configuration to file "/var/lib/kubelet/config.yaml"
certificateDir folder "/etc/kubernetes/pki"
kubeconfig folder "/etc/kubernetes"

# 初始化成功后执行
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 节点加入 master
kubeadm join 10.10.100.8:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:adf536d61e01af388662826afd26d230dfe82d0af351331029b2e0ad0e1254a3
```

```yml
apiVersion: kubeadm.k8s.io/v1beta2
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
  # 当前节点的 IP 地址
  advertiseAddress: 10.10.100.8
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: k8s-master
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
# 使用国内镜像仓库
imageRepository: registry.aliyuncs.com/google_containers
# imageRepository: k8s.gcr.io
kind: ClusterConfiguration
# 当前节点 k8s 的版本
kubernetesVersion: v1.18.6
networking:
  dnsDomain: cluster.local
  # 添加 pod 网段, 默认覆盖网络 (Overlay Network) Flannel 插件地址段
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
# 新增内容
# kubeadm init --feature-gates=SupportIPVSProxyMode=true
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
  SupportIPVSProxyMode: true
mode: ipvs
```

##### 6.1 安装 flannel 网络 (扁平化网络  )

kubernets 要求为扁平化网络存在

```bash
# 下载 flannel 配置
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# kubernetes 配置 flannel
kubectl create -f kube-flannel.yml

# 查看安装情况
kubectl get pod -n kube-system
kubectl get node
```

#### 7. 部署 Kubernetes Cluster

A Pod Network allows nodes within the cluster to communicate. This uses the **flannel** virtual network add-on for this purpose.

```bash
# 1. Initialize a cluster
kubeadm init –pod-network-cidr=10.244.0.0/16

# 2. Manage Cluster as Regular User
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 3. Set Up Pod Network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 4. Check Status of Cluster
sudo kubectl get nodes
sudo kubectl get pods --all-namespaces
sudo kubectl get pods -n kube-system

# 5. Join Worker Node to Cluster
kubeadm join --discovery-token cfgrty.1234567890jyrfgd --discovery-token-ca-cert-hash sha256:1234..cdef 1.2.3.4:6443

# 6. Create First Pod
# k8s master
kubectl create deployment nginx --image=nginx
# see details of the nginx deployment sepcification
kubectl describe deployment nginx
# expose the nginx pod accessible via the internet
kubectl create service nodeport nginx --tcp=80:80

kubectl get pods
kubectl get svc
```

#### 8. kubernetes 命令 kubectl

```bash
kubectl [command] [TYPE] [NAME] [flags]
# command : create, get, describe, delete, exec, expose, logs, run, scale, apply
# TYPE :  resource type. pods(po), services(svc), deployments(deploy), replicasets(rs)
#	jobs, events(ev), 
# NAME : name of the resource

kubectl get pods --sort-by=.metadata.name

kubectl apply -f example-service.yaml

kubectl get pods -o wide
kubectl get rc,services
kubectl get ds

kubectl describe nodes <node-name>
kubectl describe pods/<pod-name>
kubectl describe pods

kubectl delete -f pod.yaml
kubectl delete pods --all

kubectl exec -ti <pod-name> -- /bin/bash

kubectl logs -f <pod-name>
```

##### 8.1 查看状态

```bash
# pod
kubectl get pod -n kube-system -o wide [-w]
kubectl get pods --all-namespaces
kubectl get po pod1
 
# node
kubectl get node -o wide --all-namespaces
kubectl get nodes -o wide --all-namespaces
```

##### 8.2 展示一个或多个资源 [kubectl get]

命令格式： https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get

```bash
kubectl get [(-o|--output=)json|yaml|wide|custom-columns=...|custom-columns-file=...|go-template=...|go-template-file=...|jsonpath=...|jsonpath-file=...] (TYPE[.VERSION][.GROUP] [NAME | -l label] | TYPE[.VERSION][.GROUP]/NAME ...) [flags]

# List all pods in ps output format with more information
kubectl get pods -o wide

# List deployments in JSON output format, in the "v1" version of the "apps" API group:
kubectl get deployments.v1.apps -o json

# List a single pod in JSON output format.
kubectl get -o json pod web-pod-13je7
```

##### 8.3 部署 [kubectl run] (pod)

在 *pod* 中创建并运行特定的 *image*
命令地址： https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run

```bash
kubectl run NAME --image=image [--env="key=value"] [--port=port] [--dry-run=server|client] [--overrides=inline-json] [--command] -- [COMMAND] [args...]

# self create test.
kubectl run myapp-deployment --image=harbor.nihility.cn/library/myapp:v1 --port=80
# 查看部署
kubectl get pods myapp-deployment -o wide
kubectl get pod myapp-deployment -o wide

# start nginx pod
kubectl run nginx --image=nginx

# Start a hazelcast pod and let the container expose port 5701.
kubectl run hazelcast --image=hazelcast/hazelcast --port=5701
kubectl run hazelcast --image=hazelcast/hazelcast --env="DNS_DOMAIN=cluster" --env="POD_NAMESPACE=default"
kubectl run hazelcast --image=hazelcast/hazelcast --labels="app=hazelcast,env=prod"

# 空运行。打印相应的API对象而不创建它们。
kubectl run nginx --image=nginx --dry-run=client

# Start a nginx pod, but overload the spec with a partial set of values parsed from JSON.
kubectl run nginx --image=nginx --overrides='{ "apiVersion": "v1", "spec": { ... } }'

# Start a busybox pod and keep it in the foreground, don't restart it if it exits.
kubectl run -i -t busybox --image=busybox --restart=Never

kubectl run nginx --image=nginx -- <arg1> <arg2> ... <argN>
kubectl run nginx --image=nginx --command -- <cmd> <arg1> ... <argN>
```

##### 8.4 暴露一个资源作为一个 Kubernetes 服务  [kubectl expose]

命令操作： https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose
pod (po), service (svc), replicationcontroller (rc), deployment (deploy), replicaset (rs)

```bash
kubectl expose (-f FILENAME | TYPE NAME) [--port=port] [--protocol=TCP|UDP|SCTP] [--target-port=number-or-name] [--name=name] [--external-ip=external-ip-of-service] [--type=type]

# Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000.
kubectl expose rc nginx --port=80 --target-port=8000
kubectl expose -f nginx-controller.yaml --port=80 --target-port=8000

# Create a service for a pod valid-pod, which serves on port 444 with the name "frontend"
kubectl expose pod valid-pod --port=444 --name=frontend
kubectl expose service nginx --port=443 --target-port=8443 --name=nginx-https

kubectl expose deployment nginx --port=80 --target-port=8000
```

##### 8.5 删除资源 [kubectl delete]

Delete resources by filenames, stdin, resources and names, or by resources and label selector.
命令地址：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete

```bash
kubectl delete ([-f FILENAME] | [-k DIRECTORY] | TYPE [(NAME | -l label | --all)])

# Delete a pod using the type and name specified in pod.json.
kubectl delete -f ./pod.json

kubectl delete pod,service baz foo

kubectl delete pod foo --now [--force]

# Delete all pods
kubectl delete pods --all
```

##### 8.6 调整 size [kubectl scale]

Set a new size for a Deployment, ReplicaSet, Replication Controller, or StatefulSet.
命令地址： https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#scale

```bash
kubectl scale [--resource-version=version] [--current-replicas=count] --replicas=COUNT (-f FILENAME | TYPE NAME)

# Scale a replicaset named 'foo' to 3.
kubectl scale --replicas=3 rs/foo

# Scale a resource identified by type and name specified in "foo.yaml" to 3.
kubectl scale --replicas=3 -f foo.yaml

# If the deployment named mysql's current size is 2, scale mysql to 3.
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql

# Scale multiple replication controllers.
kubectl scale --replicas=5 rc/foo rc/bar rc/baz
kubectl scale --replicas=3 statefulset/web
```

##### 8.7 创建资源 [kubectl create]

Create a resource from a file or from stdin. JSON and YAML formats are accepted.
命令：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create

```bash
kubectl create -f FILENAME
kubectl create -f ./pod.json

# Create a ClusterRole
kubectl create clusterrole NAME --verb=verb --resource=resource.group [--resource-name=resourcename] [--dry-run=server|client|none]

kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods
```

Create a deployment with the specified name.

```bash
kubectl create deployment NAME --image=image [--dry-run=server|client|none]
# Create a new deployment named my-dep that runs the busybox image.
kubectl create deployment my-dep --image=busybox
```

#### 9. docker harbor 安装

*harbor* 下载地址： https://github.com/goharbor/harbor/releases
*docker-compose* 下载地址： https://github.com/docker/compose/releases

```bash
# 配置 docker-compose
mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 配置 docker daemon.json
"insecure-registries": ["https://harbor.nihility.cn"]

# install docker harbor
tar zxf harbor-offline-installer-v1.10.4.tgz
# configuration harbor.yml
hostname: harbor.nihility.cn
harbor_admin_password: Harbor12345
  certificate: /data/cert/server.crt
  private_key: /data/cert/server.key
  
# install
install.sh

# 创建证书
openssl genrsa -des3 -out server.key 2048
openssl req -new -key server.key -out server.csr
# docker 无需密码，退去密码
cp server.key server.key.bak
openssl rsa -in server.key.bak -out server.key
# 证书签名
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
chmod 777 *

# 登录
https://10.10.100.139/
admin/Harbor12345
# docker login
docker login https://harbor.nihility.cn
admin/Harbor12345

# 操作，上传镜像到 harbor
docker pull wangyanglinux/myapp:v1
# docker tag SOURCE_IMAGE[:TAG] harbor.nihility.cn/library/IMAGE[:TAG]
docker tag wangyanglinux/myapp:v1 harbor.nihility.cn/library/myapp:v1
# docker push harbor.nihility.cn/library/IMAGE[:TAG]
docker push harbor.nihility.cn/library/myapp:v1

# pull images
docker pull harbor.nihility.cn/library/myapp:v1
```

#### 10. kubectl 示例

<font color="red">注意：</font> `ClusterIP` 只对集群内部可见，`NodePort` 对外部可见，`LoadBalancer`
![services-iptables-overview](../images/services-iptables-overview.svg)

```bash
# kubectl run name --image=(镜像名) --replicas=(备份数) --port=(容器要暴露的端口) --labels=(设定自定义标签)
# kubectl create -f xx.yaml  (陈述式对象配置管理方式)
# kubectl apply -f xxx.yaml  (声明式对象配置管理方式（也适用于更新等）)

1. 创建资源
kubectl create deployment deployment-myapp --image=harbor.nihility.cn/library/myapp:v1
kubectl create deployment deployment-nginx --image=nginx
1.1 查看创建资源
	kubectl get deployment -o wide
	kubectl get deployments -o wide
1.2 删除创建资源
	kubectl delete deployment [DEPLOYMENT-NAME]

2. 运行资源
kubectl run pod-myapp --image=harbor.nihility.cn/library/myapp:v1 --port=80
2.1 查看运行资源
	kubectl get pods -o wide
2.2 删除运行资源
	kubectl delete pod [POD-NAME]

3. 暴露服务
kubectl expose deployments/deployment_name --type="NodePort" --port=(要暴露的容器端口) --name=(Service对象名字)
# 暴露 deployment 服务 --target-port=容器内端口, --port=对外暴露的端口
kubectl expose deployment deployment-myapp --port=8080 --target-port=80
kubectl expose deployment deployment-myapp --type="ClusterIP" --target-port=80 --port=8080 --name=deployment-myapp-8080
kubectl expose deployment/deployment-myapp --type="NodePort" --port=8089 --target-port=80 --name=deployment-myapp-8089
# 默认 --type 为 "ClusterIP"
-> curl 10.96.159.251:8080/hostname.html
kubectl expose deployment deployment-nginx --target-port=80 --port=8080 --name=deployment-nginx-8080
# 暴露 pod 服务
kubectl expose pod pod-myapp --port=80 --name=pod-myapp
kubectl expose pod pod-myapp --port=8080 --target-port=80 --name=pod-myapp-8080
-> curl 10.103.27.22:8080

3.1 查看服务信息
	kubectl get services [SERIVCE-NAME] -o wide
	kubectl get service [SERIVCE-NAME] -o wide
3.2 删除暴露服务
	kubectl delete services [SERVICE-NAME]

4. 扩容 (Deployment, ReplicaSet, Replication Controller, or StatefulSet)
kubectl scale --replicas=5 rc/foo rc/bar rc/baz
# If the deployment named mysql's current size is 2, scale mysql to 3.
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql
4.1 扩容为 3 个
kubectl scale --replicas=3 deployment deployment-myapp
4.2 缩小 pod 为 2 个
kubectl scale --replicas=2 deployment/deployment-myapp
```

##### 10.1 其他 pod 操作

```bash
1. 查看运行日志
kubectl logs -f [POD-NAME]
kubectl logs --tail=20 [POD-NAME] # most recent 20 lines
kubectl logs --since=1h [POD-NAME] # Show all logs from pod nginx written in the last hour

2. Execute a command in a container.
# 执行一个命令
kubectl exec [POD-NAME] -- command
# 交互式
kubectl exec -it deployment-myapp-5dc4948dd7-4zwxl -- /bin/sh

3. Attach to a process that is already running inside an existing container.
-> kubectl attach (POD | TYPE/NAME) -c CONTAINER
kubectl attach rs/nginx

4. 查看在 pod 中的所有容器
kubectl describe [pod/POD-NAME] -n default
kubectl describe pod/deployment-myapp-5dc4948dd7-9b65l -n default

4.1 查看 pod 描述
kubectl describe pods/pod-myapp
kubectl describe pod/pod-myapp
```

