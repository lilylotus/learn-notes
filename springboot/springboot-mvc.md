#### 1. 统一返回格式

实现接口 `org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice`

```java
@RestControllerAdvice
public class ResponseResultBodyAdvice implements ResponseBodyAdvice<Object>, Ordered {

    private static final Logger log = LoggerFactory.getLogger(ResponseResultBodyAdvice.class);
    private static final Class<? extends Annotation> ANNOTATION_TYPE = ResponseResultBody.class;

    /**
     * 对 @ResponseResultBody 注解拦截
     * @return true 采用了 @ResponseResultBody 注解
     */
    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        log.info("ResponseResultBodyAdvice supports [{}]", returnType.getContainingClass());
        return AnnotatedElementUtils.hasAnnotation(returnType.getContainingClass(), ANNOTATION_TYPE)
                || returnType.hasMethodAnnotation(ANNOTATION_TYPE);
    }

    /**
     * 使用了 @ResponseResultBody 注解就转换
     */
    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType, Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request, ServerHttpResponse response) {
        log.info("ResponseResultBodyAdvice beforeBodyWrite [{}]", (body == null ? "空" : body.getClass().getName()));
        if (body instanceof ResultResponse) {
            return body;
        } else if ("text".equals(selectedContentType.getType())) {
            return "{" +
                    "\"apiVersion\"" + ":" + "\"1.0.0\"," +
                    "\"data\"" + ":" + "\"" + body + "\"," +
                    "\"message\"" + ":" + "\"ResponseResultBodyAdvice 统一请求\"" +
                    "}";
        }
        return ResultResponse.success(body);
    }


    @ExceptionHandler(Exception.class)
    public final ResponseEntity<ResultResponse<?>> exceptionHandler(Exception ex, WebRequest request) {
        log.error("ExceptionHandler: {}", ex.getMessage());
        HttpHeaders headers = new HttpHeaders();
        if (ex instanceof ResultException) {
            return this.handleResultException((ResultException) ex, headers, request);
        }
        return this.handleException(ex, headers, request);
    }


    /** 对ResultException类返回返回结果的处理 */
    protected ResponseEntity<ResultResponse<?>> handleResultException(ResultException ex, HttpHeaders headers, WebRequest request) {
        return this.handleExceptionInternal(ex, ResultResponse.failure(ex.getResultStatus()),
                headers, ex.getResultStatus().getHttpStatus(), request);
    }

    /** 异常类的统一处理 */
    protected ResponseEntity<ResultResponse<?>> handleException(Exception ex, HttpHeaders headers, WebRequest request) {
        return this.handleExceptionInternal(ex, ResultResponse.failure(ex.getMessage()),
                headers, HttpStatus.INTERNAL_SERVER_ERROR, request);
    }

    /**
     * org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler#handleExceptionInternal(java.lang.Exception, java.lang.Object, org.springframework.http.HttpHeaders, org.springframework.http.HttpStatus, org.springframework.web.context.request.WebRequest)
     * <p>
     * A single place to customize the response body of all exception types.
     * <p>The default implementation sets the {@link WebUtils#ERROR_EXCEPTION_ATTRIBUTE}
     * request attribute and creates a {@link ResponseEntity} from the given
     * body, headers, and status.
     */
    protected ResponseEntity<ResultResponse<?>> handleExceptionInternal(
            Exception ex, ResultResponse<?> body, HttpHeaders headers, HttpStatus status, WebRequest request) {
        if (HttpStatus.INTERNAL_SERVER_ERROR.equals(status)) {
            request.setAttribute(WebUtils.ERROR_EXCEPTION_ATTRIBUTE, ex, WebRequest.SCOPE_REQUEST);
        }
        return new ResponseEntity<>(body, headers, status);
    }
    
	/** 优先级越高，在多个统一返回的时候内容在越里层 */
    @Override
    public int getOrder() {
        return HIGHEST_PRECEDENCE + 10;
    }
}
```

#### 获取请求 headers

使用 `org.springframework.web.bind.annotation.RequestHeader` 方法参数注解获取所有 *headers*，该情况每个 header 中仅有一个值。

