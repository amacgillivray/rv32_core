#include <iostream>
#include "daemon.hpp"

int main()
{

    std::cout << "Starting Daemon Process" << std::endl;
    laa::Daemon daemon;
    std::cout << "\nDaemon State after start: \n";
    std::cout << daemon.get_debug_info() << std::endl;

    daemon.run();
    return (0);
}