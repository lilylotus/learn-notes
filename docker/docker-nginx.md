#### 1. 启动服务

```bash
$ docker run -it -p 80:80 \
-v `pwd`/html:/usr/share/nginx/html \
-v `pwd`/conf/nginx.conf:/etc/nginx/nginx.conf \
-v `pwd`/logs:/var/log/nginx \
nginx
```

网关

```
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

