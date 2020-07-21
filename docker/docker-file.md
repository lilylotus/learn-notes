#### 1. docker-file

参考地址：https://docs.docker.com/engine/reference/builder/

##### 1.1 docker-file 构建

默认依据命令执行目录下  `Dockerfile` 文件构建新镜像

```bash
docker build .
-t, --tag list # 指定新 image 的 tag， 可以同时指定多个 repositories
-f, --file string [path/to/Dockerfile] # Dockerfile 的路径

$ docker build -f /path/file/Dockerfile -t shy/myapp:v1
```

#### 2. Dockerfile Format

`#` 为行注解，`Dockerfile` 必须以 `FORM` 指令开头

##### 2.1 环境变量

使用 `$var` 或者 `${var}` 格式使用变量
可用于：`ADD`, `COPY`, `ENV`, `EXPOSE`, `FROM`, `LABEL`, `STOPSIGNAL`, `USER`, `VOLUME`, `WORKDIR`, `ONBUILD`

```bash
ENV abc=hello
ENV abc=bye def=$abc
ENV ghi=$abc
# 在整个指令中，环境变量替换将对每个变量使用相同的值
# def -> hello , ghi -> bye
```

##### 2.2 指令列表

`FROM`, `RUN`, `CMD`, `LABEL`, `EXPOSE`, `ADD`, `COPY`, `ENTRYPOINT`, `VOLUME`, `WORKDIR`

##### FROM

```bash
<image>[:<tag>]

---
ARG VERSION=latest
FROM busybox:$VERSION
```

##### RUN

一次 *RUN* 指令执行就会在 *image* 中产生一层

```bash
RUN <command> (shell 形式，在 Linux 默认 [/bin/sh -c])
RUN ["executable", "param1", "param2"] (exec 形式，)
```

<font color="blue">*shell* 形式时可以使用 `\` 做多命令的连接，当作一个命令执行，只产生一层</font>

```bash
RUN /bin/bash -c 'source $HOME/.bashrc; \
echo $HOME'
# 等同于
RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'
```

*exec* 形式解析为 *JSON array*，意味着仅能使用双引号(`""`)不能用单引号(`''`)

```bash
RUN ["/bin/bash", "-c", "echo hello"]
```

##### CMD

<font color="red">注意：一个 `Dockerfile` 仅能有一个 `CMD` 指令，有多个时仅最后一个生效</font>

```bash
CMD ["executable","param1","param2"] (exec form, this is the preferred form)
CMD ["param1","param2"] 			 (as default parameters to ENTRYPOINT)
CMD command param1 param2 			 (shell form)
```

`CMD` 的目的是给运行中的容器提供一个默认值。

##### VOLUME

```dockerfile
VOLUME ["/data"]
VOLUME /data
```

`VOLUME` 指令并不会在 `docker build` 的时候生成卷，而是在 `docker run` 的时候产生，目录默认在 `<docker-home>/volumes` 目录下

startup 指定脚本

```bash
#!/bin/bash
echo "startup args : $@"
date "+%Y%m%d %H:%M:%S" >> /data/date.txt
```

```dockerfile
FROM ubuntu:18.04
ADD startup /opt
RUN chmod +x /opt/startup

#RUN mkdir /data && echo "Hello VOLUME" >> /data/hello.txt
VOLUME /data

ENTRYPOINT ["/opt/startup", "Dockerfile VOLUME instruction."]
```

```bash
$ docker build -t local/volume:v0.1 .

# 不能加 --rm , 会在容器结束后自动删除卷
$ docker run -it local/volume:v0.1
	-> startup args : Dockerfile VOLUME instruction.
	
# 查看 docker run 后的容器元数据
$ docker inspect aaf3f25cce69

$ docker run -it ubuntu:18.04 /bin/bash -c "Hello Docker Ubuntu:18.04"
-> 是没有 Mounts 数据产出，不会自动挂载卷
```

容器在 `docker run` 后自动生成的挂在卷信息

```json
"Mounts": [
    {
        "Type": "volume",
        "Name": "42c48c61805e81b19a46e1331e8315204cf5ec3a363e4f303e7823ec0840d4d2",
        "Source": "/data/docker/volumes/42c48c61805e81b19a46e1331e8315204cf5ec3a363e4f303e7823ec0840d4d2/_data",
        "Destination": "/data",
        "Driver": "local",
        "Mode": "",
        "RW": true,
        "Propagation": ""
    }
]
```

---

#### `CMD` 和 `ENTRYPOINT` 区别和关联

<font color="blue">`CMD` 启动容器时候指定了运行的命令，则会覆盖掉 CMD 指定的命令</font>
<font color="blue">`ENTRYPOINT`  容器启动后执行的命令，并且不可被 `docker run` 提供的参数覆盖</font>

```dockerfile
CMD ["executable","param1","param2"] exec 执行，推荐方式
CMD ["param1","param2"] 提供 ENTRYPOINT 的默认参数

