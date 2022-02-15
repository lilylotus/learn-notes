[java 运行参数](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html)

| **GC Algorithm**                                            | **JVM argument**        |
| ----------------------------------------------------------- | ----------------------- |
| Serial GC                                                   | -XX:+UseSerialGC        |
| Parallel GC （Java 8 Default GC Algorithm）吞吐量           | -XX:+UseParallelGC      |
| Concurrent Market & Sweep (CMS) GC ，响应时间               | -XX:+UseConcMarkSweepGC |
| G1 GC （Java 9 Default gc algorithm），平衡吞吐量和响应时间 | -XX:+UseG1GC            |
| Shenandoah GC                                               | -XX:+UseShenandoahGC    |
| Z GC （ JVM 11+，性能极好）                                 | -XX:+UseZGC             |
| Epsilon GC                                                  | -XX:+UseEpsilonGC       |

### GC 常用参数

#### Old generation collectors:

- G1 - `-XX:+UseG1GC`
- ConcurrentMarkSweep - `-XX:+UseConcMarkSweepGC` （并发的、低暂停、cpu 敏感）
- Serial Old - `-XX:+UseSerialGC` （带压缩）
- Parallel Old

#### Young generation collectors:

- Serial (Copy) - `-XX:+UseSerialGC`
- Parallel Scavenge - `-XX:+UseParallelGC ` （jdk1.8 default）
- Parallel New - `-XX:+UseParNewGC` （串行 gc 的多线程版本）

年轻代为并发收集，可与 CMS 一同使用 : **`-XX:+UseParNewGC`** + **`-XX:+UseConcMarkSweepGC`**

-XX:+UseSerialGC         (Serial Old [MarkSweepCompact])
-XX:+UseParallelGC       (Parallel Scavenge [young], jdk1.8 default)
-XX:+UseConcMarkSweepGC  (ConcurrentMarkSweep [old])
    -XX:ConcGCThreads=4      Concurrent GC threads
    -XX:ParallelGCThreads=2  Parallel GC threads
-XX:+UseG1GC             (G1)

常用组合： -Xms1g -Xmx1g -Xmn512m -XX:+UseConcMarkSweepGC -XX:+CMSScavengeBeforeRemark -XX:+UseParNewGC

打印 GC 日志：
-XX:+PrintHeapAtGC        Print heap information at every gc
-XX:+PrintTenuringDistribution    Tenuring age information.
-XX:+PrintGCTimeStamps    Relative time stamp at the start of gc event
-XX:+PrintGCDateStamps    Calendar date stamp at the start of gc event
-Xloggc:gc.log

-Xms512m -Xmx512m -Xmn400m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCApplicationStoppedTime -XX:+PrintTenuringDistribution -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:gc.log

## GC 优化

#### JVM 内存结构

