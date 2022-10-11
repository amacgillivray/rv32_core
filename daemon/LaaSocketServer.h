#ifndef __LAASOCKETSERVER_H__
#define __LAASOCKETSERVER_H__

#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <netinet/in.h>
#include <cstring>
 
#define CLIENT_QUEUE_LEN 10
#define SERVER_PORT 7000

/*
This class has only three methods
1. InitListening() which creates, binds the socket for listening and waits for a client
2. ReciveFromClient() if connected receives data from client
3. SendToClient() if connected sends data to client
*/
class LaaSocketServer
{
	private:
	int listen_sock_fd, client_sock_fd;
	struct sockaddr_in6 server_addr, client_addr;
	socklen_t client_addr_len;
	//char str_addr[INET6_ADDRSTRLEN]; //to see INET6 address
	bool isConnected;

	public:

    // default constructor
	LaaSocketServer()
	{
		isConnected=false;
		listen_sock_fd = -1;
		client_sock_fd = -1;
		 memset(&server_addr,0,sizeof(server_addr));
		 memset(&client_addr,0,sizeof(client_addr));
	}

	// destructor
    ~LaaSocketServer()
	{
		if(isConnected)
		{
			/* Do TCP teardown */
			close(client_sock_fd);
			close(listen_sock_fd);
		}
    
    }
	
	int InitListening()
	{
		int ret, flag;
		/* Create socket for listening (client requests) */
		listen_sock_fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
		if(listen_sock_fd == -1) 
		{
			perror("socket()");
			return EXIT_FAILURE;
		}
		//--------------------------------------------------------
		/* Set socket to reuse address */
		flag = 1;
		ret = setsockopt(listen_sock_fd, SOL_SOCKET, SO_REUSEADDR, &flag, sizeof(flag));
		if(ret == -1) 
		{
			perror("setsockopt()");
			return EXIT_FAILURE;
		}
		//--------------------------------------------------------
		server_addr.sin6_family = AF_INET6;
		server_addr.sin6_addr = in6addr_any;
		server_addr.sin6_port = htons(SERVER_PORT);
 
		/* Bind address and socket together */
		ret = bind(listen_sock_fd, (struct sockaddr*)&server_addr, sizeof(server_addr));
		if(ret == -1) 
		{
			perror("bind()");
			close(listen_sock_fd);
			return EXIT_FAILURE;
		}
		//--------------------------------------------------------
		/* Create listening queue (client requests) */
		ret = listen(listen_sock_fd, CLIENT_QUEUE_LEN);
		if (ret == -1) 
		{
			perror("listen()");
			close(listen_sock_fd);
			return EXIT_FAILURE;
		}

		client_addr_len = sizeof(client_addr);
		//------------------------------------------------------		
		/* Do TCP handshake with client */
		client_sock_fd = accept(listen_sock_fd,
				(struct sockaddr*)&client_addr,
				&client_addr_len);
		if (client_sock_fd == -1) 
		{
			perror("accept()");
			close(listen_sock_fd);
			return EXIT_FAILURE;
		}
		/*
		inet_ntop(AF_INET6, &(client_addr.sin6_addr),
				str_addr, sizeof(str_addr));
		printf("New connection from: %s:%d ...\n",
				str_addr, ntohs(client_addr.sin6_port));
		*/
		//At this point, the connection is established between 
		//client and server, and they are ready to transfer data.

		isConnected=true;
		return EXIT_SUCCESS;
	}


	int ReciveFromClient(char* buffer,int size )
	{
		int ret=0;
		/* Wait for data from client */
		if(isConnected)
		{
			ret = read(client_sock_fd, buffer, size);
			if (ret == -1) 
			{
				perror("read()");
				close(client_sock_fd);
				return EXIT_FAILURE;
			}
		}
		return ret;
	}

	int SendToClient(const char* buffer,int size)
	{
		int ret=0;
		/* Send response to client */
		if(isConnected)
		{
			ret = write(client_sock_fd, buffer, size);
			if (ret == -1) 
			{
				perror("write()");
				close(client_sock_fd);
				return EXIT_FAILURE;
			}
		}
		return ret;
	}
};

#endif // __LAASOCKETSERVER_H__