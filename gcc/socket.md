[参考文档 socket 编程](http://c.biancheng.net/cpp/html/3035.html)

## Socket 是什么？

在计算机通信领域，**socket** 被翻译为 "套接字"，它是计算机之间进行通信的一种约定或一种方式。通过 **socket** 这种约定，一台计算机可以接收其他计算机的数据，也可以向其他计算机发送数据。

学习 socket，也就是学习计算机之间如何通信，并编写出实用的程序。

### IP 地址 （IP Address）

计算机分布在世界各地，要想和它们通信，必须要知道确切的位置。确定计算机位置的方式有多种，IP 地址是最常用的。

计算机并不知道 IP 地址对应的地理位置，当要通信时，只是将 IP 地址封装到要发送的数据包中，交给路由器去处理。路由器用非常智能和高效的算法，快速找到目标计算机，并将数据包传递给它，完成一次单向通信。

目前大部分软件使用 IPv4 地址，但 IPv6 也正在被人们接受。

### 端口 （Port）

有了 IP 地址，虽然可以找到目标计算机，但仍然不能进行通信。一台计算机可以同时提供多种网络服务，例如Web 服务、FTP 服务（文件传输服务）、SMTP 服务（邮箱服务）等，仅有 IP 地址，计算机虽然可以正确接收到数据包，但是却不知道要将数据包交给哪个网络程序来处理，所以通信失败。

为了区分不同的网络程序，计算机会为每个网络程序分配一个独一无二的端口号（Port Number），例如，Web服务的端口号是 80，FTP 服务的端口号是 21，SMTP 服务的端口号是 25。端口（Port）是一个虚拟的、逻辑上的概念。

### 协议（Protocol）

协议（Protocol）就是网络通信的约定，通信的双方必须都遵守才能正常收发数据。协议有很多种，例如 TCP、UDP、IP 等，通信的双方必须使用同一协议才能通信。协议是一种规范，由计算机组织制定，规定了很多细节，例如，如何建立连接，如何相互识别等。

> 协议仅仅是一种规范，必须由计算机软件来实现。例如 IP 协议规定了如何找到目标计算机，那么各个开发商在开发自己的软件时就必须遵守该协议，不能另起炉灶。

所谓协议族（Protocol Family），就是一组协议（多个协议）的统称。最常用的是 TCP/IP 协议族，它包含了 TCP、IP、UDP、Telnet、FTP、SMTP 等上百个互为关联的协议，由于 TCP、IP 是两种常用的底层协议，所以把它们统称为 TCP/IP 协议族。

### 数据传输方式

计算机之间有很多数据传输方式，各有优缺点，常用的有两种：**SOCK_STREAM** 和 **SOCK_DGRAM**。

1) SOCK_STREAM 表示面向连接的数据传输方式。数据可以准确无误地到达另一台计算机，如果损坏或丢失，可以重新发送，但效率相对较慢。常见的 http 协议就使用 SOCK_STREAM 传输数据，因为要确保数据的正确性，否则网页不能正常解析。

2. SOCK_DGRAM 表示无连接的数据传输方式。计算机只管传输数据，不作数据校验，如果数据在传输中损坏，或者没有到达另一台计算机，是没有办法补救的。也就是说，数据错了就错了，无法重传。因为 SOCK_DGRAM 所做的校验工作少，所以效率比 SOCK_STREAM 高。

有可能多种协议使用同一种数据传输方式，所以在 socket 编程中，需要同时指明数据传输方式和协议。

综上所述：IP地址和端口能够在广袤的互联网中定位到要通信的程序，协议和数据传输方式规定了如何传输数据，有了这些，两台计算机就可以通信了。

## Windows 下 DDL 的加载

WinSock（Windows Socket）编程依赖于系统提供的动态链接库(DLL)，有两个版本：

- 较早的 DLL 是 wsock32.dll，大小为 28KB，对应的头文件为 winsock1.h
- 最新的 DLL 是 ws2_32.dll，大小为 69KB，对应的头文件为 winsock2.h

