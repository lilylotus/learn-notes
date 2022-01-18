### C++ time

```c++
#include <iostream>
#include <ctime>
#include <chrono>

int main()
{
    auto start = std::chrono::system_clock::now();

    // 秒为单位的数值，以 1970 年 1 月 1 日 为基准
    time_t t1 = time(0);
    std::cout << "time(0) = " << t1 << std::endl;
    char* tChar = ctime(&t1);
    std::cout << "ctime() = " << tChar << std::endl;
    tm* local_struct =  localtime(&t1);
    std::cout << local_struct->tm_year + 1900 << "/" << local_struct->tm_mon + 1 << "/" << local_struct->tm_mday << " " 
        << local_struct->tm_hour << ":" << local_struct->tm_min << ":" << local_struct->tm_sec << std::endl;

    auto end = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    std::cout << "Duration count = " << duration.count() << std::endl;
    std::cout << (double)(duration.count()) * std::chrono::microseconds::period::num / std::chrono::microseconds::period::den  << "s" << std::endl;
    return 0;
}
```

> time(0) = 1642499735
>
> ctime() = Tue Jan 18 17:55:35 2022
>
> 2022/1/18 17:55:35
>
> Duration count = 1027
>
> 0.001027s 

##### 1. 访问限制

> C++ 的类访问限制，private|protected|public 的访问限制仅在编译的时候有效，在运行时没有管。
> C++ 的 OOP 只在源码级别存在，在运行的时候时不存在关系的

```c++
class A {
	private:
    	int i;
    	int *p;
    public:
    	A() { printf("A::A()"); p = 0; i = 0; }
		~A() { printf("A::~A()"); if (0 != p) { delete p; } }
		void g(A *q) { printf("A::g() q->i=%d, q=%p", q->i, q); }
    	void g(A q) { printf("A::g() q.i=%d", .i); }
}

int main(int argv, char *argc[]) {
    A a, b;
    a.g(&b); // 在运行的时候可以访问 A 的 private 私有成员。
}

----------
    
class friend {
    public:
    void f() { cout << "I'm class friend function f()" << end; }
}
void f() { cout << "I'm global friend function f()" << endl; }
class master {
    friend void friend::f();
    friend void f();
}
```

> C++ 推荐类使用初始化列表，尽量不要在构造函数初始化

```c++
class A {
    private:
    int a, b, c;
    public:
    A();
    A(int aa, int bb, int cc);
    ~A();
}
A::A() {}
A::A(int aa = 0, int bb = 0, int cc = 0): a(aa), b(bb), c(cc) {}
A::~A() {}
```

> C++ 友元函数或者友元类

```c++
class B;
class A {
    private:
    int i;
   	t
    friend void function(A aa);
    // friend void B::function(A aa);
    friend class B;
}
// 友元函数
void function(A aa) { cout << aa.i << endl; }
// 友元类函数
class B {
public:
    void function(A aa) { cout << aa.i << endl; }
}
```

> C++ 的默认值参数是写在声明里面的，不是写在实现里
> 默认值是在编译时存在的， **不推荐使用默认值参数，不符合设计要求，不安全**

```c++
// Hello.h
class Hello {
public:
    void test(int a, int b = 100);
}
// Hello.cpp
void Hello::test(int a, int b) { printf("a=%d, b=%d", a, b); }
```

> C++ 多态，会在有虚函数的类中维护一个 vtable 保存实现虚函数的指针

```c++
class A {
private:
    int i;
public:
    A() : i(20) {}
    virtual void print() { cout << "A::print i= " << i << endl; }
}
class B : public A {
private:
    int j;
public:
    B() : j(30) {}
    virtual void print() { cout << "B::print j= " << j << endl; }
}

A a; B b;
A *pa = &a;
B *pb = &b;

int *pai = (int*)pa;
int *pbi = (int*)pb;

*pai = *pbi;
pa->print(); // -> B:print j = 66666 ， j 的数据异常是因为 a 得到了 b 的虚拟地址表，但 a 没有 j

// 注意虚拟的地址表，有虚函数的类叫做虚类
```

> 拷贝构造函数
> 注意：函数传递的是 *值传递* 不是 *址传递*
> 还有就是 *赋值* 和 *声明初始化*

