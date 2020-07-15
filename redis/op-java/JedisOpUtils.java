package cn.lifecycle.redisutil;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

/**
 * Created by yzx on 2019/5/9.
 */
public class JedisOpUtils {
    /*static {
        JedisPoolConfig config = new JedisPoolConfig();
        String host = "127.0.0.1";
        String password = "redis";
        int port = 6379;

        config.setMaxIdle(10);
        config.setMaxTotal(600);
        config.setMaxWaitMillis(1000);
        config.setTestOnBorrow(true);

        jedisPool = new JedisPool(config, host, port, 1000, password);
    }*/

    public static JedisOpUtils getInstance() {
        if (null == jedisUtils) {
            synchronized (JedisOpUtils.class) {
                if (null == jedisUtils) {
                    JedisPoolConfig config = new JedisPoolConfig();
                    config.setMaxIdle(10);
                    config.setMaxTotal(600);
                    config.setMaxWaitMillis(1000);
                    config.setTestOnBorrow(true);
                    jedisPool = new JedisPool(config, "127.0.0.1", 6379, 1000, "redis", 10);
                    jedisUtils = new JedisOpUtils();
                }
            }
        }
        return jedisUtils;
    }

    private static JedisPool jedisPool;
    private static JedisOpUtils jedisUtils;
    private JedisOpUtils() {}
    public Jedis getResources() { return jedisPool.getResource(); }
    public void releaseJedis(Jedis jedis) { if (null != jedis && null != jedisPool) { jedis.close(); } }
    public void releaseJedisPool() { if (null != jedisPool) { jedisPool.close(); } }

    public static boolean isNull(String key) { return null == key || "".equals(key.trim()); }

}
