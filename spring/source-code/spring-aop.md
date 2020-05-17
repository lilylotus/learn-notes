### Aspect Oriented Programming (面向对象编程)

Aspect-oriented Programming (AOP)  面向切面编程通过提供另一种程序接口的思想了补充 Object-oriented Programming (OOP)  面向对象编程。

`OOP` 中模块化的关键单元是类，而在 `AOP` 中模块化是方面。
Aspect 使关注的模块化(如事务管理)可以跨越过个类型和对象。关注在 `AOP` 文献中被称为“跨领域”关注。

Spring IoC 容器没有依赖于 *AOP*，AOP 对 Spring IoC 进行了补充，以提供功能非常强大的中间件解决方案。

AOP 在 Spring 框架中主要作用于：

- 提供声明式企业服务。此类服务中最重要的是声明式事务管理。
- 让用户实现自定义切面，并用 AOP 补充其对 OOP 的使用。

#### 1. AOP 的概念

首先定义一些主要的 AOP 概念和术语。(concepts and terminology)。 这些并不是 spring 规范规定的。
不幸的是，AOP 术语并不是特别直观。但是，如果使用 Spring 自己的术语，将会更加令人困惑。

- `Aspect`
  涉及多个 classes 的关注点的模块化。在 spring 中有用 `@Aspect` 注解类 和 常规的 schema-based 方式
- `Join point`
  程序执行过程中的一点，如方法的执行或异常的处理。在 Spring AOP 中，join point 代表方法的执行。
- `Advice`
  在连接点处采取的具体操作。通知类型有 *around*，*before*，*after*。
  通知模型作为一个拦截器，在连接点上下维护连接器链。
- `Pointcut`
  匹配连接点的断言。通知与切入点表达式关联，并在与该切入点匹配的任何连接点上运行。
  Spring 使用 AspectJ 切入点表达式语言为默认。
- `Introduction`
  代表类型声明其他方法或字段。
- `Target Object`
  一个或多个切面通知的对象。由称为 *通知对象*。由于 Spring AOP 是使用运行时代理实现的，因此该对象始终是代理对象。
- `AOP Proxy`
  由 AOP 框架创建的对象，用于实现切面的约定。(通知方法的执行等)
  在 Spring Framework 中，AOP 代理是 JDK 动态代理或 CGLIB 代理。
- `Weaving`
  将切面与其他应用程序类型或对象链接以创建通知的对象。
  可以在编译期间完成(使用 AspectJ 编译器)，加载期间，运行期间。
  像其他纯 Java AOP 框架一样，推荐 Spring AOP 在运行时执行编织。

Spring 的通知类型：

- `Before Advice`
  在连接点之前，但是没有能力去阻止执行处理流程到接入点。除非抛出了异常。
- `After Returning Advice`
  在接入点一般完成后通知才执行。(方法返回且没有抛出异常)
- `After throwing advice`
  在一个方法由于抛出异常退出后执行
- `After (finally) Advice`
  无论连接点退出的方式如何，都将执行的建议。(正常或者异常返回)
- `Around advice`
  围绕方法调用的连接点通知。这是这几种通知中最重要的。
  该通知可以在方法 调用之前和完成之后 执行自定义的行为。
  负责选择是返回连接点还是通过返回其自身的返回值或引发异常来拦截通知的方法执行。

围绕通知是最通用的建议。由于 Spring AOP 与 AspectJ 一样，提供了各种通知类型，建议您使用功能最弱的通知类型，以实现所需的行为。

<font color="blue">Spring AOP 是用纯 Java 实现的，不需要特殊的编译过程。</font>
Spring AOP 不需要控制类加载器的层次结构，因此适合在 Servlet 容器或应用程序服务器中使用。

Spring AOP 目前仅支持方法连接点，通知在 spring beans 上执行方法。Field 的拦截未实现。

Spring AOP 的 AOP 方法不同于大多数其它 AOP 框架。目的不是提供最完整的 AOP 实现。(尽管 Spring AOP 非常强大)。相反，其目的是在 AOP 实现和 Spring IoC 之间提供紧密的集成，帮助解决企业应用程序中的常见问题。

过使用常规 bean 定义语法来配置 Aspect。

Spring 无缝地将 Spring AOP 和 IoC 与 AspectJ 集成在一起，基于 Spring 的一致应用程序架构中支持 AOP 的所有使用。

> Spring 框架的中心宗旨之一是非侵入性。
> 这是一个想法，您不应被迫将特定于框架的类和接口引入业务或域模型。
>
> @AspectJ 注解类型 的方法 或者 Spring XML 配置类型 的方法。

#### 2. AOP 的代理

Spring AOP 默认使用标准的 JDK 动态代理在作为 AOP 的代理。
这就允许任意的接口 (或一系列的接口)  来代理。

