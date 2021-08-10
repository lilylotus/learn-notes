> Java Virtual Machine 对 Java 编程语言一无所知，仅会处理一些特定的 *二进制*  格式和 *class* 文件。
> Java *class* 文件包含了 *Java Virtual Machine* 指令集 (字节码) 和符号表还有一些辅组信息。

## 数据类型

### *Java Virtual Machine* 原始类型 (primitive type) 支持 [整型/浮点类型]

| 类型    | 表示                                  | 初始值  |
| ------- | ------------------------------------- | ------- |
| byte    | 8-bit 带符号的补码                    | 0       |
| short   | 16-bit 带符号的补码                   | 0       |
| int     | 32-bit 带符号的补码                   | 0       |
| long    | 64-bit 带符号的补码                   | 0       |
| char    | 16-bit 无符号整型 (UTF-16) 编码       | \u0000  |
| float   | 浮点数值的集合/浮点扩展指数值集       | +0(正0) |
| double  | double 数值的集合/double 扩展指数值集 | +0(正0) |
| boolean | true/false                            | false   |

<font color="blue">*returnAddress* 类型也是原始类型，但是并不能直接通过 java 编程语言获取该类型值</font>

- For `byte`, from -128 to 127 (-27 to 27 - 1), inclusive
- For `short`, from -32768 to 32767 (-215 to 215 - 1), inclusive
- For `int`, from -2147483648 to 2147483647 (-231 to 231 - 1), inclusive
- For `long`, from -9223372036854775808 to 9223372036854775807 (-263 to 263 - 1), inclusive
- For `char`, from 0 to 65535 inclusive

### *Float-Point* (浮点) 值集合/值

> 遵循 *IEEE 754* 的标准，定义了范围内的正负值、正负零、正负无穷性 (*infinities*)、制定了一个不是数的值 (`NaN`) [使用来表示确定的无效操作返回结果，如：0/0 (零除零)]

*s* ⋅ *m* ⋅ 2(*e* − *N* + 1), where *s* is +1 or −1, *m* is a positive integer less than 2*N*, and *e* is an integer between *Emin* = −(2*K*−1−2) and *Emax* = 2*K*−1−1, inclusive, and where *N* and *K* are parameters that depend on the value set.

**Table 2.3.2-A. Floating-point value set parameters**

| Parameter | float | float-extended-exponent | double | double-extended-exponent |
| --------- | ----- | ----------------------- | ------ | ------------------------ |
| *N*       | 24    | 24                      | 53     | 53                       |
| *K*       | 8     | ≥ 11                    | 11     | ≥ 15                     |
| *Emax*    | +127  | ≥ +1023                 | +1023  | ≥ +16383                 |
| *Emin*    | -126  | ≤ -1022                 | -1022  | ≤ -16382                 |

### 布尔类型 *boolean*

Java 虚拟机使用 1 表示 *true* ， 0 表示 *false*。使用 `int` 类型表示 `boolean` 类型。

在 *Oracle* 的 Java 虚拟机的实现中，`boolean` 数组用 `byte` 数组表示，每一个 boolean 元素使用 8 bit 的表示。

### 引用类型

有三种引用类型：类类型 (`class`)、数组类型(`array`)、接口类型(`interface`)
数据的元素类型可是：原始类型、类(class)类型、接口类型
引用类型默认值为 `null` (指向没有对象)

## *Java* 虚拟机结构

[Java JVM 内存结构](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-2.html)

![JVM](../../images/jvm.png)

![JVM内存](../../images/jvm_jmm.png)

- -Xms 设置堆的最小空间大小。
- -Xmx 设置堆的最大空间大小。
- -XX:NewSize 设置新生代最小空间大小。
- -XX:MaxNewSize 设置新生代最大空间大小。
- -XX:PermSize 设置永久代最小空间大小。
- -XX:MaxPermSize 设置永久代最大空间大小。
- -Xss 设置每个线程的堆栈大小

