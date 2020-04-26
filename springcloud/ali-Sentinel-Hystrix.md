#### 1. 服务熔断的替代， 阿里 Sentinel

官网链接：https://github.com/alibaba/Sentinel

##### 1.1 运行控制平台

```bash
java -Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dproject.name=sentinel-dashboard -jar sentinel.jar
```

默认的用户名和密码都是 `sentinel`

##### 1.2 引入依赖

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
</dependency>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>2.2.0.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

##### 1.3 配置

```yaml
spring:
  cloud:
    sentinel:
      transport:
        dashboard: localhost:8080
```

默认 *sentinel* 采用懒加载的模式，在客户端首次调用的时候进行初始化，开始向控制台发送心跳包

```yaml
sentinel.eager=true # 取消懒加载
```

##### 1.4 通用资源保护

适用于 `RestTemplate` 方式处理

定义 Sentinel 降级逻辑

```java
// 熔断降级执行方法
public Employee serviceBlockHandler(Integer id) {
    return new Employee(0, "Sentinel RestTemplate 熔断降级",
                        "Sentinel RestTemplate 熔断降级", "Sentinel RestTemplate 熔断降级");
}
// 抛出异常执行降级方法
public Employee serviceFallBack(Integer id) {
    return new Employee(0, "Sentinel RestTemplate 异常降级",
                        "Sentinel RestTemplate 异常降级", "Sentinel RestTemplate 异常降级");
}
```

处理降级

```java
// blockHandler: 熔断降级的调用方法
// fallback: 抛出异常的降级方法
// value: 加载本地自定义的资源
@SentinelResource(value = "getEmployeeById", blockHandler = "serviceBlockHandler", fallback = "serviceFallBack")
@RequestMapping(value = "/{id}", method = RequestMethod.GET)
public Employee getEmployeeById(@PathVariable("id") Integer id) {}
```

##### 1.5 本地资源配置

```yaml
spring:
  cloud:
    sentinel:
      transport:
        dashboard: localhost:8080
      datasource:
        ds1:
          file:
            file: classpath:flowrule.json
            datatype: json
            rule-type: flow
      eager: true # 关闭懒加载
```

资源文件

```json
[
  {
    "resource": "getEmployeeById",
    "controlBehavior": 0,
    "count": 1,
    "grade": 1,
    "limitApp": "default",
    "strategy": 0
  }
]
```

##### 1.6 RestTemplate 支持

统一配置

```java
public class ExceptionUtils {

    private static final Logger log = LoggerFactory.getLogger(ExceptionUtils.class);

    public static SentinelClientHttpResponse handleFallBack(HttpRequest request, byte[] body,
                                                                ClientHttpRequestExecution execution,
                                                                BlockException ex) {
        log.error("ExceptionUtils -> handleBlockHandler 熔断异常降级", ex);
        return new SentinelClientHttpResponse("handleBlockHandler 熔断异常降级");
    }

    public static SentinelClientHttpResponse handleBlockHandler(HttpRequest request, byte[] body,
                                                                ClientHttpRequestExecution execution,
                                                                BlockException ex) {
        log.error("ExceptionUtils -> handleBlockHandler 熔断限流降级", ex);
        return new SentinelClientHttpResponse("handleBlockHandler 熔断限流降级");
    }

}

// 在 RestTemplate 处理
@Bean
@LoadBalanced
@SentinelRestTemplate(fallbackClass = ExceptionUtils.class, fallback = "handleFallBack",
                      blockHandlerClass = ExceptionUtils.class, blockHandler = "handleBlockHandler")
public RestTemplate restTemplate() {
    return new RestTemplate();
}
```

##### 1.7 Feign的支持

```yaml
# 启用支持
feign:
  sentinel:
    enabled: true
```

其它的和 Hystrix 对 Feign 的支持一致

**注意：** sentinel 版本支持 spring cloud `Hoxton.SR1`

```xml
<spring-cloud-alibaba.version>2.2.0.RELEASE</spring-cloud-alibaba.version>
<spring-cloud.version>Hoxton.SR1</spring-cloud.version>
```

