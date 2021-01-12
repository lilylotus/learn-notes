##### 1. `@SpringBootApplication`

*Spring boot* 主要是关于自动配置。然后自动配置是由 *component scanning* 类操作的，查找所有类路径下有 `@Component` 注解的类。还设计扫描 `@Configuration` 注解然后初始化一些额外的 *beans*。
`@SpringBootApplication` 实则是包含了三个功能在一个步骤中：

 	1. `@EnableAutoConfiguration` 允许 自动配置 机制
 	2. `@ComponentScan` 允许扫描 `@Component`
 	3. `@SpringBootConfiguration` 注册额外的 *beans* 在上下文中

##### 2. `@EnableAutoConfiguration`

该注释启用了 *Spring Application Context* 的自动配置，并根据类路径中预定义类的存在来尝试猜测和配置我们可能需要的 *bean*。
自动配置类是常规的 *Spring Configuration bean* 。
它们使用 *SpringFactoriesLoader* 机制定位（针对此类）。
通常，自动配置 bean 是 *`@Conditional` Bean*
最经常使用 `@ConditionalOnClass` 和 `@ConditionalOnMissingBean` 批注

##### 3. `@SpringBootConfiguration`

它指示一个类提供 Spring Boot 应用程序配置。
它可以替代 Spring 的标准 `@Configuration` 批注，以便自动找到配置。
应用程序应该只包含一个 `@SpringBootConfiguration`，大多数惯用的 Spring Boot 应用程序将从 `@SpringBootApplication` 继承它。
这两个注释的主要区别是 `@SpringBootConfiguration` 允许自动定位配置。这对于单元或集成测试特别有用。

##### 4. `@ImportAutoConfiguration`

它仅导入和应用指定的自动配置类。
`@ImportAutoConfiguration` 和 `@EnableAutoConfiguration` 之间的区别是后者尝试配置扫描期间在类路径中找到的 bean，`@ImportAutoConfiguration` 仅运行我们配置在注解中的类。

#####   5. `@AutoConfigureBefore`, `@AutoConfigureAfter`, `@AutoConfigureOrder`

如果想在 自动配置 中确定顺序然而没有了解个个之间的具体联系，可以使用注解 `@AutoConfigureOrder`。
这个注解和 `@Order` 类似，区别在于针对 自动注入 类有特定的排序。

##### 6. 条件注释

###### 6.1 `@ConditionalOnBean` and `@ConditionalOnMissingBean`

这些注释可根据是否存在特定 bean 来包含 bean。
它的 *value* 属性可以用来特定的 *按类型 (by type)* 或者 *按名称 (by name)*。
搜索属性还使我们能够限制在搜索 bean 时应考虑的 ApplicationContext 层次结构。

###### 6.2 `@ConditionalOnClass` and `@ConditionalOnMissingClass`

##### 7. springboot 加载 application.properties 顺序

注意： 可以用 YAML (.yml) 文件替代 application.properties 文件

`SpringApplication` loads properties from `application.properties` files in the following locations and adds them to the Spring `Environment`:

1. A `/config` subdirectory of the current directory
2. The current directory
3. A classpath `/config` package
4. The classpath root

The list is ordered by precedence (properties defined in locations higher in the list override those defined in lower locations).

If you do not like `application.properties` as the configuration file name, you can switch to another file name by specifying a `spring.config.name` environment property. You can also refer to an explicit location by using the `spring.config.location` environment property (which is a comma-separated list of directory locations or file paths)

```
$ java -jar myproject.jar --spring.config.name=myproject

$ java -jar myproject.jar --spring.config.location=classpath:/default.properties,classpath:/override.properties
# 以 classpath:/default.properties 文件为运行配置文件

$ java -jar boot.jar --spring.config.additional-location=classpath:/config/,file:./custom.yml
# 以 classpath:/config/ 目录中的 application.yml 文件为运行配置文件

$ java -jar boot.jar --spring.config.additional-location=file:./custom.yml,classpath:/config/
# 以 file:./custom.yml 文件为运行配置文件

$java -jar spring-boot.jar --spring.config.additional-location=classpath:/custom/,file:./custom.yml
```

