#### 1. 统一返回格式

实现接口 `org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice`

```java
@RestControllerAdvice
public class ResponseResultBodyAdvice implements ResponseBodyAdvice<Object>, Ordered {

    private static final Logger log = LoggerFactory.getLogger(ResponseResultBodyAdvice.class);
    private static final Class<? extends Annotation> ANNOTATION_TYPE = ResponseResultBody.class;

    /**
     * 对 @ResponseResultBody 注解拦截
     * @return true 采用了 @ResponseResultBody 注解
     */
    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        log.info("ResponseResultBodyAdvice supports [{}]", returnType.getContainingClass());
        return AnnotatedElementUtils.hasAnnotation(returnType.getContainingClass(), ANNOTATION_TYPE)
                || returnType.hasMethodAnnotation(ANNOTATION_TYPE);
    }

    /**
     * 使用了 @ResponseResultBody 注解就转换
     */
    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType, Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request, ServerHttpResponse response) {
        log.info("ResponseResultBodyAdvice beforeBodyWrite [{}]", (body == null ? "空" : body.getClass().getName()));
        if (body instanceof ResultResponse) {
            return body;
        } else if ("text".equals(selectedContentType.getType())) {
            return "{" +
                    "\"apiVersion\"" + ":" + "\"1.0.0\"," +
                    "\"data\"" + ":" + "\"" + body + "\"," +
                    "\"message\"" + ":" + "\"ResponseResultBodyAdvice 统一请求\"" +
                    "}";
        }
        return ResultResponse.success(body);
    }


    @ExceptionHandler(Exception.class)
    public final ResponseEntity<ResultResponse<?>> exceptionHandler(Exception ex, WebRequest request) {
        log.error("ExceptionHandler: {}", ex.getMessage());
        HttpHeaders headers = new HttpHeaders();
        if (ex instanceof ResultException) {
            return this.handleResultException((ResultException) ex, headers, request);
        }
        return this.handleException(ex, headers, request);
    }


    /** 对ResultException类返回返回结果的处理 */
    protected ResponseEntity<ResultResponse<?>> handleResultException(ResultException ex, HttpHeaders headers, WebRequest request) {
        return this.handleExceptionInternal(ex, ResultResponse.failure(ex.getResultStatus()),
                headers, ex.getResultStatus().getHttpStatus(), request);
    }

    /** 异常类的统一处理 */
    protected ResponseEntity<ResultResponse<?>> handleException(Exception ex, HttpHeaders headers, WebRequest request) {
        return this.handleExceptionInternal(ex, ResultResponse.failure(ex.getMessage()),
                headers, HttpStatus.INTERNAL_SERVER_ERROR, request);
    }

    /**
     * org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler#handleExceptionInternal(java.lang.Exception, java.lang.Object, org.springframework.http.HttpHeaders, org.springframework.http.HttpStatus, org.springframework.web.context.request.WebRequest)
     * <p>
     * A single place to customize the response body of all exception types.
     * <p>The default implementation sets the {@link WebUtils#ERROR_EXCEPTION_ATTRIBUTE}
     * request attribute and creates a {@link ResponseEntity} from the given
     * body, headers, and status.
     */
    protected ResponseEntity<ResultResponse<?>> handleExceptionInternal(
            Exception ex, ResultResponse<?> body, HttpHeaders headers, HttpStatus status, WebRequest request) {
        if (HttpStatus.INTERNAL_SERVER_ERROR.equals(status)) {
            request.setAttribute(WebUtils.ERROR_EXCEPTION_ATTRIBUTE, ex, WebRequest.SCOPE_REQUEST);
        }
        return new ResponseEntity<>(body, headers, status);
    }
    
	/** 优先级越高，在多个统一返回的时候内容在越里层 */
    @Override
    public int getOrder() {
        return HIGHEST_PRECEDENCE + 10;
    }
}
```

#### 获取请求 headers

使用 `org.springframework.web.bind.annotation.RequestHeader` 方法参数注解获取所有 *headers*，该情况每个 header 中仅有一个值。

```java
@RequestMapping("/headers")
public Map<String, String> headers(@RequestHeader Map<String, String> headers) { }
```

若是一个请求有多个值，`org.springframework.util.MultiValueMap` map 来接收，获取的 value 是 List。

```java
@RequestMapping("/headers")
public Map<String, String> headers(@RequestHeader MultiValueMap<String, String> headers) { }
```

直接使用 `org.springframework.http.HttpHeaders` 接收所有的 Header 参数。

```java
@GetMapping("/httpHeaders")
public Map<String, String> httpHeaders(@RequestHeader HttpHeaders headers) { }
```



