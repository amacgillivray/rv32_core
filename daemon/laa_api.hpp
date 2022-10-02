#pragma once
#ifndef LAA_API
#define LAA_API

#include <chrono>
#include <string>
#include <string.h>
#include <sstream>
#include <unistd.h>
#include <mqueue.h> 

#include "laa_config.hpp"

// Todo - move to a folder other than daemon, 
// compile to a .so or .a file -- then update client to link that during
// compilation (tests/client.cpp)

namespace laa {
    // todo - remove inline, use separate .h / .cpp 
    // after writing makefile rule to compile to an archive or shared object
    inline bool request_execution(size_t executable_size);
}

bool laa::request_execution(size_t executable_size)
{
    // todo: 
    // bool dae_acc = false;
    mqd_t s; // server

    mq_attr queue_attributes{
        LAA_MQ_FLAGS,   // mq_flags
        LAA_MQ_MAXMSG,  // mq_maxmsg
        LAA_MQ_MSGSIZE, // mq_msgsize
        0               // mq_curmsgs
    };

    // get the time
    const auto p1 = std::chrono::system_clock::now();
    int uni_time = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();

    // put information into a JSON string
    std::ostringstream oss;
    oss << "{ \"pid\": \"" << getpid() << "\"," 
        << " \n\"type\": \"1\"," 
        << " \n\"msg\": \"" << executable_size << "\","
        << " \n\"time\": \"" << uni_time << "\" }";
    std::string msg = oss.str();

    // pad to max msg size
    msg.append( LAA_MQ_MSGSIZE - msg.length(), ' ');

    // open queue named in laa_config and send the json to it
    s = mq_open(
        LAA_MQ_NAME, 
        LAA_MQ_FLAGS,
        LAA_MQ_MODE,
        &queue_attributes
    );

    if (s == -1)
    {
        perror("Client Failed: mq_open. Is the Daemon process running?");
        exit(1);
    }

    int sent = mq_send(s, msg.c_str(), msg.length()-1, 0);

    // if not 0, then errno has the error from mq_send
    return (sent == 0);
}

#endif

