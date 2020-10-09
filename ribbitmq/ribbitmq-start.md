#### 1. Ribbitmq 安装

##### 1.1 Ribbitmq / Erlang 下载

```bash
# rabbitmq download link
https://github.com/rabbitmq/rabbitmq-server/releases
# Erlang download link
https://www.erlang.org/downloads
https://github.com/erlang/otp/releases
https://www.erlang-solutions.com/resources/download.html
```

*注意：*  `Rabbitmq` 版本 `3.8.3,3.8.2,3.8.1,3.8.0` 推荐使用 `Erlang` - *22.x* 最低要求 *21.3*

  `Rabbitmq` 版本 `3.7.x` 推荐使用 `Erlang` - *22.x* 最低要求 *21.3*

##### 1.2 rabbitmq 安装

 centos7 安装

```bash
# 1. 安装 erlang
rpm --import https://packages.erlang-solutions.com/rpm/erlang_solutions.asc

cat <<EOF > /etc/yum.repos.d/erlang.repo
[erlang-solutions]
name=CentOS $releasever - $basearch - Erlang Solutions
baseurl=https://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
enabled=1
EOF

# 可选安装
sudo yum install erlang-hipe

# 安装
yum localinstall esl-erlang_22.3-1~centos~7_amd64.rpm
yum localinstall rabbitmq-server-3.8.3-1.el7.noarch.rpm
```

ubuntu18.04

```bash
# append /etc/apt/sources.list
deb https://packages.erlang-solutions.com/ubuntu bionic contrib

wget https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
sudo apt-key add erlang_solutions.asc

# 安装
sudo gdebi esl-erlang_22.3-1\~ubuntu\~bionic_amd64.deb
sudo gdebi rabbitmq-server_3.8.3-1_all.deb
```

docker images

```bash
docker pull rabbitmq:3.8.3
docker pull rabbitmq:3.7.26
```

##### 1.3 rabbitmq 运行配置

*web 管理界面插件：* `rabbitmq-plugins enable rabbitmq_management`

默认端口 <font color="blue">4369、5672、15672、25672</font>

```bash
# 默认文件位置
node           : rabbit@example
home dir       : /var/lib/rabbitmq
config file(s) : /etc/rabbitmq/advanced.config
               : /etc/rabbitmq/rabbitmq.conf
```

rabbitmq.conf 配置

```
# 这是一个注释
listeners.tcp.default = 5673

# 或者
[{rabbit, [{tcp_listeners, [5673]}]}]
```

常用配置命令

```bash
# 安装 web 插件
rabbitmq-plugins enable rabbitmq_management

# 用户操作
rabbitmqctl add_user username password
rabbitmqctl list_users
rabbitmqctl set_user_tags username tag tag2 ...
# tag（administrator，monitoring，policymaker，management）

rabbitmqctl delete_user <username>
rabbitmqctl change_password <username> <newpassword>
rabbitmqctl clear_password <username>
# 不能使用密码登陆，但是可以通过SASL登陆如果配置了SASL认证

# vhosts 操作
rabbitmqctl add_vhost <vhostpath>
rabbitmqctl delete_vhost <vhostpath>
rabbitmqctl list_vhosts [<vhostinfoitem> ...]

# 权限
rabbitmqctl set_permissions -p "/" username '.*' '.*' '.*'
rabbitmqctl list_user_permissions username

# 针对一个 vhosts
rabbitmqctl set_permissions [-p <vhostpath>] <user> <conf> <write> <read>
rabbitmqctl clear_permissions [-p <vhostpath>] <username>
rabbitmqctl list_permissions [-p <vhostpath>]
rabbitmqctl list_user_permissions <username>
```

#### ISSUE

##### User can only log in via localhost

```bash
# 找到这个文件 rabbit.app
/usr/lib/rabbitmq/lib/rabbitmq_server-3.7.7/ebin/rabbit.app

将：{loopback_users, [<<”guest”>>]}，
改为：{loopback_users, []}，
原因：rabbitmq 从 3.3.0 开始禁止使用 guest/guest 权限通过除 localhost 外的访问

##############
vi /etc/rabbitmq/rabbitmq.config
#保存以下配置（）
[
{rabbit, [{tcp_listeners, [5672]}, {loopback_users, ["guest"]}]}
].
```

