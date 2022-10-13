#include "daemon.hpp"
#include "request.hpp"
#include <vector>

laa::Daemon::Daemon()
{
    try {
        // mq_unlink(LAA_MQ_NAME);
        initialize_mqueue();
        // initialize_sock();
    } catch (std::runtime_error &e) {
        log_error( e.what() );
        log_error("Unable to initialize socket or queue. Aborting Daemon process.");
        exit(1); 
    }
}

laa::Daemon::~Daemon(){
    // need to close any open shmem, sockets, queues, etc
    destroy_mqueue();
}

void laa::Daemon::run()
{
    // listen to socket for new requests
    // receive_request()
    // when no new requests and idle, handle_request
    // later, add logging and 
    // std::cout << "Ran demon. Exiting." << std::endl;

    char * buff = new char [LAA_MQ_MSGSIZE]{"\0"};
    size_t bytes = 0;
    while(1)
    {
        bytes = mq_receive(queue, buff, LAA_MQ_MSGSIZE, 0);
        if (bytes>0)
        {
            // TODO - remove couts used for debugging

            std::cout << "Received Message:\n"
                      << buff << "\n";
            
            receive_request(buff);

            std::cout << "State after client sent message: \n" 
                      << get_debug_info()
                      << std::endl;

            std::cout << "Exiting." 
                      << std::endl;
            break;
        }
    }
    delete[] buff;
    return;
}

void laa::Daemon::test_msg( const char * str )
{
    receive_request(str);
}

std::string laa::Daemon::get_debug_info()
{
    std::string debug = "Jobs in Daemon Queue: " + std::to_string(queued_jobs.size()) + "\n";
    std::vector<laa::request> temp;
    while(queued_jobs.size()>0)
    {
        temp.emplace_back(queued_jobs.front());
        queued_jobs.pop();
    }
    for (size_t i = 0; i < queued_jobs.size(); i++)
    {
        debug.append("\tJob #" + std::to_string(i) + ": ");
        //  + std::string(queued_jobs[i].get_json()) + "\n");
        // show that we are accessing it as an object, by reading 
        // values from the request object itself instead of 
        // just printing the JSON string again
        debug.append("\n\t\tPID: " + std::to_string(temp[i].get_pid()));
        debug.append("\n\t\tType: " + std::to_string(temp[i].get_type()));
        debug.append("\n\t\tMessage: " + std::to_string(temp[i].required_shmem()));
        debug.append("\n\t\tTime Sent: " + temp[i].time_sent());
        debug.append("\n\t\tTime Received: " + temp[i].time_received());
    }
    while(temp.size()>0)
    {
        queued_jobs.emplace(temp.back());
        temp.pop_back();
    }

    return debug.c_str();
}

void laa::Daemon::receive_request( const char * str )
{
    // todo - if this is a one-liner, just put it in the run loop
    // instead of having it as its own function. 
    queued_jobs.emplace(str);
    
}

void laa::Daemon::handle_request()
{
    // handle the oldest request on the queue
    // todo 
}

void laa::Daemon::initialize_mqueue()
{
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
        perror(strerror(errno));
        delete queue_attributes;
        queue_attributes = nullptr; // avoid double free when destroy_mqueue is called
        throw std::runtime_error("Unable to open Daemon MQ.");
    }
    
    return;
}

void laa::Daemon::destroy_mqueue()
{
    mq_close(queue);
    mq_unlink(LAA_MQ_NAME);
    delete queue_attributes;
}

void laa::Daemon::initialize_sock() 
{
    // todo, if necessary
    // may actually use its own class
}

void laa::Daemon::log_error( std::string msg )
{
    std::cerr << msg;
    perror(strerror(errno));
}