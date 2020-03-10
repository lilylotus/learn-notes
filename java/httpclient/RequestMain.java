package cn.nihility.httpclient;

import com.alibaba.fastjson.JSON;

import java.util.HashMap;
import java.util.Map;

/**
 * @author yzx
 * @date 2019-10-30 14:39
 */
public class RequestMain {

    public static void main(String[] args) {
        Map<String, String> doGetMap = new HashMap<>(16);
        doGetMap.put("name", "Get名称");
        doGetMap.put("age", "1234");

        Map<String, String> postMap = new HashMap<>(16);
        postMap.put("name", "POST名称");
        postMap.put("age", "1200");

        Map<String, String> post2Map = new HashMap<>(16);
        post2Map.put("flag", "400");
        post2Map.put("meaning", "什么玩意?");

        Map<String, String> fileMap = new HashMap<>(16);
        fileMap.put("E:\\log\\BingWallpaper-2019-02-25.jpg", "必应壁纸.JPG");
        fileMap.put("E:\\log\\th.jpg", "什么玩意.JPG");
        fileMap.put("E:\\log\\mc.gif", "MAC.GIF");


        User user = new User();
        user.setAge(100);
        user.setName("潘婷");
        user.setGender("女");
        user.setMotto("不要喝水吃饭");
//        post2Map.put("user", JSON.toJSONString(user));

        Map<String, String> headerMap = new HashMap<>(16);
        headerMap.put("Content-Type", "application/json;charset=UTF-8");

        Map<String, String> header2Map = new HashMap<>(16);
        header2Map.put("Content-Type", "text/plain;charset=UTF-8");

        PooledHttpClient01 pooledHttpClient01 = new PooledHttpClient01();

        pooledHttpClient01.doGet("http://localhost:9000/spring/hello/hei");
        pooledHttpClient01.doGet("http://localhost:9000/spring/hello/getParams", doGetMap);
        pooledHttpClient01.doGet("http://localhost:9000/spring/hello/getParams", headerMap, doGetMap);

        System.out.println("===================================");


        pooledHttpClient01.doPost("http://localhost:9000/spring/hello/postNoParam");
        pooledHttpClient01.doPost("http://localhost:9000/spring/hello/postWithParam", postMap); // 不能有表头
        pooledHttpClient01.doPost("http://localhost:9000/spring/hello/doPostMultiParam", headerMap, post2Map, JSON.toJSONString(user));
        pooledHttpClient01.doPost("http://localhost:9000/spring/hello/postWithParamFile", null, postMap, fileMap, null); // 没有表头

        try {
            Thread.sleep(3000L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        pooledHttpClient01.shutdown();

    }

}
