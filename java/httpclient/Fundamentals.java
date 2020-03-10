package cn.nihility.httpclient;

import com.alibaba.fastjson.JSON;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.CharArrayBuffer;

import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * @author yzx
 * @date 2019-10-29 15:02
 */
public class Fundamentals {

    public static final int MAX_TOTAL_POOL = 150;
    public static final int MAX_TIMEOUT = 5000;
    public static final int REQUEST_TIME_OUT = 2000;

    public static void main(String[] args) {
        Fundamentals fundamentals = new Fundamentals();

        fundamentals.doGetNoParam();
        System.out.println("==============================");
        fundamentals.doGetWithParam();
        System.out.println("==============================");
        fundamentals.doPostNoParam();
        System.out.println("==============================");
        fundamentals.doPostWithParam();
        System.out.println("==============================");
        fundamentals.doPostWithEntity();
        System.out.println("==============================");
        fundamentals.doPostWithMultiParams();
        System.out.println("==============================");
        fundamentals.doPostUrlencodedForm();
        System.out.println("==============================");
        fundamentals.doPostWithFile();

    }

    public void httpPool() {

        PoolingHttpClientConnectionManager pool = new PoolingHttpClientConnectionManager();

        pool.setMaxTotal(MAX_TOTAL_POOL);
        pool.setDefaultMaxPerRoute(MAX_TOTAL_POOL);

        RequestConfig.Builder requestConfig = RequestConfig.custom();
        requestConfig.setConnectTimeout(MAX_TIMEOUT);
        requestConfig.setSocketTimeout(MAX_TIMEOUT);
        requestConfig.setConnectionRequestTimeout(REQUEST_TIME_OUT);
        RequestConfig requestConfigBuild = requestConfig.build();

        HttpClientBuilder httpClientBuilder = HttpClients.custom().setConnectionManager(pool).setDefaultRequestConfig(requestConfigBuild);





    }

