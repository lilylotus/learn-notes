#### 安装 nginx

##### centos yum 安装

需要 centos 7.4+ x86_64 环境

```bash
# yum install yum-utils

# /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

默认是 stable 版本，要使用 mainline 版本
# yum-config-manager --enable nginx-mainline

安装
# yum install nginx
```

##### 源码安装

下载地址 http://nginx.org/download/ Stable version ([ nginx-1.18.0](http://nginx.org/download/nginx-1.18.0.tar.gz))

```bash
tar zxf nginx-1.16.1.tar.gz
# 安装所需包
yum install -y gcc gcc-c++ make automake pcre pcre-devel zlib zlib-devel openssl openssl-devel

# 添加 nginx 用户，可以不做
useradd -s /sbin/nologin nginx

# 编译
# --with-http_stub_status_module nginx 的访问状态
./configure --prefix=/usr/local/src/nginx \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_gzip_static_module

# 安装
make && make install

# 配置 nginx 为系统服务
vim /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

#### nginx 应用

##### nginx 常用命令

```bash
1. 启动 nginx
# nginx
# nginx -c nginx.conf

2. 停止 nginx
# nginx -s stop (立即停止服务)
# nginx -s quit (完成任务后推出)
# killall nginx (直接杀死 nginx 进程)

3. 不关闭重新加载配置文件
# nginx -s reload

4. 测试配置文件
# nginx -t
$ nginx -t -c nginx.conf
```

##### nginx 配置

[nginx 配置](./nginx.conf)

```
# nginx 配置 /etc/nginx/nginx.conf

user  nginx; # nginx 的使用用户
worker_processes  1;  # 这个和 CUP 核心数量一致或者两倍
error_log  /var/log/nginx/error.log warn; # error
pid        /var/run/nginx.pid;

events {
    worker_connections  1024; // 每个 worker 进程⽀支持的最⼤大连接数, work_process * con
    use epoll; // 内核模型 select,poll,epoll
}

# 非虚拟主机的配置或公共配置定义在 http{} 段内 server{} 段外
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    server {
        listen 40080;
        server_name t1.drill.cn;

        root /data/nginx/t1;
        index index.html;
    }

	# curl t2.drill.cn:40081
    server {
        listen 40081;
        server_name t2.drill.cn;

        root /data/nginx/t2;
        index index.html;
    }

    keepalive_timeout  65;
    gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

##### **nginx 日志配置规范**

```bash
# 配置在 http 下

//Nginx默认配置
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
'$status $body_bytes_sent "$http_referer" '
'"$http_user_agent" "$http_x_forwarded_for"';

//Nginx⽇日志变量量
$remote_addr //表示客户端地址
$remote_user //http客户端请求nginx认证⽤用户名
$time_local //Nginx的时间
$request //Request请求⾏行行, GET等⽅方法、http协议版本
$status //respoence返回状态码
$body_bytes_sent //从服务端响应给客户端body信息⼤大⼩小
$http_referer //http上⼀一级⻚页⾯面, 防盗链、⽤用户⾏行行为分析
$http_user_agent //http头部信息, 客户端访问设备
$http_x_forwarded_for //http请求携带的http信息
```

##### **配置 nginx 状态监控**

```bash
--with-http_stub_status_module 记录 Nginx 客户端基本访问状态信息

# 配置格式，可放在 server 和 localtion 中
location /status {
    stub_status on;
    access_log off;
}
//Nginx_status概述
Active connections: 2 
server accepts handled requests
 28 28 22 
Reading: 0 Writing: 1 Waiting: 1 

server 表示 Nginx 处理接收握⼿总次数。
accepts 表示 Nginx 处理接收总连接数。
请求丢失数=(握手数-连接数)可以看出,本次状态显示没有丢失请求。
handled requests，表示总共处理理了了 22 次请求。
Reading Nginx读取数据
Writing Nginx写的情况
Waiting Nginx 开启 keep-alive ⻓接情况下, 既没有读也没有写, 建⽴连接情况
```

##### **nginx 文件下载**

