#### 1. 判断 class 的类型和类实例的类型

##### 1.1 判断 class 的类型

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

##### 1.2 判断类实例的类型

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

