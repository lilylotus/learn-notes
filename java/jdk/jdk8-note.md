### 接口默认实现

接口里可以写抽象方法，也能写实现方法 （default 默认方法实现）

#### 默认方法和静态方法

Java 1.8 开始可以有方法实现，可以在接口中添加默认方法和静态方法。
默认方法使用 `default` 修饰，只能用在接口当中。静态方法使用 `static` 修饰。
并且接口中的默认方法、静态方法可以同时有多个。
<font color="color">注意：</font>接口静态方法不可以被接口实现类重写。可以直接通过静态方法所在的 `接口名`.`静态方法名` 来调用

```java
public interface Map<K,V> {
    /* 默认方法 */
	default V getOrDefault(Object key, V defaultValue) {
        V v;
        return (((v = get(key)) != null) || containsKey(key))
            ? v
            : defaultValue;
    }
    /* 静态方法 */
	public static <K extends Comparable<? super K>, V> Comparator<Map.Entry<K,V>> comparingByKey() {
            return (Comparator<Map.Entry<K, V>> & Serializable)
                (c1, c2) -> c1.getKey().compareTo(c2.getKey());
        }
}
```

#### 多接口继承问题

##### 问题一

```java
interface People {
    default void eat() { System.out.println("People eat"); }
}

interface Man {
    default void eat() { System.out.println("Man eat"); }
}

interface Boy extends People, Man {
    /* 通过重写继承多个接口中相同的默认方法解决冲突
    * 通过 接口.super.默认方法 调用继承接口方法实现
    * */
    @Override default void eat() {
        People.super.eat();
        Man.super.eat();
        System.out.println("Boy eat");
    }
}

class Colleague implements Boy { }

输出：
People eat
Man eat
Boy eat
```

##### 问题二

```java
interface People {
    /* 此时该默认实现会被置灰，表示没有被使用 */
    default void eat() { System.out.println("People eat"); }
}

interface Man extends People {
    @Override default void eat() { System.out.println("Man eat"); }
}

interface Boy extends People, Man { }

class Colleague implements Boy { }

输出：
Man eat
-----
因为 Man 继承了 People，而 Man 又重定义了默认方法 eat，这时候就可以推断出使用那个默认方法。
```

##### 问题三

```java
interface People {
    default void eat() { System.out.println("People eat"); }
}

interface Man extends People {
    @Override default void eat() { System.out.println("Man eat"); }
    /* 因为 Boy 的重新，该抽象方法会提示未被使用 */
    void talk();
}

interface Boy extends People, Man {
    /* 这时候会覆盖掉 Man 的 talk 方法还变为了默认方法 */
    @Override default void talk() { System.out.println("Boy talk"); }
}

class Colleague implements Boy { }

输出：
Man eat
Boy talk
```

