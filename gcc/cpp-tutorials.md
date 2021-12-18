## Setup C++

- Visual Studio
- Visual Assist Options （插件）
- **C++  Version 11**

## Tips

### Struct

```C++
struct Entity
{
	int x, y;
	static int gx, gy;
	void Print()
	{
		std::cout << "x = " << x << ", y = " << y << std::endl;
	}
};

int Entity::gx;
int Entity::gy;

int main() 
{
    Entity e1;
	e1.x = 10;
	e1.y = 20;

    // 声明并赋值
	Entity e2 = { 6, 9 };
    
	Entity::gx = 100;
	Entity::gy = 200;
	std::cout << "static gx = " << Entity::gx << ", static gy = " << Entity::gy << std::endl;
    
    return 0;
}
```



## How C++ Works

```C++
#include <iostream>

// main 函数是程序的执行入口，是一个特殊的函数
int main() 
{
    // << 是一个操作符，其实就是一个函数
	std::cout << "Hello World!" << std::endl;
	std::cin.get();

    // main 函数可以没有 return，0 表示成功执行
	return 0;
}
```

<font color="red">注意：</font> 

- head 文件不会被编译，仅 cpp 文件会被编译。head 文件会被引入到 cpp 文件中，然后编译。
- 当有大量的 cpp 文件需要编译，每个 cpp 文件单独被编译，生成 obj 文件（.obj）。
- 最后所有的 .obj 文件链接（linking）为 exe （可执行）文件。

两个重要的概念：

1. **declaration**（声明）：`void Log(constant char* message);`，没有具体的实现 。
2. **definition**（定义）：

cpp 的执行流程：

1. 编译（compile）：[CTRL + F7] -> 生成 **.obj** 文件
2. 链接（linking）：生成可执行文件 **.exe**。会把函数的声明（declaration）和定义（definition）关联起来。

## C++ Compiler

C++ 编译输出 **.obj** 文件。**.obj** 机器码文件的可读输出为 **.asm** 文件（汇编）[Output Files - Assembler Output -> Assembly-Only (/FA)]。

对于编译来说，文件名称没有任何意义。

**预处理**（preprocess）代码：输出 **.i** 文件， 把 `#include` / `#define` 的代码复制到指定的代码段中。

```C++
// 条件预处理指令
#if 1
// coding
#endif
```

```
int Multiply() 
{
	return 2 * 5; // 这里在编译时会直接计算出结果，得到常量 10
}
```

优化代码。

## C++ Linker

把编译输出的 **.obj** 中需要链接的函数、变量等组装在一起。需要有入口函数 `main`。

注意是编译错误还是链接错误。

## variables (变量)

(`unsigned`)`char (1 byte), short(2 byte), int (4 byte), long(4 byte), long long(8 byte)`

`float(4 byte)[5.2F/f], double (8 byte)[5.2D/d]`

`bool (1 byte)`

## Header Files

 声明（declaration）`*.h` -> `#include "*.h"`

定义（definition）实现声明的定义（方法、类 ...）

```C++
// Log.h Header File Declaration
//#pragma once
#ifndef _LOG_H
#define _LOG_H
void InitLog();
void Log(const char* message);
#endif

// Log.cpp Header File Definition
#include <iostream>
#include "Log.h"
void InitLog()
{
    std::cout << "Init Log" << std::endl;
}
void Log(const char* message)
{
    std::cout << messge << std::endl;
}
```

## Pointers (指针)

**指针**仅仅是一个地址，是一个保存内存地址的 interger （整型） ，类型对保存地址没有任何意义，仅当获取该内存地址所在内容时，指针类型才指定获取多大的内存数据。

指针仅仅是一个变量保存了内存地址的位置。

```C++
// 定义一个空指针
void* vptr = 0;
void* vptr2 = nullptr; // C++ 关键字
void* vptr3 = NULL; // #define NULL 0
```

声明指针、赋值。指针类型对内存地址来说没有意义。

当变量直接定义，没有使用 `new` 关键字申请内存，那么分配的内存来 栈（内存连续）当中，`new` 分配的内存在 堆 （内存不一定连续）当中。

```C++
int var = 8;
void* iptr = &var;
// *iptr = 100; 编译错误， void 指针仅知道了 var 变量在内存的地址，但是没有类型支持，不知道要访问、修改的内存大小，所以才有了不同类型的指针

// 用指针访问值和修改值
int* iptr = &var;
*itpr = 200; // 当指明了指针的类型，编译才不会报错，才指定如何操作内存大小。

char* buffer = new char[8];
memset(buffer, 10, 8);
char** cptr = &buffer; // 指针的指针
*(buffer + 2) = 100;
char** cptr = &buffer; // 声明了一个 char* (char指针类型) 的指针变量
std::cout << *(buffer + 2) << std::endl;
// *(cptr) 表示了 buffer 指针的地址值，也是一个 char* 指针类型，就和操作 *(buffer + 2) 一致
std::cout << *(*(cptr) + 2) << std::endl;
delete[] buffer;
```

指针和数组是一致的

```C++
// 在 栈 中分配了 10 个 int 变量
int SomeArray[10];
int* pLocation6 = &SomeArray[6];
int* pLocation0 = &SomeArray[0];

std::cout << "pLocation6 = " << (int)pLocation6 << std::endl;
std::cout << "pLocation0 = " << (int)pLocation0 << std::endl;
std::cout << "Difference = " << (pLocation6 - pLocation0) << std::endl;
```

