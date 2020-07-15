### 生成证书库
根证书就是给别的证书签名的证书，根证书的职责就是与 CA 做同样的事情，确认其他的证书是否可信，如果可信，进行签名

```cmd
keytool -genkey -alias basic -keyalg dsa -keysize 1024 -startdate 2019/11/01 -validity 365 -keystore E:\apache-tomcat-8.5.34\conf\basic.keystore -storepass basicpass -keypass basicpass

-storepass      数据库的密码
-keypass        数据库表的密码
```

### jks 转 p12
```cmd
keytool -importkeystore -srckeystore E:\apache-tomcat-8.5.34\conf\basic.keystore -destkeystore E:\apache-tomcat-8.5.34\conf\basic.p12 -srcstorepass basicpass -deststorepass basicpass

-importkeystore    使用导入证书库功能
-srckeystore    源证书库
-destkeystore   目标证书库（后缀表示格式-storetype具体查看文档）
-srcstorepass   源证书库的密码
-deststorepass  目标证书库的密码

主密码：证书库条目的密码（数据库表的密码）此时在目标位置生成了一个basic.p12的证书库，p12可以在大多数的浏览器中导入。
```

### 证书库导出 cer 文件
```cmd
keytool -v -list -keystore E:\apache-tomcat-8.5.34\conf\basic.keystore -storepass basicpass

-v      详细输出
-list   查看


获得 cer 文件
keytool -export -v -alias basic -keystore E:\apache-tomcat-8.5.34\conf\basic.keystore -file E:\apache-tomcat-8.5.34\conf\basic.cer -storepass basicpass -keypass basicpass

```

### 证书库生成证书请求
```cmd
keytool -certreq -alias basic -keystore E:\apache-tomcat-8.5.34\conf\basic.keystore -file E:\apache-tomcat-8.5.34\conf\serverreq.cer -storepass basicpass -keypass basicpass

此时会生成一个cer文件，安装提示无效的证书。
证书请求就是需要发送给ca或者第三方请求签名的文件。
```

### 对证书请求进行签名
```cmd
keytool -gencert -v -alias basic -infile E:\apache-tomcat-8.5.34\conf\serverreq.cer -outfile E:\apache-tomcat-8.5.34\conf\resserver.cer -keystore E:\apache-tomcat-8.5.34\conf\basic.keystore -storepass basicpass -keypass basicpass

```

### 完整例子

```cmd
1. 创建证书库

创建根证书库
keytool -genkey -alias key_basic -validity 365 -keystore E:\ssl\basic.keystore -storepass storepass -keypass keypass

创建客户端证书库
keytool -genkey -alias key_client -validity 365 -keystore E:\ssl\client.keystore -storepass storepass -keypass storepass

创建服务器证书库
keytool -genkey -alias key_server -validity 365 -keystore E:\ssl\server.keystore -storepass storepass -keypass storepass

2. 导出根证书
keytool -export -v -alias key_basic -keystore E:\ssl\basic.keystore -file E:\ssl\basic.cer -storepass storepass -keypass keypass

3. 证书库发起请求
服务器发起请求
keytool -certreq -alias key_server -keystore H:\server.keystore -file H:\server_req.cer -storepass server -keypass keyserver

客户端发起请求
keytool -certreq -alias key_client -keystore H:\client.keystore -file H:\client_req.cer -storepass client -keypass keyclient


```