几乎所有的 Windows 操作系统都已经支持 ws2_32.dll，可以毫不犹豫地使用最新的 ws2_32.dll。

使用 DLL 之前必须把 DLL 加载到当前程序，可以在编译时加载，也可以在程序运行时加载。

### 静态链接库、动态链接库：

静态链接库在链接时，编译器会将 **.obj** 文件和 **.LIB** 文件组织成一个 **.exe** 文件，程序运行时，将全部数据加载到内存。如果程序体积较大，功能较为复杂，那么加载到内存中的时间就会比较长，最直接的一个例子就是双击打开一个软件，要很久才能看到界面。这是静态链接库的一个弊端。

动态链接库有两种加载方式：隐式加载和显示加载。

- 隐式加载又叫载入时加载，指在主程序载入内存时搜索 DLL，并将 DLL 载入内存。隐式加载也会有静态链接库的问题，如果程序稍大，加载时间就会过长，用户不能接受。
- 显式加载又叫运行时加载，指主程序在运行过程中需要 DLL 中的函数时再加载。显式加载是将较大的程序分开加载的，程序运行时只需要将主程序载入内存，软件打开速度快，用户体验好。

**注意：**.lib 文件包含 DLL 导出的函数和变量的符号名，只是用来为链接程序提供必要的信息，以便在链接时找到函数或变量的入口地址，.dll 文件才包含实际的函数和数据。

```cpp
# 隐式加载的方式，在编译时加载
#pragma comment(lib, "demo.lib")
```

### WSAStartup() 函数

使用 DLL 之前，还需要调用 **`WSAStartup()`** 函数进行初始化，以指明 **WinSock** 规范的版本。

```cpp
int WSAStartup(WORD wVersionRequested, LPWSADATA lpWSAData);
```

- wVersionRequested 为 WinSock 规范的版本号，低字节为主版本号，高字节为副版本号（修正版本号）
- lpWSAData 为指向 WSAData 结构体的指针

WinSock 规范的最新版本号为 2.2，较早的有 2.1、2.0、1.1、1.0，ws2_32.dll 支持所有的规范，而 wsock32.dll 仅支持 1.0 和 1.1。

**wsock32.dll** 已经能够很好的支持 TCP/IP 通信程序的开发，ws2_32.dll 主要增加了对其他协议的支持，不过建议使用最新的 **2.2** 版本。

```c++
MAKEWORD(1, 2);  //主版本号为1，副版本号为2，返回 0x0201
MAKEWORD(2, 2);  //主版本号为2，副版本号为2，返回 0x0202
```

# socket 缓冲区以及阻塞模式

可以使用 **`write()/send()`** 函数发送数据，使用 **`read()/recv()`** 函数接收数据，了解数据是如何传递的。

## socket 缓冲区

每个 **socket** 被创建后，都会分配两个缓冲区，输入缓冲区和输出缓冲区。

**`write()/send()`** 并不立即向网络中传输数据，而是先将数据写入缓冲区中，再由 **TCP** 协议将数据从缓冲区发送到目标机器。一旦将数据写入到缓冲区，函数就可以成功返回，不管它们有没有到达目标机器，也不管它们何时被发送到网络，这些都是 **TCP** 协议负责的事情。

***TCP*** 协议独立于 **`write()/send()`** 函数，数据有可能刚被写入缓冲区就发送到网络，也可能在缓冲区中不断积压，多次写入的数据被一次性发送到网络，这取决于当时的网络情况、当前线程是否空闲等诸多因素，不由程序员控制。

**`read()/recv()`** 函数也是如此，也从输入缓冲区中读取数据，而不是直接从网络中读取。

I/O 缓冲区特性可整理如下：

- I/O 缓冲区在每个 TCP 套接字中单独存在
- I/O 缓冲区在创建套接字时自动生成
- 即使关闭套接字也会继续传送输出缓冲区中遗留的数据
- 关闭套接字将丢失输入缓冲区中的数据

