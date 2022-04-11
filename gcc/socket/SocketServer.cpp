#include <iostream>
// inet_addr �ϵĺ������رվ���
//#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <WinSock2.h>
// ���� inet_addr �������µ� inet_pton() or InetPton()
#include <WS2tcpip.h>

// ���� ws2_32.dll
//#pragma comment (lib, "ws2_32.lib")

const int BUFFER_SIZE = 100;

/*

TCP (Transmission Control Protocol) �������Э��: 
	��һ���������ӵġ��ɿ��ġ������ֽ�����ͨ��Э�飬�����ڴ���ǰҪ�������ӣ�������Ϻ�Ҫ�Ͽ�����
���ӵĽ������������֣�: connect() ��������ʱ���ͻ��˺ͷ������˻��໥�����������ݰ�
	�������ֵĹؼ���Ҫȷ�϶Է��յ����Լ������ݰ�
���ݴ���ʱ ACK = Seq�� + ���ݵ��ֽ��� + 1������������Э����ͬ������ 1 ��Ϊ�˸��߶Է�Ҫ���ݵ� Seq �š�

Ϊ��������ݰ����ش���TCP�׽���ÿ�η������ݰ�ʱ����������ʱ��
�����һ��ʱ����û���յ�Ŀ��������ص� ACK ������ô��ʱ����ʱ�����ݰ����ش���ACK ����ʧ�������һ�����ش���

�ش���ʱʱ�䣨RTO, Retransmission Time Out��
ֵ̫���˻ᵼ�²���Ҫ�ĵȴ���̫С�ᵼ�²���Ҫ���ش������������������ RTT ʱ�䣬
�������������������˲̬ʱ�ӱ仯������ʵ����ʹ������Ӧ�Ķ�̬�㷨������ Jacobson �㷨�� Karn �㷨�ȣ���ȷ����ʱʱ�䡣

����ʱ�䣨RTT��Round-Trip Time����ʾ�ӷ��Ͷ˷������ݿ�ʼ��
�����Ͷ��յ����Խ��ն˵� ACK ȷ�ϰ������ն��յ����ݺ������ȷ�ϣ����ܹ�������ʱ�ӡ�

�ش�������TCP���ݰ��ش���������ϵͳ���õĲ�ͬ����������
��Щϵͳ��һ�����ݰ�ֻ�ᱻ�ش� 3 �Σ�����ش� 3 �κ�δ�յ������ݰ��� ACK ȷ�ϣ��Ͳ��ٳ����ش���

ע�⣺�����Ҫ˵�����ǣ����Ͷ�ֻ�����յ��Է��� ACK ȷ�ϰ��󣬲Ż��������������е����ݡ�

ÿ�� socket �������󣬶���������������������뻺�����������������
I/O ���������Կ��������£�
1. I/O ��������ÿ�� TCP �׽����е�������
2. I/O �������ڴ����׽���ʱ�Զ�����
3. ��ʹ�ر��׽���Ҳ������������������������������
4. �ر��׽��ֽ���ʧ���뻺�����е�����

���������������Ĭ�ϴ�Сһ�㶼�� 8K������ͨ�� getsockopt() ������ȡ
Windows Socket Buffer Ĭ�� 65536 = 64 K

*/

