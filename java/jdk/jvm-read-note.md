> Java Virtual Machine 对 Java 编程语言一无所知，仅会处理一些特定的 *二进制*  格式和 *class* 文件。
> Java *class* 文件包含了 *Java Virtual Machine* 指令集 (字节码) 和符号表还有一些辅组信息。

###### *Java Virtual Machine* 原始类型 (primitive type) 支持 [整型/浮点类型]

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

###### *Float-Point* (浮点) 值集合/值

> 遵循 *IEEE 754* 的标准，定义了范围内的正负值、正负零、正负无穷性 (*infinities*)、制定了一个不是数的值 (`NaN`) [使用来表示确定的无效操作返回结果，如：0/0 (零除零)]

*s* ⋅ *m* ⋅ 2(*e* − *N* + 1), where *s* is +1 or −1, *m* is a positive integer less than 2*N*, and *e* is an integer between *Emin* = −(2*K*−1−2) and *Emax* = 2*K*−1−1, inclusive, and where *N* and *K* are parameters that depend on the value set.

**Table 2.3.2-A. Floating-point value set parameters**

| Parameter | float | float-extended-exponent | double | double-extended-exponent |
| --------- | ----- | ----------------------- | ------ | ------------------------ |
| *N*       | 24    | 24                      | 53     | 53                       |
| *K*       | 8     | ≥ 11                    | 11     | ≥ 15                     |
| *Emax*    | +127  | ≥ +1023                 | +1023  | ≥ +16383                 |
| *Emin*    | -126  | ≤ -1022                 | -1022  | ≤ -16382                 |

###### *boolean*

> Java 虚拟机使用 1 表示 *true* ， 0 表示 *false*
> 如果编译器将 Java 编程语言的布尔值映射到 Java 虚拟机类型 *int* 的值，则编译器必须使用相同的编码。

###### 引用类型

有三种引用类型：类类型、数组类型、接口类型
数据的元素类型可是：原始类型、类(class)类型、接口类型
引用类型默认值为 `null` (指向没有对象)



##### *Java* 虚拟机结构

##### 运行时区域 (Run-Time Data Areas)

> *Java Virtual Machine*  在程序执行时定义了多种 *运行时*  数据区域，某些区域在 *Java* 虚拟机启动时创建，关闭时销毁。其它的区域对每个线程，每个线程数据区域在线程被创建时创建，在线程退出时销毁。

##### pc (program counter) Register (寄存器)

> Java 虚拟机可一次支持多个线程。每个 *Java* 虚拟机线程都有自己的 *pc Register* (pc 寄存器)，
> 每个线程都在执行一个方法代码，也就是那个线程当前在执行的代码，如果该方法不是 *native* 方法，那么 *pc* 寄存器就会包含 *Java* 虚拟机正在执行的指令地址，如果被当前线程执行的方法为 *native* 方法，*Java* 虚拟机的 *pc* 寄存器值时未定义的，Java 虚拟机的 pc 寄存器大，可以保存 *returnAddress* 或 在特定平台上 *native* 指针。

###### *Java Virtual Machine* Stack (栈)

> 每个 *Java* 虚拟机线程都有自己私有的 *Java* 虚拟机栈，和 *Java* 虚拟机线程同时创建，它存储本地变量和部分返回结果，在方法调用和返回结果起到作用。
> *Java* 虚拟机栈不会直接被操作，除了帧的出栈和入栈，帧也许是由堆分配，
>
> <font color="blue">Java 虚拟机的内存空间不需要是连续的</font>
>
> <font color="red">栈异常：</font>
> 在一个线程当中的计算超过了 *Java* 虚拟机保证的大小，那么 *Java* 虚拟机会抛出 **StackOverflowError** 异常
> 如果 *Java* 虚拟机栈可以动态的扩展，当尝试扩展但是没有足够的内存来扩展，或者没有足够的内存在创建新 *Java* 虚拟机线程时初始化栈，那么 *Java* 虚拟机会报 **OutOfMemoryError** 异常。

###### Heap (堆)

> Java 虚拟机具有一个在所有 Java 虚拟机线程之间共享的堆。堆是运行时 (Run-Time) 数据区，从中分配所有类实例和数组的内存。
> 堆实在 *虚拟机* 启动时创建，堆存储的对象会被回收被一个自动的存储管理系统 (垃圾收集器)，对象不会被显式的释放内存。
> *Java* 虚拟机设定没有特定的自动存储管理系统，这个自动管理系统的技术由实现者的系统需求决定
> <font color="blue">堆可以是固定大小的，也可以根据计算的要求进行扩展，如果不需要更大的堆，则可以收缩</font>
> 堆的内存不需要一定的连续
> <font color="red">如果计算需要的堆多于自动存储管理系统可以提供的堆，则 Java 虚拟机将抛出 OutOfMemoryError 异常。 </font>

###### Method Area (方法区域)

