#include <iostream>
// inet_addr �ϵĺ������رվ���
//#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <WinSock2.h>
// ���� inet_addr �������µ� inet_pton() or InetPton()
#include <WS2tcpip.h>
#include "SocketHelper.h"

// ���� ws2_32.dll
//#pragma comment (lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

int SocketStickyServer()
{
	// ��ʼ�� DDL��ws2_32.dll ֧�ֵ���߰汾Ϊ 2.2������ʹ�õİ汾Ҳ�� 2.2
	WSADATA wsaData;
	int wsaStartResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	std::cout << "WSAStartup result [" << wsaStartResult << "]" << std::endl;
	std::cout << "wVersion: " << (int)LOBYTE(wsaData.wVersion) << "." << (int)HIBYTE(wsaData.wVersion) << std::endl;
	std::cout << "wHighVersion: " << (int)LOBYTE(wsaData.wHighVersion) << "." << (int)HIBYTE(wsaData.wHighVersion) << std::endl;
	std::cout << "szDescription: " << wsaData.szDescription << std::endl;
	std::cout << "szSystemStatus: " << wsaData.szSystemStatus << std::endl;

	// ���� socket��socket() ���������׽��֣�ȷ���׽��ֵĸ�������
	SOCKET serverSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	unsigned socketBufferSize;
	int opLen = sizeof(socketBufferSize);
	getsockopt(serverSocket, SOL_SOCKET, SO_SNDBUF, (char*)&socketBufferSize, &opLen);
	std::cout << "Socket ������Ĭ�ϴ�С [" << socketBufferSize << "]" << std::endl;

	// ����˰� socket��bind() �������׽������ض��� IP ��ַ�Ͷ˿ڰ󶨣������� IP ��ַ�Ͷ˿ڵ����ݲ��ܽ����׽��ִ���
	// �ͻ���Ҫ�� connect() ������������
	sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockAddr)); // ÿ���ֽ����Ϊ 0
	sockAddr.sin_family = PF_INET; // ʹ�� ipv4 ��ַ
	// �����쳣�� error C4996: 'inet_addr': Use inet_pton() or InetPton() instead 
	// or define _WINSOCK_DEPRECATED_NO_WARNINGS to disable deprecated API warnings
	//sockAddr.sin_addr.s_addr = inet_addr("127.0.0.1"); // �󶨵�����ĵ�ַ
	//InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);
	inet_pton(AF_INET, "127.0.0.1", &sockAddr.sin_addr.s_addr);
	sockAddr.sin_port = htons(50000); // �˿�
	bind(serverSocket, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR)); // �󶨵� socket

	listen(serverSocket, 20);

	SOCKADDR clientAddr;
	int nSockAddrSize = sizeof(SOCKADDR);
	// ע�⣺accept() ����������ִ�У�������벻�ܱ�ִ�У���ֱ�����µ�������
	SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddr, &nSockAddrSize);
	printSocketInfo(clientSocket);

	// ע������ó�����ͣ 10 �룬�ȴ����ջ�������������ͻ��˷��͵����ݣ����һ�ν���
	Sleep(10000);

	// ���ܿͻ��˵�����
	char buffer[BUFFER_SIZE] = { 0 }; // ������
	int recStrLen = recv(clientSocket, buffer, BUFFER_SIZE, 0);
	std::cout << "�������ݳ��� [" << recStrLen << "] ����Ϊ [" << buffer << "]" << std::endl;
	send(clientSocket, buffer, recStrLen, NULL);

	// �ر� Socket
	closesocket(clientSocket);
	closesocket(serverSocket);

	// ���� DDL ʹ��
	WSACleanup();

	system("pause");

	return 0;
}