int SocketServer()
{
	// ��ʼ�� DDL��ws2_32.dll ֧�ֵ���߰汾Ϊ 2.2������ʹ�õİ汾Ҳ�� 2.2
	WSADATA wsaData;
	int wsaStartResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	std::cout << "WSAStartup result [" << wsaStartResult << "]" << std::endl;
	std::cout << "wVersion: " << (int)LOBYTE(wsaData.wVersion) << "." << (int)HIBYTE(wsaData.wVersion) << std::endl;
	std::cout << "wHighVersion: " << (int)LOBYTE(wsaData.wHighVersion) << "." << (int)HIBYTE(wsaData.wHighVersion) << std::endl;
	std::cout << "szDescription: " << wsaData.szDescription << std::endl;
	std::cout << "szSystemStatus: " << wsaData.szSystemStatus << std::endl;

	/* ע�⣺
	AF Ϊ��ַ�壨Address Family����Ҳ���� IP ��ַ���ͣ����õ��� AF_INET �� AF_INET6
	AF -> Address Family, INET -> Inetnet
	SOCK_STREAM �������� -> IPPROTO_TCP (0) ��ʾ TCP Э��
	SOCK_DGRAM ���䷽ʽ -> IPPROTO_UDP (1) ��ʾ UDP Э��
	** Linux ��һ�н��ļ������ص��� Socket �ļ������� ��fd��
	*  Windows ���ص��� SOCKET ���͵��ļ����
	* ÿ�� socket �������󣬶���������������������뻺�����������������
	*/
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
	InetPton(AF_INET, TEXT("127.0.0.1"), &sockAddr.sin_addr.s_addr);
	sockAddr.sin_port = htons(50000); // �˿�
	bind(serverSocket, (SOCKADDR*)&sockAddr, sizeof(SOCKADDR)); // �󶨵� socket

	/** ע�ͣ�
	* �������˳���
	* 1. ʹ�� bind() ���׽���
	* 2. ��Ҫʹ�� listen() �������׽��ֽ��뱻������״̬
	* 3. ���� accept() ������Ӧ�ͻ��˵�����
	* int listen(SOCKET sock, int backlog)
	* sock Ϊ��Ҫ�������״̬���׽��֣�backlog Ϊ������е���󳤶�
	* 
	* ������������ָ��û�пͻ�������ʱ���׽��ִ��ڡ�˯�ߡ�״̬
	* ֻ�е����յ��ͻ�������ʱ���׽��ֲŻᱻ�����ѡ�����Ӧ����
	* 
	* ������� : �׽������ڴ���ͻ�������ʱ��������µ�����������׽�����û������ģ�ֻ�ܰ����Ž���������
	* ����ǰ��������Ϻ��ٴӻ������ж�ȡ������������������µ�����������Ͱ����Ⱥ�˳���ڻ��������Ŷӣ�
	* ֱ������������������������ͳ�Ϊ������У�Request Queue��
	* �����������ʱ���Ͳ��ٽ����µ����󣬶��� Linux �ͻ��˻��յ� ECONNREFUSED ���󣬶��� Windows �ͻ��˻��յ� WSAECONNREFUSED ����
	* 
	* ע�⣺listen() ֻ�����׽��ִ��ڼ���״̬����û�н������󡣽���������Ҫʹ�� accept() ������
	*/
	// ����״̬
	listen(serverSocket, 20);

	/* ע�ͣ�
	int accept(int sock, struct sockaddr *addr, socklen_t *addrlen);  //Linux
	SOCKET accept(SOCKET sock, struct sockaddr *addr, int *addrlen);  //Windows
	accept() ����һ���µ��׽������Ϳͻ���ͨ��
	addr �����˿ͻ��˵� IP ��ַ�Ͷ˿ں�
	sock �Ƿ������˵��׽���
	ע�����֣�����Ϳͻ���ͨ��ʱ��Ҫʹ����������ɵ��׽��֣�������ԭ���������˵��׽���
	*/
	// ���ܿͻ�������
	SOCKADDR clientAddr;
	int nSockAddrSize = sizeof(SOCKADDR);
	// ע�⣺accept() ����������ִ�У�������벻�ܱ�ִ�У���ֱ�����µ�������
	SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddr, &nSockAddrSize);

	// ���ܿͻ��˵�����
	char buffer[BUFFER_SIZE] = { 0 }; // ������
	// memset(buffer, 0, BUFFER_SIZE);
	int recStrLen = recv(clientSocket, buffer, BUFFER_SIZE, 0);
	std::cout << "�������ݳ��� [" << recStrLen << "] ����Ϊ [" <<  buffer << "]" << std::endl;


	// Windows �� Linux ��ͬ��Windows ������ͨ�ļ����׽��֣���������ר�ŵĽ��պͷ��͵ĺ�����
	// int send(SOCKET sock, const char *buf, int len, int flags);
	// ���� flags ����һ������Ϊ 0 �� NULL����ѧ�߲����
	// ��ͻ��˷�������
	const char* msg = "Hello Socket Client!";
	send(clientSocket, msg, (int)strlen(msg) + sizeof(char), NULL);

	// �ͻ��˽�������ʹ�� recv() ����
	// int recv(SOCKET sock, char *buf, int len, int flags);

	// �ر� Socket
	closesocket(clientSocket);
	closesocket(serverSocket);

	// ���� DDL ʹ��
	WSACleanup();

	system("pause");

	return 0;
}
