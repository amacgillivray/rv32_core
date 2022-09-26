#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include <memory>
#include <mqueue.h> 
#include <cstring>
#include <unistd.h>

#include "../laa_config.hpp"
#include "../laa_api.hpp"

void standalone_test();

// todo later: allow argument for # messages to send in the test
int main(int argc, char ** argv)
{
    size_t exe_sz = 12345;

    if (laa::request_execution(exe_sz))
        std::cout << "Message sent to daemon successfully." << std::endl;
    else {
        std::cout << "Error: Message send failure." << std::endl;
        perror(strerror(errno));
    }
}


void standalone_test() 
{
    const char * msg = "Hello, Daemon! This is a client process\nwith some text.\n";
    // char buffer[LAA_MQ_MSGSIZE] = {'\0'};

    // pid_t pid = getpid();

    mqd_t s; // server

    mq_attr queue_attributes{
        LAA_MQ_FLAGS,   // mq_flags
        LAA_MQ_MAXMSG,  // mq_maxmsg
        LAA_MQ_MSGSIZE, // mq_msgsize
        0               // mq_curmsgs
    };

    s = mq_open(
        LAA_MQ_NAME, 
        LAA_MQ_FLAGS, // note use of MQ_FLAGS instead of MQ_OFLAGS
                      // since we are connecting, not opening 
        LAA_MQ_MODE,
        &queue_attributes
    );

    if (s == -1)
    {
        perror("Client Failed: mq_open. Is the Daemon process running?");
        exit(1);
    }
    
    std::cout << "Sending message to server: " << msg << std::endl;
    mq_send(s, msg, strlen(msg), 0);
    std::cout << "Message sent. Awaiting Acknowledgement.";
    // mq_receive(s, &buffer, LAA_MQ_MSGSIZE, pid);
}