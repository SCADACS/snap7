##
## OSX barebone makefile for c examples : Tested with OSX 10.9 Mavericks
##
## Simply run make or make clean
##
## Intend this makefile only as a "batch examples updater" after library modification.
##

Libs     := -lsnap7 

CXX      := g++
CC       := gcc
CXXFLAGS :=-O3
CFLAGS   :=

.PHONY: all clean

all: 
	$(CC) $(CFLAGS) -o client ../client.c $(Libs) 
	$(CC) $(CFLAGS) -o server ../server.c $(Libs) 
	$(CC) $(CFLAGS) -o srv_resourceless ../serv_resourceless.c $(Libs) 
	$(CC) $(CFLAGS) -o apartner ../apartner.c $(Libs) 
	$(CC) $(CFLAGS) -o ppartner ../ppartner.c $(Libs) 

clean:
	$(RM) client
	$(RM) server
	$(RM) srv_resourceless
	$(RM) apartner
	$(RM) ppartner
