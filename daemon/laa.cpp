#include <iostream>
#include "daemon.hpp"

int main()
{
    std::cout << "Starting Daemon Process" << std::endl;
    laa::Daemon daemon;
    daemon.run();
    return (0);
}