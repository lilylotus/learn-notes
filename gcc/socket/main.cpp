#include <iostream>
// gethostbyname 弃用
//#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <WinSock2.h>
#include <WS2tcpip.h>
#include <vector>


#pragma comment(lib, "ws2_32.lib")

//int selectServer();

template<typename T>
void printMsg(T msg)
{
	std::cout << msg << std::endl;
}

//void funcGethostbyname(const char* domain)
//{
//	struct hostent* host = gethostbyname(domain);
//	if (NULL == host)
//	{
//		printMsg("Get Domain IP Address Error!");
//		system("pause");
//		exit(0);
//	}
//
//	// 别名
//	for (int i = 0; host->h_aliases[i]; i++)
//	{
//		std::cout << "Aliases [" << (i + 1) << "][" << host->h_aliases[i] << "]" << std::endl;
//	}
//
//	// 地址类型
//	std::cout << "Address type : " << ((host->h_addrtype == AF_INET) ? "AF_INET" : "AF_INET6") << std::endl;
//
//	// IP 地址
//	for (int i = 0; host->h_addr_list[i]; i++) {
//		printf("IP addr %d: %s\n", i + 1, inet_ntoa(*(struct in_addr*)host->h_addr_list[i]));
//	}
//}

void funcGetaddrinfo(const char* domain)
{
	addrinfo* answer;
	addrinfo hint;
	ADDRINFO* curr;

	char ipStr[16];
	memset(&hint, 0, sizeof(ADDRINFO));
	hint.ai_family = AF_INET;
	hint.ai_socktype = SOCK_STREAM;

	int ret = getaddrinfo(domain, NULL, &hint, &answer);

	if (0 != ret)
	{
		std::cout << "getaddrinfo Error [" << gai_strerror(ret) << "]" << std::endl;
	}

	for (curr = answer; curr != NULL; curr = curr->ai_next)
	{
		inet_ntop(AF_INET, &(((sockaddr_in*)(curr->ai_addr))->sin_addr), ipStr, 16);
		printMsg(ipStr);
	}

	freeaddrinfo(answer);

}

void swap(int a, int b)
{
	int tmp = b;
	b = a;
	a = tmp;
	std::cout << "a = " << a << " , b = " << b << std::endl;
}

void swapReference(int& a, int& b)
{
	int tmp = b;
	b = a;
	a = tmp;
	std::cout << "a = " << a << " , b = " << b << std::endl;
}

void swapPoint(int* a, int* b)
{
	int tmp = *b;
	*b = *a;
	*a = tmp;
	std::cout << "a = " << *a << " , b = " << *b << std::endl;
}

int main()
{
	std::cout << "Hello Socket Program!" << std::endl;

	int a = 1;
	int b = 2;
	swap(a, b);
	std::cout << "a = " << a << " , b = " << b << std::endl;
	
	std::cout << "============" << std::endl;
	swapReference(a, b);
	std::cout << "a = " << a << " , b = " << b << std::endl;

	std::cout << "============" << std::endl;
	swapPoint(&a, &b);
	std::cout << "a = " << a << " , b = " << b << std::endl;

	//WSADATA wsaData;
	//WSAStartup(MAKEWORD(2, 2), &wsaData);

	////funcGethostbyname("www.baiud.com");
	//printMsg("----------------------");
	//funcGetaddrinfo("www.baidu.com");

	//WSACleanup();

	std::vector<int> v;
	v.push_back(1);
	v.push_back(2);
	v.push_back(3);
	v.push_back(4);
	v.push_back(5);
	int vSize = v.size();
	std::cout << "Vector size = " << vSize << std::endl;
	for (int i = 0; i < vSize; i++)
	{
		std::cout << v[i] << std::endl;
	}

	/*char buffer[256] = { 0 };
	std::cin >> buffer;
	std::cout << "输入: " << buffer << std::endl;*/

	
	//selectServer();

	system("pause");

	return 0;
}