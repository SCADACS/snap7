#               
# MinGW 32 makefile
#
# Change vars MINGW and MINREL in accord to your compiler path/release
#                
MINGW    =C:/MinGW32
MINREL   =4.7.2
#
#
CPP      = g++.exe
CC       = gcc.exe
TEMP     =../../temp
OBJ      = $(TEMP)/win32/snap_msgsock.o $(TEMP)/win32/snap_sysutils.o $(TEMP)/win32/snap_tcpsrvr.o $(TEMP)/win32/snap_threads.o $(TEMP)/win32/s7_client.o $(TEMP)/win32/s7_isotcp.o $(TEMP)/win32/s7_micro_client.o $(TEMP)/win32/s7_partner.o $(TEMP)/win32/s7_peer.o $(TEMP)/win32/s7_server.o $(TEMP)/win32/s7_text.o $(TEMP)/win32/snap7_libmain.o
LINKOBJ  = $(TEMP)/win32/snap_msgsock.o $(TEMP)/win32/snap_sysutils.o $(TEMP)/win32/snap_tcpsrvr.o $(TEMP)/win32/snap_threads.o $(TEMP)/win32/s7_client.o $(TEMP)/win32/s7_isotcp.o $(TEMP)/win32/s7_micro_client.o $(TEMP)/win32/s7_partner.o $(TEMP)/win32/s7_peer.o $(TEMP)/win32/s7_server.o $(TEMP)/win32/s7_text.o $(TEMP)/win32/snap7_libmain.o
LIBS     = -L"$(MINGW)/lib" -static-libgcc --no-export-all-symbols --add-stdcall-alias $(MINGW)/lib/libws2_32.a $(MINGW)/lib/libwinmm.a $(MINGW)/lib/gcc/mingw32/$(MINREL)/libstdc++.a 
INCS     = -I"$(MINGW)/include" -I"../../../src/sys" -I"../../../src/core" -I"../../../src/lib"
CXXINCS  = -I"$(MINGW)/include" -I"../../../src/sys" -I"../../../src/core" -I"../../../src/lib"
OUTPATH  = ../../bin/Legacy/win32/
DLL      = snap7.dll
OUTLIB   = $(OUTPATH)snap7.lib
BIN      = $(OUTPATH)$(DLL)
CXXFLAGS = $(CXXINCS) -DBUILDING_DLL=1 -Ofast -pedantic
CFLAGS   = $(INCS) -DBUILDING_DLL=1
RM       = rm -f

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

DLLWRAP=dllwrap.exe
DLLTOOL=dlltool.exe
DEFFILE=$(OUTPATH)snap7.def

clean: clean-custom
	${RM} $(OBJ) $(BIN) $(OUTLIB) $(DEFFILE)

$(BIN): $(LINKOBJ)
	$(DLLWRAP) --output-def $(DEFFILE) --driver-name c++ $(LINKOBJ) $(LIBS) -o $(BIN)

$(TEMP)/win32/snap_msgsock.o: ../../../src/sys/snap_msgsock.cpp
	$(CPP) -c ../../../src/sys/snap_msgsock.cpp -o $(TEMP)/win32/snap_msgsock.o $(CXXFLAGS)

$(TEMP)/win32/snap_sysutils.o: ../../../src/sys/snap_sysutils.cpp
	$(CPP) -c ../../../src/sys/snap_sysutils.cpp -o $(TEMP)/win32/snap_sysutils.o $(CXXFLAGS)

$(TEMP)/win32/snap_tcpsrvr.o: ../../../src/sys/snap_tcpsrvr.cpp
	$(CPP) -c ../../../src/sys/snap_tcpsrvr.cpp -o $(TEMP)/win32/snap_tcpsrvr.o $(CXXFLAGS)

$(TEMP)/win32/snap_threads.o: ../../../src/sys/snap_threads.cpp
	$(CPP) -c ../../../src/sys/snap_threads.cpp -o $(TEMP)/win32/snap_threads.o $(CXXFLAGS)

$(TEMP)/win32/s7_client.o: ../../../src/core/s7_client.cpp
	$(CPP) -c ../../../src/core/s7_client.cpp -o $(TEMP)/win32/s7_client.o $(CXXFLAGS)

$(TEMP)/win32/s7_isotcp.o: ../../../src/core/s7_isotcp.cpp
	$(CPP) -c ../../../src/core/s7_isotcp.cpp -o $(TEMP)/win32/s7_isotcp.o $(CXXFLAGS)

$(TEMP)/win32/s7_micro_client.o: ../../../src/core/s7_micro_client.cpp
	$(CPP) -c ../../../src/core/s7_micro_client.cpp -o $(TEMP)/win32/s7_micro_client.o $(CXXFLAGS)

$(TEMP)/win32/s7_partner.o: ../../../src/core/s7_partner.cpp
	$(CPP) -c ../../../src/core/s7_partner.cpp -o $(TEMP)/win32/s7_partner.o $(CXXFLAGS)

$(TEMP)/win32/s7_peer.o: ../../../src/core/s7_peer.cpp
	$(CPP) -c ../../../src/core/s7_peer.cpp -o $(TEMP)/win32/s7_peer.o $(CXXFLAGS)

$(TEMP)/win32/s7_server.o: ../../../src/core/s7_server.cpp
	$(CPP) -c ../../../src/core/s7_server.cpp -o $(TEMP)/win32/s7_server.o $(CXXFLAGS)

$(TEMP)/win32/s7_text.o: ../../../src/core/s7_text.cpp
	$(CPP) -c ../../../src/core/s7_text.cpp -o $(TEMP)/win32/s7_text.o $(CXXFLAGS)

$(TEMP)/win32/snap7_libmain.o: ../../../src/lib/snap7_libmain.cpp
	$(CPP) -c ../../../src/lib/snap7_libmain.cpp -o $(TEMP)/win32/snap7_libmain.o $(CXXFLAGS)
	
all-after:
	$(DLLTOOL) -D $(DLL) -d $(DEFFILE) -l $(OUTLIB)
	
	
	
