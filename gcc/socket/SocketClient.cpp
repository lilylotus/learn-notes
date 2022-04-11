#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>

// ���� ws2_lib.dll
#pragma comment(lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

//int SocketClient()
int SocketClient()
{
	// 1. ��ʼ�� WSA DDL
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	// 2. ���� socket
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// 3. ���ӷ�����
	sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr));
	sockAddr.sin_family = PF_INET;
	sockAddr.sin_port = htons(50000);
	InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);
	connect(sock, (sockaddr*)&sockAddr, sizeof(SOCKADDR));

	// 4. �������������Ϣ
	const char* msg = "���� SocketClient ������������!";
	send(sock, msg, (int)strlen(msg) + 1, 0);

	// 5. ������Ϣ
	char buffer[BUFFER_SIZE] = { 0 };
	int recStrLen = recv(sock, buffer, BUFFER_SIZE, 0);
	std::cout << "�������ݳ��� [" << recStrLen << "] ����Ϊ [" << buffer << "]" << std::endl;

	// 6. �ر� socket
	closesocket(sock);

	// 7. �ͷ� DDL ����
	WSACleanup();

	system("pause");

	return 0;
}