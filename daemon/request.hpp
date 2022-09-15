#ifndef REQUEST_HPP
#define REQUEST_HPP

#include<iostream>
class request
{
	private:
	pid_t pid;
	size_t length;
	time_t time;

	public:
	request(pid_t p, size_t l, time_t t);
	request(const request& req);
}
#endif
