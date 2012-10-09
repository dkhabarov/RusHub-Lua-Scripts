--[[:::::::::::: (c) 2010 by Saymon ::::::::::::::::::::::::
��������: Access IPRanges beta 
�����: Saymon
����� � ���������� ��� PtokaX - Nickolya
������� ��� RusHub by Saymon
��������: ������ ��������� ���� ����� ����� � ���� ��� �� ������������� ���������� ������� ������� � �������, ��������� � ����.

������ ������� ���������� ��������������� Saymon ��� EW DCMagnet's HuB (PtokaX 0.4.1.2). 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]]

--[::::::::::: ��������� �������. :::::::::::::::::::::::::::]
Provider = "Etherway"                                  -- �������� ������ �������� ����������.
ProviderSite = "http://etherway.ru"                    -- ��� ���� ������ �������� ����������.
AdminMail = "ewmagnet@mail.ru"                         -- E-Mail �������������� ����.                                   
NickReport = {                                         -- ���� ��������������� ����. 
"Saymon","��� ����� �������� ������ ���",
}

tLocal = { --������� � ����������� ������ ����������
    {"10.0.0.0","10.255.255.255",},       -- ��������� ���� Etherway.ru
	{"109.248.128.0","109.248.255.255",}, -- Etherway VPN
	{"127.0.0.1","127.255.255.1",},       -- localhost
}

sBot = Core.GetConfig("sHubBot")     -- �������� ���  ���� � ������� ����
HubName = Core.GetConfig("sHubName") -- �������� ��� ���� � ������� �������
--[::::::::::::: ����� ��������. ����� �������� ��� �������. ���� ��� ������ Lua, �� ����� ������ �� �������!! ::]
Version = "0.1 beta"
function OnStartup()
    for i in ipairs(tLocal) do
        tLocal[i][1] = tLocal[i][1]:iptonumber()
        tLocal[i][2] = tLocal[i][2]:iptonumber()
    end
end

function string.iptonumber(ip)
    local i1, i2, i3, i4 = ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    if i1 then
        return i1*16777216+i2*65536+i3*256+i4
    end
end
				 
function OnGetNickList(UID, sData)
	if not CheckInDiap(UID) then 
		  Core.SendToNicks(NickReport, "���� ��������� ������� ����� ��� ����� ["..UID.sNick.." - "..UID.sIP.."]. �������: IP ����� ������������ �� ������������� ���������� ���������� "..Provider..".", sBot)
          Core.SendToUser(UID,"\t\t"..HubName.."\r\n\n"..
              "\tIP �����: ["..UID.sIP.."] �������� �������� � �������� ����������\r\n"..
			  "\t��� IP ������� �������� ���������� "..Provider.." "..ProviderSite.." .\r\n\t"..string.rep("�", 70).."\n"..
			  "\t���� �� �� ��� ��������� "..Provider..", �� ��������� ���������� � ��������������� ����.\n\t"..
			  "\t������� ��� ����� ������� �� E-Mail: "..AdminMail.."\n\t"..
			  "\n\t"..string.rep("�", 70).."\n\tAccess IPRanges v "..Version..". � 2009-2010 by Saymon.", sBot) 
		  Core.Disconnect(UID)
	end
	Core.SendToUser(UID,"�������� IP ������ ["..UID.sIP.."] �� �������������� � �������� ���������� "..Provider.." �������� �������. ������ ��������.", sBot)
end 

function CheckInDiap(user) 
	local ip = user.sIP:iptonumber()
	for _,range in ipairs(tLocal) do
		if range[1] <= ip and ip <= range[2] then
			return true
		end
	end
	return false
end
