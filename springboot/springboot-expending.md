## Spring Boot 拓展点

一。创建对象实例
* `org.springframework.context.annotation.ImportSelector`
    由 spring boot 默认创建 bean 对象实例，掌握整个对象生命周期
    注意：要配合注解 `org.springframework.context.annotation.Import` 使用
* `org.springframework.context.annotation.ImportBeanDefinitionRegistrar`
    由用户自定义 bean 的创建方法，创建后的实例对象交由 spring boot 管理
* `org.springframework.beans.factory.FactoryBean`
    用户自定义创建对象实例，实现该接口本身实体也是一个 spring bean 实体
* `org.springframework.context.annotation.Import`
    Import 注解，引入 `ImportBeanDefinitionRegistrar`/`ImportSelector` 实现

二。`资源控制拓展`

* `org.springframework.context.ApplicationContextAware`
    获取 spring 容器中的对象实例
* `org.springframework.web.servlet.config.annotation.WebMvcConfigurer`
    添加/注册自定义 web mvc 支持，如：拦截器等
* `org.springframework.context.annotation.ImportSelector`
    自定义 web 请求拦截器
* `org.springframework.context.ResourceLoaderAware`
    资源加载

### ImportSelector

#### 实现 ImportSelector 接口

```java
public class ImportSelectorStarter implements ImportSelector, ResourceLoaderAware {

    private ResourceLoader resourceLoader;

    @Override
    public void setResourceLoader(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        System.out.println("SelectorImport Start Loading ...");

        Map<String, Object> attributesMap =
                importingClassMetadata.getAnnotationAttributes(ImportSelectorAnnotation.class.getName(), true);
        AnnotationAttributes attributes = AnnotationAttributes.fromMap(attributesMap);

        final List<String> scanPath = Optional.ofNullable(attributes)
                .map(at -> at.getStringArray("value"))
                .map(Arrays::asList)
                .orElse(new ArrayList<>(0));

        final List<String> classNameList = new ArrayList<>(10);
        scanPath.forEach(path -> scanPathClass(path, classNameList));

        System.out.println("SelectorImport Start Loading End");
        return classNameList.toArray(new String[0]);
    }

    private void scanPathClass(String path, List<String> classNameList) {
        System.out.println("Scan class path [" + path + "]");
        ResourcePatternResolver resolver = ResourcePatternUtils.getResourcePatternResolver(resourceLoader);
        CachingMetadataReaderFactory readerFactory = new CachingMetadataReaderFactory(resourceLoader);

        // "classpath*:your/package/name/**/*.class" ： dir 目录及其子目录下
        // dir/*/*.class ：dir 目录的子目录下
        // dir/*.class  ： dir 目录下
        String location = "classpath*:" + path.replace(".", "/") + "/**/*.class";
        System.out.println("location [" + location + "]");

        try {
            Resource[] resources = resolver.getResources(location);
            for (Resource resource : resources) {
                MetadataReader metadata = readerFactory.getMetadataReader(resource);
                String className = metadata.getClassMetadata().getClassName();
                System.out.println("Scan class name [" + className + "]");
                classNameList.add(className);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println("Scan class over");
    }
}
```

#### Import 注解使用，和常见的 Enablexxx 注解类似

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Import({ImportSelectorStarter.class})
@Inherited
@Documented
public @interface ImportSelectorAnnotation {
    /* 扫描的包 */
    String[] value() default {};
}
```

#### 添加使用注解的配置类

```java
@ImportSelectorAnnotation({"cn.nihility.selector2.scan",
                           "cn.nihility.selector2.entity"})
public class ImportSelectorStarterConfig { }
```

#### spring 容器加载配置

添加到 `META-INF/spring.factories` spring boot 配置加载文件

```
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
  cn.nihility.selector2.ImportSelectorStarterConfig
