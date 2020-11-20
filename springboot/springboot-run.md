### Spring Boot Jar 包启动执行

* 所需依赖，Spring Boot 会以自己实现的打包方式，可执行的 Jar 包
    ```groovy
    implementation 'org.springframework.boot:spring-boot-loader'
    ```
    
* 大体实现代码逻辑

```java
// urls 为 spring boot 依赖的 jar 包和自己的 class 路径
URLClassLoader classLoader = new URLClassLoader(urls.toArray(new URL[0]), null);
// 把当前线程的 ClassLoader 上下文配置为自定的实现
Thread.currentThread().setContextClassLoader(classLoader);
Class<?> mainClass = Class.forName("test.BootLearnApplication", false, classLoader);
Method mainMethod = mainClass.getDeclaredMethod("main", String[].class);
mainMethod.setAccessible(true);
// main 为 static 方法，不需要具体的实体类实例
mainMethod.invoke(null, new Object[] { args });
```