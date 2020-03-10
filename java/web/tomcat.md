##### 基本知识

Web 过滤器 ： 在WEB容器启动时侯就加载
流程：用户请求 -> 过滤器将用户请求发送给 Web 资源 -> 资源响应发送至过滤器
 -> 过滤器将 Web 资源的响应发送给用户

过滤器的生命周期
	实例化(web.xml) -> 执行一次
	初始化(init())  	  -> 执行一次
	过滤(doFilter())    -> 执行n次
	销毁(destroy())     -> 执行一次

Web 过滤器实现了 Filter 的接口

1. init() 方法，过滤器的初始化方法，Web 容器创建过滤器实例后将调用此方法可以从 web.xml 中过滤容器的参数
2. doFilter() 方法， 此方法完成实际的过滤操作(过滤器的核心放方法).
   当用户请求访问与过滤器关联的 URL 时，Web 容器先调用过滤器的 doFilter 方法
   FilterChain 参数可以调用 chain.doFilter 方法，将请求传给下一个过滤器(或目标资源)
   可转发、重定向将请求转发到其它资源
3. destroy() 方法

**注意：**filter 仅一个， filter mapping 可以多个对应一个 filter
可以声明多个过滤器
用户请求    -> 过滤器1 ->  过滤器2    ->  过滤器3    -> web资源
当多个过滤器的 url-pattern 对应一个过滤器时，会形成过滤器链，
会按照 web.xml 中过滤器的定义先后组装成一条链
过滤器会有放行方法 doFilter  顺序为  : 过滤前的代码 -> doFilter 过滤方法 -> 过滤后的代码

*过滤器的应用：*

 	1. 对用户的请求进行统一的认证
 	2. 编码转换
 	3. 对用户的发送数据进行过滤替换
 	4. 转换图片格式
 	5. 对响应的内容进行压缩 

---

##### 拦截器

*web.xml* 中各个元素的执行顺序：`context-param-->listener-->filter-->servlet`
拦截器是在 `Spring MVC` 中配置，从整个项目中看，一个 servlet 请求的执行过程就变成
`context-param-->listener-->filter-->servlet-->interceptor(指的是拦截器)`
为什么拦截器是在 servlet 执行之后，因为拦截器本身就是在 servlet 内部的

###### 基本概念

***context-param***
一些需要初始化的配置，放入 context-param 中，从而被监听，这里特指 `org.springframework.web.context.ContextLoaderListener` 监听，然后加载

***监听器 (listener)***
对项目起到监听的作用，它能感知到包括 request (请求域)，session (会话域)和 applicaiton(应用程序)的初始化和属性的变化

***过滤器(filter)***  对请求起到过滤的作用
它在监听器之后，作用在 servlet 之前，对请求进行过滤

***servlet***  对 request 和 response 进行处理的容器，它在 filter 之后执行
servlet 其中的一部分就是 controller 层（标记为servlet_2），
还包括渲染视图层(标记为 servlet_3)和进入 ontroller 之前系统的一些处理部分(servlet_1)另外我们把 servlet 开始的时刻标记为 servlet_0，servlet 结束的时刻标记为 servlet_4
servlet0(开始) -> servlet1 -> servlet2 -> servlet3 -> servlet4

***拦截器(interceptor)***
就是对请求和返回进行拦截，它作用在 servlet 的内部，具体来说有三个地方

       1. servlet_1 和 servlet_2 之间，即请求还没有到 controller 层
       2. servlet_2 和 servlet_3 之间，即请求走出 controller 层次，还没有到渲染时图层
       3. servlet_3 和 servlet_4 之间，即结束视图渲染，但是还没有到 servlet 的结束



###### 使用原则

对整个流程清楚之后，然后就是各自的使用，在使用之前应该有一个使用规则，
因为有些功能比如判断用户是否登录，既可以用过滤器，也可以用拦截器，
用哪一个才是合理的呢？那么如果有一个原则，使用起来就会更加合理。

