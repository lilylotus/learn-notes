# 排序

排序算法可以分为两类：

- 原地排序算法：除了函数调用所需要的栈和固定数目的实例变量外无需额外的内存
- 其它排序算法：需要额外的内存空间来存储另外一份数组副本

## 初级排序算法

### 选择排序

算法的时间效率取决于比较次数。

特点：

- 运行时间和输入无关。为了找出最小的元素而扫描一遍数组并不能为下一次扫描提供什么信息，改性质在某些情况是缺点。（一个有序的数组或主键全部一样的数组和一个元素随机排列的数组排序时间一样长）
- 数据移动是最少的。用了 N 次交换，交换次数和数组的大小是线性关系。其它算法都不具备这个特性。

```java
public static void sort(int[] a) {
    int len = a.length;
    for (int i = 0; i < len; i++) {
        int min = i;
        for (int j = i + 1; j < len; j++) {
            if (SortUtil.less(a[j], a[min])) {
                min = j;
            }
        }
        if (min != i) {
            SortUtil.exch(a, i, min);
        }
    }
}
```

### 插入排序

与选择排序不同的是，插入排序所需的时间取决于输入中元素的初始顺序。

适用场景：

- 数组中每个元素距离它最终位置都不远
- 一个有序的大数组接一个小数组
- 数组中只有几个元素位置不正确

当倒置的数量很少时，插入排序可能比大多数算法都快。对于大规模乱序数组插入排序很慢，因为它只会交换相邻的元素。

```java
public static void sort(int[] a) {
    int len = a.length;
    /*int index;
        for (int i = 1; i < len; i++) {
            int tmp = a[i];
            index = i - 1;
            while (index >= 0 && tmp < a[index]) {
                a[index + 1] = a[index];
                index--;
            }
            a[index + 1] = tmp;
        }*/

    for (int i = 1; i < len; i++) {
        for (int j = i; j > 0 && SortUtil.less(a[j], a[j - 1]); j--) {
            SortUtil.exch(a, j, j - 1);
        }
    }
}
```

### 希尔排序

为了简单的加速插入排序。

希尔排序的思想是为了使数组中任意相隔 h 的元素都是有序的，称为 h 有序数组。

希尔排序更高效的原因是它权衡了子数组的规模和有序性。

```java
public static void sort(int[] arr) {
    int j;
    for (int gap = arr.length / 2; gap >  0; gap /= 2) {
        for (int i = gap; i < arr.length; i++) {
            int tmp = arr[i];
            for (j = i; j >= gap && SortUtil.less(tmp, arr[j - gap]); j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = tmp;
        }
    }
}
```

### 归并排序

自底向上的归并排序比较适合链表组织的数据。

```java
public static void sort(int[] a) {
    sort(a, 0, a.length - 1);
}

public static void sort1(int[] a) {
    // 自底向上的归并排序方式
    int len = a.length;
    for (int sz = 1; sz < len; sz = sz + sz) {
        for (int lo = 0; lo < len - sz; lo += sz + sz) {
            merge(a, lo, lo + sz - 1, Math.min(lo + sz + sz - 1, len - 1));
        }
    }
}

private static void sort(int[] array, int low, int high) {
    if (high <= low) {
        return;
    }
    int m = low + (high - low) / 2;
    sort(array, low, m);
    sort(array, m + 1, high);
    merge1(array, low, m, high);
}

private static void merge(int[] array, int low, int mid, int high) {
    // 将 a[low ... mid] 和 a[mid + 1 ... high] 归并
    int left = low;
    int m = mid + 1;

    int[] aux = new int[array.length];
    System.arraycopy(array, 0, aux, 0, array.length);

    for (int k = low; k <= high; k++) {
        if (left > mid) array[k] = aux[m++];
        else if (m > high) array[k] = aux[left++];
        else if (SortUtil.less(aux[m], aux[left])) array[k] = aux[m++];
        else array[k] = aux[left++];
    }
}

private static void merge1(int[] array, int low, int mid, int high) {
    int left = low;
    int m = mid + 1;
    int index = left;

    int[] aux = new int[array.length];
    System.arraycopy(array, 0, aux, 0, array.length);

    while (left <= mid && m <= high) {
        if (SortUtil.less(aux[left], aux[m])) {
            array[index++] = aux[left++];
        } else {
            array[index++] = aux[m++];
        }
    }
    while (left <= mid) {
        array[index++] = aux[left++];
    }
    while (m <= high) {
        array[index++] = aux[m++];
    }

}
```

### 快速排序

