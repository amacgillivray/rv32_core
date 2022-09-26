#pragma once
#ifndef LAA_REQUEST
#define LAA_REQUEST

#include <cstdlib> 
#include <cstddef>
#include <sys/types.h>

#include <chrono>
#include <string>
#include <sstream>
#include <iomanip>

#include "json.hpp"

namespace laa {

class request
{
	
public:
	
	request( const char * json );
	
	request( const request& req );
	
	/** 
	 * @brief once at the top of the queue, daemon will check for shmem needs,
	 * 		  using this function. Returns 0 if no shmem is needed, or the 
	 *		  size of the shared memory segment the daemon should initialize.
	 */
	size_t required_shmem() const;

	std::string time_sent() const;

	std::string time_received() const;
	
	pid_t get_pid() const;
	
	short int get_type() const;
	
	// get the timing info as a string
	const char * get_timing_data();

	// Rebuilds the JSON string for this request and returns it.
	const char * get_json();

private:
	
	/**
	 * Parses a JSON string passed to the constructor.
	 */
	void parse( const char * json );
	
	// todo - internal function to write out times to csv file??
	
	struct timing { 
		std::chrono::_V2::system_clock::time_point sent; 
		std::chrono::_V2::system_clock::time_point received;
		// time_t processed bad name need to define stages; 
	};
	timing time;

	/* Process ID that originated the request */
	pid_t pid;
		
	// Probably best to create an enum for types 
	short int type;
	
	// set based on certain messa
	size_t required_shmem_length;
	
	laa::JsonPartial json;

}; 

} 

#endif