```c++
class A {
    A(const A& o) { cout++; cout << "A::A(const A& 0)" << endl; }
}

A fun(A a) { -> 这里有拷贝构造函数
    a.print();
    return a; -> 这里也有拷贝构造函数
}

// 赋值
A a, b;
a = b; // 赋值

// 声明初始化
A a;
A b(a); // 等同于 A b = a;
```

> 运算符重载
> 对象是 *成员的复制* 不是 *位的复制*

  // ERROR: c++ 产生的只是一个临时的中间值， 前置 ++ 的效率要高于后置 ++。

  // (c++)++ 编译错误

  // ++(c++) 编译错误

```c++
class SortContainer
{
private:
    int opCount;
public:
    SortContainer();
    SortContainer(const SortContainer& other); // Copy Constructor
    SortContainer& operator++();  // ++i，前置形式
    const SortContainer operator++(int);  // i++，后置形式
    SortContainer& operator--();
    const SortContainer operator--(int);
};

SortContainer::SortContainer(const SortContainer& other)
{
    this->opCount = other.opCount;
}
SortContainer& SortContainer::operator--()
{
    opCount -= 1;
    return *this;
}
const SortContainer SortContainer::operator--(int)
{
    SortContainer tmp = *this;
    --(*this);
    return tmp;
}
SortContainer& SortContainer::operator++()
{
    opCount += 1;
    return *this;
}
const SortContainer SortContainer::operator++(int)
{
    // ERROR: c++ 产生的只是一个临时的中间值， 前置 ++ 的效率要高于后置 ++。
    // (c++)++ 编译错误
    // ++(c++) 编译错误
    SortContainer tmp = *this; // Copy Constructor
    ++(*this);
    return tmp;
}
```



```c++
+ - * / % ^ & | ~
- const T operatorX(const T& i, const T& j) const;
! && || < <= == >= > 
- bool operatorX(const T& i, const T& j) const;
[]
- T& T::operator[](int index);

--------------------------
class Integer {
private:
    int i;
public:
    const Integer& operator++ (); // prefix++
    const Integer operator++(int); // postfix++
    const Integer& operator--(); // prefix--
    const Integer operator--(int); // postfix--
}

const Integer& Integer::opeator++() { // prefix++
    *this += 1;
    return *this;
}
const Integer Integer::operator++(int) { // postfix++
    Integer old( *this ); // fetch
    ++(*this);// increment
    return old;
}
----------------------------
== != < > <= >=
class Integer {
public:
    bool operator==( const Integer& rhs ) const ;
    bool operator!=( const Integer& rhs ) const ;
}

bool Integer::operator==( const Integer& rhs ) const {
    return i == rhs.i;
}

bool Integer::operator<( const Integer& rhs ) const {
    return i < rhs.i;
}

---------------------------------------------
class Integer {
private:
    int i;
public:
    Integer() : i(0) { cout << "Integer::Integer()" << endl; }
    Integer(int ii) : i(ii) { cout << "Integer::Integer(int) " << ii << endl; }
    ~Integer() { cout << "Integer::~Integer()" << endl; }
    void p() { cout << "i = " << i << endl; }

    const Integer operator+(const Integer& that) {
        cout << "operator + " << endl;
        Integer result(this->i + that.i);
        return result;
    }

    friend const Integer operator-(const Integer& p1, const Integer& p2);

    // prefix --
    const Integer& operator--() {
        cout << "prefix --" << endl;
        i -= 1;
        return *this;
    }
    // postfix --
    const Integer operator--(int) {
        cout << "post fix --" << endl;
        Integer old( *this );
        --( *this );
        return old;
    }

    bool operator==(const Integer& that) const {
        cout << "operator == " << endl;
        return i == that.i;
    }

    bool operator<(const Integer& that) const {
        cout << "operator < " << endl;
        return i < that.i;
    }
    bool operator<=(const Integer& that) const {
        cout << "operator <= " << endl;
        return *this < that || *this == that;
    }

};

const Integer operator-(const Integer& p1, const Integer& p2) {
    cout << "friend operator -" << endl;
    return Integer(p1.i - p2.i);
}

int main(int argc, char *argv[]) {

    Integer i;
    Integer ii = 40;
    Integer iii(50);

    cout << "-------------------------" << endl;
    i.p();
    ii.p();
    iii.p();

    cout << "-------------------------" << endl;

    Integer plus = ii + iii;
    plus.p();

    cout << "-------------------------" << endl;
    plus = plus - ii;
    plus.p();

    cout << "-------------------------" << endl;
    Integer fix = plus--; // plus = 50
    fix.p(); // i = 50
    plus.p(); // i = 49

    cout << "-------------------------" << endl;
    Integer fix1 = --plus; // plus = 49
    fix1.p(); // plus = 48
    plus.p(); // plus = 48

    cout << "-------------------------" << endl;
    Integer op1 = 100;
    Integer op2 = 200;

    bool r1 = op1 == op2;
    cout << " 100 == 200 -> " << r1 << endl;

    bool r2 = op1 < op2;
    cout << " 100 < 200 -> " << r2  << endl;

    bool r3 = op2 <= op1;
    cout << " 200 <= 100 -> " << r3 << endl;

    cout << "===========================" << endl;

    return 0;
}

-->
Integer::Integer()
Integer::Integer(int) 40
Integer::Integer(int) 50
-------------------------
i = 0
i = 40
i = 50
-------------------------
operator + 
Integer::Integer(int) 90
i = 90
-------------------------
friend operator -
Integer::Integer(int) 50
Integer::~Integer()
i = 50
-------------------------
post fix --
prefix --
i = 50
i = 49
-------------------------
prefix --
i = 48
i = 48
-------------------------
Integer::Integer(int) 100
Integer::Integer(int) 200
operator == 
 100 == 200 -> 0
operator < 
 100 < 200 -> 1
operator <= 
operator < 
operator == 
 200 <= 100 -> 0
===========================
Integer::~Integer()
Integer::~Integer()
Integer::~Integer()
Integer::~Integer()
Integer::~Integer()
Integer::~Integer()
Integer::~Integer()
Integer::~Integer()

```

