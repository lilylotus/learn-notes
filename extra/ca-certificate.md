## 证书
### 安全协议 [SSL/TLS]

SSL (Secure Sockets Layer 安全套接字协议)，及其继任者传输层安全（Transport Layer Security，TLS）是为网络通信提供安全及数据完整性的一种安全协议。TLS 与 SSL 在传输层与应用层之间对网络连接进行加密。

Secure Socket Layer，为 Netscape 所研发，用以保障在 Internet 上数据传输的安全，利用数据加密(Encryption)技术，可确保数据在网络上的传输过程中不会被截取及窃听。

SSL 协议位于 TCP/IP 协议与各种应用层协议之间，为数据通讯提供安全支持。SSL 协议可分为两层：
SSL 记录协议（SSL Record Protocol）：它建立在可靠的传输协议（如 TCP）之上，为高层协议提供数据封装、压缩、加密等基本功能的支持。
SS L握手协议（SSL Handshake Protocol）：它建立在 SSL 记录协议之上，用于在实际的数据传输开始前，通讯双方进行身份认证、协商加密算法、交换加密密钥等。

术语：
* `CA` (Certification Authority、Certifying Authority) : 认证机构
* `HTTPS`（Hypertext Transfer Protocol Secure）：安全超文本传输协议
* `PKC` (Public-Key Certificate) ：公钥证书，也简称为证书（certificate）

### 证书签发
#### 生成 CA 根证书

生成 CA 密钥对   --->  生成根证书签发申请  ---> 根证书签发

```bash
# 1. 生成 CA 密钥对
# openssl genrsa -out file.pem 2048[4096] RSA
openssl genrsa -out /root/cas/ca/cakey.pem 2048 RSA

# 2. 生成根证书的签发申请
# 证书访问的时候必须以域名的形式出现
openssl req -new -key /root/cas/ca/cakey.pem -out /root/cas/ca/cacert.csr -subj /CN=drill.cn

# 3. 生成根证书签发申请
openssl x509 -req -days 3650 -sha1 -extensions v3_ca -signkey /root/cas/ca/cakey.pem -in /root/cas/ca/cacert.csr -CAcreateserial -out /root/cas/ca/ca.cer
```

####  生成服务端证书

CA 根证书   --->  生成服务器私钥 ---> 服务器证书签发申请  ---> 服务器证书签发

```bash
# 1. 生成要私钥
openssl genrsa -aes256 -out /root/cas/server/serverkey.pem 2048

# 2. 生成服务端证书签发申请
openssl req -new -key /root/cas/server/serverkey.pem -out /root/cas/server/server.csr -subj /CN=drill.cn

# 3. 生成服务端签发申请
openssl x509 -req -days 3560 -sha1 -extensions v3_req -CA /root/cas/ca/ca.cer -CAkey /root/cas/ca/cakey.pem -CAserial /root/cas/server/ca.srl -CAcreateserial -in /root/cas/server/server.csr -out /root/cas/server/server.cer
```

####  客户端证书

服务端根证书 ---> 生成客户端私钥 ---> 生成客户端签发申请 ---> 客户端证书签发

```bash
# 1. 生成客户端私钥
openssl genrsa -aes256 -out /root/cas/client/client-key.pem 2048

# 2. 生成客户端签发申请
openssl req -new -key /root/cas/client/client-key.pem -out /root/cas/client/client.csr -subj /CN=drill.cn

# 3. 客户端证书签发
# 该证书仅针对 drill.com 有效
openssl x509 -req -days 3650 -sha1 -CA /root/cas/ca/ca.cer -CAkey /root/cas/ca/cakey.pem -CAserial /root/cas/server/ca.srl -in /root/cas/client/client.csr -out /root/cas/client/client.cer
```

#### JAVA 证书

上面生成的证书目前在 JAVA 环境下还不能使用，需与转换为 "PKCS#12" 编码格式密钥文件才可以被 JAVA 的 keytool 工具管理。

```bash
# 1. 生成客户端证书
# 客户端证书随后是要发给浏览器
openssl pkcs12 -export -clcerts -name cas-client -inkey /root/cas/client/client-key.pem -in /root/cas/client/client.cer -out /root/cas/tomcat/client.p12

# 2. 生成服务端证书
# 主要有 tomcat 服务器使用
openssl pkcs12 -export -clcerts -name cas-server -inkey /root/cas/server/serverkey.pem -in /root/cas/server/server.cer -out /root/cas/tomcat/server.p12

# 3. 导入信任证书
# 将现在生成的服务器端证书导入到本机的受信任证书当中
# JDK 表示当前使用的证书得到了认可
keytool -importcert -trustcacerts -alias drill.cn -file /root/cas/ca/ca.cer -keystore /root/cas/tomcat/ca-trust.p12

# 4. 查看证书信息
keytool -list -keystore /root/cas/tomcat/client.p12 -storetype pkcs12 -v
```

### tomcat 使用证书

tomcat 配置文件 `conf/server.xml`

#### tomcat 单向认证

> 单向认证：只是在服务端提供一个公共的证书，所有的客户端连接之后都可以获得此公钥。
> 加密后，服务端可以利用私钥进行解密。

```
 <Connector port="443" protocol="HTTP/1.1"
        maxThreads="150" SSLEnabled="true" 
        schema="https" secure="true" clientAuth="false" sslProtocol="TLS"
        keystoreFile="/root/cas/tomcat/server.p12"
        keystoreType="pkcs12" keystorePass="luckluck" \>
```

#### tomcat 双向认证

```
 <Connector port="443" protocol="HTTP/1.1"
        maxThreads="150" SSLEnabled="true" 
        schema="https" secure="true" clientAuth="true" sslProtocol="TLS"
        keystoreFile="/root/cas/tomcat/server.p12"
        keystoreType="pkcs12" keystorePass="luckluck"
        truststoreFile="/root/cas/tomcat/ca-trust.p12"
        truststoreType="jks"
        truststorePass="luckluck"/>
```