##### 客户端的负载均衡 (Client Side Load Balancer) -- Ribbon

*Ribbon* 是客户端负载平衡器，可让您对 *HTTP* 和 *TCP* 客户端的行为进行大量控制。**
*Feign* 已经使用了 *Ribbon*，因此，如果您使用 `@FeignClient`，也适用。

Ribbon 中的中心概念是指定客户端的概念。

每个负载均衡器都是组件的一部分，这些组件可以一起工作以按需联系远程服务器，并且该组件具有您作为应用程序开发人员提供的名称（例如，使用 `@FeignClient` 批注）。
根据需要，*Spring Cloud* 通过使用 *RibbonClientConfiguration* 为每个命名客户端创建一个新的集合作为 *ApplicationContext*。
它包含（除其他事项外）一个 `ILoadBalancer`，一个 `RestClient` 和一个 `ServerListFilter`。

**使用 Ribbon**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>
</dependency>
```

**自定义 Ribbon 客户端**

```java
@Configuration
@RibbonClient(name = "custom", configuration = CustomConfiguration.class)
public class TestConfiguration {}
```

`@RibbonClient` 注解类配置 *Ribbon Client*，该组件自动放入 `RbiionClientConfiguraiont` 当中。
*注意：* 自定义的配置必须声明 `@Configuration` 注解

自定义 *Bean*

```java
@Configuration(proxyBeanMethods = false)
protected static class FooConfiguration {
    @Bean
    public ZonePreferenceServerListFilter serverListFilter() {
        ZonePreferenceServerListFilter filter = new ZonePreferenceServerListFilter();
        filter.setZone("myTestZone");
        return filter;
    }
    @Bean
    public IPing ribbonPing() {
        return new PingUrl();
    }
}
```

