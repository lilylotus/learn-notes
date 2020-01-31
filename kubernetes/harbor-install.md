#### 安装 docker-compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

#### 镜像推送

```bash
# 登录上面配置好的本地 harbor
docker login https://hub.nihility.cn

# 拉取一个镜像
docker pull wangyanglinux/myapp:v1

# Tag an image for this project:
docker tag SOURCE_IMAGE[:TAG] hub.nihility.cn/library/IMAGE[:TAG]

# Push an image to this project:
docker push hub.nihility.cn/library/IMAGE[:TAG]
```

