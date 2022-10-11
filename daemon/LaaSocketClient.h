#ifndef __LAASOCKETCLIENT_H__
#define __LAASOCKETCLIENT_H__

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>
#include <cstring>
 
#define SERVER_PORT 7000

/*
This class has only three methods
1. InitConnection() which creates, connects the socket to the server, 
in this class it is assumed that the server is running on localhost 
2. ReciveFromServer() if connected receives data from the server
3. SendToServer() if connected sends data to the server
*/

class LaaSocketClient
{
	private:
	int sock_fd;
	struct sockaddr_in6 server_addr;
	bool isConnected;
	
	public:

    // default constructor
	LaaSocketClient()
	{
		isConnected=false;
		sock_fd = -1;
		 memset(&server_addr,0,sizeof(server_addr));
	}

	// destructor
    ~LaaSocketClient()
	{
		if(isConnected)
		{
			/* Do TCP teardown */
			close(sock_fd);
		}
    }

	int InitConnection()
	{
		int ret;
		/* Create socket for communication with server */
		sock_fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
		if (sock_fd == -1) 
		{
			perror("socket()");
			return EXIT_FAILURE;
		}
		//------------------------------------------------
		/* Connect to server running on localhost */
		server_addr.sin6_family = AF_INET6;
		inet_pton(AF_INET6, "::1", &server_addr.sin6_addr);
		server_addr.sin6_port = htons(SERVER_PORT);
 
		/* Try to do TCP handshake with server */
		ret = connect(sock_fd, (struct sockaddr*)&server_addr, sizeof(server_addr));
		if (ret == -1) 
		{
			perror("connect()");
			close(sock_fd);
			return EXIT_FAILURE;
		}
		//At this point, the connection is established between 
		//client and server, and they are ready to transfer data.

		isConnected=true;
		return EXIT_SUCCESS;
	}

	int ReciveFromServer(char* buffer,int size )
	{
		int ret=0;
		/* Wait for data from server */
		if(isConnected)
		{
			ret = read(sock_fd, buffer, size);
			if (ret == -1) 
			{
				perror("read()");
				close(sock_fd);
				return EXIT_FAILURE;
			}
		}
		return ret;
	}

	int SendToServer(const char* buffer,int size)
	{
		int ret=0;
		/* Send data to server */
		if(isConnected)
		{
			ret = write(sock_fd, buffer, size);
			if (ret == -1) 
			{
				perror("write()");
				close(sock_fd);
				return EXIT_FAILURE;
			}
		}
		return ret;
	}

};


#endif // __LAASOCKETCLIENT_H__