> 输出：一个 int 4 字节（bytes），6 个 int 24 字节，地址相差 24
> pLocation6 = 8518600
> pLocation0 = 8518576
> Difference = 6

```C++
int SomeArray[10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 };
int* pLocation0 = &SomeArray[0];
for (int i = 0; i < 10; i++)
{
    //std::cout << SomeArray + i << " = " << *(SomeArray + i) << std::endl;
    std::cout << pLocation0 << " = " << *pLocation0 << std::endl;
    pLocation0++;
}
```

字符串数组

```C++
char SomeString[] = "Hello!";
char* pSomeString = SomeString;
std::cout << "pSomeString = " << pSomeString << std::endl;

char* pLocation3 = &SomeString[3];
char* pLocation0 = &SomeString[0];
std::cout << "pLocation3 = " << (int)pLocation3 << " = " << pLocation3 << std::endl;
std::cout << "pLocation0 = " << (int)pLocation0 << " = " << pLocation0 << std::endl;
std::cout << "Difference = " << pLocation3 - pLocation0 << std::endl;
```

>输出：当 SomeString 赋值时。
>pSomeString = Hello!
>pLocation3 = 13893067 = lo!
>pLocation0 = 13893064 = Hello!
>Difference = 3
>
>当 SomeString 没有初始化赋值时： char SomeString[10];
>
>pSomeString = 烫烫烫烫烫烫烫烫烫烫瘊
>pLocation3 = 9960147 = 烫烫烫烫烫烫烫烫甜鷹
>pLocation0 = 9960144 = 烫烫烫烫烫烫烫烫烫烫瘊
>Difference = 3

为什么是输出 **烫** 这个中文：是因为 Debug 模式，所有分配出来的栈空间的每个字节都初始化为 0xCC。0xCCCC 的汉字编码就是烫，所有 0xCCCC 会被当做文本的 "烫"。

```C++
struct sSomeSubject
{
    int x = 0xA3A2A1A0;
    int y = 0xB3B2B1B0;
};

sSomeSubject SomeObjectArray[10];
// Heap (run time)
sSomeSubject* pSomeObject = new sSomeSubject[10];
// 声明了一个对象指针的数组
sSomeSubject** ppSomeObject = new sSomeSubject * [10];

for (int i = 0; i < 10; i++)
    ppSomeObject[i] = new sSomeSubject();

delete[] pSomeObject;
for (int i = 0; i < 10; i++)
    delete ppSomeObject[i];
delete[] ppSomeObject;
```

**Polymorphism** （多态）

```C++
#include <vector>

std::vector<sSomeSubject*> vSomeVector;
vSomeVector.push_back(new sSomeSubject());

for (auto& a : vSomeVector)
    std::cout << a->x << std::endl;
// &a 引用
for (auto& a : vSomeVector)
    delete a;

vSomeVector.clear();
```

## Reference （引用）

仅是编译时区分变量，当运行时其实就仅有一个变量 vara。

注意：引用仅会绑定引用变量声明时定义的引用变量，后面不能换变量绑定。

```C++
void IncrementRefrence(int& var) 
{
	var++;
}

int vara = 100;
int varb = vara;
int& ref = vara;
std::cout << "vara = " << vara << std::endl;
std::cout << "varb = " << varb << std::endl;
std::cout << "ref = " << ref << std::endl;

varb = 300;
ref = 600;
std::cout << "vara = " << vara << std::endl;
std::cout << "varb = " << varb << std::endl;
std::cout << "ref = " << ref << std::endl;

IncrementRefrence(varb);
IncrementRefrence(ref);
```

> 输出：vara 随着引用变量 ref 的修改也随之修改了。
>
> vara = 100
> varb = 100
> ref = 100
>
> vara = 600
> varb = 300
> ref = 600
>
> vara = 601
> varb = 301
> ref = 601

## Class（类）

注意：`Class` 中的变量默认是 **private** （私有）的。`struct` 中的变量默认是 **public**（公有）的。

```C++
class Player
{
public:
	void setX(int x)
	{
		this->x = x;
	}
	int getX()
	{
		return x;
	}
protected:
private:
	int x, y;
	int speed;
};
```

## Static in C++

- `static` 变量仅会在当前 cpp 中编译链接，不会在别的 cpp 中编译链接，别的 cpp 不会找到，类似是 cpp `private` 变量。
- `static` 方法没有 class/struct 实例。

```C++
// Static.cpp
static int vStaticVar = 100;

// Main.cpp
#include <iostream>
int vStaticVar = 300;
int main()
{
	std::cout << "vStaticVar = " << vStaticVar << std::endl;
    return 0;
}
```

> 输出：vStaticVar = 300

当 Static.cpp 中的 `static` 修饰符去掉后，编译就会报链接错误：*Static.obj : error LNK2005: "int vStaticVar" (?vStaticVar@@3HA) already defined in Main.obj*

```C++
// Static.cpp
int vStaticVar = 100;

// Main.cpp
#include <iostream>
// 申明，别的地方会有个 int 类型的 vStaticVar 变量，具体哪里有不知道
extern int vStaticVar;
int main()
{
	std::cout << "vStaticVar = " << vStaticVar << std::endl;
    return 0;
}
```

> 输出：vStaticVar = 100