```bash
# nginx 是默认不允许列出整个目录

autoindex on | off;
# 配置： http, server, location

# autoindex 常⽤用参数
autoindex_exact_size off;
# 默认为on， 显示出文件的确切大小，单位是 bytes。
# 修改为off，显示出⽂件的大概⼤小，单位是 kB 或者 MB 或者 GB。

autoindex_localtime on;
# 默认为 off，显示的文件时间为 GMT 时间。
# 修改为 on， 显示的⽂件时间为⽂件的服务器时间。

 # 默认中⽂⽬录乱码，添加上解决乱码。
charset utf-8,gbk;

location /down {
	# /data/nginx/down 目录
	root /data/nginx;
	autoindex on;
	autoindex_localtime on;
	autoindex_exact_size off;
	charset utf-8,gbk;
}
```

##### **nginx 访问限制**

连接频率限制 `limit_conn_module`
请求频率限制 `limit_req_module`

> http 协议的连接与请求
> HTTP 是建立在 TCP 协议上, HTTP 请求需要先建立 TCP 三次握手（称为TCP连接）上，在连接的基础上发起 HTTP 请求。

HTTP 协议的连接与请求

| http 协议版本 | 链接关系        |
| ------------- | --------------- |
| HTTP1.0       | TCP 不能复用    |
| HTTP1.1       | 顺序性 TCP 复用 |
| HTTP2.0       | 多路复用 TCP    |

HTTP 请求建立在一次 TCP 连接基础上，一次 TCP 请求至少产生一次 HTTP 请求

##### **nginx 链接限制**

```bash
语法：在 http 块下
limit_conn_zone key zone=name:size;

limit_conn zone number;
# 在 http,server,location 块下

示例：
http {
	# http 段配置连接限制, 共享内存区大小 10M
	limit_conn_zone $binary_remote_addr zone=conn_zone:10m;
	
	server {
		location / {
			limit_conn conn_zone 1; # 同⼀时刻只允许一个客户端 IP 连接
			limit_conn_log_level error;  #设置超出最大连接数的日志级别
		}
	}
}

压力测试：
yum install -y httpd-tools
# ab -n 50 -c 20 http://t2.drill.cn/index.html
```

##### **nginx 请求限制**

```bash
# http 段配置请求限制, rate 限制速率，限制一秒钟最多一个 IP 请求
limit_req_zone key zone=name:size rate=rate; # http 块
limit_req_zone $binary_remote_addr zone=req_zone:10m rate=1r/s;

limit_req zone=name [burst=number] [nodelay | delay=number];# http, server, location 块

location /search/ {
    # 1r/s 只接收一个请求,其余请求拒绝处理并返回错误码给客户端
	limit_req zone=one burst=5;
}
```

> 多个请求可以建立在一次 TCP 连接之上,
> 比对一个连接的限制会更加的有效。因为同一时刻只允许一个连接请求进入。
> 但是同一时刻多个请求可以通过一个连接进入。所以请求限制才是比较优的解决方案。

##### **访问控制**

基于 IP 的访问控制 `http_access_module`
基于⽤用户登陆认证 `http_auth_basic_module`

*IP 访问控制*

```bash
location / {
    deny 192.168.1.1;
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    deny all;
    # 从上到下的顺序，类似 iptables。匹配到了便跳出。
    # 如上的例子先禁止了 192.16.1.1，接下来允许了 3 个网段，其中包含了一个ipv6，
    # 最后未匹配的 IP 全部禁止访问.被 deny 的将返回 403 状态码。
}

缺点：会有 IP 代理跳过此过滤
解决方式：
1.采用 HTTP 头信息控制访问, 代理理以及 web 服务开启 http_x_forwarded_for
2.结合 geo 模块作
3.通过 HTTP 自动以变量传递
```

*用户登录认证*

```bash
auth_basic off; # off | on -> http, server, location, limit_except
auth_basic_user_file file; # 配置密码文件位置

# 生成密码
htpasswd -c /etc/nginx/auth_conf test
htpasswd /data/auth user

用户认证局限性
1.用户信息依赖文件方式
2.用户管理文件过多, 无法联动
3.操作管理机械，效率低下
解决办法
1. Nginx 结合 LUA 实现高效验证
2. Nginx 结合 LDAP 利用 nginx-auth-ldap 模块
```

##### **虚拟主机**

