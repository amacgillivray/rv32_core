#include <iostream>
#include "daemon.hpp"

int main()
{
    std::cout << "Starting Daemon Process" << std::endl;
    const char * teststr = 
    "\
    {\
        \"pid\": \"12341\",\
        \"type\": \"1\",\
        \"msg\": \"request\",\
        \"time\": \"1663694039\"\
    }";
    
    laa::Daemon daemon;
    std::cout << "Testing Message:\n"
              << teststr << std::endl;
    daemon.test_msg(teststr);
    std::cout << "\nDaemon State after receiving message: \n";
    std::cout << daemon.get_debug_info() << std::endl;

    daemon.run();
    return (0);
}