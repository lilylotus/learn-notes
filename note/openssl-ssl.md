# openssl SSL 证书
如何使用 OpenSSL 工具箱生成自签名 SSL 证书以启用 HTTPS 连接。

## OpenSSL 生成自签名证书

SSL 证书的公共名称 (CN)。 该公共名称 (CN) 是使用该证书的系统的标准名称。 对于静态 DNS，请使用网关集群中设置的主机名或 IP 地址（例如，192.16.183.131 或 dp1.acme.com）。

运行以下 OpenSSL 命令来生成您的专用密钥和公共证书。
```bash
# -subj "/C=CN/ST=BJ/L=BJ/O=HD/OU=dev/CN=ca/emailAddress=ca@world.com"
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem -subj "/C=CN/CN=yzx"
```

检查已创建的证书：
```bash
openssl x509 -text -noout -in certificate.pem
```

将密钥和证书组合在 PKCS#12 (P12) 捆绑软件中：
```bash
openssl pkcs12 -inkey key.pem -in certificate.pem -export -out certificate.p12
```

验证您的 P12 文件:
```bash
openssl pkcs12 -in certificate.p12 -noout -info
```

## 生成认证中心的 PKCS#12 文件

生成 P12 文件之前，必须具有专用密钥（例如，key.pem）、由认证中心签名的证书（例如，certificate.pem）以及一个或多个来自 CA 认证机构的证书。

如果具有来自 CA 的中间证书，请将这些证书并置成一个 .pem 文件以构建 caChain。请确保在每个证书的数据之后输入新行。
```bash
cat ca1.pem ca2.pem ca3.pem > caChain.pem
cat caChain.pem
-----BEGIN CERTIFICATE-----
MIIEpjCCA46gAwIBAgIQEOd26KZabjd+BQMG1Dwl6jANBgkqhkiG9w0BAQUFADCB
...
lQX7CkTJn6lAJUsyEa8H/gjVQnHp4VOLFR/dKgeVcCRvZF7Tt5AuiyHY
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEPDCCAySgAwIBAgIQSEus8arH1xND0aJ0NUmXJTANBgkqhkiG9w0BAQUFADBv
...
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIENjCCAx6gAwIBAgIBATANBgkqhkiG9w0BAQUFADBvMQswCQYDVQQGEwJTRTEU
...
-----END CERTIFICATE-----
```

创建 P12 文件，其中包含专用密钥、签名证书和步骤 1 中创建的 CA 文件（适用的情况下）。 如果没有要包含在内的 CA 证书，那么请省略 CAfile 选项。以下命令使用了 OpenSSL（这是 SSL 和 TLS 协议的开放式源代码实现）
```bash
openssl pkcs12 -inkey key.pem -in certificate.pem -export -out certificate.p12 -CAfile caChain.pem -chain

openssl pkcs12 -inkey key.pem -in certificate.pem -export -out certificate.p12
```

### openssl 生成证书及签名

C  表示 Country or Region
ST 表示 State/Province
L  表示 Locality
O  表示 Organization
OU 表示 Organization Unit
CN 表示 Common Name

```bash
# 1. 生成私钥
openssl genrsa -out private-key.pem 2048
openssl rsa -in private-key.pem -noout -text

# 2. 生成私钥对应的公钥
openssl rsa -in private-key.pem -pubout -out public-key.pem
openssl rsa -pubin -in public-key.pem -noout -text

# 3. 根据私钥生成证书签名请求
# -subj "/C=CN/ST=BJ/L=BJ/O=HD/OU=dev/CN=hello/emailAddress=hello@world.com"
openssl req -new -key private-key.pem -out csr.pem -subj "/C=CN/CN=openssl"
openssl req -in csr.pem -noout -text

# 发送签发请求到 CA 进行签发，生成 x509 证书
# 4.1 生成 CA 私钥
openssl genrsa -out ca-private.pem 2048

# 4.2 根据 CA 私钥生成 CA 的自签名证书
# 这一步直接生成自签名的证书，而在第三步生成的是证书签名请求，这个证书签名请求是要发给 CA 生成最终证书的。
# -subj "/C=CN/ST=BJ/L=BJ/O=HD/OU=dev/CN=ca/emailAddress=ca@world.com"
openssl req -new -x509 -days 365 -key ca-private.pem -out ca.crt -subj "/C=CN/CN=ca"

# 4.3 使用 CA 的私钥和证书对用户证书签名
openssl x509 -req -days 3650 -in csr.pem -CA ca.crt -CAkey ca-private.pem -CAcreateserial -out crt.pem
openssl x509 -in crt.pem -noout -serial -dates -subject
```

| 格式          | 说明                                                       |
| ------------- | ---------------------------------------------------------- |
| `.crt` `.cer` | 证书 (Certificate)                                         |
| `.key`        | 密钥/私钥 (Private Key)                                    |
| `.csr`        | 证书认证签名请求 (Certificate signing request)              |
| `*.pem`       | base64 编码文本储存格式，可以单独放证书或密钥，也可以同时放两个 |
| `*.der`       | 证书的二进制储存格式(不常用)                                 |