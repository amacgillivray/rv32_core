#pragma once
#ifndef LAA_REQUEST
#define LAA_REQUEST

#include <cstdlib> 
#include <cstddef>
#include <cstring>
#include <sys/types.h>

#include <chrono>
#include <string>
#include <sstream>
#include <iomanip>
#include <map>

namespace laa {

class request
{

private: 

	/**
	* @class request::JsonParser
	* @brief Supports reading a string based on a subset of normal JSON syntax.
	*        Only supports 1 level of KV pairs where everything is a string.
	* @note  Internal as it only supports a subset of JSON syntax, as needed 
	* 	     to parse requests.
	*/
	class JsonParser {

	public:
		
		JsonParser();
		
		/**
		* @brief Calls set_json_string with the given string in the constructor
		*/
		JsonParser( const char * str );
		
		~JsonParser();
		
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

public:
	
	request();

	// The same as initializing and then calling set(json)
	request( const char * json );
	
	// Copy Constructor 
	request( const request& rhs );

	// Move Constructor
	request( request && rhs );

	// Copy Assignment
	request& operator=( const request & rhs );

	// Move Assignment
	request& operator=( request && rhs );

	/**
	 * @brief Interprets the given JSON string and uses it to set all values.
	 */
	void set( const char * json );

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
	
	JsonParser json;

}; 

} 

#endif