> 赋值重载 *=*
> T& operator=(const T& that);

```c++
// 有动态分配内存，必须这样写
T& T::operator=( const T& that ) {
    if ( this != &that ) { // 检查地址， ( *this == that )  检查值
        // perform assignment
    }
    return *this;
}

A& operator=(const A& that) {
    if (this == &that) { return *this; }
    if ( this->geti() == that.geti() ) { return *this; }
    delete this->i; this->i = 0;
    i = new int; *i = that.geti();
    return *this;
}
// 这里的函数 geti() 是 const 修饰的， 因为参数为 const 修饰

class A {
public:
    explict A(const T& that) ; // explict 这里指定只能由 T 的构造
}
```

**注意：** const 修饰的参数仅能访问该对象 const 的函数

> 自动类型转换

*原型*

```c++
char -> short -> int -> float -> double
                 int -> long
```

*隐式*

```c++
T -> T&		T& -> T 	T* -> void*
T[] -> T* 	T* -> T[] 	T -> const T
```

##### 模板 注意：模板是不会做自动类型转换， 模板是声明

*函数模板 Function Template*

```c++
template <class type> return-type func-name(parameter list)
{
   // 函数的主体
}

template <class T> // 只有 T 可以换
void swap( T& x, T& y ) {
    T temp = x; x = y; y = temp;
}

// 是由编译器帮做出来相关类型的函数
int i = 3, j = 4;
swap(i, j); // use explict int swap

float k = 3.5, f = 4.5;
swap(k, f); // instanstiate float swap
```

*类模板*  **注意：T 的类要重载某些类**

```c++
template <class type, class type1, class type2> class class-name {
}

template <class T> void Stack<T>::pop () {}

template <class T>
class Vector {
public:
    Vector(int);
    ~Vector();
    T& operator[](int);
private:
    T* m_elements;
    int m_size;
}

// 类模板外部定义成员函数的方法
template<模板形参列表> 函数返回类型 类名<模板形参名>::函数名(参数列表){函数体}
template<class T1,class T2> void A<T1,T2>::h(){}
```

Vector< Vector< double * > > **注意：习惯每个尖括号要隔个空格，防止编译为  >> 右移符号**
**模板的声明或定义只能在全局，命名空间或类范围内进行。即不能在局部范围，函数内进行**