### 运行时数据区域 (Run-Time Data Areas)

*Java Virtual Machine*  在程序执行时定义了多种 *运行时*  数据区域，某些区域在 *Java* 虚拟机启动时创建，关闭时销毁。其它数据区是对应每个线程。每个线程数据区域在线程被创建时创建，在线程退出时销毁。

#### PC 寄存器 (pc (program counter) Register)

Java 虚拟机 (`Java Virtual Machine`) 可支持多个线程同时执行。<font color="red">每个 *Java* 虚拟机线程都有自己的 *pc (program counter) Register* (pc 寄存器)。</font>

在任何时候，每个 Java 虚拟机线程都在执行单个方法的代码，也就即该线程的当前方法。

如果该方法不是 *native* 方法，那么 *pc* 寄存器就会保存（包含) *Java* 虚拟机正在执行的指令地址。如果被当前线程执行的方法为 *native* 方法，*Java* 虚拟机的 *pc* 寄存器值是未定义 （undefined）的。

Java 虚拟机的 pc 寄存器足够大，可以保存 `returnAddress` 或在特定平台上 *native* 指针。

#### Java 虚拟机栈 （Java Virtual Machine Stack）

<font color="red">每个 *Java* 虚拟机线程都有自己私有的 *Java* 虚拟机栈，</font>在 *Java* 虚拟机线程创建时同时创建。*Java* 虚拟机栈存储帧 (`frames`)。栈帧。

一个 Java 虚拟机栈和传统编程语言（C）中的栈数据结构类似，它存储本地变量和部分返回结果，在方法调用和返回结果起到作用。

*Java* 虚拟机栈不会直接被操作，除了帧的出栈和入栈，帧也许是由堆分配。

<font color="red">Java 虚拟机的内存空间不需要是连续的</font>

Java 官方文档保证，Java Virtual Machine Stack （栈）要么是固定大小，或依据需要动态扩展/收缩大小。

当 Java 虚拟机栈是固定大小时，每一个 Java 虚拟机栈在栈创建时就独立分配了大小。

<font color="red">栈异常：</font>
在一个线程当中的计算超过了 *Java* 虚拟机保证的大小，那么 *Java* 虚拟机会抛出 **StackOverflowError** 异常。
如果 *Java* 虚拟机栈可以动态的扩展，当尝试扩展但是没有足够的内存来扩展，或者没有足够的内存在创建新 *Java* 虚拟机线程时初始化栈，那么 *Java* 虚拟机会报 **OutOfMemoryError** 异常。

#### 堆 (Heap)

Java 虚拟机有一个在所有 Java 虚拟机线程之间共享的堆 (`Heap`）。堆是运行时 (`Run-Time`) 数据区，从中分配所有类实例和数组的内存。

堆在 *Java 虚拟机* 启动时创建。堆存储的对象会被一个自动的存储管理系统 (垃圾收集器) 回收，对象不会被显式的释放 （deallocated） 内存。

*Java* 虚拟机设定没有特定的自动存储管理系统，这个自动管理系统的技术由实现者的系统需求决定。

<font color="blue">堆可以是固定大小的，也可以根据计算要求进行扩展，如果大的堆不是必要的，则可以收缩</font>

堆的内存不需要一定是连续的

<font color="red">如果计算需要的堆多于自动存储管理系统可以提供的堆，则 Java 虚拟机将抛出 `OutOfMemoryError` 异常。 </font>

#### 方法区 （Method Area）

<font color="red">*Java* 虚拟机有一个所有 *Java* 虚拟机线程共享的方法区域 （method area)。</font>这方法区域类似于常规编程语言编译代码的存储区域或者类似于操作系统的处理的 *文本* （text）段。

它存储了每一个类的结构，如：运行时常量池、字段和方法数据、方法和构造器的代码，包括用于类和实例初始化以及接口初始化的特殊方法。

