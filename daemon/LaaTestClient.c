#include "LaaSocketClient.h"

int main(int argc, char const* argv[])
{
	 char buffer[1024] = { 0 };
    char* hello = "Hello from client";
	int valread;
	LaaSocketClient laaTC;

	printf("InitConnection called\n");
	laaTC.InitConnection();
	valread = laaTC.SendToServer(hello,strlen(hello));
    printf("Hello message sent\n");
	printf("Ret=%d\n", valread);
	valread = laaTC.ReciveFromServer(buffer,1024 );
    printf("%s\n", buffer);
	printf("Ret=%d\n", valread);

	return 0;
}