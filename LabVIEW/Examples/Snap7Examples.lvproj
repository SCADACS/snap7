<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="13008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="Client" Type="Folder">
			<Item Name="Block-Down-Upload.vi" Type="VI" URL="../Client/Block-Down-Upload.vi"/>
			<Item Name="BlockInfo.vi" Type="VI" URL="../Client/BlockInfo.vi"/>
			<Item Name="BlockUpload.vi" Type="VI" URL="../Client/BlockUpload.vi"/>
			<Item Name="BlockDel.vi" Type="VI" URL="../Client/BlockDel.vi"/>
			<Item Name="DBFill.vi" Type="VI" URL="../Client/DBFill.vi"/>
			<Item Name="DBGet.vi" Type="VI" URL="../Client/DBGet.vi"/>
			<Item Name="Directory.vi" Type="VI" URL="../Client/Directory.vi"/>
			<Item Name="Password.vi" Type="VI" URL="../Client/Password.vi"/>
			<Item Name="PlcInfo.vi" Type="VI" URL="../Client/PlcInfo.vi"/>
			<Item Name="PlcDateTime.vi" Type="VI" URL="../Client/PlcDateTime.vi"/>
			<Item Name="ReadArea.vi" Type="VI" URL="../Client/ReadArea.vi"/>
			<Item Name="GetSetParam.vi" Type="VI" URL="../Client/GetSetParam.vi"/>
			<Item Name="ReadSZL.vi" Type="VI" URL="../Client/ReadSZL.vi"/>
			<Item Name="RunStop.vi" Type="VI" URL="../Client/RunStop.vi"/>
		</Item>
		<Item Name="Server" Type="Folder">
			<Item Name="ServerDemo.vi" Type="VI" URL="../Server/ServerDemo.vi"/>
		</Item>
		<Item Name="Partner" Type="Folder">
			<Item Name="PPartner.vi" Type="VI" URL="../Partner/PPartner.vi"/>
			<Item Name="APartner.vi" Type="VI" URL="../Partner/APartner.vi"/>
		</Item>
		<Item Name="Snap7.lvlib" Type="Library" URL="../../lib/Snap7.lvlib"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="lv_snap7.dll" Type="Document" URL="../../lib/windows/lv_snap7.dll"/>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