```java
@RequestMapping("/headers")
public Map<String, String> headers(@RequestHeader Map<String, String> headers) { }
```

若是一个请求有多个值，`org.springframework.util.MultiValueMap` map 来接收，获取的 value 是 List。

```java
@RequestMapping("/headers")
public Map<String, String> headers(@RequestHeader MultiValueMap<String, String> headers) { }
```

直接使用 `org.springframework.http.HttpHeaders` 接收所有的 Header 参数。

```java
@GetMapping("/httpHeaders")
public Map<String, String> httpHeaders(@RequestHeader HttpHeaders headers) { }
```

---

#### Spring MVC + Servlet 3.0(+) 标准

是以 *war* 方式部署在 *tomcat* 等 *servlet 3.0+*  容器时才按此方式初始化，`SpringServletContainerInitializer`。当以 *jar* 包的方式部署时就不是采用这种方式处理 *servlet* 容器初始化。

##### servlet 3.0+ / spring mvc

`javax.servlet.ServletContainerInitializer` 接口设计类支持基于代码的 *servlet* 容器配置，*spring* 正是基于该规范，只不过和传统的不同，而是基于自己的 `SPI` `WebApplicationInitializer` 来接管处理容器初始化。

`ServletContainerInitializers (SCIs)` 通过入口文件 `META-INF/services/javax.servlet.ServletContainerInitializer` 被注册。*servlet* 容器在启动时会默认读取该文件内容(实现了 `ServletContainerInitializer` 接口的类全名)，进行容器的初始化。该文件必须存在于 *jar* 文件中，并包含了 *SCI* 的实现。

```java
@HandlesTypes(WebApplicationInitializer.class)
public class SpringServletContainerInitializer implements ServletContainerInitializer { }
// 该配置会加载所有实现了 WebApplicationInitializer 接口的类
```

*spring boot web* 中 `org.springframework.web.SpringServletContainerInitializer` 实现了 `javax.servlet.ServletContainerInitializer` 的接口，负责加载 *servlet* 容器规定的容器资源，但是本身不会处理这些资源，而是代理转给具体的 `org.springframework.web.WebApplicationInitializer` 接口实现类来执行处理资源。

`SpringServletContainerInitializer` 这个类将会在任意实现了兼容 *servlet 3.0* 的容器启动期间被加载和实例化然后它的 `onStartup` 方法会被调用，前提是假设 *spring-web* 模块的 *JAR* 存在于 *classpath* 路径中。通过 *JAR Services API* `ServiceLoader#load(Class)` 方法检测 *spring-web* 模块的 `META-INF/services/javax.servlet.ServletContainerInitializer` 服务配置文件。

`WebApplicationInitializer#onStartup(ServletContext)` 有意和 `ServletContainerInitializer#onStartup(Set, ServletContext)` 方法相似。`SpringServletContainerInitializer` 负责实例化和代理 *ServletContext* 给任何用户定义的 `WebApplicationInitializer` 实现类。然后每个 `WebApplicationInitializer` 的职责就是做初始化 *ServletContext* 的真正工作。

<font color="red">注意：</font>由于 `WebApplicationInitializer` 来真正的处理 `servletContext` 的初始化工作，换句话说，任何的 *servlet*，*listener*，或者 *filter* 都因该被一个 `WebApplicationInitializer` 注册，而不仅仅是 *Spring MVC*  特殊的组件。

##### WebApplicationInitializer 接口

接口被实现在 *Servlet 3.0+* 的环境目的为了编程化的配置 `ServletContext`，相对于传统的 *web.xml* 配置方式。

实现了 *SPI* 的会被 `SpringServletContainerInitializer` 自动检测到，它自己会被任意的 *servlet 3.0* 容器启动。

