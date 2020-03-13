**Lambda expression** may refer to:

- Lambda expression in computer programming, also called an [anonymous function](https://en.wikipedia.org/wiki/Anonymous_function), is a defined function not bound to an identifier.
- [Lambda expression in lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus#Definition), a formal system in mathematical logic and computer science for expressing computation by way of variable binding and substitution.

###### Stream 终端操作

```java
toArray();
toArray(IntFunction<A[]> generator);

reducereduce(U identity, 
             BiFunction<U, ? super T, U> accumulator,
             BinaryOperator<U> combiner);
reduce(T identity, BinaryOperator<T> accumulator);
reduce(BinaryOperator<T> accumulator);

min(Comparator<? super T> comparator);
max(Comparator<? super T> comparator);

forEach(Consumer<? super T> action);

count();
```





#### Lambda 表达式

1. 函数式接口

   ```
   Conceptually, a functional interface has exactly one abstract method
   
   Note that instances of functional interfaces can be created with lambda expressions, method references, or constructor references.
   ```
   
   - 如果一个接口只有一个抽象方法，那么该接口就是一个函数式接口
   - 如果我们在某个接口上声明了 **FunctionalInterFace** 注解，那么编译器会按照函数式接口的定义来要求该接口
   - 如果某个接口仅有一个抽象方法，但我们没有为该接口声明 **FunctionalInterface** ，那么编译器依旧会把该接口当做函数式接口

Consumer 函数式接口：接受一个参数，不返回任何结果

```
@FunctionalInterface
public interface Consumer<T> {


list.forEach( i -> System.out.println(i) ); # 这里有类型推断
list.forEach( (Integer i) -> System.out.println(i) );

list.forEach(System.out::println); # 通过方法引用类创建一个函数式接口 [method reference]
```



#### Lambda 表达式的作用

- Lambda 表达式为 Java 添加了缺失的函数式编程特性，使我们能将函数当做一等公民看待
- 在将函数作为一等公民的语言中， Lambda 表达式的类型是函数， **但在 Java 中， Lambda 表达式是对象**， 它依附于一类特定的对象类型 (函数式接口 Functional Interface)

1. lambda 传递的是行为而不仅为值
2. 提升抽象层次
3. API 重用性更好
4. 更加灵活

```
/**
 * 函数式接口可以通过三种方式实现
 * 1. Lambda 表达式
 * 2. 方法引用
 * 3. 构造方法引用
 */
 
 MyInterface31 i31 = () -> {}; 
 () -> {} 必须要通过上下文的信息来处理， lambda 仅关系方法的参数和返回，对于方法名称不关心
```

```java
String::toUpperCase -> 这是实例方法引用，此方法的第一个输入一定是存在本调用实例
lambda 调用传入的一个参数一定是此被调用对象的实例
```

#### 流式 stream() , parallelStream() 并行

和 linux Pipline 类似

```java
// 流方式 stream(),  parallelStream() 并行
System.out.println("============ lambda implement ==============");
list.stream().map( item -> item.toUpperCase() ).forEach( item -> System.out.println(item) );

System.out.println("========== method reference =============");
list.stream().map( String::toUpperCase ).forEach( System.out::println );


Collections.sort( nameList,  (o1, o2) -> o2.compareTo(o1) );
Collections.sort( nameList, Comparator.reverseOrder() );
```



#### java.util.function.Function 函数式接口 （一个输入一个输出）

```java
    public int computeAndThen(int a, Function<Integer, Integer> function1, Function<Integer, Integer> function2) {
        return function1.andThen(function2).apply(a);
    }
test.computeAndThen(10, v -> v * 3, v -> v * v);
    
andThen (先执行函数本身在执行函数参数) | compose (先执行参数函数在执行本身函数)
```



传递行为的操作 compute(int a, Function<Integer, Integer> function) function) ; function 就是一个 lambda

> 在以前行为(方法)是固定写好的，现在使用了 Function 后可以在方法中传递行为，更加的灵活了。
> 现在仅需要定义好要操作的方法，具体的操作方式可以在使用的时候在定义

#### **java.util.function.BiFunction** (两个输入返回一个输出)

```java
public int computeBiFunction(int a, int b, BiFunction<Integer, Integer, Integer> biFunction) {return biFunction.apply(a, b);}

System.out.println(test.computeBiFunction(10, 10, (value1, value2) -> value1 / value2));
```

#### java.util.function.Predicate (判断测试条件返回结果 true|false )

```java
Predicate<String> predicate = p -> p.length() > 3;
Predicate<String> predicate1 = p -> p.length() < 5;

System.out.println(predicate.test("Hello")); --> true

System.out.println(predicate.or(predicate1).test("Hello"));
System.out.println(predicate.and(predicate1).test("Hell"));
```

#### java.util.function.Supplier (不接收参数同时返回一个结果)

```java
很多的工厂都是不接受参数直接返回结果的。
Supplier<FunctionPerson> supplier1 = () -> new FunctionPerson("Supplier", 20);
System.out.println(supplier1.get());

// 构造方法引用
Supplier<FunctionPerson> supplier2 = FunctionPerson::new;
System.out.println(supplier2.get()); 
// 注意： 要求对象必须有默认的构造函数方法
```



**高阶函数：**如果函数接受一个函数作为一个参数或返回一个函数作为返回值

#### Java Lambda  结构

- 当只有一个参数且类型可以推导时，圆括号可以省略掉。如： item -> item * 2
- Lambda 表达式主题可以包含零条或多条语句
- 如果 Lambda 表达式的主体只有一条语句，花括号可以省略，匿名函数的返回类型与该主体表达式一致
- 如果 Lambda 表达式主体包含一条以上的语句，则表达式必须包含在花括号内，匿名函数的返回类型与代码块的返回类型一致，若没有返回则为空



#### java.util.function 是 jdk8 新加的 Function 包

- java.util.function.BinaryOperator （两个输入和输出结果的类型一致）
  public interface BinaryOperator<T> extends BiFunction<T,T,T>

  ```java
  public String getShort(String a, String b, Comparator<String> comparator) { 
      return BinaryOperator.minBy(comparator).apply(a, b);
  }
  
  System.out.println(test.getShort("Hello", "wc", Comparator.comparingInt(String::length))); -> wc
  
  System.out.println(test.getShort("Hello", "wc", Comparator.comparingInt(a -> a.charAt(0)))); --> Hello
  ```

  **注意：** Lambda 的方法引用为静态方法引用



#### 空指针异常 optional

**java.util.Optional**

```java
Optional<String> optional = Optional.of("hello");
// 要先调用 isPresent() 在调用 get(), 不可直接调用 get()
// 不推荐 (1) if (optional.isPresent()) { System.out.println(optional.get()); }
// 推荐使用函数式的方式使用, ifPresent 当值存在的时候才调用此函数
optional.ifPresent(item -> System.out.println(item));
// 推荐使用方法引用来调用
optional.ifPresent(System.out::println);

注意： optional 推荐使用函数式的方式使用，不推荐平常的方式使用 (1)
    Optional.ofNullable("Hello"); 当方法返回值不确定是不是为空的时候，使用 ofNullable 在操作

// 推荐的空值返回处理操作
Optional<Company> op = Optional.ofNullable(company);
return op.map(theCompany -> theCompany.getEmployee()).orElse(Collections.emptyList());
```

**推荐：** 注意当返回一个集合的时候，返回值不能返回 null， 当没有数据的时候也要返回一个空的集合

**注意：**Optional 不要作为类的成员变量和方法参数，可以作为返回值规避空指针异常



---

#### 方法引用 (method reference)

方法引用实际上是 Lambda 的一种语法糖
我们可以把方法引用看作是一个 [函数指针]， function pointer
方法引用分为四类：

1. 类名::**静态方法名**

   ```java
   public static int compareByAge(Student s1, Student s2) {
       return s1.getAge() - s2.getAge(); 
   }
   1. list.sort((t1, t2) -> t1.getAge() - t2.getAge());
   2. list.sort(Student::compareByAge);
   1 和 2 的方法完全一致，2 是一种 Lambda 方法糖
       className::staticMethod -> 类似方法指针
       className.staticMetehod -> 类的方法调用
   ```

2. 引用名(对象名)::实例方法名

   ```java
   public int compareByAge(Student s1, Student s2) {
   	return s1.getAge() - s2.getAge();
   }
   Student.StudentComparator comparator = new Student.StudentComparator();
   list.sort(comparator::compareByAge);
   ```

3. 类名::实例方法名

   ```java
   public int compareWithAge(Student s) {
       return getAge() - s.getAge();
   }
   
   list.sort(Student::compareWithAge);
   这里的调用者是 sort 中 lambda 方法的第一个参数，所以上面的比较就可以仅用一个参数就好
   
   List<String> cities = Arrays.asList("chongqing", "beijing", "shanghai", "qingdao");
   Collections.sort(cities, String::compareTo);
   cities.forEach(System.out::println);
   ```

4. 构造方法引用: 类名::new

   ```java
   public String getString(Supplier<String> supplier) {
   	return supplier.get() + " test";
   }
   System.out.println(demo.getString(String::new)); --> test
   
   public String getString2(String str, Function<String, String> function) {
   	return function.apply(str);
   }
   System.out.println(demo.getString2("hello", String::new)); --> hello
   ```

   

---

#### 默认方法

接口抽象方法前要带上 default 关键字

1. 同时实现多个接口是有相同的默认实现的方法时要重写方法

   ```java
   @Override
   public void myMethod() {
       System.out.println("Override myMethod");
       DefaultInterface02.super.myMethod(); // 仅使用特定接口的重复方法
   }
   ```

2. 如果一个类继承了一个接口的和实现一个接口，现在要使用的共同方法是
   **结果是** 取实现类中的共同方法， 原因是 java 认为实现类的优先级高于接口的默认方法，契约

**为什么接口有默认的方法**
引入默认方法是为了向后兼容，

---

#### 流操作 java.util.stream.Stream (接口) [支持并行操作]

**流由 3 部分构成：**

1. 源
2. 零个或多个中间操作
3. 终止操作

**流操作分类**

1. 惰性求值
2. 及早求值
   

stream 的创建

```java
// 创建方式 1
Stream stream = Stream.of("hello", "one", "two", "three");

// 创建方式 2
String[] array = new String[] {"hello", "one", "two", "three"};
Stream stream1 = Stream.of(array);
Stream stream2 = Arrays.stream(array); // 和上一种是一样的

// 创建方式 3
List<String> list = Arrays.asList("hello", "one", "two", "three");
Stream<String> stream3 = list.stream();

IntStream.of(5, 6, 7).forEach(System.out::println); --> 5,6,7
IntStream.range(1, 3).forEach(System.out::println); --> 1,2
IntStream.rangeClosed(1, 3).forEach(System.out::println); --> 1,2,3

IntStream.range(1, 3).map(v -> 2 * v).reduce(0, Integer::sum); -> 6
// reduce 求和操作
```



Lambda 表达式和 Stream 和普通的操作有什么根本的区别。
**函数式编程操作的是行为，用特定的行为来操作数据**



- Collection 提供了新的 stream() 方法
- 流不存储值，通过管道方式获取值
- 本质是函数式的，对流的操作会生成一个结果，不过并不会修改底层的数据源，集合可以作为底层数据源
- 延迟查找、(过滤、映射、排序)等都可以延迟实现

```java
Stream<String> stream = Stream.of("one", "two", "three", "four", "five");

// stream 转换为 array
String[] stringArray = stream.toArray(v -> new String[v]);
Arrays.asList(stringArray).forEach(System.out::println);

String[] stringArray = stream.toArray(String[]::new);

// stream 转换为 list
List<String> list = stream.collect(Collectors.toList());
list.forEach(System.out::println);

// 原始的 stream 转 list
List<String> list = stream.collect(() -> new ArrayList<String>(),
                (theList, item) -> theList.add(item),
                (theList, theList1) -> theList.addAll(theList1));

List<String> list = stream.collect(ArrayList::new, ArrayList::add, ArrayList::addAll);

stringStream.collect(StringBuilder::new, // 创建一个返回的容器
                     StringBuilder::append, // 每次把元素添加的一个新的 容器 中
                     StringBuilder::append // 把每次添加好元素的容器合并在 第一个创建的容器中
                    ).toString();

stream.collect(Collectors.toList()); // 这种方式最简单，但是不能定制集合容器类型
// 用这种方式去自定义集合容器类型
stream.collect(Collectors.toCollection(ArrayList::new));
stream.collect(Collectors.toCollection(LinkedList::new));

stream.collect(LinkedList::new, LinkedList::add, LinkedList::addAll); // 自定义集合容器类型

// 转化为 set 类型
Set<String> set = stream.collect(Collectors.toCollection(TreeSet::new));
set.forEach(System.out::println);

// 返回拼接的字符串 joining
stream.collect(Collectors.joining());   --> onetwothree
stream.collect(Collectors.joining("-")); --> one-two-three
    
============================================================
// 多个流内元素合并
Stream<List<Integer>> stream = Stream.of(Arrays.asList(1, 2, 34), Arrays.asList(3, 3, 1), Arrays.asList(23, 12, 4));
stream.flatMap(theList -> theList.stream()) // 把多有流元素取出合并为一个流
                .map(item -> item * item) // 每个元素取出后平方
                .forEach(System.out::println);

Stream<String> stream = Stream.generate(UUID.randomUUID()::toString);
stream.findFirst().ifPresent(System.out::println); // 符合 optional 的使用方式，为空就不输出

===============================================================
Stream.iterator 一般会加 limit 限制流的长度
Stream.iterate(1, item -> item+2).limit(6).forEach(System.out::println); --> 1,3,5,7,9,11
```



```
Optional<Integer> reduce = list.stream().filter(item -> item > 2)
                .map(item -> 2 * item).skip(2).limit(2).reduce(Integer::sum);
reduce.ifPresent(System.out::println);
        
mapToInt, mapToLong, mapToDouble 使用具体的 Stream 防止自动装箱和拆箱的性能损耗

int sum = list.stream().filter(item -> item > 2)
                .mapToInt(item -> item * 2).skip(2).limit(2).sum();

```

**注意：同一个流关闭了或者操作过了就不能在使用了**
**流 Stream 在没有遇到终止操作时所有的中间操作都不会操作**
**操作流的时候因该注意操作顺序和方法，防止出现无限流**
**流并不是按照书写的顺序执行的**
**流中存在短路运算操作， 只要满足了最后的终止操作后所有的剩余中间操作都可以不用做了**

```java
List<String> list = Arrays.asList("hello", "world", "hello world");
list.stream().mapToInt(item -> {
    int len = item.length();
    System.out.println(item);
    return len;
}).filter(len -> len == 5).findFirst().ifPresent(System.out::println);

-->
hello
5

```



```java
List<String> list1 = Arrays.asList("hello welcome", "world hello", "hello world", "hello welcome");
list1.stream().flatMap( item -> Arrays.asList(item.split(" ")).stream())
                .distinct().forEach(System.out::println);
-->
hello
welcome
world

=========================================
list1.stream().map(item -> item.split(" ")) -> Stream<String[]>
                .flatMap(Arrays::stream) -> Stream<T> stream(T[] array) -> Stream<String>
                .distinct().forEach(System.out::println);

============================================
List<String> list2 = Arrays.asList("Hei", "Hello", "你好");
List<String> list3 = Arrays.asList("zhangsan", "lishi", "wangwu", "liliu");
list2.stream()
    .flatMap(item -> list3.stream().map(item2 -> item + " " + item2))
    .forEach(System.out::println);
-->
Hei zhangsan
Hei lishi
Hei wangwu
Hei liliu
```



#### Stream 分组 -- **Collectors.groupingBy**

```java
Map<String, List<Student>> collect = list.stream().collect(Collectors.groupingBy(Student::getName));

Map<Integer, List<Student>> collect1 = list.stream().collect(Collectors.groupingBy(Student::getScore));
// 注意：统计的是什么类型，返回的 map key 就是什么类型

// 统计同一 score 下的学生人数  Collectors.counting()
Map<Integer, Long> collect2 = list.stream().collect(Collectors.groupingBy(Student::getScore, Collectors.counting()));

// 统计同意 score 下学生的平均年龄
Map<Integer, Double> collect3 = list.stream().collect(Collectors.groupingBy(Student::getScore, Collectors.averagingDouble(Student::getAge)));
```

#### Stream 分区 -- **Collectors.partitioningBy**

```java
注意：分区仅有两个，要么为 true 要么为 false
    
Map<Boolean, List<Student>> collect4 = 
    list.stream().collect(Collectors.partitioningBy(s -> s.getScore() >= 80));

```



---

jdk8 中及其重要的方法，Stream 中的流 collect 操作
`java.util.stream.Stream#collect(java.util.stream.Collector<? super T,A,R>)`
`<R, A> R collect(Collector<? super T, A, R> collector);`

**优先使用具体的 stream 流操作 (IntStream, DoubleStream)，避免不必要的装箱和拆箱造成的性能影响**



**特别特别重要的组件**
**java.util.stream.Collector  -- Collector<T, A, R>** **重要接口**
<T, A, R> -> 重要的参数类型



---

#### 比较器 -- java.util.Comparator

**java.util.Collections** 集合工具类

```java
List<String> list = Arrays.asList("nihao", "hello", "world", "welcome");

Collections.sort(list, (item1, item2) -> item2.length() - item1.length());

// 使用比较器比较
Collections.sort(list, Comparator.comparingInt(String::length).reversed());

Collections.sort(list, 
                 Comparator.comparingInt((String item) -> item.length()).reversed());

// thenComparing 在遇到有相同的比值时在按照另一条件比较
Collections.sort(list,Comparator.comparingInt(String::length)
                 .thenComparing(String.CASE_INSENSITIVE_ORDER));

Collections.sort(list, 
                 Comparator.comparingInt((String::length))
                 .thenComparing((item1, item2) -> 
                                item1.toLowerCase().compareTo(item2.toLowerCase())));
```



`comparingInt(ToIntFunction<? super T> keyExtractor)`  
注意在添加比较器的时候有可能自动类型推导不出 **<? super T>** 原因是比较器参数为向上取



---

#### 自定义 Collector -- **java.util.stream.Collector**

```java
Collector<T, Set<T>, Set<T>>
    1. T 所遍历的流中每个元素的类型
    2. Set<T> 中间结果容器的类型
    3. Set<T> 最终返回结果的类型
public class MyCollectors<T> implements Collector<T, Set<T>, Set<T>>
```

```java
public class MyCollectors<T> implements Collector<T, Set<T>, Set<T>> {
    // 提供一个空的容器，供 accumulator 后续方法调用的容器
    @Override
    public Supplier<Set<T>> supplier() {
        System.out.println("supplier invoked!");
        return HashSet::new;
    }
    // void accept(T t, U u); T 为中间的结果容器， U 流中遍历的下一个元素
    @Override
    public BiConsumer<Set<T>, T> accumulator() {
        System.out.println("accumulator invoked!");
        // return HashSet<T>::add; 错误，有可能 supplier 返回 TreeSet 而 HashSet 不能满足要求
        // return (set, item) -> set.add(item); 和下面写法等价
        return Set::add;
    }
    // 将并行流的多个中间结果合并起来
    @Override
    public BinaryOperator<Set<T>> combiner() {
        System.out.println("combiner invoked!");
        return (set1, set2) -> { set1.addAll(set2); return set1; };
    }

    // 将所有的结果合并到一起
    @Override
    public Function<Set<T>, Set<T>> finisher() {
        System.out.println("finisher invoked!");
        // return t -> t;
        return Function.identity();
    }
    // 表示当前收集器诸多不可变的特性集合
    @Override
    public Set<Characteristics> characteristics() {
        System.out.println("characteristics invoked!");
        return Collections.unmodifiableSet(EnumSet.of(Characteristics.IDENTITY_FINISH, Characteristics.UNORDERED));
    }
    public static void main(String[] args) {

        List<String> list = Arrays.asList("hello", "world", "welcome");

        Set<String> collect = list.stream().collect(new MyCollectors<>());
        System.out.println(collect);
    }
}

--> finisher 并没有调用，因为中间结果容器的类型和返回结果的类型一致，实际上 finisher 不用编写，有 jdk 底层自动完成调用
    2. 由于设置的 characteristics 为 Characteristics.IDENTITY_FINISH 所以直接以中间容器结果返回，不在调用 finisher 了，注意：一定要中间结果要和输出结果的转换要成功，因为中间没有校验会抛出错误。
supplier invoked!
accumulator invoked!
combiner invoked!
characteristics invoked!
characteristics invoked!
[world, hello, welcome]
```



`java.util.stream.Stream#collect(java.util.stream.Collector<? super T,A,R>)` 具体由`java.util.stream.ReferencePipeline` 调用



**注意：** Collector 的 characteristics 特性不能随意的乱写，程序会按照定义好的特性来执行
**Characteristics.IDENTITY_FINISH** 异常，不会执行 finisher， Set<String> 不能直接转换为 Map<String, String>

**Characteristics.CONCURRENT** 表示多个线程操作同一个容器，并且 combiner 不会被调用
	`accumulator()` 不要在这里边迭代遍历元素，防止多线程写和读并发异常
**parallelStream** 这个表示多个线程操作各自的容器

`java.util.ConcurrentModificationException` 一个线程变更集合数据另一个线程遍历数据就有可能报出异常 **java.util.ConcurrentModificationException**

加上了 **CONCURRENT** 特性就只有一个中间容器存在，不加就会有多个中间容器存在
**注意：**有了多个容器的时候就会调用 combiner 在合成中间容器结果
	在并行情况下并且收集器本身没有 **CONCURRENT** 特性 **combiner** 才会被调用



```java
set.stream().parallel().sequential().parallel()
注意：这里的具体并行还是串行以最后一次设置并行或串行为准
--> sourceStage.parallel = false; 只是设置的是否并行的标志位
```



```
set.parallelStream() 在并行的时候 supplier() 会生成多个容器

 *     A a1 = supplier.get();
 *     accumulator.accept(a1, t1);
 *     accumulator.accept(a1, t2);
 *     R r1 = finisher.apply(a1);  // result without splitting
 *
 *     A a2 = supplier.get();
 *     accumulator.accept(a2, t1);
 *     A a3 = supplier.get();
 *     accumulator.accept(a3, t2);
 *     R r2 = finisher.apply(combiner.apply(a2, a3));  // result with splitting
 
```



---

对于 `java.util.stream.Collectors` (静态工厂) 来说，实现一般分为两种情况：

1. 通过 CollectorImpl 来实现
2. 通过 reducing 方法来实现， reducing 方法本身又是通过 CollectorImpl 来实现



```java
public static <T> Collector<T, ?, List<T>> toList() {
    return new CollectorImpl<>((Supplier<List<T>>) ArrayList::new, List::add,
                               (left, right) -> { left.addAll(right); return left; },
                               CH_ID);
}
```

```
public static <T> Collector<T, ?, Integer>
summingInt(ToIntFunction<? super T> mapper) {
    return new CollectorImpl<>(
            () -> new int[1],
            (a, t) -> { a[0] += mapper.applyAsInt(t); },
            (a, b) -> { a[0] += b[0]; return a; },
            a -> a[0], CH_NOID);
            
  采用数据 (new int[1]) 因为要有一个容器 (对象类型) 来保存和处理数据，
  不能直接用数值类型是因为数值类型式不可变了，无法作为容器传递
}
```



---

#### 分析 groupingby

