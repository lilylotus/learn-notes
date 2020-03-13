package cn.nihility.httpclient;

import org.apache.http.*;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.ConnectionKeepAliveStrategy;
import org.apache.http.conn.HttpClientConnectionManager;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.message.BasicHeaderElementIterator;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 当流量为0时, 你会发现存在处于 ClOSE_WAIT 的连接. 究其原因是, httpclient 清理过期/被动关闭的 socket 采用懒惰清理的策略.
 * 它是在连接从连接池取出使用的时候, 检测状态并做相应处理. 如果没有流量, 那这些socket将一直处于 CLOSE_WAIT (半连接的状态), 系统资源被浪费.
 * 解决方案，官方的建议引入一个清理线程, 定期主动处理过期/空闲连接, 这样就 OK 了
 *
 * @author yzx
 * @date 2019-10-29 18:28
 */
public class PooledHttpClient01 {

    private static final Logger logger = LoggerFactory.getLogger(PooledHttpClient01.class);

    // 连接池的最大连接数
    private static final int DEFAULT_POOL_MAX_TOTAL = 500;
    // 连接池按route配置的最大连接数
    private static final int DEFAULT_POOL_MAX_PER_ROUTE = 50;
    // tcp connect的超时时间
    private static final int DEFAULT_CONNECT_TIMEOUT = 30000;
    // 从连接池获取连接的超时时间
    private static final int DEFAULT_CONNECT_REQUEST_TIMEOUT = 10000;
    // tcp io的读写超时时间
    private static final int DEFAULT_SOCKET_TIMEOUT = 60000;

    private static volatile PooledHttpClient01 pooledHttpClient01;

    private PoolingHttpClientConnectionManager phccm;
    private RequestConfig requestConfig;
    private ConnectionKeepAliveStrategy strategy;
    private IdleConnectionMonitorThread idleThread;

    private CloseableHttpClient httpClient;

    private PooledHttpClient01() {
        Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory>create()
                .register("http", PlainConnectionSocketFactory.getSocketFactory())
                .register("https", SSLConnectionSocketFactory.getSocketFactory())
                .build();

        phccm = new PoolingHttpClientConnectionManager(registry);
        phccm.setMaxTotal(DEFAULT_POOL_MAX_TOTAL);
        phccm.setDefaultMaxPerRoute(DEFAULT_POOL_MAX_PER_ROUTE);

        requestConfig = RequestConfig.custom()
                .setConnectTimeout(DEFAULT_CONNECT_TIMEOUT)                   // 设置连接超时
                .setSocketTimeout(DEFAULT_SOCKET_TIMEOUT)                     // 设置读取超时
                .setConnectionRequestTimeout(DEFAULT_CONNECT_REQUEST_TIMEOUT) // 设置从连接池获取连接实例的超时
                .build();

        strategy = (response, context) -> {
            HeaderElementIterator it = new BasicHeaderElementIterator
                    (response.headerIterator(HTTP.CONN_KEEP_ALIVE));
            while (it.hasNext()) {
                HeaderElement he = it.nextElement();
                String param = he.getName();
                String value = he.getValue();
                if (value != null && param.equalsIgnoreCase("timeout")) {
                    return Long.parseLong(value) * 1000;
                }
            }
            //如果没有约定，则默认定义时长为60s
            return 60 * 1000L;
        };

        httpClient = HttpClients.custom()
                .setConnectionManager(phccm)
                .setDefaultRequestConfig(requestConfig)
                .setKeepAliveStrategy(strategy)
                .build();

        idleThread = new IdleConnectionMonitorThread(phccm);
        idleThread.start();
    }

    public static PooledHttpClient01 getInstance() {

        if (pooledHttpClient01 == null) {
            synchronized (PooledHttpClient01.class) {
                if (pooledHttpClient01 == null) {
                    pooledHttpClient01 = new PooledHttpClient01();
                }
            }
        }

        return pooledHttpClient01;
    }

    private CloseableHttpClient getHttpClient() {
        return HttpClients.custom()
                .setConnectionManager(phccm)
                .setDefaultRequestConfig(requestConfig)
                .setKeepAliveStrategy(strategy)
                .build();

        /*return httpClient;*/
    }

    public void shutdown() {
        idleThread.shutdown();
    }

    public void doPost(String url, Map<String, String> headers, Map<String, String> params, String bodyString) {
        doPost(url, headers, params, null, bodyString);
    }

    public void doPost(String url, Map<String, String> headers, Map<String, String> params) {
        doPost(url, headers, params, null, null);
    }