<font color="red">注意：</font>如果  `spring.config.location`  包含的是目录（不是文件），必须以 `/` 结尾。
<font color="red">配置路径以相反的顺序搜索，以第一个找的到的 `application.yml` 文件为此次运行的配置文件，若是直接指定配置文件 [`file:./custom.yml`] 那么以该指定的配置文件来运行</font>
默认的配置路径 `classpath:/,classpath:/config/,file:./,file:./config/`. 
查询顺序为：1. `file:./config/`, 2. `file:./`, 3. `classpath:/config/`, 4. `classpath:/`

自定义配置路径使用 `spring.config.additional-location`  时，会添加到默认的配置路径前面，例如：配置了  `classpath:/custom-config/,file:./custom-config/` ，此时搜索路径顺序为 1. `file:./custom-config/`，2. `classpath:/custom-config/`，3. `file:./config/`, 4. `file:./`, 5. `classpath:/config/`, 6. `classpath:/`
<font color="red">注意：</font> `spring:profiles:active` 配置的 `biz` 也为按照搜索路径顺序查找 `application-biz.yml` 文件

##### 8. 日志记录

```properties
logging.file.name=my.log
logging.file.path=/var/log
# -> /var/log/my.log

logging.level.root=warn
logging.level.org.springframework.web=debug
logging.level.org.hibernate=error
```

Depending on your logging system, the following files are loaded:

| Logging System          | Customization                                                |
| :---------------------- | :----------------------------------------------------------- |
| Logback                 | `logback-spring.xml`, `logback-spring.groovy`, `logback.xml`, or `logback.groovy` |
| Log4j2                  | `log4j2-spring.xml` or `log4j2.xml`                          |
| JDK (Java Util Logging) | `logging.properties`                                         |

注意： 推荐使用 `-spring` 变体的日志配置，(`logback-spring.xml` 而不是 `logback.xml`)，使用标准的日志配置，spring 可能不能完全的控制日志的初始化。

---

##### spring boot 文件资源加载

*spring boot* 默认加载`org.springframework.boot.context.config.ConfigFileApplicationListener`

```java
String DEFAULT_SEARCH_LOCATIONS = 
    "classpath:/,classpath:/config/,file:./,file:./config/";
```

`org.springframework.boot.context.config.ConfigFileApplicationListener.Loader#getSearchNames` 加载 *bootstrap* 

```java
if (this.environment.containsProperty(CONFIG_NAME_PROPERTY)) {
    // 得到 bootstrap
    String property = this.environment.getProperty(CONFIG_NAME_PROPERTY);
    return asResolvedSet(property, null);
}

file:./config/bootstrap.properties
```

方式一：

```java
ClassPathResource classPathResource = 
    new ClassPathResource("excleTemplate/test.xlsx");
InputStream inputStream =classPathResource.getInputStream();
```

方式二：

```java
InputStream inputStream = Thread.currentThread().getContextClassLoader().getResourceAsStream("excleTemplate/test.xlsx");
```

方式三：

```java
InputStream inputStream = this.getClass().getResourceAsStream("/excleTemplate/test.xlsx");
```

方式四：

```java
File file = ResourceUtils.getFile("classpath:excleTemplate/test.xlsx");
InputStream inputStream = new FileInputStream(file);
```

前三种方法在开发环境(IDE中)和生产环境(linux部署成jar包)都可以读取到，第四种只有开发环境 时可以读取到，生产环境读取失败。

---

### spring boot 启动

```java
String libsPath = "D:\\coding\\idea\\boot-learn\\build\\libs\\lib";
File libFiles = new File(libsPath);

List<URL> urls = new ArrayList<>(50);
//File[] files = libFiles.listFiles(((file, s) -> s.endsWith(".jar")));
File[] files = libFiles.listFiles();

File classFile = new File("D:\\coding\\idea\\boot-learn\\out\\production\\classes");

assert files != null;
for (File file : files) {
    urls.add(file.toURI().toURL());
}
urls.add(classFile.toURI().toURL());

URLClassLoader classLoader = new URLClassLoader(urls.toArray(new URL[0]), RunDemo.class.getClassLoader());
Thread.currentThread().setContextClassLoader(classLoader);
Class<?> mainClass = Class.forName("cn.nihility.boot.BootLearnApplication", false, classLoader);
Method mainMethod = mainClass.getDeclaredMethod("main", String[].class);
mainMethod.setAccessible(true);
mainMethod.invoke(null, new Object[] { args });
```