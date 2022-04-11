#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>

// ���� ws2_lib.dll
#pragma comment(lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

int SocketStickyClient()
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

	// 2. ���� socket
	SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// 3. ���ӷ�����
	connect(sock, (sockaddr*)&sockAddr, sizeof(SOCKADDR));

	// 4. �������������Ϣ
	const char* msg = "abc";
	int msgLen = (int)strlen(msg);
	std::cout << "������Ϣ���� [" << msgLen << "]" << std::endl;
	for (int i = 0; i < 3; i++)
	{
		send(sock, msg, msgLen, 0);
		Sleep(2000);
	}

	std::cout << "��ʼ׼��������Ϣ" << std::endl;
	// 5. ������Ϣ
	int recStrLen = recv(sock, buffer, BUFFER_SIZE, 0);
	std::cout << "�������ݳ��� [" << recStrLen << "] ����Ϊ [" << buffer << "]" << std::endl;

	// 6. �ر� socket
	closesocket(sock);
	
	// 7. �ͷ� DDL ����
	WSACleanup();

	system("pause");

	return 0;
}