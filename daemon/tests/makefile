SHELL := /bin/sh
include ../../config.mk
.DEFAULT_GOAL := client
EXES := client
SRCS := client.cpp
OBJS := $(SRCS:.cpp=.o)

-include $(SRCS:.cpp=.d)

.PHONY: all
all : $(EXES)
	
client : $(OBJS)
	${CXX} ${CXXSTD} ${CXXEFLAGS} $^ -o $@

%.o : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@ $<

.PHONY: clean
clean: 
	rm $(OBJS)
	rm $(EXES)
