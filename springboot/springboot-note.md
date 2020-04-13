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