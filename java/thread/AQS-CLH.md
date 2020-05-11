#### 1. 简介

> 简单解释一下J.U.C，是JDK中提供的并发工具包,`java.util.concurrent`。里面提供了很多并发编程中很常用的实用工具类，比如atomic原子操作、比如lock同步锁、fork/join等。

#### 2. Lock 接口

lock 作为切入点来讲解 AQS，毕竟同步锁是解决线程安全问题的通用手段，也是我们工作中用得比较多的方式。
Lock API

```java
void lock() // 如果锁可用就获得锁，如果锁不可用就阻塞直到锁释放
void lockInterruptibly() // 和 lock()方法相似, 但阻塞的线程可中断，抛出 java.lang.InterruptedException异常
boolean tryLock() // 非阻塞获取锁;尝试获取锁，如果成功返回true
boolean tryLock(long timeout, TimeUnit timeUnit) //带有超时时间的获取锁方法
void unlock() // 释放锁
```

#### 3. Lock 的实现

- ReentrantLock
  表示重入锁，它是唯一一个实现了Lock接口的类。重入锁指的是线程在获得锁之后，再次获取该锁不需要阻塞，而是直接关联一次计数器增加重入次数
- ReentrantReadWriteLock
  重入读写锁，它实现了 ReadWriteLock 接口，在这个类中维护了两个锁，一个是 ReadLock，一个是 WriteLock，他们都分别实现了 Lock 接口。
  读写锁是一种适合读多写少的场景下解决线程安全问题的工具，基本原则是：`读和读不互斥、读和写互斥、写和写互斥`。也就是说涉及到影响数据变化的操作都会存在互斥。
- StampedLock
  stampedLock 是 JDK8 引入的新的锁机制，可以简单认为是读写锁的一个改进版本，读写锁虽然通过分离读和写的功能使得读和读之间可以完全并发，但是读和写是有冲突的，如果大量的读线程存在，可能会引起写线程的饥饿。stampedLock 是一种乐观的读策略，使得乐观锁完全不会阻塞写线程

#### 4. QAS 简介

QAS - AbstractQueuedSynchronizer 的一个抽象类，它提供了一个 FIFO 队列，可以看成是一个用来实现同步锁以及其他涉及到同步功能的核心组件，常见的有: `ReentrantLock`、`CountDownLatch` 等。
AQS 是一个抽象类，主要是通过继承的方式来使用，它本身没有实现任何的同步接口，仅仅是定义了同步状态的获取以及释放的方法来提供自定义的同步组件。
可以这么说，只要搞懂了 AQS，那么 J.U.C 中绝大部分的 api 都能轻松掌握。

##### 4.1 QAS 两种功能

- 独占锁，每次只能有一个线程持有锁，比如 `ReentrantLock` 就是以独占方式实现的互斥锁
- 共享锁，允许多个线程同时获取锁，并发访问共享资源，比如 `ReentrantReadWriteLock`

#### 5. 总结

AQS队列的实现过程，主要是基于非公平锁的独占锁实现。在获得同步锁时，同步器维护一个同步队列，获取状态失败的线程都会被加入到队列中并在队列中进行自旋；移出队列（或停止自旋）的条件是前驱节点为头节点且成功获取了同步状态。在释放同步状态时，同步器调用tryRelease(int arg)方法释放同步状态，然后唤醒头节点的后继节点。