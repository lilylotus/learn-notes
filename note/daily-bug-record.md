### 一。HttpServletRequest 请求 body 被重复消费，导致 @PostMapping 中 @RequestBody 获取异常

#### 异常描述

Required request body is missing.

org.springframework.http.converter.HttpMessageNotReadableException: Required request body is missing: public kl.iam.urm.comm.entity.SuccessResponse 

#### 解决方法

如果确实想多次获取请求体内容，需要重写过滤器，重新封装一个继承 `HttpServletRequestWrapper` 类的可重复读取 *body* 内容的 request，传递下去。（推荐，对后面的操作无感）

或者把请求来的 *body* 放到 request 的参数中，随后的所有请求在参数列表获取。（需要后面注意获取方式）