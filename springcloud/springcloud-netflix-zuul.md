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

#### 1. zuul 网关

##### 1.1 简介

zuul 是 Netflix 开源的微服务网关，可以和 Eureka，Ribbon，Hystrix 等组件配合使用，zuul 网关是由一系列的过滤器组成。

- 动态路由：动态将请求路由到不同后端的集群
- 压力测试：逐渐增加指向集群的流量，了解性能
- 负载均衡：为每一个负载类型分配对应的容量，并弃用超出限定的请求
- 静态响应处理：边缘位置进行响应，避免转发到内部集群
- 身份认证和安全：识别每一个请求的验证要求，并拒绝不符合的请求， spring Cloud 对 zuul 进行了整合和增强

##### 1.2 搭建 zuul 网关服务器

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
</dependency>
```

开启网关功能

```java
@EnableZuulProxy
public class Application() {}
```

##### 1.3 配置过滤规则 (路由)

路由：根据请求的 url 转发到不同的微服务当中

```yaml
zuul:
  routes:
    spring-cloud-service-provider:
      path: /service-provider/** # 映射路径 localhost/service-provider/xx
      url: http://localhost:52200 # 转发的实际微服务地址 52200
```

面向微服务配置

```yaml
zuul:
  routes:
    spring-cloud-service-provider:
      path: /service-provider/** # 映射路径 localhost/service-provider/xx
      serviceId: spring-cloud-service-provider # 配置转发的微服务 id
```

简化配置，当路由 id 和 serviceId 一致时

```yaml
zuul:
  routes:
    service-product: /product-service/**
# http://localhost:52204/spring-cloud-service-provider/employee/list
```

