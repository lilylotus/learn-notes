# Helm 概念

在没使用 helm 之前，向 kubernetes 部署应用，我们要依次部署 deployment、svc 等，步骤较繁琐。况且随着很多项目微服务化，复杂的应用在容器中部署以及管理显得较为复杂，helm 通过打包的方式，支持发布的版本管理和控制，很大程度上简化了 Kubernetes 应用的部署和管

Helm 本质就是让 K8s 的应用管理(Deployment，Service 等 ) 可配置，能动态生成。通过动态生成 K8s 资源清单文件(deployment.yaml，service.yaml)。然后调用 Kubectl 自动执行 K8s 资源部

Helm 是官方提供的类似于 YUM 的包管理器,是部署环境的流程封装。
Helm 有两个重要的概念: `chart` 和 `release`

- `chart` 是创建一个应用的信息集合，包括各种 Kubernetes 对象的配置模板、参数定义、依赖关系、文档说明等。chart 是应用部署的自包含逻辑单元。可以将 chart 想象成 apt、yum 中的软件安装包
- `release` 是 chart 的运行实例，代表了一个正在运行的应用。当 chart 被安装到 Kubernetes 集群，就生成一个 release。chart 能够多次安装到同一个集群，每次安装都是一个 release

`Helm` 客户端负责 chart 和 release 的创建和管理以及和 Tiller 的交互。
`Tiller` 服务器运行在 Kubernetes 集群中，它会处理 Helm 客户端的请求，与 Kubernetes API Server 交互

# Helm 部署

下载地址：https://github.com/helm/helm/releases

```bash
$ wget https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz
$ tar zxvf helm-v2.16.9-linux-amd64.tar.gz
$ mv linux-amd64/helm /usr/local/bin
$ helm version
```

## Helm 初始化使用

```bash
1. Initialize a Helm Chart Repository
$ helm init
# 或者
$ helm init --upgrade --tiller-image cnych/tiller:v2.10.0
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
$ helm search repo stable

2. Install an Example Chart
$ helm repo update
$ helm show chart stable/mysql / helm show all stable/mysql
$ helm install stable/mysql --generate-name

3. Uninstall a Release
$ helm uninstall smiling-penguin

4. Help
$ helm get -h
```

## Helm Tiller 安装

Helm installs the `tiller` service on your cluster to manage charts. Since RKE enables RBAC by default we will need to use `kubectl` to create a `serviceaccount` and `clusterrolebinding` so `tiller` has permission to deploy to the cluster.

- Create the `ServiceAccount` in the `kube-system` namespace.
- Create the `ClusterRoleBinding` to give the `tiller` account access to the cluster.
- Finally use `helm` to install the `tiller` service

```bash
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:tiller

helm init --service-account tiller

# Users in China: You will need to specify a specific tiller-image in order to initialize tiller. 
# The list of tiller image tags are available here: https://dev.aliyun.com/detail.html?spm=5176.1972343.2.18.ErFNgC&repoId=62085. 
# When initializing tiller, you'll need to pass in --tiller-image

$ helm init --service-account tiller \
--tiller-image registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:<tag>
```

<font color="red">注意：</font> `helm v2.16.9` 在 `helm init` 后自动部署了 `tiller-deploy` 到 `kube-system` 下
` kubectl get pod -n kube-system -l app=helm`
就无需执行下面 `tiller` 安装

```yaml
# rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
```

```bash
$ kubectl create -f rbac-config.yaml
-> serviceaccount/tiller created 
-> clusterrolebinding.rbac.authorization.k8s.io/tiller created

$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
# 上面这一步非常重要，不然后面在使用 Helm 的过程中可能出现Error: no available release name found的错误信息。

$ helm init --service-account tiller --skip-refresh
```



校验安装

```bash
$ kubectl -n kube-system  rollout status deploy/tiller-deploy
-> deployment "tiller-deploy" successfully rolled out

$ helm version
-> Client: &version.Version{SemVer:"v2.16.9", GitCommit:"8ad7037828e5a0fca1009dabe290130da6368e39", GitTreeState:"clean"}
-> Server: &version.Version{SemVer:"v2.16.9", GitCommit:"8ad7037828e5a0fca1009dabe290130da6368e39", GitTreeState:"clean"}
```

# Helm 自定义模板

```bash
$ mkdir helm && cd helm

# 创建自描述文件 Chart.yaml , 这个文件必须有 name 和 version 定义
$ cat <<EOF > Chart.yaml
name: hello-world
version: 1.0.0
EOF

# 创建模板文件, 用于生成 Kubernetes 资源清单 (manifests)
$ mkdir templates

$ cat <<EOF > ./templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: harbor.nihility.cn/library/myapp:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
EOF

$ cat <<'EOF' > ./templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: hello-world
EOF
```

helm 执行

```bash
# 在所建的 helm 目录下，helm install RELATIVE_PATH_TO_CHART 创建一次 Release
$ helm install .
# 更新了文件重新 install 升级
$ helm upgrade ranting-manatee .

$ helm  list
# 查看删除的历史/部署历史/失败历史
$ helm list --deleted [--deployed, --failed]
# 查看所有版本
$ helm list -a [-all]

#查询特定状态
$ helm status RELEASE_NAME

# 删除当前版本及相关 Kubernetes 资源
$ helm delete ranting-manatee
# 完全删除
$ helm delete --purge ranting-manatee

# 回滚版本
$ helm rollback RELEASE_NAME REVISION_NUMBER
$ helm rollback ranting-manatee 2

# 构建历史
$ helm history ranting-manatee
```

## 配置环境值

```bash
# 配置文件 values.yaml
$ cat <<EOF > values.yaml
image:
  repository: harbor.nihility.cn/library/myapp
  tag: v1
EOF

# 这个文件中定义的值,在模板文件中可以通过 .VAlues 对象访问到
$ cat <<EOF > templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
EOF

# 部署安装
# 在 values.yaml 中的值可以被部署 release 时用到的参数
# --values YAML_FILE_PATH 或 --set key1=value1, key2=value2 覆盖掉
$ helm install --set image.tag='latest'

# 升级版本
$ helm upgrade -f values.yaml ranting-manatee .
```

## Debug

```bash
# 使用模板动态生成K8s资源清单,非常需要能提前预览生成的结果。
# 使用--dry-run --debug 选项来打印出生成的清单文件内容,而不执行部署
helm install . --dry-run --debug --set image.tag=latest
```

