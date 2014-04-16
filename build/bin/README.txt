These folders will contain binary libraries generated from project/makefiles in unix, osx and windows.

Unix OS target is the same of which your are running the compiler.
Example : if you run "make -f i386_linux.mk all" under Ubuntu 13.10, you will find in bin/i386-linux a library that can run into Ubuntu 13.10 and in all OS derivative of Ubuntu that have the same LIBC release (one of them is LinuxMint 15).

For windows, release\WinXX and bin\WinXX contains the same files.

