Unix usage:

Linux i386 (all distros)
make -f i386_linux.mk clean|all|install

Linux native x86_64 (all distros)
make -f x86_64_linux.mk clean|all|install

Linux ARM V6 (Raspberry and clones)
make -f arm_v6_linux.mk clean|all|install

Linux ARM v7 (all other boards)
make -f arm_v7_linux.mk clean|all|install

Linux mips board
make -f mips_linux.mk clean|all|install

BSD i386
gmake -f i386_bsd.mk clean|all|install

BSD native x86_64
gmake -f x86_64_bsd.mk clean|all|install

Linux mips (big endian)
make -f mips.mk clean|all|install

Solaris 32 bit using Oracle Solaris Studio 
gmake -f i386_solaris_cc.mk clean|all|install

Solaris 64 bit using Oracle Solaris Studio 
gmake -f x86_64_solaris_cc.mk clean|all|install

Solaris 32 bit using GNU 
gmake -f i386_solaris_gcc.mk clean|all|install

Solaris 64 bit using GNU 
gmake -f x86_64_solaris_gcc.mk clean|all|install
