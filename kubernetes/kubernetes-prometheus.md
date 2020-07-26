`Prometheus` 项目地址： https://github.com/coreos/kube-prometheus

所需 docker image

```bash
# Prometheus:v0.5.0

grafana/grafana:7.1.0
jimmidyson/configmap-reload:v0.3.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
quay.io/coreos/kube-state-metrics:v1.9.5
quay.io/coreos/prometheus-operator:v0.40.0
quay.io/prometheus/alertmanager:v0.21.0
quay.io/prometheus/node-exporter:v0.18.1
quay.io/prometheus/prometheus:v2.20.0

# 压力测试
docker pull k8s.gcr.io/hpa-example
```

# 组件说明

- `MetricServer` :是 kubernetes 集群资源使用情况的聚合器，收集数据给 kubernetes 集群内使用，如 kubectl，hpa，scheduler 等。 
- `PrometheusOperator` :是一个系统监测和警报工具箱，用来存储监控数据。
- `NodeExporter` :用于各 node 的关键度量指标状态数据。 
- `KubeStateMetrics` :收集 kubernetes 集群内资源对象数据，制定告警规则。 
- `Prometheus` :采用 pull 方式收集 apiserver ， scheduler ， controller-manager ， kubelet 组件数据，通过 http 协议传输。 
- `Grafana` :是可视化数据统计和监控平台。

# 部署

```bash
git clone https://github.com/coreos/kube-prometheus.git
cd kube-prometheus/manifests

# 当所有的配置更改完成，镜像下载安装完成后，执行部署，在 prometheus 目录
# Create the namespace and CRDs, and then wait for them to be availble before creating the remaining resources
$ kubectl create -f manifests/setup
$ until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
$ kubectl create -f manifests/

# 删除
$ kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup

# 设置时区 Asia/Shanghai
$ timedatectl
$ timedatectl list-timezones
$ ntpdate time.pool.aliyun.com

# 同步系统时间到硬件时间，不建议硬件时间随系统时间变化
$ timedatectl set-local-rtc 0
$ hwclock --systohc
# 是否启用自动同步时间
$ timedatectl set-ntp yes|no

# 使用 ntpdate 同步时间
$ systemctl start crond
/etc/ntp.conf
server time.pool.aliyun.com
server ntp1.aliyun.com
server ntp2.aliyun.com
server ntp3.aliyun.com

$ timedatectl set-timezone Asia/Shanghai
$ yum install -y ntp
$ systemctl start ntpd && systemctl enable ntpd
$ timedatectl set-ntp on
```

修改 grafana-service.yaml，使用 NodePort 方式访问 grafana，可以指定 nodePort: 暴露端口
修改 prometheus-service.yaml，改为 NodePort，可以指定 nodePort: 暴露端口
修改 alertmanager-service.yaml，改为 NodePort，可以指定 nodePort: 暴露端口

### Access the dashboards

Prometheus, Grafana, and Alertmanager dashboards can be accessed quickly using `kubectl port-forward` 

Prometheus：Then access via [http://localhost:9090](http://localhost:9090/)

```bash
$ kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
```

基本的查询 K8S 集群中每个 POD 的 CPU 使用情况

```
sum by (pod_name)(rate(container_cpu_usage_seconds_total{image!="",pod_name!=""}[1m]))
```

Grafana
Then access via [http://localhost:3000](http://localhost:3000/) and use the default grafana user:password of `admin:admin`.

```bash
$ kubectl --namespace monitoring port-forward svc/grafana 3000
```

Alert Manager：Then access via [http://localhost:9093](http://localhost:9093/)

```bash
$ kubectl --namespace monitoring port-forward svc/alertmanager-main 9093
```

查看 node 运行信息

```bash
$ kubectl top node
```

# Horizontal Pod Autoscaling

Horizontal Pod Autoscaling 可以根据 CPU 利用率自动伸缩一个 Replication Controller、Deployment 或者 Replica Set 中的 Pod 数量

```bash
kubectl run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=200m --expose --port=80
```

创建 HPA 控制器

```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

增加负载,查看负载节点数目

```bash
$ kubectl run -i --tty load-generator --image=busybox /bin/sh
$ while true; do wget -q -O - http://php-apache.default.svc.cluster.local; done
```

# 资源限制 - Pod

`Kubernetes` 对资源的限制实际上是通过 `cgroup` 来控制的，`cgroup` 是容器的一组用来控制内核如何运行进程的相关属性集合。针对内存、CPU 和各种设备都有对应的 `cgroup`

默认情况下，Pod 运行没有 CPU 和内存的限额。 这意味着系统中的任何 Pod 将能够像执行该 Pod 所在的节点一样，消耗足够多的 CPU 和内存 。一般会针对某些应用的 pod 资源进行资源限制，这个资源限制是通过 resources 的 requests 和 limits 来实现

```yaml
spec:
  containers:
  - image: xxxx
    imagePullPolicy: Always
    name: auth
    ports:
    - containerPort: 8080
      protocol: TCP
    resources:
      limits:
        cpu: "4"
        memory: 2Gi
      requests:
        cpu: 250m
        memory: 250Mi
```

requests 要分分配的资源，limits 为最高请求的资源值。可以简单理解为初始值和最大值

# 资源限制 - 名称空间

## I、计算资源配额

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: spark-cluster
spec:
  hard:
    pods: "20"
    requests.cpu: "20"
    requests.memory: 100Gi
    limits.cpu: "40"
    limits.memory: 200Gi
```

## II、配置对象数量配额限制

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: spark-cluster
spec:
  hard:
    configmaps: "10"
    persistentvolumeclaims: "4"
    replicationcontrollers: "20"
    secrets: "10"
    services: "10"
    services.loadbalancers: "2"
```

## III、配置 CPU 和 内存 LimitRange

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 50Gi
      cpu: 5
    defaultRequest:
      memory: 1Gi
      cpu: 1
    type: Container
```

- `default` 即 limit 的值
- `defaultRequest` 即 request 的值