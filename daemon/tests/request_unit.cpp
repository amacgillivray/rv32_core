#include <iostream>
#include <vector>
#include <string>
#include "../request.hpp"
#include "../laa_api.hpp"

void test_requests();

int main()
{   
    test_requests();
    return (0);
}

void test_requests()
{  
    const size_t gen = 5;
    std::vector<std::string> request_strings;
    for (size_t i = 0; i < gen; i++)
        request_strings.push_back(laa::generate_test_request());
    
    // Initializes a request, then moves it with the move constructor
    laa::request a;
    a.set(request_strings.at(0).data());
    std::cout << "A Json: " << a.get_json() << std::endl;
    laa::request b(std::move(a)); 
    std::cout << "B Json: " << b.get_json() << std::endl;

    // Change B's json
    b.set(request_strings[1].data());
    std::cout << "Altered B Json: " << b.get_json() << std::endl;
    a = std::move(b);
    std::cout << "A Json from B: " << a.get_json() << std::endl;
    
    // TEST COPY CONSTRUCTOR 
    laa::request c{};
    c.set(request_strings[2].data());
    laa::request d(c);
    std::cout << "D Json from C: " << d.get_json() << std::endl; 
    
    // TEST COPY ASSIGNMENT
    laa::request e{};
    laa::request f{};
    e.set(request_strings[3].data());
    f = e;
    std::cout << "F Json from E: " << f.get_json() << std::endl;

    return;
}
