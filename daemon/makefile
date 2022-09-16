SHELL := /bin/sh
include ../config.mk
.DEFAULT_GOAL := laa
EXES := laa
SRCS := laa.cpp daemon.cpp request.cpp
OBJS := $(SRCS:.cpp=.o)

# get auto-generated dependencies
-include $(SRCS:.cpp=.d)

# because I have a habit of typing "make all"
.PHONY: all
all : $(EXES)
	
laa : $(OBJS)
	${CXX} ${CXXSTD} ${CXXEFLAGS} $^ -o $@

%.o : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@ $<

% : %.cpp
	${CXX} ${CXXSTD} -c ${CXXOFLAGS} -o $@.o $<
	
# Remove object files and executables
.PHONY: clean
clean: 
	rm $(OBJS)
	rm $(EXES)
