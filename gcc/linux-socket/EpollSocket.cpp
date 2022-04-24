// g++ -std=c++11 -pthread SelectSocket.cpp
#include <iostream>
// socket()/bind()/listen()/accept()
#include <sys/socket.h>
// epoll()
#include <sys/epoll.h>
// fcntl()
#include <fcntl.h>
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

const int SERVER_PORT = 10000;
const int BUFFER_LENGTH = 128;
const int MAX_EVENTS = 10;
const int BACKLOG = 10;

void printSocketaddrInfo(sockaddr_in* addr)
{
	// char *inet_ntoa(struct in_addr in);
	// uint16_t ntohs(uint16_t netshort);
	std::cout << "socket info = " << inet_ntoa(addr->sin_addr) << ":" << ntohs(addr->sin_port) << std::endl;
}

int socket_read(int sock_fd, char buffer[], int buffer_len)
{
	memset(buffer, '\0', buffer_len);
	// ssize_t read(int fd, void *buf, size_t count);
	int read_byte_len = (int) read(sock_fd, buffer, buffer_len);
	std::cout << "fd = " << sock_fd << " read byte len = " << read_byte_len << std::endl;
	std::cout << "fd = " << sock_fd << " receive message = " << buffer << std::endl;
	return read_byte_len;
}

int socket_write(int sock_fd, char buffer[], int buffer_len)
{
	int write_byte_len = write(sock_fd, buffer, buffer_len);
	std::cout << "fd = " << sock_fd << " write byte len = " << write_byte_len << std::endl;
	return write_byte_len;
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

	// ------------ epoll
	// https://man7.org/linux/man-pages/man7/epoll.7.html

	/* 
		epoll 事件（event）的两种触发模式：
			边沿触发 edge-triggered (ET)-(EPOLLET): 事件只要有，就会一直触发
				 edge-triggered mode delivers events only 
				 when changes occur on the monitored file descriptor.
				 EPOLLET flag should use nonblocking file descriptors.
			水平触发 level-triggered (LT)-(EPOLLIN) [epoll 默认模式]: 事件从无到有，才会触发
				socket 接收缓冲区不为空，有数据可读，读事件一直触发
				socket 发送缓冲区不满，可以继续写入数据，写事件一直触发
	*/

	// int epoll_create(int size);
	// int epoll_create1(int flags);
	int epoll_fd = epoll_create1(0);
	std::cout << "epoll_create1 result = " << epoll_fd << std::endl;

	// Level-triggered (LT) and edge-triggered (ET)
	struct epoll_event ev, events[MAX_EVENTS];
	// EPOLLIN 对应的文件描述符可以读（包括对端 socket 正常关闭）
	// EPOLLOUT df 可以写
	// EPOLLET 边缘触发
	ev.events = EPOLLIN;
    ev.data.fd = server_socket_fd;
    // https://man7.org/linux/man-pages/man2/epoll_ctl.2.html
    // int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
    // op - EPOLL_CTL_ADD/EPOLL_CTL_MOD/EPOLL_CTL_DEL
    int epoll_ctl_reault = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, server_socket_fd, &ev);
    std::cout << "epoll_ctl result = " << epoll_ctl_reault << std::endl;

    // https://man7.org/linux/man-pages/man2/epoll_wait.2.html
    // int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout);
    int nfds = 0;
    int n = 0;

    sockaddr_in client_sockaddr;
	socklen_t sockaddr_len = sizeof(client_sockaddr);
	std::cout << "sockaddr len = " << sockaddr_len << std::endl;

    while (true)
    {
    	nfds = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
    	if (nfds == -1)
    	{
    		std::cout << "epoll_wait result error" << std::endl;
    		break;
    	}

		// 遍历所有的事件
    	for (n = 0; n < nfds; ++n)
    	{
    		if (events[n].data.fd == server_socket_fd)
    		{
    			if (events[n].events & EPOLLIN)
    			{
					// int accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict addrlen);
					memset(&client_sockaddr, 0, sockaddr_len);
					int client_socket_fd = accept(server_socket_fd, 
						(sockaddr *)&client_sockaddr, &sockaddr_len);
					std::cout << "accept result (client socket fd) = " << client_socket_fd << std::endl;
					printSocketaddrInfo(&client_sockaddr);

					ev.events = EPOLLIN | EPOLLET;
					ev.data.fd = client_socket_fd;

					// 设置连接为非阻塞模式
					int flags = fcntl(client_socket_fd, F_GETFL, 0);
					if (flags < 0) 
					{
                        std::cout << "set no block error, fd:" << client_socket_fd << std::endl;
                        continue;
                    }
                    if (fcntl(client_socket_fd, F_SETFL, flags | O_NONBLOCK) < 0) {
                        std::cout << "set no block error, fd:" << client_socket_fd << std::endl;
                        continue;
                    }

                    // 将新的连接添加到 epoll 中
					// int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
					epoll_ctl_reault = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, client_socket_fd, &ev);
					std::cout << "accept epoll_ctl result = " << epoll_ctl_reault << 
						" fd = " << client_socket_fd << std::endl;
				}
    		}
    		else
    		{
    			// 判断是不是断开和连接出错，因为连接断开和出错时,也会响应`EPOLLIN`事件
    			if (events[n].events & EPOLLERR || events[n].events & EPOLLHUP)
    			{
					// 出错时,从 epoll 中删除对应的连接，第一个是要操作的 epoll 的描述符，因为是删除,所有event参数 null 就可以了
					epoll_ctl(epoll_fd, EPOLL_CTL_DEL, events[n].data.fd, NULL);
					std::cout << "client close fd:" << events[n].data.fd << std::endl;
					close(events[n].data.fd);
    			}
    			else if (events[n].events & EPOLLIN) 
    			{ //如果是可读事件
    				char buffer[BUFFER_LENGTH] = {0};
    				int len = socket_read(events[n].data.fd, buffer, BUFFER_LENGTH);
    				// 如果读取数据出错,关闭并从 epoll 中删除连接
    				if (len <= 0)
    				{
    					std::cout << "read client socket error" << std::endl;
    					epoll_ctl(epoll_fd, EPOLL_CTL_DEL, events[n].data.fd, NULL);
    					close(events[n].data.fd);
    				}
    				else
    				{
    					socket_write(events[n].data.fd, buffer, len);
    				}
    			}
    		}
    	}
    }

	// int close(int fd);
	std::cout << "close server socket." << std::endl;
	close(server_socket_fd);
	close(epoll_fd);

	return 0;
}