##### RestTemplate

从 *Spring Framework 5* 开始，*Spring* 与 *WebFlux* 堆栈一起，引入了一个名为 *WebClient* 的新 *HTTP* 客户端。 *WebClient* 是 *RestTemplate* 的现代 *HTTP* 客户端。它不仅提供了传统的同步 API，而且还支持有效的非阻塞和异步方法。

支持的方法：

- `getForObject(url, classType)` –通过对URL进行 GET 检索表示。响应（如果有）被解组到给定的类类型并返回。
- `getForEntity(url, responseType)` – 通过在 URL 上执行 GET 检索作为 ResponseEntity 的表示形式。.
- `exchange(requestEntity, responseType)` – execute the specified request and return the response as *ResponseEntity*.
- `execute(url, httpMethod, requestCallback, responseExtractor)` – execute the *httpMethod* to the given URI template, preparing the request with the *RequestCallback*, and reading the response with a *ResponseExtractor*.



###### url 参数

```java
// @PathVariable(name = "id")
String url = baseUrl + port + "/rest/foo2/{id}/{name}";
Map<String, String> params = new HashMap<>();
params.put("id", "111");
params.put("name", "paramName");
final Foo foo = restTemplate.getForObject(url, Foo.class, params);
// 也可以直接使用占位符
final Foo foo = restTemplate.getForObject(url, Foo.class, 111, "addName");

--------------------
// @RequestHeader(name = "id", defaultValue = "-1")
String uri = baseUrl + port + "/rest/foo-header";
HttpHeaders headers = new HttpHeaders();
headers.set("id", "1000");
headers.add("name", "addHeader");
HttpEntity<Foo> requestEntity = new HttpEntity<>(null, headers);
final ResponseEntity<Foo> responseEntity = restTemplate.exchange(uri, HttpMethod.GET, requestEntity, Foo.class);
final Foo body = responseEntity.getBody();

---------------------
// @RequestParam(name = "id", defaultValue = "10000")
--> 使用 /rest/foo?name=headerName&id=11 此 url
```

###### post

```java
String uri = baseUrl + port + "/rest/foo2";
Foo foo = new Foo(123, "POST-Name");
final ResponseEntity<Foo> responseEntity = restTemplate.postForEntity(uri, foo, Foo.class);
final Foo result = responseEntity.getBody();

----
    (@RequestBody Foo foo,
     @RequestHeader(name = "h1", defaultValue = "default h1 value") String h1,
     @RequestHeader(name = "h2", defaultValue = "default h2value") String h2)

String uri = baseUrl + port + "/rest/foo21";
Foo foo = new Foo(123, "POST-Name");
HttpHeaders headers = new HttpHeaders();
headers.set("h1", "h1 Header Value");
headers.set("h2", "h2 Header Value");
HttpEntity<Foo> request = new HttpEntity<>(foo, headers);
final ResponseEntity<Foo> responseEntity = restTemplate.postForEntity(uri, request, Foo.class);
final Foo result = responseEntity.getBody();
```

