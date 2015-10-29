************************************************************************
The Demo programs and snap7 classes are fully compatible with Mono 2.10.
************************************************************************

In Windows, run dotnet.bat inside the visual studio (or sdk) prompt which sets path and other environment variables. 
You can find it in "Microsoft Visual Studio XXX -> Visual studio tool. 

In Unix (whatever flavour) run .\mono.sh

Optionally you can add the switch /platform:<string> in the bach file.

Notes from MSDN:

  <string> = x86, Itanium, x64, or anycpu (default).

Remarks

- x86 compiles your assembly to be run by the 32-bit, x86-compatible common language runtime.
- Itanium compiles your assembly to be run by the 64-bit common language runtime on a computer with an Itanium processor.
- x64 compiles your assembly to be run by the 64-bit common language runtime on a computer that supports the AMD64 or EM64T instruction set.
- anycpu (default) compiles your assembly to run on any platform.

On a 64-bit Windows operating system:

- Assemblies compiled with /platform:x86 will execute on the 32 bit CLR running under WOW64.
- Executables compiled with the /platform:anycpu will execute on the 64 bit CLR.
- DLLs compiled with the /platform:anycpu will execute on the same CLR as the process into which it is being loaded.


Finally, to run these demos you need the correct binary library (libsnap7.so or snap7.dll) either 32 or 64 bit.
Please copy them from release/<platform> folder to /usr/lib (unix) or to winbin folder (windows).

