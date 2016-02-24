##
## x86_64 Linux based (Debian/Ubuntu/Red Hat/Slackware etc.) Makefile
## Use make
##
TargetCPU  :=x86_64
OS         :=linux
CXXFLAGS   := -std=c++11 -fdiagnostics-color -O3 -fPIC -pedantic

# Standard part

include common.mk

