Java 类加载器 (**按需加载**)
类加载流程：x.java -> x.class -> ClassLoader -> JVM
类加载器可以把 Java 类动态的加载到 JVM 中并运行，即可以在程序运行时再加载类，提供了灵活的动态加载方式
类装载器就是寻找类或接口字节码文件进行解析并构造 JVM 内部对象表示的组件

> 1、装载：查找和导入Class文件
> 2、链接：其中解析步骤是可以选择的
> （a）检查：检查载入的class文件数据的正确性
> （b）准备：给类的静态变量分配存储空间，并将其初始化为默认值，内存都将在 **方法区** 中分配
> （c）解析：将符号引用转成直接引用
> 3、初始化：对静态变量，静态代码块执行初始化工作

注意：在 链接->准备 阶段，具体初始化默认值。

1. 进行内存分配的 **仅包括类变量**（static），而不包括实例变量，实例变量会在对象实例化时随着对象一块分配在 Java 堆中。
2. 设置的 **初始值通常情况下是数据类型默认的零值**（如 `0`、`0L`、`null`、`false`等），而不是被在 Java 代码中被显式地赋予的值
3. 类字段的字段属性表中存在 ConstantValue 属性，即 **同时被 `final` 和 `static` 修饰**，那么在准备阶段变量 `value` 就会被初始化为 ConstValue 属性所指定的值

示例：

一个类变量 `public static int value = 666;`，在准备阶段时初始值是 `0` 而不是 `666`，在 **初始化阶段** 才会被真正赋值为 `666`。

一个静态类变量 `public static final int value = 666;`，则再准备阶段 JVM 就已经赋值为 `666` 了。

- 启动类加载器 (Bootstrap ClassLoader) 
  加载 Java 核心类库进 JVM 当中，此类加载器时原生的 C++ 代码实现，并不是继承自 java.lang.ClassLoader，它时所有其它类加载器的最终父类加载器，负责加载 **%JAVA_HOME%/jre/lib** 目录下的类库，其实它属于 JVM 整体的一部分，JVM 一启动就将指定的类加载到内存当中，避免以后 I/O 操作，提高系统运行效率，**启动类加载器无法被其它 JAVA 程序直接调用**
- 扩展类加载器 (Application ClassLoader)
  负责加载 Java 的拓展库 [**%JAVA_HOME%/jre/lib/ext**] 目录中的类库，这个类由启动类加载器加载，但因为启动类加载器非 Java 实现，脱离了 Java 体系，所有获取扩展类加载器的父加载器会得到 `null` 值，但是它的父类加载确实是 *启动类加载器*
- 应用程序类加载器 (Application ClassLoader)
  也叫做系统类加载器 (System ClassLoader)，负责加载用户类路径 (**CLASSPATH**) 指定的类库，若引用程序没有自定义类加载器，那么应用程序默认就使用应用程序类加载器，**它由启动类加载器加载，但它的父类加载器被设置成了扩展类加载器**，可以 `ClassLoader.getSystemClassLoader()` 获取

`java.lang.ClassLoader`

```java
java.lang.ClassLoader#loadClass(java.lang.String, boolean)
if (parent != null) {
    c = parent.loadClass(name, false);
} else {
    c = findBootstrapClassOrNull(name); // 最终的父亲类就是 Bootstrap ClassLoader
}

```

###### 双亲委派机制

```java
public class MyClassLoader extends ClassLoader {
    private String name;
    public MyClassLoader(ClassLoader parent, String name) {
        super(parent); this.name = name;
    }
    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        byte[] data = getClassByteArray(name);
        // 自定义的类加载器获取类的字节码文件会指定特定的文件路径
        return this.defineClass(name, data, 0, data.length);
    }
    
    public static void main(String[] args) {
        ClassLoader classLoader = MyClassLoader.class.getClassLoader();
        System.out.println(classLoader);
        MyClassLoader loader = new MyClassLoader(classLoader, "MyClassLoader");
        
        Class<?> clazz = loader.loadClass("cn.nihility.jvm.MyClassExt");
        System.out.println(clazz.getClassLoader());
    }
}

1. 当 MyClassExt 这个类放到 CLASSPATH 路径下是，MyClassExt 会在启动时被 sun.misc.Launcher$AppClassLoader 加载，那么 MyClassLoader 再次加载时发现已经父加载器加载，所以就不会在加载了
> sun.misc.Launcher$AppClassLoader@18b4aac2
> sun.misc.Launcher$AppClassLoader@18b4aac2
    
2. 当 MyClassExt 这个类放到 CLASSPATH 路径以外，这时就会由 MyClassLoader 自己加载
> sun.misc.Launcher$AppClassLoader@18b4aac2
> MyClassLoader
```