```bash
# 仅修改 listen 监听端⼝口即可, 但不不能和系统端⼝口发⽣生冲突
server {
	listen 40082;
	server_name t2.drill.cn;
	root /data/nginx/t2;
}
server {
	listen 40083;
	server_name t2.drill.cn;
	root /data/nginx/t1;
	index index.html;
	location /dir {
		alias /data/nginx/t1;
	}
}

注意：
1. 使用 alias 时，目录名后面一定要加"/"。
3. alias 在使用正则匹配时，必须捕捉要匹配的内容并在指定的内容处使用。
4. alias 只能位于 location 块中。（root 可以不放在 location 中）
```

```bash
server {
    listen 80 default_server;
    server_name www.example.com;
    location / {
        root /usr/share/nginx/html;
        # alias /usr/share/nginx/html;
        index index.html index.htm;
    }
}
```

##### 三. 静态资源配置

1. 文件高效读取 `sendfile on | off, http, server, location`

2. 提高网络传输效率 `tcp_nopush on | off, http, server, location`
   开启情况下提高网络包的 "传输效率"

3. `tcp_nopush` 对应的 `tcp_nodelay` 对应配置

   `tcp_nodelay on | off`  *在 keepalive 连接下，提高网络传输的 **实时性***

###### 静态资源压缩

1. `gzip` 压缩配置，传输时压缩，注意性能
   `gzip on | off, http, server, location`

2. `gzip` 压缩比率配置
   `gzip_comp_level level`  默认等级 1， *http, server, location*
   **注意：** 压缩本身比较耗费服务器性能

3. `gzip` 压缩协议版本

   `gzip_http_version 1.0 | 1.1` *http, server, location*, 主流 http 协议版本 1.1

4. 扩展压缩模块 (不常用)
   `gzip_static on | off | always` 预读 gzip 功能，先压缩好在处理 *http, server, location*

```bash
sendfile on;

location ~ .*\.(jpg|gif|png)$ {
	gzip on;
	gzip_http_version 1.1;
	gzip_comp_level 2;
	gzip_types text/plain application/json application/x-javascript app
lication/css application/xml application/xml+rss text/javascript application/x-http
d-php image/jpeg image/gif image/png;
	root /data/nginx/images;
}
```

###### 静态资源浏览器缓存

1. 无缓存

   > 浏览器器请求->⽆无缓存->请求WEB服务器器->请求响应->呈现

2. 有缓存

   > 浏览器器请求->有缓存->校验过期->是否有更更新->呈现
   > 校验是否过期 Expires HTTP1.0, Cache-Control(max-age) HTTP1.1
   > 协议中Etag头信息校验 Etag ()
   > Last-Modified头信息校验 Last-Modified (具体时间)

3. **配置缓存** `expires`

   ```bash
   expires [modified] time; # http,server, location
   
   作⽤用: 添加 Cache-Control Expires 头
   
   location ~ .*\.(js|css|html)$ {
   	root /data/resources;
   	expires 1h; # 7d
   }
   
   # 取消缓存
   location ~ .*\.(css|js|swf|json|mp4|htm|html)$ {
       add_header Cache-Control no-store;
       add_header Pragma no-cache;
   }
   ```

##### 四. 跨域访问

```bash
Syntax: add_header name value [always];
Default: —
Context: http, server, location, if in location

Access-Control-Allow-Origin

------

add_header 'Access-Control-Allow-Origin' $http_origin;
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Methods' 'GET,POST,PUT,DELETE,OPTIONS';
add_header 'Access-Control-Allow-Headers' 'DNT,web-token,app-token,Authorization,Accept,Origin,Keep-Alive,User-Agent,X-Mx-ReqToken,X-Data-Type,X-Auth-Token,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';

if ($request_method = 'OPTIONS') {
	add_header 'Access-Control-Max-Age' 1728000;
	add_header 'Content-Type' 'text/plain; charset=utf-8';
	add_header 'Content-Length' 0;
	
	add_header Access-Control-Allow-Origin $http_origin;
    add_header Access-Control-Allow-Methods $http_access_control_request_method;
    add_header Access-Control-Allow-Credentials true;
    add_header Access-Control-Allow-Headers $http_access_control_request_headers;
    add_header Access-Control-Max-Age 1728000;

	return 204;
}

# 变量：$http_origin	http://t2.drill.cn:40081
```

