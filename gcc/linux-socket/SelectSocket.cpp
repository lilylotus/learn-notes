// g++ -std=c++11 -pthread SelectSocket.cpp
#include <iostream>
// socket()/bind()/listen()/accept()
#include <sys/socket.h>
// select()
#include <sys/select.h>
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

const int SERVER_PORT = 10000;
const int BACKLOG = 10;

void printSocketaddrInfo(sockaddr_in* addr)
{
	// char *inet_ntoa(struct in_addr in);
	// uint16_t ntohs(uint16_t netshort);
	std::cout << "socket info = " << inet_ntoa(addr->sin_addr) << ":" << ntohs(addr->sin_port) << std::endl;
}

int process_client_socket(int client_socket_fd)
{
	char buffer[128] = {0};
	// 4. read message from client
	// ssize_t read(int fd, void *buf, size_t count);
	int read_byte_len = (int) read(client_socket_fd, buffer, 128);
	std::cout << "fd = " << client_socket_fd << " read byte len = " << read_byte_len << std::endl;
	std::cout << "fd = " << client_socket_fd << " receive message = " << buffer << std::endl;

	if (read_byte_len <= 0) {
		std::cout << "exceptions quit" << std::endl;
		close(client_socket_fd);
		return 1;
	}

	// 5. write message to client
	// ssize_t write(int fd, const void *buf, size_t count);
	int write_byte_len = write(client_socket_fd, buffer, read_byte_len);
	std::cout << "fd = " << client_socket_fd << " write byte len = " << write_byte_len << std::endl;

	if (0 == strcmp(buffer, "quit")) {
		std::cout << "fd = " << client_socket_fd << " client close socket" << std::endl;
		close(client_socket_fd);
		return 1;
	}
	else if (0 == strcmp(buffer, "quit server")) 
	{
		std::cout << "fd = " << client_socket_fd << " quit server socket" << std::endl;
		close(client_socket_fd);
		return -1;
	}

	return 0;
}

int main(int argc, char const *argv[])
{
	std::cout << "Hello Select Socket World!" << std::endl;

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
	local_sockaddr.sin_port = htons(SERVER_PORT);
	// in_addr_t inet_addr(const char *cp);
	// INADDR_ANY inet_addr("127.0.0.1");
	local_sockaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	int bind_reault = bind(server_socket_fd, (sockaddr *)&local_sockaddr, sizeof(local_sockaddr));
	std::cout << "binde result = " << bind_reault << std::endl;

	// 3. listen
	// int listen(int sockfd, int backlog);
	int listen_result = listen(server_socket_fd, BACKLOG);
	std::cout << "listen result = " << listen_result << std::endl;

	// ------------ select


	// int select(int nfds, 
    //	     fd_set *restrict readfds, fd_set *restrict writefds, 
    //       fd_set *restrict exceptfds, struct timeval *restrict timeout);
    // void FD_ZERO(fd_set *set);
    // void FD_CLR(int fd, fd_set *set);
    // void FD_SET(int fd, fd_set *set);

    fd_set read_fd_set;
    fd_set read_fd_set_copy;
    int index = 0;
    int max_sock_fd = server_socket_fd;
    int current_max_sock_fd = max_sock_fd;
    int select_ready_count = 0;

    struct timeval time_val;
    time_val.tv_sec = 5;
    time_val.tv_usec = 0;
	
	// void FD_ZERO(fd_set *set);
    FD_ZERO(&read_fd_set);
    // void FD_SET(int fd, fd_set *set);
    // //i.e listenfd is available for connections.
    FD_SET(server_socket_fd, &read_fd_set);

    sockaddr_in client_sockaddr;
	socklen_t sockaddr_len = sizeof(client_sockaddr);
	std::cout << "sockaddr len = " << sockaddr_len << std::endl;

    while(1)
    {
    	read_fd_set_copy = read_fd_set;
    	current_max_sock_fd = max_sock_fd + 1;
    	select_ready_count = select(current_max_sock_fd, &read_fd_set_copy, NULL, NULL, &time_val);
    	if (select_ready_count < 0) 
    	{
    		std::cout << "select cause error" << std::endl;
    		break;
    	}
    	else if (select_ready_count == 0) 
    	{
    		//std::cout << "select timeout ..." << std::endl;
    		continue;
    	}
		
		std::cout << "select ready count = " << select_ready_count << std::endl;

		int process_result = 0;
		for (index = 0; index < current_max_sock_fd; index++)
		{
			if (FD_ISSET(index, &read_fd_set_copy))
			{
				std::cout << "fd index = " << index << std::endl;
				if (index == server_socket_fd)
				{
					// int accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict addrlen);
					memset(&client_sockaddr, 0, sockaddr_len);
					int client_socket_fd = accept(server_socket_fd, (sockaddr *)&client_sockaddr, &sockaddr_len);
					std::cout << "accept result (client socket fd) = " << client_socket_fd << std::endl;
					printSocketaddrInfo(&client_sockaddr);
					FD_SET(client_socket_fd, &read_fd_set);
					max_sock_fd = (max_sock_fd < client_socket_fd) ? client_socket_fd : max_sock_fd;
				}
				else
				{
					process_result = process_client_socket(index);
	    			if (process_result != 0)
	    			{
	    				FD_CLR(index, &read_fd_set);
	    				if (process_result == -1)
	    				{
	    					break;
	    				}
	    			}
				}
			}
		}

		if (process_result == -1)
		{
			for (index = 0; index < current_max_sock_fd; index++)
			{
				FD_CLR(index, &read_fd_set);
				close(index);
			}
			break;
		}
    }

    FD_CLR(server_socket_fd, &read_fd_set);
	// int close(int fd);
	std::cout << "close server socket." << std::endl;
	close(server_socket_fd);

	return 0;
}