若是此时在 Static.cpp 的 vStaticVar 加上 `static` 修饰符，那么会报：*Main.obj : error LNK2001: unresolved external symbol "int vStaticVar" (?vStaticVar@@3HA)*

`static` 在 `class` 、`struct` 中：

```C++
struct Entity
{
	static int x, y;
};

int Entity::x;
int Entity::y;

Entity::x = 20;
Entity::y = 30;
```

## Constructor （构造器）/ Destructor （析构函数）

变量没有初始化值是随机的，主要看当时所在内存的值。

C++ 当没有声明/定义默认的构造函数时会自动生成默认的构造函数。

析构函数不用显示手动调用，不然会析构两次。

```C++
class Entity
{
public:
	float x, y;

    // 类的初始化构造函数
	Entity() ;
    // Entity() = delete; 这样 Entity e; 就会报错，It is a deleted function.
	Entity(float x, float y);
    // 类的析构函数，在类变量的生命周期结束时会自动调用析构函数，自定义释放空间
	~Entity();
	void Print() 
	{
		std::cout << x << ", " << y << std::endl;
	}
private:

};
Entity::Entity()
{
}
Entity::Entity(float x, float y)
{
	this->x = x; this->y = y;
}
Entity::~Entity()
{
    std::cout << "Destory Entity!" << std::endl;
}

int main() 
{
    Entity e(10.0F, 5.0F);
	e.Print(); // 10, 5
    return 0;
}
```

## Inheritance （继承）

避免 code 重复

- 初始化构造函数先从继承的父类开始调用
- 变量生命周期结束，销毁调用析构函数与初始化相反，先从子类调用

```C++
class Entity
{
public:
	float x, y;
	Entity() { x = 0; y = 0; std::cout << "Entity Initialize" << std::endl; }
	~Entity() { std::cout << "Destroy Entity" << std::endl; }
	void Move(float xa, float ya) { x += xa; y += ya; }
};

class Player : public Entity
{
public:
	const char* Name;

	Player() { Name = nullptr; std::cout << "Player Initialize" << std::endl; }
	~Player() { std::cout << "Destroy Player" << std::endl; }
	void PrintName() { std::cout << Name << std::endl; }
};

int main() 
{
	std::cout << sizeof(Player) << std::endl;
	Player player;
	player.Move(5.0F, 5.0F);
    
    return 0;
}
```

> 输出：
>
> 12
> Entity Initialize
> Player Initialize
> Destroy Player
> Destroy Entity

### Virtual Function (虚函数)

- 没有虚函数时，仅会调用当前对象的方法。
- 当使用了 `virtual` 修饰类方法，表明该方法为虚函数，（动态调用- v-table）

```C++
#include <string>

class Entity
{
public:
 	virtual std::string GetName() { return "Entity"; }
};

class Player : public Entity
{
public:
	Player(const std::string& name) : m_Name(name) {}
    // C++ 11 , override 表明是 virtual 的重写
	std::string GetName() override { return m_Name; }
private:
	std::string m_Name;
};

void PrintName(Entity* entity)
{
	std::cout << entity->GetName() << std::endl;
}

int main() 
{
    Entity* e = new Entity();
	std::cout << e->GetName() << std::endl;
	PrintName(e);

	Player* p = new Player("Player!");
	std::cout << p->GetName() << std::endl;
	PrintName(p);

	Entity* entity = p;
	std::cout << entity->GetName() << std::endl;

	delete e;
	delete p;
    
    return 0;
}
```

> 输出：当基类 Entity 没有用 `virtual` 关键字修饰时
>
> Entity
> Entity
> Player!
> Entity
> Entity
>
> 输出：当使用 `virtual` 关键字修饰时
>
> Entity
> Entity
> Player!
> Player!
> Player!

### Virtual Destructors (虚析构函数)

```C++
class Base
{
public:
	Base() { std::cout << "Base Constructor!" << std::endl; }
    // 添加 virtual 关键字
	virtual ~Base() { std::cout << "Base Destructor!" << std::endl; }
};

class Driver : public Base
{
public:
	Driver() { std::cout << "Driver Constructor!" << std::endl; }
    // 添加 virtual 关键字
	virtual ~Driver() { std::cout << "Driver Destructor!" << std::endl; }
};

int main()
{
	Base* base = new Base();
	delete base;
	std::cout << "split==========" << std::endl;
	Driver* driver = new Driver();
	delete driver;
	std::cout << "split==========" << std::endl;
	Base* poly = new Driver();
    // 在没有虚析构函数时，注意：这里的 Driver 缺少了 Driver 的析构函数调用！
	delete poly;
    
    return 0;
}
```

> 普通继承输出：
>
> Base Constructor!
> Base Destructor!
> split==========
> Base Constructor!
> Driver Constructor!
> Driver Destructor!
> Base Destructor!
> split==========
> Base Constructor!
> Driver Constructor!
> Base Destructor!  # 注意：这里的 Driver 缺少了 Driver 的析构函数调用！

# Interface in C++ (Pure Virtual Function)

纯的虚函数没有实现，仅有声明，具体的定义实现由继承的类来实现。

继承纯虚函数的类必须重写该纯虚函数。