##### 静态资源防盗链

> 盗链指的是在自己的界面展示不在自己服务器上的内容，通过技术手段获得他⼈服务器的资源地址，
> 绕过别⼈资源展示页面，在自己页面向用户提供此内容，从而减轻自己服务器的负担，
> 因为真实的空间和流量来自别人服务器
> 防盗链设置思路: 区别哪些请求是非正常用户请求

`http_refer` 防盗链配置模块

```bash
Syntax: valid_referers none | blocked | server_names | string ...;
Default: —
Context: server, location

location ~ .*\.(jpg|gif|png)$ {
    valid_referers none blocked 10.10.37.118;
    # valid_referers ~/google\./; 匹配域名
    if ($invalid_referer) {
        return 403;
    }
    root  /data/nginx/images;
}
```

##### 五. nginx 代理

> ngx_http_proxy_module： 将客户端的请求以 http 协议转发至指定服务器进行处理
> ngx_stream_proxy_module：将客户端的请求以 tcp 协议转发至指定服务器处理
> ngx_http_fastcgi_module：将客户端对 php 的请求以 fastcgi 协议转发至指定服务器助理
> ngx_http_uwsgi_module：将客户端对 Python 的请求以 uwsgi 协议转发至指定服务器处理

###### 正向代理和反向代理的区别

> 区别在于代理的对象不一样
> 正向代理代理的对象是客户端
> 反向代理代理的对象是服务端

1. nginx 代理配置

   ```bash
   Syntax: proxy_pass URL;
   Default: —
   Context: location, if in location, limit_except
   
   # http://localhost:8000/uri/
   # http://192.168.56.11:8000/uri/
   # http://unix:/tmp/backend.socket:/uri/
   ```

2. 缓冲区

   ```bash
   # 尽可能收集所有头请求,
   Syntax: proxy_buffering on | off;
   Default:
   proxy_buffering on;
   Context: http, server, location
   # 扩展:
   proxy_buffer_size
   proxy_buffers
   proxy_busy_buffer_size
   ```

3. 跳转重定向

   ```bash
   Syntax: proxy_redirect default;
   proxy_redirect off;proxy_redirect redirect replacement;
   Default: proxy_redirect default;
   Context: http, server, location
   ```

4. 头信息

   ```bash
   Syntax: proxy_set_header field value;
   Default: proxy_set_header Host $proxy_host;
   proxy_set_header Connection close;
   Context: http, server, location
   # 扩展:
   proxy_hide_header
   proxy_set_body
   ```

5. 代理理到后端的 `TCP` 连接超时

   ```bash
   Syntax: proxy_connect_timeout time;
   Default: proxy_connect_timeout 60s;
   Context: http, server, location
   # 扩展
   proxy_read_timeout # 以及建立
   proxy_send_timeout # 服务端请求完, 发送给客户端时间
   ```

6. 常见配置

   ```bash
   # /etc/nginx/proxy_params
   
   proxy_redirect default;
   proxy_set_header Host $http_host;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_connect_timeout 30;
   proxy_send_timeout 60;
   proxy_read_timeout 60;
   proxy_buffer_size 32k;
   proxy_buffering on;
   proxy_buffers 4 128k;
   proxy_busy_buffers_size 256k;
   proxy_max_temp_file_size 256k;
   
   location / {
   	proxy_pass http://127.0.0.1:8080;
   	include proxy_params;
   }
   ```


###### 常用参数

