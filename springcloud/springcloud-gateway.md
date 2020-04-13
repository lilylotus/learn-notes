##### Spring Cloud Gateway (网关)

若是不想启动 `spring.cloud.gateway.endabled=false`

> Spring Cloud Gateway 需要 Spring Boot 和 Spring Webflux 提供的 Netty 运行时。
> 它不能在传统的 Servlet 容器中或作为 WAR 构建时使用。

**常用名称 (Glossary)**

- **Route (路由)**：网关的基本构建块，它由 ID，目标 URI，谓词集合和过滤器集合定义。如果聚合谓词为 true，则匹配路由。
- **Predicate (断言)**： `Java 8 Function Predicate`。输入类型为 *Spring Framewrok* 的 `ServerWebExchange`。这使您可以匹配 HTTP 请求中的所有内容，例如标头或参数。
- **Filter (过滤器)** ： 这个是 *Spring Framework* `GatewayFilter` 的实例，由特定的工厂构建。在这里，您可以在发送下游请求之前或之后修改请求和响应。