## 垃圾收集器

### Serial 收集器

单线程收集器，收集时会暂停所有工作线程（Stop The World，STW），使用复制收集算法，虚拟机运行在 Client 模式时的默认新生代收集器。

### ParNew 收集器

ParNew 收集器就是 Serial 的多线程版本，除了使用多收集线程外，其余行为包括算法、STW、对象分配规则、回收策略等都与 Serial 收集器一摸一样，在单 CPU 的环境中，ParNew 收集器并不会比 Serial 收集器有更好的效果。

### Parallel Scavenge 收集器

Parallel Scavenge 收集器（PS 收集器）也是一个多线程收集器，也是使用复制算法，对象分配规则与回收策略都与 ParNew 收集器有所不同，它是以**吞吐量**最大化（即 GC 时间占总运行时间最小）为目标的收集器实现，它允许较长时间的 STW 换取总吞吐量最大化。

### Parallel Old 收集器

老年代版本吞吐量优先收集器，使用多线程和标记－整理算法，JVM 1.6 提供，在此之前，新生代使用了 PS 收集器的话，老年代除 Serial Old 外别无选择，因为 PS 无法与 CMS 收集器配合工作。

## GC

- 通常情况下，对象在 eden 中分配，当 eden 无法分配时，触发一次 Minor GC
- 配置了 `-XX:PretenureSizeThreshold=3145728` 的情况下，对象大于设置值将直接在老年代分配
- eden 经过 GC 后存活且 survivor 能容纳的对象，将移动到 survivor 空间内，若 survivor 中继续熬过若干次回收（默认为15次）将会被移动到老年代中，回收次数由 `-XX:MaxTenuringThreshold=15` 设置
- survivor 中相同年龄所有对象大小的累计值大于 survivor 空间的一半，大于或等于个年龄的对象就可以直接进入老年代，无需达到 MaxTenuringThreshold 中要求的年龄
- 在 Minor GC 触发时，会检测之前每次晋升到老年代的平均大小是否大于老年代的剩余空间，如果大于改为直接进行一次Full GC

### jdk1.8 默认并行（parallel） GC `-XX:+UseParallelGC`

吞吐量优先的垃圾收集器（GC 时间占总运行时间最小）

 jdk1.8 default -XX:+UseParallelGC ，新生代使用 PSYoungGen 收集器，老年代使用 ParOldGen

Scavenge 【（从废弃物中）觅食；捡破烂；拾荒；吃（动物尸体）】

- PSYoungGen: Parallel Scavenge ：新生代
  [多线程收集器，也是使用复制算法，吞吐量最大化（即 GC 时间占总运行时间最小）为目标的收集器实现，允许较长时间的 STW 换取总吞吐量最大化]

- ParOldGen： Parallel Old，老年代
  [老年代版本吞吐量优先收集器，使用多线程和标记－整理算法，JVM 1.6 提供，在此之前，新生代使用了 PS 收集器的话，老年代除 Serial Old 外别无选择，因为 PS 无法与 CMS 收集器配合工作]

### 并发（concurrent）GC，标记清除 `–XX:+UseConcMarkSweepGC`

响应时间优先的垃圾收集器，最短停顿时间为目标 （总体 GC 时间最小）

 –XX:+UseConcMarkSweepGC -XX:+UseParNewGC

- par new generation：(Parallel New)
  [ParNew 新生代使用并行收集器，收集器就是 Serial 的多线程版本，除了使用多条收集线程外，其余行为包括算法、STW、对象分配规则、回收策略等都与 Serial 收集器一摸一样]

### 新一代 GC `-XX:+UseG1GC`

 -XX:+UseG1GC

## JVM 堆内存划分

- 老年代（Old Generation）

在新生代中经历了几次 Minor GC 仍然存活的对象，就会被放到老年代。

Major GC 针对的是老年代的垃圾回收。CMS 就是一种针对老年代的垃圾回收算法。

