#ifndef LAA_JSON
#define LAA_JSON

#include <cstring>
#include <string>
#include <vector>
#include <stack>
#include <map>

#include <iostream>

namespace laa {
    
/**
 * @brief Supports reading a string based on a subset of normal JSON syntax.
 *        Only supports 1 level of KV pairs where everything is a string.
 * @note  May be moved to within the Request class since that is the only place it will likely be used,
 *        and since it does not support (nor need to support) the full JSON syntax. 
 * @todo give more semantic name (JsonParser) to better indicate purpose
 */
class JsonPartial {

public:
    
    JsonPartial();
    
    /**
     * @brief Calls set_json_string with the given string in the constructor
     */
    JsonPartial( const char * str );
    
    ~JsonPartial();
    
    /**
     * @brief Set or change the JSON string contained by this object. 
     *        Deletes all old contents, then parses the new string.
     */
    void set_json_string( const char * str );

    /**
     * @brief Returns the string that was parsed by this object.
     */
    const char * get_json_string() const;
    
    /**
     * @brief Allow reading the value of a mapped key-value pair
     *        by specifying the name of the key as a string.
     * @throw std::out_of_range if the key does not exist. 
     */
    const char * operator[](const std::string & key) const;
    
private: 
    
    /**
     * @brief Reads the JSON string and writes all key-value pairs to the 
     *      std::map object. 
     */
    void map_json();
    
    /* The JSON string */
    std::string str;

    /* Map of the JSON key-value pairs, accessible (non-mutable) with [] operator */
    std::map<std::string, std::string> json;
};
    
}


#endif /* end of include guard: LAA_JSON */
