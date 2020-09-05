#### springboot 2.x 测试

可以用 `@SpringBootTest` 替换掉 `@ContextConfiguration` 测试注解

> 如果使用 *Junit4* 还是得加上注解 `@RunWith(SpringRunner.class) ` ，如果是 *Junit5* 那就不需要在添加这些注解，`@ExtendWith(SpringExtension.class)`

默认的 `@SpringBootTest` 不会启动一个服务，可以使用 `@SpringBootTest` 的  `webEnvironment` 属性来添加测试功能。

- `MOCK` 默认，加载一个 *WEB* 的 `ApplicationContext` 和提供一个模拟的 web 环境。当使用此注解时内嵌的服务器并不会启动。当 *classpath* 没有 *web* 环境的时候，会启动一个非 *web* 的 `ApplicationContext` 。可以使用注解 `@AutoConfigureMockMvc` 或者 `@AutoConfigureWebTestClient` 来模拟 *web* 环境。
- `RANDOM_PORT`，加载一个 `WebServerApplicationContext` 然后提供一个真正的 *web* 环境，内嵌的服务器将启动并监听随机的一个端口
- `DEFINED_PORT`，和 `RANDOM_PORT` 功能类似，监听的端口为 `application.yml` 配置的端口或默认端口
- `NONE`，使用 `SpringApplication` 加载 `ApplicationContext` 上下文，不提供任何 *web* 环境。

>如果使用 `@Transactional` 注解，默认会在最后回滚所有操作。当使用了  `RANDOM_PORT` 或者 `DEFINED_PORT` 显示提供了一个真实的 *web* 环境，HTTP 客户端和 SERVER 运行在各自的线程，因此在各自的事务中，不会默认回滚数据。

指定测试运行时配置类使用注解 `@Configuration`，以前使用的是 `@ContextConfiguration(classes=...)`，默认查找注解了  `@SpringBootApplication` 或者  `@SpringBootConfiguration` 的类来作为配置类。

若是想自定义运行时主配置，使用注解 `@TestConfiguration`，不想内嵌的 `@Configuration` 注解，此注解会替换掉应用的主配置。

##### 在模拟环境中进行测试

默认的 `@SpringBootTest` 不会启动服务器，有个 *web* endpoint 想针对 *web* 的终端进行测试。

```java
@SpringBootTest
@AutoConfigureMockMvc
class MockMvcExampleTests {
    @Test
    void exampleTest(@Autowired MockMvc mvc) throws Exception {
        mvc.perform(get("/")).andExpect(status().isOk()).andExpect(content().string("Hello World"));
    }
}
```

> 仅想针对 web 层进行测试，而不想启动完整的 `ApplicationContext`，可以使用注解 `@WebMvcTest`

Alternatively (或者)，可以配置一个 `WebClientTest`

```java
@SpringBootTest
@AutoConfigureWebTestClient
class MockWebTestClientExampleTests {
    @Test
    void exampleTest(@Autowired WebTestClient webClient) {
        webClient.get().uri("/").exchange().expectStatus().isOk().expectBody(String.class).isEqualTo("Hello World");
    }
}
```

##### 在运行的服务器中测试

启动一个完整的服务器，推荐使用 `WebEnvironment.RANDOM_PORT` 随机端口配置

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class RandomPortWebTestClientExampleTests {
    @Test
    void exampleTest(@Autowired WebTestClient webClient) {
        webClient.get().uri("/").exchange().expectStatus().isOk().expectBody(String.class).isEqualTo("Hello World");
    }
}
```

##### Auto-configured Spring `MVC` Tests

仅为了测试 Spring MVC Controllers， `@WebMvcTest` 注解仅会扫描 `@Controller`, `@ControllerAdvice`, `@JsonComponent`, `Converter`, `GenericConverter`, `Filter`, `HandlerInterceptor`, `WebMvcConfigurer` 和 `HandlerMethodArgumentResolver`. 通常 `@Component` beans 不会被处理。

```java
@WebMvcTest(UserVehicleController.class)
class MyControllerTests {
    @Autowired
    private MockMvc mvc;
    @MockBean
    private UserVehicleService userVehicleService;
    @Test
    void testExample() throws Exception {
        given(this.userVehicleService.getVehicleDetails("sboot"))
                .willReturn(new VehicleDetails("Honda", "Civic"));
        this.mvc.perform(get("/sboot/vehicle").accept(MediaType.TEXT_PLAIN))
                .andExpect(status().isOk()).andExpect(content().string("Honda Civic"));
    }
}
```

