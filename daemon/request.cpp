#include "request.h"

request::request(pide_t p, size_t l, time_t t)
{
	pid=p;
	length=l;
	time=t;
}
request::request(const request& req)
{
	pid=req.pid;
	length=req.length;
	time=req.time;
}
