Feign 是声明性 Web 服务客户端
Spring Cloud 集成了 Ribbon 和 Eureka 以及 Spring Cloud LoadBalancer，以在使用 Feign 时提供负载平衡的 http 客户端。

**使用 Feign**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
    <version>2.2.2.RELEASE</version>
</dependency>
```

```java
@SpringBootApplication
@EnableFeignClients
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

```java
@FeignClient("stores")
public interface StoreClient {
    @RequestMapping(method = RequestMethod.GET, value = "/stores")
    List<Store> getStores();

    @RequestMapping(method = RequestMethod.POST, value = "/stores/{storeId}", consumes = "application/json")
    Store update(@PathVariable("storeId") Long storeId, Store store);
}
```

`@FeignClient` 注解中的 *名称* (stores) 是任意的客户端名称，用来创建 `Ribbon` 负载平衡器，或者 `Spring Cloud LoadBalancer`。
上面的负载平衡器客户端将希望发现 *stores* 服务的物理地址。
如果您的应用程序是 Eureka 客户端，则它将在 Eureka 服务注册表中解析该服务。
如果您不想使用 Eureka，则只需在外部配置中配置服务器列表即可

> 为了保持向后兼容性，被用作默认的负载均衡器实现。但是，`Spring Cloud Netflix Ribbon` 现在处于维护模式，因此我们建议改用 `Spring Cloud LoadBalancer`。
> set the value of `spring.cloud.loadbalancer.ribbon.enabled` to `false`.

Spring Cloud 的 Feign 支持的中心概念是指定客户的概念。