[JVM 内存优化参考文档](https://tech.meituan.com/2017/12/29/jvm-optimize.html)

主流虚拟机（Hotspot VM）的垃圾回收都采用“分代回收”的算法。

“分代回收”是基于这样一个事实：对象的生命周期不同，所以针对不同生命周期的对象可以采取不同的回收方式，以便提高回收效率。

Hotspot VM 将内存划分为不同的物理区，就是“分代”思想的体现。JVM 内存主要由新生代、老年代、永久代构成 （JDK1.8 变为了 MetaSpace）。

- 新生代的垃圾回收（又称 Minor GC）：其中很多对象的生命周期很短，垃圾回收后只有少量对象存活，所以选用复制算法，只需要少量的复制成本就可以完成回收。
- 老年代的垃圾回收（又称 Major GC）：区域中对象存活率高，通常使用“标记-清理”或“标记-整理”算法。
- 整堆包括新生代和老年代的垃圾回收称为 Full GC：（HotSpot VM 里，除了 CMS 之外，其它能收集老年代的 GC 都会同时收集整个 GC 堆，包括新生代）。

**注意：**各分区的大小对GC的性能影响很大。如何将各分区调整到合适的大小，分析活跃数据的大小是很好的切入点。

**活跃数据的大小**是指，应用程序稳定运行时长期存活对象在堆中占用的空间大小，也就是 Full GC 后堆中老年代占用空间的大小。可以通过 GC 日志中 Full GC 之后老年代数据大小得出，比较准确的方法是在程序稳定后，多次获取 GC 数据，通过取平均值的方式计算活跃数据的大小。活跃数据和各分区之间的比例关系如下：

| 空间   | 倍数                                    |
| :----- | :-------------------------------------- |
| 总大小 | **3-4** 倍活跃数据的大小                |
| 新生代 | **1-1.5** 活跃数据的大小                |
| 老年代 | **2-3** 倍活跃数据的大小                |
| 永久代 | **1.2-1.5** 倍Full GC后的永久代空间占用 |

#### 优化步骤

明确应用程序的系统需求是性能优化的基础，系统的需求是指应用程序运行时某方面的要求，譬如：

- 高可用，可用性达到几个 9。 
- 低延迟，请求必须多少毫秒内完成响应。 
- 高吞吐，每秒完成多少次事务。

明确系统需求之所以重要，是因为上述性能指标间可能冲突。比如通常情况下，缩小延迟的代价是降低吞吐量或者消耗更多的内存或者两者同时发生。

若是主要关注高可用和低延迟两项指标，如何量化 GC 时间和频率对于响应时间和可用性的影响。通过这个量化指标，可以计算出当前 GC 情况对服务的影响，也能评估出 GC 优化后对响应时间的收益，这两点对于低延迟服务很重要。

**例如在相同的内存分配率的前提下，新生代中的 Eden 区增加一倍，Minor GC 的次数就会减少一半。**

这时有这样的疑问，扩容 Eden 区虽然可以减少 Minor GC 的次数，但会增加单次 Minor GC 时间么？**Minor GC 时间更多取决于 GC 后存活对象的数量，而非 Eden 区的大小。**因此如果堆中短期对象很多，那么扩容新生代，单次 Minor GC 时间不会显著增加。

如何选择各分区大小应该依赖应用程序中**对象生命周期的分布情况：如果应用存在大量的短期对象，应该选择较大的年轻代；如果存在相对较多的持久对象，老年代应该适当增大。**

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

推荐使用的垃圾收集器组合： ParNew + CMS

老年代 `-XX:+UseConcMarkSweepGC`  （concurrent mark-sweep - CMS）

新生代 `-XX:+UseParNewGC` （par new）[参数会被自动添加]

#### CMS 的四个主要阶段

1. Init-mark 初始标记 (STW) ：该阶段进行可达性分析，标记 GC ROOT 能直接关联到的对象，所以很快。 
2. Concurrent-mark 并发标记：由前阶段标记过的对象出发，所有可到达的对象都在本阶段中标记。 
3. Remark 重标记 (STW) ：暂停所有用户线程，重新扫描堆中的对象，进行可达性分析，标记活着的对象。因为并发标记阶段是和用户线程并发执行的过程，所以该过程中可能有用户线程修改某些活跃对象的字段，指向了一个未标记过的对象，如下图中红色对象在并发标记开始时不可达，但是并行期间引用发生变化，变为对象可达，这个阶段需要重新标记出此类对象，防止在下一阶段被清理掉，这个过程也是需要 STW 的。**特别需要注意一点，这个阶段是以新生代中对象为根来判断对象是否存活的。** Remark 阶段必须扫描整个堆来判断对象是否存活，包括图中灰色的不可达对象。**为了修正并发标记期间因用户程序继续运作而导致标记产生变动的那一部分对象的标记记录**。
4. 并发清理，进行并发的垃圾清理。

#### CMS 垃圾收集器主要有三个问题：

1. 内存碎片（原因是采用了标记-清除算法）
2. 对 CPU 资源敏感（原因是并发时和用户线程一起抢占 CPU）
3. 浮动垃圾：在并发标记阶段产生了新垃圾不会被及时回收，而是只能等到下一次GC

[浮动垃圾的产生](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/cms.html)：第二次暂停是在并发跟踪阶段结束时进行的，它查找由于CMS收集器完成对对象的引用后，应用程序线程对对象中的引用进行更新而导致并发跟踪遗漏的对象。该第二暂停称为重新标记暂停。

**`-XX:CMSFullGCsBeforeCompaction`** ：设置在执行多少次 *Full GC* 后对内存空间进行压缩整理，默认是 0 就可以。

CMS 提供 **`CMSScavengeBeforeRemark`** 参数，用来保证 Remark 前强制进行一次 Minor GC。

总结来说，CMS 的设计聚焦在获取最短的时延，为此它“不遗余力”地做了很多工作，包括尽量让应用程序和 GC 线程并发、增加可中断的并发预清理阶段、引入卡表等，虽然这些操作牺牲了一定吞吐量但获得了更短的回收停顿时间。

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

G1 收集器的设计目标是取代 CMS 收集器，同 CMS 相比，在以下方面表现的更出色： 

- G1 是一个有整理内存过程的垃圾收集器，不会产生很多内存碎片。
-  G1 的 Stop The World(STW) 更可控，G1 在停顿时间上添加了预测机制，用户可以指定期望停顿时间。

garbage-first (G1) 垃圾收集器。高概率满足 GC 暂停时间目标，同时保持良好的吞吐量。

G1 提供了两种 GC 模式，Young GC 和 Mixed GC，两种都是完全 Stop The World 的。 

* Young GC：选定所有年轻代里的 Region。通过控制年轻代的 region 个数，即年轻代内存大小，来控制 young GC 的时间开销。
* Mixed GC：选定所有年轻代里的 Region，外加根据 global concurrent marking 统计得出收集收益高的若干老年代 Region。在用户指定的开销目标范围内尽可能选择收益高的老年代 Region。

由此可知，Mixed GC 不是 full GC，它只能回收部分老年代的 Region，如果 mixed GC 实在无法跟上程序分配内存的速度，导致老年代填满无法继续进行 Mixed GC，就会使用 serial old GC（full GC）来收集整个 GC heap。所以可以知道，**G1 是不提供 full GC 的**。

在G1的实现过程中，引入了一些新的概念，对于实现高吞吐、没有内存碎片、收集时间可控等功能起到了关键作用：

#### **Region** 

传统的GC收集器将连续的内存空间划分为新生代、老年代和永久代（JDK 8 去除了永久代，引入了元空间Metaspace），这种划分的特点是各代的存储地址（逻辑地址，下同）是连续的。

而 G1 的各代存储地址是不连续的，每一代都使用了 n 个不连续的大小相同的 Region，每个 Region 占有一块连续的虚拟内存地址。

**注意：**一个 Region 的大小可以通过参数 **`-XX:G1HeapRegionSize`** 设定，取值范围从 1M 到 32M，且是 2 的指数。如果不设定，那么 G1 会根据 Heap 大小自动决定。

#### **SATB**

全称是 Snapshot-At-The-Beginning，由字面理解，是 GC 开始时活着的对象的一个快照。

针对对多核处理器（multiprocessor）、大容量内存（RAM）的服务器。堆（heap）大小在 6GB 左右或者更大，GC 延迟要求有限（稳定且可预测的暂停时间低于 0.5 秒）。

`-XX:+UseG1GC`

| 参数                               | 含义                                                         |
| :--------------------------------- | :----------------------------------------------------------- |
| -XX:G1HeapRegionSize=n             | 设置 Region 大小，并非最终值                                 |
| -XX:MaxGCPauseMillis               | 设置 G1 收集过程目标时间，默认值 200ms，不是硬性条件         |
| -XX:G1NewSizePercent               | 新生代最小值，默认值 5%                                      |
| -XX:G1MaxNewSizePercent            | 新生代最大值，默认值 60%                                     |
| -XX:ParallelGCThreads              | STW 期间，并行 GC 线程数                                     |
| -XX:ConcGCThreads=n                | 并发标记阶段，并行执行的线程数                               |
| -XX:InitiatingHeapOccupancyPercent | 设置触发标记周期的 Java 堆占用率阈值。默认值是 45%。这里的 java 堆占比指的是 non_young_capacity_bytes，包括 old+humongous |

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

