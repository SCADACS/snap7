##
## i386 OSX based Makefile
## Tested with OSX 10.9 Mavericks
##
TargetCPU  :=i386
OS         :=osx
CXXFLAGS   := -O3 -fPIC -pedantic 

# Standard part

include common.mk
