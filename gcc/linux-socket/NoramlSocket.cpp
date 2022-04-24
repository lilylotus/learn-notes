// g++ -std=c++11 -pthread NormalSocket.cpp
#include <iostream>
// socket()/bind()/listen()/accept()
#include <sys/socket.h>
// close
#include <unistd.h>
// sockaddr_in/ sockaddr
#include <netinet/in.h>
#include <netinet/ip.h>
// inet_addr
#include <arpa/inet.h>
// memset()/strcmp()
#include <string.h>
// write()/read()
#include <unistd.h>
#include <thread>

void printSocketaddrInfo(sockaddr_in* addr)
{
	// char *inet_ntoa(struct in_addr in);
	// uint16_t ntohs(uint16_t netshort);
	std::cout << "socket info = " << inet_ntoa(addr->sin_addr) << ":" << ntohs(addr->sin_port) << std::endl;
}

void process_client_socket(int client_socket_fd)
{
	char buffer[128] = {0};
	while (true)
	{
		std::cout << "fd = " << client_socket_fd << " thread id = " << std::this_thread::get_id() << std::endl;
		memset(buffer, 0, 128);
		// 4. read message from client
		// ssize_t read(int fd, void *buf, size_t count);
		int read_byte_len = (int) read(client_socket_fd, buffer, 128);
		std::cout << "fd = " << client_socket_fd << " read byte len = " << read_byte_len << std::endl;
		std::cout << "fd = " << client_socket_fd << " receive message = " << buffer << std::endl;

		if (read_byte_len <= 0) {
			std::cout << "exceptions quit" << std::endl;
			close(client_socket_fd);
			break;
		}

		// 5. write message to client
		// ssize_t write(int fd, const void *buf, size_t count);
		int write_byte_len = write(client_socket_fd, buffer, read_byte_len);
		std::cout << "fd = " << client_socket_fd << " write byte len = " << write_byte_len << std::endl;

		if (0 == strcmp(buffer, "quit")) {
			std::cout << "fd = " << client_socket_fd << " quit server socket" << std::endl;
			close(client_socket_fd);
			break;
		}
	}
}

int main(int argc, char const *argv[])
{
	std::cout << "Hello Socket World!" << std::endl;

	// 1. socket - create an endpoint for communication
	// int socket(int domain, int type, int protocol);
	// domain: AF_INET - IPv4 , AF_INET6 - IPv6
	// type: SOCK_STREAM - tcp, SOCK_DGRAM - udp
	int server_socket_fd = socket(AF_INET, SOCK_STREAM, 0);
	std::cout << "server socket = " << server_socket_fd << std::endl;

	// 2. bind to local port
	// int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
	sockaddr_in local_sockaddr;
	memset(&local_sockaddr, 0, sizeof(local_sockaddr));
	local_sockaddr.sin_family = AF_INET;
	local_sockaddr.sin_port = htons(8080);
	// in_addr_t inet_addr(const char *cp);
	// INADDR_ANY inet_addr("127.0.0.1");
	local_sockaddr.sin_addr.s_addr = INADDR_ANY;
	int bind_reault = bind(server_socket_fd, (sockaddr *)&local_sockaddr, sizeof(local_sockaddr));
	std::cout << "binde result = " << bind_reault << std::endl;

	// 3. listen
	// int listen(int sockfd, int backlog);
	int listen_result = listen(server_socket_fd, 20);
	std::cout << "listen result = " << listen_result << std::endl;

	// 4. accept client connect, block
	// int accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict addrlen);
	sockaddr_in client_sockaddr;
	socklen_t sockaddr_len = sizeof(client_sockaddr);
	std::cout << "sockaddr len = " << sockaddr_len << std::endl;
	
	while (true) {
		memset(&client_sockaddr, 0, sockaddr_len);
		int client_socket_fd = accept(server_socket_fd, (sockaddr *)&client_sockaddr, &sockaddr_len);
		std::cout << "accept result (client socket fd) = " << client_socket_fd << std::endl;
		printSocketaddrInfo(&client_sockaddr);

		std::thread client(process_client_socket, client_socket_fd);
		// client.join();
		client.detach();

		// 4. read message from client
		// ssize_t read(int fd, void *buf, size_t count);
		// char buffer[128] = {0};
		// int read_byte_len = (int) read(client_socket_fd, buffer, 128);
		// std::cout << "read byte len = " << read_byte_len << std::endl;
		// std::cout << "receive message = " << buffer << std::endl;

		// 5. write message to client
		// ssize_t write(int fd, const void *buf, size_t count);
		// int write_byte_len = write(client_socket_fd, buffer, read_byte_len);
		// std::cout << "write byte len = " << write_byte_len << std::endl;

		// close(client_socket_fd);

		// if (0 == strcmp(buffer, "quit")) {
		// 	std::cout << "quit server socket" << std::endl;
		// 	break;
		// }
	}

	// int close(int fd);
	std::cout << "close server socket." << std::endl;
	close(server_socket_fd);

	return 0;
}