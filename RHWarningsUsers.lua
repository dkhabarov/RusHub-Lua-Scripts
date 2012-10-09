--::::::::::::::::::::::::::::::: Copyright (c) 2010 by Saymon ::::::::::::::::::::::::::::::::::::::::::
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--       * ��������: RHWarnings Users
--       * ���� ������ ��� RusHub - http://rushub.org/
--       * ������: 0.1
--       * ����/�����: 13.01.2011/23:41
--       * �����: Saymon
--       * ��� ������: dchub://dc.hub21.ru - dchub://dc-lan.hub21.ru
--       * ��������: ������ �������������� ����� � ������������ �������� � ��� ����� bMaxWarningNumber ��������������.
--       * ��� ������ ������� ����� ������ �����.
--       * ������������� ��: RusHub 2.2.14[beta] Lua plugin 1.33[beta] - Windows XP.
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
tbSetMan={
    sHubBot = Config.sHubBot,-- ��� ����
    bMaxWarningNumber=3,--�������� ��������������
    bBannedTime="1m",--����� ����
    bSendAllForWarningUser=true,--�������� �� � ���� ����, ��� ���� ������� ��������������
    tAccessProfilesForWaring={--������� ��������, ��� ����� ����� ������ � �������� ��������������
    [0]=true,[1]=true,
   },
    sCmdWarn = "warninguser",--������� �������������� �����
    sMenu="������� ���������\\�������������� ������\\",
    sMenu2="����\\������������ �����"
}
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
tWarnNumbers = {{"������","������","������","��������","�����","������","�������","�������","�������",},}
--::::::::::::::::::::::::::::::::::
require"Ban"
tbWarnUsers={}
--::::::::::::::::::::::::::::::::::
function OnUserEnter(UID)
    if tbSetMan.tAccessProfilesForWaring[UID.iProfile] then
        Core.SendToUser(UID,"$UserCommand 1 3 "..tbSetMan.sMenu.."������������ �����$<%[mynick]> !"..tbSetMan.sCmdWarn.." %[line:������� ���] %[line:�������]&#124;")
        Core.SendToUser(UID,"$UserCommand 1 2 "..tbSetMan.sMenu2.."$<%[mynick]> !"..tbSetMan.sCmdWarn.." %[nick] %[line:������� �������] &#124;")
    end
end

function OnChat(UID,sData)
    sData=sData:sub(UID.sNick:len()+4)
     local _,_,Command,f=sData:find"%p(%S+)%s+(.*)"
     if Command and Command == tbSetMan.sCmdWarn then
        if tbSetMan.tAccessProfilesForWaring[UID.iProfile] then
            if f then
                local _,_,sNick,sReason=f:find"(%S+)%s+(.*)"
                if sNick and sNick~="" then
                     if Core.GetUser(sNick) then
			    if tbWarnUsers[sNick] then 
				tbWarnUsers[sNick] = tbWarnUsers[sNick]+1
			    else
				tbWarnUsers[sNick] = 1
			    end
			    if tbWarnUsers[sNick] >= tbSetMan.bMaxWarningNumber  then
				  tbWarnUsers[sNick] = nil
				  Core.SendToUser(sNick,"\n�� ���� �������� �������� �� ���� ����.\n\t�������: "..(sReason or "").."\n\t����� ����: "..tbSetMan.bBannedTime,tbSetMan.sHubBot)
				  Core.SendToProfile({0,1}, "���� "..sNick.." ��� �������� ������� ����� ���������� ��������������. \n��� ��������: "..UID.sNick,tbSetMan.sHubBot)
				  Ban.BanUser(sNick, tbSetMan.bBannedTime, "", sReason)
				  Core.Disconnect(sNick)
                    else
			 Core.SendToProfile({0,1},UID.sNick.." ����������� ����� "..sNick.." �� �������: "..(sReason or "")..".",tbSetMan.sHubBot)
                         Core.SendToUser(sNick,"�� �������� "..tWarnNumbers[1][tbWarnUsers[sNick]].." �������������� �� �������: "..(sReason or "")..". ��� ��������� ���������� �������� ��� � ����!",tbSetMan.sHubBot,tbSetMan.sHubBot)
			 if tbSetMan.bSendAllForWarningUser then
			    Core.SendToAll("������������ � ����� "..sNick.." ������� "..tWarnNumbers[1][tbWarnUsers[sNick]].." �������������� "..("�� �������: "..sReason or "")..".��� ��������� ���������� �������� ��� � ����!",tbSetMan.sHubBot)
			 end
		    end
		    else
                        Core.SendToUser(UID,"������!!! ����� � ��������� ����� ��� �� ����!",tbSetMan.sHubBot)
                     end
                else
                    Core.SendToUser(UID,"������!!! �������� �� ������ ������� ��� �����!",tbSetMan.sHubBot)
                end
                
            end
        else
           Core.SendToUser(UID,"������!!! � ��� ��� ���� �� ������������� ���� �������!",tbSetMan.sHubBot)
        end
	return true
     end
end
