#### 启动服务

```bash
$ docker run -it -p 80:80 \
-v `pwd`/html:/usr/share/nginx/html \
-v `pwd`/conf.d:/etc/nginx/conf.d \
-v `pwd`/logs:/var/log/nginx \
nginx:1.18.0

# -v `pwd`/conf/nginx.conf:/etc/nginx/nginx.conf
# 按需配置
```

##### 默认 nginx.conf 配置

[nginx default configuration](../nginx/nginx-default.conf)

```
# 放到 conf.d 目录 server80.conf
server {
    listen 80;

    location / {
        root html;
        index index.html;
    }

    location /sentinel {
        proxy_pass http://192.168.1.15:52203/;
    }

    location /eurekaclient {
        proxy_pass http://192.168.1.15:52002/;
    }
}
```