方法区域在 *Java* 虚拟器启动时创建。**尽管方法区域在逻辑上是堆的一部分**，但是简单的实现可以选择不进行垃圾回收或压缩。本规范不强制要求方法区的位置或用于管理编译代码的策略。

方法区域可以是固定大小的，或者可以根据计算的需要进行扩展，如果不需要更大的方法区域，则可以缩小。方法区域的内存不必是连续的。

如果无法使方法区域中的内存可用以满足分配请求，则 Java 虚拟机将抛出 `OutOfMemoryError` 异常。

#### 运行时常量池 （Run-Time Constant Pool）

运行时常量池是一个在每个类（per-class）或每个接口（per-interface）的 class 文件中常量表 （constant_table）运行时表示形式。

它包含几种常量：范围从编译时已知的数字文字到必须在运行时解析的方法和字段引用。

运行时常量池的功能类似于传统编程语言的符号表（symbol table），尽管它包含比典型符号表更广泛的数据。

**每个运行时常量池从 *Java* 虚拟机的方法区域分配内存。**当 Java 虚拟机创建类或接口时，将为类或接口构造运行时常量池。

**异常：**
创建类或接口时，如果运行时常量池的构造所需的内存超过 Java 虚拟机的方法区域中可用的内存，则 Java 虚拟机将抛出 `OutOfMemoryError` 异常。

#### 本地方法栈 （Native Method Stacks）

Java 虚拟机的实现可以使用传统的堆栈（俗称“ C堆栈”）来支持 *native* 方法（用 Java 编程语言以外的语言编写的方法）。

native 方法堆栈也可以由 Java 虚拟机指令集的解释器实现使用，例如 C 语言。

无法加载 native 方法且本身不依赖常规堆栈的 Java 虚拟机实现不需要提供 native 方法堆栈。

如果提供，**通常在创建每个线程时为每个线程分配 *native* 方法堆栈。**

本规范允许 native 方法堆栈具有固定大小或根据计算需要动态扩展和收缩。如果本机方法堆栈的大小是固定的，则在创建该堆栈时可以独立选择每个本机方法堆栈的大小。

*Java 虚拟机实现可以让程序员或用户控制本地方法堆栈的初始大小，以及在可变大小的本地方法堆栈的情况下，控制最大和最小方法堆栈大小。*

<font color="red">异常：</font>
如果线程中的计算所需的本机方法堆栈超出允许的范围，则 Java 虚拟机将抛出 StackOverflowError 异常。
如果可以动态扩展本机方法堆栈并尝试进行本机方法堆栈扩展，但可能无法提供足够的内存或者如果无法提供足够的内存来为新线程创建初始本机方法堆栈，则 Java 虚拟机将抛出 OutOfMemoryError 异常。

### Frame （帧）

Frame 用于存储数据和部分结果，以及执行动态链接、方法返回值和调度异常。

<font color="blue">每次方法调用时都会创建一个新 (Frame) 帧。当方法调用完成后 Frame 就会被销毁，无论方法是正常的调用完成还是突然的（它抛出了未捕获的异常）</font>

<font color="red">Frame 帧是从创建帧的线程的 Java 虚拟机堆栈分配的。</font>每个帧（frame）都有自己的局部变量数组，自己的操作数堆栈、当前方法的类的运行时常量池的引用。

*可以使用附加的特定于实现的信息（例如调试信息）来扩展帧。*

局部变量数组和操作栈的大小在编译时决定，并和与帧（frame）关联的方法的代码一起提供。因此， Frame 数据结构的大小仅取决于 *Java* 虚拟机的实现，并且这些结构的内存可以在方法调用时同时分配。

只有一个 frame，即执行方法的 frame，在给定的控制线程中的任何一点都处于活动（激活）状态。该 frame 称为当前帧（frame），其方法称为当前方法 （current method）。当前方法所在的类被定义为当前类（class）。对局部变量和操作数堆栈的操作通常参考（引用）当前帧。

