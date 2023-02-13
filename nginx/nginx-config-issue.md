### nginx issue

## 隐藏 nginx 版本号

```
# 在 http 模块当中配置
server_tokens off;
```

## location 路径匹配问题

后台文件路径 /opt/nginx/images/a.jpg

```
location /image {
	root /opt/nginx/images;
	# root /opt/nginx/images/;
}

location /image/ {
	root /opt/nginx/images;
}

访问地址 host:/image/a.jpg 映射路径 /opt/nginx/images/image/a.jpg
```

### location 下 root 和 alias 路径处理

alias 指定的目录是准确的，给 location 指定一个目录。
root 指定目录的上级目录，并且该上级目录要含有 locatoin 指定名称的同名目录。

```
location /alias/ {
	alias /opt/nginx/images/;
}

访问地址 host:/alias/a.jpg 映射路径 /opt/nginx/images/a.jpg (成功)
会去请求地址去掉匹配字段 (/alias/) 后的路径在 alias 目录下找文件
```

<font color="red">注意：</font> alias 配置时路径末尾要加 `/` 目录结尾。
设置 root 注意一个问题，如果该 root 设置不是根目录，该绝对地址要把目录的部分省略掉。

```
location /images/ {
	alias /opt/nginx/images/;
}
location /images/ {
	root /opt/nginx/;
}
以上写法可以达到相同的效果
```

### location 和 proxy_pass 代理

proxy_pass 代理地址是否携带反斜杠区别。

```
location /proxy { proxy_pass http://10.0.41.80:51000; }
请求：host:/proxy/hei/headers 代理后访问 http://10.0.41.80:51000/proxy/hei/headers

location /proxy { proxy_pass http://10.0.41.80:51000/; }
请求：host:/proxy/hei/headers 代理后访问 http://10.0.41.80:51000/hei/headers

location /proxy/ { proxy_pass http://10.0.41.80:51000/hei/; }
请求：host:/proxy/headers 代理后访问 http://10.0.41.80:51000/hei/headers

location /proxy/ { proxy_pass http://10.0.41.80:51000/hei; }
请求：host:/proxy/headers 代理后访问 http://10.0.41.80:51000/heiheaders (错误)
```

proxy_pass  以反斜线 `/` 结尾，代理后地址 <font color="red">proxy_pass + (path - location)</font>
proxy_pass  不以以反斜线 `/` 结尾，代理后地址 <font color="red">proxy_pass + path</font>

location 后带反斜线和不带的区别

- `location /proxy {}`
  可以匹配 /proxyxxx/xxx/xxx/xx，/proxy/xxx/xxx
- `location /proxy/ {}`
  仅能匹配 host:/proxy/xx/xxx 的路径，location 指定的地址。

<font color="red">注意：</font>若是 `location` 配置的是正则路径匹配，那么 `proxy_pass` 代理地址后不能有反斜线 `/`。正则匹配的路径后是否带反斜线 (`/`)  的代理转发方式和不用正则处理方式一样。

```
location ~ /(a|b) { proxy_pass http://10.0.41.80:51000/; }
# 以上是错误的

# 改正为正则 location 中 proxy_pass 代理地址最后不能有 /
location ~ /(a|b) { proxy_pass http://10.0.41.80:51000; }

请求： host:/aaaa/hei/headers 代理后 http://10.0.41.80:51000/aaaa/hei/headers
```

<font color="red">注意：</font>若 location 的 url 与请求 path 完全一致， `proxy_pass URL` 中是否含有 URI，如果不包含，nginx 会使用 [proxy_pass + path] 为代理后地址，如果包含了 URI，则会直接使用 [proxy_pass] 为代理地址。
在使用 proxy_pass 指令时，如果不想改变原地址中的 URI，就不要在 URL 变量中配置 URI。

```
------------------------
location /user/headers4 { proxy_pass http://10.0.41.80:51000/hei; }
请求：host:/user/headers4 代理后地址 http://10.0.41.80:51000/hei
请求：host:/user/headers4xxx/xxx 代理后地址 http://10.0.41.80:51000/heixxx/xxx

------------------------
location /user/headers5 { proxy_pass http://10.0.41.80:51000/hei/; }
请求：host:/user/headers5 代理后地址 http://10.0.41.80:51000/hei
请求：host:/user/headers5xxx/xxx 代理后地址 http://10.0.41.80:51000/hei/xxx/xxx

------------------------
location /user/headers6/ { proxy_pass http://10.0.41.80:51000/hei/; }
请求：host:/user/headers6/ 代理后地址 http://10.0.41.80:51000/hei/
请求：host:/user/headers6/xxx 代理后地址 http://10.0.41.80:51000/hei/xxx

------------------------
location /user/headers7/ { proxy_pass http://10.0.41.80:51000/hei; }
请求：host:/user/headers7/ 代理后地址 http://10.0.41.80:51000/hei
请求：host:/user/headers7/xxx 代理后地址 http://10.0.41.80:51000/heixxx

------------------------
location ~ /(c|d) { proxy_pass http://10.0.41.80:51000; }
请求：host:/c/hei 代理后地址 http://10.0.41.80:51000/c/hei

------------------------
location ~ /(e|f)/ { proxy_pass http://10.0.41.80:51000; }
请求：host:/e/hei 代理后地址 http://10.0.41.80:51000/e/hei
```

