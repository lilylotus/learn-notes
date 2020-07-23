### openssl 生成签名证书

#### 基本概念

- ***CA*** 认证机构
- ***证书(网站)*** 发给客户端的证书
- ***私钥(网站)*** 服务器保存的解密私钥

#### 基本流程

1. 虚拟的CA机构，生成一个证书
2. 生成自己的密钥，然后填写证书认证申请，拿给上面的 CA 机构去签名
3. 就得到了自建 CA 机构认证的签名证书

#### 生成签名证书流程

##### 生成一个 CA 认证机构

生成 CA 认证机构的证书 RSA 密钥 key
des3 是算法，2048 位强度，caserver.key 是密钥文件名， -out 指生成文件的路径和名称

```bash
openssl genrsa -des3 -out caserver.key 2048
```

查看生成的私钥

```bash
openssl rsa -text -in caserver.key
```

用私钥 caserver.key 生成 CA 认证机构的证书 caserver.crt，就是相当于用私钥生成公钥，再把公钥包装成证书
这个证书 caserver.crt 有的又称为"根证书"，因为可以用来认证其它证书

```bash
openssl req -new -x509 -key caserver.key -out caserver.crt -days 365

Country Name (2 letter code) [XX]:CN  
State or Province Name (full name) []:ShangHai
Locality Name (eg, city) [Default City]:ShangHai
Organization Name (eg, company) [Default Company Ltd]:nihility
Organizational Unit Name (eg, section) []:nihility
Common Name (eg, your name or your server's hostname) []:*.nihility.cn
Email Address []:lily@nihility.cn
```

创建证书签名请求 CSR 文件
私钥就包含在请求文件中了，认证机构要用它来生成网站的公钥，然后包装成一个证书
-key ：指定 ca 私钥，-out ：caserver.csr 生成证书文件

```bash
openssl req -new -key caserver.key -out caserver.csr

Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:ShangHai
Locality Name (eg, city) [Default City]:ShangHai
Organization Name (eg, company) [Default Company Ltd]:nihility
Organizational Unit Name (eg, section) []:nihility
Common Name (eg, your name or your server's hostname) []:*.nihility.cn
Email Address []:lily@nihility.cn

A challenge password []:luck
An optional company name []:nihility
```

查看 csr 文件

```bash
openssl req -text -in caserver.csr -noout
```

删除私钥中的密码

```bash
openssl rsa -in caserver.key -out caserver_no_password.key
```

生成 CA 证书
x509 : 指定格式，-in : 指定请求文件，-signkey : 自签名
注意：caserver.crt 是证书持有人的信息，持有人的公钥，以及签署者的签名等信息

```bash
openssl x509 -req -days 365 -in caserver.csr -signkey caserver.key -out caserver.crt
```

##### 生成客户端证书

生成私钥

```bash
openssl genrsa -out client.key 2048
```

生成请求文件

```bash
openssl req -new -key client.key -out client.csr

Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:ShangHai
Locality Name (eg, city) [Default City]:ShangHai
Organization Name (eg, company) [Default Company Ltd]:nihility
Organizational Unit Name (eg, section) []:nihility
Common Name (eg, your name or your server's hostname) []:*.nihility.cn
Email Address []:lily@nihility.cn

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:luck
An optional company name []:nihility
```

发给 CA 签名

```bash
openssl x509 -req -days 365 -in client.csr -signkey client.key -out client.crt
```

