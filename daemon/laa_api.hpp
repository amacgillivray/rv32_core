#ifndef LAA_API
#define LAAA_API

#include <chrono>
#include <string>
#include <string.h>
#include <sstream>
#include "json.cpp"
#include "laa_config.hpp"
#include <unistd.h>


using namespace std;

namespace laa {
    
    bool func(int size){
        bool dae_acc = false;

        // get the time
        const auto p1 = chrono::system_clock::now();
        int uni_time = chrono::duration_cast<chrono::milliseconds>(p1.time_since_epoch()).count();

        // compress information into a string
        ostringstream oss;
        oss << "{\"pid\": " << getpid() << " \n\"type\": 1 \n\"msg\": " << &size << " \n\"time\": " << uni_time << "}";
        string json_content = oss.str();
        const char *content_mk2 = json_content.c_str();

        // create the json
        JsonPartial json;

        json.set_json_string(content_mk2);


        // open queue named in laa_config and send the json to it


        // change dae_acc to true if the json is accepted by the daemon


        return dae_acc;
    }

    
}


#endif

