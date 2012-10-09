--[[::::::::::::::::::::::::::::::::: Copyright (c) 2010 by Saymon ::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	    * ��������: SendReports
	    * ������� ��: 12/02/2010
	    * �����: Saymon
	    * ���� ������ ��� RusHub - http://rushub.org
	         * ��������: ������ ��������� ��������� ������ �� ����� ������������� ����.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]]

local sHubBot = ""                            -- ��� ����. ���� "" �� ������� � �������� ����. ��� ���� ������ ����� ���������� � �� �������� 0,1
local iSendRoportTo = "pmprofile"                -- ���� ����� �������� ������. pmprofile - � ����� ��� Profiles. opchat ��� ����� �� � Easy OPChat
local EnabledRH_OPChat = false                 -- ������ Easy OPChat ����������? true - ��. false - ���. 
                                              -- Easy OPChat ������ ������ � ������ ���� �����. ( ��� ������ Easy OPChat ����� ����� ��� - http://mydc.ru/topic3838.html )
local RH_OPchat_LuaName = "EasyChat.lua"      -- ��� ����� ������� Easy OPChat � ����� scripts 
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function OnStartup()
	if EnabledRH_OPChat then
		sChatName = Core.GetGVal(RH_OPchat_LuaName, "sChatName")
	end
	if sHubBot == "" then 
		sHubBot = Config.sHubBot 
	end
end
function OnChat(UID,sData)
 sData=sData:sub(UID.sNick:len()+4)
  local _,_,Command,f=sData:find"%p(%S+)%s+(.*)"
  if Command and Command == "report" or Command and Command == "������" then
    if UID.iProfile > 1 or UID.iProfile == -1 then
      if f then
        local _,_,sNick,Reason=f:find"(%S+)%s+(.*)"
        if sNick and sNick~="" then
          if Core.GetUser(sNick) then
              Core.SendToUser(UID,"���� ������ �� ������������ <"..sNick.."> ���������� ���� ���������� � �������������� ����. �������: "..(Reason or ""),sHubBot)
             if iSendRoportTo == "opchat" then
                 Core.SendToProfile({0,1},"��������� ������ �� ����� ' "..UID.sNick.." ' �� ����� ' "..sNick.." '. �������: '"..(Reason or "").."'", sChatName,sChatName)
             elseif iSendRoportTo == "pmprofile" then
                 Core.SendToProfile({0,1}, "��������� ������ �� ����� '"..UID.sNick.."' �� ����� '"..sNick.."'. �������: '"..(Reason or "").."'", sHubBot, sHubBot)
             end
          else
            Core.SendToUser(UID,"������������ � ����� <"..sNick.."> ��� �� ����.",sHubBot)
          end
        end
      else
        Core.SendToUser(UID,"�� �� ����� ���.",sHubBot)
      end
    else
      Core.SendToUser(UID,"��� ���� �� ������������� ���� �������.",sHubBot)
    end
    return true
  end
end
function OnUserEnter(UID)
     if UID.iProfile > 1 or UID.iProfile == -1 then
       local MenuReport = "$UserCommand 1 2 ��������� ������ �� ����� ����� $<%[mynick]> !report %[nick] %[line:������� �������]&#124;|"..
                           "$UserCommand 1 3 ��������� ������ �� ����� $<%[mynick]> !report %[line:������� ���] %[line:������� �������]&#124;"
        Core.SendToUser(UID,MenuReport)
	end
end