### spring boot 自动装载机制

> `ImportSelector` 是 spring 导入外部配置的核心接口，在 spring boot 的自动配置和 `@Enablexx` 中起到了决定性的作用。当 `@Configuration` 标注的 *Class* 上使用引入 `@Import` 注解引入一个 `ImportSelector` 接口实现类后，会把类中的 Class 名称定义为 Bean

`DeferredImportSelector` 该接口继承了 `ImportSelector` 接口，和 `ImportSelector` 的区别在于装载 *Bean* 的时机，`DeferedImportSelector`  是在所有的 `@Configuration` 都执行完成后才会进行装载。经常会配合 `DeferredImportSelector` 注解一起使用。

#### 1. spring boot 自动装载机制步骤

##### 1.1 定义一个自动装载配置类

稍后该类会自动的把要添加到 spring 容器的 bean 创建

```java
public class UserConfiguration {
    @Bean
    public User getUser() { return new User("自动装载机制", 20); }
}
// 注意该类没有 spring 自动装载的注解，所有 spring 不会自动配置
```

##### 1.2 实现 `ImportSelector` 的自动装载选择器

spring 会自动找到实现了 `org.springframework.context.annotation.ImportSelector` 接口的类，并执行接口 `selectImports` 方法。

```java
public class UserImportSelector implements ImportSelector {
    /* 根据获取配置自动引入配置类的名称 */
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[] {UserConfiguration.class.getName()};
    }
}
```

##### 1.3 定义自己的 `Enablexx` 注解

到时 spring 会自定去找到 `Import` 的类

```java
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Target(ElementType.TYPE)
// 自动导入要的配置类 selector， 配置该注解到启动类的上面
@Import(UserImportSelector.class)
public @interface EnableUserBean {}
```

##### 1.4 应用实现

```java
@EnableUserBean
public class TestEnableApplication {
    public static void main(String[] args) {
        /**
         * --> EnableUserBean --> 自动 import UserImportSelector
         * --> UserConfiguration --> user
         */
        /* 获取 spring 容器 */
        AnnotationConfigApplicationContext context =
                new AnnotationConfigApplicationContext(TestEnableApplication.class);
        final User user = context.getBean(User.class);
        System.out.println(user);
    }
}
```

##### 1.5 `ImportSelector` 接口在哪里调用

在 `org.springframework.context.annotation.ConfigurationClassParser#processImports` 方法

`SpringFactoriesLoader` 类加载 `META-INF/spring.factories` 中配置的类。