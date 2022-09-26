#include "json.hpp"

laa::JsonPartial::JsonPartial() : str("")
{
}

laa::JsonPartial::JsonPartial(const char *str) : str(str)
{
    map_json();
}

laa::JsonPartial::~JsonPartial()
{
}

void laa::JsonPartial::set_json_string(const char *str)
{
    this->str.assign(str);
    json.clear();
    map_json();
}

const char *laa::JsonPartial::get_json_string() const
{
    return str.c_str();
}

const char *laa::JsonPartial::operator[](const std::string &key) const
{
    return json.at(key).c_str();
}

void laa::JsonPartial::map_json()
{
    size_t i = 0, s = 0, e = 0;
    size_t num_quot = 0;
    bool in_key = true;
    std::string key = "";
    std::string val = "";
    std::string buf = "";

    // Parse the JSON string looking for keys and values
    while (i < strlen(str.data()))
    {

        if (str[i] == '"')
        {
            if (num_quot == 0)
            {
                s = i + 1;
                num_quot++;
            }
            else
            {
                e = i;
                num_quot = 0;
                buf = str.substr(s, e - s);
                if (in_key)
                    key = buf;
                else
                {
                    val = buf;
                    // Insert the key-value pair to the map
                    // since here we have both the key and value
                    json.insert({key, val});
                    key.clear();
                    val.clear();
                }
            }
        }
        // If we hit the ":" char, we're in the value-side of the line
        // If we hit an end-line marker (, or }), then we expect the 
        // string to end or the next quotes to contain a key. 
        else if (str[i] == ':')
            in_key = false;
        else if (str[i] == ',' || str[i] == '}')
            in_key = true;

        i++;
    }
    return;
}
