[java 运行参数](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html)

测试代码

```java
    /**
     * VM参数：-verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8
     */
    @SuppressWarnings("unused")
    public static void testAllocation() {
        byte[] allocation1 = new byte[2 * _1MB];
        byte[] allocation2 = new byte[2 * _1MB];
        byte[] allocation3 = new byte[2 * _1MB];
        byte[] allocation4 = new byte[4 * _1MB];  // 出现一次Minor GC
    }

    /**
     * VM参数：-verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8
     * -XX:PretenureSizeThreshold=3145728
     */
    @SuppressWarnings("unused")
    public static void testPretenureSizeThreshold() {
        byte[] allocation = new byte[4 * _1MB];  //直接分配在老年代中
    }

    /**
     * VM参数：-verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=1
     * -XX:+PrintTenuringDistribution
     */
    @SuppressWarnings("unused")
    public static void testTenuringThreshold() {
        byte[] allocation1 = new byte[_1MB / 4];  // 什么时候进入老年代决定于XX:MaxTenuringThreshold设置
        byte[] allocation2 = new byte[4 * _1MB];
        byte[] allocation3 = new byte[4 * _1MB];
        allocation3 = null;
        allocation3 = new byte[4 * _1MB];
    }

    /**
     * VM参数：-verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=15
     * -XX:+PrintTenuringDistribution
     */
    @SuppressWarnings("unused")
    public static void testTenuringThreshold2() {
        byte[] allocation1 = new byte[_1MB / 4];   // allocation1+allocation2大于survivo空间一半
        byte[] allocation2 = new byte[_1MB / 4];
        byte[] allocation3 = new byte[4 * _1MB];
        byte[] allocation4 = new byte[4 * _1MB];
        allocation4 = null;
        allocation4 = new byte[4 * _1MB];
    }

    /**
     * VM参数：-verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails -XX:SurvivorRatio=8 -XX:-HandlePromotionFailure
     */
    @SuppressWarnings("unused")
    public static void testHandlePromotion() {
        byte[] allocation1 = new byte[2 * _1MB];
        byte[] allocation2 = new byte[2 * _1MB];
        byte[] allocation3 = new byte[2 * _1MB];
        allocation1 = null;
        byte[] allocation4 = new byte[2 * _1MB];
        byte[] allocation5 = new byte[2 * _1MB];
        byte[] allocation6 = new byte[2 * _1MB];
        allocation4 = null;
        allocation5 = null;
        allocation6 = null;
        byte[] allocation7 = new byte[2 * _1MB];
    }
```



### UseParNewGC

`-XX:+UseParNewGC`

启用在年轻代中使用并行（parallel）线程进行收集。

当使用参数 `-XX:+UseConcMarkSweepGC` 时会自动使用该年轻代 *GC*  收集器。

**注意：**在 JDK 8 中不推荐使用 `-XX:+UseParNewGC` 选项而不使用 `-XX:+UseConcMarkSweepGC` 选项。

### UseConcMarkSweepGC

老年代 `-XX:+UseConcMarkSweepGC`  （concurrent mark-sweep - CMS）

新生代 `-XX:+UseParNewGC` （par new）[参数会被自动添加]

响应时间（暂停时间）垃圾收集器 （产生内存碎片，Full GC）

```
[GC (Allocation Failure) [ParNew: 16703K->1024K(18432K), 0.0005533 secs] 17427K->1747K(28672K), 0.0005694 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]

Heap
 par new generation   total 18432K, used 14984K [0x00000000fe200000, 0x00000000ff600000, 0x00000000ff600000)
  eden space 16384K,  85% used [0x00000000fe200000, 0x00000000fefa2078, 0x00000000ff200000)
  from space 2048K,  50% used [0x00000000ff200000, 0x00000000ff300010, 0x00000000ff400000)
  to   space 2048K,   0% used [0x00000000ff400000, 0x00000000ff400000, 0x00000000ff600000)
 concurrent mark-sweep generation total 10240K, used 723K [0x00000000ff600000, 0x0000000100000000, 0x0000000100000000)
 Metaspace       used 3281K, capacity 4496K, committed 4864K, reserved 1056768K
  class space    used 357K, capacity 388K, committed 512K, reserved 1048576K
```



### UseParallelGC

jdk1.8 默认，吞吐量收集器，`-XX:+UseParallelOldGC` 参数会被自动添加

`-XX:+UseParallelGC` - (PSYoungGen / ParOldGen) 吞吐量

