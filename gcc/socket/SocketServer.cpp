#include <iostream>
// inet_addr 老的函数，关闭警告
//#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <WinSock2.h>
// 不用 inet_addr ，改用新的 inet_pton() or InetPton()
#include <WS2tcpip.h>

// 加载 ws2_32.dll
//#pragma comment (lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

/*

TCP (Transmission Control Protocol) 传输控制协议: 
	是一种面向连接的、可靠的、基于字节流的通信协议，数据在传输前要建立连接，传输完毕后还要断开连接
连接的建立（三次握手）: connect() 建立连接时，客户端和服务器端会相互发送三个数据包
	三次握手的关键是要确认对方收到了自己的数据包
数据传输时 ACK = Seq号 + 传递的字节数 + 1，与三次握手协议相同，最后加 1 是为了告诉对方要传递的 Seq 号。

为了完成数据包的重传，TCP套接字每次发送数据包时都会启动定时器
如果在一定时间内没有收到目标机器传回的 ACK 包，那么定时器超时，数据包会重传。ACK 包丢失的情况，一样会重传。

重传超时时间（RTO, Retransmission Time Out）
值太大了会导致不必要的等待，太小会导致不必要的重传，理论上最好是网络 RTT 时间，
但又受制于网络距离与瞬态时延变化，所以实际上使用自适应的动态算法（例如 Jacobson 算法和 Karn 算法等）来确定超时时间。

往返时间（RTT，Round-Trip Time）表示从发送端发送数据开始，
到发送端收到来自接收端的 ACK 确认包（接收端收到数据后便立即确认），总共经历的时延。

重传次数：TCP数据包重传次数根据系统设置的不同而有所区别。
有些系统，一个数据包只会被重传 3 次，如果重传 3 次后还未收到该数据包的 ACK 确认，就不再尝试重传。

注意：最后需要说明的是，发送端只有在收到对方的 ACK 确认包后，才会清空输出缓冲区中的数据。

每个 socket 被创建后，都会分配两个缓冲区，输入缓冲区和输出缓冲区。
I/O 缓冲区特性可整理如下：
1. I/O 缓冲区在每个 TCP 套接字中单独存在
2. I/O 缓冲区在创建套接字时自动生成
3. 即使关闭套接字也会继续传送输出缓冲区中遗留的数据
4. 关闭套接字将丢失输入缓冲区中的数据

输入输出缓冲区的默认大小一般都是 8K，可以通过 getsockopt() 函数获取
Windows Socket Buffer 默认 65536 = 64 K

*/