> *Java* 虚拟机由一个方法区域，由所有的 *Java* 虚拟机线程共享。类似于常规语言编译代码的存储区域或者类似于操作系统的处理的 *文本* 段。
> 它存储了每一个类的结构，如：运行时常量池、字段和方法数据、方法和构造器的代码，包括用于类和实例初始化以及接口初始化的特殊方法
> 方法区域在 *Java* 虚拟器启动时创建，尽管方法区域在逻辑上是堆的一部分，但是简单的实现可以选择不进行垃圾回收或压缩。方法区域可以是固定大小的，或者可以根据计算的需要进行扩展，如果不需要更大的方法区域，则可以缩小。方法区域的内存不必是连续的。
> <font color="red">异常：</font>
> 如果无法使方法区域中的内存可用以满足分配请求，则 Java 虚拟机将抛出 OutOfMemoryError 异常。

###### Run-Time Constant Pool (运行时常量池)

> 运行时常量池是类文件中 *constant_pool* 表的每个类或每个接口的运行时表示形式
> 每个运行时常量池从 *Java* 虚拟机的方法区域分配内存，当 Java 虚拟机创建类或接口时，将为类或接口构造运行时常量池。
>
> <font color="red">异常：</font>
> 创建类或接口时，如果运行时常量池的构造所需的内存超过Java虚拟机的方法区域中可用的内存，则 Java 虚拟机将抛出 OutOfMemoryError 异常。

###### Native Method Stacks （本地方法栈）

> Java 虚拟机的实现可以使用传统的堆栈（俗称“ C堆栈”）来支持 *native* 方法（用 Java 编程语言以外的语言编写的方法）
> Java 虚拟机的指令集的解释器的实现可用例如 *C* 语言，本地方法栈可能来使用。
> *Java* 虚拟机实现无法加载 *native* 方法且本身不依赖常规堆栈，不需要提供 *native* 方法堆栈
> 如果提供，通常在创建每个线程时为每个线程分配 *native* 方法堆栈。
> <font color="red">异常：</font>
> 如果线程中的计算所需的本机方法堆栈超出允许的范围，则 Java 虚拟机将抛出 StackOverflowError 异常。
> 如果可以动态扩展本机方法堆栈并尝试进行本机方法堆栈扩展，但可能无法提供足够的内存或者如果无法提供足够的内存来为新线程创建初始本机方法堆栈，则 Java 虚拟机将抛出 OutOfMemoryError 异常。

###### Frame （帧）

> Frame 用于存储数据和部分结果，以及执行动态链接，方法的返回值和调度异常
> <font color="blue">每次调用方法时都会创建一个新 (Frame) 框架，当方法调用完成后 Frame 就会被销毁，无论方法是正常的调用完成还是突然的（它抛出了未捕获的异常）</font>
> Frame 是由线程中的 *Java* 虚拟机栈创建，每个 Frame 都有自己本地变量的数组，它自己的操作栈、当前运行类的方法的运行时常量池引用
> 本地变量数组和操作栈的大小由编译时决定，随着 Frame 相关的方法代码一起提供，因此 Frame 数据结构的大小仅仅依赖于 *Java* 虚拟机的实现，这些结构的内存可随着方法的调用被分配。
> 在给定的控制线程中，仅执行方法的那个 Frame 在任何时候都是激活的，该 Frame 称为 *当前 Frame*，然后这个方法被称为 *当前方法*， 这个定义当前方法的类被称为 *当前类*。操作本地变量和操作栈典型的引用当前帧
>
> 如果方法调用另一个方法或者方法完成了那么当前 Frame 就会停止。当一个方法被调用，一个新的 Frame 会被创建然后变为当前 Frame，并把控制权传输到新的方法。一个方法返回值，当前 Frame 回传结果给它调用方法，如果有那么给前一个 Frame。<font color="red">前一帧变为当前帧时，当前帧将被丢弃。
> </font>
> <font color="blue">请注意，由线程创建的框架在该线程本地，并且不能被任何其他线程引用。</font>

###### Local Variables （本地变量）

> Java虚拟机使用局部变量在方法调用时传递参数。在调用类方法时，所有参数都将从局部变量 0 开始在连续的局部变量中传递。
> 在调用实例方法时，始终使用局部变量 0 将引用传递给在其上调用实例方法的对象（*this* 在 Java 编程语言中）随后将任何参数传递到从局部变量 1 开始的连续局部变量中。

###### Operand Stacks

> 每个帧包含一个后进先出（LIFO）堆栈，称为其操作数堆栈。Frame 的最大操作数堆栈深度是在编译时确定的，并与与该 Frame 关联的方法的代码一起提供。



---

######  **Loading, Linking, and Initializing**  (加载、链接、初始化)

> Loading (加载) ：查找特定名称的类或接口由二进制表示的文件，然后依据该二进制数据创建一个类或接口的过程。
> Linking (链接)：链接是获取类或接口并将其组合到 Java 虚拟机的运行时状态以便可以执行的过程
> Initializing (初始化) ：类或接口的初始化包括执行类或接口的初始化方法 <clinit>

