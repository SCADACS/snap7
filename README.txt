Snap7 Package 1.4.0 (See History.txt for details)

The files deployed differs only for their compression method, their content is the same.

7-Zip is the best and today is natively supported by many OS.
Anyway, in doubt, download the .zip archive for Windows and .gz archive for Unix (Linux, BSD, Solaris).

There is an unique package for all the platforms since the source code (library, examples and wrappers) is fully multi-platform. Compiled examples, libraries deployed and project/makefiles are divided by folder.

No installation is needed, unpack snap7-full-x.y.z wherever you want : all paths inside projects/makefiles are relative, both for Windows and Unix.

The compiled examples and rich-demos are ready to run, in Unix remember to copy the correct libsnap7.so (release/deploy.html contains the list divided by OS/distro) in usr/lib.


Linux ARM boards
================

If you plan to download the package directly from one of these boards, you can safely delete, after unpacking, all folders relative to windows/bsd/solaris and i386/x86_64 Linux to have more room in your SD card.

As you can see in the online documentation, Snap7 was succesfully built and tested with 

- Raspberry PI     (ARM V6)
- Raspberry PI 2   (ARM V7)
- pcDuino          (ARM V7)
- BeagleBone Black (ARM V7)
- CubieBoard 2     (ARM V7)
- UDOO Quad        (ARM V7)

The libsnap7.so that you will find, one for each of these boards, was not cross-compiled but built directly inside them.

I'm pretty sure that the libraries deployed can run in other same-class linux boards if they are "standard Linux" based, and very sure that the libraries can be succesfully built in the others using the correct makefile (V6 or V7).

Please report feedback and send the libraries if you do this.
