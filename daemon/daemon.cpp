#include "daemon.hpp"

laa::Daemon::Daemon()
{
    try {
        initialize_mqueue();
        initialize_sock();
    } catch (std::runtime_error &e) {
        log_error(e.message);
        log_error("Unable to initialize socket or queue. Aborting Daemon process.");
        exit(1); 
    }
}

laa::Daemon::~Daemon(){
    // need to close any open shmem, sockets, queues, etc
    delete queue_attributes;
}

void laa::Daemon::run()
{
    
}

void laa::Daemon::initialize_mqueue()
{
    int saved_error; 
    
    queue_attributes = new mq_attr(
        LAA_MQ_FLAGS,   // mq_flags
        LAA_MQ_MAXMSG,  // mq_maxmsg
        LAA_MQ_MSGSIZE, // mq_msgsize
        0               // mq_curmsgs
    );

    queue = mq_open(
        LAA_MQ_NAME, 
        LAA_MQ_OFLAG,
        LAA_MQ_MODE
        queue_attributes
    );
    
    if (queue == (mqd_t)(-1))
    {
        saved_error = errno; 
        delete queue_attributes;
        throw std::runtime_error("Unable to open Daemon MQ.");
    }
    
    return;
}

void laa::Daemon::initialize_sock() 
{
    
}