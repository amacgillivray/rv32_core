#include "request.h"

laa::request::request(const char * json)
{
	// read json and set
	// time sent
	// pid 
	// type
	// required shmem length
	
	// then set time_received based on current time
}

laa::request::request(const request& req)
{
	pid=req.pid;
	length=req.required_shmem_length;
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

const char * get_timing_data( const char * outfile )
{
	// create csv-fmt string with the timing info 
}
