### 1. Spring 资源加载

`org.springframework.context.ResourceLoaderAware` 接口的实现

```java
/*
	location: 
	classpath*:com/test/*.class 表示 test 目录下所有的 class 文件
	classpath*:com/test/*/*.class 表示 test 目录下的子目录中的所有 class 文件
    classpath*:com/test/**/*.class 表示 test 目录及其子目录下的所有 class 文件
*/
PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver(MvcHttpServlet.class.getClassLoader());
CachingMetadataReaderFactory metadataReader = new CachingMetadataReaderFactory(resolver);
Resource[] resources = resolver.getResources(location);

Stream.of(resources).forEach(r -> {
    try {
        MetadataReader metadata = metadataReader.getMetadataReader(r);
        String clazzName = metadata.getClassMetadata().getClassName();

    });
```

