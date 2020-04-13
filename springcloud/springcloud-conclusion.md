当前学习的 `Spring Cloud` 版本 `Hoxton.SR3`
支持的 `Spring Boot` 版本 `2.2.5.RELEASE`

---

##### 1. Spring Cloud Config (统一配置)

`Spring Cloud Config` 为分布式系统中的外部化配置提供服务器端和客户端支持。
使用 `Config Server`，您可以在中心位置管理所有环境中应用程序的外部属性。

**服务端：** `spring-cloud-config-server`  -> `@EnableConfigServer`
**客户端：** `spring-cloud-starter-config` -> `@RefreshScope`

##### 2. Netflix 支持

###### 2.1 Service Discovery (服务发现和注册)  [Eureka server/client] [localhost:8761]

服务发现是基于微服务的体系结构的主要宗旨之一。
可以将服务器配置和部署为高可用性，每个服务器将有关已注册服务的状态复制到其他服务器。

**服务端：** `spring-cloud-stater-netflix-eureka-server`  -> `@EnableEurekaClient`
**客户端：** `spring-cloud-starter-netflix-eureka-client` -> `@EnableEurekaServer`

###### 2.2 熔断器 [断路器] (Circuit Breaker) --- Hystrix

`Netflix` 创建了一个名为 *Hystrix* 的库，该库实现了断路器模式。在微服务架构中，通常有多个服务调用层。
较低级别的服务中的服务故障可能会导致级联故障，直至用户。
在错误和断路的情况下，开发人员可以提供备用功能。
开路可停止级联故障，并让不堪重负的服务时间得以恢复。
回退可以是另一个受 Hystrix 保护的调用，静态数据或合理的空值。可以将回退链接在一起，以便第一个回退进行其他业务调用，然后回退到静态数据。

**客户端：** `spring-cloud-netflix-hystrix` -> `@EnableCircuitBreaker`

###### 2.3 Circuit Breaker 仪表盘， (Hystrix Dashboard)

*Hystrix* 的主要优点之一是它收集的有关每个 *HystrixCommand* 的一组度量。
*Hystrix* 仪表盘以有效的方式显示每个断路器的运行状况。

**使用：** `spring-cloud-starter-netflix-hystrix-dashboard` -> `@EnableHystrixDashBoard`

###### 2.4  客户端负载均衡器 (Client Side Load Balancer) -- [Ribbon]

Ribbon 是客户端负载平衡器，可让您对 HTTP 和 TCP 客户端的行为进行大量控制。
Feign 已经使用了 Ribbon，因此，如果您使用 `@FeignClient`，则也适用。
Ribbon 中的中心概念是指定客户端的概念。
每个负载平衡器都是一组组件的一部分，这些组件可以一起工作以按需联系远程服务器，并且该组件的名称是您作为应用程序开发人员提供的名称。
根据需要，Spring Cloud 通过使用 RibbonClientConfiguration 为每个命名客户端创建一个新的集合作为 ApplicationContext。

**使用：** `spring-cloud-starter-netflix-ribbon` -> `@RibbonClient`

###### 2.5 路由和过滤器 (Router and Filter) -- [Zuul]

路由是微服务架构不可或缺的一部分。
`/` 可能被映射到您的Web应用程序，`/api/users` 被映射到用户服务，而  `/api/shop` 被映射到 `shop` 服务。
Zuul 是 Netflix 提供的基于 JVM 的路由器和服务器端负载平衡器。

**使用：** `spring-cloud-starter-netfilx-zuul` -> `@EnableZuulProxy` / `@EnableZuulServer`

##### 3. Spring Cloud Sleuth (跟踪) [localhost:9411]

Spring Cloud Sleuth 为 Spring Cloud 实现了分布式跟踪解决方案。

**使用：** `spring-cloud-starter-sleuth` (仅使用 Sleuth，没有 Zipkin 集成) [日志相关]
或者 `spring-cloud-starter-zipkin`  *Sleuth* 使用 *Zipkin* 通过 *HTTP*

##### 4. Spring Cloud Consul

该项目通过自动配置并绑定到 Spring Environment 和其他 Spring 编程模型习惯用法，为 Spring Boot 应用程序提供 Consul 集成。
通过一些简单的注释，您可以快速启用和配置应用程序内部的通用模式，并使用基于Consul的组件构建大型分布式系统。
提供的模式包括服务发现，控制总线和配置。
通过与 Spring Cloud Netflix 集成提供智能路由（Zuul）和客户端负载平衡（Ribbon），断路器（Hystrix）。

##### Spring Cloud Gateway (API 网关)

该项目提供了一个在 Spring 生态系统之上构建的 API 网关，包括：Spring 5，Spring Boot 2 和 Project Reactor。
Spring Cloud Gateway 旨在提供一种简单而有效的方法来路由到 API，并为它们提供跨领域的关注点，例如：安全性，监视/指标和弹性。