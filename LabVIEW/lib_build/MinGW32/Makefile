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
TEMP     =../../lib_tmp
OBJ      = $(TEMP)/win32/lv_snap7.o
LINKOBJ  = $(TEMP)/win32/lv_snap7.o
LIBS     = -L"$(MINGW)/lib" -static-libgcc --no-export-all-symbols --add-stdcall-alias $(MINGW)/lib/gcc/mingw32/$(MINREL)/libstdc++.a ../../../release/windows/win32/snap7.lib
CXXINCS  = -I"$(MINGW)/include"
OUTPATH  = ../../lib/win32/
DLL      = lv_snap7.dll
OUTLIB   = $(TEMP)/lv_snap7.lib
BIN      = $(OUTPATH)$(DLL)
CXXFLAGS = $(CXXINCS) -DBUILDING_DLL=1 -Ofast -pedantic
RM       = rm -f

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

DLLWRAP=dllwrap.exe
DLLTOOL=dlltool.exe
DEFFILE=$(OUTPATH)lv_snap7.def

clean: clean-custom
	${RM} $(OBJ) $(BIN) $(OUTLIB) $(DEFFILE)

$(BIN): $(LINKOBJ)
	$(DLLWRAP) --output-def $(DEFFILE) --driver-name c++ $(LINKOBJ) $(LIBS) -o $(BIN)

$(TEMP)/win32/lv_snap7.o: ../../lib_src/lv_snap7.cpp
	$(CPP) -c ../../lib_src/lv_snap7.cpp -o $(TEMP)/win32/lv_snap7.o $(CXXFLAGS)

all-after:
	$(DLLTOOL) -D $(DLL) -d $(DEFFILE) -l $(OUTLIB)
	
	
	
