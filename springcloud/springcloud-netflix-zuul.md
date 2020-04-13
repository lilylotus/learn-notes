##### 路由和过滤 (Router and Filter) -- Zuul

`Zuul` 是基于 *JVM* 的路由，是服务端的负载均衡，来自于 Netflix。
**使用场景**

- Authentication 认证
- Insights
- Stress Testing
- Canary Testing
- Dynamic Routing
- Service Migration
- Load Sheding
- Security
- Static Response handing
- Active/Active traffic management

Zuul 的规则引擎使规则和过滤器基本上可以用任何 JVM 语言编写，并内置对 Java 和 Groovy 的支持。

**使用 zuul**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
</dependency>
```

**嵌入式 Zuul 反向代理**
在 Spring Boot 的 main 类中注解 `@EnableZuulProxy`。
这样做会导致将本地呼叫转发到适当的服务。

```yaml
zuul:
  ignoredServices: '*'
  routes:
    users: /myusers/**
```

所有的请求都会被忽略，除了 `users`

