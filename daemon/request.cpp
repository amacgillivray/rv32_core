#include "request.hpp"

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