mcs /t:library ../snap7.net.cs /out:snap7.net.dll
mcs /r:snap7.net.dll ../Client.cs  /out:Client.exe
mcs /r:snap7.net.dll ../Server.cs /out:Server.exe
mcs /r:snap7.net.dll ../SrvResourceless.cs /out:SrvResourceless.exe
mcs /r:snap7.net.dll ../APartner.cs /out:APartner.exe
mcs /r:snap7.net.dll ../PPartner.cs /out:PPartner.exe


