#### 1. spring boot 添加拦截器

##### 1.1 声明拦截器

实现 `org.springframework.web.servlet.HandlerInterceptor` 接口

```java
@Slf4j
public class AutoIdempotentInterceptor implements HandlerInterceptor {

    private TokenServiceImpl tokenService;
    
    public AutoIdempotentInterceptor() {
    }
    public AutoIdempotentInterceptor(TokenServiceImpl tokenService) {
        this.tokenService = tokenService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        log.info("AutoIdempotentInterceptor -> preHandle");

        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        HandlerMethod handlerMethod = (HandlerMethod) handler;
        Method method = handlerMethod.getMethod();

        if (method.isAnnotationPresent(AutoIdempotent.class)) {
            try {
                // 等幂性校验
                return tokenService.checkToken(request);
            } catch (Exception ex) {
                ResultVo resultVo = ResultVo.getFailedResult(101, ex.getMessage());
                writeRespnseJson(response, JSON.toJSONString(resultVo));
                throw ex;
            }
        }

        // 最后返回 true
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }

    /**
     * 返回 json 数据
     * @param response
     * @param jsonMsg
     */
    private void writeRespnseJson(HttpServletResponse response, String jsonMsg) {
        PrintWriter writer = null;
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=utf-8");
        try {
            writer = response.getWriter();
            writer.println(jsonMsg);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (null != writer) {
                writer.close();
            }
        }
    }
}
```

##### 1.2 注册拦截器

实现 `org.springframework.web.servlet.config.annotation.WebMvcConfigurer` 接口

```java

@Slf4j
@Configuration
public class InterceptorConfiguration implements WebMvcConfigurer {

    @Autowired
    private TokenServiceImpl tokenService;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        log.info("registration idempotent interceptor.");
        final InterceptorRegistration registration = registry.addInterceptor(new AutoIdempotentInterceptor(tokenService));
        registration.addPathPatterns("/**");
        registration.excludePathPatterns("/error");
        registration.excludePathPatterns("/static/**");
        registration.excludePathPatterns("/login");
    }

}
```