```java
// org.springframework.web.WebApplicationInitializer#onStartup 中的实现
@Override
public void onStartup(ServletContext servletContext) throws ServletException {
    // Create the 'root' Spring application context
    AnnotationConfigWebApplicationContext rootContext =
        new AnnotationConfigWebApplicationContext();
    rootContext.register(ApplicationStarter.class);

    // Manage the lifecycle of the root application context
    servletContext.addListener(new ContextLoaderListener(rootContext));

    // Create the dispatcher servlet's Spring application context
    AnnotationConfigWebApplicationContext dispatcherContext =
        new AnnotationConfigWebApplicationContext();
    dispatcherContext.register(ApplicationStarter.class);

    // Register and map the dispatcher servlet
    ServletRegistration.Dynamic dispatcher =
        servletContext.addServlet("dispatcher", new DispatcherServlet(dispatcherContext));
    dispatcher.setLoadOnStartup(1);
    dispatcher.addMapping("/");
}
```

 <font color="red">关键类:</font> `org.springframework.web.servlet.support.AbstractDispatcherServletInitializer`，`org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer`，`org.springframework.web.context.support.AnnotationConfigWebApplicationContext`，`ConfigurableWebApplicationContext`

*dispatcher* 配置实现常继承 `AbstractAnnotationConfigDispatcherServletInitializer` （抽象类）

谨记，`WebApplicationInitializer` 实现会被自动加载，所以你可以以你觉得合适的方式自由的对它们进行打包。

注意： `WEB-INF/web.xml` 和 `WebApplicationInitializer` 并没有彼此排除。`web.xml` 可以注册一个 *servlet*，而 `WebApplicationInitializer` 也可以注册一个 *servlet*。`WEB-INF/web.xml` 存在时，其中的 *version* 属性必须设置为 *3.0* 或其以上，否则 `ServletContainerInitializer` 引导程序将会被 *servlet* 容器忽略。

#### spring boot run

创建一个 `SpringApplication` 实例，在执行 *run* 方法。

创建实例步骤：

1. 判断当前运行环境，NONE, SERVLET, REACTIVE
2. 加载初始化 spring boot 预定义的所有 `ApplicationContextInitializer` 实现
3. 加载初始化 spring boot 预定义的所有 `ApplicationListener` 实现
4. 指定启动类

`SpringFactoriesLoader`  会加载解析所有 *classpath* 下 `META-INF/spring.factories` 配置内容，大都配置在 *spring-boot-autoconfiguration* 和 *spring-boot* 和 *spring-boot-beans* 模块下。

`org.springframework.boot.SpringApplication#getSpringFactoriesInstances(java.lang.Class<T>)`

运行 *run* 步骤：

1. 加载初始化 spring boot 预定义的所有 `SpringApplicationRunListener` 实现
2. 依据当前运行环境创建标准运行环境 `StandardEnvironment`/`StandardServletEnvironment`/`StandardReactiveWebEnvironment`
   按照 *profiles* 处理环境变量。
3. 加载 `Banner` 标识，默认位置在资源根 `banner.txt` 文件定义
4. 依据运行的环境创建对应的 `ApplicationContext`
   `SERVLET` -> `AnnotationConfigServletWebServerApplicationContext`
   `REACTIVE` -> `AnnotationConfigReactiveWebServerApplicationContext`
   默认 -> `AnnotationConfigApplicationContext`
5. 加载初始化 spring boot 预定义的所有 `SpringBootExceptionReporter`
6. 准备 *Context* 环境，联合 Context/Environment/Listener
7. 调用 `org.springframework.context.support.AbstractApplicationContext#refresh` 更新和初始化环境 <font color="red">重点</font>
8. 启动所有 *Listener*  和按配置环境 (environment) 和 参数 运行环境

#### web server 容器加载

`ServletWebServerApplicationContext#onRefresh`
`ServletWebServerApplicationContext#createWebServer`

1. 向 spring boot 容器中获取 `ServletWebServerFactory`  实例，不同的环境 *servlet* 容器不同
   *tomcat* -> `org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory`
   *undertow* -> `UndertowServletWebServerFactory`
2. *ServletContext* 上下文初始化
   检查是否有 *WebApplicationContext.ROOT* context 上下文环境变量，决定是否采用内嵌的 tomcat
   准备 *web* 应用的 context
   注册 context 到 spring 容器 *application* 的 `scope`
   注册环境
   *servlet* 容器启动调用 `ServletContextInitializer`  接口的 `onStartup` 方法

