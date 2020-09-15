##### 创建线程池注意事项

1. 创建线程或线程池时请指定有意义的线程名称，方便出错时回溯。
2. 线程资源必须通过线程池提供，不允许在应用中自行显式创建线程
3. 线程池不允许使用 `Executors` 去创建，而是通过 `ThreadPoolExecutor` 去创建，这样的处理方式让写同学更加明确线程池运行规则，避资源耗尽风险

##### ThreadPoolExecutor 参数任务队列，workQueue

任务队列，被添加到线程池中，但尚未被执行的任务；它一般分为直接提交队列、有界任务队列、无界任务队列、优先任务队列几种。

###### 直接提交队列

设置为 `SynchronousQueue` 队列，`SynchronousQueue` 是一个特殊的 *BlockingQueue*。
每一个插入操作必须等待另一个线程相对应的删除操作，反之亦然。是一个同步队列但没有内部容量。

```java
final ThreadPoolExecutor executor =
    new ThreadPoolExecutor(1, 2, 1000L, TimeUnit.MILLISECONDS,
                           new SynchronousQueue<>(), new ThreadPoolExecutor.AbortPolicy());
```

使用 `SynchronousQueue` 队列，提交的任务不会被保存，总是会马上提交执行。执行任务线程小于  *maximumPoolSize* 则会创建新的线程执行，若大于则会依据设置的 handler 指定拒绝策略。

###### 有界任务队列

是一个 *BlockingQueue* 有界队列背后实现为数组，队列的执行顺序为 *FIFO (first-in-first-out)*。

```java
ThreadPoolExecutor executor =
    new ThreadPoolExecutor(1, 3, 300L, TimeUnit.MILLISECONDS,
                           new ArrayBlockingQueue<>(10), new ThreadPoolExecutor.AbortPolicy());
```

使用 `ArrayBlockingQueue` 有界任务队列，若有新的任务需要执行时，线程池会创建新的线程，直到创建的线程数量达到 corePoolSize 时，则会将新的任务加入到等待队列中。若等待队列已满，即超过 `ArrayBlockingQueue` 初始化的容量，则继续创建线程，直到线程数量达到 maximumPoolSize 设置的最大线程数量，若大于 maximumPoolSize，则执行拒绝策略。在这种情况下，线程数量的上限与有界任务队列的状态有直接关系，如果有界队列初始容量较大或者没有达到超负荷的状态，线程数将一直维持在 corePoolSize 以下，反之当任务队列已满时，则会以 maximumPoolSize 为最大线程数上限。

###### 无界任务队列

```java
ThreadPoolExecutor executor =
    new ThreadPoolExecutor(1, 3, 200L, TimeUnit.MILLISECONDS,
                           new LinkedBlockingQueue<>(), Executors.defaultThreadFactory(),
                           new ThreadPoolExecutor.AbortPolicy());
```

使用无界任务队列，线程池的任务队列可以无限制的添加新的任务，而线程池创建的最大线程数量就是你 corePoolSize 设置的数量，也就是说在这种情况下 maximumPoolSize 这个参数是无效的，哪怕你的任务队列中缓存了很多未执行的任务，当线程池的线程数达到 corePoolSize 后，就不会再增加了；若后续有新的任务加入，则直接进入队列等待，当使用这种任务队列模式时，一定要注意你任务提交与处理之间的协调与控制，不然会出现队列中的任务由于无法及时处理导致一直增长，直到最后资源耗尽的问题。

###### 优先任务队列

```java
ThreadPoolExecutor executor =
    new ThreadPoolExecutor(1, 3, 200L, TimeUnit.MILLISECONDS,
                           new PriorityBlockingQueue<>(), Executors.defaultThreadFactory(),
                           new ThreadPoolExecutor.AbortPolicy());
```

除了第一个任务直接创建线程执行外，其他的任务都被放入了优先任务队列，按优先级进行了重新排列执行，且线程池的线程数一直为 corePoolSize。`PriorityBlockingQueue` 是一个特殊的无界队列，它其中无论添加了多少个任务，线程池创建的线程数也不会超过 corePoolSize 的数量，只不过其它队列一般是按照先进先出的规则处理任务，而 `PriorityBlockingQueue` 队列可以自定义规则根据任务的优先级顺序先后执行。

#### 拒绝策略

创建线程池时，为防止资源被耗尽，任务队列都会选择创建有界任务队列，但种模式下如果出现任务队列已满且线程池创建的线程数达到你设置的最大线程数时，这时就需要你指定 `ThreadPoolExecutor` 的 `RejectedExecutionHandler` 参数即合理的拒绝策略，来处理线程池"超载"的情况。ThreadPoolExecutor 自带的拒绝策略如下：

1. `AbortPolicy` 策略：该策略会直接抛出异常，阻止系统正常工作；
2. `CallerRunsPolicy` 策略：如果线程池的线程数量达到上限，该策略会把任务队列中的任务放在调用者线程当中运行；
3. `DiscardOledestPolicy` 策略：该策略会丢弃任务队列中最老的一个任务，也就是当前任务队列中最先被添加进去的，马上要被执行的那个任务，并尝试再次提交；
4. `DiscardPolicy` 策略：该策略会默默丢弃无法处理的任务，不予任何处理。当然使用此策略，业务场景中需允许任务的丢失；

以上内置的策略均实现了 `RejectedExecutionHandler` 接口，当然你也可以自己扩展 `RejectedExecutionHandler` 接口，定义自己的拒绝策略。

##### 线程复用，线程池

