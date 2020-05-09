### Nginx 基础

#### 1. 环境搭建

```bash
yum -y install gcc gcc-c++ autoconf pcre pcre-devel make automake
yum -y install wget httpd-tools vim
```

#### ２. Nginx 介绍

Nginx是一个开源且高性能、可靠的HTTP中间件、代理服务

##### 2.1 特性

###### 2.1.1 IO 多路复用 (epoll)

有A、B、C三个老师，他们都遇到一个难题，要帮助一个班级的学生解决课堂作业。
谁完成了作业举手，有举手的同学他才去指导问题，他让学生主动发声，分开了“并发”。

###### 2.1.2 轻量级

功能模块少 - Nginx仅保留了HTTP需要的模块，其他都用插件的方式，后天添加

###### 2.1.3 CPU亲和

把 CPU 核心和 Nginx 工作进程绑定，把每个 worker 进程固定在一个 CPU 上执行，减少切换 CPU 的 cache miss，从而提高性能。

#### 3. Nginx 配置

##### 3.1 基本配置

```
#打开主配置文件，若你是用lnmp环境安装
vim /usr/local/nginx/conf/nginx.conf

----------------------------------------

user                    #设置nginx服务的系统使用用户
worker_processes        #工作进程数 一般情况与CPU核数保持一致
error_log               #nginx的错误日志
pid                     #nginx启动时的pid

events {
    worker_connections    #每个进程允许最大连接数
    use                   #nginx使用的内核模型
}
```

使用 nginx 的 http 服务，在配置文件 nginx.conf 中的 http 区域内，配置无数个 server ，每一个 server 对应这一个虚拟主机或者域名

```
http {
    
    server {
        listen 80                          #监听端口;
        server_name localhost              #地址
        
        location / {                       #访问首页路径
            root /xxx/xxx/index.html       #默认目录
            index index.html index.htm     #默认文件 
        }        
        
        error_page  500 504   /50x.html    #当出现以上状态码时从新定义到50x.html        
        location = /50x.html {             #当访问50x.html时
            root /xxx/xxx/html             #50x.html 页面所在位置
        }        
    }
    
    server {
        ... ... 
    } 
}
```

一个 server 可以出现多个 location ，对不同的访问路径进行不同情况的配置

```
http {
    sendfile  on                  #高效传输文件的模式 一定要开启
    keepalive_timeout   65        #客户端服务端请求超时时间
    log_format  main   XXX        #定义日志格式 代号为main
    access_log  /usr/local/access.log  main     #日志保存地址 格式代码 main
}
```

#### 4. 静态资源  WEB 服务

##### 4.1 静态资源

非服务器动态运行生成的文件，换句话说，就是可以直接在服务器上找到对应文件的请求

1. 浏览器端渲染：HTML,CSS,JS
2. 图片：JPEG,GIF,PNG
3. 视频：FLV,MPEG
4. 文件：TXT，任意下载文件

##### 4.2 静态资源服务场景 - CDN

什么是 CDN？例如一个北京用户要请求一个文件，而文件放在的新疆的资源存储中心，如果直接请求新疆距离太远，延迟久。使用 nginx 静态资源回源，分发给北京的资源存储中心，让用户请求的动态定位到北京的资源存储中心请求，实现传输延迟的最小化

##### 4.3 配置静态资源

```
# 配置域：http、server、location
#文件高速读取
http {
     sendfile   on;
}

#在 sendfile 开启的情况下，开启 tcp_nopush 提高网络包传输效率
#tcp_nopush 将文件一次性一起传输给客户端，就好像你有十个包裹，快递员一次送一个，来回十趟，开启后，快递员讲等待你十个包裹都派件，一趟一起送给你
http {
     sendfile   on;
     tcp_nopush on;
}

#tcp_nodelay 开启实时传输，传输方式与 tcp_nopush 相反，追求实时性，但是它只有在长连接下才生效
http {
     sendfile   on;
     tcp_nopush on;
     tcp_nodelay on;
}

#将访问的文件压缩传输 （减少文件资源大小，提高传输速度）
#当访问内容以 gif 或 jpg 结尾的资源时
location ~ .*\.(gif|jpg)$ {
    gzip on; #开启
    gzip_http_version 1.1; #服务器传输版本
    gzip_comp_level 2; #压缩比，越高压缩越多，压缩越高可能会消耗服务器性能
    gzip_types   text/plain application/javascript application/x-javascript text/javascript text/css application/xml application/xml+rss image/jpeg image/gif image/png;     #压缩文件类型
    root /opt/app/code;     #对应目录（去该目录下寻找对应文件）
}

#直接访问已压缩文件
#当访问路径以 download 开头时，如 www.baidu.com/download/test.img
#去 /opt/app/code 目录下寻找 test.img.gz 文件，返回到前端时已是可以浏览的 img 文件
location ~ load^/download {
    gzip_static on #开启;
    tcp_nopush on;
    root /opt/app/code;
}
```

