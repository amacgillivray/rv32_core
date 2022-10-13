#pragma once
#ifndef LAA_API
#define LAA_API

#include <chrono>
#include <string>
#include <string.h>
#include <sstream>
#include <unistd.h>
#include <mqueue.h> 
#include <cmath>
#include <random>

#include "../daemon/laa_config.hpp"

// Todo - move to a folder other than daemon, 
// compile to a .so or .a file -- then update client to link that during
// compilation (tests/client.cpp)

namespace laa {
    // todo - remove inline, use separate .h / .cpp 
    // after writing makefile rule to compile to an archive or shared object
    inline bool request_execution(size_t executable_size);
    std::string generate_test_request();
}


#endif