    public void doPost(String url, Map<String, String> params) {
        doPost(url, null, params, null, null);
    }

    public void doPost(String url) {
        doPost(url, null, null, null, null);
    }

    public void doPost(String url, Map<String, String> headers,
                       Map<String, String> params, Map<String, String> uploadFilePathMapName,
                       String bodyString) {

        logger.info("********** {} Start **********", url);

        HttpPost httpPost;

        // 添加上传文件
        if (null != uploadFilePathMapName && uploadFilePathMapName.size() > 0) {
            httpPost = new HttpPost(url);
            MultipartEntityBuilder multipartEntityBuilder = MultipartEntityBuilder.create();

            buildBinaryBody(multipartEntityBuilder, uploadFilePathMapName);
            // 配置请求参数
            buildTextBody(multipartEntityBuilder, params);

            httpPost.setEntity(multipartEntityBuilder.build());
        } else {
            if (null != bodyString && !"".equals(bodyString)) {
                String urlWithParams = getUrlWithParams(url, params);
                httpPost = new HttpPost(urlWithParams);

                StringEntity stringEntity = new StringEntity(bodyString, StandardCharsets.UTF_8);
                httpPost.setEntity(stringEntity);
            } else {
                httpPost = new HttpPost(url);
                if (null != params && params.size() > 0) {
                    httpPost.setEntity(getUrlEncodedFromEntity(params));
                }
            }
        }

        // 添加请求头配置
        if (null != headers && headers.size() > 0) {
            for (Map.Entry<String, String> entry : headers.entrySet()) {
                httpPost.addHeader(entry.getKey(), entry.getValue());
            }
        }

        logger.info("---------- request headers start ----------");
        Header[] allHeaders = httpPost.getAllHeaders();
        showAllHeaders(allHeaders);
        logger.info("---------- request headers end ----------");

        CloseableHttpResponse response = null;
        CloseableHttpClient httpClient = getHttpClient();
        try {
            logger.info("POST 请求 httpclient 实例 [{}]", httpClient);
            // 执行请求
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpPost);
            long end = System.currentTimeMillis();
            logger.info("POST 请求 URL [{}] 用时 [{}]", url, (end - start));

            /*logger.info("********** Cookies Start **********");
            for (Cookie cookie : cookies) {
                logger.info("Cookie Name [{}], Value [{}], Expire [{}]", cookie.getName(), cookie.getValue(), cookie.getExpiryDate());
            }
            logger.info("********** Cookies End **********");*/

            if (response == null || response.getStatusLine() == null) {
                logger.error("POST 请求 URL [{}] 请求失败", url);
            } else {
                printRequestResponse(response, response.getEntity());
            }

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeHttpResponse(response);
            /*closeHttpClient(httpClient);*/
        }

