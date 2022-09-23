#ifndef LAA_JSON
#define LAA_JSON

#include <cstring>
#include <string>
#include <vector>
#include <stack>
#include <map>

namespace laa {
    
/**
 * @brief Supports reading a string based on a subset of normal JSON syntax.
 *        Only supports 1 level of KV pairs where everything is a string.
 * @note  May be moved to within the Request class since that is the only place it will likely be used,
 *        and since it does not support (nor need to support) the full JSON syntax.
 */
class JsonPartial {

public:
    
    JsonPartial();
    
    JsonPartial( const char * str );
    
    ~JsonPartial();
    
    void set_json_string( const char * str );
    
    const char * get_json_string() const;
    
    /**
     * @brief Allow reading the value of a mapped key-value pair
     *        by specifying the name of the key as a string. 
     */
    const char * operator[](const char * key) const;
    
private: 
    
    /**
     * @brief Reads the JSON string and writes all key-value pairs to the 
     *      std::map object. 
     */
    void map_json();
    
    const char * str;
    std::map<const char *, const char *> json;
};
    
}


#endif /* end of include guard: LAA_JSON */
