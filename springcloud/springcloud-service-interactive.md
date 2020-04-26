#### 1. Spring Cloud 微服务间的通信

##### 1.1  常用通信方式

* <font color="red">RestTemplate</font>
  *Spring* 使用 *rest* 资源的一个对象，交互访问的资源通过 URL 进行识别和定位，每次调用都使用模板方法的设计模式，模板方法依赖于具体接口的调用，从而实现了资源的交互和调用；  交互方法有 30 多种，大多数都是基于 HTTP 的方法，比如：delete()、getForEntity()、getForObject()、put()、headForHeaders()等；
* <font color="red">Feign</font> 
  一个声明式的伪 HTTP 客户端，使得编写 HTTP 客户端更加容易
  只需要创建一个接口，用注解的方式去配置，完成对服务提供方的接口绑定，简化了代码的开发量
  同时，它还具有可拔插的注解特性，而且支持 feign 自定义的注解和 springMvc 的注解(默认)

注意：*RestTemplate*  和 *Feign* 两种通信方式不可共用

##### 1.2 RestTemplate 方式

```java
// 注册一个负载均衡后的 RestTemplate ， Ribbon 的实现负载均衡
@Bean
@LoadBalanced
public RestTemplate restTemplate() {
    return new RestTemplate();
}
// 使用
@Autowired
private RestTemplate restTemplate;
// 一句 service id 来访问
restTemplate.getForObject("http://spring-cloud-service-provider/tag", String.class);
```

##### 1.3 Ribbon LoadBalancerClient 方式

```java
// 注入对象
@Autowired
private LoadBalancerClient loadBalancer;

// 使用 Service id 访问 Eureka 中心该 id 信息
ServiceInstance instance = loadBalancer.choose(PER_SERVICE);
String uri = String.format("http://%s:%s%s", instance.getHost(), instance.getPort(), "/employee/tag");
// 发起访问
RestTemplate restTemplate = new RestTemplate();
String tag = restTemplate.getForObject(uri, String.class);
```

##### 修改轮询策略方法：

```yaml
# 修改 ribbon 负载的策略， 服务名 - ribbon - NFLoadBalancerRuleClassName : 全路径策略类
spring-cloud-service-provider:
  ribbon:
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RoundRobinRule
    # 重试机制
    ConnectTimeout: 250 # Ribbon 连接超时时间
    ReadTimeout: 1000 # Ribbon 数据读取超时时间
    OkToRetryOnAllOperations: true # 是否对所有操作进行重试
    MaxAutoRetriesNextServer: 1 # 切换实例的重试次数
    MaxAutoRetries: 1 # 对当前实例的重试次数
```

##### 1.4 Feign 方式

```java
// Application 启动类添加注解
@EnableFeignClients
@EnableCircuitBreaker // 可选
public class Application {}

// 添加 Feign 接口代理
@FeignClient("spring-cloud-service-provider")
public interface EmployeeClient {
    @RequestMapping(value = "/employee/tag", method = RequestMethod.GET)
    String getTag();
}

// 使用，注入接口
@Autowired
private EmployeeClient employeeClient;

String tag = employeeClient.getTag(); // 直接调用接口方法
```



#### 2. Hystrix 熔断器

##### 2.1 服务降级

```java
// 启动类上添加
@EnableCircuitBreaker

// 在调用 REST 方法上添加， 当请求出错时回调函数
@HystrixCommand(fallbackMethod = "fallbackMethod")
@RequestMapping(path = {"/uri"}, method = RequestMethod.GET)
public String serviceUri() {}

public String fallbackMethod() {
    log.info("EmployeeFeignController -> fallbackMethod");
    return "Fallback response:: No services details available temporarily";
}
```

Fallback 相当于是降级操作. 实现一个 fallback 方法, 当请求后端服务出现异常的时候, 可以使用 fallback 方法返回的值. fallback 方法的返回值一般是设置的默认值或者来自缓存.告知后面的请求服务不可用了，不要再来了。

##### 2.1 请求熔断

当 Hystrix Command 请求后端服务失败数量超过一定比例(默认50%), 断路器会切换到开路状态(Open). 这时所有请求会直接失败而不会发送到后端服务. 断路器保持在开路状态一段时间后(默认5秒), 自动切换到半开路状态(HALF-OPEN).

#### 3. API Gateway 网关配置

##### 3.1 配置

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: service_provider
        uri: lb://spring-cloud-service-provider # lb:// 负载均衡
        predicates:
        - Path=/employee/** # 转发的路径
        filters:
          - PrefixPath=/user # 会在请求前加上该前缀后在请求
          - name: CircuitBreaker
            args:
              name: fetchIngredients # 降级配置
              fallbackUri: /gatewayFallback
```

