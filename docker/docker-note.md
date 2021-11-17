### Docker 镜像/容器分层

```bash
docker inspect busybox

# 其中镜像层次展示
"Data": {
    "LowerDir": "/data/docker/overlay2/106c8b60aeb375917e6698933649f489e967f4fcc8633723fbae831a8d4e2baa/diff",
    "MergedDir": "/data/docker/overlay2/77d48b443e472e89dee3e2bef951fd020937a74aaa6e4f309101b76c0fa22d3e/merged",
    "UpperDir": "/data/docker/overlay2/77d48b443e472e89dee3e2bef951fd020937a74aaa6e4f309101b76c0fa22d3e/diff",
    "WorkDir": "/data/docker/overlay2/77d48b443e472e89dee3e2bef951fd020937a74aaa6e4f309101b76c0fa22d3e/work"
}
```

- **LowerDir**：当前镜像层依赖的下层镜像，[是 overlay2 （覆盖）文件系统的只读层，对于 docker 是按顺序组装的镜像层]（只读层）
- **UpperDir**：当前镜像层所新加的数据层，[overlay2 （覆盖）文件系统的 (read-write) 读写层，对于 docker 相当于包含该容器所做更改的容器特定层]（变更的读写层）
- **MergedDir**：是overlay2 （覆盖）文件系统的结果，Docker 在运行容器时有效地将 chroot 放入此目录。（表示 UpperDir 和 LowerDir 合并的结果，Docker 用它来运行容器）
- **WorkDir**：是 overlay2 （覆盖）文件系统所需的目录，需要一个空目录供内部使用

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

#### 容器间网络互通

##### 通过容器间 IP 访问

```bash
# container 1
$ docker run -it --name c1 --rm busybox /bin/sh
$ ip ad

# container 2
$ docker run -it --name c2 --rm busybox /bin/sh
$ ip ad

# 直接通过两个容器的 IP 地址访问，但是重启容器后 IP 地址可能改变，不通用
```

##### link 参数

对容器创建的顺序有要求，如果集群内部多个容器要互访，使用就不太方便

```bash
# container 1
$ docker run -it --name c1 --rm busybox /bin/sh

# container 2
$ docker run -it --name c2 --link c1:c1-alias --rm busybox /bin/sh
$ ping c1-alias
$ ping c1

# container 3
$ docker run -it --name c3 --link c1 --rm busybox /bin/sh
$ ping c1

# --link container-name:alias
# 使用 --link 容器名称[:容器别名] ，没有容器别名时，别名和容器名称一致，使用容器名称和别名都可以
```

##### 使用 bridge 网络

创建一个 bridge 网络

```bash
docker network create br

$ docker run -it --rm --name b1 --network br busybox /bin/sh
$ docker run -it --rm --name b2 --network br --network-alias box busybox /bin/sh
$ ping b1 / $ ping box

# --network br 使用新建的网络，默认可以通过 --name 访问
# --network-alias box 指定网络别名，可以通过这个别名访问
```

#### 创建容器时指定 IP

```bash
yum install -y iproute net-tools

docker run --rm -it --network br --ip 172.18.0.200 busybox /bin/sh
```

