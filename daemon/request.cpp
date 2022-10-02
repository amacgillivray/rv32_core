#include "request.hpp"
#include <chrono>

laa::request::request(const char * json)
{
	parse(json);
	
	// time received isn't sent by the client, but 
	// determined here after we have parsed their message.
	time.received = std::chrono::system_clock::now();
}

laa::request::request(const request& req)
{
	pid=req.pid;
	required_shmem_length=req.required_shmem_length;
	time=req.time;
	type=req.type;
}

size_t laa::request::required_shmem() const 
{
	return required_shmem_length;
}

pid_t laa::request::get_pid() const 
{
	return pid;
}

short int laa::request::get_type() const
{
	return type;
}

std::string laa::request::time_sent() const 
{
	std::stringstream ss;
	// need lvalue for tm, need tm for put time
	std::time_t ts = std::chrono::_V2::system_clock::to_time_t(time.sent);
	std::tm tm = *std::gmtime(&ts);
	ss << std::put_time( &tm, "%Y-%m-%d %H:%M:%S");
	return ss.str();
}

std::string laa::request::time_received() const
{
	std::stringstream ss;
	// need lvalue for tm, need tm for put time
	std::time_t tr = std::chrono::_V2::system_clock::to_time_t(time.received);
	std::tm tm = *std::gmtime(&tr);
	ss << std::put_time( &tm, "%Y-%m-%d %H:%M:%S");
	return ss.str();
}

const char * laa::request::get_timing_data()
{
	return "todo: request::get_timing_data not yet implemented.";
	// create csv-fmt string with the timing info 
}

void laa::request::parse( const char * json )
{
	this->json.set_json_string(json);
	pid = atol(this->json["pid"]);
	type = atoi(this->json["type"]);
	required_shmem_length = atoll(this->json["msg"]);
	time.sent = std::chrono::system_clock::from_time_t(strtol(this->json["time"],NULL,10));
	
	// todo - define a list of valid message types somewhere 
	// that we can use to determine what the format of "msg" is
	// for now, blindly assume that the type is a standard request
	// and treat message as the # of bytes of shmem needed

	// should also define these somewhere for both here and user lib?
	// const char [] words = [
	// 	"pid", // process id
	// 	"type", // request type
	// 	"msg", // message, if any
	// 	"ts" // time sent
	// ];
}

const char * laa::request::get_json()
{
	return json.get_json_string();
}


// ----------------------
// JSON Parser
// ----------------------

laa::request::JsonParser::JsonParser() : str("")
{
}

laa::request::JsonParser::JsonParser(const char *str) : str(str)
{
    map_json();
}

laa::request::JsonParser::~JsonParser()
{
}

void laa::request::JsonParser::set_json_string(const char *str)
{
    this->str.assign(str);
    json.clear();
    map_json();
}

const char *laa::request::JsonParser::get_json_string() const
{
    return str.c_str();
}

const char *laa::request::JsonParser::operator[](const std::string &key) const
{
    return json.at(key).c_str();
}

void laa::request::JsonParser::map_json()
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
