#### Spring Cloud OpenFeign

OpenFeign 是声明式 web 服务客户端，它使编写 *web service clients* 更加简单。为了使用 *Feign* 创建一个接口然后添加注解。Feign 支持插件化的编码器和解码器。*Spring Cloud* 添加了对 *Spring MVC* 注解的支持，为了使用相同的 `HttpMessageConverters` （在 *Spring WEB* 中默认使用）。

Spring Cloud 集成了 `Ribbon` 和 `Eureka` 以及 `Spring Cloud LoadBalancer`，以在使用 Feign 时提供负载平衡的 http 客户端。

**Ribbon** 是基于 HTTP 和 TCP *客户端* 的负载均衡工具。它可以在客户端配置 *RibbonServerList* (服务端列表)，使用 HttpClient 或者 RestTemplate 模拟 HTTP 请求，步骤想到繁琐。

**Feign** 是在 *Ribbon* 之上的改进，使用起来更加方便的 HTTP 客户端，采用接口的方式，只需要创建一个接口，在上面添加注解即可，将需要调用的其他服务方法定义为抽象的方法即可，不需要自己构建 HTTP 请求。

*Feign* 本身已经集成了 *Ribbon* 依赖和自动配置，因此不需要在额外引入依赖，也不需要注册 *RestTemplate* 对象。

#### 1. Fegin 组件

##### 1.1 导入依赖

```xml
<!-- spring cloud 整合的 OpenFeign -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
    <version>2.2.2.RELEASE</version>
</dependency>
```

```groovy
implementation 'org.springframework.cloud:spring-cloud-starter-openfeign'
```

##### 1.2 Feign 的使用

写一个要调用对方服务的接口

```java
@FeignClient("spring-cloud-service-provider") // 指定要调用微服务的 service id
public interface EmployeeFeignClient {
	// 配置调用的方法接口
    @RequestMapping(value = "/employee/tag", method = RequestMethod.GET)
    String getTag();
    
    @RequestMapping(value = "/employee/{id}", method = RequestMethod.GET)
    Employee getEmployeeById(@PathVariable("id") Integer id);
}
```

```java
@SpringBootApplication
@EnableFeignClients // 启用 Feign 支持
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

使用 Feign 接口

```java
@Autowired // 自动注入 Feign 代理的接口
private EmployeeFeignClient employeeFeignClient;

// 直接调用接口方法，实现了负载均衡
String tag = employeeFeignClient.getTag();
```

`@FeignClient` 注解中的 *名称* (stores) 是任意的客户端名称，用来创建 `Ribbon` 负载平衡器，或者 `Spring Cloud LoadBalancer`。也可以指定 URL 使用 `url` 属性 （绝对值或者 hostname）。这个 bean 的名称在 *application context* 中是接口的全限定名称，指定自己的别名使用 `qualifier` 属性在 `@FeignClient` 注解上。
上面的负载平衡器客户端将希望发现 *stores* 服务的物理地址。如果应用程序是 Eureka 客户端，则它将在 Eureka 服务注册表中解析该服务。
如果您不想使用 Eureka，则只需在外部配置中配置服务器列表即可，通过拓展配置 `simplediscoveryclient`

> 为了保持向后兼容性，被用作默认的负载均衡器实现。但是，`Spring Cloud Netflix Ribbon` 现在处于维护模式，因此我们建议改用 `Spring Cloud LoadBalancer`。
> set the value of `spring.cloud.loadbalancer.ribbon.enabled` to `false`.

Spring Cloud 的 Feign 支持的中心概念是指定客户的概念。

##### 1.3 Feign 常用配置属性

```yaml
feign:
  client:
    config:
      feignName:
        connectTimeout: 5000
        readTimeout: 5000
        loggerLevel: full
        # Feign 错误解码器
        errorDecoder: com.example.SimpleErrorDecoder
        retryer: com.example.SimpleRetryer
        requestInterceptors:
          - com.example.FooRequestInterceptor
          - com.example.BarRequestInterceptor
        decode404: false
        encoder: com.example.SimpleEncoder
        decoder: com.example.SimpleDecoder
        contract: com.example.SimpleContract

---
feign:
  client:
    config:
      # default 配置会在所有的 @FeignClient 中使用
      default:
        connectTimeout: 5000
        readTimeout: 5000
        loggerLevel: basic