## 阻塞模式

对于 **TCP** 套接字（默认情况下），当使用 **`write()/send()`** 发送数据时：

1) 首先会检查写入缓冲区，如果缓冲区的可用空间长度小于要发送的数据，那么 **`write()/send()`** 会被阻塞（暂停执行），直到缓冲区中的数据被发送到目标机器，腾出足够的空间，才唤醒 `write()/send()` 函数继续写入数据。

2) 如果 TCP 协议正在向网络发送数据，那么输出缓冲区会被锁定，不允许写入，`write()/send()` 也会被阻塞，直到数据发送完毕缓冲区解锁，`write()/send()` 才会被唤醒。

3) 如果要写入的数据大于缓冲区的最大长度，那么将分批写入。

4) 直到所有数据被写入缓冲区 `write()/send()` 才能返回。

当使用 **`read()/recv()`** 读取数据时：

1) 首先会检查缓冲区，如果缓冲区中有数据，那么就读取，否则函数会被阻塞，直到网络上有数据到来。

2) 如果要读取的数据长度小于缓冲区中的数据长度，那么就不能一次性将缓冲区中的所有数据读出，剩余数据将不断积压，直到有 `read()/recv()` 函数再次读取。

3) 直到读取到数据后 `read()/recv()` 函数才会返回，否则就一直被阻塞。

这就是 TCP 套接字的阻塞模式。所谓阻塞，就是上一步动作没有完成，下一步动作将暂停，直到上一步动作完成后才能继续，以保持同步性。

注意：TCP 套接字默认情况下是阻塞模式，也是最常用的。当然你也可以更改为非阻塞模式。

# TCP 的粘包问题以及数据的无边界性

**socket** 缓冲区和数据的传递过程，数据的接收和发送是无关的，**`read()/recv()`** 函数不管数据发送了多少次，都会尽可能多的接收数据。也就是说，**`read()/recv()`** 和 **`write()/send()`** 的执行次数可能不同。

例如，write()/send() 重复执行三次，每次都发送字符串"abc"，那么目标机器上的 read()/recv() 可能分三次接收，每次都接收"abc"；也可能分两次接收，第一次接收"abcab"，第二次接收"cabc"；也可能一次就接收到字符串"abcabcabc"。

这就是数据的**“粘包”**问题，客户端发送的多个数据包被当做一个数据包接收。也称数据的无边界性，**`read()/recv()`** 函数不知道数据包的开始或结束标志（实际上也没有任何开始或结束标志），只把它们当做连续的数据流来处理。

## TCP 连接三次握手

TCP（Transmission Control Protocol，传输控制协议）是一种面向连接的、可靠的、基于字节流的通信协议，数据在传输前要建立连接，传输完毕后还要断开连接。

客户端在收发数据前要使用 **`connect()`** 函数和服务器建立连接。建立连接的目的是保证 IP 地址、端口、物理链路等正确无误，为数据的传输开辟通道。

TCP 建立连接时要传输三个数据包，俗称**三次握手（Three-way Handshaking）**

TCP 数据报文：

- 序号：Seq（Sequence Number）序号占 32 位，用来标识从计算机 A 发送到计算机 B 的数据包的序号，计算机发送数据时对此进行标记。
- 确认号：Ack（Acknowledge Number）确认号占 32 位，客户端和服务器端都可以发送，Ack = Seq + 1
- 标志位：每个标志位占用1Bit，共有6个，分别为 URG、ACK、PSH、RST、SYN、FIN，具体含义如下
  - URG：紧急指针（urgent pointer）有效。
  - ACK：确认序号有效。
  - PSH：接收方应该尽快将这个报文交给应用层。
  - RST：重置连接。
  - SYN：建立一个新连接。
  - FIN：断开一个连接。