Spring AOP 任然可以使用 CGLIB 代理，这需要来代理类而不是对象。默认，CGLIB 是用来在当业务对象没有实现接口的时候。很好的实践是使用接口编程而不是类，业务逻辑通常实现一个或多个业务接口。

掌握 Spring AOP 是基于代理的这一事实很重要。

#### 3. `@AspectJ` 的支持

`@AspectJ` 是一种将切面声明为带有注释的常规 Java 类的样式。
但是，AOP 运行时仍然是纯 Spring AOP，并且不依赖于 AspectJ 编译器或编织器。

#### 4. 使用 `@AspectJ` 支持

要在 Spring 配置中使用 `@AspectJ` 切面，需要允许 Spring 支持配置 Spring AOP 基于 `@AspectJ` 切面的 和 自动代理 beans 基于是否通知这些切面。通过自动代理，我们的意思是，如果 Spring 确定一个或多个切面通知使用bean，它会自动为该 bean 生成一个代理，以拦截方法调用，并确保按需执行通知。

`@AspectJ` 支持 XML 或者 Java 类型的配置。无论哪种情况，您都需要确保 AspectJ 的 `AspectJweaver.jar` 库位于应用程序的类路径中。

为了允许使用 `@AspectJ` 的支持同 Java `@Configuration` ， 添加 `@EnableAspectJAutoProxy` 注解

```java
@Configuration
@EnableAspectJAutoProxy
public class AppConfig {}

// 重点是注入了 @Import(AspectJAutoProxyRegistrar.class) 配置
// ImportBeanDefinitionRegistrar 接口
```

XML 配置

```xml
<aop:aspectj-autoproxy/>
```

##### 4.1 确定一个切面 Aspect

```java
@Aspect
public class AspectLearn {}
```

``@Aspect`` 注解的类可以和别的 Java 类一样有字段和方法。
也可以包含 `pointcut`，`advice`， `introduction (inter-type)` 声明。

> 可以注册 aspect 类作为常规的 beans，使用 Spring XML 配置或者自动检测通过 classpath 扫描，和其它任何被 Spring 管理的 bean 一样。
>
> 注意：单单是 `@Aspect` 注解是不够的对于自动探测于 classpath 下，为了达到目的，还需要添加 `@Component` 注解。
>
> 在 Spring AOP 中，切面本身不能成为其它切面的通知目标。 `@Aspect` 注解表示的作为一个切面，因此排除在自动代理之内。

##### 4.2 声明一个切点

<font color="red">Spring AOP 仅支持 Spring Bean 的方法执行连接点，因此，可以将切入点视为与 Spring bean 上的方法执行相匹配的切入点。</font>
<font color="blue">`@Pointcut` 注解作用于 Bean 的方法上，该方法签名必定是 `void` 返回类型</font>

```java
@Pointcut("execution(* transfer(..))") // pointcut 表达式
private void transfer() {} // pointcut 签名
```

支持的切入点指示符

- `execution`
  用于匹配方法执行的连接点。是使用 Spring AOP 时要使用的主要切入点指示符。
- `within`
  限制匹配到某些类型内的连接点，使用 Spring AOP 时在匹配类型内声明的方法的执行
- `this`
  限制匹配的连接点，哪里的 bean 的引用 (Spring AOP proxy)， 是给定类型的实例
- `target`
  目标对象(应用对象已经被代理了) 是一个给定类型的实例
- `args`
  匹配实例给定的类型

Spring AOP 是基于代理的系统，可区分代理对象本身（绑定到此对象）和代理后面的目标对象（绑定到目标）。

<font color="red">由于 Spring的AOP 框架基于代理的性质，因此根据定义，不会拦截目标对象内的调用。对于 JDK 代理，只能拦截代理上的公共接口方法调用。</font>

<font color="blue">使用 CGLIB，可以拦截代理上的公共方法和受保护方法(甚至包可见的方法)。</font>

但是，通常应通过公共签名设计通过代理进行的常见交互。

请注意，切入点定义通常与任何拦截方法匹配。如果严格地将切入点设置为仅公开使用，即使在 CGLIB 代理方案中通过代理可能存在非公开交互，也需要相应地进行定义。

如果您的拦截需要在目标类中包括方法调用甚至构造函数，请考虑使用 Spring 驱动的 *native AspectJ Weaving*，而不是 Spring 的基于代理的 AOP 框架。这构成了具有不同特征的 AOP 使用模式，因此请确保在做出决定之前先熟悉编织。

**pointcut 结合表达式**
`&&` ，`||`，`!`

```java
@Pointcut("execution(public * *(..))")
private void anyPublicOperation() {} 

@Pointcut("within(com.xyz.someapp.trading..*)")
private void inTrading() {} 

@Pointcut("anyPublicOperation() && inTrading()")
private void tradingOperation() {} 
```

常见切入点表达式

