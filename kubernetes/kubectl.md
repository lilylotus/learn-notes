#### 运行一个镜像

```bash
kubectl run NAME --image=image [--env="key=value"] [--port=port] [--replicas=replicas] [--dry-run=bool] [--overrides=inline-json] [--command] -- [COMMAND] [args...] [options]

kubectl run nginx-deployment --image=hub.nihility.cn/library/myapp:v1 --port=80 --replicas=1

kubectl get deployment
kubectl get rs
kubectl get svc
kubectl get pod [-o wide]

# 删除 pod
kubectl delete pod nginx-deployment-b69685d5-rnw6z

# 扩容节点
kubectl scale --replicas=3 deployment/nginx-deployment

# 暴露节点

kubectl expose --help
# kubectl expose deployment nginx --port=80 --target-port=8000
# 暴露内部地址
kubectl expose deployment nginx-deployment --port=30000 --target-port=80

kubectl get svc
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
nginx-deployment   ClusterIP   10.98.173.65   <none>        30000/TCP   3m38s
# TYPE 有 ClusterIP (内网映射) 和 NodePort (可以外网访问)
# 修改 TYPE
kubectl edit svc nginx-deployment
	> type: ClusterIP > type: NodePort
nginx-deployment   NodePort    10.98.173.65   <none>        30000:32554/TCP   6m29s

# 查看 IP 映射
ipvsadm -Ln | grep 10.98.173.65
```



```bash
# 查看详情
kubectl describe pod myapp
kubectl log myapp [-c test 在有多个容器是要指定具体容器名称]
```