ENTRYPOINT ["executable", "param1", "param2"] exec 执行，推荐方式
```

相同点：

- 都可以 shell 或 exec 函数调用的方式执行命令
- 存在多个 `CMD` 指令或 `ENTRYPOINT` 指令时，仅最后一个生效

差异：

- `CMD` 指令指定的容器启动时命令可以被 `docker run` 指定的命令覆盖，而 `ENTRYPOINT` 指令指定的命令不能被覆盖，而是将 `docker run` 指定的参数当做 `ENTRYPOINT` 指定命令的参数
- `CMD` 指令可以为 `ENTRYPOINT` 指令设置默认参数，而且可以被 `docker run` 指定的参数覆盖

##### 差异一

> `CMD` 指令指定的容器启动时命令可以被 `docker run` 指定的命令覆盖，而 `ENTRYPOINT` 指令指定的命令不能被覆盖，而是将 `docker run` 指定的参数当做 `ENTRYPOINT` 指定命令的参数

*startup* 脚本，打印执行参数

```bash
#!/bin/bash
echo "startup args : $@"
```

`CMD` 编写 `Dockerfile`

```dockerfile
FROM ubuntu:18.04
ADD startup /opt
RUN chmod +x /opt/startup

CMD ["/opt/startup"]
```

```bash
$ docker build -t local/cmd:v0.1 .
```

`ENTRYPOINT` 编写 `Dockerfile`

```dockerfile
FROM ubuntu:18.04
ADD startup /opt
RUN chmod +x /opt/startup

ENTRYPOINT ["/opt/startup"]
```

```bash
$ docker build -t local/entrypoint:v0.1 .
```

执行 `docker run`

```bash
$ docker run -it --rm local/cmd:v0.1
	-> startup args :
$ docker run -it --rm local/cmd:v0.1 /bin/bash -c 'echo Hello'
	-> Hello

$ docker run -it --rm local/entrypoint:v0.1
	-> startup args :
$ docker run -it --rm local/entrypoint:v0.1 /bin/bash -c 'echo Hello'
	-> startup args : /bin/bash -c 'echo Hello'
```

##### 差异二

> `CMD` 指令可以为 `ENTRYPOINT` 指令设置默认参数，而且可以被 `docker run` 指定的参数覆盖

```dockerfile
FROM ubuntu:18.04
ADD startup /opt
RUN chmod +x /opt/startup

CMD ["arg2-cmd"]
ENTRYPOINT ["/opt/startup", "arg1-entrypoint"]
```

```bash
$ docker build -t local/ec:v0.1 .

# 运行
$ docker run -it --rm local/ec:v0.1
	-> startup args : arg1-entrypoint arg2-cmd
$ docker run -it --rm local/ec:v0.1 arg3
	-> startup args : arg1-entrypoint arg3
```

##### 注意

`CMD` 指令为 `ENTRYPOINT` 指令提供默认参数是基于镜像层次结构生效的，而不是基于是否在同个 `Dockerfile` 
如果 `Dockerfile` 指定基础镜像中是 `ENTRYPOINT` 指定的启动命令，则该 `Dockerfile` 中的 `CMD` 依然是为基础镜像中的 `ENTRYPOINT` 设置默认参数

```dockerfile
FROM ubuntu:18.04
ADD startup /opt
RUN chmod +x /opt/startup
ENTRYPOINT ["/opt/startup", "in base:v0.1"]
```

`docker build -t local/base:v0.1 .`

```dockerfile
FROM local/base:v0.1
CMD ["/bin/bash", "-c", "echo in super:v0.1"]
```

`docker build -t local/super:v0.1 .`

```bash
$ docker run -it --rm local/super:v0.1
	-> startup args : in base:v0.1 /bin/bash -c echo in super:v0.1
```

证实了 `CMD` 依然为基础镜像中的 `ENTRYPOINT` 指定提供了默认参数