`ThreadPoolExecutor` 一个线程池
`Executors` 类线程池工厂
`Executor` 框架提供了各种类型的线程池：

`public static ExecutorService newFixedThreadPool(int nThreads);`

返回固定数量的线程池，线程数量始终不变，当新任务提交时若有空闲线程，则立即执行，
若无则会被暂存到任务队列中，待有空闲线程在执行。

`public static ExecutorService newSingleThreadExecutor();`
仅有一个线程，若多余的线程被提交到该线程池，任务会被保存到任务队列，
待线程空闲后按先入先出顺序执行。

`public static ExecutorService newCachedThreadPool();`
返回有实际情况调整数量的线程池，线程池的线程数量不变，但若有空闲线程可一复用，
则会优先使用可复用线程，当所以线程都在工作但又有新任务提交，
则会新创建线程处理任务，处理完成后返回线程池复用。

`public static ScheduleExecutorService newSingleThreadScheduleExecutor();`
线程池大小为1，定时执行任务或者周期性执行某个任务。

`public static ScheduleExecutorService newSechudledThreadPool(int corePoolsize);`
线程池大小指定数量。

##### 计划任务 (ScheduledExecutorService)

*schedule()* 在给定时间对任务进行一次调度。
*scheduleAtFixRate()* 和 *scheduleWithFixedDelay()* 会对任务进行周期性调度。

*FixRate* 任务调度的频率是一定的，以上一个任务开始执行时间为起点，之后 period 调度下一次任务
而 *FixDelay* 则是在上一次任务结束后在经过 *delay* 时间后在执行任务。

**注意：**在 scheduleAtFixRate() 若执行周期是 2 秒，但是任务每次执行时间大于 2 秒，
那么执行的周期就会变为任务的执行时间，也就是当任务完成后立即执行下一个任务。

**注意2：**调度程序实际上并不会保证任务会无限期的持续调用，如果任务本身抛出异常，
那么后续的所有执行都将会被中断，因此要让程序持续稳定的执行，那么做好异常处理是非常重要的。

`newFixedThreadPool(), newSingleThreadExecutor(), newCachedThreadPool()` 
方法都是由 **ThreadPoolExecutor** 类封装。

```java
public ThreadPoolExecutor(
	int corePoolSize,  // 指定线程池的数量
	int maximumPoolSize, // 指定了线程池的最大数量
	long keepAliveTime, // 当线程池数量超过 corePoolSize 时，多余空闲线程的存活时间被销毁
	TimeUnit unit, // keepAliveTime 的单位
	BlockingQueue<Runnable> workQueue, // 任务队列，被提交但还未执行的任务
	ThreadFactory threadFactory, // 线程工厂
	RejectedExecutionHandler handler) // 拒绝策略，当任务太多来不及处理，如何拒绝任务
```

**workQueue 和 handler 重点理解。**
**workQueue ：**被提交但还未执行的任务队列，是一个 BlockingQueue 接口对象，
仅用于存放 Runnable 对象，依据队列的功能可分，在 ThreadPoolExecutor 的构造函数
当中可使用的如下 BlockingQueue ：

1. 直接提交队列： 该功能由 SynchronousQueue 对象提供，SynchronousQueue 是一个特殊的
	BlockingQueue， SynchronousQueue 没有容量，每一个插入操作都要等待一个相应的删除操作，
	反之亦然，使用 SynchronousQueue 提交任务不会真实的保存，而总是讲新任务提交给线程i执行，
	若没有空闲进程，则尝试创建新的进程，如果进程数量达到最大值，则执行拒绝策略，
因此 SynchronousQueue 队列通常要设置很大的 maxmumPoolSize 值，否则很容易执行拒绝策略
	
2. 有界任务队列：若有新任务需要执行，如果线程数小于 corePoolSize，则会优先创建新的线程，
    若大于 corePoolSize，则会将新任务加入等待队列，若队列已满无法加入，则在总线程数不大于 maximumPoolSize 前提下，创建新线程执行任务，若大于 maximumPoolSize，则执行拒绝策略。也就是仅当任务队列装满时才可能将线程提升到 corePoolSize 以上。

 3. 无界任务队列：无界任务队列可以通过 LinkedBlockingQueue 类实现。与有界队列相比，除非系统资源耗尽，否则无界任务队列不存在任务加入队列失败的情况，当新任务到来，系统线程小于 corePoolSize，线程池会生成新的线程执行任务，当系统线程到达 corePoolSize 时，就不会继续增加了，若后续还有任务加入，而又无空闲的线程资源，则任务进入等待队列，若任务创建和处理速度相差很大，无界队列会快速增长，知道系统资源耗尽。

 4. 任务优先队列：通过 PriorityBlockingQueue 实现，控制任务执行的有限顺序，依据任务自身的有限级顺序先后执行，确保系统性能的同时，也能很好的保证质量

**handler：拒绝策略**
AbortPolicy：直接抛出异常，阻止系统正常工作。
CallerRunsPolicy ：只要线程池未关闭，该策略直接在调用者线程中运行当期被丢弃的任务，
                                   任务提交线程性能可能会急剧下降。
DiscardOledestPolicy : 对其最老的一个请求。
DiscardPolicy: 默默丢弃无法处理的任务，不予任何处理。
可以自己实现 RejectedExecutionHander 接口，自定义拒绝策略。

**线程池获取异常信息：**

```java
/* 获取异常抛出的堆栈信息 */
pools.execute(new DivTask(100, i));

Future re = pools.submit(new DivTask(100, i));
re.get();
```