把整个项目的流程比作一条河，
**监听器**的作用就是能够听到河流里的所有声音，
**过滤器**就是能够过滤出其中的鱼，
**拦截器**则是拦截其中的部分鱼，并且作标记。

当需要监听到项目中的一些信息，并且不需要对流程做更改时，用监听器；
当需要过滤掉其中的部分信息，只留一部分时，就用过滤器；
当需要对其流程进行更改，做相关的记录时用拦截器。

---

##### 监听器

`context-param -> listener -> filter -> servlet`
Servlet 监听器, 一个 web.xml 下可以有多个监听器，监听器的启动顺序和注册顺序一致
启动的优先级为 ：context-param -> 监听器 -> 过滤器 -> Servlet

###### 监听器的分类

1. 按监听的对象划分

   - 监听应用程序环境对象 `ServletContext` 的事件监听器
   - 监听用户会话的对象 (`HttpSession`) 的事件监听器
   - 监听请求消息对象的 (`ServletRequest`) 的事件监听器

2. 按监听的事件划分

   - 监听域对象自身的创建和销毁的事件监听器
     `ServletContext -> ServletContextListener`
     (主要用途 1. 全局属性对象 2. 定时器 3. 数据库初始)
     `HttpSession -> HttpSessionListener`
     (主要用途 1. 统计在线人数 2. 记录访问日志)
     一个 web 项目仅有一个 HttpSession，可有多个 HttpSessionListener
     方法传入的参数 HttpSessionEvent 可以获取当前创建的 HttpSession 对象
     `ServletRequest -> ServletRequestListener`
     (主要用途 1. 读取参数 2. 记录访问历史)
     一个 web 项目仅有一个 ServletRequest，可有多个 ServletRequestListener
     方法传入的参数 ServletRequestEvent 可以获取当前的 Request 对象
     获取 ServletContext 对象， 获取 ServletRequest 对象
     可以监听到用户的每一次请求

   - 监听域对象中的属性的增加和删除的事件监听器
     `每个中都定义的三个方法 1. attributeAdded 2. attributeRemoved 3. attributeReplaced 来管理`

     ```java
     ServletContext -> ServletContextAttributeListener
     request.setAttribute("requestAttr", "Request Attribute Value");
     
     HttpSession -> HttpSessionAttributeListener
     request.getSession().setAttribute("sessionAttr", "Session Attribute Value");
                     
     ServletRequest -> ServletRequestAttributeListener
     request.getServletContext().setAttribute("servletContextAttr", "servletContext Attribute Value");
     ```

3. 监听绑定到 `HttpSession` 域中的某个对象状态的事件监听器 
   (不需要在 web.xml 中注册 Listener)
   绑定  -> 解除绑定，`HttpSessionBindingListener`
   valueBound  绑定
   valueUnbound 解除绑定 

   钝化(将对象存储的物理介质)  ->  活化(从物理介质加载到内存) (必须实现 Serializable)
   `HttpSessionActivationListener`
   sessionWillPassivate    钝化
   sessionDidActivate  活化  

---

##### web.xml

```xml
version : apache-tomcat-7.0.94
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
                      http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
                      version="3.0">

version : apache-tomcat-8.0.53
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
                      version="3.1">

version : apache-tomcat-8.5.40
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
                      version="3.1">

version : apache-tomcat-9.0.17
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
                      version="4.0">
```

###### html

```html
<head>
    <meta charset="UTF-8"/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <title>Hello Servlet</title>
    <meta name="keywords" content="Servlet"/>
    <meta name="description" content="Self description"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1, viewport-fit=cover"/>
    <meta name="format-detection" content="telephone=no"/>
</head>

HTML5
<!DOCTYPE html>

HTML 4.01 Strict
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

HTML 4.01 Transitional
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
```

###### servlet

```java
Servlet 3.0
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd" id="WebApp_ID" version="3.0">
</web-app>

Servlet 3.1
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://xmlns.jcp.org/xml/ns/javaee" xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd" id="WebApp_ID" version="3.1">
</web-app>

    =================================

<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path;
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
```

