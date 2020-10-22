## REST API 规范

[参考 opensource 规范](https://opensource.zalando.com/restful-api-guidelines)
[示例](https://github.com/godruoyi/restful-api-specification)

### 协议

通过 `API` 于后端服务通信的过程中，`应该` 使用 `HTTPS` 协议。

### API ROOT URL （根路径）

`API` 的根入口点应尽可能保持足够简单，这里有两个常见的 `URL` 根例子：

* api.example.com/*
* example.com/api/*

> 如果应用很庞大或者预计将会变的很庞大，那 `应该` 将 `API` 放到子域下（`api.example.com`）。这种做法可以保持某些规模化上的灵活性。

### Versioning (版本控制)

所有的 `API` 必须保持向后兼容，`必须` 在引入新版本 `API` 的同时确保旧版本 `API` 仍然可用。所以 `应该` 为其提供版本支持。
目前比较常见的两种版本号形式：

- 在 URL 中嵌入版本编号
  ```bash
  api.example.com/v1/*
  ```
  这种做法是版本号直观、易于调试；另一种做法是，将版本号放在 `HTTP Header` 头中
- 通过媒体类型来指定版本信息
  ```bash
  Accept: application/vnd.example.com.v1+json
  ```
  其中 `vnd` 表示 `Standards Tree` 标准树类型，有三个不同的树: `x`，`prs` 和 `vnd`
  * 未注册的树（`x`）主要表示本地和私有环境
  * 私有树（`prs`）主要表示没有商业发布的项目
  * 供应商树（`vnd`）主要表示公开发布的项目
  > 后面几个参数依次为应用名称（一般为应用域名）、版本号、期望的返回格式。

### Endpoints (端点)

端点就是指向特定资源或资源集合的 `URL`。在端点的设计中，你 `必须` 遵守下列约定：

* URL 的命名 `必须` 全部小写
* URL 中资源（`resource`）的命名 `必须` 是名词，并且 `必须` 是复数形式
* `必须` 优先使用 `Restful` 类型的 URL
* URL `必须` 是易读的
* URL `一定不可` 暴露服务器架构

> 至于 URL 是否必须使用连字符（`-`） 或下划线（`_`），不做硬性规定，但 `必须` 根据团队情况统一一种风格。

反例：

* https://api.example.com/getUserInfo?userid=1
* https://api.example.com/getusers
* https://api.example.com/sv/u
* https://api.example.com/cgi-bin/users/get_user.php?userid=1

正例：

* https://api.example.com/zoos
* https://api.example.com/animals
* https://api.example.com/zoos/{zoo}/animals
* https://api.example.com/animal_types
* https://api.example.com/employees

### HTTP 动词

对于资源的具体操作类型，由 `HTTP` 动词表示。常用的 `HTTP` 动词有下面五个（括号里是对应的 `SQL` 命令）。

* GET（SELECT）：从服务器取出资源（一项或多项）。
* POST（CREATE）：在服务器新建一个资源。
* PUT（UPDATE）：在服务器更新资源（客户端提供改变后的完整资源）。
* PATCH（UPDATE）：在服务器更新资源（客户端提供改变的属性）。
* DELETE（DELETE）：从服务器删除资源。

其中

1. 删除资源 `必须` 用 `DELETE` 方法
2. 创建新的资源 `必须` 使用 `POST` 方法
3. 更新资源 `应该` 使用 `PUT` 方法
4. 获取资源信息 `必须` 使用 `GET` 方法

针对每一个端点来说，下面列出所有可行的 `HTTP` 动词和端点的组合

| 请求方法 | URL | 描述 |
| ---------- | --- | --- |
| GET | /zoos                              | 列出所有的动物园(ID和名称，不要太详细) |
| POST | /zoos                              | 新增一个新的动物园 |
| GET | /zoos/{zoo}                        | 获取指定动物园详情 |
| PUT | /zoos/{zoo}                        | 更新指定动物园(整个对象) |
| PATCH | /zoos/{zoo}                        | 更新动物园(部分对象) |
| DELETE | /zoos/{zoo}                        | 删除指定动物园 |
| GET | /zoos/{zoo}/animals                | 检索指定动物园下的动物列表(ID和名称，不要太详细) |
| GET | /animals                           | 列出所有动物(ID和名称)。 |
| POST | /animals                           | 新增新的动物 |
| GET | /animals/{animal}                  | 获取指定的动物详情 |
| PUT | /animals/{animal}                  | 更新指定的动物(整个对象) |
| PATCH | /animals/{animal}                  | 更新指定的动物(部分对象) |
| GET | /animal_types                      | 获取所有动物类型(ID和名称，不要太详细) |
| GET | /animal_types/{type}               | 获取指定的动物类型详情 |
| GET | /employees                         | 检索整个雇员列表 |
| GET | /employees/{employee}              | 检索指定特定的员工 |
| GET | /zoos/{zoo}/employees              | 检索在这个动物园工作的雇员的名单(身份证和姓名) |
| POST | /employees                         | 新增指定新员工 |
| POST | /zoos/{zoo}/employees              | 在特定的动物园雇佣一名员工 |
| DELETE | /zoos/{zoo}/employees/{employee}   | 从某个动物园解雇一名员工 |

> 超出 `Restful` 端点的，`应该` 模仿上表的方式来定义端点。

### Filtering (过滤)

> 如果记录数量很多，服务器不可能都返回给用户。API `应该` 提供参数，过滤返回结果。

- ?limit=10：指定返回记录的数量
- ?offset=10：指定返回记录的开始位置。
- ?page=2&per_page=100：指定第几页，以及每页的记录数。
- ?sortby=name&order=asc：指定返回结果按照哪个属性排序，以及排序顺序。
- ?animal_type_id=1：指定筛选条件

所有 `URL` 参数 `必须` 是全小写，`必须` 使用下划线类型的参数形式。

> 分页参数 `必须` 固定为 `page`、`per_page`

经常使用的、复杂的查询 `应该` 标签化，降低维护成本。如

```bash
GET /trades?status=closed&sort=sortby=name&order=asc

可为其定制快捷方式
GET /trades/recently_closed
```

### Authentication (认证方式)

`应该` 使用 `OAuth2.0` 的方式为 API 调用者提供登录认证。`必须` 先通过登录接口获取 `Access Token` 后再通过该 `token` 调用需要身份认证的 `API`。

Oauth 的端点设计示列

* RFC 6749   /token
* Twitter    /oauth2/token
* Fackbook   /oauth/access_token
* Google     /o/oauth2/token
* Github     /login/oauth/access_token
* Instagram  /oauth/authorize

客户端在获得 `access token` 的同时 `必须` 在响应中包含一个名为 `expires_in` 的数据，它表示当前获得的 `token` 会在多少 `秒` 后失效。

```json
{
    "access_token": "token....",
    "token_type": "Bearer",
    "expires_in": 3600
}
```

客户端在请求需要认证的 `API` 时，`必须` 在请求头 `Authorization` 中带上 `access_token`。

当超过指定的秒数后，`access token` 就会过期，再次用过期/或无效的 `token` 访问时，服务端 `应该` 返回 `invalid_token` 的错误或 `401` 错误码。

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
    "error": "invalid_token"
}
```

> Laravel 开发中，`应该` 使用 [JWT](https://github.com/tymondesigns/jwt-auth) 来为管理你的 Token，并且 `一定不可` 在 `api` 中间件中开启请求 `session`。

### Response (响应)

所有的 `API` 响应，`必须` 遵守 `HTTP` 设计规范，`必须` 选择合适的 `HTTP` 状态码。`一定不可` 所有接口都返回状态码为 `200` 的 `HTTP` 响应，如：

```http
HTTP/1.1 200 ok
Content-Type: application/json
Server: example.com

{
    "code": 0,
    "msg": "success",
    "data": {
        "username": "username"
    }
}
```

```http
HTTP/1.1 200 ok
Content-Type: application/json
Server: example.com

{
    "code": -1,
    "msg": "该活动不存在",
}
```

下表列举了常见的 `HTTP` 状态码

| 状态码 | 描述 |
| ---------- | --- |
| 1xx | 代表请求已被接受，需要继续处理 |
| 2xx | 请求已成功，请求所希望的响应头或数据体将随此响应返回 |
| 3xx | 重定向 |
| 4xx | 客户端原因引起的错误 |
| 5xx | 服务端原因引起的错误 |

> 只有来自客户端的请求被正确的处理后才能返回 `2xx` 的响应，所以当 API 返回 `2xx` 类型的状态码时，前端 `必须` 认定该请求已处理成功。

必须强调的是，所有 `API` `一定不可` 返回 `1xx` 类型的状态码。当 `API` 发生错误时，`必须` 返回出错时的详细信息。目前常见返回错误信息的方法有两种：

1. 将错误详细放入 `HTTP` 响应首部
   ```http
   X-MYNAME-ERROR-CODE: 4001
   X-MYNAME-ERROR-MESSAGE: Bad authentication token
   X-MYNAME-ERROR-INFO: http://docs.example.com/api/v1/authentication
   ```
2. 直接放入响应实体中 
   ```bash
   HTTP/1.1 401 Unauthorized
   Server: nginx/1.11.9
   Content-Type: application/json
   Transfer-Encoding: chunked
   Cache-Control: no-cache, private
   Date: Sun, 24 Jun 2018 10:02:59 GMT
   Connection: keep-alive
   
   {"error_code":40100,"message":"Unauthorized"}
   ```

考虑到易读性和客户端的易处理性，我们 `必须` 把错误信息直接放到响应实体中，并且错误格式 `应该` 满足如下格式：

```json
{
    "message": "您查找的资源不存在",
    "error_code": 404001
}
```

其中错误码（`error_code`）`必须` 和 `HTTP` 状态码对应，也方便错误码归类，如：

```http
HTTP/1.1 429 Too Many Requests
Server: nginx/1.11.9
Content-Type: application/json
Transfer-Encoding: chunked
Cache-Control: no-cache, private
Date: Sun, 24 Jun 2018 10:15:52 GMT
Connection: keep-alive

{"error_code":429001,"message":"你操作太频繁了"}
```

```http
HTTP/1.1 403 Forbidden
Server: nginx/1.11.9
Content-Type: application/json
Transfer-Encoding: chunked
Cache-Control: no-cache, private
Date: Sun, 24 Jun 2018 10:19:27 GMT
Connection: keep-alive

{"error_code":403002,"message":"用户已禁用"}
```

`应该` 在返回的错误信息中，同时包含面向开发者和面向用户的提示信息，前者可方便开发人员调试，后者可直接展示给终端用户查看如：

```json
{
    "message": "直接展示给终端用户的错误信息",
    "error_code": "业务错误码",
    "error": "供开发者查看的错误信息",
    "debug": [
        "错误堆栈，必须开启 debug 才存在"
    ]
}
```

#### 200 ok

`200` 状态码是最常见的 `HTTP` 状态码，在所有 **成功** 的 `GET` 请求中，`必须` 返回此状态码。`HTTP` 响应实体部分 `必须` 直接就是数据，不要做多余的包装。

错误示例：

```http
HTTP/1.1 200 ok
Content-Type: application/json
Server: example.com

{
    "user": {
        "id":1,
        "nickname":"fwest",
        "username": "example"
    }
}
```

正确示例：

1、获取单个资源详情

```json
{
    "id": 1,
    "username": "godruoyi",
    "age": 88,
}
```

2、获取资源集合

```json
{
    "data": [
    {
        "id": 1,
        "username": "godruoyi",
        "age": 88,
    },
    {
        "id": 2,
        "username": "foo",
        "age": 88,
    }],
    "meta": {
        "pagination": {
            "total": 101,
            "count": 2,
            "per_page": 2,
            "current_page": 1,
            "total_pages": 51,
            "links": {
                "next": "http://api.example.com?page=2"
            }
        }
    }
}
```

> 其中，分页和其他额外的媒体信息，必须放到 `meta` 字段中。