```

##### 1.4 Feign 默认复写

*Spring Cloud* 的 Feign 支持的中心概念是指定客户的概念。每个 *Feign* 客户端都是组件装配的一部分，它们协同工作以按需联系远程服务器，组件有一个应用开发者给在 `@FeignClient` 注解中的名称。*Spring Cloud* 创建一个新的配件作为一个 `ApplicationContext` 按需给每个命名客户端使用 `FeignClientsConfiguration`。

*Spring Cloud* 允许完全控制 *feign client*，通过使用添加额外的配置 （在 `FeignClientsConfiguration` 之上），使用注解 `@FeignClient`

```java
@FeignClient(name = "stores", configuration = FooConfiguration.class)
public interface StoreClient { }
```

> `FooConfiguration` 不必添加注解 `@Configuration`，若是有，那么需要注意从所有的 `@ComponentScna` 中排除掉，否则包含该配置将会变为默认的源  `feign.Decoder`, `feign.Encoder`, `feign.Contract` 等。

> `serviceId` 现在已经被弃用，推荐使用 `name`  属性。

`@FeignClient` 注解中 `name` 和 `url` 属性支持占位符。

```java
@FeignClient(name = "${feign.name}", url = "${feign.url}")
public interface StoreClient {}
```

Spring Cloud OpenFeign 默认为 *Feign* 提供以下 bean，（`BeanType` beanName: `ClassName`)

- `Decoder` feignDecoder: `ResponseEntityDecoder` (which wraps a `SpringDecoder`)
- `Encoder` feignEncoder: `SpringEncoder`
- `Logger` feignLogger: `Slf4jLogger`
- `Contract` feignContract: `SpringMvcContract`
- `Feign.Builder` feignBuilder: `HystrixFeign.Builder`
- `Client` feignClient: if Ribbon is in the classpath and is enabled it is a `LoadBalancerFeignClient`, otherwise if Spring Cloud LoadBalancer is in the classpath, `FeignBlockingLoadBalancerClient` is used. If none of them is in the classpath, the default feign client is used. <font color="red">注意</font>
  - `spring-cloud-starter-netflix-ribbon`
  - `spring-cloud-starter-loadbalancer`
  - `spring-cloud-starter-openfeign`

*OkHttpClient* and *ApacheHttpClient* feign clients 都可以使用，具体使用通过配置 `feign.okhttp.enabled` 或者 `feign.httpclient.enabled` 设置为 `true`，需要包含它们在 *classpath*。当然，可以自定义一个 *HTTP Client* 来使用通过提供一个 bean ，任意实现了 `org.apache.http.impl.client.CloseableHttpClient` 当使用 *Apache* 或者 `okhttp3.OkHttpClient` 当使用 *OK HTTP*。

##### 1.5 Feign Hystrix 支持

若是 *Hystrix* 在 *classpath* 和 `feign.hystrix.enabled=true` ，*Feign* 将会把所有的方法用一个断路器（circuit breaker）包装。返回一个 `com.netflix.hystrix.HystrixCommand` 任然是可以的。这使您可以使用反应性模式（通过调用 `.toObservable()` 或 `.observe()` 或异步使用（通过调用 `.queue()` ）。

禁用 *Hystrix*

```java
@Configuration
public class FooConfiguration {
    @Bean
    @Scope("prototype")
    public Feign.Builder feignBuilder() { return Feign.builder(); }
}
```

##### 1.6 Feign Hystrix 回调

Hystrix 支持回退的概念，它们的电路断开或出现错误时执行的默认代码路径。为了允许在给定的 `@FeignClient` 使用回调需配置 `fallback` 属性为实现了 *fallback* 的类名称。你任然需要将声明的实现注册为 *Spirng Bean*。

```java
@FeignClient(name = "hello", fallback = HystrixClientFallback.class)
protected interface HystrixClient {
    @RequestMapping(method = RequestMethod.GET, value = "/hello")
    Hello iFailSometimes();
}

static class HystrixClientFallback implements HystrixClient {
    @Override
    public Hello iFailSometimes() { return new Hello("fallback"); }
}
```

如果需要访问引起回退触发器的原因，可以使用  `@FeignClient` 的属性 `fallbackFactory` 。

```java
@FeignClient(name = "hello", fallbackFactory = HystrixClientFallbackFactory.class)
protected interface HystrixClient {
    @RequestMapping(method = RequestMethod.GET, value = "/hello")
    Hello iFailSometimes();
}

@Component
static class HystrixClientFallbackFactory implements FallbackFactory<HystrixClient> {
    @Override
    public HystrixClient create(Throwable cause) {
        return new HystrixClient() {
            @Override
            public Hello iFailSometimes() {
                return new Hello("fallback; reason was: " + cause.getMessage());
            }
        };
    }
}
```

##### 1.7 feign 接口继承支持

```java
public interface UserService {
    @RequestMapping(method = RequestMethod.GET, value ="/users/{id}")
    User getUser(@PathVariable("id") long id);
}

@RestController
public class UserResource implements UserService {}

@FeignClient("users")
public interface UserClient extends UserService {}
```

##### 1.8 feign request/response 压缩

```properties
feign.compression.request.enabled=true
feign.compression.response.enabled=true
-------
feign.compression.request.enabled=true
feign.compression.request.mime-types=text/xml,application/xml,application/json
feign.compression.request.min-request-size=2048
-------
feign.compression.response.enabled=true
feign.compression.response.useGzipDecoder=true
```

#### 2. 高并发处理

##### 2.1 对并发量大的方法隔离

- 线程池隔离
  给消耗时间的方法调用分配多的线程支持
- 信号量隔离
  请求计数

#### 3. 服务容错

##### 3.1 雪崩效应

微服务构架中，一个请求一般会调用多个服务。
当A服务不可用时 , 导致 B 服务的不可用 , 并将不可用逐渐蔓延到 C , 就发生了微服务中的"雪崩"现象

##### 3.2 服务隔离

##### 3.3 熔断降级

##### 3.4 服务限流