> Seq 是 Sequence 的缩写，表示序列
> Ack(ACK) 是 Acknowledge 的缩写，表示确认
> SYN 是 Synchronous 的缩写，是“同步的”，这里表示建立同步连接
> FIN 是 Finish 的缩写，表示完成

客户端调用 **`socket()`** 函数创建套接字后，因为没有建立连接，所以套接字处于 `CLOSED` 状态。

服务器端调用 `listen()` 函数后，套接字进入 `LISTEN` 状态，开始监听客户端请求。

客户端开始发起请求：

1) 当客户端调用 `connect()` 函数后，TCP 协议会组建一个数据包，并设置 **SYN** 标志位，表示该数据包是用来建立同步连接的。同时生成一个随机数字 x，填充“序号（**Seq**）”字段，表示该数据包的序号。完成这些工作，开始向服务器端发送数据包，客户端就进入了 **`SYN-SEND`** 状态。

2) 服务器端收到数据包，检测到已经设置了 **SYN** 标志位，就知道这是客户端发来的建立连接的“请求包”。服务器端也会组建一个数据包，并设置 **SYN** 和 **ACK** 标志位，**SYN** 表示该数据包用来建立连接，**ACK** 用来确认收到了刚才客户端发送的数据包。

服务器生成一个随机数 y，填充“序号（Seq）”字段。y 和客户端数据包没有关系。

服务器将客户端数据包序号（x）加 1，得到 x+1，并用这个数字填充“确认号 **Ack** 字段。

服务器将数据包发出，进入 **`SYN-RECV`**  状态。

3) 客户端收到数据包，检测到已经设置了 **SYN** 和 **ACK** 标志位，就知道这是服务器发来的“确认包”。客户端会检测“确认号（Ack）”字段，看它的值是否为 x+1，如果是就说明连接建立成功。

接下来，客户端会继续组建数据包，并设置 **ACK** 标志位，表示客户端正确接收了服务器发来的“确认包”。同时，将刚才服务器发来的数据包序号（y）加1，得到 y+1，并用这个数字来填充“确认号（Ack）”字段。

客户端将数据包发出，进入 **`ESTABLISED`** 状态，表示连接已经成功建立。

4) 服务器端收到数据包，检测到已经设置了 **ACK** 标志位，就知道这是客户端发来的“确认包”。服务器会检测“确认号（Ack）”字段，看它的值是否为 y+1，如果是就说明连接建立成功，服务器进入 `ESTABLISED` 状态。

至此，客户端和服务器都进入了 **`ESTABLISED`** 状态，连接建立成功，接下来就可以收发数据了。

**注意：**三次握手的关键是要确认对方收到了自己的数据包，这个目标就是通过“确认号（**ack**）字段实现的。



客户端最后一次发送 ACK 包后进入 TIME_WAIT 状态，而不是直接进入 CLOSED 状态关闭连接。

## Linux Socket 函数

### 服务端

#### 1. 创建 socket `socket()`

