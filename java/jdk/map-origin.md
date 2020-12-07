##### `HashMap` 源码理解

> 迭代集合需要的时间比例和 *HashMap* 的实例容量大小和 load factor 有关系
> <font color="blue">重点：别把初始化容量设置的太大，也别把加载因子设置得太小，如果对迭代的性能有要求的时候</font>
>
> 影响 *HashMap* 的性能有： 初始化容量 和 加载因子
> 当 *HashMap* 容量超过了 加载因子和当前容量乘积 时，hash table 将会重建 (内部的数据结构也将会重新构建)，*hash table* 将会两倍于现在

```java
Map<String, String> map = new HashMap<>();
->
JDK 1.8
初始化 HashMap 默认的初始容量 (数组长度) 为 16 [1 << 4]，加载因子为 0.75
注意：默认的初始容量必须为 2 的整次方。容量在阈值后会扩展 2 倍大小。
由 list 变为 tree 存储的阈值，必须大于 2 且至少为 8. (默认的第一次阈值为 12 = 16 * 0.75)
HashMap 可以存放 null 键和 null 值，但不是线程并发安全的，还不会保证 map 键值的排序
```

##### HashMap resize()

* 首次初始化
    1. 指定容量时：threshold （阈值）= 接近初始化容量最大的 2 的幂次方值
    2. 首次初始化时，threshold （阈值）大于零，初始化 table 容量就为 threshold
    3. 没有指定容量，table 容量为默认容量 16，加载因子 0.75
    4. 新的 threshold （阈值） = 容量 * 加载因子

* 扩容
    1. 新容量 = 旧容量 * 2
    2. 新 threshold 在就容量大于默认初始化容量 16 时直接 * 2 （翻倍）
    3. 否则新 threshold = 新容量 * 加载因子

###### hash 值的计算

```java
(h = key.hashCode()) ^ (h >>> 16)
^ (异或) [當兩兩數值相同為否，而數值不同時為真]
```

###### `put()`

> 放到 map 中的位置为 `tab[i = (n - 1) & hash]`  (n 为 tab 的长度，容量大小)，当该位置为 `null` 时，直接放入该位置。 *长度 - 1 与 hash 的求与运算*



---

##### 1. HashMap 初始化

```java
Map<String, String> map = new HashMap<>();
```

构造一个空的 `HashMap`，<font color="red">初始化容量为 16，阈值为 16，默认加载因子 0.75f</font>

```java
Map<String, String> map = new HashMap<>(16);
// 在给定容量的构造函数中，阈值的初始化
this.threshold = tableSizeFor(initialCapacity);
//下一次改变大小的 阈值 16，给定 cap 值最近的 2 的次方值，不需要 (capacity * load factor) 计算
```

构造一个空的 `HashMap`，<font color="red">初始化容量为 自定义，默认加载因子 0.75f</font>，初始容量为给定容量相邻的 2 的次方

```java
/* Returns a power of two size for the given target capacity. */
static final int tableSizeFor(int cap) {
    int n = cap - 1;
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16; // 前面为 cap 的最大值 - 1 所占前位填充为 1
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```

> `HashMap` 最大容量为 1073741824 (1 << 30)
> `loadFactor <= 0 || Float.isNaN(loadFactor)` 加载因子校验
>
> `>>>`  表示不带符号向右移动二进制数，移动后前面统统补 0；`>>` 表示带符号移动
> 没有 `<<<` 这种运算符，因为左移都是补零，没有正负数的区别。

打印二进制

```java
static void printBinary(int n) {
    for (int i = 1; i <= 32; i++) {
        System.out.print((n >>> (32 - i)) & 1);
        if (i % 4 == 0) { System.out.print(' '); }
    }
    System.out.println();
}
```

`threshold` 阈值，下一个改变大小的值 `(capacity * load factor)`

#### 2. HashMap 类层级结构

`HashMap`  继承自 `AbstractMap` 同时实现了 `Map` 接口，`AbstractMap` 实现了 `Map` 接口

#### 3. HashMap put 存放值解析

把指定的 `value` 和 `key`  存到 `map` 当中，当前面 `map` 当中 `key` 存在，它的旧值会被替换。

##### 3.1 hash key 值

hashCode 是 int 类型，把高 16 位和低 16 位异或

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

`HashMap` 使用 `Node` 保存值，`Node` 实现了 `Map.Entry` 接口。
若是节点 hash 碰撞，产业树节点 `TreeNode` 继承 `LinkedHashMap.Entry`

##### 3.2 put

**resize**

当 `HashMap` 实例第一次 `put` 值时，此时 `table` 为 `null` 会进行第一次 `resize` 调用。
`oldCap` 大于零时还大于最大容量，此时阈值 `threshold` 为 `Integer.MAX_VALUE`。
新的容量 `newCap` 为 `oldCap` 两倍 `oldCap << 1`，默认初始化容量为 16 (`1 << 4`)，新的阈值也为老的阈值两倍 `oldThr << 1`。
<font color="red">注意：</font>初始化时当定义了初始化阈值，新的容量就为当前阈值 `newCap = oldThr`，没有定义阈值时，初始化容量为默认容量 `16`，初始化阈值就为 初始化容量乘初始化默认加载因子 (`DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY`) = `16 * 0.75f` = 12。

把就 table 的值放到扩容后的新 table。

```java
// e.next == null , 没有子节点
newTab[e.hash & (newCap - 1)] = e;
```

<font color="blue">注意：</font>当出现 hash 碰撞时，相同 hash key 的 value 数量大于 `TREEIFY_THRESHOLD = 8` 时，会由链表转为红黑树。