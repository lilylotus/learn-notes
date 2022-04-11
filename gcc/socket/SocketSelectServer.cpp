#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>
#include <vector>
#include "SocketHelper.h"

// Link to ws2_32.lib

int funcWSAStartup(WSADATA& wsaData)
{
	int wsaResult = 0;
	//MAKEWORD(2, 2); == 0x0202
	if ((wsaResult = WSAStartup(0x0202, &wsaData)) != 0)
	{
		std::cout << "WSAStartup() failed with error [" << wsaResult << "]" << std::endl;
		WSACleanup();
	}
	else
	{
		printMessage("WSAStartup() is fine!");
	}
	return wsaResult;
}

SOCKET funcCreateServerSocket()
{
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (INVALID_SOCKET == sock)
	{
		std::cout << "socket() funcation failed with error [" << WSAGetLastError() << "]" << std::endl;
		WSACleanup();
	}
	return sock;
}

void initSockAddrIn(SOCKADDR_IN& addr, const char* host, unsigned short port)
{
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	if (NULL == host)
	{
		addr.sin_addr.s_addr = INADDR_ANY;
	}
	else
	{
		inet_pton(AF_INET, host, &addr.sin_addr.s_addr);
	}
}

void funcCloseSocket(const SOCKET& sk)
{
	if (closesocket(sk) == 0)
	{
		printMessage("closesocket() is fine!");
	}
	else 
	{
		std::cout << "closesocket() failed with error code " << WSAGetLastError() << std::endl;
	}
}

void funcWSACleanup()
{
	if (WSACleanup() == 0)
	{
		printMessage("WSACleanup() is fine!");
	}
	else
	{
		std::cout << "WSACleanup() failed with error code " << WSAGetLastError() << std::endl;
	}
}

int clientSocketProcess(SOCKET sk)
{
	char buffer[1024] = { 0 }; // 缓冲区
	int recvLen = recv(sk, buffer, 1024, 0);
	if (recvLen <= 0)
	{
		std::cout << "接受数据长度为：" << recvLen << ", 判定客户端 socket = "<< (int)sk << " 已经退出，任务结束。" << std::endl;
		return -1;
	}

	std::cout << "SOCKET = " << (int)sk << " 数据长度：" << recvLen <<  " 消息：" << buffer << std::endl;

	if (0 == strcmp(buffer, "logout"))
	{
		std::cout << "SOCKET = " << (int)sk << " 客户端要求关闭连接" << std::endl;
		closesocket(sk);
		return -2;
	}
	else
	{
		const char* msg = "成功收到消息!";
		send(sk, msg, strlen(msg), 0);
	}

	return 0;
}

