# visualVM

## 启动 JMX 参数

```bash
-Dcom.sun.management.jmxremote # 启用jmx
-Dcom.sun.management.jmxremote.ssl=false # 不需要ssl连接
-Dcom.sun.management.jmxremote.authenticate=false # 不需要权限密码连接
-Dcom.sun.management.jmxremote.port=1099 # 设置jmx连接端口
-Djava.rmi.server.hostname=192.168.10.6  # 设置jmx指定服务器Ip(如果不设置，则默认是本地localhost)
```

## jstatd 连接

### 1. 添加配置文件

```bash
vim jstatd.all.policy

grant codebase "file:${java.home}/../lib/tools.jar" {
   permission java.security.AllPermission;
};
```

### 2. 启动 jstatd

```bash
nohup jstatd \
-J-Djava.security.policy=jstatd.all.policy \
-J-Djava.rmi.server.hostname=192.168.10.6 \
-p 11099 \
-J-Djava.rmi.server.logCalls=true \
> jstatd.log 2>&1 &
```

参数说明：

- -J-Djava.security.policy=jstatd.all.policy = 号后面的是文件的绝对路径；
- -J-Djava.rmi.server.logCalls=true 打开日志,如果客户端有连接过来的请求,可以监控到,便于排错；
- -J-Djava.rmi.server.hostname=192.168.10.6 指明本机 hostname 对应的本机地址,确保该地址可以给客户机访问。因为有的服务器 hostname 对应的 ip 不一定是外网能连上的，最好在这里直接明确指定；
- -p 11099 指定服务的端口号，默认是1099。也是可选参数。