#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>

#pragma comment(lib, "ws2_32.lib")

int SocketFileClient()
{

	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);
	SOCKET clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	sockaddr_in sockAddr;
	memset(&sockAddr, 0, sizeof(sockaddr_in));
	sockAddr.sin_family = PF_INET;
	sockAddr.sin_port = htons(50000);
	inet_pton(AF_INET, "127.0.0.1", &sockAddr.sin_addr.s_addr);
	connect(clientSocket, (sockaddr*)&sockAddr, sizeof(sockaddr));

	const int bufferSize = 1024;
	char buffer[bufferSize] = { 0 };
	int nCount;

	FILE* fp;
	fopen_s(&fp, "sk.mp4", "wb");
	if (NULL == fp) 
	{
		std::cout << "打开文件失败" << std::endl;
		closesocket(clientSocket);
		WSACleanup();
		system("pause");
		exit(0);
	}
	while ((nCount = recv(clientSocket, buffer, bufferSize, 0)) > 0)
	{
		fwrite(buffer, nCount, 1, fp);
	}
	const char* msg = "文件下载成功";
	std::cout << msg << std::endl;
	send(clientSocket, msg, (int)strlen(msg), 0);

	fclose(fp);
	closesocket(clientSocket);
	WSACleanup();

	system("pause");
	return 0;
}