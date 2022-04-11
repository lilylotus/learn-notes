#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>
#include "SocketHelper.h"

//#pragma comment(lib, "ws2_32.lib")

int SocketFileServer()
{
	// 1. 初始化 WSAData
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);
	printWSADATA(wsaData);

	// 2. 创建 Socket
	SOCKET serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// 3. 绑定 ip + port
	sockaddr_in sockAddr;
	sockAddr.sin_family = PF_INET;
	sockAddr.sin_port = htons(50000);
	inet_pton(AF_INET, "127.0.0.1", &sockAddr.sin_addr.s_addr);
	bind(serverSocket, (sockaddr*)&sockAddr, sizeof(sockaddr));

	// 4. 监听
	listen(serverSocket, 20);

	// 5. 接受客户端请求
	SOCKADDR clientSocketAddr;
	int nSockAddrLen = sizeof(SOCKADDR);
	SOCKET clientSocket = accept(serverSocket, &clientSocketAddr, &nSockAddrLen);
	printSocketInfo(clientSocket);
	printSockAddrInInfo((sockaddr_in*)(&clientSocketAddr));

	// 循环发送数据
	const int bufferSize = 1024;
	char buffer[bufferSize] = { 0 };
	int nCount;
	FILE* fp;
	fopen_s(&fp, "D:\\mv.mp4", "rb");
	if (NULL == fp)
	{
		std::cout << "文件不存在" << std::endl;
		system("pause");
		exit(0);
	}
	while ((nCount = fread(buffer, 1, bufferSize, fp)) > 0)
	{
		send(clientSocket, buffer, nCount, 0);
	}

	// 文件发送完毕，断开输出流，向客户端发出 FIN 包
	shutdown(clientSocket, SD_SEND);
	memset(buffer, 0, bufferSize);
	recv(clientSocket, buffer, bufferSize, 0); // 阻塞，等待客户端接受完毕

	std::cout << "客户端响应 [" << buffer << "]" << std::endl;

	fclose(fp);
	closesocket(clientSocket);
	closesocket(serverSocket);

	WSACleanup();

	system("pause");
	return 0;
}