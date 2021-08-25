[Full GC (Metadata GC Threshold) [PSYoungGen: 8613K->0K(114688K)] [ParOldGen: 104K->8413K(131072K)] 8717K->8413K(245760K), [Metaspace: 20539K->20538K(1067008K)], 0.0293014 secs] [Times: user=0.08 sys=0.00, real=0.03 secs]

解决：

```
-XX:MetaspaceSize=265M
```

---

`-Xms512m -Xmx512m -XX:MetaspaceSize=128M -XX:+UseParallelGC `

2021-08-25T11:37:32.053+0800: 1.681: [GC (Allocation Failure) [PSYoungGen: 131584K->7481K(153088K)] 131584K->7497K(502784K), 0.0138374 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]

- 1.681 :  GC 发生时，虚拟机运行了多少秒
- GC (Allocation Failure) : 发生了一次垃圾回收，这是一次 `Minor GC` 。注意它不表示只 GC 新生代，括号里的内容是 GC 发生的缘由，Allocation Failure 的缘由是年轻代中没有足够区域可以存放须要分配的数据而失败。
- PSYoungGen : 垃圾收集器的名称
- 131584K->7481K(153088K) ： 指的是 垃圾收集前->垃圾收集后(年轻代堆总大小)
- 131584K->7497K(502784K) ：垃圾收集先后，JVM 堆的大小（总堆 502784K，堆大小包括新生代和年老代），计算出年老代占用空间 = 502784K - 153088K = 34969K （341.5M）
- 0.0138374 secs : 整个 GC 过程持续时间
- user=0.00 sys=0.00, real=0.01 secs : 用户态耗时，内核态耗时和总耗时。GC 耗时记录

---

2021-08-25T11:21:45.557+0800: 35.887: [Full GC (Ergonomics) [PSYoungGen: 2660K->0K(123904K)] [ParOldGen: 128224K->111182K(131072K)] 130885K->111182K(254976K), [Metaspace: 103501K->103468K(1142784K)], 0.4424642 secs] [Times: user=1.33 sys=0.00, real=0.44 secs]

`Full GC` 的原因是 *Ergonomics* （人体工学），是由于开启了 `UseAdaptiveSizePolicy`，JVM 本身进行自适应调整引起的 `FULL GC`。

> 发现当我们使用 Server 模式下的 `ParallelGC` 收集器组合（Parallel Scavenge + Serial Old 的组合）下，担保机制的实现和之前的 Client 模式下（SerialGC 收集器组合）有所变化。在 GC 前还会进行一次判断，如果 要分配的内存 >= Eden 区大小的一半，那么会直接把要分配的内存放入老年代中。否则才会进入担保机制。

如果晋升到老年代的平均大小大于老年代的剩余大小，则认为要进行一次 FULL GC。

如果老生代的剩余空间少于下一次收集所需空间，那么现在就做一个完整的 GC 收集。

虚拟机估算出下次分配可能会发生无法分配的问题，于是提前预测到可能的问题，提前发生一次 FULL GC。

Ergonomics 翻译成中文，一般都是“人体工程学”。在 JVM 中的垃圾收集器中的 Ergonomics 就是负责自动的调解 GC 暂停时间和吞吐量之间的平衡，然后虚拟机性能更好的一种做法。

> Parallel Scavenge 的目标是达到一个可控的吞吐量，吞吐量=程序运行时间/（程序运行时间+GC时间），如程序运行了 99s，GC 耗时 1s，吞吐量=99/（99+1）= 99%。Parallel Scavenge 提供了两个参数用以精确控制吞吐量，分别是用以控制最大 GC 停顿时间的 `-XX:MaxGCPauseMillis` 及直接控制吞吐量的参数 `-XX:GCTimeRatio`。