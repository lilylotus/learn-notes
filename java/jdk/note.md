### 1. 判断 class 的类型和类实例的类型

#### 1.1 判断 class 的类型

```java
interface BasicInterface;
interface InheritInterface extends BasicInterface;
class BasicInterfaceImpl implements BasicInterface;
class BasicInterfaceImplExtends extends BasicInterfaceImpl;
class InheritInterfaceImpl implements InheritInterface;

/* aClass.isAssignableFrom(B.class) 指的是 aClass 本身或它的子类，也包括接口 */
Class<BasicInterfaceImpl> aClass = BasicInterfaceImpl.class;
aClass.isAssignableFrom(BasicInterfaceImpl.class); // true
aClass.isAssignableFrom(BasicInterfaceImplExtens.class); // true

Class<BasicInterface> basicInterfaceClass = BasicInterface.class;
basicInterfaceClass.isAssignableFrom(BasicInterface.class); // true
basicInterfaceClass.isAssignableFrom(InheritInterface.class); // true
basicInterfaceClass.isAssignableFrom(InheritInterfaceImpl.class); // true
basicInterfaceClass.isAssignableFrom(BasicInterfaceImplExtens.class); // true
```

#### 1.2 判断类实例的类型

```java
/* a instanceof b, a 实例是 b 类本身或子类或子接口 */
BasicInterfaceImpl basicInterface = new BasicInterfaceImpl();
basicInterface instanceof BasicInterface // true

BasicInterfaceImplExtens basicInterfaceImplExtens = new BasicInterfaceImplExtens();
basicInterfaceImplExtens instanceof BasicInterface // true
basicInterfaceImplExtens instanceof BasicInterfaceImpl // true

InheritInterfaceImpl inheritInterface = new InheritInterfaceImpl();
inheritInterface instanceof BasicInterface // true
```

### 获取运行的 java/class 运行目录参数

```java
ProtectionDomain protectionDomain = getClass().getProtectionDomain();
System.out.println(protectionDomain.getCodeSource().getLocation());

//单独 class 运行或 war: file:/D:/test/out/production/classes/
// jar 包运行: file:/D:/test/build/libs/boot.jar
URI uri = protectionDomain.getCodeSource().getLocation().toURI();

// file
System.out.println(uri.getScheme());
// 路径: /D:/test/build/libs/boot.jar
System.out.println(uri.getSchemeSpecificPart());
// 路径: /D:/test/build/libs/boot.jar
System.out.println(uri.getPath());
// 路径: file:/D:/test/build/libs/boot.jar
System.out.println(uri.toURL());

// 运行根目录: D:/test
System.out.println(System.getProperty("user.dir"));
```