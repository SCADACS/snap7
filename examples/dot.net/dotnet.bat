cd winbin
csc /platform:anycpu /t:library ..\snap7.net.cs 
csc /platform:anycpu /r:snap7.net.dll ..\Client.cs 
csc /platform:anycpu /r:snap7.net.dll ..\Server.cs
csc /platform:anycpu /r:snap7.net.dll ..\APartner.cs
csc /platform:anycpu /r:snap7.net.dll ..\PPartner.cs
cd..


