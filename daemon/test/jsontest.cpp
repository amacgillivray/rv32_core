#include <string>
#include <cstring>
#include <vector>
#include <stack>
#include <map>
#include <iostream>

void map_json( const char * str ) {    
    size_t i = 0, s = 0, e = 0;
    size_t num_quot = 0;
    bool in_quote = false;
    
    // Whether or not we have encountered a colon for the current line / item
    bool keypart = true;
    
    std::vector<std::string> keys;
    std::vector<std::string> values;

    std::string json = str;
    
    while( i < strlen(str) )
    {
        // HANDLE SINGLE QUOTE
        if (str[i] == '"')
        {
            if (num_quot == 0) {
                s = i+1;
                num_quot++;
            }
            else {
                e = i;
                num_quot = 0;
                if (keypart) {
                    keys.push_back(json.substr(s, e-s));
                } else {
                    values.push_back(json.substr(s, e-s));
                }
            }
        }
        
        if (str[i] == ':')
        {
            keypart = true;
        }
        
        if (str[i] == ',' || str[i] == '}')
        {
            keypart = false;
        }
        i++;
    }
    
    for (size_t f = 0; f < keys.size(); f++) 
    {
        std::cout << keys.at(f) << ": " << values.at(f) << std::endl;
    }
    return;
}

int main()
{
    const char * teststr = 
    "\
    {\
        \"pid\": \"12341\",\
        \"type\": \"1\",\
        \"msg\": \"request\",\
        \"time\": \"1663694039\"\
    }";
    
    map_json(teststr);
    
    return (0);
}