        logger.info("********** {} End **********", url);

    }

    private void buildBinaryBody(MultipartEntityBuilder multipartEntityBuilder, Map<String, String> uploadFilePathMapName) {
        if (null == uploadFilePathMapName || uploadFilePathMapName.size() == 0) { return; }
        try {
            for (Map.Entry<String, String> entry : uploadFilePathMapName.entrySet()) {
                multipartEntityBuilder.addBinaryBody("files", new File(entry.getKey()),
                        ContentType.DEFAULT_BINARY, URLEncoder.encode(entry.getValue(), "UTF-8"));
            }
        } catch (UnsupportedEncodingException ex) {
            ex.printStackTrace();
        }
    }

    private void buildTextBody(MultipartEntityBuilder multipartEntityBuilder, Map<String, String> params) {

        if (null == params || params.size() == 0) { return; }

        ContentType contentType = ContentType.create("text/plain", StandardCharsets.UTF_8);

        for (Map.Entry<String, String> entry : params.entrySet()) {
            multipartEntityBuilder.addTextBody(entry.getKey(), entry.getValue(), contentType);
        }

    }

    public void doGet(String url) {
        doGet(url, Collections.EMPTY_MAP, Collections.EMPTY_MAP);
    }

    public void doGet(String url, Map<String, String> params) {
        doGet(url, Collections.EMPTY_MAP, params);
    }

    public void doGet(String url, Map<String, String> headers, Map<String, String> params) {

        logger.info("********** {} Start **********", url);

        // 配置表头
        String reqUrl;
        if (null != params && params.size() > 0) {
            reqUrl = getUrlWithParams(url, params);
            logger.info("GET 请求重置参数 URL = [{}]", reqUrl);
        } else {
            reqUrl = url;
        }

        HttpGet httpGet = new HttpGet(reqUrl);

        // 添加请求头配置
        if (null != headers && headers.size() > 0) {
            for (Map.Entry<String, String> entry : headers.entrySet()) {
                httpGet.addHeader(entry.getKey(), entry.getValue());
            }
        }

        CloseableHttpResponse response = null;
        try {
            CloseableHttpClient httpClient = getHttpClient();
            logger.info("GET 请求 httpclient 实例 [{}]", httpClient);
            // 执行请求
            long start = System.currentTimeMillis();
            response = httpClient.execute(httpGet);
            long end = System.currentTimeMillis();
            logger.info("GET 请求 URL [{}] 用时 [{}]", url, (end - start));


            if (response == null || response.getStatusLine() == null) {
                logger.error("GET 请求 URL [{}] 请求失败", reqUrl);
            } else {
                printRequestResponse(response, response.getEntity());
            }

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
           closeHttpResponse(response);
        }

        logger.info("********** {} End **********", url);
    }

    private void printRequestResponse(CloseableHttpResponse response, HttpEntity entity) {
        logger.info("响应状态 [{}]", response.getStatusLine());

        logger.info("---------- response headers start ----------");
        Header[] allHeaders = response.getAllHeaders();
        showAllHeaders(allHeaders);
        logger.info("---------- response headers end ----------");

        // 6. 解析返回的请求数据
        if (null != entity) {
            logger.info("响应数据长度 [{}]", entity.getContentLength());

            Header contentType = entity.getContentType();
            logger.info("ContentType Name [{}], Value [{}]", contentType.getName(), contentType.getValue());

            try {
                logger.info("响应内容 [{}]", EntityUtils.toString(entity, StandardCharsets.UTF_8));
            } catch (IOException e) {
                e.printStackTrace();
            }

            try {
                EntityUtils.consume(entity);
            } catch (IOException e) {
                e.printStackTrace();
            }

            /*HttpContext httpContext = new BasicHttpContext();
            httpContext.setAttribute("", "");*/

            /*InputStream content = null;
            try {
                content = entity.getContent();

                final Reader reader = new InputStreamReader(content, StandardCharsets.UTF_8);
                final CharArrayBuffer charArrayBuffer = new CharArrayBuffer(DEFAULT_BUFFER_SIZE);
                final char[] buffer = new char[1024];
                int len;
                while ((len = reader.read(buffer)) != -1) {
                    charArrayBuffer.append(buffer, 0, len);
                }

                body = charArrayBuffer.toString();
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
            }*/

        }
    }

    private void showAllHeaders(Header[] allHeaders) {
        if (null == allHeaders || allHeaders.length == 0) { return; }
        for (Header header : allHeaders) {
            logger.info("Header Name [{}], Value [{}]", header.getName(), header.getValue());
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

    private HttpEntity getUrlEncodedFromEntity(Map<String, String> params) {
        List<NameValuePair> pairList = new ArrayList<>(params.size());
        for (Map.Entry<String, String> entry : params.entrySet()) {
            pairList.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
        }
        return new UrlEncodedFormEntity(pairList, StandardCharsets.UTF_8);
    }

    private String getUrlWithParams(String url, Map<String, String> params) {
        if (null == params || params.size() == 0) { return url; }

        StringBuilder sb = new StringBuilder(url);
        boolean first = true;
        try {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                if (first) {
                    sb.append("?").append(entry.getKey())
                            .append("=").append(URLEncoder.encode(entry.getValue(), "UTF-8"));
                    first = false;
                } else {
                    sb.append("&").append(entry.getKey())
                            .append("=").append(URLEncoder.encode(entry.getValue(), "UTF-8"));
                }
            }
        } catch (UnsupportedEncodingException ex) {
            ex.printStackTrace();
        }
        logger.info("重组后的 URL [{}]", sb.toString());
        return sb.toString();
    }


    static class IdleConnectionMonitorThread extends Thread {
        private final HttpClientConnectionManager httpClientConnectionManager;
        private volatile boolean exitFlag = false;

        private IdleConnectionMonitorThread(HttpClientConnectionManager httpClientConnectionManager) {
            this.httpClientConnectionManager = httpClientConnectionManager;
            setDaemon(true);
        }

        @Override
        public void run() {
            while (!exitFlag) {
                synchronized (this) {
                    try {
                        wait(2000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    httpClientConnectionManager.closeExpiredConnections();
                    httpClientConnectionManager.closeIdleConnections(30, TimeUnit.SECONDS);
                    logger.info("清理空闲连接 ...");
                }
            }
        }

        private void shutdown() {
            this.exitFlag = true;
            synchronized (this) {
                notify();
            }
        }
    }

}
