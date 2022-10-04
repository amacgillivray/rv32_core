SHELL := /bin/sh
include ../../config.mk
.DEFAULT_GOAL := all
EXES := client request_unit
SRCS := client.cpp request_unit.cpp
OBJS := $(SRCS:.cpp=.o)

-include $(SRCS:.cpp=.d)

.PHONY: all
all : $(EXES)
	
client : client.o
	${CXX} ${CXXSTD} ${CXXEFLAGS} $^ -o $@

request_unit : request_unit.o ../request.o
	${CXX} ${CXXSTD} ${CXXEFLAGS} $^ -o $@

%.o : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@ $<

% : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@.o $<

.PHONY: clean
clean: 
	rm $(OBJS)
	rm $(EXES)
