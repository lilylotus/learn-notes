Feign 是声明性 Web 服务客户端
Spring Cloud 集成了 Ribbon 和 Eureka 以及 Spring Cloud LoadBalancer，以在使用 Feign 时提供负载平衡的 http 客户端。

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
@EnableFeignClients // 启动 Feign
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

`@FeignClient` 注解中的 *名称* (stores) 是任意的客户端名称，用来创建 `Ribbon` 负载平衡器，或者 `Spring Cloud LoadBalancer`。
上面的负载平衡器客户端将希望发现 *stores* 服务的物理地址。
如果您的应用程序是 Eureka 客户端，则它将在 Eureka 服务注册表中解析该服务。
如果您不想使用 Eureka，则只需在外部配置中配置服务器列表即可

> 为了保持向后兼容性，被用作默认的负载均衡器实现。但是，`Spring Cloud Netflix Ribbon` 现在处于维护模式，因此我们建议改用 `Spring Cloud LoadBalancer`。
> set the value of `spring.cloud.loadbalancer.ribbon.enabled` to `false`.

Spring Cloud 的 Feign 支持的中心概念是指定客户的概念。

##### 1.3 Feign 常用配置

```yaml
feign:
  client:
    config:
      feignName: # 定义 Feign 的名称
      connectTimeout: 5000 # 相当于 Request.Options
      readTimeout: 5000 # 相当于 Request.Options
      loggerLevel: full # 日志级别
      # Feign 错误解码器
      errorDecoder: cn.nihility.feign.SimpleErrorDecoder
      retryer: cn.nihility.feign.SimpleRetryer
      requestInterceptors:
        - cn.nihility.feign.FooRequestInterceptor
        - cn.nihility.feign.BarRequestInterceptor
      decode404: false
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