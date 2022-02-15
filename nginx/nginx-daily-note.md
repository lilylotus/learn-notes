### nginx WebScoket 配置支持

在 server 标签下配置匹配路径，`~` 表示使用正则表达式

```
location ~ ^/(uri|uri2|uri3)/ {
    // 转发代理地址
    proxy_pass           http://127.0.0.1:8080/;
    // 使用 http 版本为 1.1 
    proxy_http_version   1.1;
    // 超时设置，表明连接成功以后等待服务器响应的时候，如果不配置默认为 60s
    proxy_read_timeout   3600s;
    proxy_set_header Host $host:$server_port;
    // 启用支持 websocket 连接
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

### Nginx 反向代理获取客户端真实 IP、域名、协议、端口

nginx 添加如下配置：

```
proxy_set_header Host $http_host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

解释以上配置是在 Nginx 反向代理的时候，添加一些请求 Header。

1. `Host`包含客户端真实的域名和端口号；
2. `X-Forwarded-Proto`表示客户端真实的协议（http还是https）；
3. `X-Real-IP`表示客户端真实的IP；
4. `X-Forwarded-For`和`X-Real-IP`类似，但它在多层代理时会包含真实客户端及中间每个代理服务器的IP，每个IP用逗号隔开，一般来说最左边的第一个IP地址就是客户端IP。

通过获取HTTP请求头 `request.getHeader("X-Forwarded-For")` 或 `request.getHeader("X-Real-IP")` 来实现，也就是上面在 Nginx 上配置的 Header，这种方案获取的结果的确是正确的，但是觉得并不优雅。因为既然 Servlet API 提供了 `request.getRemoteAddr()` 方法获取客户端 IP，那么无论有没有用反向代理对于代码编写者来说应该是透明的。

Tomcat 配置 `setting.xml` 添加

```xml
<Valve className="org.apache.catalina.valves.RemoteIpValve" />
```

[RemoteIpValve](https://tomcat.apache.org/tomcat-8.5-doc/api/org/apache/catalina/valves/RemoteIpValve.html)