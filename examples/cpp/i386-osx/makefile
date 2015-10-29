##
## OSX barebone makefile for c++ examples : Tested with OSX 10.9 Mavericks
##
## Simply run make or make clean
##
## Intend this makefile only as a "batch examples updater" after library modification.
##

Libs     := -lsnap7 
Wrapper  :=snap7.cpp

CXX      := g++
CC       := gcc
CXXFLAGS :=-O3
CFLAGS   :=

.PHONY: all clean

all: 
	$(CXX) $(CXXFLAGS) -o client ../client.cpp ../$(Wrapper) $(Libs) 
	$(CXX) $(CXXFLAGS) -o server ../server.cpp ../$(Wrapper) $(Libs) 
	$(CXX) $(CXXFLAGS) -o srv_resourceless ../srv_resourceless.cpp ../$(Wrapper) $(Libs) 
	$(CXX) $(CXXFLAGS) -o apartner ../apartner.cpp ../$(Wrapper) $(Libs) 
	$(CXX) $(CXXFLAGS) -o ppartner ../ppartner.cpp ../$(Wrapper) $(Libs) 

clean:
	$(RM) client
	$(RM) server
	$(RM) srv_resourceless
	$(RM) apartner
	$(RM) ppartner