*模板函数*
*模板类*

###### 模板类继承

1. 普通类继承模板类

   ```c++
   template <class T>
   class Base {
       T data;
   };
   
   class Derived : public Base<int> {
   // ...  
   };
   ```

2. 模板类继承了普通类（非常常见））

   ```c++
   class Base {}
   template <class T>
   class Derived : public Base {
       T data;
   }
   ```

3. 类模板继承类模板

   ```c++
   template <class T>
   class Base { T data; };
   template <class T1, class T2>
   class Derived : public Base<T1> {
   	T2 data2;
   }
   ```

4. 模板类继承类模板，即继承模板参数给出的基类

###### 模板添加变量

```c++
template <class T, int len = 100> // 在使用的时候变
class Array {
public:
    Array();
    T& operator[] (int);
private:
    T elements[len]; // fixed array
}

Array<int, 10> v1;
Array<int, 10*5> v2;

```

##### 文件读写操作

> ```cpp
> ofstream  文件写操作，内存写入存储设备
> ifstream  文件读操作，存储设备读取到内存中
> fstream   读写操作，对打开的文件可进行读写操作
> 
> 文件打开模式：
>     ios::in   只读
>     ios::out  只写
>     ios::app  从文件末尾开始写，防止丢失文本中原有的内容，追加模式
>     ios::binary 二进制模式
>     ios::nocreate 打开一个文件时，如果文件不存在，不创建
>     ios::noreplace 打开一个文件时，如果文件不存在，创建该文件
>     ios::trunc   打开一个文件时，然后清空内容
>     ios::ate     打开一个文件时，将位置移动到文件末尾
> 文件指针位置的 C++ 中的用法：
>     ios::beg   文件开头
>     ios::end   文件末尾
>     ios::cur   文件当前位置
>     举个例子：
>         file.seekg(0, ios::beg)  让文件指针定位到文件开头
>         file.seekg(0, ios::end)  让文件指针定位到文件末尾
>         file.seekg(10, ios::cur) 让文件指针从当前位置向文件末尾方向移动10个字节
>         file.seekg(-10, ios::cur) 让文件指针从当前位置向文件开始方向移动10个字节
>         file.seekg(10,ios::beg)   让文件指针定位到离文件开头10个字节的位置
> 常用的错误判断方法:
>     good()   如果文件打开成功
>     bad()    打开文件时发生错误
>     eof()    到达文件尾
>         
> 
> getline()函数的作用：从输入字节流中读入字符，存到string变量中
> 直到遇到下面的情况停止：
>     读入了文件结束标志
>     读到一个新行
>     达到字符串的最大穿长度
>     如果getline没有读入字符，将返回false，用于判断文件是否结束
> ```

```c++
// 引入 <fstream>
#include <fstream>
// 写入
// 1.1 创建流对象
ofstream ofs;
// 1.2 指定写入的文件
/*
ios::in   读文件打开
ios::out  写文件打开
ios::ate  从文件尾打开
ios::app  追加方式打开
ios::trunc  如果已经有文件先删除在撞见
ios::binary 二进制方式
*/
ofs.open("file.txt", ios::out);
// 1.3 写入的内容
ofs << "写入一行数据" << endl;
// 1.4 关闭流
ofs.close();

// 读取数据
// 2.1 创建流
ifstream ifs;
// 2.2 指定路径和打开方法
ifs.open("file.txt", ios::in);
if (!ifs.is_open()) {
    cout << "open file failure" << endl;
    return ;
}
// 2.3 指定读入方式
---- 1 这个按照空格或换行读取数据
char buffer[1024] = {0};
while (ifs >> buffer) {
    cout << buffer << endl;
}
----- 2 这个就是一行一行的读取
char buffer[1024] = {0};
while (ifs.getline(buffer, sizeof(buffer))) {
    cout << buffer << endl;
}
----- 3
string buffer;
while (getline(ifs, buffer)) {
    cout << buffer << endl;
}
------- 4 不推荐
char c;
while ((c = ifs.get()) != EOF) {
    cout << c ;
}

// 2.4 关闭流
ifs.close();
```

