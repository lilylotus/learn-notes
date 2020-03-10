#### JUC

>JDK 的 JUC 包 (java.util.concurrent) 提供大量 Java 并发工具提供使用，基本由 Doug Lea 编写

##### 名词解析

###### 1. QAS

AQS 是一个抽象类，类全路径
java.util.concurrent.locks.AbstractQueuedSynchronizer，抽象队列同步器，是基于模板模式开发的并发工具抽象类

###### 2. CAS

> CAS 是 Conmpare And Swap (比较和交换)的缩写，是一个原子操作指令

CAS 机制当中使用了 3 个基本操作数：内存地址 addr，预期旧的值 oldVal，要修改的新值 newVal
更新一个变量的时候，只有当变量的预期旧值 oldVal 和内存地址 addr 当中的实际值相同时，才会将内存地址 addr 对应的值修改为 newVal
基于乐观锁的思路，通过CAS在不断尝试和比较，可以对变量值线程安全地更新

###### 3. 线程中断

1. 线程中断是一种线程协作机制，用于协作其他线程中断任务的执行
2. 当线程处于阻塞等待状态，例如调用了 wait()、join()、sleep() 方法之后，调用线程的 interrupt() 方法之后，线程会马上退出阻塞并收到 InterruptedException
3. 当线程处于运行状态，调用线程的 interrupt() 方法之后，线程并不会马上中断执行，需要在线程的具体任务执行逻辑中通过调用 isInterrupted() 方法检测线程中断标志位，然后主动响应中断，通常是抛出 InterruptedException