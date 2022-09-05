## 服务负载失效

uri 配置为服务负载方式 `lb://service` 无效

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: myRoute
        uri: lb://service
        predicates:
        - Path=/service/**
```

添加 spring cloud loadbalancer 依赖

```properties
implementation 'org.springframework.cloud:spring-cloud-starter-loadbalancer'
implementation "com.github.ben-manes.caffeine:caffeine"
```

## Http 请求 Host 参数被修改

[配置 filter 保留 header 参数](https://docs.spring.io/spring-cloud-gateway/docs/3.0.4/reference/html/#the-preservehostheader-gatewayfilter-factory)

是否以原始的 *host* 请求头发送，而不是由 httpclient 决定的 host 请求头。

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: preserve_host_route
        uri: https://example.org
        filters:
        - PreserveHostHeader
```

没有配置保留原始 host 请求头，使用 gateway client 默认 host 请求头 `reactor.netty.http.client.HttpClientConnect.HttpClientHandler#requestWithBody`

```java
SocketAddress remoteAddress = uri.getRemoteAddress();
if (!headers.contains(HttpHeaderNames.HOST)) {
    headers.set(HttpHeaderNames.HOST, resolveHostHeaderValue(remoteAddress));
}
```

若是前面还有 nginx 做后台代理转发， nginx 需要配置 **`proxy_set_header Host $http_host;`** 添加 http `Host` 请求参数。

```properties
location ~ ^/(gateway)/ {
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   Host $http_host;
    proxy_set_header   X-NginX-Proxy true;
    proxy_pass         http://127.0.0.1:54000;
}
```

nginx 中 `$host`、`$http_host` 和 `$proxy_host` 区别

| 变量        | 是否保留端口             | 值                                                |
| ----------- | ------------------------ | ------------------------------------------------- |
| $host       | 不显示端口               | 浏览器请求的 ip ，不包含端口号                    |
| $http_host  | 端口存在则显示           | 浏览器请求的 [ip/域名]:port                       |
| $proxy_host | 默认 80 不显示，其它显示 | 代理服务请求的 [ip/域名]:port ，proxy_pass 中的值 |

示例：若请求 local.test.com:8080 

- $host -> local.test.com
- $http_host -> local.test.com:8080
- $proxy_host -> 127.0.0.1:54000