```

### ImportBeanDefinitionRegistrar

#### 实现 ImportBeanDefinitionRegistrar 接口

```java
public class ImportBeanDefinitionRegistrarStarter implements ImportBeanDefinitionRegistrar, ResourceLoaderAware {
    private ResourceLoader resourceLoader;
    private int index = 0;

    @Override
    public void setResourceLoader(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    @Override
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        System.out.println("RegisterBeanDefinitions starting.");
        Map<String, Object> attributesMap =
                importingClassMetadata.getAnnotationAttributes(RegistrarAnnotation.class.getName(), true);
        AnnotationAttributes attributes = AnnotationAttributes.fromMap(attributesMap);

        List<String> scanList = Optional.ofNullable(attributes)
                .map(at -> at.getStringArray("value"))
                .map(Arrays::asList)
                .orElse(new ArrayList<>(0));
        System.out.println("Scan " + scanList);

        final List<String> classNameList = new ArrayList<>(10);
        scanList.forEach(path -> findResources(path, classNameList));
        classNameList.forEach(clazz -> registryBean(registry, clazz));

        System.out.println("RegisterBeanDefinitions over.");

        /*BeanDefinitionBuilder builder = BeanDefinitionBuilder.genericBeanDefinition(MyFactoryBeanAdapt.class);
        GenericBeanDefinition beanDefinition = (GenericBeanDefinition) builder.getBeanDefinition();
        beanDefinition.getConstructorArgumentValues().addGenericArgumentValue(UserMapper.class);
        //走public构造器(且要求参数最多的且参数是在spring容器中)
        beanDefinition.setAutowireMode(AbstractBeanDefinition.AUTOWIRE_BY_TYPE);

        registry.registerBeanDefinition("userMapper", beanDefinition);*/
    }

    private void registryBean(BeanDefinitionRegistry registry, String clazzFullName) {
        System.out.println("registry class [" + clazzFullName + "]");

        BeanDefinitionBuilder builder = BeanDefinitionBuilder.genericBeanDefinition(FactoryBeanStarter.class);
        //builder.addPropertyValue("mapperInterface", clazzFullName);

        GenericBeanDefinition beanDefinition = (GenericBeanDefinition) builder.getBeanDefinition();
        /* 要有对应的 getter/setter 方法 */
        //beanDefinition.getPropertyValues().add("mapperInterface", clazzFullName);
        beanDefinition.getConstructorArgumentValues().addGenericArgumentValue(clazzFullName);
        beanDefinition.setAutowireMode(AbstractBeanDefinition.AUTOWIRE_BY_TYPE);

        /*GenericBeanDefinition beanDefinition = (GenericBeanDefinition) builder.getBeanDefinition();
        beanDefinition.getConstructorArgumentValues().addGenericArgumentValue(mapper);
        // 走 public 构造器(且要求参数最多的且参数是在 spring 容器中)
        beanDefinition.setAutowireMode(AbstractBeanDefinition.AUTOWIRE_BY_TYPE);*/

        String registryBeanName = "mapperInterface#index" + (++index);
        registry.registerBeanDefinition(registryBeanName, beanDefinition);
        System.out.println("Registry bean name [" + registryBeanName + "]");
    }

