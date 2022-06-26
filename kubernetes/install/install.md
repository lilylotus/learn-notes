## 使用 configuration 文件初始化

[Using kubeadm init with a configuration file](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file)

print default configuration : `kubeadm config print --init-defaults`

list images: `kubeadm config images list --kubernetes-version ${k8s_version}`
pull the images: `kubeadm config images pull --kubernetes-version ${k8s_version}`
pull k8s images: `kubeadm config images pull --config=kubeadm-init.yaml`

init command: `kubeadm init --config=kubeadm-init.yaml --upload-certs | tee kubeadm-init.log`

## network plugin calico install

[Kubernetes Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)
[Networking Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy)

[calico addon](https://projectcalico.docs.tigera.io/about/about-calico)
[install calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart)

```bash
# 1. Install the Tigera Calico operator and custom resource definitions.
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml

# 2. Install Calico by creating the necessary custom resource.
# may need to change the default IP pool CIDR to match your pod network CIDR.
kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml

# 3. Confirm that all of the pods are running with the following command.
watch kubectl get pods -n calico-system

```

## network plugin flannel

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

## 修改 kube-proxy

`kubectl edit configmap -n kube-system kube-proxy`

```yaml
...
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
ipvs:
  strictARP: true
...
```

## install ingress-nginx

[Ingress-Nginx Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/)

install command : `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/baremetal/deploy.yaml`

## dashbord

[Deploy and Access the Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

[Kubernetes Dashboard git release](https://github.com/kubernetes/dashboard/releases)

Deploying the Dashboard UI :
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
```

获取登录 token :
```bash
kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token
```