[socket()](https://man7.org/linux/man-pages/man2/socket.2.html) - create an endpoint for communication

```cpp
#include <sys/socket.h>

int socket(int domain, int type, int protocol);

// 示例：创建监听 socket
int ListenSocket = socket(AF_INET, SOCK_STREAM, 0);
```

- **domain** ：指定用于通信的协议族，定义在 `<sys/socket.h>` 头文件中。常用的是 `AF_INET` （IPv4 Internet protocols - ipv4 协议族）和 `AF_INET6` （IPv6 Internet protocols - ipv6 网络协议）
- **type**：指定通信的方式、语义。常用的是 `SOCK_STREAM` （提供有序的、可靠的、双向的、基于连接的 字节流。指定的是 **TCP** 传输协议），`SOCK_DGRAM` （无连接的、不可靠的消息、固定的最大长度。**UDP** 传输协议）。从 Linux 2.6.27 ，定义了新的目的，`SOCK_NONBLOCK` 非阻塞。
- **protocol**：协议的类型，常用的是 0 或 **`NULL`**

创建成功，返回一个新的 ***socket*** 文件描述符 （file descriptor）。
遇到错误，返回 -1 ，并设置 **errno** 以指示错误。

#### 2. 绑定到本机的某个端口 `bind()`

[bind()](https://man7.org/linux/man-pages/man2/bind.2.html) - bind a name to a socket

```c++
#include <sys/socket.h>
// inet_pton - 把 ipv4/ipv6 地址转为二进制格式
// int inet_pton(int af, const char *restrict src, void *restrict dst);
// return 1 - success, 0 - src 字符串对应的网络协议地址不正确， -1 - error
#include <arpa/inet.h>
// memset
#include <string.h>

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

// 示例：绑定监听的 socket 到本机的 50000 端口
// Bing Socket to ip:port
sockaddr_in bindSockAddr;
int iSockAddrLen = sizeof(bindSockAddr);
memset(&bindSockAddr, 0, iSockAddrLen);
bindSockAddr.sin_family = AF_INET;
bindSockAddr.sin_port = htons(50000);
// bindSockAddr 绑定到 127.0.0.1 地址上
//inet_pton(AF_INET, "127.0.0.1", &bindSockAddr.sin_addr.s_addr);
// bindSockAddr 绑定到 0.0.0.0 地址上
bindSockAddr.sin_addr.s_addr = INADDR_ANY;
// -1 -> Error , 0 -> Success
int bindResult = bind(ListenSocket, (sockaddr*)&bindSockAddr, iSockAddrLen); 
```

- **sockfd** ：要绑定端口的 socket 文件描述符
- **addr**：配置要绑定的 ip:port
- **addrlen** ：地址类型的长度

绑定成功返回 0，绑定失败返回 -1。

##### ipv4/ipv6 地址转二进制，二进制转为 ipv4/ipv6 地址

[inet_pton()](https://man7.org/linux/man-pages/man3/inet_pton.3.html) - convert IPv4 and IPv6 addresses from text to binary form

[inet_ntop()](https://man7.org/linux/man-pages/man3/inet_ntop.3.html) - convert IPv4 and IPv6 addresses from binary to text form

```c++
#include <arpa/inet.h>

int inet_pton(int af, const char *restrict src, void *restrict dst);
const char *inet_ntop(int af, const void *restrict src, char *restrict dst, socklen_t size);

// 示例：转换 127.0.0.1 地址
unsigned char buffer[sizeof(struct in6_addr)];
inet_pton(AF_INET, "127.0.0.1", buffer);

char str[INET6_ADDRSTRLEN] = { 0 };
if (inet_ntop(AF_INET, buffer, str, INET6_ADDRSTRLEN) == NULL) {
    perror("inet_ntop");
    exit(EXIT_FAILURE);
}
printf("%s\n", str);
```

- **af**：AF - Address Family，地址协议族，`AF_INET` (ipv4) or `AF_INET6` (ipv6)
- **src**：对于地址的字符串，"127.0.0.1" / "1:0:0:0:0:0:0:8"
- **dst**：输出到哪里

inet_pton 返回值 1 - success, 0 - src 字符串对应的网络协议地址不正确， -1 - error。

inet_ntop 返回值，成功返回非 `NULL` 的 *dest* 指针，异常返回 `NULL`。

#### 3. 监听 `listen()`

[listen()](https://man7.org/linux/man-pages/man2/listen.2.html) - listen for connections on a socket

```c++
#include <sys/socket.h>

int listen(int sockfd, int backlog);

// 示例：监听 socket
// listen, 0 -> Success, -1 -> Failure
int listenResult = listen(ListenSocket, 20);
```

- **sockfd** ：指定要监听的 socket 文件描述符
- **backlog**：定义了 sockfd 待处理连接队列可能会增长的最大长度。`/proc/sys/net/ipv4/tcp_max_syn_backlog` 文件定义。

监听成功返回 0 ，失败返回 -1。

#### 4. 接收客户端连接 `accept()`

[accept()](https://man7.org/linux/man-pages/man2/accept.2.html) - accept a connection on a socket

```C++
#include <sys/socket.h>

// socklen_t - unsigned int 至少 32 bits - 4 bytes 字节
int accept(int sockfd, struct sockaddr *restrict addr,
           socklen_t *restrict addrlen);

#define _GNU_SOURCE             /* See feature_test_macros(7) */
#include <sys/socket.h>

int accept4(int sockfd, struct sockaddr *restrict addr,
            socklen_t *restrict addrlen, int flags);

// 示例：接收客户端连接
sockaddr_in clientSockAddr;
int sockaddrLen = sizeof(sockaddr);
memset(&clientSockAddr, 0, sizeof(sockaddr));
int clientSocket = accept(ListenSocket, (sockaddr*)&clientSockAddr, (socklen_t*)&sockaddrLen);
```

- **sockfd**：监听的服务端 socket 文件描述符
- **addr**：连接的客户端地址信息
- **addrlen**：地址数据格式长度

接收成功返回和客户端连接对于的一个 socket 文件描述符（非负整数）。失败返回 -1 。

#### 5. 接收数据 `read()`

[read()](https://man7.org/linux/man-pages/man2/read.2.html) - read from a file descriptor

```C++
#include <unistd.h>
// ssize_t - long unsigned int (8 bytes)
ssize_t read(int fd, void *buf, size_t count);

// 示例：从 socket 从读取数据
char buffer[1024] = {0};
int readBytesCount = (int)read(ListenSocket, buffer, 1024);
```

- **fd**：要读取数据的 socket 文件描述符
- **buf**：从 socket 中读取 count bytes 的数据放到 buf 缓存中
- **count**：本次从 socket 中读取的数据长度

成功返回读取到的数据 bytes 长度，0 - 表示文件结尾。错误或异常返回 -1 。

#### 6. 发送数据 `write()`

[write()](https://man7.org/linux/man-pages/man2/write.2.html) - write to a file descriptor

```C++
#include <unistd.h>
// strlen()
#include <string.h>
// ssize_t - long unsigned int (8 bytes)
ssize_t write(int fd, const void *buf, size_t count);

// 示例：
const char* msg = "欢迎来到 Linux Socket Server";
int writeBytesCount = (int)send(clientSocket, msg, (int)strlen(msg), 0);
```

写入成功返回写入的字节数，错误返回 -1 .

#### 7. 关闭 socket `close()`

[close()](https://man7.org/linux/man-pages/man2/close.2.html) - close a file descriptor

```C++
#include <unistd.h>

int close(int fd);

// 示例：关闭 socket
close(ListenSocket);
```

成功关闭返回 0 ，错误/异常返回 -1 .

#### 8. 非阻塞异步处理函数 `select()`

[select()](https://man7.org/linux/man-pages/man2/select.2.html) - select, pselect, FD_CLR, FD_ISSET, FD_SET, FD_ZERO - synchronous I/O multiplexing

```C++
#include <sys/select.h>

int select(int nfds, fd_set *restrict readfds,
           fd_set *restrict writefds, fd_set *restrict exceptfds,
           struct timeval *restrict timeout);

// 取消当前 socket 的事件绑定监控，从监听事件集合中删除改文件描述符
void FD_CLR(int fd, fd_set *set);
// 当前 socket 是否有绑定事件触发
int  FD_ISSET(int fd, fd_set *set);
// 把当前 socket 绑定到某个事件 (read/write/exception)
void FD_SET(int fd, fd_set *set);
// 初始化 fd_set 事件集合数据
void FD_ZERO(fd_set *set);

int pselect(int nfds, fd_set *restrict readfds,
            fd_set *restrict writefds, fd_set *restrict exceptfds,
            const struct timespec *restrict timeout,
            const sigset_t *restrict sigmask);

// 示例：监听客户端发送数据，服务端的读事件
fd_set fdReadSet;
FD_ZERO(&fdReadSet);
// 每次 select 时需要放入要监听的事件集合
FD_SET(ListenSocket, &fdReadSet);
// 注意：默认 select 会阻塞直到有客户发送数据进来
timeval tVal = { 1, 0 }; // 1 秒
int selectCount = select(ListenSocket + 1, &fdReadSet, 0, 0, &tVal);
```

- **nfds** ：此参数应设置为编号最高的文件三个集合中任何一个的描述符加 1。 检查每组中指示的文件描述符，最多此限制（但请参阅 BUGS）。

成功返回当前监听的 3 个事件集合中触发事件的 socket 数量。错误返货 -1 。

#### 9. 异步处理消息 `poll()`

[poll()](https://man7.org/linux/man-pages/man2/poll.2.html) - wait for some event on a file descriptor

```C++
#include <poll.h>

int poll(struct pollfd *fds, nfds_t nfds, int timeout);

#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include <poll.h>

int ppoll(struct pollfd *fds, nfds_t nfds,
          const struct timespec *tmo_p, const sigset_t *sigmask);
```

#### 10. 异步消息处理 `epoll()`

[epoll()](https://man7.org/linux/man-pages/man7/epoll.7.html) -- I/O event notification facility

```C++
#include <sys/epoll.h>
```

##### 边沿触发 (Level-triggered) 和水平触发 (edge-triggered)

**epoll** 事件分发接口能够同时作为边沿触发 (ET) 和水平触发 (LT) 。两种机制的区别可以如下面描述：

1.  The file descriptor that represents the read side of a pipe (**rfd**) is registered on the **epoll** instance.【表示管道读取端的文件描述符 (rfd) 在 epoll 实例上注册。】
2. A pipe writer writes 2 kB of data on the write side of the pipe. 【管道写入器在写入端写入 2 kB 的数据管道】
3. A call to `epoll_wait(2)` is done that will return **rfd** as a ready file descriptor.
4. The pipe reader reads 1 kB of data from **rfd**.
5. A call to **`epoll_wait(2)`** is done.

监听读缓冲区的变化：

- [LT] 水平触发：只要读缓冲区有数据就会触发 epoll_wait
- [ET] 边沿触发： 数据来一次，epoll_wait 只触发一次

监听写缓冲区的变化：

- [LT] 水平触发：只要可以写，就会触发
- [ET] 边沿触发： 数据从有到无，就会触发

推荐的使用示例：

```c++
#define MAX_EVENTS 10
struct epoll_event ev, events[MAX_EVENTS];
int listen_sock, conn_sock, nfds, epollfd;

/* Code to set up listening socket, 'listen_sock', (socket(), bind(), listen()) omitted. */

epollfd = epoll_create1(0);
if (epollfd == -1) {
    perror("epoll_create1");
    exit(EXIT_FAILURE);
}

// read()
ev.events = EPOLLIN;
ev.data.fd = listen_sock;
if (epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev) == -1) {
    perror("epoll_ctl: listen_sock");
    exit(EXIT_FAILURE);
}

for (;;) {
    nfds = epoll_wait(epollfd, events, MAX_EVENTS, -1);
    if (nfds == -1) {
        perror("epoll_wait");
        exit(EXIT_FAILURE);
    }

    for (n = 0; n < nfds; ++n) {
        if (events[n].data.fd == listen_sock) {
            conn_sock = accept(listen_sock, (struct sockaddr *) &addr, &addrlen);
            if (conn_sock == -1) {
                perror("accept");
                exit(EXIT_FAILURE);
            }
            setnonblocking(conn_sock);
            ev.events = EPOLLIN | EPOLLET;
            ev.data.fd = conn_sock;
            if (epoll_ctl(epollfd, EPOLL_CTL_ADD, conn_sock, &ev) == -1) {
                perror("epoll_ctl: conn_sock");
                exit(EXIT_FAILURE);
            }
        } else {
            do_use_fd(events[n].data.fd);
        }
    }
}
```



##### 10.1 打开一个 epoll 的文件描述符 `epoll_create()`

[epoll_create()](https://man7.org/linux/man-pages/man2/epoll_create.2.html)

注意：**`epoll_create()`** was added to the kernel in version 2.6. Since Linux 2.6.8, the size argument is ignored, but must be greater than zero (1).

**`epoll_create1()`** 当 **flag** 参数是 0 值，除了事实上绝对的 **size** 参数会丢弃，`epoll_create1()` 就和 `epoll_create()` 相同。

成功返回一个 *epoll* 的文件描述符实例 （非复整数）。失败/错误返回 -1 ，`errno` 表明错误的原因。

```c++
 #include <sys/epoll.h>
// open an epoll file descriptor
int epoll_create(int size);
int epoll_create1(int flags);
```

`epoll_create()` returns a file descriptor referring to the new *epoll* instance.

`epoll_create()` 返回一个指向新 *epoll* 实例的文件描述符，该文件描述符用来随后所有 *epoll* 接口的调用。当不在需要使用时，需要调用 `close()` 函数关闭，当所有文件描述符引用到一个 epoll 实例已经关闭，内核销毁实例并释放相关资源以供重用。

##### 10.2 添加关注感兴趣的文件描述符 `epoll_ctl()`

[epoll_ctl()](https://man7.org/linux/man-pages/man2/epoll_ctl.2.html)

通过方法 `epoll_ctl()` 注册感兴趣的文件描述符，添加项到 *epoll* 实例的兴趣列表当中。

当处理成功，返回 0 值。当遇到异常，返回 -1 值， `errno` 设置表示错误原因。

```c++
#include <sys/epoll.h>
// control interface for an epoll file descriptor
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
```

针对 *op* 参数有效的值：

- `EPOLL_CTL_ADD` ：在 *epoll* 文件描述符的兴趣列表中添加一个条目 *epfd* 。
- `EPOLL_CTL_MOD`：Change the settings associated with **fd** in the interest list to the new settings specified in **event**.
- `EPOLL_CTL_DEL`：Remove (deregister) the target file descriptor **fd** from the interest list.  The **event** argument is ignored and can be NULL (but see BUGS below).

针对 *event* 参数中的 *events* 值配置列表：

- `EPOLLIN`:  The associated file is available for `read(2)` operations.
- `EPOLLOUT`：The associated file is available for `write(2)` operations.
- `EPOLLET`: Requests edge-triggered notification for the associated file descriptor.

`struct epoll_event` 的数据结构

```c++
typedef union epoll_data {
    void        *ptr;
    int          fd;
    uint32_t     u32;
    uint64_t     u64;
} epoll_data_t;

struct epoll_event {
    uint32_t     events;      /* Epoll events */
    epoll_data_t data;        /* User data variable */
};
```

##### 10.3 等待 I/O 事件 `epoll_wait()`

[epoll_wait()](https://man7.org/linux/man-pages/man2/epoll_wait.2.html)

等待 I/O 事件，阻塞调用线程 如果当前没有可用的事件。

成功，返回准备好请求 I/O 的文件描述符数据量或者 0 值表示没有准备好事件的文件描述符。遇到异常，返回 -1 值，`errno` 设置表示错误原因。

```c++
#include <sys/epoll.h>
// wait for an I/O event on an epoll file descriptor
int epoll_wait(int epfd, struct epoll_event *events,
               int maxevents, int timeout);
```



### 客户端

#### 1. 连接到服务端 `connect()`

[connect()](https://man7.org/linux/man-pages/man2/connect.2.html) - initiate a connection on a socket

```C++
#include <sys/socket.h>
// socklen_t - unsigned int (4bytes - 0 to 4294967295)
int connect(int sockfd, const struct sockaddr *addr,
            socklen_t addrlen);

// 示例：
int conResult = connect(clientSocket, (sockaddr*)&sockAddr, sizeof(sockaddr));
```

成功连接返回 0 ，失败返回 -1 .