    private void findResources(String path, List<String> classNameList) {
        System.out.println("Scan resource path [" + path + "]");
        String location = "classpath*:" + path.replace(".", "/") + "/**/*.class";
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver(resourceLoader);
        CachingMetadataReaderFactory factory = new CachingMetadataReaderFactory(resourceLoader);
        try {
            Resource[] resources = resolver.getResources(location);
            for (Resource resource : resources) {
                MetadataReader metadata = factory.getMetadataReader(resource);
                String className = metadata.getClassMetadata().getClassName();
                System.out.println("Scan class name [" + className + "]");
                classNameList.add(className);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println("Scan resource path over");
    }
}
```

#### 实现 FactoryBean 接口，自定义 bean 的实例初初始化

采用 JDK 动态代理方式实现接口 + 注解的实现

```java
public class FactoryBeanStarter implements FactoryBean<Object>, BeanClassLoaderAware {

    private Class<?> mapperInterface;
    private ClassLoader classLoader;

    public FactoryBeanStarter() {
        System.out.println("FactoryBeanStarter Constructor");
    }

    public FactoryBeanStarter(Class<?> mapperInterface) {
        this.mapperInterface = mapperInterface;
        System.out.println("FactoryBeanStarter Constructor [" + mapperInterface.getName() + "]");
    }

    @Override
    public Object getObject() {
        return Proxy.newProxyInstance(classLoader,
                new Class<?>[] {mapperInterface},
                (proxy, method, args) -> {
                    System.out.println("proxy object [" + proxy.getClass().getName() + "]");
                    System.out.println("proxy method [" + method.getName() + "]");
                    System.out.println("proxy args [" + splitArgs(args) + "]");

                    Select annotation = method.getAnnotation(Select.class);
                    if (null != annotation) {
                        String sql = annotation.sql();
                        System.out.println("Exec sql [" + sql + "]");
                        return new SelectEntity(sql);
                    }
                    return new SelectEntity("Factory Bean Proxy Default Entity");
                });
    }

    @Override
    public Class<?> getObjectType() { return mapperInterface; }

    @Override
    public void setBeanClassLoader(ClassLoader classLoader) { this.classLoader = classLoader; }
}
```

#### 添加注解，联合 Import 注解一起使用

注册实现的配置类

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Import({ImportBeanDefinitionRegistrarStarter.class})
@Inherited
@Documented
public @interface RegistrarAnnotation {
    /* 扫描的包 */
    String[] value() default {};
}
```

#### Registrar 配置类

```java
@RegistrarAnnotation({"cn.nihility.registrar2.mapper"})
public class RegistrarConfig {}
```

#### spring boot 自动配置

路径：`META-INF/spring.factories`

```
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
  cn.nihility.registrar2.RegistrarConfig
```

### 编程式 bean 注册

`org.springframework.beans.factory.support.BeanDefinitionBuilder` 和
`org.springframework.beans.factory.support.GenericBeanDefinition`

操作方式

```java
// 定义一个 Bean 定义的构造器， 指定操作 bean 的实例对象
BeanDefinitionBuilder builder = BeanDefinitionBuilder.genericBeanDefinition(FactoryBeanStarter.class);

// 采用实例构造方法初始化实例
// 添加构造参数, 下两种方式一样
builder.addConstructorArgValue(SelectMapper.class);
builder.addConstructorArgValue("mapper.SelectMapper");
// 添加构造函数参数依赖 bean， 参数为依赖 bean 的名称
 builder.addConstructorArgReference("entityA");

// 采用属性配置方式初始化对象属性
// 采用 setter 方式初始化实例
builderAB.addPropertyValue("entityA", "entityA");
builderAB.addPropertyValue("entityA", "test.EntityA");
// 采用 setter 依赖别的 bean 的方式
builder.addPropertyReference("entityA", "entityA");

// 设置自动注入的模式
builder.setAutowireMode(AutowireCapableBeanFactory.AUTOWIRE_BY_TYPE);

// 最后得到 bean 的构造定义实例
GenericBeanDefinition beanDefinition = (GenericBeanDefinition) builder.getBeanDefinition();

// 交给 spring bean 构造注册容器
ctx.registerBeanDefinition("factoryBeanStarter", beanDefinition);
```

### ClassPathBeanDefinitionScanner 按指定过滤条件注册 bean

```java
@Configuration
@Import(ScannerConfig.class)
public class ScannerConfig implements ApplicationContextAware, ImportBeanDefinitionRegistrar {

  private final static Logger log = LoggerFactory.getLogger(ScannerConfig.class);
  private ApplicationContext applicationContext;

  @Override
  public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
    ClassPathBeanDefinitionScanner scanner = new ClassPathBeanDefinitionScanner(registry) {
      @Override
      protected Set<BeanDefinitionHolder> doScan(String... basePackages) {
        Set<BeanDefinitionHolder> beanDefinitions = super.doScan(basePackages);

        GenericBeanDefinition definition;
        for (BeanDefinitionHolder holder : beanDefinitions) {
          definition = (GenericBeanDefinition) holder.getBeanDefinition();
          String beanClassName = definition.getBeanClassName();
          System.out.println(beanClassName);

          // 偷梁换柱，改变 bean 的内部实体类和添加参数
          definition.getConstructorArgumentValues().addGenericArgumentValue(beanClassName);
          definition.setBeanClass(FilterClassWrapper.class);

          definition.setAutowireMode(AbstractBeanDefinition.AUTOWIRE_BY_TYPE);
          definition.setLazyInit(false);
        }
        return beanDefinitions;
      }
      /**
       * 自定义是否加入 candidates 组件中，重写 ClassPathScanningCandidateComponentProvider
       */
      @Override
      protected boolean isCandidateComponent(AnnotatedBeanDefinition beanDefinition) {
        return beanDefinition.getMetadata().isInterface() && beanDefinition.getMetadata().isIndependent();
      }
    };
    scanner.setResourceLoader(applicationContext);
    // 添加过滤条件 或 排除条件
    scanner.addIncludeFilter(((metadataReader, metadataReaderFactory) -> {
      String className = metadataReader.getClassMetadata().getClassName();
      log.info("Include Filter Class Name [{}]", className);
      return className.contains("IncludeFilterClass");
    }));
    // 指定扫描的包
    scanner.scan("cn.nihility.mapper");
  }

  @Override
  public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
    this.applicationContext = applicationContext;
  }
}
```

### BeanDefinitionRegistryPostProcessor 接口实现注册 bean

* 实现 BeanDefinitionRegistryPostProcessor 接口
```java
public class BeanDefinitionRegistryPostProcessorImpl implements BeanDefinitionRegistryPostProcessor {
    private final static Logger log = LoggerFactory.getLogger(BeanDefinitionRegistryPostProcessorImpl.class);
    private String tag;
    public BeanDefinitionRegistryPostProcessorImpl(String tag) { this.tag = tag; }
    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
      log.info("postProcessBeanDefinitionRegistry tag[{}]", tag);
      // 注册 bean 到 spring 容器
      GenericBeanDefinition definition = new GenericBeanDefinition();
      definition.setBeanClass(ExcludeFilterClass.class);
      registry.registerBeanDefinition("ExcludeFilterClass", definition);
    }
    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
      log.info("postProcessBeanFactory tag[{}]", tag);
    }
  }
```

采用某些方法来注册实现了 BeanDefinitionRegistryPostProcessor 接口类实例到 spring 容器

* 此处使用 ImportBeanDefinitionRegistrar 接口实现类来注册

```java
@Configuration
@Import(ImportBeanDefinitionRegistrarImpl.class)
public class ImportBeanDefinitionRegistrarImpl implements ImportBeanDefinitionRegistrar {
  private final static Logger log = LoggerFactory.getLogger(ImportBeanDefinitionRegistrarImpl.class);
  @Override
  public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
    // spring 容器注册 BeanDefinitionRegistryPostProcessorImpl
    BeanDefinitionBuilder builder = BeanDefinitionBuilder.genericBeanDefinition(BeanDefinitionRegistryPostProcessorImpl.class);
    builder.addConstructorArgValue("BeanDefinitionBuilder Tag");
    registry.registerBeanDefinition("BeanDefinitionRegistryPostProcessorImpl", builder.getBeanDefinition());
  }
}
```

这样 BeanDefinitionRegistryPostProcessor 接口中实现的 bean 注册就可以到 spring 容器。