### nacos 配置中心

目前 nacos 配置中心支持 3 中配置文件。

* 依据 `${prefix}-${spring.profiles.active}.${file-extension}` 规则的默认配置文件，spring cloud 通用支持
* 拓展配置文件 `extension-configs`
* 共享配置文件 `shared-configs`

默认的加载配置顺序： `nacos 默认` > `nacos 拓展配置` > `nacos 共享配置`  > `本地配置`

#### 启动配置文件加载顺序

*spring boot bootstrap.yml* 配置

```yaml
spring:
  application:
    name: nacos
  cloud:
    nacos:
      config:
        # 加载优先级 config > extension > shared
        # 拓展配置集数组，对应 Config 数组
        extension-configs:
          - data-id: extension.yml
            group: DEFAULT_GROUP
            # 是否自动刷新配置，默认为 false
            refresh: true
        # 共享配置集数组，对应 Config 数组
        shared-configs:
          - data-id: shared.yml
            group: DEFAULT_GROUP
            # 是否自动刷新配置，默认为 false
            refresh: true
        # nacos 中配置格式 ${prefix}-${spring.profiles.active}.${file-extension} : umc-biz.yml/umc.yml
        # prefix -> spring.application.name
        # file-extension -> properties|yml 两种类型 : spring.cloud.nacos.config.file-extension
        # file-extension 不填默认为 properties
        enabled: true
        server-addr: 127.0.0.1:8848
        file-extension: yml
      discovery:
        enabled: false
        server-addr: 127.0.0.1:8848
```

本地 *application.yml* 配置

```yaml
app:
  value: local app value
shared:
  value: local shared value
common:
  value: local common value
extension:
  value: local extension value
```

nacos 默认配置

```yaml
app:
  value: nacos app value
common:
  value: nacos common value
```

nacos extension 配置

```yaml
common:
  value: extension common value
extension:
  value: extension extension value
```

nacos share 配置

```yaml
shared:
  value: shared shared value
common:
  value: shared common value
```

最后展示值:

```json
{
  "sharedValue": "shared shared value",
  "extensionValue": "extension extension value",
  "commonValue": "nacos common value",
  "appValue": "nacos app value"
}
```
