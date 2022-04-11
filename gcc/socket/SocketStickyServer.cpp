#include <iostream>
// inet_addr 老的函数，关闭警告
//#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <WinSock2.h>
// 不用 inet_addr ，改用新的 inet_pton() or InetPton()
#include <WS2tcpip.h>
#include "SocketHelper.h"

// 加载 ws2_32.dll
//#pragma comment (lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

int SocketStickyServer()
{
	// 初始化 DDL，ws2_32.dll 支持的最高版本为 2.2，建议使用的版本也是 2.2
	WSADATA wsaData;
	int wsaStartResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	std::cout << "WSAStartup result [" << wsaStartResult << "]" << std::endl;
	std::cout << "wVersion: " << (int)LOBYTE(wsaData.wVersion) << "." << (int)HIBYTE(wsaData.wVersion) << std::endl;
	std::cout << "wHighVersion: " << (int)LOBYTE(wsaData.wHighVersion) << "." << (int)HIBYTE(wsaData.wHighVersion) << std::endl;
	std::cout << "szDescription: " << wsaData.szDescription << std::endl;
	std::cout << "szSystemStatus: " << wsaData.szSystemStatus << std::endl;

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
	//InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);
	inet_pton(AF_INET, "127.0.0.1", &sockAddr.sin_addr.s_addr);
	sockAddr.sin_port = htons(50000); // 端口
	bind(serverSocket, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR)); // 绑定到 socket

	listen(serverSocket, 20);

	SOCKADDR clientAddr;
	int nSockAddrSize = sizeof(SOCKADDR);
	// 注意：accept() 会阻塞程序执行（后面代码不能被执行），直到有新的请求到来
	SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddr, &nSockAddrSize);
	printSocketInfo(clientSocket);

	// 注意这里，让程序暂停 10 秒，等待接收缓存区缓存大量客户端发送的数据，随后一次接收
	Sleep(10000);

	// 接受客户端的数据
	char buffer[BUFFER_SIZE] = { 0 }; // 缓冲区
	int recStrLen = recv(clientSocket, buffer, BUFFER_SIZE, 0);
	std::cout << "接受数据长度 [" << recStrLen << "] 内容为 [" << buffer << "]" << std::endl;
	send(clientSocket, buffer, recStrLen, NULL);

	// 关闭 Socket
	closesocket(clientSocket);
	closesocket(serverSocket);

	// 结束 DDL 使用
	WSACleanup();

	system("pause");

	return 0;
}
