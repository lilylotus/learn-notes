

# 类加载流程

[JavaSE doc : 如何找到 Class 文件](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/findingclasses.html#sthref6)， 参考 [JavaSE 11 类加载、链接、初始化](https://docs.oracle.com/javase/specs/jvms/se11/html/jvms-5.html)，参考 [JavaSE 8 类加载、链接、初始化](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-5.html)

【引用维基百科中对 Java 类加载器的介绍】Java 类加载器（Java Classloader）是 Java 运行环境 （Java Runtime Environment）的一个部件，负责**动态加载** Java 类到 Java 虚拟机的内存空间当中。类通常是按需加载，即第一次使用该类时才加载。

Java 虚拟机（Java Virtual Machine）动态加载（loads）、链接（links）、初始化（initializes）类和接口。

## 加载 （loads）

加载是查找具有特定名称的类或接口类型的二进制表示（.class）并从该二进制表示创建类或接口的过程。（Loading is the process of finding the binary representation of a class or interface type with a particular name and creating a class or interface from that binary representation）

每个 Java 类（.class 的类字节码文件）必须由某个类加载器加载到内存当中。

### 类加载器

JVM 中有三个默认的类加载器：

- 引导类（启动类）【Bootstrap】类加载器：有原生的 C++ 编写，不是继承自 `java.lang.ClassLoader`，且在 JVM 虚拟机启动时自动加载，负责加载 Java 核心类库，保存在 *<JAVA_HOME>/jre/lib* 目录中
- 拓展（Extensions）类加载器：负责加载 Java 的拓展库，默认目录为 *<JAVA_HOME>/jre/lib/ext* 或通过指定加载拓展目录参数 `java.ext.dirs` 查找并加载 Java 类。拓展加载器由 `sun.misc.Launcher$ExtClassLoader` 实现。拓展类加载器的父级类加载器就是引导类加载器，但是无法直接通过 `getParent()` 函数来获取 。
-  应用程序（Apps）类加载器：也叫做系统类加载器（System Classloader）。负责根据应用程序类路径（`java.class.path` 或者 `CLASSPATH` 环境变量）来加载类。一般 Java 应用的类都是由应用程序类加载器加载，但是可以通过 `ClassLoader.getSystemClassLoader()` 来获得，由 `sun.misc.Launcher$AppClassLoader` 来实现。应用程序类加载器的父级类加载器是拓展类加载器，可以直接通过 `getParent()` 函数来获取。

除了上面的 JVM 默认的类加载器，可以自定义类加载器来加载类，同时继承 `java.lang.ClassLoader` 抽象类加载器，重写 `java.lang.ClassLoader#loadClass(java.lang.String)` 或 `java.lang.ClassLoader#findClass` 来自定义加载类的流程，来实现打类加载器的**双亲委派机制** 。

###  双亲委派机制

在类加载器加载类的时候，当前的类加载器或先询父级类加载器是否已经有加载过此类了，递归到最上级的引导类加载器，若父级类加载器已经加载过此类了，那么对应父类的所有子类加载器都不会在重复加载此类了。

**注意：** 不同的来加载器加载同一个类的字节码文件到 JVM 内存中时，JVM 会认为加载上来的类是不一样的。JVM 对与对象的唯一标识是 [Classloader 实例 + 类全名(com.example.Test)]。

## 链接（links）

链接是获取类或接口并将其组合到 Java 虚拟机的运行时状态以便可以执行的过程。（Linking is the process of taking a class or interface and combining it into the run-time state of the Java Virtual Machine so that it can be executed. ）

链接其中又分为三个小的步骤：1. 校验 （Verification） 2. 准备（Preparation） 3. 解析（Resolution）

### 验证（Verificaiton）

验证确保那些二进制表示的类或接口是结构正确的。验证可能会导致加载其他类和接口，但不需要验证或准备它们。

### 准备（Preparation）

准备工作包括为类或接口创建**静态字段**并将这些字段初始化为其**默认值**。这不需要执行任何 Java 虚拟机代码，静态字段的显式初始化程序作为初始化的一部分执行，而不是准备。

准备工作可以在创建后的任何时间进行，但必须在初始化之前完成。

### 解析（Resolution）

将符号引用转为直接引用。

The **Java Virtual Machine** instructions *anewarray, checkcast, getfield, getstatic, instanceof, invokedynamic, invokeinterface, invokespecial, invokestatic, invokevirtual, ldc, ldc_w, multianewarray, new, putfield, and putstatic* make symbolic references to the run-time constant pool.

对运行时常量池进行符号引用。执行这些指令中的任何一个都需要解析其符号引用。

解析是从运行时常量池中的符号引用动态确定具体值的过程。

## 初始化（initializes）

类或接口的初始化包括执行类或接口的初始化方法 `<clinit>` （Initialization of a class or interface consists of executing the class or interface initialization method <clinit>）

### 初始化执行条件

类或接口仅当如下情况才会被初始化：

- 当执行其中任何一个（*new, getstatic, putstatic, or invokestatic*） Java 虚拟机指令时。这些指令通过**字段引用**或**方法引用**直接或间接引用类或接口。
  - new : 创建一个对象，通过 `new` 或者反射机制（Create new object）
  - getstatic : 从一个类中获取静态字段 （Get *static* field from class）
  - putstatic：给类的静态字段赋值 （Set *static* field in class）
  - invokestatic：调用类的静态方法（Invoke a class (*static*) method）
- 在类库中调用某些反射方法
- 若是一个类，则当其子类之一初始化时
- 若是一个接口定义非抽象、非静态方法，当一个类直接或间接实现该接口时
- 当一个类作为 Java 虚拟器的启动类时

在初始化之前，必须链接一个类或接口，即已经完成了验证、准备和可选地解析。

### 初始化顺序

用在 *ConstantValue* 中的常量值（constant vlaue）初始化类所有的 `final static` 字段，顺序按照字段在类结构中的顺序。

若是一个类而不是接口时，它的超类还未被初始化时先执行超类的初始化流程。

类的初始化流程：

```
超类 -- 静态变量
超类 -- 静态初始化代码块
子类 -- 静态变量
子类 -- 静态初始化代码块
超类 -- 变量
超类 -- 初始化代码块
超类 -- 构造函数
子类 -- 变量
子类 -- 初始化代码块
子类 -- 构造函数
```

一段测试代码：

```java
public class ClassInitializeOrder {

    public static int k = 0;

    public static ClassInitializeOrder t1 = new ClassInitializeOrder("t1");
    public static ClassInitializeOrder t2 = new ClassInitializeOrder("t2");

    public static int i = print("i");
    public static int n = 99;

    public int a = 0;
    public int j = print("j");

    {
        print("构造块");
    }
    static {
        print("静态块");
    }

    public ClassInitializeOrder(String str) {
        System.out.println((++k) + ":" + str  + " i = " + i + "  n = " + n);
        ++i;
        ++n;
    }

    public static int print(String str) {
        System.out.println((++k) + ":" + str  + " i = " + i + "  n = " + n);
        ++n;
        return ++i;
    }

    public static void main(String[] args) {
        new ClassInitializeOrder("init");
    }

}
```

代码运行结果：

```
1:j i = 0  n = 0
2:构造块 i = 1  n = 1
3:t1 i = 2  n = 2
4:j i = 3  n = 3
5:构造块 i = 4  n = 4
6:t2 i = 5  n = 5
7:i i = 6  n = 6
8:静态块 i = 7  n = 99
9:j i = 8  n = 100
10:构造块 i = 9  n = 101
11:init i = 10  n = 102
```

