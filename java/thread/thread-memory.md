影响线程数量的因素：

```java
-Xms intial java heap size
-Xmx maximum java heap size
-Xss the stack size for each thread
系统限制 系统最大可开线程数
    
public class TestThread extends Thread {
    private static final AtomicInteger count = new AtomicInteger();
    public static void main(String[] args) {
        while (true) { (new TestThread()).start();}
    }
    @Override
    public void run() {
        System.out.println(count.incrementAndGet());
        while (true) {
            try { Thread.sleep(Integer.MAX_VALUE); }
            catch (InterruptedException e) { break; }
        }
    }
}

不考虑系统限制
-Xms    -Xmx    -Xss    结果
1024m   1024m   1024k   1737
1024m   1024m   64k     26077
512m    512m    64k     31842
256m    256m    64k     31842
```

由上面的测试结果可以看出增大堆内存（-Xms，-Xmx）会减少可创建的线程数量，
增大线程栈内存（-Xss，32位系统中此参数值最小为 60K）也会减少可创建的线程数量。

这个问题总算完满解决，最后总结下影响Java线程数量的因素：
    Java虚拟机本身：-Xms，-Xmx，-Xss；
    系统限制：
        /proc/sys/kernel/pid_max，
        /proc/sys/kernel/thread-max，
        max_user_process（ulimit -u），
        /proc/sys/vm/max_map_count。