```java
public static void sort(int[] a) {
    // sort(a, 0, a.length - 1);
    // sort2(a, 0, a.length - 1);
    sort3way(a, 0, a.length - 1);
}

private static void sort(int[] array, int lo, int hi) {
    if (hi <= lo) {
        return;
    }
    int index = partition1(array, lo, hi);
    sort(array, lo, index - 1);
    sort(array, index + 1, hi);
}

private static void sort2(int[] array, int lo, int hi) {
    if (hi <= lo) {
        return;
    }
    int index = partition2(array, lo, hi);
    sort2(array, lo, index - 1);
    sort2(array, index, hi);
}

private static void sort3way(int[] array, int lo, int hi) {
    if (hi <= lo) {
        return;
    }
    quick3way(array, lo, hi);
}


public static void quick3way(int[] array, int lo, int hi) {
    if (hi <= lo) {
        return;
    }
    int lt = lo;
    int i = lo + 1;
    int gt = hi;
    int v = array[lo];

    while (i <= gt) {
        if (array[i] < v) {
            SortUtil.exch(array, lt++, i++);
        } else if (array[i] > v) {
            SortUtil.exch(array, i, gt--);
        } else {
            i++;
        }
    }

    quick3way(array, lo, lt - 1);
    quick3way(array, gt + 1, hi);

}

private static int partition(int[] array, int lo, int hi) {
    int lIndex = lo;
    int rIndex = hi + 1;
    int v = array[lo];

    while (true) {
        while (SortUtil.less(array[++lIndex], v)) {
            if (lIndex == hi) {
                break;
            }
        }
        while (SortUtil.less(v, array[--rIndex])) {
            if (rIndex == lo) {
                break;
            }
        }
        if (lIndex >= rIndex) {
            break;
        }
        SortUtil.exch(array, rIndex, lIndex);
    }

    SortUtil.exch(array, lo, rIndex);
    return rIndex;
}

private static int partition1(int[] array, int lo, int hi) {
    int lIndex = lo;
    int rIndex = hi;
    int tmp = array[lo];

    while (lIndex < rIndex) {
        while (lIndex < rIndex && array[rIndex] >= tmp) {
            rIndex--;
        }
        array[lIndex] = array[rIndex];
        while (lIndex < rIndex && array[lIndex] <= tmp) {
            lIndex++;
        }
        array[rIndex] = array[lIndex];
    }

    array[lIndex] = tmp;

    return lIndex;
}

private static int partition2(int[] array, int lo, int hi) {
    int mid = (hi + lo) / 2;
    int lIndex = lo;
    int rIndex = hi;
    int v = array[mid];

    while (lIndex <= rIndex) {
        while (lIndex <= rIndex && SortUtil.less(array[lIndex], v)) {
            lIndex++;
        }
        while (lIndex <= rIndex && SortUtil.less(v, array[rIndex])) {
            rIndex--;
        }
        if (lIndex <= rIndex) {
            SortUtil.exch(array, lIndex++, rIndex--);
        }
    }

    return lIndex;
}
```

### 堆排序

能在已知的算法中唯一能够同时最优地利用空间和时间的算法，在最坏的情况下也能保证使用 2NlogN 次比较和恒定的额外空间。

```java
public static void sort(int[] arr) {
    //创建堆
    for (int i = (arr.length - 1) / 2; i >= 0; i--) {
        //从第一个非叶子结点从下至上，从右至左调整结构
        adjustHeap(arr, i, arr.length);
    }

    //调整堆结构+交换堆顶元素与末尾元素
    for (int i = arr.length - 1; i > 0; i--) {
        //将堆顶元素与末尾元素进行交换
        int temp = arr[i];
        arr[i] = arr[0];
        arr[0] = temp;

        //重新对堆进行调整
        adjustHeap(arr, 0, i);
    }
}

/**
     * 调整堆
     *
     * @param arr    待排序列
     * @param parent 父节点
     * @param length 待排序列尾元素索引
     */
private static void adjustHeap(int[] arr, int parent, int length) {
    //将temp作为父节点
    int temp = arr[parent];
    //左孩子
    int lChild = 2 * parent + 1;

    while (lChild < length) {
        //右孩子
        int rChild = lChild + 1;
        // 如果有右孩子结点，并且右孩子结点的值大于左孩子结点，则选取右孩子结点
        if (rChild < length && arr[lChild] < arr[rChild]) {
            lChild++;
        }

        // 如果父结点的值已经大于孩子结点的值，则直接结束
        if (temp >= arr[lChild]) {
            break;
        }

        // 把孩子结点的值赋给父结点
        arr[parent] = arr[lChild];

        //选取孩子结点的左孩子结点,继续向下筛选
        parent = lChild;
        lChild = 2 * lChild + 1;
    }
    arr[parent] = temp;
}
```

```java
/**
     * Rearranges the array in ascending order, using the natural order.
     *
     * @param pq the array to be sorted
     */
public static void sort(int[] pq) {
    int n = pq.length;

    // heapify phase
    for (int k = n / 2; k >= 1; k--)
        sink(pq, k, n);

    // sortdown phase
    int k = n;
    while (k > 1) {
        exch(pq, 1, k--);
        sink(pq, 1, k);
    }
}

/***************************************************************************
     * Helper functions to restore the heap invariant.
     ***************************************************************************/

private static void sink(int[] pq, int k, int n) {
    while (2 * k <= n) {
        int j = 2 * k;
        if (j < n && less(pq, j, j + 1)) j++;
        if (!less(pq, k, j)) break;
        exch(pq, k, j);
        k = j;
    }
}

/***************************************************************************
     * Helper functions for comparisons and swaps.
     * Indices are "off-by-one" to support 1-based indexing.
     ***************************************************************************/
private static boolean less(int[] pq, int i, int j) {
    return pq[i - 1] < pq[j - 1];
}

private static void exch(int[] pq, int i, int j) {
    int swap = pq[i - 1];
    pq[i - 1] = pq[j - 1];
    pq[j - 1] = swap;
}
```

