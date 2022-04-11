#include <iostream>
#include <thread>
#include <WinSock2.h>
#include <WS2tcpip.h>

int readSocketProcess(SOCKET sk)
{
	char buffer[1024] = { 0 }; // ������
	int recvLen = recv(sk, buffer, 1024, 0);
	if (recvLen <= 0)
	{
		std::cout << "�������ݳ���Ϊ��" << recvLen << ", �ж��ͻ��� socket = " << (int)sk << " �Ѿ��˳������������" << std::endl;
		return -1;
	}

	std::cout << "SOCKET = " << (int)sk << " ���ݳ��ȣ�" << recvLen << " ��Ϣ��" << buffer << std::endl;
	
	return 0;
}

void cmdThread(SOCKET sk)
{
	char buffer[256] = { 0 };
	while (1)
	{
		std::cin >> buffer;
		std::cout << "�������ݣ�" << buffer << std::endl;

		if (0 == strcmp(buffer, "exit"))
		{
			std::cout << "�˳�" << std::endl;
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
	std::cout << "connect() �ɹ����ӵ�������." << std::endl;

	std::thread inputThread(cmdThread, clientSocket);
	inputThread.detach();

	FD_SET fdWriteSet;
	FD_SET fdReadSet;
	fd_set fdExpSet;
	int selectTotal;
	while (1)
	{
		// ��ռ�������
		FD_ZERO(&fdReadSet);
		FD_ZERO(&fdWriteSet);		
		FD_ZERO(&fdExpSet);

		// ÿ�� select ʱ��Ҫ����Ҫ�������¼�����
		FD_SET(clientSocket, &fdReadSet);
		//FD_SET(clientSocket, &fdWriteSet);
		//FD_SET(clientSocket, &fdExpSet);

		timeval tVal = { 1, 0 }; // 1 ��
		selectTotal = select(0, &fdReadSet, &fdWriteSet, &fdExpSet, &tVal);
		if (selectTotal < 0)
		{
			std::cout << "select() ����" << std::endl;
			break;
		}
		//std::cout << "select() result : " << selectTotal << std::endl;

		if (FD_ISSET(clientSocket, &fdReadSet))
		{
			FD_CLR(clientSocket, &fdReadSet);
			if (-1 == readSocketProcess(clientSocket))
			{
				std::cout << "��������ƹر����ӣ��������!" << std::endl;
				break;
			}
		}

		//std::cout << "���������߼�" << std::endl;
	}

	closesocket(clientSocket);
	WSACleanup();

	system("pause");
	return 0;
}