Full GC 是针对整堆（包括新生代和老年代）做垃圾回收的。

### CMS 垃圾回收的 6 个重要阶段

1. initial-mark 初始标记（CMS 的第一个 STW 阶段），标记 GC Root 直接引用的对象，GC Root 直接引用的对象不多，所以很快。
2. concurrent-mark 并发标记阶段，由第一阶段标记过的对象出发，所有可达的对象都在本阶段标记。
3. concurrent-preclean 并发预清理阶段，也是一个并发执行的阶段。在本阶段，会查找前一阶段执行过程中,从新生代晋升或新分配或被更新的对象。通过并发地重新扫描这些对象，预清理阶段可以减少下一个stop-the-world 重新标记阶段的工作量。
4. concurrent-abortable-preclean 并发可中止的预清理阶段。这个阶段其实跟上一个阶段做的东西一样，也是为了减少下一个STW重新标记阶段的工作量。增加这一阶段是为了让我们可以控制这个阶段的结束时机，比如扫描多长时间（默认5秒）或者Eden区使用占比达到期望比例（默认50%）就结束本阶段。
5. remark 重标记阶段（CMS的第二个STW阶段），暂停所有用户线程，从GC Root开始重新扫描整堆，标记存活的对象。需要注意的是，虽然CMS只回收老年代的垃圾对象，但是这个阶段依然需要扫描新生代，因为很多GC Root都在新生代，而这些GC Root指向的对象又在老年代，这称为“跨代引用”。
6. concurrent-sweep ，并发清理。

```
[GC (CMS Initial Mark) [1 CMS-initial-mark: 7624K(10240K)] 12857K(19456K), 0.0008565 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-mark-start]
[CMS-concurrent-mark: 0.003/0.003 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-preclean-start]
[CMS-concurrent-preclean: 0.000/0.000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-abortable-preclean-start]
[CMS-concurrent-abortable-preclean: 0.000/0.000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (CMS Final Remark) [YG occupancy: 5232 K (9216 K)][Rescan (parallel) , 0.0008685 secs][weak refs processing, 0.0000269 secs][class unloading, 0.0006762 secs][scrub symbol table, 0.0011167 secs][scrub string table, 0.0005097 secs][1 CMS-remark: 7624K(10240K)] 12857K(19456K), 0.0033591 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-sweep-start]
[CMS-concurrent-sweep: 0.001/0.001 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[CMS-concurrent-reset-start]
[CMS-concurrent-reset: 0.000/0.000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
```

> 虽然 abortable-preclean 阶段是 concurrent 的，不会暂停其他的用户线程。就算不优化，可能影响也不大。

### 优化

降低 abortable preclean 时间，而且不增加 final remark 的时间（因为 remark 是 STW 的）。

调低 abortable preclean 阶段的时间 ：

- -XX:CMSMaxAbortablePrecleanTime=5000 ： 默认值5s，代表该阶段最大的持续时间
- -XX:CMSScheduleRemarkEdenPenetration=50 ：默认值 50%，代表 Eden 区使用比例超过 50% 就结束该阶段进入 remark

有用的结论：如果 abortale preclean 阶段时间太短，随后在 remark 时，新生代占用越大，则 remark 持续的时间（STW）越长。

这就两难了，不缩短 abortale preclean 耗时会报 longgc；缩短的话，remark 阶段又会变长，而且是 STW，更不能接受。

- `-XX:+CMSScavengeBeforeRemark`  ：尝试在 remark 阶段之前进行一次 Minor GC，以降低新生代的占用。

增加 CMSScavengeBeforeRemark 参数之后的 minor GC 停顿时间 + remark 停顿时间如果比增加之前的 remark GC 停顿时间要小，这才是好的方案。

虽然官方说明这个增加这个参数是尝试进行 Minor GC，不一定会进行。但实际使用起来，几乎每次 remark 前都会 Minor GC。