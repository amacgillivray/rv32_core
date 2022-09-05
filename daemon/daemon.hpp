#pragma once
#ifndef LA2_DAEMON
#define LA2_DAEMON 

#include <string>
#include <vector>

#include "virtual_core.hpp"

class LA2_Daemon {

public:

    struct request {
        // pid;
        // char user[32];
        // program binary;

        // for timing: 
        // request arrival time
        // job start time
        // request end time
        // could then write out stats for profiling the application later
        
        // todo: probably ought to be its own class
    };

    /**
     * @brief Construct a new la2 daemon object
     * @todo  Should initialize the sockets or queues needed for comms
     */
    LA2_Daemon();
    
    /**
     * @brief Destroy the la2 daemon object
     * @todo Should destroy any open sockets or queues.
     */
    ~LA2_Daemon();

    /**
     * @todo Calling this should start listening on the socket / queue and 
     *        begin a message-handling loop that does not end until the 
     *        current system is shut down.
     */
    void run();

private:

    /**
     * @brief Handles a new request
     * @todo  Should use the message to create a new request at the end of 
     *         the queued_jobs vector.
     */
    void handle_request();

    std::vector<LA2_Daemon::request> queued_jobs;


};

#endif 