```C++
#include <string>
class Printable
{
public:
	// Pure Virtual Function
	// 类中所有的方法都是纯虚函数，接口类
	virtual std::string GetClassName() = 0;
};

class Entity : public Printable
{
public:
	virtual std::string GetName() { return "Entity"; }
	std::string GetClassName() override { return "ClassName::Entity"; }
};

class Player : public Entity
{
public:
	Player(const std::string& name) : m_Name(name) {}
	std::string GetName() override { return m_Name; }
	std::string GetClassName() override { return "ClassName::Player"; }

private:
	std::string m_Name;
};

void PrintName(Entity* entity) { std::cout << entity->GetName() << std::endl; }
void Print(Printable* obj) { std::cout << obj->GetClassName() << std::endl; }

int main() 
{
    // Printable* e = new Printable(); 纯虚函数的 class 无法实例化，会编译报错
	Entity* e = new Entity();
	Print(e);

	Player* p = new Player("Welcome!");
	Print(p);

	Entity* entity = p;
	Print(entity);

	delete e;
	delete p;
    return 0;
}
```

> 输出:
>
> ClassName::Entity
> ClassName::Player
> ClassName::Player

### Visibility （变量的可见性）

类中的可见性 `private`/`protected`/`public`

继承可见性：`private`/`protected`/`public`

## Array （数组）

```c++
// create array in stack
int exam[5];
int* ptr = exam;
for (int i = 0; i < 5; i++)
	exam[i] = 5;
exam[2] = 50;
*(exam + 3) = 60; // exam[3] = 60;
// 先强制转为 char* 指针，向前移动 4 字节，在强制转为 int* 指针，赋值 int 类型数值
*(int*)((char*)ptr + 4) = 6; // exam[1] = 6;

// create array in heap
int* another = new int[5];
for (int i = 0; i < 5; i++)
    another[i] = 16;
delete[] another;

// 计算数组的大小
int arr[5];
// only for stack array
int count = sizeof(arr) / sizeof(int); // = 5

class Enitty
{
public:
    // 编译常量
	static const int examSize = 5;
	int examSize[size];
}
```

## String （字符串）

```C++
// 注意： string 是以 \0 结尾
const char* name = "UserName";
// name[2] = 'a'; -> const - do not allow edit content
std::cout << name << std::endl; // -> UserName

const char vn[10] = "User\0Name";
std::cout << strlen(vn) << std::endl; // 字符串长度 = 4

char name2[9] = { 'U', 's', 'e', 'r', 'N', 'a', 'm', 'e', 0 };
std::cout << name2 << std::endl; // without 0 end -> UserName烫烫烫烫$祜

#include <string>
std::string vstring = std::string("UserName") + " Hello!";
vstring += " Hello!";
std::cout << vstring << std::endl;

// 使用 & 引用 (reference)，若是改为 std::string str，就是传值，调用该方法时会复制（新建）一个 string
// const 表示不允许修改该数据引用
void PrintString(const std::string& str)
{
	std::cout << str << std::endl;
}


const char* vc = u8"Hello!"; // 1 bytes
const wchar_t* vc2 = L"Hello!"; // 2 bytes
const char16_t* vc3 = u"Hello!"; // 2 bytes
const char32_t* vc4 = U"Hello!"; // 4 bytes

// const
const int* const var = 20; // 指针和值都不可以修改

class Instant
{
private:
	int* ptr;
public:
	const int* const getVar() const
	{
		// ptr = new int; third const not allow you do it.
		return ptr;
	}
};
```

## Mutable （可变的-可被改变的）

1. 用在类中 `const` 修饰方法中，但想修改某个字段 `mutable`
2. lambda 表达式中

```C++
class EntityInstance
{
private:
	std::string m_Name;
    // 该变量是可以修改的
	mutable int m_DebugCount = 0;
public:
	EntityInstance() : m_Name("Welcome!") {}
	const std::string& GetName() const
	{
		m_DebugCount++;
		return m_Name;
	}
};
```

lambda

```C++
int x = 9;
// & 使用引用， = 传值
auto f = [=]() mutable
{
    x++;
    std::cout << x << std::endl;
};
f();
// x = 9; 值不会被修改
```

# 构造函数（constructor）初始化列表

推荐使用的是构造函数初始值设定项列表 (Member Initializer Lists, Constructor Initializer List)。

对于原始类型采用哪种初始化方式都一样的，但是对于自定义 class 类型，推荐构造初始化列表。

```C++
#include <iostream>
#include <string>

using String = std::string;

class Inner
{
public:
	Inner() { std::cout << "Create Default Inner!" << std::endl; }
	Inner(int index) { std::cout << "Create Inner With Index " << index << "!" << std::endl; }
};

class Instance
{
private:
	String m_Name;
	Inner m_Inner;
public:
	//Instance() : m_Name("Welcome!") { m_Inner = Inner(8); }
	Instance() : m_Name("Welcome!"), m_Inner(10) {}
	Instance(const String& name) : m_Name(name) {}
};

Instance ins;
```

> 当没有使用成员变量初始化时输出：默认创建了 Inner 类两次
>
> Create Default Inner!
> Create Inner With Index 8!
>
> 当使用成员变量初始化时输出：仅创建 Inner 一次
>
> Create Inner With Index 10!

### Copy Constructor (拷贝构造函数)