```java
	/**
     * A join point is in the web layer if the method is defined
     * in a type in the com.xyz.someapp.web package or any sub-package
     * under that.
     */
@Pointcut("within(com.xyz.someapp.web..*)")

    /**
     * A join point is in the service layer if the method is defined
     * in a type in the com.xyz.someapp.service package or any sub-package
     * under that.
     */
    @Pointcut("within(com.xyz.someapp.service..*)")

/**
 * A business service is the execution of any method defined on a service
 * interface. This definition assumes that interfaces are placed in the
 * "service" package, and that implementation types are in sub-packages.
 *
 * If you group service interfaces by functional area (for example,
 * in packages com.xyz.someapp.abc.service and com.xyz.someapp.def.service) then
 * the pointcut expression "execution(* com.xyz.someapp..service.*.*(..))"
 * could be used instead.
 *
 * Alternatively, you can write the expression using the 'bean'
 * PCD, like so "bean(*Service)". (This assumes that you have
 * named your Spring service beans in a consistent fashion.)
 */
@Pointcut("execution(* com.xyz.someapp..service.*.*(..))")

/**
 * A data access operation is the execution of any method defined on a
 * dao interface. This definition assumes that interfaces are placed in the
 * "dao" package, and that implementation types are in sub-packages.
 */
@Pointcut("execution(* com.xyz.someapp.dao.*.*(..))")
```

```java
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern?name-pattern(param-pattern) throws-pattern?)

returning type pattern，name pattern，parameters pattern 是可选的
```

`*` 表示任意的返回值类型。
*name-pattern* 匹配方法名称。
`()` 匹配没有参数的方法	`(..)` 匹配任意参数的方法	`(*)` 匹配一个任意参数的方法 	
`(*,String)` 匹配两个参数的方法，第一个参数任意，第二个参数为 String 类型

```java
// 任意在 service 包中的类的方法
execution(* com.xyz.service.*.*(..))
// 任意在 service 包及子包中的类的方法
execution(* com.xyz.service..*.*(..))
```

##### 4.3 通知

```java
@Before("execution(* com.xyz.myapp.dao.*.*(..))")
public void doAccessCheck() {}

@AfterReturning(
    pointcut="com.xyz.myapp.SystemArchitecture.dataAccessOperation()",
    returning="retVal")
public void doAccessCheck(Object retVal) {}

@AfterThrowing(
    pointcut="com.xyz.myapp.SystemArchitecture.dataAccessOperation()",
    throwing="ex")
public void doRecoveryActions(DataAccessException ex) {}

@After("com.xyz.myapp.SystemArchitecture.dataAccessOperation()")
public void doReleaseLock() {}

@Around("com.xyz.myapp.SystemArchitecture.businessService()")
public Object doBasicProfiling(ProceedingJoinPoint pjp) throws Throwable {
    // start stopwatch
    Object retVal = pjp.proceed();
    // stop stopwatch
    return retVal;
}
```

`JoinPoint` 接口提供的方法

- `getArgs()`: Returns the method arguments.
- `getThis()`: Returns the proxy object.
- `getTarget()`: Returns the target object.
- `getSignature()`: Returns a description of the method that is being advised.
- `toString()`: Prints a useful description of the method being advised.

---

#### 2. spring aop 源码

重要类

```java
DefaultAopProxyFactory
```

<font color="blue">`BeanPostProcessor` 是工厂钩子接口，允许自定义修改新的 bean 实例，检查标记接口或者用代理在覆盖它们</font>
不是后置处理器
`ApplicationContexts` 能够自动检测在 beans 定义中的 `BeanPostProcessor` bean，在随后的创建 bean 中应用它们。普通的 bean 工厂允许编程式注册 `post-processor`，应用与通过该工厂创建的所有 Bean。

`postProcessBeforeInitialization` 接口方法 `post-processor` 填充 beans
`postProcessAfterInitialization` 接口方法 `post-processor` 代理包装 beans

```
ApplicationContexts can autodetect BeanPostProcessor beans in their
* bean definitions and apply them to any beans subsequently created.
```

```java
实现了 spring Bean 自动代理的 post-processors
处理所有的 AspectJ 注解的切面在当下的 Application Context 中，Spring Advisors 同样。
通过 BeanPostProcessor 接口来处理代理的
AnnotationAwareAspectJAutoProxyCreator -> BeanPostProcessor

AbstractAutoProxyCreator#postProcessAfterInitialization()
AbstractAutoProxyCreator#wrapIfNecessary()
AbstractAutoProxyCreator#createProxy()
ProxyFactory#getProxy()
ProxyCreatorSupport#createAopProxy()
// 具体的创建 AOP 代理
DefaultAopProxyFactory#createAopProxy()
    —> JdkDynamicAopProxy -> 处理接口 aop
    -> ObjenesisCglibAopProxy -> cglib 处理非接口 aop
```