若是 location 的 direction 和 proxy_pass 代理的地址 URI 一样，proxy_pass 就不会改变 URI 地址。

## 代理参数配置

示例 [nginx proxy config params](./nginx-proxy-params.conf)

### 代理 header 配置

```
location /proxy {
	# Proxy Settings
    proxy_set_header PROXY-HOST $proxy_host;
    proxy_set_header HTTP-HOST $http_host;
    proxy_set_header HOST $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}

访问主机 IP： 10.0.41.80 (51000)
虚拟机 IP：192.168.10.21 (8080)   网关 192.168.10.1
docker nginx IP: 172.17.0.2 (80)

{
    "proxy-host": "10.0.41.80:51000",
    "x-forwarded-for": "192.168.10.1",
    "x-real-ip": "192.168.10.1",
    "host": "192.168.10.21",
    "http-host": "192.168.10.21:8080"
}
```

```
// 传递域名给后端服务器，不设置此项，默认传递 IP 给后端。
proxy_set_header Host $http_host;

// 最后一层代理的IP地址。多层代理会覆盖，只显示最后一层代理 IP 地址。
proxy_set_header X-Real-IP $remote_addr;

// 传真实客户端地址。
// 代理访问后端服务器，访问日志定义的 X-Forwarded-For 字段会显示客户端的真实 IP。多层代理会追加。
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

### buffer 配置

```
// 开启内容缓冲，nignx 会把后端返回的内容先放到缓冲区当中，然后再返回给客户端。
Syntax:  proxy_buffering on | off;
Default: proxy_buffering on;
Context: http, server, location

// 设置代理服务器保存响应头信息的缓冲区大小。
// 这个参数并不受 proxy_buffering 开启或关闭的影响，它始终都是生效的。
Syntax:  proxy_buffer_size size;
Default: proxy_buffer_size 4k|8k;
Context: http, server, location

// 响应缓冲区的个数和大小，响应内容先写入缓冲区，写满或者写完，立即发送给客户端。
// 这里设置的缓冲区大小是针对每个请求连接而言的。
Syntax:  proxy_buffers number size;
Default: proxy_buffers 8 4k|8k;
Context: http, server, location

--------------------------------
proxy_buffering on;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 96k;
```

## 跨域处理 (CROS)

```
location / {
    # 允许跨域的请求，可以自定义变量$http_origin，*表示所有
    add_header 'Access-Control-Allow-Origin' *;
    # 允许携带cookie请求
    add_header 'Access-Control-Allow-Credentials' 'true';
    # 允许跨域请求的方法：GET,POST,OPTIONS,PUT
    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,PUT';
    # 允许请求时携带的头部信息，*表示所有
    add_header 'Access-Control-Allow-Headers' *;
    # 允许发送按段获取资源的请求
    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
    # 一定要有！！！否则Post请求无法进行跨
    # 在发送Post跨域请求前，会以Options方式发送预检请求，服务器接受时才会正式请求
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        # 对于Options方式的请求返回204，表示接受跨域请求
        return 204;
    }
}
```

## 防盗链

```
# 在动静分离的location中开启防盗链机制  
location ~ .*\.(html|htm|gif|jpg|jpeg|bmp|png|ico|txt|js|css){  
    # 最后面的值在上线前可配置为允许的域名地址  
    valid_referers blocked 192.168.12.129;  
    if ($invalid_referer) {  
        # 可以配置成返回一张禁止盗取的图片  
        # rewrite   ^/ http://xx.xx.com/NO.jpg;  
        # 也可直接返回403  
        return   403;  
    }  
      
    root   /soft/nginx/static_resources;  
    expires 7d;  
}
```

## SSL

```
server {
    # 监听HTTPS默认的443端口
    listen 443;
    # 配置自己项目的域名
    server_name www.xxx.com;
    # 打开SSL加密传输
    ssl on;
    # 输入域名后，首页文件所在的目录
    root html;
    # 配置首页的文件名
    index index.html index.htm index.jsp index.ftl;
    # 配置自己下载的数字证书
    ssl_certificate  certificate/xxx.pem;
    # 配置自己下载的服务器私钥
    ssl_certificate_key certificate/xxx.key;
    # 停止通信时，加密会话的有效期，在该时间段内不需要重新交换密钥
    ssl_session_timeout 5m;
    # TLS 握手时，服务器采用的密码套件
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    # 服务器支持的 TLS 版本
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    # 开启由服务器决定采用的密码套件
    ssl_prefer_server_ciphers on;

    location / {
        ....
    }
}

# --------- HTTP 请求转 HTTPS -------------
server {
    # 监听HTTP默认的80端口
    listen 80;
    # 如果80端口出现访问该域名的请求
    server_name www.xxx.com;
    # 将请求改写为HTTPS（这里写你配置了HTTPS的域名）
    rewrite ^(.*)$ https://www.xxx.com;
}
```

