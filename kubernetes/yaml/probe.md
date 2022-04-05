# 探针 (probe)

探针是 kubectl 对容器定期执行诊断，调用由容器实现的 Headler
- ExecAction: 在容器内部执行，退出返回状态码为 0 表示诊断成功
- TCPSocketAction: 对指定容器 IP 地址进行 TCP 检查，端口打开，则诊断完成
- HTTPGetAction：对指定容器发送 Http Get 请求，响应状态码  >= 200 && < 400 ，成功

Pod 生命周期探测的方式：
[Pod Lifecycle Probe](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#lifecycle-1)
[Probe params](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Probe)
- livenessProbe: 表明容器是否运行。若是失败，kubectl 会杀掉容器，受到重启策略执行
- readinessProbe: 指示容器是否准备好服务，探测失败，断点控制器会把 pod 匹配的 service 的端点中删除该 pod 的 IP 地址
- startupProbe: StartupProbe 表示 Pod 已成功初始化。

[Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

[生命周期处理器 LifecycleHandler](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#LifecycleHandler)
- `exec`: ExecAction
- `httpGet ` : HTTPGetAction
- `tcpSocket ` : TCPSocketAction


## Define a liveness command

[define-a-liveness-command](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command)

command returns a non-zero value, the kubelet kills the container and restarts it.

```yaml
# exec-liveness.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: busybox:1.35.0
    imagePullPolicy: IfNotPresent
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      # wait 5 seconds before performing the first probe
      initialDelaySeconds: 5
      # perform a liveness probe every 5 seconds
      periodSeconds: 5
```

## Define a liveness HTTP request

[Define a liveness HTTP request](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request)

Any code greater than or equal to 200 and less than 400 indicates success

```yaml
# http-liveness.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/liveness
    args:
    - /server
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
```

```go
http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
    duration := time.Now().Sub(started)
    if duration.Seconds() > 10 {
        w.WriteHeader(500)
        w.Write([]byte(fmt.Sprintf("error: %v", duration.Seconds())))
    } else {
        w.WriteHeader(200)
        w.Write([]byte("ok"))
    }
})
```

## Define a TCP liveness probe

[Define a TCP liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-tcp-liveness-probe)

kubelet will attempt to open a socket to your container on the specified port. If it can establish a connection, the container is considered healthy, if it can't it is considered a failure.

If the liveness probe fails, the container will be restarted.
If the readiness probe succeeds, the Pod will be marked as ready.

```yaml
# tcp-liveness-readiness
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
  - name: goproxy
    image: k8s.gcr.io/goproxy:0.1
    ports:
    - containerPort: 8080
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20
```

## 指定探针 （probe）使用端口

```yaml
ports:
- name: liveness-port
  containerPort: 8080
  hostPort: 8080

livenessProbe:
  httpGet:
    path: /healthz
    port: liveness-port
  failureThreshold: 1
  periodSeconds: 10

startupProbe:
  httpGet:
    path: /healthz
    port: liveness-port
  failureThreshold: 30
  periodSeconds: 10
```

示例
```yaml
spec:
  terminationGracePeriodSeconds: 3600  # pod-level
  containers:
  - name: test
    image: ...

    ports:
    - name: liveness-port
      containerPort: 8080
      hostPort: 8080

    livenessProbe:
      httpGet:
        path: /healthz
        port: liveness-port
      failureThreshold: 1
      periodSeconds: 60
      # Override pod-level terminationGracePeriodSeconds #
      terminationGracePeriodSeconds: 60
```

## HTTP 探针（probe）

[HTTP probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#http-probes)

