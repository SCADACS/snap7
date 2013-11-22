##
## i386 BSD based (FreeBSD etc.) Makefile
## Use gmake instead of make
##
TargetCPU  :=i386
OS         :=bsd
CXXFLAGS   := -O3 -fPIC -pedantic 

# Standard part

include common.mk

