#include <iostream>
#include <thread>
#include <WinSock2.h>
#include <WS2tcpip.h>

int readSocketProcess(SOCKET sk)
{
	char buffer[1024] = { 0 }; // 缓冲区
	int recvLen = recv(sk, buffer, 1024, 0);
	if (recvLen <= 0)
	{
		std::cout << "接受数据长度为：" << recvLen << ", 判定客户端 socket = " << (int)sk << " 已经退出，任务结束。" << std::endl;
		return -1;
	}

	std::cout << "SOCKET = " << (int)sk << " 数据长度：" << recvLen << " 消息：" << buffer << std::endl;
	
	return 0;
}

void cmdThread(SOCKET sk)
{
	char buffer[256] = { 0 };
	while (1)
	{
		std::cin >> buffer;
		std::cout << "输入内容：" << buffer << std::endl;

		if (0 == strcmp(buffer, "exit"))
		{
			std::cout << "退出" << std::endl;
			closesocket(sk);
			return;
		}

		send(sk, buffer, strlen(buffer), 0);
		memset(buffer, 0, 256);
	}

}

int main()
{

	int iResult;
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	SOCKET clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	sockaddr_in serverAddr;
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(50000);
	inet_pton(AF_INET, "127.0.0.1", &serverAddr.sin_addr.s_addr);
	iResult = connect(clientSocket, (sockaddr*)&serverAddr, sizeof(sockaddr));
	if (iResult == SOCKET_ERROR)
	{
		std::cout << "connect() failed with erro " << WSAGetLastError() << std::endl;
		return 1;
	}
	std::cout << "connect() 成功连接到服务器." << std::endl;

	std::thread inputThread(cmdThread, clientSocket);
	inputThread.detach();

	FD_SET fdWriteSet;
	FD_SET fdReadSet;
	fd_set fdExpSet;
	int selectTotal;
	while (1)
	{
		// 清空集合数据
		FD_ZERO(&fdReadSet);
		FD_ZERO(&fdWriteSet);		
		FD_ZERO(&fdExpSet);

		// 每次 select 时需要放入要监听的事件集合
		FD_SET(clientSocket, &fdReadSet);
		//FD_SET(clientSocket, &fdWriteSet);
		//FD_SET(clientSocket, &fdExpSet);

		timeval tVal = { 1, 0 }; // 1 秒
		selectTotal = select(0, &fdReadSet, &fdWriteSet, &fdExpSet, &tVal);
		if (selectTotal < 0)
		{
			std::cout << "select() 结束" << std::endl;
			break;
		}
		//std::cout << "select() result : " << selectTotal << std::endl;

		if (FD_ISSET(clientSocket, &fdReadSet))
		{
			FD_CLR(clientSocket, &fdReadSet);
			if (-1 == readSocketProcess(clientSocket))
			{
				std::cout << "服务端疑似关闭连接，任务结束!" << std::endl;
				break;
			}
		}

		//std::cout << "处理其它逻辑" << std::endl;
	}

	closesocket(clientSocket);
	WSACleanup();

	system("pause");
	return 0;
}