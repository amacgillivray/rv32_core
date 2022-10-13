SHELL := /bin/sh
include ../config.mk
.DEFAULT_GOAL := laa_api.so
SRCS := laa_api.cpp
OBJS := $(SRCS:.cpp=.o)

# get auto-generated dependencies
-include $(SRCS:.cpp=.d)

# because I have a habit of typing "make all"
.PHONY: all
all : laa_api.so
	
laa_api.so : $(OBJS)
	${CXX} ${CXXSTD} ${CXXEFLAGS} $^ -o $@ -shared

%.o : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@ $<

% : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@.o $<
	
# Remove object files and executables
.PHONY: clean
clean: 
	rm $(OBJS)
	rm laa_api.so
