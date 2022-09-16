#pragma once
#ifndef LA2_VIRTUAL_CORE
#define LA2_VIRTUAL_CORE

#include <string>
#include <chrono>

// must track whether the core is active or idle
// Also tracks the process that requested the core, 
// the user that originated that process, 
// the time the job was started

// Functionality may be expanded soon
class LA2_Virtual_Core {

public:

    LA2_Virtual_Core();
    ~LA2_Virtual_Core();

private:

    /**
     * @brief Identifies the core.
     */
    int id;

    /**
     * @brief Tracks the active/idle state of the core.
     */
    bool active;


// todo - already starting to look like there is some overlap with the request struct in LA2_Daemon
// Maybe the request struct should also be standalone and passed between the objects?
    /**
     * @brief If a job is active, contains the ID of the process whose request
     *        is currently using the core.
     */
    std::string pid;

    /**
     * @brief If a job is active, contains the name of the user whose request
     *        is currently using the core.
     */
    std::string user;

    /**
     * @brief If a job is currently active, contains the time it began.
     */
    time_t job_start;

};

#endif