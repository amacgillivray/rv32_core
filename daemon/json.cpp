#include "json.hpp"

laa::JsonPartial::JsonPartial():str("")
{
    
}

laa::JsonPartial::JsonPartial( const char * str ):str(str)
{
    map_json();
}

laa::JsonPartial::~JsonPartial()
{
    
}

void laa::JsonPartial::set_json_string( const char * str )
{
    this->str = str;
    json.clear();
    map_json();
}

const char * laa::JsonPartial::get_json_string() const
{
    return str;
}

const char * laa::JsonPartial::operator[](const char * key) const
{
    // todo - throw on invalid key? 
    //      decide
    
    // if (json.contains(key))
    // {
        return json[key];
    // } else {
    //     throw;
    // }
}

void laa::JsonPartial::map_json() {    
   size_t i = 0, s = 0, e = 0;
   size_t num_quot = 0;
   bool keypart = true; // rename to in_key
   // bool in_quote = false;;
   
   std::vector<std::string> keys;
   std::vector<std::string> values;

   std::string json = str;
   
   while( i < strlen(str) )
   {
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
       
       else if (str[i] == ':')
       {
           keypart = true;
       }
       
       else if (str[i] == ',' || str[i] == '}')
       {
           keypart = false;
       }
       
       i++;
   }
   
   for (size_t f = 0; f < keys.size(); f++) 
   {
       json.insert({keys.at(i).c_str(), values.at(i).c_str()}); 
   }
   return;
}