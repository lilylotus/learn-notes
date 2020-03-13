#### Stream 源码分析

`java.util.stream.Stream`  `java.util.stream.BaseStream`  `java.lang.AutoCloseable`

`java.util.Spliterator` `java.util.Spliterators`



**管道操作**

`java.util.stream.ReferencePipeline`
`java.util.stream.AbstractPipeline`



joda-collect 时间操作

---

#### Stream 分析

```java
public void test(Consumer<Integer> consumer) {
	consumer.accept(100);
}

Consumer<Integer> consumer = i -> System.out.println(i);
IntConsumer intConsumer = i -> System.out.println(i);

stream.test(consumer); // 面向对象方式，传递的实例
// stream.test(intConsumer); // 报错

stream.test(consumer::accept); // 函数式方式， 传递的行为
stream.test(intConsumer::accept); // 函数式方式
```



**java.util.stream.StreamSupport**

```java
list.stream().forEach(System.out::println);
--> java.util.stream.ReferencePipeline.Head#forEach
--> 直接操作源的管道有优化
    
list.stream().map(item -> item).forEach(System.out::println);   
--> java.util.stream.ReferencePipeline#forEach
    
-> java.util.stream.AbstractPipeline#copyInto
if (!StreamOpFlag.SHORT_CIRCUIT.isKnown(getStreamAndOpFlags())) {
    wrappedSink.begin(spliterator.getExactSizeIfKnown());
    spliterator.forEachRemaining(wrappedSink);
    wrappedSink.end();
}

-> java.util.stream.ReferencePipeline#map
-> java.util.stream.ReferencePipeline.StatelessOp
-> java.util.stream.Sink.ChainedReference#ChainedReference
-> java.util.stream.AbstractPipeline#opWrapSink
    
    return new StatelessOp<P_OUT, R>(this, StreamShape.REFERENCE,
                                     StreamOpFlag.NOT_SORTED | StreamOpFlag.NOT_DISTINCT) {
    @Override
    Sink<P_OUT> opWrapSink(int flags, Sink<R> sink) {
        return new Sink.ChainedReference<P_OUT, R>(sink) {
            @Override
            public void accept(P_OUT u) {
                downstream.accept(mapper.apply(u));
            }
        };
    }
};

--> Sink begin -> accept -> end

java.util.stream.TerminalOp
```



`Arrays.asList("hello", "world", "welcome");` 返回的 list 是 **java.util.Arrays.ArrayList**  的 Arraylist
而不是 **java.util.ArrayList** 注意其中的区别

**java.util.Arrays$ArrayList**

**java.util.stream.StreamOpFlag**
**java.util.stream.Sink**