```C++
#include <iostream>
#include <string>

class CopyString
{
private:
	char* m_Buffer;
	unsigned int m_Size;
public:
	CopyString(const char* str)
	{
		m_Size = strlen(str);
		// char 字符串最后需要 0 结束
		m_Buffer = new char[m_Size + 1];
		memcpy(m_Buffer, str, m_Size + 1);
		m_Buffer[m_Size] = 0;
		std::cout << "Created CopyString" << std::endl;
	}
	/* 拷贝构造函数
	CopyString(const CopyString& other)
		: m_Buffer(other.m_Buffer), m_Size(other.m_Size) { std::cout << "Invoke Copy Constructor" << std::endl; }*/
	// 更加严格的写法
	/*CopyString(const CopyString& other)
	{
		std::cout << "Invoke Copy Constructor" << std::endl;
		memcpy(this, &other, sizeof(CopyString));
	}*/
	CopyString(const CopyString& other)
		: m_Size(other.m_Size)
	{
		std::cout << "Invoke Copy Constructor" << std::endl;
		m_Buffer = new char[m_Size + 1];
		memcpy(m_Buffer, other.m_Buffer, m_Size + 1);
	}
	~CopyString() { std::cout << "Destroyed CopyString" << std::endl; delete[] m_Buffer; }
	char& operator[](unsigned int index) { return m_Buffer[index]; }
	// friend 关键字，声明这个函数是这个对对象的友函数，在该函数中就可以访问这个 class 的内容
	friend std::ostream& operator<<(std::ostream& stream, const CopyString& cs);
};

std::ostream& operator<<(std::ostream& stream, const CopyString& cs)
{
	stream << cs.m_Buffer;
	return stream;
}

/*
* PrintCopyStringInstance(CopyString ins)
* 当采用值拷贝的写法，会调用拷贝构造函数，产生一个临时的实例对象
* 
* PrintCopyStringInstance(const CopyString& ins)
* 当型参采用 & 引用的写法，不会调用拷贝构造函数，推荐写法，提高性能，不用在生成中间临时对象
*/
void PrintCopyStringInstance(const CopyString& ins) {
	std::cout << ins << std::endl;
}

int main()
{
	CopyString ins("Welcome!");
	// 没有拷贝构造函数时是 shallow 浅拷贝，内部的 char* 还是一样的，会导致 delete 多次，运行时出现异常
	CopyString copyIns = ins;

	copyIns[2] = 'X';

	std::cout << ins << std::endl;
	std::cout << copyIns << std::endl;
	
	std::cout << "--------" << std::endl;
	PrintCopyStringInstance(ins);
	PrintCopyStringInstance(copyIns);

	system("pause");
	return 0;
}
```

> 当没有使用拷贝构造函数时，输出：可以看出，对象仅创建了一次，但是销毁了两次，异常产生。
> Created CopyString
> WeXcome!
> WeXcome!
> 请按任意键继续. . .
> Destroyed CopyString
> Destroyed CopyString

> 当使用了拷贝构造函数后，输出：
>
> Created CopyString
> Invoke Copy Constructor -> 这里产生了一个新的对象，不是原来对象的引用
> Welcome!
> WeXcome!
> 请按任意键继续. . .
> Destroyed CopyString
> Destroyed CopyString

## new （heap 中申请内存）

```C++
int a = 10;
int* b = new int;
*b = 100;	
int* arr = new int[50]; // 50 * 4 = 200 bytes

Instance* ins = new Instance();
// c 分配内存的方式
Instance* ins2 = (Instance*) malloc(sizeof(Instance));

std::cout << *b << std::endl;

delete b;
delete[] arr;
delete ins;
// c 回收内存的方式
free(ins2);
```

## 显示转换(explict conversion) 和隐式转换（Implict Conversion)

```C++
class ConInstance
{
public:
	std::string m_Name;
	int m_age;
public:
	// explicit 关键字，不允许隐式转换，必须 CoInstance ins(20) 或 CoInstance ins = (CoInstance)20; 或 CoInstance(20);
	/*explicit ConInstance(int age) : m_Name("Unknown!"), m_age(age) {}*/
	ConInstance(int age) : m_Name("Unknown!"), m_age(age) {}
	ConInstance(const String& name) : m_Name(name), m_age(-1) {}
};

void PrintCoInstance(const ConInstance& ins) {
	std::cout << ins.m_Name << " : " << ins.m_age << std::endl;
}

// 推荐写法
ConInstance ins("Instance");
ConInstance ins2(20);

// 或者
ConInstance ins3 = ConInstance("Instance");
ConInstance ins4 = ConInstance(20);

// 隐式转换
ConInstance ins5 = std::string("Implicit Instance");
ConInstance ins6 = 20;

PrintCoInstance(20);
PrintCoInstance(std::string("Implicit Instance"));
```

## operator overloading (操作符重载)

操作符也是一种函数  

