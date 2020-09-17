**一. 创建 network 指定 IP**

`docker network create --subnet=172.20.0.0/16 network-name`

示例: `docker network create --subnet=172.20.0.0/16 network`

Additionally, you also specify the `--gateway` `--ip-range` and `--aux-address` options.

```bash
$ docker network create --driver=bridge --subnet=192.168.0.0/16 br0

# 指定详细参数
$ docker network create \
  --driver=bridge \
  --subnet=172.28.0.0/16 \
  --ip-range=172.28.5.0/24 \
  --gateway=172.28.5.254 \
  br0
```

**二. 运行 docker 指定 network**

```bash
docker run -it --name u01 \
--network=net20 \
--ip=172.20.0.2 \
--privileged \
ubuntu:18.04 /bin/bash
```

**三. docker 添加多个 network**

```bash
添加一个 network net20 : 
docker run -it --name u02 \
--network=net20 \
--ip=172.20.0.3 \
--privileged \
ubuntu:18.04 /bin/bash
添加另一个 network net18 : 
docker network connect net18 u02
```

1. 使用 docker-compose

   ```bash
   version: '3.0'
   services:
     web:
       image: ubuntu:18.04
       networks:
         - net20
         - net18
   networks:
     net20:
     net18:
   ```

   