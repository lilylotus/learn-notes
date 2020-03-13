#### Transaction 事务

> 什么是事务？

事务就是逻辑上的一组操作，要么所有操作都执行，要么所有操作都不执行。

> 事务的特性 (ACID)

1. A (Atomicity) 原子性
   
   事务是最小的执行单位，不允许分割。事务的原子性确保动作要么全部完成，要么完全不起作用。
原子性强调一次处理事务所有步骤都必须成功，要么都不成功。
   原子性是整个数据库事务是不可分割的工作单位，只有事务中的所有的数据库操作都执行成功，才算整个事务成功。事务中任何一个 SQL 执行失败，已经执行成功的 SQL 语句也必须撤销，回到执行事务的之前的状态。
   
2. C (Consistency) 一致性
   一致性指事务将数据库的一种一致性状态转变为另一种一致性的状态。在事务开始之前和结束后，数据库的完整性约束都没有被破坏掉。
   以转账的例子，假设 A(1000) 和 B(0) 的总金额为 1000 元，无论是 A 转钱给 B 还是 B 转钱给 A，无论怎么操作两者的总金额都为 1000 不会改变，不会多也不会少。

3. I (Isolation) 隔离性
   隔离性要求每个读写事务对其他事务操作的对象互相分离。
   比如 A 转账的操作不会因为别人也在转账而收到干扰。

4. D (Durability) 持久性
   持久性指一个事务被提交之后，其结果将永久性的保存。它对数据库中数据的改变是持久的，即使数据库发生故障也不应该对其有任何影响。

---

#### 事务的控制语句

1. MYSQL 事务控制语句

   ```mysql
   start transaction begin # 显示的开启一个事务
   commit # 提交一个事务
   roolback # 回滚事务
   savepoint identifier # 在事务当中创建一个保存点
   release savepoint identifier # 删除事务保存点
   rollback to [savepoint] identifier # 回滚到事务当中的某个保存点
   set transaction transaction_level # 修改事务的隔离级别
   
   ---
   set session transaction isolation level read committed; # 修改会话级别的事务
   ```

2. MYSQL 的事务隔离级别
   [READ UNCOMMITTED 读未提交， READ COMMITTED 读已提交，
   REPEATABLE READ 可重复读， SERIALIZABLE 序列化] 事务隔离级别由低到高
   ***InnoDB 默认的隔离级别是 REPEATABLE READ 级别***
   *隔离级别越低，事务请求锁和保持锁的时间越短*

   1. READ UNCOMMITTED 读未提交 [TRANSACTION_READ_UNCOMMITTED]
      即一个事务读到了另一个未提交事务修改过的数据。
      有可能产生 **脏读**
   2. READ COMMITTED 读已提交 [TRANSACTION_READ_COMMITTED]
      READ COMMITTED 中文叫已提交读，或者叫不可重复读。
      即一个事务能读到另一个已经提交事务修改后的数据，如果其他事务均对该数据进行修改并提交，该事务也能查询到最新值。
      从某种程度上已提交读是违反事务的隔离性的。
   3. REPEATABLE READ 可重复读 [TRANSACTION_REPEATABLE_READ]
      即事务能读到另一个已经提交的事务修改过的数据，但是第一次读过某条记录后，即使后面其他事务修改了该记录的值并且提交，该事务之后再读该条记录时，读到的仍是第一次读到的值，而不是每次都读到不同的数据。
   4. SERIALIZABLE 序列化 [TRANSACTION_SERIALIZABLE]
      上面三种隔离级别可以进行 读-读 或者 读-写、写-读三种并发操作，而SERIALIZABLE不允许读-写，写-读的并发操作。

> MYSQL 默认采用 REPEATABLE_READ 隔离级别， ORACLE 默认采用 READ_COMMITTED 隔离级别。

---

#### 并发事务带来的问题

   在典型的应用程序中，多个事务并发运行，经常会操作相同的数据来完成各自的任务（多个用户对同一数据进行操作）。并发虽然是必须的，但可能会导致以下的问题。

1. 脏读 (Dirty Read)
   当一个事务正在访问数据库并且对数据进行了修改，而这种修改还没有提交到数据库中，这是另外一个事务也访问了这个数据，然后使用了这个数据。因为这个数据是还没有提交的数据，那么另一个事务读到的数据是 “脏数据” ，靠 “脏数据” 所做的操作可能导致结果的不正确。