如果一个 frame 的方法调用另一个方法或如果它的方法完成，它就不再是当前的。当方法被调用时，会创建一个新 frame，并变为当前 frame 当将控制转移到这个新方法时。在方法返回时，当前帧将其方法调用的结果（如果有 [if any]）传递回前一帧。然后丢弃（discarded）当前帧，因为前一帧成为当前帧。

<font color="red">请注意，由线程创建的帧是该线程的本地帧，不能被任何其他线程引用。</font>

#### 局部变量 （Local Variables）

每个 frame 都包含一个变量数组，称其为局部变量。帧 （frame）的局部变量数组长度在编译时（compile-time ）确定，并以类（class）或接口（interface）的二进制表示形式以及与 frame 关联的方法的代码提供。

单个局部变量可以保存 boolean、byte、char、short、int、float、reference 或 returnAddress 类型的值。一对局部变量可以保存 long 或 double 类型的值。

局部变量通过索引寻址。第一个局部变量的索引为零。当且仅当该整数在局部变量数组的大小 0 到小于数组长度之间时，整数才被认为是局部变量数组的索引。

*long* 或 *double* 类型的值占用两个连续的局部变量。这样的值只能使用较小的索引来寻址。

Java 虚拟机不需要 n 为偶数。直观地说，long 和 double 类型的值不需要在局部变量数组中 64 位对齐。

Java 虚拟机使用局部变量在方法调用时传递参数。在类方法调用中，任何参数都在从局部变量 0 开始的连续局部变量中传递。在实例方法调用时，局部变量 0 始终用于传递对调用实例方法的对象的引用（Java 编程语言中的 *this*）。任何参数随后都会在从局部变量 1 开始的连续局部变量中传递。

#### 操作数栈 （ Operand Stacks）

每个帧包含一个后进先出（LIFO）堆栈，称为其操作数堆栈。帧的操作数堆栈的最大深度在编译时确定，并与与该帧关联的方法的代码一起提供。

在上下文明确的情况下，我们有时会将当前帧的操作数堆栈简称为操作数堆栈。

创建包含操作数堆栈的帧创建时，操作数堆栈为空。Java 虚拟机提供将常量或值从局部变量或字段加载到操作数堆栈的指令。其他 Java 虚拟机指令从操作数堆栈中获取操作数，对其进行操作，并将结果推回到操作数堆栈上。操作数堆栈还用于准备要传递给方法的参数和接收方法结果。

这些对操作数堆栈操作的限制是通过类文件验证来强制执行的。

在任何时候，操作数堆栈都有一个关联的深度，其中 long 或 double 类型的值对深度贡献两个单位，任何其他类型的值贡献一个单位。

#### 动态链接 （Dynamic Linking）

每个帧都包含对当前方法类型的运行时常量池的引用，以支持方法代码的动态链接。方法的类（class）文件代码指的是要调用的方法和要通过符号引用访问的变量。动态链接将这些符号方法引用转换为具体方法引用，根据需要加载类以解析尚未定义的符号，并将变量访问转换为与这些变量的运行时位置相关联的存储结构中的适当偏移量。

方法和变量的这种后期绑定使得方法使用的其他类中的更改不太可能破坏此代码。

#### 正常方法调用完成（ Normal Method Invocation Completion）

#### 突然的方法调用完成（Abrupt Method Invocation Completion）

---

####  **Loading, Linking, and Initializing**  (加载、链接、初始化)

[JVM 启动加载](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-5.html)

> Loading (加载) ：查找特定名称的类或接口由二进制表示的文件，然后依据该二进制数据创建一个类或接口的过程。
> Linking (链接)：链接是获取类或接口并将其组合到 Java 虚拟机的运行时状态以便可以执行的过程
> Initializing (初始化) ：类或接口的初始化包括执行类或接口的初始化方法 <clinit>

