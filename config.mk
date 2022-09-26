export SHELL := /bin/sh

export rootdir := $(abspath $(CURDIR)/..)/
export bindir := $(rootdir)bin/
export libdir := $(rootdir)lib/
export MAKE := make
export OBJECT_MODE := 32_64
export RM := rm -f
export MKDIR := mkdir
export AR := ar
export ARFLAGS = rcs
export CXX := g++
export CXXSTD := -std=c++17
export CXXDBG := -g3
export CXXFLST := -fstrict-enums \
                  -ftabstop=4
export CXXWARN := -Wall \
				  -Wextra \
				  -pedantic \
				  -Wcast-align \
				  -Wcast-qual \
				  -Wctor-dtor-privacy \
				  -Wdisabled-optimization \
				  -Wextra-semi \
				  -Wfloat-equal \
				  -Wformat=2 \
				  -Wformat-nonliteral \
				  -Winit-self \
				  -Wlogical-op \
				  -Wmissing-declarations \
				  -Wmissing-include-dirs \
				  -Wnoexcept \
				  -Wnoexcept-type \
				  -Wno-unused-parameter \
				  -Wold-style-cast \
				  -Woverloaded-virtual \
				  -Wpointer-arith \
				  -Wredundant-decls \
				  -Wsuggest-final-types \
				  -Wsuggest-final-methods \
				  -Wsuggest-override \
				  -Wundef \
				  -Wunused \
				  -Wuseless-cast \
				  -Wwrite-strings
export CXXFLAGS += $(CXXFLST) \
                   $(CXXWARN) \
                   $(CXXDBG) \
                   -O2 \
                   -DLAA_ROOTDIR=\"$(rootdir)\"
export CXXEFLAGS = $(CXXFLAGS) -fpie
export CXXOFLAGS = $(CXXFLAGS) -MD -MP -fpic