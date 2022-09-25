#include "daemon.hpp"

laa::Daemon::Daemon()
{
    try {
        initialize_mqueue();
        initialize_sock();
    } catch (std::runtime_error &e) {
        log_error( e.what() );
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
    // listen to socket for new requests
    // receive_request()
    // when no new requests and idle, handle_request
    // later, add logging and 
    std::cout << "Ran demon. Exiting." << std::endl;
    return;
}

void laa::Daemon::test_msg( const char * str )
{
    receive_request(str);
}

std::string laa::Daemon::get_debug_info()
{
    std::string debug = "Jobs in Daemon Queue: " + std::to_string(queued_jobs.size()) + "\n";
    for (size_t i = 0; i < queued_jobs.size(); i++)
    {
        debug.append("\tJob #" + std::to_string(i) + ": " + std::string(queued_jobs[i].get_json()) + "\n");
    }
    return debug.c_str();
}

void laa::Daemon::receive_request( const char * str )
{
    // todo: if str not given, get it from the socket 
    // initialize the request in the vector for later handling.
    queued_jobs.emplace_back(str);
}

void laa::Daemon::handle_request()
{
    // handle the oldest request on the queue
}

void laa::Daemon::initialize_mqueue()
{
    // int saved_error; 
    
    queue_attributes = new mq_attr{
        LAA_MQ_FLAGS,   // mq_flags
        LAA_MQ_MAXMSG,  // mq_maxmsg
        LAA_MQ_MSGSIZE, // mq_msgsize
        0               // mq_curmsgs
    };

    queue = mq_open(
        LAA_MQ_NAME, 
        LAA_MQ_OFLAG,
        LAA_MQ_MODE,
        queue_attributes
    );
    
    if (queue == (-1))
    {
        // saved_error = errno;
        delete queue_attributes;
        throw std::runtime_error("Unable to open Daemon MQ.");
    }
    
    return;
}

void laa::Daemon::initialize_sock() 
{
    
}

void laa::Daemon::log_error( std::string msg )
{
    // todo
}