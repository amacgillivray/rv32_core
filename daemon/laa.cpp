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
    daemon.test_msg(teststr);
    daemon.run();
    return (0);
}