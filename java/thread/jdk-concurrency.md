> **进程**是操作系统分配资源的最小单元，**线程**是操作系统调度的最小单元
> 进程 (Process) 是计算机中的程序关于某数据集合的一次运动，是系统进行资源分配和调度的基本单位，是操作系统的结构基础。
> **线程**是轻量级的进程，是程序执行的最小单位。

<font color="red">New ---> Runnable (<--> Blocked) (<--> Waiting) --> Running --> Terminated</font>

>存储资源是操作系统由虚拟内存机制来管理和分配的。进程是操作系统分配存储资源的最小单元。
>每个进程有独立的虚拟内存地址空间，会真正地拥有独立与父进程之外的物理内存。
>并且由于进程拥有独立的内存地址空间，导致了进程之间无法利用直接的内存映射进行进程间通信。
>
>**线程**解决的最大问题就是它可以很简单地表示共享资源的问题，这里说的资源指的是存储器资源，
>资源最后都会加载到物理内存，一个进程的所有线程都是共享这个进程的同一个虚拟地址空间的，
>也就是说从线程的角度来说，它们看到的物理资源都是一样的，这样就可以通过共享变量的方式
>来表示共享资源，也就是直接共享内存的方式解决了线程通信的问题。
>而线程也表示一个独立的逻辑流，这样就完美解决了进程的一个大难题。

冯诺依曼结构把计算机系统抽象成 **CPU + 存储器 + IO**，那么计算机资源分为两种： 计算资源 和 存储资源



#### 一. jdk 多线程操作

###### 1. 重入锁

> synchronized, Object.wait(), Object.notify() 的替代
> <font color="red">java.util.concurrent.locks.ReentrantLock </font> -> lock(), unlock()

开发人员必须手动的指定何时加锁和何时解锁，所以重入锁对逻辑的控制灵活性要远远好于 synchronized
但是要注意，在退出临界区时必须手动的释放锁，否则其他线程没有机会访问临界区了。
之所以叫重入锁是因为这种锁可以重复进入，但是得相应的解锁，且仅限于一个线程。
但是释放次数多了就会抛出 IllegalMonitorStateException 异常。

###### 2. 中断响应

对于 synchronized 来说，若一个线程等待锁，结果就只有两种情况，要么获得此锁继续执行，
要么保持等待。
而重入锁可以被中断，也就是在等待锁的过程当中依据需要取消对锁的请求。

lock1.lockInterruptibly();
if (lock1.isHeldByCurrentThread()) { lock1.unlock(); }

###### 3. 锁申请等待限时

得不到锁一定时间后自动放弃。
lock.tryLock(5, TimeUnit.SECONDS) ： 最多等待 5 秒，超过后还未得到锁，返回 false
lock1.tryLock() ： 未得到锁，返回 false，不会造成死锁。

**公平锁**
会按照时间的先后顺序，保证先到先得。 synchronized 是非公平锁。
ReentrantLock 默认是非公平锁。
ReentrantLock(boolean fair);  true : 公平， false : 非公平

**总结：**
lock() : 获得锁，若锁被占用则等待。
lockInterruptibly() : 获得锁，但是有先响应中断。
tryLock() : 尝试获取锁，若成功返回 true，失败返回 false，不等待立即返回
tryLock(long time, TimeUnit unti) :
unlock() : 释放锁

**原子状态：**原子状态使用 CAS 操作来存储当期锁的状态，判断是否已经被别的线程持有
**等待队列：**所有没有请求到锁的线程，会进入等待队列进行等待，若有线程释放则从队列中唤醒一个线程继续工作。
阻塞原语 park() 和 unpark(),用来挂起和恢复线程，没有得到锁的线程会被挂起。



###### 4. 重入锁的 ： condition 条件

(Object.wait() 和 Object.nofity() 配合 synchronized 使用) 类似
Lock 接口的 newCondition 生成与当期重入锁绑定的 Condition， 可在适当的时候等待或通知。

await() 使当期线程等待，同事释放当期锁，当其他线程使用 signal() 或 signalAll() 线程会重新获得锁并继续执行，或当线程中断也可跳出等待。
awaitUninterruptibly() 和await() 类似，不会在等待过程中响应中断。
signal() 唤醒一个等待线程

**注意：**和 Object.await() 和 notify() 一样，当线程使用 Condition.await() 时，要求线程持有相关的重入锁。在 Condition.await() 调用后，此线程会释放此锁，当 signal() 调用后，系统会从当前线程中唤醒一个等待线程，一旦线程被唤醒就会尝试获取与之绑定的重入锁，成功获取就会继续执行。

