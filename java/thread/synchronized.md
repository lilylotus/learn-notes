object.wait() 会释放掉监视器， object.notify() 会随机唤醒一个对象
若想要再次进入线程则必须再次获取对象监视器

wait 和 notify 都可以让线程等待若干时间， 除了 wait 可以被唤醒外，另一个区别就是 wait 方法会释放对象目标锁 Thread.sleep 不会释放任何资源
不要在 Thread 对象实例上使用 wait() 或 notify() ，有可能影响系统 API

join     yield
join --> 其它线程等待当前线程执行完毕后才执行
yield 让出 CUP 给予其他线程机会

wait notify notifyAll    suspend(不会释放任何资源) resume
interrupted isInterrupted


| synchronized 实现线程间的同步，它对同步代码加锁，使得每次仅能一个线程进入同步代码块  
**关键字 synchronized 用法**
1. 指定加锁对象：对给定对象加锁，进入同步代码块前要获得给定对象的锁
2. 直接作用于实例方法：相当于对当前实例加锁，进入代码前要获取当前对象的实例锁
3. 直接作用于静态方法：相当于对当前类加锁，进入前要获取当前类的锁

注意： 多个线程操作时要对应同一个锁的实例  
**synchronized 可以确保线程间的可见性和有序性**

| 重如锁，可以多次进入
```java
ReentrantLock
lock : 获得锁，如果锁已经被占用，则等待
lockInterruptibly() : 获得锁，优先响应中断
tryLock() : 尝试获取锁，如果成功，返回 true， 失败返回 false， 不等待
tryLock(long time, TimeUnit unit): 在给定的时间内尝试获取锁
unlock() : 释放锁

```

| 重入锁的条件 Condition

当 Condition 的 await 时，要求线程持有相关的重入锁， 在调用后会释放这把锁
同理 signal 方法调用也要求线程获得相关的锁， signal 后系统会在 Condition 对象的等待队列当中唤醒一个线程。  
在 signal 方法调用后，一般需要释放相关的锁谦让给被唤醒的线程

| 读写分离锁
```java
ReentrantReadWriteLock reentrantReadWriteLock = new ReentrantReadWriteLock();
ReentrantReadWriteLock.ReadLock readLock = reentrantReadWriteLock.readLock();
ReentrantReadWriteLock.WriteLock writeLock = reentrantReadWriteLock.writeLock();
```