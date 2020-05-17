###### 文件上传格式

`multipart/form-data`

###### Servlet 3.1 or later 新特性。

在 `META-INF/services` 路径新建文件 `javax.servlet.ServletContainerInitializer`

`创建要启动的类并实现 javax.servlet.ServletContainerInitializer 接口`
`@HandlesTypes(Class)` 自动加载所有注解中的类，或者是实现了该接口的类

#### 1. 示例

##### 1.1 配置要在 tomcat 启动是自动加载的类

`resources/META-INF/services/javax.servlet.ServletContainerInitializer`

```
cn.nihility.servlet.AppInitializer
```

##### 1.2 该自动加载类实现指定 sevlet3.1 规范接口

`javax.servlet.ServletContainerInitializer` 实现该接口

```java
@HandlesTypes(IAppInitializer.class)
public class AppInitializer implements ServletContainerInitializer {

    @Override
    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
        System.out.println("Servlet3.1 规定 javax.servlet.ServletContainerInitializer 运行起来了");

        List<IAppInitializer> initializers = new LinkedList<>();

        if (null != c) {
            for (Class<?> clazz : c) {
                // 确认该加入的 HandleType 实现类
                if (!clazz.isInterface()
                        && !Modifier.isAbstract(clazz.getModifiers())
                        && IAppInitializer.class.isAssignableFrom(clazz)) {
                    try {
                        initializers.add((IAppInitializer) clazz.newInstance());
                    } catch (InstantiationException | IllegalAccessException e) {
                        throw new ServletException("实例化 IAppInitializer 失败", e);
                    }
                }
            }
        }

        ctx.log(initializers.size() + " 个 IAppInitializer 实现类在 classpath 出没");
        System.out.println(initializers.size() + "个 IAppInitializer 实现类在 classpath 出没");

        if (initializers.isEmpty()) {
            ctx.log("木有找到 cn.nihility.servlet.IAppInitializer");
            System.out.println("木有找到 cn.nihility.servlet.IAppInitializer");
        } else {
            initializers.forEach(i -> {
                try {
                    i.onAppStartup(ctx);
                } catch (ServletException e) {
                    System.out.println("带起 " + i.getClass().getName() + " 失败");
                    e.printStackTrace();
                }
            });
        }

    }
}
```

*注意：* `@HandlesTypes` 注解为自动查找该接口的实现类或者是指定类放到 *onStartup* 注入 *Class* 集合中

```java
// 稍后 tomcat 会自动加载实现了该接口的类， 注意接口方法参数
public interface IAppInitializer {
    void onAppStartup(ServletContext servletContext) throws ServletException;
}
```

