#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>

// 加载 ws2_lib.dll
#pragma comment(lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

//int SocketClient()
int SocketClient()
{
	// 1. 初始化 WSA DDL
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	// 2. 创建 socket
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// 3. 连接服务器
	sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = PF_INET;
	sockAddr.sin_port = htons(50000);
	InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);
	connect(sock, (sockaddr*)&sockAddr, sizeof(SOCKADDR));

	// 4. 向服务器发送消息
	const char* msg = "我是 SocketClient 发起连接请求!";
	send(sock, msg, (int)strlen(msg) + 1, 0);

	// 5. 接受消息
	char buffer[BUFFER_SIZE] = { 0 };
	int recStrLen = recv(sock, buffer, BUFFER_SIZE, 0);
	std::cout << "接受数据长度 [" << recStrLen << "] 内容为 [" << buffer << "]" << std::endl;

	// 6. 关闭 socket
	closesocket(sock);

	// 7. 释放 DDL 调用
	WSACleanup();

	system("pause");

	return 0;
}