#### 5. 浏览器缓存

HTTP协议定义的缓存机制（如：Expires; Cache-control等 ）减少服务端的消耗，降低延迟

##### 5.1 浏览器无缓存

浏览器请求 -> 无缓存 -> 请求WEB服务器 -> 请求相应 -> 呈现
在**呈现**阶段会根据缓存的设置在浏览器中生成缓存

##### 5.2 浏览器有缓存

浏览器请求 -> 有缓存 -> 校验本地缓存时间是否过期 -> 没有过期 -> 呈现
若过期从新请求 WEB 服务器

##### 5.3 nginx 配置

```
location ~ .*\.(html|htm)$ {
    expires 12h;    #缓存12小时
}
```

服务器响应静态文件时，请求头信息会带上 etag 和 last_modified_since 2个标签值，浏览器下次去请求时，头信息发送这两个标签，服务器检测文件有没有发生变化，如无,直接头信息返 etag 和last_modified_since，状态码为 **304** ，浏览器知道内容无改变,于是直接调用本地缓存，这个过程也请求了服务，但是传着的内容极少。

#### 6. 跨域访问

```
location ~ .*\.(html|htm)$ {
     add_header Access-Control-Allow-Origin *;
     add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
     #Access-Control-Allow-Credentials true #允许cookie跨域
}
```

在响应中指定 Access-Control-Allow-Credentials 为 true 时，Access-Control-Allow-Origin 不能指定为 *，需要指定到具体域名

相关跨域内容可参考 Laravel 跨域功能中间件 使用代码实现跨域，原理与nginx跨域配置相同

#### 7. 防盗链

防止服务器内的静态资源被其他网站所套用
此处介绍的 nginx 防盗链为基础方式

```
$http_referer 
#表示当前请求上一次页面访问的地址，换句话说，访问 www.baidu.com 主页，这是第一次访问，所以 $http_referer 为空，但是访问此页面的时候还需要获取一张首页图片，再请求这张图片的时候 $http_referer 就为 www.baidu.com

```

```
location ~ .*\.(jpg|gif)$ {
    #valid_referers 表示我们允许哪些 $http_referer 来访问
    #none 表示没有带 $http_referer，如第一次访问时 $http_referer 为空
    #blocked 表示 $http_referer 不是标准的地址，非正常域名等
    #只允许此ip
    valid_referers none blocked 127.xxx.xxx.xx
    if ($invalid_referer) {     #不满足情况下变量值为1
        return 403;
    }
}
```

#### 8. HTTP 代理

##### 8.1 代理的区别

正向代理代理的对象是客户端
反向代理代理的对象是服务端

##### 8.2 反向代理配置

```
语法：proxy_pass URL
默认：——
位置：loaction

#代理端口
#场景：服务器 80 端口开放，8080 端口对外关闭，客户端需要访问到 8080
#在 nginx 中配置 proxy_pass 代理转发时，如果在 proxy_pass 后面的 url 加 /，表示绝对根路径；
# 如果没有 /，表示相对路径，把匹配的路径部分也给代理走
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:8080/;
        proxy_redirect default;

        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr; #获取客户端真实IP

        proxy_connect_timeout 30; #超时时间
        proxy_send_timeout 60;
        proxy_read_timeout 60;

        proxy_buffer_size 32k;
        proxy_buffering on; #开启缓冲区,减少磁盘io
        proxy_buffers 4 128k;
        proxy_busy_buffers_size 256k;
        proxy_max_temp_file_size 256k; #当超过内存允许储蓄大小，存到文件
    }
}
```

#### 9. 负载均衡

负载均衡的实现方法就是反向代理。将客户的请求通过 nginx 分发（反向代理）到一组多台不同的服务器上

```
#配置
语法：upstream name ...
默认：——
位置：http

upstream #自定义组名 {
    server x1.baidu.com;    #可以是域名
    server x2.baidu.com;
    #server x3.baidu.com
                            #down         不参与负载均衡
                            #weight=5;    权重，越高分配越多
                            #backup;      预留的备份服务器
                            #max_fails    允许失败的次数
                            #fail_timeout 超过失败次数后，服务暂停时间
                            #max_coons    限制最大的接受的连接数
                            #根据服务器性能不同，配置适合的参数

    #server 106.xx.xx.xxx;        可以是ip
    #server 106.xx.xx.xxx:8080;   可以带端口号
    #server unix:/tmp/xxx;        支出socket方式
}
```

proxy.conf 配置文件
前端负载均衡服务器A（127.0.0.1），后台服务器B（127.0.0.2），后台服务器C（127.0.0.3）

