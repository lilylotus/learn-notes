##### CMD

<font color="red">注意：`Dockerfile` 中仅能有一个 `CMD` 指令，若有多个指令也仅最后一个有效</font>
`CMD` 指令的最主要一个目的是给正在运行的容器提供默认参数
如果使用 `CMD` 指令为 `ENTRYPOINT` 指令提供默认的参数，它们两者都应该指定为 *JSON array* 的格式

> *exec* 形式被解析为 JSON array，意味着必须使用双引号(`""`)引上 word 而非单引号(`''`)

与 *shell* 形式不用， *exec* 形式不会调用命令 shell，不会有变量替换。
正确的方式：`CMD [ "sh", "-c", "echo $HOME" ]`
`CMD` 首选的格式是 *array* 形式

```bash
CMD ["executable","param1","param2"] (exec form, this is the preferred form)
CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
CMD command param1 param2 (shell form)
```

```bash
FROM ubuntu:18.04
CMD ["/usr/bin/wc", "--help"]
```

若是使用指定参数 `docker run` 那么它们将会替换默认在 `CMD` 中的参数。
`CMD` 在构建期间什么都没执行，但为 *image* 指定了预期的命令。

##### LABEL

`LABEL` 指令给 *image* 添加元数据

```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

```dockerfile
LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"
LABEL version="1.0"
LABEL description="This text illustrates \
that label-values can span multiple lines."
```

`docker image inspect` 查看 images's 标签， `--format` 选项仅显示

```dockerfile
docker image inspect --format='' myimage
```

##### EXPOSE

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

指定 *port* 是否监听 *TCP* 或 *UDP*, 默认是 *TCP* 若没有指定。
<font color="blue">`-P` flag 指的是公布所有 *exposed* 的端口，映射它们到高端口</font>

```dockerfile
EXPOSE 80/udp
# 或者
EXPOSE 80/udp
EXPOSE 80/TCP
```

##### ENV

```dockerfile
ENV <key> <value>
ENV <key>=<value> ...
```

第一种格式 `<key>` 空格后的会作为 `<value>`
第二种格式在一行 设置多个变量

```dockerfile
ENV myName="John Doe" myDog=Rex\ The\ Dog \
    myCat=fluffy
# 等同于
ENV myName John Doe
ENV myDog Rex The Dog
ENV myCat fluffy
```

`docker run --env <key>=<value>`

##### ADD

两种格式

```dockerfile
ADD [--chown=<user>:<group>] <src>... <dest>
ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

> `--chown` 仅支持 Dockerfile 使用在 Linux 构建的容器

```dockerfile
ADD hom* /mydir/

# ? 代替任意单个字符
ADD home?.txt /mydir/
```

`<dist>` 是绝对路径或在相对 `WORKDIR` 的路径, 添加 "test.txt" 到 `<WORKDIR>/relativeDIR/`

```dockerfile
ADD test.txt relativeDir/
```

绝对路径

```dockerfile
ADD test.txt /absoluteDir/
```

新的 *file* 和  *directories* 被创建 UID 和 GID 是 0，除了选定 `--chown`

```dockerfile
ADD --chown=55:mygroup files* /somedir/
ADD --chown=bin files* /somedir/
ADD --chown=1 files* /somedir/
ADD --chown=10:11 files* /somedir/
```

> 注意：目录本身不会被复制，仅是它的内容

##### COPY

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

```dockerfile
COPY hom* /mydir/
COPY hom?.txt /mydir/
# 相对目录
COPY test.txt relativeDir/
COPY test.txt /absoluteDir/
```

```dockerfile
COPY --chown=55:mygroup files* /somedir/
COPY --chown=bin files* /somedir/
COPY --chown=1 files* /somedir/
COPY --chown=10:11 files* /somedir/
```

##### ENTRYPOINT

```dockerfile
# exec form,preferred form
ENTRYPOINT ["executable", "param1", "param2"]
# shell form
ENTRYPOINT command param1 param2
```

`ENTRYPOINT` 允许配置容器，将会可执行的运行。

```dockerfile
docker run -it --rm -p 80:80 nginx
```

`docker run <image>` 会附加在 `exec` 形式的 `ENTRYPOINT` 在所有元素之后。将会覆盖所有 `CMD` 指定的参数。
`-d` 将会添加参数到 entry point.

```dockerfile
FROM ubuntu
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
# -> top -b -c
```