2. 丢失修改 (Lost to modify)
   指在一个事务读取数据的时候，另一个事务也访问了该数据，那么第一个事务中修改了这个数据后，第二个事务也修改了这个数据，这样第一个事务内的数据结构就被丢失掉了，因此称为丢失修改。

3. 不可重复读 (Unrepeatable read)
   指在一个事务内多次读取同一数据，在这个事务还没有结束的时候，另一个事务也访问了该数据，那么，在第一个事务的两次读取数据之间，由于第二个事务的修改导致第一个事务两次读取的数据可能不一样。这样就发生在一个事务内两次读取到的数据是不一样的情况，因此称为不可重复读。

4. 幻读 (Phantom read)
   幻读与不可重复读类似。它发生在事务 (T1) 读取了几行数据后，接着另一个并发事务 (T2)  插入了一些数据时，在随后的查询当中，事务 T1 就会发现对了一些原本不存在的记录，就好像发生了幻觉一样，所以称幻读。

   > 不可重复读和幻读的区别
   > **不可重复读重点在修改， 幻读重点在于新增或者删除**

   

---

事务相关属性定义的接口 : ***`org.springframework.transaction.TransactionDefinition`***

#### SPRING 定义的隔离级别

Spring 定义的隔离级别和 `java.sql.Connection` 定义的隔离级别是一致的

1. `TransactionDefinition#ISOLATION_DEFAULT`
   采用数据库自身的隔离级别， 查看 `java.sql.Connection#getTransactionIsolation`
2. `TransactionDefinition#ISOLATION_READ_UNCOMMITTED`
   允许读取到未被提交的数据。
   可能产生 *脏读 (dirty reads)、不可重复读 (non-repeatable reads)、幻读 (phantom reads)*
3. `TransactionDefinition#ISOLATION_READ_COMMITTED`
   防止一个事务读取到未提交的数据。
   脏读被阻止了，而 *不可重复读、幻读* 任然可能发生。
4. `TransactionDefinition#ISOLATION_REPEATABLE_READ`
   脏读和不可重复读被预防了。幻读还可能发生。
5. `TransactionDefinition#ISOLATION_SERIALIZABLE`
   脏读、不可重复读、幻读都被控制了。



**注意：**普通异常 *Exception* 时不会回滚的，若没有特定指明，默认回滚的为 *Error* 和 *RuntimeException*
`@Transactional(rollbackFor = Exception.class)`

#### SPRING 事务的传播行为

当事务方法被另一个事务方法调用时，必须指定事务应该如何传播。
默认是 *`Propagation#REQUIRED -> TransactionDefinition.PROPAGATION_REQUIRED`*

1. `TransactionDefinition#PROPAGATION_REQUIRED`

   Spring 默认的事务传播方式，*支持当前事务*，如果有就加入存在的事务，没有事务就创建一个新的事务。

   **注意：**外层事务提交了后内层事务才会提交。内/外只要报错它内外都会一起回滚。
   **只要内层方法报错抛出异常，即使外层有try-catch，该事务也会回滚！**
   *因为内外层方法在同一个事务中，内层只要抛出了异常，这个事务就会被设置成 **rollback-only**，即使外层 try-catch 内层的异常，该事务也会回滚。*

   ```java
   -> 内部报错
   Participating transaction failed - marking existing transaction as rollback-only
   Initiating transaction rollback
   Rolling back JDBC transaction on Connection
       
   --> 外部事务报错
   Initiating transaction rollback
   Rolling back JDBC transaction on Connection
       
   -> 内部报错外部 try-catch (还是会回滚)
   Global transaction is marked as rollback-only but transactional code requested commit
       
   ----
   Transaction rolled back because it has been marked as rollback-only
   ```

   

2. `TransactionDefinition#PROPAGATION_SUPPORTS`
   *支持当前事务*，如果当前执行存在事务就加入事务，没有事务就不处理事务。
此注解表示的本身是没有事务性的。
   
3. `TransactionDefinition#PROPAGATION_MANDATORY`
   *支持当前事务*，如果当前执行存在事务就加入此事务，没有事务则会抛出异常。
若执行的方法没有事务则抛出异常：
   *No existing transaction found for transaction marked with propagation 'mandatory'*
   内层的事务要等外层事务处理完成后提交才一起提交。
   
   ```java
   DataSourceTransactionManager - Participating in existing transaction
   ```
   
   
   
