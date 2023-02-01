```bash
# 启动
minikube start --driver=docker --kubernetes-version=v1.23.8 [--image-mirror-country='cn'] [--cni calico]

# 挂载卷启动
minikube start --driver=docker --kubernetes-version=v1.23.8 --cni calico --mount --mount-string="/minikube/data:/minikube/data"

# 关闭
minikube stop

# kubectl 别名
alias kubectl="minikube kubectl -- "

# 运行状态查看
minikube status
minikube node list

# 删除运行缓存
minikube delete --all --purge

# 网络暴露
minikube service list
minikube service --url nginx-service
kubectl port-forward --address 0.0.0.0 -n default service/nginx-service 32615:32615
```

