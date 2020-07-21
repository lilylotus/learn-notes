#### 卷操作

创建/查看/使用/删除

```bash
$ docker volume create vol
$ docker volume inspect vol
$ docker run -it --name vol -v vol:/data ubuntu:18.04 /bin/bash -c 'date "+%Y%m%d %H:%M:%S" >> /data/date.txt'

# 只读方式挂载
$ docker run -it --name vol -v vol:/data:ro ubuntu:18.04 /bin/bash -c 'cat /data/date.txt'

$ docker volume rm vol
```

注意：容器删除后创建的卷不会随之删除。删除卷时确保没有容器使用该卷。