###### 5. 允许多线程同时访问，(信号量 Semaphore)

synchorized 和 ReentrantLock 一次都仅允许一个线程访问一个资源，而信号量则可以指定多个线程
同时访问一个资源。

public Semaphore(intn permits);
public Semaphore(int permits, boolean fair);

public void acquire()
public void acquireUninterruptibly()
public boolean tryAcquire()
public boolean tryAcquire(long timeout, TimeUnit unit)
public void release()

acquire() 会尝试获取一个准入许可，若无法获得则线程会等待，直到一个线程释放许可或中断。
release() 线程访问资源后释放该许可。

###### 6. ReadWriteLock 读写锁(读写分离锁)

可以有效的减少锁竞争提高系统性能。
锁分离机制 ：
读-读： 不互斥，不互相阻塞
读-写： 读阻塞写，写也会阻塞读
写-写：写写阻塞

Lock lock = new ReentrantLock();
ReentrantReadWriteLock readWriteLock = new ReentrantReadWriteLock();
Lock readLock = readWriteLock.readLock();
Lock writeLock = readWriteLock.writeLock()

###### 7. 倒计时器 ：  CountDownLatch (倒计数门闩)

countDown() --> await() --> begin running

**循环栅栏**　CyclicBarrier  (另一种多线程并发控制工具)
计数器可以反复使用，仅当凑齐指定计数器个数的线程后，计数器会归零执行，然就再次计数。

CyclicBarrier.await() 方法可能抛出两个异常，
InterruptedException,等待中线程被中断，这是非常通用的异常。
特有的 BrokerBarrierException，一旦遇到此异常表示当前 CyclicBarrier 已经被损坏了，
系统能没有办法等待所以线程到齐，因此就此散伙。

###### 8. 线程阻塞工具类： LockSupport

可在线程内任意位置让线程阻塞，弥补了 Thread.suspend() 由于 resume() 在之前导致线程无法继续执行的情况，和 Object.await() 相比，不需要获得某个对象的锁也不会抛出 InterruptedException 异常。

静态方法： park() 可以阻塞当前线程， parkNanos(), parkUntil() 等实现了有限等待。
不论 park() 或 unpark() 谁在前谁在后，都不会导致线程被永久挂起。
因为 LockSupport 使用了类似信号量的机制，为每个线程准备了一个许可，若许可可用那么 park() 会立即返回，并且消费掉此许可(也就是许可不可在用)，若许可不可用则会阻塞。
unpark() 使一个许可变为可用，但和信号量不同的是许可只有一个，永远不会超过一个。

除了阻塞功能外，还支持中断影响，但是和其他接受中断函数不同， LockSupport.park() 不会抛出 InterruptedException() 异常，只会默默返回，但可从 Thread.Interrupted() 获得中断标记。



---

#### 二. 线程 *Thread* 使用

##### 1. 终止线程 (Thread 的 stop() 方法， 注：废弃)

此方法太过于暴力，强行把执行到一半的线程终止，导致数据不一致问题。
在结束线程时，会直接终止线程，并且会立即释放掉这个线程的所有锁。
锁的释放可能导致另一个等待该锁的读线程读到了数据不一致的对象，发生数据错误。

##### 2. 线程中断 interrupt

在 **java** 当中，线程中断是一种重要的线程协作机制。
而且线程中断不会立即退出，而是给线程发送一个通知，告知目标线程希望退出，
至于目标线程如何处理就由它自己决定。
**注意：**即使被设置了中断，线程本身不会自己停止。

public void Thread.interrupt();  // 中断线程，设置中断标志位
public boolean Thread.isInterrupted();  // 判断是否中断，检查标志位
public static void Thread.interrupted();  // 判断释放被中断，并且清除中断状态

**注意：** Thread.sleep(1000) 会抛出 InterruptedException 中断异常而不是运行时异常，
所以程序必须捕获并处理它，当线程在休眠时被中断就会产生此异常。

**注意：**Thread.sleep() 方法由于中断抛出异常，此时会清除中断标记，如果不处理，下次循环就无法捕获此中断，故在异常处理中再次设置中断标记位。

##### 3. 等待 (wait) 和通知 (notify)

public final void wait() ;
public final native void nofity();

