#### 1. web 端 websocket 实现

##### 1.1 请求连接服务端

```javascript
var ws = null;
// 构建 websocket 对象
if ('WebSocket' in window) {
    ws = new WebSocket('ws://localhost:8080/servlet31/websocket/chat');
} else if ('MozWebSocket' in window) {
    ws = new MozWebSocket('ws://localhost:8080/servlet31/websocket/chat');
} else {
    alert("not support");
}
```

##### 1.2 监听服务端消息

```javascript
// 监听信息
ws.onmessage = function (evt) {
    var _data = evt.data;
    var obj = JSON.parse(_data);
    // 解析消息后处理
}
```

##### 1.3 发送消息到服务端

```javascript
var  message = {};
message.fromName = userName;
message.toName = $(':input:radio:checked').val();
message.content = content;

var msg = JSON.stringify(message);
// 发送消息
ws.send(msg);
```

#### 2. 服务端实现

添加依赖

```xml
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>3.1.0</version>
    <scope>provided</scope>
</dependency>

<dependency>
    <groupId>javax.websocket</groupId>
    <artifactId>javax.websocket-api</artifactId>
    <version>1.1</version>
    <scope>provided</scope>
</dependency>
```

##### 2.1 建立 socket 路径服务

使用注解 `@ServerEndpoint` 指定该 *socket* 的连接路径 *value = "/websocket/chat"*
额外的信息获取配置 *configurator = GetHttpSessionConfigurator.class*
*注意：* socket 中的 session 和 servlet 中的 httpsession 不同
<font color="red">每个 socket 连接都会新建一个服务端 socket 服务对象来一一对应</font>

```java
@ServerEndpoint(value = "/websocket/chat", 
                configurator = GetHttpSessionConfigurator.class)
public class ChatSocket {
    @OnOpen
    public void onOpen(Session session, EndpointConfig config) {}

	@OnMessage
    public void onMessage(String message, Session session) {}

    @OnClose
    public void onClose(Session session, CloseReason closeReason) {}

    @OnError
    public void OnError(Session session, Throwable thr) {}
}
```

额外的信息获取配置类

```java
public class GetHttpSessionConfigurator extends ServerEndpointConfig.Configurator {
    @Override
    public void modifyHandshake(ServerEndpointConfig config, 
                                HandshakeRequest request, HandshakeResponse response) {
        HttpSession httpSession = (HttpSession) request.getHttpSession();
        config.getUserProperties().put(HttpSession.class.getName(), httpSession);
    }
}

// 该配置类继承类 ServerEndpointConfig.Configurator
// 会把获取到了 request 或者 response 信息自定义的添加到 config 配置中
// 在从 @ServerEndpoint 注解类的 @OnOpen 注解方法的 EndpointConfig config 参数获取
// config.getUserProperties().get(key);
```

<font color="blue">还可以继承抽象类 javax.websocket.Endpoint 实现 socket 服务端</font>

配置 socket 服务连接路径， 实现接口 `javax.websocket.server.ServerApplicationConfig`

```java
public class ExamplesConfig implements ServerApplicationConfig {
    @Override
    public Set<ServerEndpointConfig> getEndpointConfigs(Set<Class<? extends Endpoint>> scanned) {
        Set<ServerEndpointConfig> result = new HashSet<>();
        if (scanned.contains(EchoEndpoint.class)) {
            result.add(ServerEndpointConfig.Builder.create(EchoEndpoint.class, "/websocket").build());
        }
        return result;
    }
    @Override
    public Set<Class<?>> getAnnotatedEndpointClasses(Set<Class<?>> scanned) {
        Set<Class<?>> results = new HashSet<>();
        for (Class<?> clazz : scanned) {
            if (clazz.getPackage().getName().contains("ws")) {
                results.add(clazz);
            }
        }
        return results;
    }
}
```

其中 `getEndpointConfigs `是配置所有继承 `Endpoint` 的类，而 `getAnnotatedEndpointClasses` 是配置所有被`@ServerEndpoint` 修饰的类。