# Deployments

[Workload Resources - Pod](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Pod)

[Pod - Container](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container)

```yaml
apiVersion: v1
kind: pod
# https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/object-meta/#ObjectMeta
metadata:
  name: pod-name
  labels:
    test: liveness
# PodSpec https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec
spec:
  containers:
    ...

```

## Creating a Deployment (pods)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
# DeploymentSpec https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/#DeploymentSpec
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  # https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-template-v1/#PodTemplateSpec
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
- `metadata.name`：Deployment 名称：`nginx-deployment`
- `spec.replicas` : 指定 pod 的数量
- `spec.selector`：定义 Deployment 如何找到要管理的 Pod
- `spec.template` 字段下包含属性：
    - `metadata.labels` : pod 的标签
    -  `spec`：pod 运行的容器
    - `spec.template.spec.containers[0].name`: 创建一个容器名命名

```bash
# create the deployment
kubectl apply -f nginx-deployment.yaml

# check deployment
kubectl get deployments

# To see the Deployment rollout status
kubectl rollout status deployment/nginx-deployment

# To see the ReplicaSet (rs) 
kubectl get rs

# To see the labels automatically generated for each Pod
kubectl get pods --show-labels

# scale
kubectl scale deployment/nginx-deployment --replicas=10
kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80

# Then update the image of the Deployment:
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1

```