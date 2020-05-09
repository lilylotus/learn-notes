#### 1. spring 初始化流程

##### 1.1 初始化代码

```java
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
context.register(ApplicationConfiguration.class);
context.refresh();

final ApplicationBean bean = context.getBean(ApplicationBean.class);
System.out.println(bean);
```

##### 1.2 注册配置类

```java
context.register(ApplicationConfiguration.class);
```

完成 `org.springframework.context.annotation.AnnotatedBeanDefinitionReader` *bean* 的注册。
`AnnotatedGenericBeanDefinition` 注解默认的 *bean* 定义。

1. 解析是否有 `org.springframework.context.annotation.Conditional` 情况注解。

   若是配置有，直接返回，稍后处理。

2. 处理 `@Scope` 注解，默认为 *singleton* 单例模式，没有代理

3. 获取 *bean* 的名称，若没指定默认为 `BeanNameGenerator` 生成的名称。默认为类首字母小写。

4. 配置是否 *lazy* 初始化，是否有 *dependsOn* 依赖，是否有 *Primary* 注解，等配置

5. `BeanDefinitionHolder` 装载该配置好的 *bean*

6. `org.springframework.beans.factory.support.BeanDefinitionRegistry` 注册该 *bean*

#### 2. spring framework 的 Context 初始化

`org.springframework.context.support.AbstractApplicationContext#refresh`

##### 2.1 初始化 context 准备

```java
org.springframework.context.support.AbstractApplicationContext#prepareRefresh
```

##### 2.2 实例化一个 *bean factory*

```java
org.springframework.context.support.AbstractApplicationContext#obtainFreshBeanFactory
ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();
```

`org.springframework.beans.factory.support.DefaultListableBeanFactory` 默认的 *list* 类型的 *bean* 工厂

##### 2.3 把刚才的 *bean* 工厂准备在 *Context* 中使用

```java
org.springframework.context.support.AbstractApplicationContext#prepareBeanFactory
```

做一些默认的环境配置和默认的 *Bean* 注入

##### 2.4 开始处理 *context* 中子类的 *bean* 工厂

```java
org.springframework.context.support.AbstractApplicationContext#postProcessBeanFactory
```

##### 2.5 调用工厂来处理在上下文 (context) 中注册好的 *bean*

```java
org.springframework.context.support.AbstractApplicationContext#registerBeanPostProcessors
```

做 *bean* 的初始化和元数据配置。

##### 2.6 注册 bean 的处理和解释 bean 的创建

```java
org.springframework.context.support.AbstractApplicationContext#registerBeanPostProcessors
```

##### 2.7 初始化 *Context* 中的信息资源

```java
org.springframework.context.support.AbstractApplicationContext#initMessageSource
```