```C++
struct Vector2
{
	float x, y;

	Vector2(float x, float y)
		: x(x), y(y) {}

	Vector2 Add(const Vector2& other) const
	{
		return Vector2(x + other.x, y + other.y);
		// 重载之后写法
		//return *this + other;
		//return operator+(other); 不要这样做，很奇怪
	}

	Vector2 Multiply(const Vector2& other) const
	{
		return Vector2(x * other.x, y * other.y);
	}

	// + * 操作符重载
	Vector2 operator+(const Vector2& other) const { return Add(other); /*return Vector2(x + other.x, y + other.y);*/ }
	Vector2 operator*(const Vector2& other) const { return Multiply(other); }
	bool operator==(const Vector2& other) const { return x == other.x && y == other.y;  }
	bool operator!=(const Vector2& other) const { return !(*this == other); }
};

// << 操作符重载
std::ostream& operator<<(std::ostream& stream, const Vector2& other)
{
	stream << other.x << ", " << other.y;
	return stream;
}

int main()
{
	Vector2 position(4.0f, 4.0f);
	Vector2 speed(0.5F, 1.5F);
	Vector2 powerup(0.5F, 1.5F);

	Vector2 result = position.Add(speed.Multiply(powerup));
	Vector2 result2 = position + speed * powerup;

	// << 操作符重载之前写法
	std::cout << result.x << ", " << result.y << std::endl;
	// << 操作符重载之后写法
	std::cout << result << std::endl;
	std::cout << result2 << std::endl;

	if (result == result2) { std::cout << " result the same as result2" << std::endl; }
	else { std::cout << " result different with result2" << std::endl; }

	system("pause");
	return 0;
}
```

### 自增、自减运算符重载

自增运算符和自减运算符是有前置和后置之分。

为了区分所重载的是前置运算符还是后置运算符，C++规定：

前置运算符作为 **一元** 运算符重载，重载为成员函数的格式：

```C++
T & operator++(); // 前置自增运算符的重载函数，函数参数是空
T & operator--(); // 前置自减运算符的重载函数，函数参数是空
```

后置运算符作为 **二元** 运算符重载，多写一个 **没用** 的参数，重载为成员函数的个数：

```C++
T  operator++(int); // 后置自增运算符的重载函数，多一个没用的参数
T  operator--(int); // 后置自减运算符的重载函数，多一个没用的参数
```

**注意：** 前后置重载的返回对象，前置重载返回的是 `&` 引用对象，后置重载返回的是普通临时对象。**目的** 是为了保持原本 **C++** 前置和后置的运算符特性。

前置运算符特性：返回的是修改数据后的对象引用。

```C++
int a = 0;

(++a) = 5;
// 可拆解为
a = a + 1; 
a = 5;
```

> a 先自增 +1 后，a 值为 1，在参与 a = 5 的计算，最后 a 的值为 5。
> 说明 (++a) 返回的是自增后 a 变量，a 变量在后续的运算过程中值会被修改。
> 所以前置运算符重载返回的必须是引用 `&`。

后置运算符特性：返回的是修改数据前的对象，临时普通对象。

而**后置运算符不能作为左值**，也就是 `(a++) = 5` 是不成立的，那么后置运算符重载返回就是普通对象。

**注意：** 在自定义对象中，最好使用的是前置运算符重载，减少开销。

## Smart Pointers (std::unique_ptr, std::shared_ptr, std::weak_ptr)

```C++
// smart pointer include
#include <memory>

class SmartInstance
{
public:
	SmartInstance() { std::cout << "Create SmartInstance!" << std::endl; }
	~SmartInstance() { std::cout << "Destroyed SmartInstance!" << std::endl; }
	void Print() {}
};


{
    std::shared_ptr<SmartInstance> sharedPtr;
    {
        //std::unique_ptr<SmartInstance> instance(new SmartInstance()); 不能这样做
        // unique_ptr ins 的生命周期结束后，new 的 对象会自定被 delete 掉
        std::unique_ptr<SmartInstance> ins = std::make_unique<SmartInstance>();
        ins->Print();
        // 不能把一个 unique pointer 赋值给另一个 pointer
        // SmartInstance* i = ins; 编译异常

        // 同样不能这样做，不是想要的 std::shared_ptr<SmartInstance> ins2(new SmartInstance());
        // shared_ptr 当所有的 stack 引用变量生命周期结束后，这个 new 的对象会自动销毁 delete
        std::shared_ptr<SmartInstance> ins2 = std::make_shared<SmartInstance>();
        sharedPtr = ins2;
        ins2->Print();
    }
    // 在此， ins 生命周期结束后，ins 中 new 的 SmartInstance 会被自动 delete 掉
    // 在此， shared_ptr ins2 生命周期结束了，但是还有一个 sharedPtr 的引用存在，所有这个 new 对象还不能被 delete
}
// 在此， sharedPtr 生命周期结束了，最后一个 shared_ptr 的引用没了，这个 new 对象此时被 delete

```

## 箭头操作符 [Arrow] (->)

```C++
class ScopeInnerEntity
{
public:
	void Print() { std::cout << "Welcome!" << std::endl; }
};

class ScopeEntity
{
private:
	ScopeInnerEntity* m_Obj;
public:
	ScopeEntity(ScopeInnerEntity* obj)
		: m_Obj(obj) {}
	~ScopeEntity() { delete m_Obj; }
	ScopeInnerEntity* const operator->() { return m_Obj; }
};

// 使用
ScopeEntity entity = new ScopeInnerEntity();
entity->Print();
```

有趣实验，内存偏移：

```C++
struct OffsetVector
{
	float x, y, z;
};

// x 的内存地址距离 0 偏移，获取的是对象 x 的内存地址
int xOffset = (int)&((OffsetVector*)nullptr)->x;
int yOffset = (int)&((OffsetVector*)nullptr)->y;
int zOffset = (int)&((OffsetVector*)nullptr)->z;

std::cout << "x offset = " << xOffset << std::endl;
std::cout << "y offset = " << yOffset << std::endl;
std::cout << "z offset = " << zOffset << std::endl;
```

