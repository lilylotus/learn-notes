#include <iostream>
#include <WinSock2.h>
#include <WS2tcpip.h>

//ͨ���׽��ֻ�ȡIP��Port�ȵ�ַ��Ϣ
bool GetAddressBySocket(SOCKET m_socket, SOCKADDR_IN& m_address)
{
	int nAddrLen = sizeof(m_address);
	memset(&m_address, 0, nAddrLen);
	//�����׽��ֻ�ȡ��ַ��Ϣ
	if (::getpeername(m_socket, (SOCKADDR*)&m_address, &nAddrLen) != 0)
	{
		printf("Get IP address by socket Failed!n");
		return false;
	}

	// ������� IP ��ַ
	char strBuffer[INET_ADDRSTRLEN];
	// ���ص�Ҳ�� IP ��ַ
	// PCSTR resultStr = inet_ntop(AF_INET, &m_address.sin_addr, strBuffer, sizeof(strBuffer));
	// std::cout << "inet_ntop result [" << resultStr << "]" << std::endl;
	inet_ntop(AF_INET, &m_address.sin_addr, strBuffer, sizeof(strBuffer));

	// ��ȡ IP �� Port
	std::cout << "Socket IP [" << strBuffer << ":" << ::ntohs(m_address.sin_port) << "]" << std::endl;
	return true;
}

void printSockAddrInInfo(const sockaddr_in* sk)
{
	char strBuffer[22] = { 0 };
	inet_ntop(AF_INET, &sk->sin_addr, strBuffer, sizeof(strBuffer));
	std::cout << "Socket IP [" << strBuffer << ":" << ::ntohs(sk->sin_port) << "]" << std::endl;
}

void printSocketInfo(SOCKET sk)
{
	SOCKADDR_IN sockAddr;
	GetAddressBySocket(sk, sockAddr);
	// true -> 1, false -> 0
	//std::cout << "��ѯ Socket ��� [" << result << "]" << std::endl;
}

void printWSADATA(WSADATA& wsaData)
{
	std::cout << "wVersion: " << (int)LOBYTE(wsaData.wVersion) << "." << (int)HIBYTE(wsaData.wVersion) << std::endl;
	std::cout << "wHighVersion: " << (int)LOBYTE(wsaData.wHighVersion) << "." << (int)HIBYTE(wsaData.wHighVersion) << std::endl;
	std::cout << "szDescription: " << wsaData.szDescription << std::endl;
	std::cout << "szSystemStatus: " << wsaData.szSystemStatus << std::endl;
}