```
[GC (Allocation Failure) [ParNew: 7328K->0K(9216K), 0.0004638 secs] 19316K->13012K(29696K), 0.0004822 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (CMS Initial Mark) [1 CMS-initial-mark: 13012K(20480K)] 14036K(29696K), 0.0004851 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-mark-start]
[GC (Allocation Failure) [ParNew: 7328K->0K(9216K), 0.0004588 secs] 20340K->14036K(29696K), 0.0004794 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [ParNew: 7328K->0K(9216K), 0.0004420 secs] 21364K->15060K(29696K), 0.0004713 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-mark: 0.002/0.003 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-preclean-start]

Heap
 PSYoungGen      total 17920K, used 5767K [0x00000000fec00000, 0x0000000100000000, 0x0000000100000000)
  eden space 16384K, 28% used [0x00000000fec00000,0x00000000ff0a1f00,0x00000000ffc00000)
  from space 1536K, 66% used [0x00000000ffc00000,0x00000000ffd00010,0x00000000ffd80000)
  to   space 2560K, 0% used [0x00000000ffd80000,0x00000000ffd80000,0x0000000100000000)
 ParOldGen       total 10240K, used 737K [0x00000000fe200000, 0x00000000fec00000, 0x00000000fec00000)
  object space 10240K, 7% used [0x00000000fe200000,0x00000000fe2b8498,0x00000000fec00000)
 Metaspace       used 3283K, capacity 4496K, committed 4864K, reserved 1056768K
  class space    used 357K, capacity 388K, committed 512K, reserved 1048576K
```



### G1

garbage-first (G1) 垃圾收集器。高概率满足 GC 暂停时间目标，同时保持良好的吞吐量。

针对对多核处理器（multiprocessor）、大容量内存（RAM）的服务器。堆（heap）大小在 6GB 左右或者更大，GC 延迟要求有限（稳定且可预测的暂停时间低于 0.5 秒）。

`-XX:+UseG1GC`

```
[GC pause (G1 Humongous Allocation) (young) (initial-mark), 0.0012029 secs]
   [Parallel Time: 1.0 ms, GC Workers: 4]
      [GC Worker Start (ms): Min: 152.1, Avg: 152.3, Max: 152.5, Diff: 0.4]
      [Ext Root Scanning (ms): Min: 0.0, Avg: 0.3, Max: 0.7, Diff: 0.7, Sum: 1.4]
      [Update RS (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.0]
         [Processed Buffers: Min: 0, Avg: 0.0, Max: 0, Diff: 0, Sum: 0]
      [Scan RS (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.0]
      [Code Root Scanning (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.0]
      [Object Copy (ms): Min: 0.2, Avg: 0.4, Max: 0.5, Diff: 0.3, Sum: 1.7]
      [Termination (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.0]
         [Termination Attempts: Min: 1, Avg: 1.0, Max: 1, Diff: 0, Sum: 4]
      [GC Worker Other (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.1]
      [GC Worker Total (ms): Min: 0.5, Avg: 0.8, Max: 0.9, Diff: 0.4, Sum: 3.1]
      [GC Worker End (ms): Min: 153.0, Avg: 153.0, Max: 153.0, Diff: 0.0]
   [Code Root Fixup: 0.0 ms]
   [Code Root Purge: 0.0 ms]
   [Clear CT: 0.0 ms]
   [Other: 0.2 ms]
      [Choose CSet: 0.0 ms]
      [Ref Proc: 0.1 ms]
      [Ref Enq: 0.0 ms]
      [Redirty Cards: 0.0 ms]
      [Humongous Register: 0.0 ms]
      [Humongous Reclaim: 0.0 ms]
      [Free CSet: 0.0 ms]
   [Eden: 3072.0K(20.0M)->0.0B(19.0M) Survivors: 0.0B->1024.0K Heap: 10045.4K(30.0M)->1890.6K(30.0M)]
 [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC concurrent-root-region-scan-start]
[GC concurrent-root-region-scan-end, 0.0009729 secs]
[GC concurrent-mark-start]
[GC concurrent-mark-end, 0.0000222 secs]
[GC remark [Finalize Marking, 0.0000517 secs] [GC ref-proc, 0.0000323 secs] [Unloading, 0.0005093 secs], 0.0006563 secs]
 [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC cleanup 10082K->10082K(30M), 0.0001555 secs]
 [Times: user=0.00 sys=0.00, real=0.00 secs] 
```