    /**
     * POST 发送文件 postWithParamFile
     */
    public void doPostWithFile() {

        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://localhost:9000/spring/hello/postWithParamFile");

        CloseableHttpResponse response = null;

        MultipartEntityBuilder multipartEntityBuilder = MultipartEntityBuilder.create();

        // 第一个文件
        String filesKey = "files";
        File file01 = new File("E:\\log\\BingWallpaper-2019-02-25.jpg");
        File file02 = new File("E:\\log\\th.jpg");
        File file03 = new File("E:\\log\\mc.gif");
        try {
            multipartEntityBuilder.addBinaryBody(filesKey, file01, ContentType.DEFAULT_BINARY, URLEncoder.encode("必应壁纸.jpg", "UTF-8"));
            // 第二个文件(多个文件的话，使用可一个key就行，后端用数组或集合进行接收即可)
            multipartEntityBuilder.addBinaryBody(filesKey, file02);
            multipartEntityBuilder.addBinaryBody(filesKey, file03);
            // 防止服务端收到的文件名乱码。 我们这里可以先将文件名URLEncode，然后服务端拿到文件名时在URLDecode。就能避免乱码问题。
            // 文件名其实是放在请求头的 Content-Disposition 里面进行传输的，如其值为form-data; name="files"; filename="头像.jpg"
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        // 其它参数(注:自定义contentType，设置UTF-8是为了防止服务端拿到的参数出现乱码)
        ContentType contentType = ContentType.create("text/plain", Charset.forName("UTF-8"));
        multipartEntityBuilder.addTextBody("name", "等沙利文", contentType);
        multipartEntityBuilder.addTextBody("age", "1000", contentType);

        HttpEntity httpEntity = multipartEntityBuilder.build();
        httpPost.setEntity(httpEntity);

        try {
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            System.out.println("文件上传 " + (end - start));

            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }


    }


    /**
     * application/x-www-form-urlencoded表单请求
     * 注： multipart/form-data 也属于表单请求， 不过其表单编码为一条消失，每一控件对应消失一部分
     * 没有文件的化，默认 application/x-www-form-urlencoded
     * 有文件要用 multipart/form-data
     *
     */
    public void doPostUrlencodedForm() {

        CloseableHttpClient httpClient = HttpClientBuilder.create().build();
        HttpPost httpPost = new HttpPost("http://localhost:9000/spring/hello/postWithParam");
        CloseableHttpResponse response = null;

        httpPost.setHeader("Content-Type", "application/x-www-form-urlencoded");

        List<BasicNameValuePair> params = new ArrayList<>(8);
        params.add(new BasicNameValuePair("name", "表单提交"));
        params.add(new BasicNameValuePair("age", "1000"));

        UrlEncodedFormEntity formEntity = new UrlEncodedFormEntity(params, StandardCharsets.UTF_8);
        httpPost.setEntity(formEntity);

        try {
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            System.out.println("请求时间 " + (end - start));

            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }

    }

    /**
     * 同时请求多参数
     */
    public void doPostWithMultiParams() {
        CloseableHttpClient httpClient = HttpClientBuilder.create().build();

        // 参数，多种类型参数
        URI uri = null;

        // 参数以键值对方式放入
        List<NameValuePair> params = new ArrayList<>(16);
        params.add(new BasicNameValuePair("flag", "4"));
        params.add(new BasicNameValuePair("meaning", "What?"));
        // 设置 URI 信息，并将参数放入 uri
        // 注:这里也支持一个键值对一个键值对地往里面放setParameter(String key, String value)

        try {
            uri = new URIBuilder().setScheme("http").setHost("localhost").setPort(9000)
                    .setPath("/spring/hello/doPostMultiParam")
                    .setParameters(params)
                    .build();

        } catch (URISyntaxException e) {
            e.printStackTrace();
        }

        HttpPost httpPost = new HttpPost(uri);


        User user = new User();
        user.setAge(100);
        user.setName("潘婷");
        user.setGender("女");
        user.setMotto("不要喝水吃饭");

        String jsonString = JSON.toJSONString(user);
        System.out.println("POST 多参数请求实体 " + jsonString);
        StringEntity stringEntity = new StringEntity(jsonString, "UTF-8");

        httpPost.setEntity(stringEntity);
        httpPost.setHeader("Content-Type", "application/json;charset=UTF-8");


        CloseableHttpResponse response = null;

        try {
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            System.out.println("请求执行 " + (end -start));

            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }

    }

    /**
     * POST 使用实体对象发送
     */
    public void doPostWithEntity() {

        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://localhost:9000/spring/hello/postWithParamEntity");

        User user = new User();
        user.setAge(100);
        user.setName("潘婷");
        user.setGender("女");
        user.setMotto("不要喝水吃饭");

        String userString = JSON.toJSONString(user);
        System.out.println("请求对象 " + userString);
        // 创建参数实体
        StringEntity stringEntity = new StringEntity(userString, "UTF-8");
        // post 请求设置参数
        httpPost.setEntity(stringEntity);
        // post 设置请求类型
        httpPost.setHeader("Content-Type", "application/json;charset=UTF-8");

        CloseableHttpResponse response = null;
        try {
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            System.out.println("POST ENTITY DURATION " + (end - start));

            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }

    }

    /**
     * POST 添加 url 参数
     */
    public void doPostWithParam() {
        // 1. 获取 httpclient
        CloseableHttpClient httpClient = HttpClientBuilder.create().build();

        // 2. 请求参数
        StringBuilder param = new StringBuilder(128);

        try {
            // 参数编码
            param.append("name=").append(URLEncoder.encode("名称", "UTF-8"));
            param.append("&");
            param.append("age=100");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        // 3. 创建 POST 请求
        HttpPost httpPost = new HttpPost("http://localhost:9000/spring/hello/postWithParam?" + param);

        // 4. 设置请求头信息 , 设置ContentType(注:如果只是传普通参数的话,ContentType不一定非要用application/json)
        httpPost.setHeader("Content-Type", "application/json;charset=UTF-8");

        // 5. 响应模型
        CloseableHttpResponse response = null;

        try {
            // 6. httpclient 发送请求
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            System.out.println("POST With Param duration time " + (end - start));

            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }

    }

    /**
     * POST 不带参数
     */
    public void doPostNoParam() {
        // 1. 获取 httpclient 客户端
        CloseableHttpClient httpClient = HttpClientBuilder.create().build();

        // 2. 创建 POST 请求
        HttpPost httpPost = new HttpPost("http://localhost:9000/spring/hello/postNoParam");

        // 3. 创建响应模型
        CloseableHttpResponse response = null;

        try {
            // 4. 有 httpclient 发起请求
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            System.out.println("POST 请求用时 " + (end - start));

            // 5. 获取响应实体
            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }
    }

    /**
     * GET -- GET 请求传递参数
     */
    public void doGetWithParam() {

        CloseableHttpClient httpClient = HttpClients.createDefault();

        // 参数
        StringBuilder param = new StringBuilder(128);
        try {
            // 字符数据最好 encoding 以下;这样一来，某些特殊字符才能传过去(如:某人的名字就是“&”,不encoding的话,传不过去)
            param.append("name=").append(URLEncoder.encode("你好", "UTF-8"));
            param.append("&");
            param.append("age=100");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        // 创建 GET 请求
        HttpGet httpGet = new HttpGet("http://localhost:9000/spring/hello/getParams?" + param);

        // 响应信息
        CloseableHttpResponse response = null;

        // 配置请求信息
        RequestConfig requestConfig = RequestConfig.custom()
                .setConnectTimeout(5000) // 设置连接超时时间 (单位: 毫秒)
                .setConnectionRequestTimeout(5000) // 设置请求超时时间 (单位: 毫秒)
                .setSocketTimeout(5000) // 设置 socket 读写超时时间 (单位: 毫秒)
                .setRedirectsEnabled(true) // 是否允许重定向
                .build();

        // 应用请求配置到此次 GET 请求
        httpGet.setConfig(requestConfig);

        try {
            long start = System.currentTimeMillis();
            // 发送 GET 请求 (httpclient 客户端)
            response = httpClient.execute(httpGet);
            long end = System.currentTimeMillis();
            System.out.println("GET 请求用时 " + (end - start));

            // 解析响应数据
            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResources(response, httpClient);
        }

    }

    private void showAllHeaders(Header[] allHeaders) {
        if (null == allHeaders || allHeaders.length == 0) { return; }

        System.out.println("------ Headers Start ------");
        for (Header header : allHeaders) {
            System.out.println(header.getName() + " : " + header.getValue());
        }
        System.out.println("------ Headers End ------");
    }

    private void printRequestResponse(CloseableHttpResponse response, HttpEntity entity) {
        System.out.println("响应状态: " + response.getStatusLine());

        Header[] allHeaders = response.getAllHeaders();
        showAllHeaders(allHeaders);

        // 6. 解析返回的请求数据
        if (null != entity) {
            System.out.println("响应数据长度: " + entity.getContentLength());
            Header contentType = entity.getContentType();
            System.out.println("contentType name " + contentType.getName() + " value " + contentType.getValue());

                /*System.out.println("响应内容: " + EntityUtils.toString(entity, StandardCharsets.UTF_8));*/

            InputStream content = null;
            try {
                content = entity.getContent();

                final Reader reader = new InputStreamReader(content, StandardCharsets.UTF_8);
                final CharArrayBuffer charArrayBuffer = new CharArrayBuffer(4096);
                final char[] buffer = new char[1024];
                int len;
                while ((len = reader.read(buffer)) != -1) {
                    charArrayBuffer.append(buffer, 0, len);
                }

                System.out.println("返回解析 : " + charArrayBuffer.toString());
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (null != content) {
                    try {
                        content.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    private void closeHttpResources(CloseableHttpResponse response, CloseableHttpClient client) {
        closeHttpResponse(response);
        closeHttpClient(client);
    }

    private void closeHttpClient(CloseableHttpClient client) {
        if (null != client) {
            try {
                client.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void closeHttpResponse(CloseableHttpResponse response) {
        if (null != response) {
            try {
                response.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * GET -- 无参
     */
    public void doGetNoParam() {
        // 1. 获取 httpclient 的客户端
        CloseableHttpClient httpClient = HttpClients.createDefault();
        // 等价于 HttpClientBuilder.create().build();

        // 2. 创建 GET 请求
        HttpGet httpGet = new HttpGet("http://localhost:9000/spring/hello/hei");

        // 3. 获取响应模型
        CloseableHttpResponse response = null;

        try {
            long start = System.currentTimeMillis();
            // 4. 客户端发起请求
            response = httpClient.execute(httpGet);

            long end = System.currentTimeMillis();
            System.out.println("duration time : " + (end - start));

            // 5. 解析响应实体
            HttpEntity entity = response.getEntity();
            printRequestResponse(response, entity);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            // 7. 关闭资源
            if (null != httpClient) {
                try {
                    httpClient.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            if (null != response) {
                try {
                    response.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

        }
    }

}
