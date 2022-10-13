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

// Todo - then update client to link to .so file during compilation
// compilation (daemon/tests/client.cpp)

namespace laa {
    inline bool request_execution(size_t executable_size);
    std::string generate_test_request();
}


#endif

