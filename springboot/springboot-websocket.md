### spring boot websocket

#### 引入依赖

```groovy
implementation 'org.springframework.boot:spring-boot-starter-websocket'
```

#### websocket 配置

##### 启用 websocket

```java
/**
 * 开启 WebSocket 支持
 */
@Configuration
@EnableWebSocket
public class WebsocketConfiguration implements WebSocketConfigurer {
    /**
     * 自定义 WebSocketServer，使用底层 websocket 方法
     * 提供对应的 onOpen、onClose、onMessage、onError方法
     * 自动探测 ServerEndpoint 注解的类
     */
    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }
    /**
     * 编程式配置 websocket
     * 实现 HandshakeInterceptor 接口     
     */
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(new WebSocketManual(), "sk")
                .addInterceptors(new WebSocketHandshakeInterceptor())
                .setAllowedOrigins("*");
    }
}
```

##### 编程式 websocket 服务端编写

```java
public class WebSocketManual extends AbstractWebSocketHandler { }
// 重载其中想要处理的方法
```

*web socket* 拦截器

```java
public class WebSocketHandshakeInterceptor implements HandshakeInterceptor {
    private static final Logger log = LoggerFactory.getLogger(WebSocketHandshakeInterceptor.class);
    /**
     * 握手开始前
     */
    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        log.info("WebSocketHandshakeInterceptor -> beforeHandshake");
        // 获得请求参数
        String query = request.getURI().getQuery();
        log.info("ServerHttpRequest query [{}]", query);
        return true;
    }
    /**
     * 握手完成后
     */
    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Exception exception) {
        log.info("WebSocketHandshakeInterceptor afterHandshake");
    }
}
```

##### 注解式 websocket 服务端实现

```java
/**
 * {@link javax.websocket.Endpoint}
 */
@Component
@ServerEndpoint(value = "/ws/{name}", configurator = WebSocketConfigurerImpl.class)
public class WebSocketAnnotation {
    @OnOpen
    public void onOpen(Session session, @PathParam("name") String name, EndpointConfig config) {}
    
    @OnClose
    public void OnClose(Session session, CloseReason closeReason) {}
    
    @OnMessage
    public void onMessage(Session session, String message) {}
    
    @OnError
    public void OnError(Session session, Throwable throwable) {}
}
```

```java
public class WebSocketConfigurerImpl extends ServerEndpointConfig.Configurator {
    @Override
    public void modifyHandshake(ServerEndpointConfig sec, HandshakeRequest request, HandshakeResponse response) {
        super.modifyHandshake(sec, request, response);
        sec.getUserProperties().put("timestamp", System.currentTimeMillis());
    }
}
```

#### html5 实现

```javascript
var websocket = null;
if('WebSocket' in window){
    websocket = new WebSocket("ws://localhost:8085/ws");
}

websocket.onopen = function(){
    console.log("连接成功");
}

websocket.onclose = function(){
    console.log("退出连接");
}

websocket.onmessage = function (event){
    console.log("收到消息"+event.data);
}

websocket.onerror = function(){
    console.log("连接出错");
}

window.onbeforeunload = function () {
    websocket.close(num);
}
```