```
proxy_redirect default;
proxy_set_header Host $http_host;
proxy_set_header X-Real-IP $remote_addr;
proxy_connect_timeout 30;
proxy_send_timeout 60;
proxy_read_timeout 60;
proxy_buffer_size 32k;
proxy_buffering on;
proxy_buffers 4 128k;
proxy_busy_buffers_size 256k;
proxy_max_temp_file_size 256k;

#服务器A的配置
http {
    ...
    upstream xxx {
        server 127.0.0.2;
        server 127.0.0.3;
    }
    server {
        liseten 80;
        server_name localhost;
        location / {
            proxy_pass http://xxx     #upstream 对应自定义名称
            include proxy.conf;
        }
    }
}

#服务器B、服务器C的配置
server {
    liseten 80;
    server_name localhost;
    location / {
         index  index.html
    }
}
```

##### 9.1 负载算法

- 轮训：按时间顺序逐一分配到不同的后端服务器
- 加权轮训：weight值越大，分配到的几率越高
- ip_hash：每个请求按访问IP的hash结果分配，这样来自同一个IP固定访问一个后端服务器
- least_conn：最少链接数，哪个机器连接数少就分发给谁
- url_hash：按照访问的URL的hash结果来分配请求，每一个URL定向到同一个后端服务器
- hash关键数值：hash自定义key

```
upstream xxx {
        ip_hash;
        server 127.0.0.2;
        server 127.0.0.3;
  }
```

ip_hash 存在缺陷，当前端服务器再多一层时，将获取不到用户的正确 IP，获取的将是前一个前端服务器的 IP，因此 nginx1.7.2 版本推出了 url_hash

`url_hash` 配置

```
 upstream xxx {
        hash $request_uri;
        server 127.0.0.2;
        server 127.0.0.3;
  }
```

#### 10. nginx 代理缓存

客户端请求 nginx，nginx 查看本地是否有缓存数据，若有直接返回给客户端，若没有再去后端服务器请求

```
http {
    proxy_cache_path    /var/www/cache #缓存地址
                        levels=1:2 #目录分级
                        keys_zone=test_cache:10m #开启的keys空间名字:空间大小(1m可以存放8000个key)
                        max_size=10g #目录最大大小(超过时，不常用的将被删除)
                        inactive=60m #60分钟内没有被访问的缓存将清理
                        use_temp_path=pff; #是否开启存放临时文件目录，关闭默认存储在缓存地址

    server {
        ...
        location / {
            proxy_cache test_cache;    #开启缓存对应的名称，在keys_zone命名好
            proxy_cache_valid 200 304 12h;    #状态码为200 304的缓存12小时
            proxy_cache_valid any 10m;    #其他状态缓存10小时
            proxy_cache_key $host$uri$is_args$args;    #设置key值
            add_header Nginx-Cache "$upstream_cache_status";
        }
    }
}
```

当有个特定请求我们不需要缓存的时候，在上面配置的内容中加入以下配置

```
server {
    ...
    if ($request_uri ~ ^/(login|register) ) {    #当请求地址有login或register时
        set $nocache = 1;    #设置一个自定义变量为true
    }
    location / {
        proxy_no_cache $nocache $arg_nocache $arg_comment;
        proxy_no_cache $http_pragma $http_authoriztion;
    }
}
```

#### 11. 常见问题

##### 11.1 相同 server_name 多个虚拟主机优先级

```
#当出现虚拟主机域名相同的情况，重启nginx时，会出现警告⚠️处理，但是并不不会阻止nginx继续使用

server {
    listen 80;
    server_name www.baidu.com
    ...
}
server {
    listen 80;
    server_name www.baidu.com
    ...
}
# 优先选择最新读取到的配置文件，当多个文件是通过include时，文件排序越靠前，越早被读取
```

##### 11.2 location 匹配优先级

```
=        #进行普通字符精确匹配，完全匹配
^~       #进行普通字符匹配，当前表示前缀匹配
~\~*     #表示执行一个正则匹配()

#当程序使用精确匹配时，一但匹配成功，将停止其他匹配
#当正则匹配成功时，会继续接下来的匹配，寻找是否还有更精准的匹配
```

##### 11.2 try_files 使用

按顺序检查文件是否存在

```
location / {
    try_files $uri $uri/ /index.php;
}

#先查找 $uri 下是否有文件存在，若存在直接返回给用户
#若$url下没有文件存在，再次访问 $uri/ 的路径是否有文件存在
#还是没有文件存在，交给 index.php 处理

location / {
    root /test/index.html
    try_files $uri @test
}

location @test {
    proxy_pass http://127.0.0.1：9090;
}

#访问 / 时，查看 /test/index.html 文件是否存在
#若不存在，让9090端口的程序去处理这个请求
```

##### 11.2 alias 和 root 区别

```
location /request_path/image/ {
    root /local_path/image/;
}

#当我们访问 http://xxx.com/request_path/image/cat.png时
#将访问 http://xxx.com/request_path/image/local_path/image/cat.png 下的文件

location /request_path/image/ {
    alias /local_path/image/;
}

#当我们访问 http://xxx.com/request_path/image/cat.png时
#将访问 http://xxx.com/local_path/image/cat.png 下的文件
```

