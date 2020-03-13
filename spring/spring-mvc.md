##### Spring MVC 无 xml 配置

pom.xml

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.1.12.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-webmvc</artifactId>
        <version>5.1.12.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>3.1.0</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

`DispatcherServlet` 使用 *Spring* 配置发现请求映射，视图解析，异常处理所需的委托组件
通过 *Java* 的方式配置注册和初始化 `DispatcherServlet`，由 *Servlet* 容器自动检测

```java
public class MyWebApplicationInitializer implements WebApplicationInitializer {

    @Override
    public void onStartup(ServletContext servletCxt) {

        // Load Spring web application configuration
        AnnotationConfigWebApplicationContext ac = new AnnotationConfigWebApplicationContext();
        ac.register(AppConfig.class);
        ac.refresh();

        // Create and register the DispatcherServlet
        DispatcherServlet servlet = new DispatcherServlet(ac);
        ServletRegistration.Dynamic registration = servletCxt.addServlet("app", servlet);
        registration.setLoadOnStartup(1);
        registration.addMapping("/app/*");
    }
}
```

> `AbstractAnnotationConfigDispatcherServletInitializer` 这个接口可以直接使用 *Serlvet API*

<font color="red">为什么 spring 启动会去加载 `MyWebApplicationInitializer` 类？</font>
`javax.servlet.annotation.HandlesTypes` 注解，指定 `ServletContainerInitializer` 可以处理的类型

```java
@HandlesTypes(WebApplicationInitializer.class)
public class SpringServletContainerInitializer implements ServletContainerInitializer { }

这里 Spring 就会自动加载实现了 WebApplicationInitializer 接口的 MyWebApplicationInitializer 类
```

![](C:\programming\dailyRecord\images\spring-init-class.png)

*Spring* 默认会去自动加载这个文件中声明的类，加载到 *Spring* 容器当中
`org.springframework.web.SpringServletContainerInitializer`

```java
@HandlesTypes(MyApplicationInitializer.class)
public class MyServletContainerInitializer implements ServletContainerInitializer {
    @Override
    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
		// 注册自己的 Servlet
        ServletRegistration.Dynamic registration = ctx.addServlet("myServlet", new MyServlet());
        registration.addMapping("/");
    }
}

会自动加载所有实现 MyApplicationInitializer 接口的类
```

**注意：** `addMapping("/")` -> */* 是针对所有的请求都处理， `/mvc` 仅处理以 *mvc* 开头的 url
如： `addMapping("/mvc")` -> 请求 *url* -> *http://localhost:9000/mvc/app/hei*
那么 `controller` 的写法应该把 *mapping* 的 *mvc* 前缀去掉
正确写法 `@RequestMapping(path = {"/app/hei"}, method = RequestMethod.GET)`
`org.springframework.web.util.UrlPathHelper#getPathWithinServletMapping`



###### MVC 配置

```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {
    // Implement configuration methods...
    /*    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        registry.jsp("/", ".jsp");
    }*/

    @Bean
    public InternalResourceViewResolver internalResourceViewResolver() {
        InternalResourceViewResolver viewResolver =
                new InternalResourceViewResolver();

        viewResolver.setPrefix("/");
        viewResolver.setSuffix(".jsp");

        return viewResolver;
    }
}
```

