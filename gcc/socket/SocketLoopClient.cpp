#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>

// ���� ws2_lib.dll
#pragma comment(lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

//int SocketLoopClient()
int SocketLoopClient()
{
	// 1. ��ʼ�� WSA DDL
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = PF_INET;
	sockAddr.sin_port = htons(50000);
	InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);

	char buffer[BUFFER_SIZE] = { 0 };

	//while (true) 
	//{
	//	// 2. ���� socket
	//	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	//	
	//	// 3. ���ӷ�����
	//	connect(sock, (sockaddr*)&sockAddr, sizeof(SOCKADDR));

	//	// 4. �������������Ϣ
	//	const char* msg = "���� SocketClient ������������!";
	//	send(sock, msg, (int)strlen(msg) + 1, 0);

	//	// 5. ������Ϣ
	//	memset(buffer, 0, BUFFER_SIZE);
	//	int recStrLen = recv(sock, buffer, BUFFER_SIZE, 0);
	//	std::cout << "�������ݳ��� [" << recStrLen << "] ����Ϊ [" << buffer << "]" << std::endl;

	//	// 6. �ر� socket
	//	closesocket(sock);
	//}

	SOCKET socketArray[10];
	for (int i = 0; i < 10; i++)
	{
		// 2. ���� socket
		SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		// 3. ���ӷ�����
		connect(sock, (sockaddr*)&sockAddr, sizeof(SOCKADDR));
		socketArray[i] = sock;
	}
	for (int loop = 0; loop < 100; loop++) 
	{
		for (int i = 0; i < 10; i++)
		{
			// 4. �������������Ϣ
			const char* msg = "���� SocketClient ������������!";
			send(socketArray[i], msg, (int)strlen(msg) + 1, 0);

			// 5. ������Ϣ
			memset(buffer, 0, BUFFER_SIZE);
			int recStrLen = recv(socketArray[i], buffer, BUFFER_SIZE, 0);
			std::cout << "SOCKET = " << (int)socketArray[i] << "���������ݳ��� [" << recStrLen << "] ����Ϊ [" << buffer << "]" << std::endl;
		}
	}
	for (int i = 0; i < 10; i++)
	{
		closesocket(socketArray[i]);
	}

	// 7. �ͷ� DDL ����
	WSACleanup();

	system("pause");

	return 0;
}