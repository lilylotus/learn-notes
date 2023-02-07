CLASSPATH=".;%JAVA_HOME%\lib;%JAVA_HOME%\lib\tools.jar" <font color="red">注意开始的 . </font>
JAVA_HOME="C:\\jdk1.8"
path="%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin"

来指导编译器在编译的时候去指定的路径下查找引用类

绝对路径：javac -classpath c:/junit3.8.1/junit.jar   xxx.java
相对路径：javac -classpath ../junit3.8.1/Junit.jar  xxx.java
系统变量：javac -classpath %CLASSPATH% xxx.java
**注意：** *%CLASSPATH%* 表示使用系统变量 CLASSPATH 的值进行查找，这里假设 Junit.jar 的路径就包含在 CLASSPATH 系统变量中

何时需要使用 -classpath (-cp)：当你要编译或执行的类引用了其它的类，但被引用类的 .class 文件不在当前目录下时，就需要通过 -classpath 来引入类
何时需要指定路径：当你要编译的类所在的目录和你执行 javac 命令的目录不是同一个目录时，就需要指定源文件的路径 (CLASSPATH 是用来指定 .class 路径的，不是用来指定 .java 文件的路径的) 

源文件中有包声明语句时，编译时要使用 **-d** 路径参数，表示编译时自动生成与包同名的文件夹，并把类文件放到该文件夹下，目的是运行时让 **JVM** 能够在包文件夹下找到要加载的类文件。

源文件中有中文字符时，要编译时要用 **-encoding UTF-8** 参数，否则编译有乱码。

当要编译的多个源文件有引用关系时，先编译不引用其他类的文件，后编译有引用的文件，否则编译会出现“找不到字符”的错误。
当源文件在非当前路径下时，编译或运行时要用到 **-cp** 源文件所在路径参数，表示到所给路径下寻找源文件。

---

**javac**

**-classpath：**可以简写成 -cp，设定要搜索类的路径，可以是目录，jar文件，zip文件（里面都是class文件），会覆盖掉所有在 CLASSPATH 里面的设定
**-sourcepath：**设定要搜索编译所需 java 文件的路径，可以是目录、jar文件、zip文件（里面都是 java 文件）
**-d：** 用于指定编译成的 class 文件的存放位置，缺省情况下不指定 class 文件的存放目录，编译的 class 文件将和源文件在同一目录下

假设 abc.java 在路径 c:\src 里面，在任何的目录的都可以执行以下命令来编译。

```java
javac -classpath c:\classes;c:\jar\abc.jar;c:\zip\abc.zip -sourcepath c:\source\project1\src;c:\source\project2\lib\src.jar;c:\source\project3\lib\src.zip c:\src\abc.java
```

---

**java**

**-classpath：**设定要搜索的类的路径，可以是目录、jar文件、zip文件（里面都是 class 文件），会覆盖掉所有的 CLASSPATH 的设定。
由于所要执行的类也是要搜索的类的一部分，所以一定要把这个类的路径也放到 -classpath 的设置里面。
在要执行的类的路径里面执行 java 时，一定要添加上点号**（.）**标示本目录也要搜索。

假设 abc.class 在路径 c:\src 里面

可以在任何路径下执行以下命令
java -classpath c:\classes;c:\jar\abc.jar;c:\zip\abc.zip;c:\src abc

**问题：**如果 main.class 属于c:\jar\abc.jar，并且在 com.test 这个包里，那么执行
`java -classpath c:\classes;c:\jar\abc.jar;c:\zip\abc.zip; com.test.main`



---

在 windows 下，
文件路径的分割符为反斜杠  \
类或者 java 文件列表的分割符为分号 ;

在 linux 下
文件路径的分隔符位斜杠 /
类或者 java 文件列表的分隔符为冒号 :

`javac -classpath /tmp/javatest/lib/mail-1.3.3.jar -d /tmp/javatest/bin/ /tmp/javatest/src/Capability.java`

`java -classpath /tmp/javatest/lib/mail-1.3.3.jar:/tmp/javatest/bin/ test.Capability`



```java
list.txt:
E:\algorithm\test\BinarySearch.java
E:\algorithm\test\Drill01.java
E:\algorithm\test\DrillClass01.java
E:\algorithm\test\DrillClassMain.java

compiler.bat
SET EXECLASS="com.example.algorithm.BinarySearch"
SET COMPLIERCLASS="E:\algorithm\test\BinarySearch.java"
SET LISTCLASS="@E:\list.txt"
SET CLASS=".;E:\algorithm\algs4-bin.jar;E:\algorithm\test"
SET SOURCEPATH="E:\algorithm\test"

javac -encoding UTF-8 -cp %CLASS% -d %SOURCEPATH% %LISTCLASS%
java -cp %CLASS% %EXECLASS% algorithm\algs4-data\tinyW.txt

javac -encoding UTF-8 -cp %CLASS% -d %SOURCEPATH% %LISTCLASS%
```

```java
java -Xms2048m -Xmx2048m -Xmn1g -Xss512k -cp %CLASS% %EXECOMCLASS% %DATAFILE%

常见参数种类（配置内存）：（-Xms 、-Xmx、-XX:newSize、-XX:MaxnewSize、-Xmn）
（-XX:PermSize、-XX:MaxPermSize）。
可以从列参数的配置是分组的，前者是用来配置堆区的，后者是用来配置非堆区的。
第一组配置参数：-Xms 、-Xmx、-XX:newSize、-XX:MaxnewSize、-Xmn

=============================================
可能需要依赖额外的 jar 包，那么 javac 和 Java
在编译和运行时我们也要加上依赖的 jar 包，需要注意的是，使用 java -cp 有额外的 jar 的时候
在 Linux 下面 ClassPath 前面是一个点号加一个冒号 .:
在 Windows 下面 ClassPath 前面是一个点号加一个分号 .;
```

##### 打包为可运行 jar 包

Manifest 文件

```java
Manifest-Version: 1.0
Main-Class: cn.nihility.remote.RemoteSay
```

打包

```bat
javac -d D:\jvm *.java

# 使用指定的 manifest ，-C 后面指定要打包的目录， 目录后面的 . 代表目录下所有文件
jar -cvfm boot.jar META-INF/MANIFEST.MF -C bootDir .
jar cvfm jvm.jar manifest

# 打包
jar cvf boot.jar target/demo/DemoTest.class
jar cvf boot.jar .
# 更新 jar 包的 main class
jar ufe boot.jar demo.DemoTest

# 打包当前目录中的所有内容到 jar 包， 0 仅打包不压缩
jar cf0M xxx.jar *
```

```bash
# 创建一个自定义的manifest-custom.mf文件
vim manifest.mf
# 打包 这里要注意如果使用时 cvmf 需要替换 mf 与 jar 文件名的指令位置
jar cvfm boot.jar manifest.mf -C target .

# manifest.mf
Manifest-Version: 1.0
Class-Path: . bcprov-jdk15on-1.60.jar libthrift-0.10.0.jar 
 slf4j-api-1.7.35.jar sdk-for-1.6.jar fpe-1.0.0.jar
Main-Class: demo.DemoTest
```