```bash
proxy_pass;
# 用来设置将客户端请求转发给的后端服务器的主机，可以是主机名、IP 地址：端口的方式，也可以代理到预先设置的主机群组，需要模块 gx_http_upstream_module 支持
location /web {
index index.html;
proxy_pass http://192.168.7.103:80; 
# 不带斜线将访问的 /web,等于访问后端服务器 http://192.168.7.103:80/web/index.html
# 后端服务器配置的站点根目录要有 web 目录才可以被访问，这是一个追加 /web 到后端服务器

proxy_hide_header; 
# 用于 nginx 作为反向代理的时候，在返回给客户端 http 响应的时候，隐藏后端服务版本相应头部的信息
# 可以设置 在 http/server 或 location 块
location /web {
    index index.html;
    proxy_pass http://192.168.7.103:80/;
    proxy_hide_header ETag;
}

proxy_pass_request_body on | off;
# 是否向后端服务器发送 HTTP 包体部分,可以设置在 http/server 或 location 块，默认即为开启

proxy_pass_request_headers on | off;
# 是否将客户端的请求头部转发给后端服务器，可以设置在 http/server 或 location 块，默认即为开启

proxy_set_header;
# 可以更改或添加客户端的请求头部信息内容并转发至后端服务器，
# 比如在后端服务器想要获取客户端的真实 IP 的时候，就要更改每一个报文的头部，如下：
# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# proxy_set_header HOST  $remote_addr;
# 添加 HOST 到报文头部，如果客户端为 NAT 上网那么其值为客户端的共用的公网 IP 地址。

proxy_hide_header field;
# 用于隐藏后端服务器特定的响应首部，默认 nginx 在响应报文中不传递后端服务器的首部字段 Date, Server, XPad,  X-Accel 等

proxy_connect_timeout time;
# 配置 nginx 服务器与后端服务器尝试建立连接的超时时间，默认为 60 秒，用法如下： 
proxy_connect_timeout 60s;
# 60s 为自定义 nginx 与后端服务器建立连接的超时时间

proxy_read_time time;
# 配置 nginx 服务器向后端服务器或服务器组发起 read 请求后，等待的超时时间，默认 60s 
proxy_send_time time;
# 配置 nginx 项后端服务器或服务器组发起 write 请求后，等待的超时时间，默认 60s

proxy_http_version 1.0;
# 用于设置 nginx 提供代理服务的 HTTP 协议的版本，默认 http 1.0

proxy_ignore_client_abort off;
# 当客户端网络中断请求时，nginx 服务器中断其对后端服务器的请求。即如果此项设置为 on 开启，则服务器会忽略客户端中断并一直等着代理服务执行返回，如果设置为 off ，则客户端中断后 Nginx 也会中断客户端请求并立即记录 499 日志，默认为 off。

proxy_headers_hash_bucket_size 64;
# 当配置了 proxy_hide_header 和 proxy_set_header 的时候，用于设置 nginx 保存 HTTP 报文头的 hash 表的上限。 
proxy_headers_hash_max_size 512;
# 设置 proxy_headers_hash_bucket_size 的大可用空间 
server_namse_hash_bucket_size 512;
# server_name hash 表申请空间大小
server_names_hash_max_szie   512;
# 设置服务器名称hash表的上限大小
```

###### 配置正向代理

```bash
server {
	resolver 8.8.8.8;
	resolver_timeout 30s;
	listen 40089;
	
	location / {
		proxy_pass http://$http_host$request_uri;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_http_version 1.1;
        proxy_buffers 256 4k;
        proxy_max_temp_file_size 0;
        proxy_connect_timeout 30;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 301 1h;
        proxy_cache_valid any 1m;
	}
}

1、不能有hostname。 
2、必须有 resolver, 即 dns，即上面的8.8.8.8，超时时间（30秒）可选。 
3、配置正向代理参数，均是由 Nginx 变量组成。
proxy_pass $scheme://$host$request_uri;  
proxy_set_header Host $http_host;  
4、配置缓存大小，关闭磁盘缓存读写减少 I/O，以及代理连接超时时间。
proxy_buffers 256 4k;  
proxy_max_temp_file_size 0;  
proxy_connect_timeout 30;  
5、配置代理服务器 Http 状态缓存时间。
proxy_cache_valid 200 302 10m;  
proxy_cache_valid 301 1h;  
proxy_cache_valid any 1m; 
配置好后，重启 nginx，以浏览器为例，要使用这个代理服务器，
则只需将浏览器代理设置为 http://服务器ip地址:40088（40088 是刚刚设置的端口号）即可使用了。
```

###### 反向代理

