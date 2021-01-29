### 拉取镜像

```bash
# 带配置 web 管理台
docker pull rabbitmq:3.8.11-management-alpine
docker pull rabbitmq:3.8.11-management
# 仅 rabbitmq 服务
docker pull rabbitmq:3.8.11-alpine
docker pull rabbitmq:3.8.11
```

### 运行

```bash
docker run -d --rm \
--name rabbit \
-p 50006:15672 -p 50007:5672 \
-v $pwd/data:/data \
rabbitmq:3.8.11-management-alpine
```

### 配置

```bash
rabbitmqctl add_user rabbit rabbit
rabbitmqctl set_user_tags rabbit administrator
rabbitmqctl set_permissions -p "/" rabbit '.*' '.*' '.*'
```

