#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include <memory>
#include <mqueue.h> 
#include <cstring>
#include <unistd.h>

#include "../laa_config.hpp"

int main()
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

    return (0);
}
