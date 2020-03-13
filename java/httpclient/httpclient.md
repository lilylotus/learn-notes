#### httpclient 版本

```groovy
implementation 'org.apache.httpcomponents:httpclient:4.5.6'
```

#### httpclient 添加 cookie 支持

```java
// 创建 cookie 存储的地方
BasicCookieStore cookieStore = new BasicCookieStore();
// 创建请求的客户端，类似于浏览器
CloseableHttpClient httpClient = HttpClientBuilder.create().setDefaultCookieStore(cookieStore).build();

HttpGet httpGet = HttpFactory.createHttpGet();
httpGet.setURI(URI.create(url));
CloseableHttpResponse response = httpClient.execute(httpGet);
HttpEntity entity = response.getEntity();
String data = EntityUtils.toString(entity, "UTF-8"); // 获取放回的内容
```

