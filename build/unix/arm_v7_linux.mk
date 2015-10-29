##
## ARMHF V7 tested on 
## - pcDUINO board - UBUNTU based
## - BeagleBone Black - Angstrom based
## - Cubieboard 2 - Debian based
##
## To improve the build speed in small systems disable -pedantic
## switch in CXXFLAGS
##
TargetCPU  :=arm_v7
OS         :=linux
CXXFLAGS   := -O3 -g -fPIC -mword-relocations -pedantic

# Standard part

include common.mk

