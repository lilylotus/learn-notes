## https

```conf
    server {
        # 服务器端口使用443，开启ssl, 这里ssl就是上面安装的ssl模块
        listen       5445 ssl;
        # 域名，多个以空格分开
        server_name  nihility2.cn;
        
        # ssl证书地址
        ssl_certificate     C:/Users/intel/Desktop/20210408/newCert/certificate2/nihility2.cn.pem;  # pem文件的路径
        ssl_certificate_key  C:/Users/intel/Desktop/20210408/newCert/certificate2/nihility2.cn.key; # key文件的路径
        
        # ssl验证相关配置
        ssl_session_timeout  5m;    #缓存有效期
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;    #加密算法
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;    #安全链接可选的加密协议
        ssl_prefer_server_ciphers on;   #使用服务器端的首选算法

        location / {
            root   C:/Users/intel/Desktop/20210408;
            index  index.html index.htm;
        }
    }
```

## WebSocket

```
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}


location / {
    proxy_pass http://127.0.0.1:8080;

    proxy_set_header Host $host:$server_port;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Forwarded $proxy_add_forwarded;
    # websocket
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    proxy_connect_timeout 4s;
    proxy_read_timeout 60s;
    proxy_send_timeout 12s;
}
```

