package cn.nihility.jvm;

/**
 * @author yzx
 * @date 2019-10-10 13:57
 */
public class HandlePromotionFailure {

    private final static int _1MB = 1024 * 1024;

    /**
     * -Pmainclass=cn.nihility.jvm.HandlePromotionFailure
     * VM 参数： -Xmn 新生代大小
     *      -Xms20M -Xmx20M -Xmn10M
     *      -XX:+PrintGCDetails
     *      -XX:SurvivorRatio=8
     *      -XX:+UseSerialGC
     *      -XX:-HandlePromotionFailure
     *
     * 当我们使用 Server 模式下的 ParallelGC 收集器组合（Parallel Scavenge+Serial Old 的组合）下，
     * 担保机制的实现和之前的 Client 模式下（SerialGC收集器组合）有所变化。
     * 在GC前还会进行一次判断，如果要分配的内存 >=Eden 区大小的一半，那么会直接把要分配的内存放入老年代中。
     * 否则才会进入担保机制。
     *
     */
    public static void testHandlePromotion() {
        byte[] allocation1, allocation2, allocation3, allocation4;

        allocation1 = new byte[2 * _1MB];
        allocation2 = new byte[2 * _1MB];
        allocation3 = new byte[2 * _1MB];
        allocation4 = new byte[3 * _1MB];
    }

    public static void main(String[] args) {
        testHandlePromotion();
    }

}
