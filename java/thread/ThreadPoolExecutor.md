##### 关闭线程池

`java.util.concurrent.Executors`

```java
ExecutorService executorService = Executors.newCachedThreadPool();
executorService.shutdown();
```

> 当没有调用 *shutdown()* 方法的时候，主线程是不会退出的，因为线程池默认的 `Executors.defaultThreadFactory()` 创建的现场是用户线程。`if (t.isDaemon()) t.setDaemon(false);`