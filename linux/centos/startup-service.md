#### 创建启动服务脚本

脚本路径 `/usr/lib/systemd/system/xx.service`, 以 `754` 的权限保存服务配置！！！

```
[Unit]:服务的说明
Description:描述服务
After:描述服务类别

[Service]服务运行参数的设置
Type=forking是后台运行的形式
ExecStart为服务的具体运行命令
ExecReload为重启命令
ExecStop为停止命令
PrivateTmp=True表示给服务分配独立的临时空间
注意：启动、重启、停止命令全部要求使用绝对路径

[Install]服务安装的相关设置，可设置为多用户
```

`docker` 服务实例 `/usr/lib/systemd/system/docker.service`

```bash
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
# forking 是后台运行的形式
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
```

自定义测试

```bash
[Unit]
Description=Start Script Test
After=network-online.target firewalld.service containerd.service
Wants=network-online.target

[Service]
Type=forking
ExecStart=/root/sh/start.sh start
ExecReload=/root/sh/start.sh reload
ExecStop=/root/sh/start.sh stop

[Install]
WantedBy=multi-user.target
```

#### 启动脚本示例

> `$MAINPID` is a systemd variable for your service that points to the PID of the main application.
> 常用信号：
> `HUP` : kill -s HUP pid
> 让 Linux 缓和的执行进程关闭，然后重启。在对配置文件修改后需要重启进程时可发送此信号。

##### nginx 启动

```bash
[Unit]
Description=nginx - high performance web server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target

#-------------------------------
$MAINPID is a systemd variable for your service that points to the PID of the main application.
常用信号：
HUP : kill -s HUP pid
ExecReload=/bin/kill -s HUP $PID
让 Linux 缓和的执行进程关闭，然后重启。在对配置文件修改后需要重启进程时可发送此信号。

TERM : kill -s TERM pid
友好告诉进程退出，进程先保存好数据，再正常退出。给父进程发送一个 TERM 信号，试图杀死它和它的子进程。请求彻底终止某项执行操作.它期望接收进程清除自给的状态并退出
#-------------------------------
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
```

##### redis 服务

```bash
[Unit]
Description=nginx - high performance web server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target
```

