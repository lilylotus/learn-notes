package cn.lifecycle.redisutil;

import com.sun.xml.internal.messaging.saaj.util.ByteInputStream;
import com.sun.xml.internal.messaging.saaj.util.ByteOutputStream;
import redis.clients.jedis.Jedis;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Collection;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * Created by yzx on 2019/5/9.
 */
public class JedisKeys {

    private static JedisKeys jedisKeys;
    private JedisOpUtils jedisOpUtils;
    private JedisKeys() { if (null == jedisOpUtils) { jedisOpUtils = JedisOpUtils.getInstance(); }}

    public static JedisKeys getInstance() {
        if (null == jedisKeys) {
            synchronized (JedisKeys.class) {
                if (null == jedisKeys) { jedisKeys = new JedisKeys(); }
            }
        }
        return jedisKeys;
    }

    public void  delete(String key) {
        if (JedisOpUtils.isNull(key)) { return; }
        Jedis jedis = jedisOpUtils.getResources();
        jedis.del(key);
        jedisOpUtils.releaseJedis(jedis);
    }

    public void delete(Collection<String> keys) {
        if (null == keys) { return; }
        Jedis jedis = jedisOpUtils.getResources();
        for (String key : keys) { jedis.del(key); }
        jedisOpUtils.releaseJedis(jedis);
    }

    public byte[] dump(String key) throws IOException {
        if (JedisOpUtils.isNull(key)) { return null; }
        ByteOutputStream bos = new ByteOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(bos);
        oos.writeObject(key);
        byte[] data = bos.getBytes();
        oos.close();
        bos.close();
        return data;
    }

    public String deDump(byte[] key) throws IOException, ClassNotFoundException {
        if (null == key) { return null; }
        ByteInputStream bis = new ByteInputStream(key, key.length);
        ObjectInputStream ois = new ObjectInputStream(bis);
        String keyObj = (String)ois.readObject();
        ois.close();
        bis.close();
        return keyObj;
    }

    public boolean hasKey(String key) {
        if (JedisOpUtils.isNull(key)) { return false; }
        Jedis jedis = jedisOpUtils.getResources();
        boolean exist = jedis.exists(key);
        jedisOpUtils.releaseJedis(jedis);
        return exist;
    }

    public boolean expire(String key, int time, TimeUnit timeUnit) {
        if (JedisOpUtils.isNull(key)) { return false; }
        Jedis jedis = jedisOpUtils.getResources();
        int expireTime;
        switch (timeUnit) {
            case SECONDS: expireTime = time; break;
            case MINUTES: expireTime = time * 60; break;
            case HOURS: expireTime = time * 60 * 60; break;
            case DAYS: expireTime = time * 60 * 60 * 24; break;
            default: expireTime = time;
        }
        Long expire = jedis.expire(key, expireTime);
        jedisOpUtils.releaseJedis(jedis);
        return  expire == 1;
    }

    public Set<String> keys(String pattern) {
        if (JedisOpUtils.isNull(pattern)) { return null; }
        Jedis jedis = jedisOpUtils.getResources();
        Set<String> keys = jedis.keys(pattern);
        jedisOpUtils.releaseJedis(jedis);
        return keys;
    }

    public boolean move(String key, int dbIndex) {
        if (JedisOpUtils.isNull(key)) { return false; }
        Jedis jedis = jedisOpUtils.getResources();
        Long move = jedis.move(key, dbIndex);
        jedisOpUtils.releaseJedis(jedis);
        return 1 == move;
    }

    public boolean persist(String key) {
        if (JedisOpUtils.isNull(key)) { return false; }
        Jedis jedis = jedisOpUtils.getResources();
        Long expire = jedis.persist(key);
        jedisOpUtils.releaseJedis(jedis);
        return 1 == expire;
    }

    public long getExpire(String key, TimeUnit timeUnit) {
        if (JedisOpUtils.isNull(key)) { return -1; }
        Jedis jedis = jedisOpUtils.getResources();
        long expire = jedis.ttl(key);
        jedisOpUtils.releaseJedis(jedis);
        if (-1 == expire) { return expire; }
        switch (timeUnit) {
            case MINUTES: expire = expire / 60; break;
            case HOURS: expire = expire / 60 / 60; break;
            case DAYS: expire = expire / 60 / 60 / 24; break;
            default: expire = expire;
        }
        return expire;
    }

    public String random() {
        Jedis jedis = jedisOpUtils.getResources();
        String key = jedis.randomKey();
        jedisOpUtils.releaseJedis(jedis);
        return key;
    }

    public void rename(String oldKey, String newKey) {
        Jedis jedis = jedisOpUtils.getResources();
        jedis.rename(oldKey, newKey);
        jedisOpUtils.releaseJedis(jedis);
    }

    public boolean renameIfAbsent(String oldKey, String newKey) {
        Jedis jedis = jedisOpUtils.getResources();
        Long renamenx = jedis.renamenx(oldKey, newKey);
        jedisOpUtils.releaseJedis(jedis);
        return 1 == renamenx;
    }

    public String type(String key) {
        if (JedisOpUtils.isNull(key)) { return null; }
        Jedis jedis = jedisOpUtils.getResources();
        String type = jedis.type(key);
        jedisOpUtils.releaseJedis(jedis);
        return type;
    }

}
