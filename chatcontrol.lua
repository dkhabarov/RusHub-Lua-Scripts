--/*************************************************************************************************/
--/*************************************************************************************************/
--* ��������: ChatControl
--* ��������: ������ ��������� �������� ���� ���� 
--* ��� ��� �������, ����� ��� ����� ������� ������� �������� ����.
--* ���� ����������� ��������� ���� �������� ��� �������������������� ������ ��� ����, ����� ����������. 
--* ������: 0.1 
--* �������: RusHub - http://rushub.org
--* ������������� ��: Ubuntu 10.10 GNU/Linux, RusHub 2.3.0, LuaScripts 2.0
--* ������� ��: �1/ 02.05.2011 22:20 (���)
--* �����: Saymon
--* ��� ������: dchub://dc.hub21.ru / dchub://dc-lan.hub21.ru
--/*************************************************************************************************/
--* Copyright (c) 2010-2011 Saymon
--/*************************************************************************************************/
--* http://myDC.ru - Russian DC++ forum - Discussion and scripts for PtokaX, RusHub, Eximius, VerliHub and other hubsoft & clients software.
--/*************************************************************************************************/
tallowedpref = {
	['!'] = true,
	['+'] = true,
}
taccess_to = {
	[0] = 1,
	[1] = 1,
	[2] = 0,
	[3] = 0,
	[-1] = 0
}
tstrmsg = {
	[1] = '������� ��� ��� ��������! ��������, ������ ����� ������ � ������?!',
	[2] = '������� ��� ��� ������� ��� �������������������� �������������!',
	[3] = '������!!! ������� ������ ��������� ���������: !chatcontrol <on&#124;off&#124;regs>',
	[4] = '<%s> --> ������� ��� ��� �������!',
	[5] = '������!!! ��� ���� �������!',
	[6] = '<%s> --> ������� ��� ��� ��������!',
	[7] = '������!!! ������� ��� ���� ��������!',
	[8] = '<%s> -- > ������� ��� ��� �������� ��� �������������������� �������������!',
	[9] = '������!!! ������� ��� ���� �������� ������ ��� ������������������ ������!',
	[10] = '� ��� ��� ���� ��� ������������� ���� �������!'
}
chat = {}
chat.state = 0
bot = Config.sHubBot

function OnUserEnter(uid)
	if chat.state == 2 then
		Core.SendToUser(uid,tstrmsg[1],bot)
	elseif chat.state == 1 and uid.iProfile == -1 then
		Core.SendToUser(uid,tstrmsg[2],bot)
    end
	if taccess_to[uid.iProfile] == 1 then
		Core.SendToUser(uid,'$UserCommand 1 3 ���� �������������\\����� ����\\����������$<%[mynick]> !chat on&#124;')
		Core.SendToUser(uid,'$UserCommand 1 3 ���� �������������\\����� ����\\������ ��� ����������$<%[mynick]> !chat off&#124;')
		Core.SendToUser(uid,'$UserCommand 1 3 ���� �������������\\����� ����\\������ ��� ������������������$<%[mynick]> !chat regs&#124;')
	end
end

function OnChat(uid,data)
local spref, scmd, scmdarg = data:match('^%b<>%s+(%p)(%S+)%s*(.*)')
	if spref and scmd and tallowedpref[spref] then
		if spref and scmd == 'chat' then
		if taccess_to[uid.iProfile] == 1 then
			if scmdarg and scmdarg ~= '' then
				if scmdarg == 'on' then
					if chat.state ~= 0 then
						chat.state = 0
						Core.SendToAll(tstrmsg[4]:format(uid.sNick),bot)
					else
						Core.SendToUser(uid,tstrmsg[5],bot)
					end
				elseif scmdarg == 'off' then 
					if chat.state ~= 2 then
						chat.state = 2
						Core.SendToAll(tstrmsg[6]:format(uid.sNick),bot)
					else
						Core.SendToUser(uid,tstrmsg[7],bot)
					end
				elseif scmdarg == 'regs' then 
					if chat.state ~= 1 then
						chat.state = 1
						Core.SendToAll(tstrmsg[8]:format(uid.sNick),bot)
					else
						Core.SendToUser(uid,tstrmsg[9],bot)
					end
				end
			else
				Core.SendToUser(uid,tstrmsg[3],bot)
			end
		else
			Core.SendToUser(uid,tstrmsg[10],bot)
		end
		return true
		end
	end
	if chat.state == 2 and uid.bInOpList == false then
		Core.SendToUser(uid,tstrmsg[1],bot)
		return true
	elseif chat.state == 1 and uid.iProfile == -1 then
		Core.SendToUser(uid,tstrmsg[2],bot)
		return true
	end
end