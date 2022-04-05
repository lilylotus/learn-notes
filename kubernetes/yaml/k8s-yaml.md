# k8s yaml 编写规则

方式一

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
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

方式二

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  # https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container
  containers:
  - name: liveness
    image: busybox:1.35.0
    imagePullPolicy: IfNotPresent
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    ports:
    - name: livenesPort
      containerPort: 80
    env:
    - name: evnKeyName
      value: envKeyValue
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

## key 解释

### 镜像拉取策略

[imagePullPolicy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy)

键值：imagePullPolicy
默认值: IfNotPresent (不存在则拉取)

- IfNotPresent：
- Always
- Never