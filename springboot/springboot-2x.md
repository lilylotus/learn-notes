##### Spring boot 测试

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
    <exclusions>
        <exclusion>
            <groupId>org.junit.vintage</groupId>
            <artifactId>junit-vintage-engine</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

`vintage engine` 可以同时使用 *Junit4* 或者 *Junit5* ，如果仅用 *Junit5* 就可以向上面引入 *exclusions* *Junit4*
`org.springframework:spring-test` 或者 `spring-boot-starter-test`

###### 测试 spring boot 应用

`spring boot` 提供了注解 `@SpringBootTest` 来代替标准的 `spring-test` `@ContextConfiguration` 注解。
**注意：** 在使用 *Junit4* 时，不要忽略 `@RunWith(SpringRunner.class)` 注解，否则测试注解会被忽略。
*Junit5* 不需要在添加除了 `@SpringBootTest` 以外的注解

`@ContextConfiguration(classes=…)` 指定那个配置类会被加载

如果测试加有 `@Transactional` ，默认在测试完成之后会自动回滚数据。



###### Junit5

Unless otherwise stated, all core annotations are located in the `org.junit.jupiter.api` package in the `junit-jupiter-api` module.

| Annotation               | Description                                                  |
| :----------------------- | :----------------------------------------------------------- |
| `@Test`                  | Denotes that a method is a test method. Unlike JUnit 4’s `@Test` annotation, this annotation does not declare any attributes, since test extensions in JUnit Jupiter operate based on their own dedicated annotations. Such methods are *inherited* unless they are *overridden*. |
| `@ParameterizedTest`     | Denotes that a method is a [parameterized test](https://junit.org/junit5/docs/current/user-guide/#writing-tests-parameterized-tests). Such methods are *inherited* unless they are *overridden*. |
| `@RepeatedTest`          | Denotes that a method is a test template for a [repeated test](https://junit.org/junit5/docs/current/user-guide/#writing-tests-repeated-tests). Such methods are *inherited* unless they are *overridden*. |
| `@TestFactory`           | Denotes that a method is a test factory for [dynamic tests](https://junit.org/junit5/docs/current/user-guide/#writing-tests-dynamic-tests). Such methods are *inherited* unless they are *overridden*. |
| `@TestTemplate`          | Denotes that a method is a [template for test cases](https://junit.org/junit5/docs/current/user-guide/#writing-tests-test-templates) designed to be invoked multiple times depending on the number of invocation contexts returned by the registered [providers](https://junit.org/junit5/docs/current/user-guide/#extensions-test-templates). Such methods are *inherited* unless they are *overridden*. |
| `@TestMethodOrder`       | Used to configure the [test method execution order](https://junit.org/junit5/docs/current/user-guide/#writing-tests-test-execution-order) for the annotated test class; similar to JUnit 4’s `@FixMethodOrder`. Such annotations are *inherited*. |
| `@TestInstance`          | Used to configure the [test instance lifecycle](https://junit.org/junit5/docs/current/user-guide/#writing-tests-test-instance-lifecycle) for the annotated test class. Such annotations are *inherited*. |
| `@DisplayName`           | Declares a custom [display name](https://junit.org/junit5/docs/current/user-guide/#writing-tests-display-names) for the test class or test method. Such annotations are not *inherited*. |
| `@DisplayNameGeneration` | Declares a custom [display name generator](https://junit.org/junit5/docs/current/user-guide/#writing-tests-display-name-generator) for the test class. Such annotations are *inherited*. |
| `@BeforeEach`            | Denotes that the annotated method should be executed *before* **each** `@Test`, `@RepeatedTest`, `@ParameterizedTest`, or `@TestFactory` method in the current class; analogous to JUnit 4’s `@Before`. Such methods are *inherited* unless they are *overridden*. |
| `@AfterEach`             | Denotes that the annotated method should be executed *after* **each** `@Test`, `@RepeatedTest`, `@ParameterizedTest`, or `@TestFactory` method in the current class; analogous to JUnit 4’s `@After`. Such methods are *inherited* unless they are *overridden*. |
| `@BeforeAll`             | Denotes that the annotated method should be executed *before* **all** `@Test`, `@RepeatedTest`, `@ParameterizedTest`, and `@TestFactory` methods in the current class; analogous to JUnit 4’s `@BeforeClass`. Such methods are *inherited* (unless they are *hidden* or *overridden*) and must be `static` (unless the "per-class" [test instance lifecycle](https://junit.org/junit5/docs/current/user-guide/#writing-tests-test-instance-lifecycle) is used). |
| `@AfterAll`              | Denotes that the annotated method should be executed *after* **all** `@Test`, `@RepeatedTest`, `@ParameterizedTest`, and `@TestFactory` methods in the current class; analogous to JUnit 4’s `@AfterClass`. Such methods are *inherited* (unless they are *hidden* or *overridden*) and must be `static` (unless the "per-class" [test instance lifecycle](https://junit.org/junit5/docs/current/user-guide/#writing-tests-test-instance-lifecycle) is used). |
| `@Nested`                | Denotes that the annotated class is a non-static [nested test class](https://junit.org/junit5/docs/current/user-guide/#writing-tests-nested). `@BeforeAll` and `@AfterAll` methods cannot be used directly in a `@Nested` test class unless the "per-class" [test instance lifecycle](https://junit.org/junit5/docs/current/user-guide/#writing-tests-test-instance-lifecycle) is used. Such annotations are not *inherited*. |
| `@Tag`                   | Used to declare [tags for filtering tests](https://junit.org/junit5/docs/current/user-guide/#writing-tests-tagging-and-filtering), either at the class or method level; analogous to test groups in TestNG or Categories in JUnit 4. Such annotations are *inherited* at the class level but not at the method level. |
| `@Disabled`              | Used to [disable](https://junit.org/junit5/docs/current/user-guide/#writing-tests-disabling) a test class or test method; analogous to JUnit 4’s `@Ignore`. Such annotations are not *inherited*. |
| `@Timeout`               | Used to fail a test, test factory, test template, or lifecycle method if its execution exceeds a given duration. Such annotations are *inherited*. |
| `@ExtendWith`            | Used to [register extensions declaratively](https://junit.org/junit5/docs/current/user-guide/#extensions-registration-declarative). Such annotations are *inherited*. |
| `@RegisterExtension`     | Used to [register extensions programmatically](https://junit.org/junit5/docs/current/user-guide/#extensions-registration-programmatic) via fields. Such fields are *inherited* unless they are *shadowed*. |
| `@TempDir`               | Used to supply a [temporary directory](https://junit.org/junit5/docs/current/user-guide/#writing-tests-built-in-extensions-TempDirectory) via field injection or parameter injection in a lifecycle method or test method; located in the `org.junit.jupiter.api.io` package. |



---

##### Spring Boot

决定运行类型 `org.springframework.boot.WebApplicationType#deduceFromClasspath`
(*SERVER, NONE, REACTIVE*)

加载参数注入所需的类
`org.springframework.core.io.support.SpringFactoriesLoader` 这个时加载 *spring.factories* 中初始化类
`spring-*.jar -> META-INF/spring.factories`  在多个 *jar* 包当中
`org.springframework.context.ApplicationContextInitializer` 这个接口实现来初始化加载参数，回调初始化配置，`org.springframework.context.ConfigurableApplicationContext` 以这个 *context* 类型
`org.springframework.context.ApplicationListener` 添加事件 *Listener* ，实现了此接口

查找 *main* 函数

```java
StackTraceElement[] stackTrace = new RuntimeException().getStackTrace();
if ("main".equals(stackTraceElement.getMethodName())) { // 获取 main 函数执行的类
    return Class.forName(stackTraceElement.getClassName());
}
```

关键方法 `org.springframework.core.io.support.SpringFactoriesLoader#loadSpringFactories`
`org.springframework.boot.SpringApplication#createSpringFactoriesInstances`

获取配置文件

```java
Enumeration<URL> systemResources1 = ClassLoader.getSystemResources("");
if (systemResources1 != null) {
    while (systemResources1.hasMoreElements()) {
        URL url = systemResources1.nextElement();
        System.out.println(url);
    }
}
------------------------------------------------
file:/C:/programming/source/springboot-mvn-20/target/test-classes/
file:/C:/programming/source/springboot-mvn-20/target/classes/
    
-------------------------
spring boot 使用：获取项目中 （包括依赖 jar 包） 的文件，不能以 / 开头。
Enumeration<URL> resourcesUrl = 
    ClassLoader.getSystemResources("META-INF/spring.factories");

------ 获取文件中的 key ：value
file:/C:/Users/clover/.m2/repository/org/springframework/boot/spring-boot-test/2.2.5.RELEASE/spring-boot-test-2.2.5.RELEASE.jar!/META-INF/spring.factories
key[org.springframework.boot.env.EnvironmentPostProcessor]
value[org.springframework.boot.test.web.SpringBootTestRandomPortEnvironmentPostProcessor]

URLConnection urlConnection = url.openConnection();
InputStream inputStream = urlConnection.getInputStream();

Properties properties = new Properties();
properties.load(inputStream);

for (Map.Entry<?, ?> et : properties.entrySet()) {
    System.out.println("key [" + et.getKey() + "] value [" + et.getValue() + "]");
}

if (null != inputStream) {
    inputStream.close();
}
```



---

##### Spring Boot 启动

`META-INF/services/javax.servlet.ServletContainerInitializer` 文件填写自动要加载到 Spring 容器的 Servlet，作为处理话容器。

```java
cn.nihility.app.MyServletContainerInitializer

@HandlesTypes(MyApplicationInitializer.class)
public class MyServletContainerInitializer implements ServletContainerInitializer {
    @Override
    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
        System.out.println("=================== MyServletContainerInitializer ===================");

        if (c != null) {
            c.stream().forEach(clazz -> System.out.println(clazz.getName()));
        }

        System.out.println("=================== register servlet");
        ServletRegistration.Dynamic registration = ctx.addServlet("myServlet", new MyServlet());
        registration.addMapping("/servlet/*");

    }
}
```

以上就是加载自己写的 Servlet 到 Spring 容器，无需添加什么注解。
`javax.servlet.annotation.HandlesTypes` 注解表示要加载的类或者接口，如果是接口，那么所有实现了该接口的类都会被加载到 `onStartUp` 参数 `Set<Class<?>>` 中。
<font color="red">自定义要加载的 Servlet 初始化容器要实现`ServletContainerInitializer`接口</font>
<font color="blue">相当于在 `web.xml` 中添加 `servlet`</font>

###### 加载 *Spring webApp* 初始化容器

> 相当于在 `web.xml` 当中添加的 `ContextListener` 和 `DispatcherServlet`

```java
public class MyWebApplicationInitializer implements WebApplicationInitializer {
    @Override
    public void onStartup(ServletContext servletContext) throws ServletException {
        System.out.println("============================== MyWebApplicationInitializer ==============================");
        // Load Spring web application configuration
        AnnotationConfigWebApplicationContext context =
                new AnnotationConfigWebApplicationContext();
        context.register(ApplicationConfig.class);
        context.refresh();

        // Create and register the DispatcherServlet
        DispatcherServlet dispatcherServlet = new DispatcherServlet(context);
        ServletRegistration.Dynamic registration = servletContext.addServlet("application", dispatcherServlet);
        registration.addMapping("/mvc/*");
        registration.setLoadOnStartup(1);
    }
}
```

<font color="red">*注意：* 要实现接口 `org.springframework.web.WebApplicationInitializer`</font>

`org.springframework.web.context.support.AnnotationConfigWebApplicationContext` 来初始化 *Web* 上下文。