4. `TransactionDefinition#PROPAGATION_REQUIRES_NEW`
   *不支持当前事务*，如果执行存在事务，若执行存在原始事务则把其挂起，自己新创建一个事务来执行。

   * 内层事务结束后提交，不用等外层事务一起提交。
   * 若外层事务报错回滚不会影响内层事务的处理。
   * 内层报错回滚，外层 try-catch 内层异常，外层不用回滚。
   * **内层报错回滚后又抛出异常，外层如果没有捕获处理内层抛出的异常，外层还是会回滚的。**

   ```java
   --> 外层异常
   Suspending current transaction, creating new transaction with name [~~~~]
   Initiating transaction commit 内部的事务提交了
   Resuming suspended transaction after completion of inner transaction 回到外部事务
   Initiating transaction rollback 外部事务回滚
   
   --> 内部异常抛出，外部接受并处理
   Initiating transaction rollback
   Resuming suspended transaction after completion of inner transaction
   Initiating transaction commit
       内部事务回滚，外部事务提交
   ```

   **注意：**对于不是 *RuntimeException* 或 *Error* 默认处理的异常，内层抛出的异常如 *IOException*  异常，内层有用 `rollbackFor = Exception.class` 处理而外层并未处理，那么内层会回滚而外层时不会回滚的。

5. `TransactionDefinition#PROPAGATION_NOT_SUPPORTED`
   *不支持当前事务*，以不存在事务的方式执行，存在事务则会被挂起。

   ```java
   DataSourceTransactionManager - Suspending current transaction [挂起存在的线程]
   ```
   
   
   
6. `TransactionDefinition#PROPAGATION_NEVER`
   *不支持当前事务*，如果当前存在事务则会抛出异常，所有的执行都以不含事务的方式执行。

7. `TransactionDefinition#PROPAGATION_NESTED`
   *不支持当前事务*，如果当前存在事务，创建一个新的事务以内嵌的方式执行，把原始事务挂起。
   若原始不存在事务则相当于 `TransactionDefinition#PROPAGATION_REQUIRED`

   > 使用前提：
   >
   > 1. JDK 版本要在 1.4 以上，有 *java.sql.Savepoint*。因为 nested 就是用 *savepoint* 来实现的。
   > 2. 事务管理器的 nestedTransactionAllowed 属性为 true。
   > 3. **外层 *try-catch* 内层的异常。**
   
   * 内层事务结束要等着外层事务一起提交
   * 外层事务回滚，内层事务也会一起回滚
   * 如果只是内层事务回滚，外层事务不受影响（但是注意，这里的内层事务不影响外层事务是有前提的，否则内外都回滚，前提为上三条）
   
   ```java
   --> 外层事务出错，回滚，内层无影响
   Creating nested transaction with name [内层新建内部事务]
   Initiating transaction rollback [内部事务提交]
   Rolling back JDBC transaction on Connection [外部事务回滚，内部事务跟着回滚]
   
   --> 内层异常抛出，外层捕获异常并处理，内层回滚，外层无影响提交。
   [强调一下，内层是 nested 模式下，外层要 try-catch 内层的异常，外层才不会回滚]
   [而内层是 REQUIRED 模式的话，即是外层 try-catch 内层异常，外层同样会回滚的]
   
   Creating nested transaction with name [~~~] [内层建立事务]
   Rolling back transaction to savepoint [内层回滚到事务建立时的 savepoint]
   Initiating transaction commit [因为外层处理了异常，外层数据提交]
   ```
   
   


> **PROPAGATION_NESTED** 是 Spring 所特有的。
> 以 PROPAGATION_NESTED 启动的事务内嵌于外部事务中（如果存在外部事务的话），此时，内嵌事务并不是一个独立的事务，它依赖于外部事务的存在，只有通过外部的事务提交，才能引起内部事务的提交，嵌套的子事务不能单独提交。
> 如果熟悉 JDBC 中的保存点（SavePoint）的概念，那嵌套事务就很容易理解了，其实嵌套的子事务就是保存点的一个应用，一个事务中可以包括多个保存点，每一个嵌套子事务。另外，外部事务的回滚也会导致嵌套子事务的回滚。

   

### 事务的传播策略

> 由于 Spring 事务是基于 AOP 的，所以事务以方法为维度存在于 Java 代码中。
> 而事务的传播是基于多事务之间相互影响的，所以在代码中表现为一个事务方法调用另一个事务方法
>
> Spring AOP 是基于 bean 增强的，也就是说当你调用一个 bean 的事务方法（被事务注解修饰的方法）时，该事务注解是可以正常生效的。但如果你调用本类中的事务方法，那就相当于将该方法中的代码内嵌到当前方法中，即该方法的事务注解会被忽略。