> 输出：
>
> x offset = 0
> y offset = 4
> z offset = 8

## 动态数组 （std::vector)

```C++
#include <vector>

struct DynamicVectorItem
{
	float x, y, z;

	DynamicVectorItem(float x, float y, float z)
		: x(x), y(y), z(z) { std::cout << "Create Vector Item!" << std::endl; }
	// copy constructor
	DynamicVectorItem(const DynamicVectorItem& other)
		: x(other.x), y(other.y), z(other.z) { std::cout << "Invoke Vector Item Copy Constructor!" << std::endl; }
};

std::ostream& operator<<(std::ostream& stream, const DynamicVectorItem& item)
{
	std::cout << item.x << ", " << item.y << ", " << item.z;
	return stream;
}

void VectorFunction(const std::vector<DynamicVectorItem>& v) { }

int main()
{
	//DynamicVectorItem* vertices = new DynamicVectorItem[5];
	//vertices[4] = DynamicVectorItem{ 1.0F, 2.0F, 3.0F };

	//std::vector<DynamicVectorItem*> vertices;
	std::vector<DynamicVectorItem> vertices;
	vertices.push_back({ 1.0F, 2.0F, 3.0F });
	vertices.push_back({ 4.0F, 5.0F, 6.0F });
	vertices.push_back({ 10.0F, 20.0F, 30.0F });
	
	std::cout << "-------- split line --------" << std::endl;
	for (unsigned int i = 0; i < vertices.size(); i++)
		std::cout << vertices[i] << std::endl;
	std::cout << "-------- split line --------" << std::endl;
	// remove item
	vertices.erase(vertices.begin() + 1);
	for (DynamicVectorItem& v : vertices)
		std::cout << v << std::endl;

	VectorFunction(vertices);

	system("pause");
	return 0;
}

// 优化后
int main()
{
    std::vector<DynamicVectorItem> vertices;
	// 告知 vector 保留 3 个元素的 array，将会立马申请 3 个元素的 array。
	vertices.reserve(3);
	vertices.push_back(DynamicVectorItem{ 1.0F, 2.0F, 3.0F });
	vertices.push_back({ 4.0F, 5.0F, 6.0F });
	// 这不需要调用拷贝构造函数
	vertices.emplace_back(10.0F, 20.0F, 30.0F);
}
```

> 输出：创建了 3 个对象，调用了 6 次拷贝构造函数
>
> Create Vector Item!
> Invoke Vector Item Copy Constructor!
> Create Vector Item!
> Invoke Vector Item Copy Constructor!
> Invoke Vector Item Copy Constructor!
> Create Vector Item!
> Invoke Vector Item Copy Constructor!
> Invoke Vector Item Copy Constructor!
> Invoke Vector Item Copy Constructor!
> -------- split line --------
> 1, 2, 3
> 4, 5, 6
> 10, 20, 30
> -------- split line --------
> 1, 2, 3
> 10, 20, 30

> 优化后输出：
>
> Create Vector Item!
> Invoke Vector Item Copy Constructor!
> Create Vector Item!
> Invoke Vector Item Copy Constructor!

结论就是：每放进去一个元素，就会新 new 一个 array，然后在把原来的输出拷贝到新的 array 中，在把新的元素添加进去。

## 使用库 Libraries (Static Linking)

[使用 GLFW 库](https://www.glfw.org/)

- 动态链接库 (dynamic)：在运行的时链接加载，与 exe 可执行文件分离

- 静态库 (static)：会把库打包到 exe 可执行文件中，执行更高效、更快

`glfw3.lib` - 是静态链接库，需要 Linker 引入 `*.lib` （如：`glfw3.lib`）

`glfw3.dll` - 是动态链接库，需要 Linker 引入 `*.dll.lib` （如：`glfw3dll.lib`) 匹配  `*dll` (`glfw3.dll`)文件，需要把 `*.dll` 库放到 exe 可执行文件同级目录。

Visual Studio 引入外部库，静态链接方式：

C/C++ / General / Additional Include Directories 中添加所需要引入的外部依赖库，仅引入了 Header 文件。
在引入链接库，Linker/Input/Additional Dependencies 引入 .lib 动态链接库的路径。

使用引用的外部依赖库

```C++
#include <iostream>
// 引入外部依赖库
#include <GLFW/glfw3.h>

int main()
{
	int a = glfwInit();
	std::cout << a << std::endl; // 1
	system("pause");
	return 0;
}
```

