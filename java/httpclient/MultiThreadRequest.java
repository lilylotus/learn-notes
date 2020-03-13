package cn.nihility.httpclient;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * @author yzx
 * @date 2019-10-31 16:38
 */
public class MultiThreadRequest {

    public static void main(String[] args) {

        Map<String, String> doPostMap = new HashMap<>(16);
        doPostMap.put("name", "Get名称");
        doPostMap.put("age", "1234");

        final String url = "http://localhost:9000/spring/hello/session";

        PooledHttpClient01 instance = PooledHttpClient01.getInstance();
        int multiCount = 100;

        multi(instance, multiCount, url, doPostMap);

        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("============================= 新一轮开始");

        multi(instance, multiCount, url, doPostMap);

        instance.shutdown();

    }

    public static void multi(final PooledHttpClient01 instance, final int multiCount,
                             final String url, final Map<String, String> doPostMap) {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(100, 2000, 30L, TimeUnit.SECONDS, new ArrayBlockingQueue<>(4000));
        CountDownLatch countDownLatch = new CountDownLatch(multiCount);
        long start = System.currentTimeMillis();

        for (int i = 0; i < multiCount; i++) {
            executor.execute(() -> {
                instance.doPost(url, doPostMap);
                countDownLatch.countDown();
            });
        }

        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        long end = System.currentTimeMillis();

        System.out.println("Duration time [" + (end - start) + "]");

        executor.shutdown();
    }

}
