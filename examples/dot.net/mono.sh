mcs /t:library snap7.net.cs /out:monobin/snap7.net.dll
mcs /r:monobin/snap7.net.dll Client.cs  /out:monobin/Client.exe
mcs /r:monobin/snap7.net.dll Server.cs /out:monobin/Server.exe
mcs /r:monobin/snap7.net.dll APartner.cs /out:monobin/APartner.exe
mcs /r:monobin/snap7.net.dll PPartner.cs /out:monobin/PPartner.exe


