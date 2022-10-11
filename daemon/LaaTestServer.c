#include "LaaSocketServer.h"

int main(int argc, char const* argv[])
{
	 char buffer[1024] = { 0 };
    char* hello = "Hello from server";
	int valread;
	LaaSocketServer laaTS;

	printf("InitListening called\n");
	laaTS.InitListening();
	valread = laaTS.ReciveFromClient(buffer,1024 );
    printf("%s\n", buffer);
	printf("Ret=%d\n", valread);
	valread = laaTS.SendToClient(hello,strlen(hello));
    printf("Hello message sent\n");
	printf("Ret=%d\n", valread);

	return 0;
}