[Linker Tools Warning LNK4098](https://docs.microsoft.com/en-us/cpp/error-messages/tool-errors/linker-tools-warning-lnk4098?view=msvc-170)

## Template （模版）

**注意：**模版并不存在，直到具体的调用时。

```C++
template<typename T>
void Print(T value)
{
	std::cout << value << std::endl;
}

template<typename T, int N>
class TemplateArray
{
private:
	T m_Array[N];
public:
	int GetSize() const { return N; }
};

template <>
class Test <int>
{
public:
   Test() { std::cout << "Specialized template" << std::endl; }
};
// Test<int> a;

int main()
{
    Print<int>(5);
	Print<std::string>("Welcome!");
    
	TemplateArray<std::string, 5> array;
	std::cout << array.GetSize() << std::endl; // 5
    
    return 0;
}
```

宏（macros）定义，预处理（Preprocessor）时会把定义改为定义的值。

```C++
#define WAIT std::cin.get();
#define LOG(x) std::cout << x << std::endl

// 使用判断语句 #ifdef PR_DEBUG == 1
#ifdef PR_DEBUG
#define LOG(x) std::cout << x << std::endl
#else
#define LOG(x)
#endif

int main()
{
    LOG("Welcome!"); // std::cout << "Welcome!" << std::endl;
    WAIT; // std::cin.get();
    return 0;
}
```

## Function Pointer （函数指针）

```C++
#include <vector>
void Welcome() { std::cout << "Welcome!" << std::endl; }
void FunctionPrint(int v) { std::cout << "Print " << v << std::endl; }
// 第二个形参是一个 函数指针
void VectorForEach(const std::vector<int>& v, void(*func)(int))
{
	for (int value : v) func(value);
}
int IntOriginReturn(int v) { return v; }

int main()
{
	// 普通的函数调用
	Welcome();
	// 把函数赋值给一个变量 void(*function)() ， 函数指针定义
	auto function = Welcome;
	function();
	// 把函数赋值给一个函数指针
	void(*func)() = Welcome;
	func();
	// 定义了一个类型
	typedef void(*WelcomeFunction)();
	WelcomeFunction wFunc = Welcome;
	wFunc();
	// 定义了一个带有变量的函数指针类型
	typedef void(*PrintFunction)(int);
	PrintFunction pFunc = FunctionPrint;
	pFunc(20);

	std::vector<int> values = { 1, 2, 4, 5, 7, 8 };
	//VectorForEach(values, pFunc); 或者
	//VectorForEach(values, FunctionPrint);
	// 使用 lambda
	VectorForEach(values, [](int value) { std::cout << "Value: " << value << std::endl; });

	// 定义了一个返回 int 类型的函数指针
	int(*IntFunc)(int) = IntOriginReturn;
	pFunc(IntFunc(200));
    
	return 0;
}
```

## Lambdas

常和函数指针一起使用。

[Lambda expressions (since C++11)](https://en.cppreference.com/w/cpp/language/lambda)

```C++
auto lambda = [](int value) { std::cout << "Value: " << value << std::endl; };
```

`[ captures ] ( params ) { body }`

- `&` (implicitly capture the used automatic variables by reference)
- `=`(implicitly capture the used automatic variables by copy)

```C++
int iv = 200;
//auto lambda = [&iv](int value) { std::cout << "Outer Value: " << iv << std::endl; };
//auto lambda = [=](int value) { std::cout << "Outer Value: " << iv << std::endl; };
auto lambda = [&](int value) { std::cout << "Outer Value: " << iv << std::endl; };
```

## namespace

[Namespaces](https://en.cppreference.com/w/cpp/language/namespace)

1. 使用 `using namespace std;` 仅可能作用在作用域小范围内
2. 仅放开要使用的命名空间中的特定函数 `using std::cout;`
3. 仅可能指定命名空间 `std::cout << std::endl;`

`namespace a =  app::function;`

`using String = std::string;`

```C++
int main()
{
    // 仅放开命名空间的特定函数。
    using std::cout;
    // 放开命名空间的所以函数
    using namespace std;
    
    return 0;
}
```

## Thread

[std::thread](https://en.cppreference.com/w/cpp/thread/thread)

```C++
#include <thread>

static bool s_Finished = false;

void DoThreadWork()
{ 
	using namespace std::literals::chrono_literals;
    
    std::cout << "Started thread id = " << std::this_thread::get_id() << std::endl;

	while (!s_Finished)
	{
		std::cout << "Working ...\n";
		std::this_thread::sleep_for(1s);
	}
}

int main()
{
	std::thread worker(DoThreadWork);

	std::cin.get();
	s_Finished = true;

	// 让主线程等待当前线程完成任务
	worker.join();
	std::cout << "Work done!" << std::endl;
    std::cout << "Started thread id = " << std::this_thread::get_id() << std::endl;
    
    return 0;
}
```

## Timing

```C++
#include <chrono>

long fibonacci(unsigned n)
{
	if (n < 2) return n;
	return fibonacci(n - 1) + fibonacci(n - 2);
}

int main()
{
    // auto start = std::chrono::high_resolution_clock::now();
	auto start = std::chrono::steady_clock::now();
	std::cout << "f(42) = " << fibonacci(42) << '\n';
	auto end = std::chrono::steady_clock::now();
	std::chrono::duration<double> elapsed_seconds = end - start;
	std::cout << "elapsed time: " << elapsed_seconds.count() << "s\n";
    
    return 0;
}
```

# Multidimensional Arrays in C++ (2D arrays)

```C++
int* array = new int[50]; // 50 * 4 = 200 bytes
int** a2d = new int* [50];
//a2d[0] = nullptr;
//a2d[1] = new int[50];
for (int i = 0; i < 50; i++)
    a2d[i] = new int[50];

delete[] array;
for (int i = 0; i < 50; i++)
    delete[] a2d[i];
delete[] a2d;
```

## Type Punning

```C++
struct PunningIns
{
	int x, y;
};

PunningIns e = { 6, 8 };
// x variable memory address position
int* position = (int*)&e;
// 8
int y = *(int*)((char*)&e + 4);
// 等同于 int y = *((int*)((char*)&e + 4));
// 6, 8
std::cout << position[0] << ", " << position[1] << std::endl;
std::cout << "y = " << y << std::endl; // 8
```