> 在 *Classloader* 加载类字节码文件到 *JVM* 的时候，当前的类加载器会先询问它的父类加载器是否有加载过此类，以此递归到 *Bootstrap Classloader*，当询问的时候某个父类加载器有加载此类文件，那么当前类加载器就不会在加载此类了。

<font color="red">注意: 不同的类加载器加载的同一个类字节码文件到 JVM 中的对象不一样, `JVM` 中 Class 对象唯一标识是 *[Classloader 实例 + 类全名 (com.test.UniqueClass)]*</font>

###### 打破双亲委派机制

1. 重写 `loadClass` 方法，自定义加载规则 (灵活，推荐)

   ```java
   @Override
   public Class<?> loadClass(String name) throws ClassNotFoundException {
       System.out.println("loadClass name : " + name);
       return findClass(name);
   }
   > 这里会报错 java.lang.SecurityException: Prohibited package name: java.lang
   	> java.lang.ClassLoader#preDefineClass
   	> Class<?> c = defineClass1(name, b, off, len, protectionDomain, source);
   > loadClass name : cn.nihility.jvm.MyClassExt
   > loadClass name : java.lang.Object
   这里符合类加载的时候会默认加载其父类 (Object)
   
   先使用 AppClassloader 加载
       @Override
       public Class<?> loadClass(String name) throws ClassNotFoundException {
       System.out.println("loadClass name : " + name);
       Class<?> clazz = findClass(name);
       System.out.println("loadClass in findClass clazz -> " + clazz);
       if (clazz != null) { return clazz; }
       return getSystemClassLoader().loadClass(name);
   }
   // 先用自定义的类加载器加载，打破双亲委派机制，自己没有找到在交给系统类加载器加载。
   ```

2. 设置当前类加载器父类加载器为 `null`，直接使用本类加载器 (不建议)



java 程序以 .java （文本文件）的文件存在磁盘上
通过 (bin/javac.exe) 编译命令把 .java 文件编译成 .class 文件（字节码文件）并存在磁盘上
首先一定要把 .class 文件加载到 JVM 内存中才能使用
classLoader 就是负责把磁盘上的 .class 文件加载到 JVM 内存中

**3 种 ClassLoader**

1. Bootstrp Loader
    Bootstrp 加载器是用 C++ 语言写的，它是在 Java 虚拟机启动后初始化的
    称为启动类加载器，是 Java 类加载层次中最顶层的类加载器
    负责加载  JDK  中的核心类库，如：rt.jar、resources.jar、charsets.jar 等
2. ExtClassLoader 
    Bootstrp loader 加载 ExtClassLoader
    ExtClassLoader 的父加载器设置为 Bootstrp loader.ExtClassLoader 是用 Java 写的
    扩展类加载器，负责加载 Java 的扩展类库，默认加载 JAVA_HOME/jre/lib/ext/ 目下的所有 jar
3. AppClassLoader 
    Bootstrp loader 加载完 ExtClassLoader 后，就会加载 AppClassLoader
    并且将 AppClassLoader 的父加载器指定为  ExtClassLoader
    系统类加载器，负责加载应用程序 classpath 目录下的所有 jar 和 class 文件
    它主要加载我们应用程序中的类，如 Test 或者用到的第三方包,如 jdbc 驱动包等
    这里的父类加载器与类中继承概念要区分，它们在 class 定义上是没有父子关系的

除了 Java 默认提供的三个 ClassLoader 之外，用户还可以根据需要定义自已的 ClassLoader
而这些自定义的 ClassLoader 都必须继承自 java.lang.ClassLoader 类

为什么要有三个类加载器，一方面是分工，各自负责各自的区块，另一方面为了实现委托模型。

**ClassLoader 加载类的原理** 
ClassLoader 使用的是**双亲委托模型**来搜索类

1. 为什么要使用双亲委托这种模型呢？
可以避免重复加载，当父亲已经加载了该类的时候，就没有必要子 ClassLoader 再加载一次
考虑到安全因素，如果不使用这种委托模式，那我们就可以随时使用自定义的 String 来
动态替代 java 核心 api 中定义的类型，这样会存在非常大的安全隐患，而双亲委托的方式,
就可以避免这种情况，
因为 String 已经在启动时就被引导类加载器（Bootstrcp ClassLoader）加载，
所以用户自定义的 ClassLoader 永远也无法加载一个自己写的 String，
除非你改变 JDK 中 ClassLoader 搜索类的默认算法。

2. JVM 在搜索类的时候，又是如何判定两个 class 是相同的呢？
JVM 在判定两个 class 是否相同时，不仅要判断两个类名是否相同，
而且要判断是否由同一个类加载器实例加载的。
只有两者同时满足的情况下，JVM 才认为这两个 class 是相同的。
就算两个 class 是同一份 class 字节码，如果被两个不同的 ClassLoader 实例所加载，
JVM 也会认为它们是两个不同 class。