object.notify() 会从等待队列当中随机选择一个唤醒，并且此选择是不公平的。
object.notifyAll() 会唤醒等待队列当中的所有线程，而不是一个。

**注意：**Object.wait() 方法不可随便调用，必须包含在对应的 synchronized 语句中。
wait() 和 notify() 都需要首先获取目标对象的一个监视器。
监视器会在 wait() 方法后释放掉。在调用 notify() 之前，也必须获取对象的监视器。

**注意：** Object.wait() 和 Thread.sleep() 方法都可以让线程等待若干时间，
但是除了 wait() 可以被唤醒外，另外一个区别在于 wait() 方法会释放目标对象的锁，
而 sleep() 不会释放任何锁。

##### 4. 挂起 (suspend) 和继续执行 (resume) [已经弃用，不推荐使用

原因: suspend 挂起线程时不会释放任何资源，其他任何线程想要访问被他占用的锁时，
都会被阻塞，无法正常运行，要对应的 resume 操作才能正常运行。
**注意：**如何 resume 在 suspend 之前就执行那么被挂起的线程就很难在执行。

##### 5. 等待线程结束 (join) 和谦让 (yield)

public final void join()
public final synchronized void join(long mills)
会让调用线程在当期对象上进行等待。

yield() 会使当前线程让出 CUP。

##### 6. volatile 与 java 内存模型 (JMM)

java 内存模型围绕着原子性、有序性、可见性展开。
volatile 易变的，不稳定的，保证变量的可见性特点。
**注意：** volatile 并不能替代锁，无法保证一些复合的操作原子性。

##### 7. 线程组

##### 8. 守护线程　(daemon)

##### 9. 线程安全和　synchronized

volatile 并不能保证线程安全，只能确保一个线程修改数据后，另一个线程可以看到修改，
但是两个线程同时修改一个数据时却依然会产生冲突。

synchronized 用法：

1. 指定枷锁对象，对给定的对象加锁，进入同步代码前要获得给定对象锁。
2. 直接作用于实例方法，相当于给实例加锁，进入同步代码前要获得当前实例的锁。
3. 直接作用于静态方法，相当于个类加锁，进入同步代码前要获得当前类的锁。

##### 10. 并发下的　ArrayList, HashMap

ArrayList 是一个线程不安全的容器，在多线程当中使用可能或导致程序出错。
常见情况：

1. 程序正常，ArrayList 操作正常
2. 程序抛出异常，因为　ArrayList 扩容过程中，内部一致性被破坏，由于没锁保护，
   另一个线程访问到了不一致的内部状态，导致越界问题
3. 非常隐蔽的问题，ArrayList 操作结果和预期不符合。多线程同时访问同一位置导致赋值问题。
   改进方法，使用线程安全的　Vector 代替。

**HashMap** 同样是线程不安全的，在多线程下会出现十分诡异的问题。
常见情况：

1. 程序正常结束，结果符合预期。
2. 程序正常结束，结果与预期不符合。
3. 程序永远无法结束，同时占用多个　CPU 导致死循环，JDK8 中死循环问题不存在。

---

#### 三. synchronized 使用

object.wait() 会释放掉监视器， object.notify() 会随机唤醒一个对象
若想要再次进入线程则必须再次获取对象监视器

wait 和 notify 都可以让线程等待若干时间， 除了 wait 可以被唤醒外，
另一个区别就是 wait 方法会释放对象目标锁 Thread.sleep 不会释放任何资源
不要在 Thread 对象实例上使用 wait() 或 notify() ，有可能影响系统 API

**join     yield**
join --> 其它线程等待当前线程执行完毕后才执行
yield 让出 CUP 给予其他线程机会

wait notify notifyAll    suspend(不会释放任何资源) resume
interrupted isInterrupted

**synchronized** 实现线程间的同步，它对同步代码加锁，使得每次仅能一个线程进入同步代码块 

**关键字 synchronized 用法**

1. 指定加锁对象：对给定对象加锁，进入同步代码块前要获得给定对象的锁
2. 直接作用于实例方法：相当于对当前实例加锁，进入代码前要获取当前对象的实例锁
3. 直接作用于静态方法：相当于对当前类加锁，进入前要获取当前类的锁

**注意：** 多个线程操作时要对应同一个锁的实例 

**synchronized 可以确保线程间的可见性和有序性**

*重如锁，可以多次进入*

