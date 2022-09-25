#pragma once
#ifndef LA2_DAEMON
#define LA2_DAEMON 

#ifndef LA2_DAEMON_LOGFILE
#define LA2_DAEMON_LOGFILE "daemon_log.txt"
#endif

#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include <memory>
#include <mqueue.h> // using sysv message queues to reply to clients

#include <sys/socket.h>

#include "laa_config.hpp"
#include "request.hpp"
#include "virtual_core.hpp"

namespace laa {

class Daemon {

public:

    /**
     * @brief Construct a new la2 daemon object
     * @todo  Should initialize the sockets or queues needed for comms
     */
    Daemon();
    
    /**
     * @brief Destroy the la2 daemon object
     * @todo Should destroy any open sockets or queues.
     */
    ~Daemon();

    /**
     * @todo Calling this should start listening on the socket / queue and 
     *        begin a message-handling loop that does not end until the 
     *        current system is shut down.
     */
    void run();
    
    /**
     * @brief Shows how the daemon would handle the provided request. For testing.
     *
     * @details
     * Allows a custom message to be handled as if it was just read from an 
     * IPC channel. Forwards the given string to the internal receive_request()
     * method.
     */
    void test_msg( const char * str );

    /** 
     * @brief Creates a string containing debugging information of the Daemon object 
     *        at a given time, and returns it. Used to reduce the need of debugging 
     *        statements throughout other functions / complex GDB debugging.
     */
    std::string get_debug_info();

private:

    /**
     * @brief Receives a new request
     * @todo  Should use the message to create a new request at the end of 
     *         the queued_jobs vector.
     */
    void receive_request( const char * str = "" );
    
    /** 
     * @brief Handles the request that is next in line for execution
     */ 
    void handle_request();

    std::vector<laa::request> queued_jobs;
    mqd_t queue;
    mq_attr * queue_attributes;

private: // Private Helpers
    void initialize_mqueue(); 
    void initialize_sock();
    void log_error( std::string msg );
    
};

}

#endif 
