##### Spring Cloud Netfix 组成

服务发现 *(Service Discovery)* `[Eureka]`

> 可以注册 Eureka 实例，并且客户端可以使用 Spring 管理的 *beans* 发现实例。
> 声明式 *Java* 配置 *(declarative Java Configuration)*  创建一个内嵌的 *Eureka* 服务器

熔断 *(Circuit Breaker)* `[Hystrix]`

> *Hystrix* 客户端可以简单的注解驱动 *(annotation-driven)* 方法装饰器来构建
> 声明式 *Java* 配置来内嵌 *Hystrix* 仪表盘

智能路由 *(Intelligent Routing)* `[Zuul]`
客户端负载平衡 *(Client Side Load Balancing)* `[Ribbon]`

声明式 *REST* 客户端  *(Declarative REST Client)*

> Feign 创建一个用 JAX-RS 或 Spring MVC 注释修饰的接口的动态实现。

拓展配置 *(External Configuration)*

> 从 Spring Environment 到 Archaius 的桥梁（使用 Spring Boot 约定启用 Netflix 组件的本机配置）

路由器和过滤器 *(Router and Filter)*

> Zuul 过滤器的自动重新注册，以及针对反向代理创建的配置方法上的简单约定

---

###### 服务发现：Eureka Client

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

客户端向 Eureka 注册时，它将提供有关自身的元数据，例如主机，端口，运行状况指示器URL，主页和其他详细信息。
Eureka从属于服务的每个实例接收心跳消息。 *(heartbeat messages)*
如果心跳在可配置的时间表上进行故障转移，则通常会将实例从注册表中删除。

最简单的 *Eureka Client* 应用：

```java
@SpringBootApplication
@RestController
public class Application {
    @RequestMapping("/")
    public String home() {
        return "Hello world";
    }
    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class).web(true).run(args);
    }
}
```

通过在类路径上使用 `spring-cloud-starter-netflix-eureka-client`，您的应用程序将自动向 *Eureka Server* 注册。需要进行配置才能找到 *Eureka* 服务器

```yaml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
```

**配置 Eureka Server 的校验**

```yaml
eureka:
  instance:
    statusPageUrlPath: ${server.servletPath}/info
    healthCheckUrlPath: ${server.servletPath}/health

# 使用 HTTPS
eureka.instance.[nonSecurePortEnabled]=[false]
eureka.instance.[securePortEnabled]=[true]
eureka:
  instance:
    statusPageUrl: https://${eureka.hostname}/info
    healthCheckUrl: https://${eureka.hostname}/health
    homePageUrl: https://${eureka.hostname}/
```

**Eureka 的健康检查**
默认 *Eureka* 使用客户端心跳来确定客户端是否启动。
除非另有说明，否则按照 *Spring Boot Actuator* 的规定，*Discovery Client* 不会传播应用程序的当前运行状况检查状态。
因此，在成功注册后，Eureka 始终宣布该应用程序处于“启动”状态。
可以通过启用 Eureka 运行状况检查来更改此行为，这会导致应用程序状态传播到 Eureka。
结果，所有其他应用程序都不会将流量发送到处于 *"UP"* 状态以外的其他状态的应用程序。
*配置 Client 允许健康检查*

```yaml
eureka:
  client:
    healthcheck:
      enabled: true

# 注意： eureka.client.healthcheck.enabled=true 应该配置在 application.yml 当中
# 设置值在 bootstrap.yml 当中会导致不良副作用，如：在 Eureka 中以 UNKONWN 状态注册
```

---

##### Eureka Server 配置

###### Eureka Server 依赖和初始化

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>
```

*若是项目已经使用了 `Thymeleaf` 作为 `template engine` ，那么 Eureka Server 的 `Freemarker template` 也许会不能正确加载，所以就需要手动配置*

```yaml
spring:
  freemarker:
    template-loader-path: classpath:/templates/
    prefer-file-system-access: false
```

**默认 `Eureka Server` 是会注册自己到 discovery**

```yaml
eureka:
   client:
      registerWithEureka: false
      fetchRegistry: false
server:
   port: 8761
