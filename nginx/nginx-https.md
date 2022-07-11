## 1. nginx 安装

### 1.1 openssl 安装

[openssl release](https://github.com/openssl/openssl/tags)

```bash
echo /usr/local/lib64 >> /etc/ld.so.conf
ldconfig -v
```

### 1.2 nginx 安装

[nginx release](http://nginx.org/en/download.html)

```bash
./configure --with-http_ssl_module --with-openssl=/root/pki/openssl
```

## 2. nginx 配置双向 SSL 认证

### 2.1 CA 证书

```bash
# 无密码
openssl genrsa -out ca.key 2048
# 有密码
# openssl genrsa -des3 -out ca.key 2048

openssl req -new -x509 -key ca.key -days 3650 -subj "/C=CN/ST=Shanghai/L=Shanghai/O=yzx/OU=ssl/CN=ssl" -out ca.crt

openssl rsa -in ca.key -text
openssl pkey -in ca.key -text
openssl x509 -in ca.crt -noout -text
```

### 2.2 服务端证书

```bash
openssl genrsa -out server.key 2048
# 签发请求
openssl req -new -key server.key -subj "/C=CN/ST=Shanghai/L=Shanghai/O=yzx/OU=ssl/CN=*.yzx.com" -out server.csr
# openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

# 解决 chrome 不安全
cat <<EOF > server.ext
[SAN]
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = DNS:doc.yzx.com,IP:192.168.110.129
EOF

openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -extfile server.ext -extensions SAN -out server.crt

openssl x509 -in server.crt -noout -text
openssl x509 -in server.crt -noout -serial -dates -subject
```

### 2.3 客户端证书

单向认证是客户端根据 ca 根证书验证服务端提供的服务端证书和私钥
双向认证还要服务端根据 ca 根证书验证客户端证书和私钥，因此双向认证之前还需要生成客户端证书和私钥

```bash
openssl genrsa -out client.key 2048
openssl req -new -key client.key -subj "/C=CN/ST=Shanghai/L=Shanghai/O=yzx/OU=ssl/CN=yzx/emailAddress=yzx@yzx.com" -out client.csr
openssl x509 -req -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt

openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
```

## 3. nginx 配置

```
server {
    listen       443 ssl;
    server_name  doc.yzx.com;

    keepalive_timeout   70;
    charset utf-8;

    ssl_certificate      /root/pki/ssl/ca2/server.crt;
    ssl_certificate_key  /root/pki/ssl/ca2/server.key;
    ssl_session_cache    shared:SSL:10m;
    ssl_session_timeout  5m;
    ssl_ciphers          ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols        TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers  on;

    ssl_client_certificate /root/pki/ssl/ca2/ca.crt;
    ssl_verify_client    on;

    # 80 -> 443
    # if ($server_port = 80) {
    #     rewrite ^(.*)$ https://$host$1 permanent;
    # }

    location / {
        proxy_pass http://192.168.110.129:8080/;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        proxy_set_header HTTP_X_FORWARDED_FOR $remote_addr;
    }
}
```

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