int SocketServer()
{
	// 初始化 DDL，ws2_32.dll 支持的最高版本为 2.2，建议使用的版本也是 2.2
	WSADATA wsaData;
	int wsaStartResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	std::cout << "WSAStartup result [" << wsaStartResult << "]" << std::endl;
	std::cout << "wVersion: " << (int)LOBYTE(wsaData.wVersion) << "." << (int)HIBYTE(wsaData.wVersion) << std::endl;
	std::cout << "wHighVersion: " << (int)LOBYTE(wsaData.wHighVersion) << "." << (int)HIBYTE(wsaData.wHighVersion) << std::endl;
	std::cout << "szDescription: " << wsaData.szDescription << std::endl;
	std::cout << "szSystemStatus: " << wsaData.szSystemStatus << std::endl;

	/* 注解：
	AF 为地址族（Address Family），也就是 IP 地址类型，常用的有 AF_INET 和 AF_INET6
	AF -> Address Family, INET -> Inetnet
	SOCK_STREAM 传输数据 -> IPPROTO_TCP (0) 表示 TCP 协议
	SOCK_DGRAM 传输方式 -> IPPROTO_UDP (1) 表示 UDP 协议
	** Linux 下一切皆文件，返回的是 Socket 文件描述符 （fd）
	*  Windows 返回的是 SOCKET 类型的文件句柄
	* 每个 socket 被创建后，都会分配两个缓冲区，输入缓冲区和输出缓冲区。
	*/
	// 创建 socket，socket() 函数创建套接字，确定套接字的各种属性
	SOCKET serverSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	unsigned socketBufferSize;
	int opLen = sizeof(socketBufferSize);
	getsockopt(serverSocket, SOL_SOCKET, SO_SNDBUF, (char*)&socketBufferSize, &opLen);
	std::cout << "Socket 缓冲区默认大小 [" << socketBufferSize << "]" << std::endl;

	// 服务端绑定 socket，bind() 函数将套接字与特定的 IP 地址和端口绑定，流经该 IP 地址和端口的数据才能交给套接字处理
	// 客户端要用 connect() 函数建立连接
	sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr)); // 每个字节填充为 0
	sockAddr.sin_family = PF_INET; // 使用 ipv4 地址
	// 编译异常： error C4996: 'inet_addr': Use inet_pton() or InetPton() instead 
	// or define _WINSOCK_DEPRECATED_NO_WARNINGS to disable deprecated API warnings
	//sockAddr.sin_addr.s_addr = inet_addr("127.0.0.1"); // 绑定到具体的地址
	InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);
	sockAddr.sin_port = htons(50000); // 端口
	bind(serverSocket, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR)); // 绑定到 socket

	/** 注释：
	* 服务器端程序
	* 1. 使用 bind() 绑定套接字
	* 2. 需要使用 listen() 函数让套接字进入被动监听状态
	* 3. 调用 accept() 函数响应客户端的请求
	* int listen(SOCKET sock, int backlog)
	* sock 为需要进入监听状态的套接字，backlog 为请求队列的最大长度
	* 
	* 被动监听，是指当没有客户端请求时，套接字处于“睡眠”状态
	* 只有当接收到客户端请求时，套接字才会被“唤醒”来响应请求
	* 
	* 请求队列 : 套接字正在处理客户端请求时，如果有新的请求进来，套接字是没法处理的，只能把它放进缓冲区，
	* 待当前请求处理完毕后，再从缓冲区中读取出来处理。如果不断有新的请求进来，就按照先后顺序在缓冲区中排队，
	* 直到缓冲区满。这个缓冲区，就称为请求队列（Request Queue）
	* 当请求队列满时，就不再接收新的请求，对于 Linux 客户端会收到 ECONNREFUSED 错误，对于 Windows 客户端会收到 WSAECONNREFUSED 错误
	* 
	* 注意：listen() 只是让套接字处于监听状态，并没有接收请求。接收请求需要使用 accept() 函数。
	*/
	// 监听状态
	listen(serverSocket, 20);

	/* 注释：
	int accept(int sock, struct sockaddr *addr, socklen_t *addrlen);  //Linux
	SOCKET accept(SOCKET sock, struct sockaddr *addr, int *addrlen);  //Windows
	accept() 返回一个新的套接字来和客户端通信
	addr 保存了客户端的 IP 地址和端口号
	sock 是服务器端的套接字
	注意区分，后面和客户端通信时，要使用这个新生成的套接字，而不是原来服务器端的套接字
	*/
	// 接受客户端请求
	SOCKADDR clientAddr;
	int nSockAddrSize = sizeof(SOCKADDR);
	// 注意：accept() 会阻塞程序执行（后面代码不能被执行），直到有新的请求到来
	SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddr, &nSockAddrSize);

	// 接受客户端的数据
	char buffer[BUFFER_SIZE] = { 0 }; // 缓冲区
	// memset(buffer, 0, BUFFER_SIZE);
	int recStrLen = recv(clientSocket, buffer, BUFFER_SIZE, 0);
	std::cout << "接受数据长度 [" << recStrLen << "] 内容为 [" <<  buffer << "]" << std::endl;


	// Windows 和 Linux 不同，Windows 区分普通文件和套接字，并定义了专门的接收和发送的函数。
	// int send(SOCKET sock, const char *buf, int len, int flags);
	// 最后的 flags 参数一般设置为 0 或 NULL，初学者不必深究
	// 向客户端发送数据
	const char* msg = "Hello Socket Client!";
	send(clientSocket, msg, (int)strlen(msg) + sizeof(char), NULL);

	// 客户端接收数据使用 recv() 函数
	// int recv(SOCKET sock, char *buf, int len, int flags);

	// 关闭 Socket
	closesocket(clientSocket);
	closesocket(serverSocket);

	// 结束 DDL 使用
	WSACleanup();

	system("pause");

	return 0;
}