```bash
# 负载均衡,设置地址池，后端3台服务器
upstream http_server_pool {
    server 10.10.37.114.8081 weight=2 max_fails=2 fail_timeout=30s;
    server 10.10.37.114.8082 weight=3 max_fails=2 fail_timeout=30s;
    server 10.10.37.114.8083 weight=4 max_fails=2 fail_timeout=30s backup;
}

# 一个虚拟主机，用来反向代理 http_server_pool 这组服务器
server {
	listen       8080;
    # 外网访问的域名        
    server_name  t2.drill.cn; 
    location / {
    	# 后端服务器返回 500 503 404 错误，自动请求转发到 upstream 池中另一台服务器
        proxy_next_upstream error timeout invalid_header http_500 http_503 http_404;
        proxy_pass http://http_server_pool;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_redirect default;
        proxy_connect_timeout 30;
        proxy_send_timeout 60;
        proxy_read_timeout 60;
        proxy_buffer_size 32k;
        proxy_buffering on;
        proxy_buffers 4 128k;
        proxy_busy_buffers_size 256k;
        proxy_max_temp_file_size 256k;
    }
	access_log  /var/log/nginx/proxy.log  combined;
}

# 最简单方法
server {
    listen 8081;
    server_name t2.drill.cn;
    location / {
        proxy_pass http://121.199.**.*:80;
    }
}
```

*nginx 负载均衡的状态*

| 状态         | 概述                                |
| ------------ | ----------------------------------- |
| fail_timeout | 经过 max_fails 失败后, 服务暂停时间 |
| down         | 当前的 server 暂时不参与负载均衡    |
| backup       | 预留的备份服务器                    |
| max_fails    | 允许请求失败的次数                  |
| max_conns    | 限制最大的接收接数                  |

*nginx 负载均衡的策略*

| 调度算法     | 概述                                                         |
| ------------ | ------------------------------------------------------------ |
| 轮询         | 按时间顺序逐一分配到不同的后端服务器(默认)                   |
| weight       | 加权轮询,weight 值越大,分配到的访问几率越高                  |
| url_hash     | 按照访问 URL 的 hash 结果来分配请求,是每个 URL 定向到同一个后端服务器 |
| ip_hash      | 每个请求按访问 IP 的 hash 结果分配,这样来自同一 IP 的固定访问一个后端服务器 |
| least_conn   | 最少链接数,那个机器链接数少就分发                            |
| hash关键数值 | hash 自定义的 key                                            |

###### Nginx 负载均衡 TCP 配置

```bash
http {
    upstream ssh_proxy {
        hash $remote_addr consistent;
        server 192.168.56.103:22;
    }
    upstream mysql_proxy {
        hash $remote_addr consistent;
        server 192.168.56.103:3306;
    }
    server {
        listen 6666;
        proxy_connect_timeout 1s;
        proxy_timeout 300s;
        proxy_pass ssh_proxy;
    }
    server {
        listen 5555;
        proxy_connect_timeout 1s;
        proxy_timeout 300s;
        proxy_pass mysql_proxy;
    }
}
```

###### 依据不同的浏览器分配

```bash
http {
	upstream firefox {
		server 172.31.57.133:80;
	}
	upstream chrome {
		server 172.31.57.133:8080;
	}
	upstream iphone {
		server 172.31.57.134:8080;
	}
	upstream android {
		server 172.31.57.134:8081;
	}
	upstream default {
		server 172.31.57.134:80;
	}
	
	server {
        listen 80;
        server_name t2.drill.cn;
        location / {
        	#safari浏览器器访问的效果
            if ($http_user_agent ~* "Safari"){
                proxy_pass http://dynamic_pools;
            }
            #firefox浏览器器访问效果
            if ($http_user_agent ~* "Firefox"){
                proxy_pass http://static_pools;
            }
            #chrome浏览器器访问效果
            if ($http_user_agent ~* "Chrome"){
                proxy_pass http://chrome;
            }
            #iphone⼿手机访问效果
            if ($http_user_agent ~* "iphone"){
                proxy_pass http://iphone;
            }
            #android⼿手机访问效果
            if ($http_user_agent ~* "android"){
                proxy_pass http://and;
            }
            #其他浏览器器访问默认规则
            proxy_pass http://dynamic_pools;
            include proxy.conf;
        }
	}
}

# 依据请求 url 来判断
if ($request_uri ~* "^/static/(.*)$")
{
	proxy_pass http://static_pools/$1;
}
```