```

**运行 server 服务**

```java
@SpringBootApplication
@EnableEurekaServer
public class Application {

    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class).web(true).run(args);
    }

}
```

服务器在 `/eureka/ *` 下有一个主页，其中包含 UI 和 HTTP API 端点，用于 Eureka 的正常功能。

**注意： 使用 gradle 时** ： 由于 Gradle 的依赖性解析规则以及缺乏父 Bom 功能，依赖 `spring-cloud-starter-netflix-eureka-server` 可能在应用启动的时候导致失败。为解决这个问题，如下配置：

```gradle
buildscript {
  dependencies {
    classpath("org.springframework.boot:spring-boot-gradle-plugin:{spring-boot-docs-version}")
  }
}

apply plugin: "spring-boot"

dependencyManagement {
  imports {
    mavenBom "org.springframework.cloud:spring-cloud-dependencies:{spring-cloud-version}"
  }
}
```

**高可用性，Zones 和 Regions**
Eureka 服务器没有后端存储，但是注册表中的所有服务实例都必须发送心跳信号以使其注册保持最新（因此可以在内存中完成）。
客户端还具有 Eureka 注册的内存缓存（因此，对于每个对服务的请求，它们都不必进入注册表）。

默认情况下，每个 Eureka 服务器也是 Eureka 客户端，并且需要（至少一个）服务 URL 来定位对等方。
如果您不提供该服务，则该服务将运行并工作，但是它将使您的日志充满关于无法向对等方注册的噪音。

*Ribbon* 支持对于客户端的 Zones 和 Regions。

**Standalone Mode (单机模式)**
只要有某种监视器或弹性运行时（例如 *Cloud Foundry*），这两个缓存（客户端和服务器）以及心跳的组合就可以使独立的 Eureka 服务器对故障具有相当的恢复能力。
在独立模式下，您可能希望关闭客户端行为，以使其不会继续尝试并无法到达其对等对象。

如何关闭 *client-side* 的行为： `application.yml (Standalone Eureka Server)`

```yaml
server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    registerWithEureka: false
    fetchRegistry: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
```

*注意：* `serviceUrl` 指向本地实例的相同主机

**Peer Awareness (同级意识)**
通过运行多个实例并要求它们相互注册，可以使 Eureka 更具弹性并可以使用。
实际上，这是默认行为，因此要使其正常工作，您需要做的就是向对等方添加有效的 `serviceUrl`

*application.yml (Two Peer Aware Eureka Servers)*

```yaml
---
spring:
  profiles: peer1
eureka:
  instance:
    hostname: peer1
  client:
    serviceUrl:
      defaultZone: https://peer2/eureka/

---
spring:
  profiles: peer2
eureka:
  instance:
    hostname: peer2
  client:
    serviceUrl:
      defaultZone: https://peer1/eureka/
```

###### Eureka Server 安全

添加依赖 `spring-boot-starter-security`。
默认情况下，当 *Spring Security* 位于类路径上时，它将要求在每次向应用程序发送请求时都发送有效的 *CSRF* 令牌。
这时需要禁用这个要求，对于 `/eureka/**` 端点来说：

```java
@EnableWebSecurity
class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().ignoringAntMatchers("/eureka/**");
        super.configure(http);
    }
}
```

###### 关闭使用 `Ribbon` 对于 Eureka Server 和 Clients starters

`spring-cloud-starter-netflix-eureka-server` 和 `spring-cloud-starter-netflix-eureka-client` 附带有 `spring-cloud-starter-netflix-ribbon`。
由于 `Ribbon` 负载均衡器现在处于维护模式，建议改用 *Eureka* 启动程序中也包括的 `Spring Cloud LoadBalancer`。

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-ribbon</artifactId>
        </exclusion>
        <exclusion>
            <groupId>com.netflix.ribbon</groupId>
            <artifactId>ribbon-eureka</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

###### JDK 11 支持

`JAXB` 模块 `Eureka server` 依赖已经在 `JDK 11` 中被移除

```xml
<dependency>
    <groupId>org.glassfish.jaxb</groupId>
    <artifactId>jaxb-runtime</artifactId>
</dependency>
```

