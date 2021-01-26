## Spring boot PropertiesLauncher

Spring Boot 启动加载类和配置文件备注。

```cmd
# 指定命令所在目录 xxx/boot-learn 目录
java 
-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8888
-Dloader.path=build/v1/v4.jar,build/v1/v1.jar,build/v2,build/libs/v3,build/libs/lib 
-jar build/libs/boot-learn-0.0.1-SNAPSHOT.jar
```

`loader.path` 是 `org.springframework.boot.loader.PropertiesLauncher` spring boot 启动中指定的配置。指定 spring boot 启动所需 *jar* 包的目录或 *jar* 文件，多个目录使用逗号 *,* 分隔。注意： 在启动包中的 `BOOT-INF/classes,BOOT-INF/lib` 是默认都会被加载的。

启动流程：

1. 获取执行启动命令的根目录，（理解为执行启动命令所在目录）
    查找 `${loader.home}` / `${user.dir}` 启动路径，`org.springframework.boot.loader.util.SystemPropertyUtils#getProperty()`
    
2. 初始化属性变量，配置文件目录 `${loader.config.location}`
    若是没有配置则默认加载配置文件 `${loader.config.name}` 默认为 `loader`

    ```
    file:getHomeDirectory()/loader.properties
    classpath:loader.properties
    classpath:BOOT-INF/classes/loader.properties
    ```

3. 初始化加载路径 `${loader.path}`

4. 创建 *Archive*
    找到 *spring boot* 启动类所在的 *jar* 包。确定是以 *jar* 方式还是以 *war* 方式运行。

---

1. 创建 *classLoader* ，把上面所有的 `${loader.path}` 中的 *jar* 包按顺序加载。
   先添加 `${loader.path}` 中指定 *jar* 包和 *jar* 包所在目录中的所有 *jar*。
   在加载启动 *jar* 中的 `BOOT-INF/lib/` 和 `BOOT-INF/classes/` 目录中的所有 *jar* 和 *class* 文件。
   把所有加载的放到 `LaunchedURLClassLoader` 中加载。

重点： `Thread.currentThread().setContextClassLoader(classLoader);`，把当前线程所在的上下文类加载器设置为加载了配置的 *jar* 路径中所有 *jar* 的 *ClassLoader*。

最后反射启动 *spring boot* 的启动 *main* 类。

```java
public void run() throws Exception {
    Class<?> mainClass = Thread.currentThread().getContextClassLoader()
        .loadClass(this.mainClassName);
    Method mainMethod = mainClass.getDeclaredMethod("main", String[].class);
    mainMethod.invoke(null, new Object[] { this.args });
}
```