```java
ReentrantLock
lock : 获得锁，如果锁已经被占用，则等待
lockInterruptibly() : 获得锁，优先响应中断
tryLock() : 尝试获取锁，如果成功，返回 true， 失败返回 false， 不等待
tryLock(long time, TimeUnit unit): 在给定的时间内尝试获取锁
unlock() : 释放锁
```

**重入锁的条件 Condition**

当 Condition 的 await 时，要求线程持有相关的重入锁， 在调用后会释放这把锁
同理 signal 方法调用也要求线程获得相关的锁， 
signal 后系统会在 Condition 对象的等待队列当中唤醒一个线程。
在 signal 方法调用后，一般需要释放相关的锁谦让给被唤醒的线程

**读写分离锁**

```java
ReentrantReadWriteLock reentrantReadWriteLock = new ReentrantReadWriteLock();
ReentrantReadWriteLock.ReadLock readLock = reentrantReadWriteLock.readLock();
ReentrantReadWriteLock.WriteLock writeLock = reentrantReadWriteLock.writeLock();
```



---

#### 四. 线程使用笔记

```java
Integer 是不可变量，对象一旦被创建，就不能被修改
若：Integer 代表 1 那么它就永久代表 1，你永远不能修改 Integer 的值
若需要新值 2 那就只能新建一个 Integer 对象
    
Integer cnt = 0;
cnt++; cnt = Integer.valueOf(cnt.intValue() + 1) 
// 注意 -128 - 127 会有 IntegerCache.cache 缓存

加锁加到 Integer 的时候，有可能导致多个 Thread 不能同时看到同一个 cnt 对象，[cnt 对象一直在变]
导致多个 Thread 加锁到不同的控制对象示例上，导致临界区代码控制出现问题。
```

**当系统仅有守护进程的时候那个此进程就会退出**

```java
Thread.sleep(1000) -->  InterruptedException e
在此异常当中会清除中断标志位，如果不在此处理，后续对中断标志位处理就可能会出错
```

> 调用某个线程的 join() 方法时，这个方法会挂起调用线程，直到被调用线程结束执行，
> 调用线程才会继续执行，父线程等待子线程结束之后才能继续运行

> suspend 挂起，resume 继续执行 ， **不推荐**使用 suspend 挂起线程
> suspend 在挂起线程导致线程暂停的同时不会释放任何资源，
> 就有可能导致其他要访问被它暂停使用的锁时都会被牵连
> 而且只有对应的 resume 操作才可以唤醒，若 resume 在 suspend 之前执行，
> 那么线程有可能永远不能被继续执行，
> 最致命的是线程状态还是为 Runnable ，严重影响判断线程的状态

```java
通知 T1 继续执行的时候 T1 并不能立即执行，必须得等 T2 释放 object 锁，
在获取到 object 的锁资源，T1 在继续执行
wait 会立即等待，但是它会释放 object 也就是当前锁对象的锁，让别的线程获取此资源
Thread.sleep 不会释放目标对象的锁资源
```

```java
synchronized 拓展功能(增强版) 重入锁 java.util.concurrent.locks.ReentrantLock
重入锁对逻辑的控制远好于 synchronized
注意： 重入锁 可以反复进入，但是仅限于同一个线程，还有注意 获取了多少次就得释放多少次

lock.tryLock(5, TimeUnit.SECONDS)
对象会持续 5 秒获取锁，若未成功获取会返回 false
```

```java
ReentrantLock 整理
lock 获取锁，若锁已经被占用则等待
lockInterruptibly 获取锁但优先响应中断
tryLock 尝试获取锁，若成功返回 true，失败返回 false，不会等待，立即退出
unLock 释放锁

是采用的 CAS (Compare And Swap 比较交换的思想) 无锁的概念

Object.wait(), Object.notify() --> synchronized 的辅助
condition --> Lock 的辅助

signal(), signalAll() 唤醒 await() 的等待

注意： singal 后重入锁也得重新获取锁对象。 
singal 操作也得在相关对象持有重入锁在当中执行(获取监视)
Condition.await() 在调用后也会释放此锁。
```

> 允许多个线程同时访问：信号量（Semaphore）
> 无论是内部锁 synchronized 还是重入锁 ReentrantLock 一次都仅允许一个线程访问一个资源
> 信号量可以指定多个线程，同时访问某一个资源
>
>  /* 获取信号量 */
> semaphore.acquire();
> /* 注意离开时务必要释放 */
> semaphore.release();

```java
t != (t = tail) -> != 不是原子操作，先获取 t 的值， 在执行 t=tail 获取新的 t 值，比较
```

