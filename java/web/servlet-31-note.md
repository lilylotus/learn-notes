###### 文件上传格式

`multipart/form-data`

###### Servlet 3.1 or later 新特性。

在 `META-INF/services` 路径新建文件 `javax.servlet.ServletContainerInitializer`

`创建要启动的类并实现 javax.servlet.ServletContainerInitializer 接口`
`@HandlesTypes(Class)` 自动加载所有注解中的类，或者是实现了该接口的类