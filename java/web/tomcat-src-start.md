##### Tomcat 源码导入配置

pom.xml -> 参照 pom 文件配置

##### 启动 Tomcat

```
配置启动 Application：
Main Class： org.apache.catalina.startup.Bootstrap

VM Options：
-Dcatalina.home=/home/dandelion/dandelion/programming/source/apache-tomcat-8.5.51-src -Dcatalina.base=/home/dandelion/dandelion/programming/source/apache-tomcat-8.5.51-src -Djava.endorsed.dirs=/home/dandelion/dandelion/programming/source/apache-tomcat-8.5.51-src/endorsed -Djava.io.tmpdir=/home/dandelion/dandelion/programming/source/apache-tomcat-8.5.51-src/temp -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.util.logging.config.file=/home/dandelion/dandelion/programming/source/apache-tomcat-8.5.51-src/conf/logging.properties -Duser.language=en -Duser.region=US -Dfile.encoding=UTF-8

-----
org.apache.catalina.startup.ContextConfig 类添加：
org.apache.catalina.startup.ContextConfig#configureStart 中添加

context.addServletContainerInitializer(new JasperInitializer(), null);
webConfig();
```



---

> war 和 jar 的区别
> jar --- 表示的是依赖关系
> war --- 表示的是一个 web 项目
> `org.apache.catalina.startup.HostConfig#deployApps()` 这个方法是加载 web 文件

```java
// Deploy XML descriptors from configBase
deployDescriptors(configBase, configBase.list());
// Deploy WARs
deployWARs(appBase, filteredAppPaths);
// Deploy expanded folders
deployDirectories(appBase, filteredAppPaths);
```

注意：是异步的区部署应用

```java
for (Future<?> result : results) {
    try {
        result.get();
    } catch (Exception e) {
        log.error(sm.getString(
            "hostConfig.deployWar.threaded.error"), e);
    }
}
```



##### 部署 web 项目在 tomcat 的三种方式

1. 把 web 项目打包为 war 形式，放到 webapp 目录下面

2. 直接 web 项目编译的 class 文件夹放到 webapp 下面，或者 Catania 目录下的添加 Context 节点

3. 在 tomcat 的 config 目录下的 `server.xml` 下添加 web 工程路径

   ```java
   <Host>
   	<Context path="" docBase="myapp" reloadable="false"/>
   </Host>
   ```



让 web 项目支持 `@WebServlet` 注解：

```xml
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1"
         metadata-complete="false">
<!-- web.xml 下的 metadata-complete="false" 配置为 false -->

@WebServlet(urlPatterns = {"/first"}, name = "firstServlet")
public class FirstServlet extends HttpServlet { }
```



<font color="red">Tomcat 是一个 Servlet 容器</font>
<font color="blue">请求流程： Request -> RequestFacade -> servlet.service(request, response); </font>

`org.apache.catalina.connector.RequestFacade` 外观模式
外观模式可以代理多个，代理模式仅可以代理一个。

`org.apache.catalina.Context`  *web.xml* 中 *Context* 配置对应的接口。
一个 *Context* 表示的是一个容器，它代表着一个 *Servlet* 的上下文，同时是一个独立的 *web* 应用在一个 *Catalina* 的 *Servlet* 引擎(*Engine*) 当中。 是一个虚拟的主机。

`Engine -> Host -> Context -> Servlet` 层级结构

```xml
<Engine name="Catalina" defaultHost="localhost">
<Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">
<Context path="/tomcat" docBase="/home/dandelion/tomcat-learn" reloadable="true" />

http://localhost:8080/tomcat/first
tomcat -> 表示的是应用
first -> 表示的一个 Servlet
localhost -> 表示的是主机，Engine，域名 (注意：多个域名映射同一个主机) -> 在对应的虚拟节点当中找应用
```



<font color="red">默认的一个 Servlet，所有的请求线程共享一个 Servlet 实例。若是实现了 `SingleThreadModel` 接口，那么就是每一个请求都有一个 *Servlet* 实例</font>

```
org.apache.catalina.core.StandardPipeline

Engine:
	Pipeline pipeline;
	List<Host>

Host:
	Pipeline pipeline;
	List<Context>

Context:
	Pipeline pipeline;
	List<Wrapper> // Wapper --- Servlet 类
	
Wrapper:
    Pipeline pipeline;
    List<Servlet> servlets // 同一个 Servlet 的实例

使用 pipeline 实现了一个类似的责任链模式。
每一个处理链最后的阀门都是 Tomcat
```

> `org.apache.catalina.core.StandardWrapper` 是 *Tomcat Wrapper* 接口的一个标准的实现
> `protected volatile Servlet instance = null;`
> `protected Stack<Servlet> instancePool = null;`
> 两种存储方式

`org.apache.catalina.core.StandardWrapperValve`  -> `org.apache.catalina.core.StandardWrapperValve#invoke` 方法。

```java
// Allocate a servlet instance to process this request
servlet = wrapper.allocate();

// Create the filter chain for this request
ApplicationFilterChain filterChain =
    ApplicationFilterFactory.createFilterChain(request, wrapper, servlet);

filterChain.doFilter(request.getRequest(), response.getResponse());

request.getRequest() ->
org.apache.catalina.connector.Request#getRequest ->
    public HttpServletRequest getRequest() {
    if (facade == null) {
        facade = new RequestFacade(this);
    }
    if (applicationRequest == null) {
        applicationRequest = facade;
    }
    return applicationRequest;
}
使用的是 RequestFacade 来包装
```



---

##### Tomcat 的获取请求

web.xml 配置

```xml
<Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" URIEncoding="UTF-8"/>
```

> `org.apache.coyote.http11.Http11Protocol` --- BIO (tomcat 8 废弃了)
> `org.apache.coyote.http11.Http11NioProtocol` --- NIO

`org.apache.coyote.AbstractProcessor`