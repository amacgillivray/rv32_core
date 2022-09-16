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
    
    // todo - create constants somewhere in a common / config file
    // since they will also need to be known by the user library/api
    
    queue_attributes = new mq_attr(
        O_NONBLOCK, // mq_flags
        10,         // mq_maxmsg
        64,         // mq_msgsize
        0           // mq_curmsgs
    );
    
    // TODO - same as above but for the mqueue name. Could also do for the 
    //  file permissions and option map
    queue = mq_open(
        "laa_daemon", 
        O_RDWR | O_CREAT | O_EXCL | O_NONBLOCK,
        600
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