int main()
{

	WSADATA wsaData;
	int iResult = 0;
	//MAKEWORD(2, 2); == 0x0202
	if ((iResult = WSAStartup(MAKEWORD(2, 2), &wsaData)) != 0) {
		std::cout << "WSAStartup() failed with error [" << iResult << "]" << std::endl;
		funcWSACleanup();
		return 1;
	}
	std::cout << "WSAStartup() is fine!" << std::endl;;

	// Create a listening socket
	SOCKET listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (INVALID_SOCKET == listenSocket) {
		std::cout << "socket() funcation failed with error [" << WSAGetLastError() << "]" << std::endl;
		funcWSACleanup();
		return 1;
	}
	std::cout << "Create listen socket success!" << std::endl;

	// Bind the socket to the local IP address
	sockaddr_in sockAddr;
	//initSockAddrIn(sockAddr, "127.0.0.1", 50000);
	initSockAddrIn(sockAddr, NULL, 50000);
	printSockAddrInInfo(&sockAddr);
	iResult = bind(listenSocket, (sockaddr*)&sockAddr, sizeof(sockAddr));
	if (iResult == SOCKET_ERROR) {
		std::cout << "bind() failed with error [" << WSAGetLastError() << "]" << std::endl;
		closesocket(listenSocket);
		WSACleanup();
		return 1;
	}
	std::cout << "bind socket to local ip success!" << std::endl;

	iResult = listen(listenSocket, 5);
	if (iResult != 0) {
		std::cout << "listen() function failed with error " << WSAGetLastError() << std::endl;
		closesocket(listenSocket);
		WSACleanup();
		return 1;
	}
	std::cout << "socket listen fine!" << std::endl;
	std::cout << "Start server ... " << std::endl;

	FD_SET fdWriteSet;
	FD_SET fdReadSet;
	fd_set fdExpSet;
	int totalSockets = 0;
	int i;
	int selectTotal;
	int iSockAddrLen = sizeof(sockaddr);
	std::vector<SOCKET> gSocketClients;
	const char* defaultWelcomeMsg = "欢迎连接 Socket 服务器";
	const int iDefaultWelcomeMsgLen = (int)strlen(defaultWelcomeMsg);
	while (1)
	{
		// Prepare the Read and Write socket sets for network I/O notification
		// 清空集合数据
		FD_ZERO(&fdWriteSet);
		FD_ZERO(&fdReadSet);
		FD_ZERO(&fdExpSet);

		// 每次 select 时需要放入要监听的事件集合
		FD_SET(listenSocket, &fdReadSet);
		FD_SET(listenSocket, &fdWriteSet);
		FD_SET(listenSocket, &fdExpSet);

		int clientSize = (int)gSocketClients.size();
		std::cout << "连接客户端数量为 : " << clientSize << std::endl;
		for (i = 0; i < clientSize; i++)
		{
			// 仅关注连接过来的客户端的可读事件
			FD_SET(gSocketClients[i], &fdReadSet);
		}

		// 注意：FD_SET 默认仅支持 64 个 socket 处理
		// nfds 整数值，指 fd_set 集合中所有的描述符 (Socket) 的范围，而不是数量
		// 是所有文件描述符的最大值 + 1 ， 在 Windows 中这个参数可以置为 0
		// 注意：默认 select 会阻塞直到有客户发送数据进来
		timeval tVal = { 1, 0 }; // 1 秒
		selectTotal = select(0, &fdReadSet, &fdWriteSet, &fdExpSet, &tVal);
		if (selectTotal < 0)
		{
			std::cout << "select() 结束" << std::endl;
			break;
		}
		std::cout << "select() result : " << selectTotal << std::endl;

		// 判断此次 select 是否有关注的事件集合数据
		 // Check for arriving connections on the listening socket.
		if (FD_ISSET(listenSocket, &fdReadSet))
		{
			// 接受客户端连接
			sockaddr clientAddr;
			memset(&clientAddr, 0, sizeof(clientAddr));
			SOCKET clientSocket = accept(listenSocket, &clientAddr, &iSockAddrLen);
			std::cout << "新客户端加入：socket = " << (int)clientSocket << std::endl;
			printSockAddrInInfo((sockaddr_in*)&clientAddr);
			if (clientSocket != INVALID_SOCKET)
			{
				char m1[] = "新客户端连接到 Socket 服务器";
				int m1Len = (int)sizeof(m1);
				for (i = 0; i < clientSize; i++)
				{
					send(gSocketClients[i], m1, m1Len, 0);
				}
				send(clientSocket, defaultWelcomeMsg, iDefaultWelcomeMsgLen, 0);
				gSocketClients.push_back(clientSocket);
			}
			else
			{
				std::cout << "无效客户端连接，accept() failed with error " << WSAGetLastError() << std::endl;
				if (WSAGetLastError() != WSAEWOULDBLOCK)
				{
					std::cout << "accept() failed with error " << WSAGetLastError() << std::endl;
				}
				else 
				{
					std::cout << "accept() is fine!" << std::endl;
				}
			}
			FD_CLR(listenSocket, &fdReadSet);
		}
		int fdReadCount = fdReadSet.fd_count;
		for (i = 0; i < fdReadCount; i++)
		{
			if (clientSocketProcess(fdReadSet.fd_array[i]) < 0)
			{
				auto iter = std::find(gSocketClients.begin(), gSocketClients.end(), fdReadSet.fd_array[i]);
				if (iter != gSocketClients.end())
				{
					gSocketClients.erase(iter);
				}
			}
		}
	}

	// 关闭所有 socket
	for (i = gSocketClients.size() - 1; i >= 0; i--)
	{
		closesocket(gSocketClients[i]);
	}

	// https://docs.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-setsockopt
	//BOOL bOptVal = FALSE;
	//int bOptLen = sizeof(BOOL);
	//int iOptVal = 0;
	//int iOptLen = sizeof(int);
	//bOptVal = TRUE;
	//// SO_REUSEADDR
	//iResult = getsockopt(listenSocket, SOL_SOCKET, SO_KEEPALIVE, (char*)&iOptVal, &bOptLen);
	//if (iResult == SOCKET_ERROR) {
	//	std::cout << "getsocketopt() for SO_KEEPALIVE failed with error " << WSAGetLastError() << std::endl;
	//} else {
	//	std::cout << "SO_KEEPALIVE value : " << iOptVal << std::endl;
	//}
	//iResult = setsockopt(listenSocket, SOL_SOCKET, SO_KEEPALIVE, (char*)&bOptVal, bOptLen);
	//if (iResult == SOCKET_ERROR) {
	//	std::cout << "setsockopt() for SO_KEEPALIVE failed with error " << WSAGetLastError() << std::endl;
	//} else {
	//	std::cout << "Set SO_KEEPALIVE: ON" << std::endl;
	//}
	//iResult = getsockopt(listenSocket, SOL_SOCKET, SO_KEEPALIVE, (char*)&iOptVal, &iOptLen);
	//if (iResult == SOCKET_ERROR) {
	//	std::cout << "getsocketopt() for SO_KEEPALIVE failed with error " << WSAGetLastError() << std::endl;
	//} else {
	//	std::cout << "SO_KEEPALIVE value : " << iOptVal << std::endl;
	//}

	closesocket(listenSocket);
	funcWSACleanup();
	
	system("pause");
	return 0;
}