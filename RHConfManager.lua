--/*************************************************************************************************/
--/*************************************************************************************************/
--* ��������: RH Conf Manager
--* ������: 0.1.2
--* �������: RusHub - http://rushub.org
--* ������������� ��: Ubuntu 10.10 GNU/Linux, RusHub 2.3.0, LuaScripts 2.0
--* ������� ��: �1/ 26.04.2011 17:06 (���)
--* �����: Saymon
--* ��� ������: dchub://dc.hub21.ru / dchub://dc-lan.hub21.ru
--* ��������: ������ ������� ��������� ����, ��� ������ ������: 
--*    +setconfig [����������] [����� ��������] - ���������� ���������
--     +getconfig - ���������� ��������� ����
--/*************************************************************************************************/
--* http://myDC.ru - Russian DC++ forum - Discussion and scripts for PtokaX, RusHub, Eximius, VerliHub and other hubsoft & clients software.
--/*************************************************************************************************/
local bot = '#RusHub'-- botname
local access_to = {-- access to profile
 [0] = 1,
 [1] = 0,
 [2] = 0,
 [3] = 0,
 [-1] = 0,
}
local send_report_if_not_access = true
local sendreport_to = { -- if not acccess, send report to
	[1] = 'nick', -- send to type: nick - for nick [2]. prof - for profile [2]
	[2] = 'Saymon', 
}
local forbid_var = {
	['sAddresses'] = true,
	['sMainPath'] = true,
	['sPluginPath'] = true, 
	['sLogPath'] = true, 
	['sLangPath'] = true,
}
local commands = {
	['setconfig'] = 'setconfig',
	['getconfig'] = 'getconfig',
	['pref'] = '+', -- prefix it script
	['enusercommand'] = false, -- enabled $UserCommand 
	
	['usercommand'] = '$UserCommand 1 3 ���� �������������\\��������� ����\\����������$<%%[mynick]> %s%s %%[line:������� ��� �����] %%[line:������� ����� �������]&#124;|'..
	'$UserCommand 1 3 ���� �������������\\��������� ����\\����������$<%%[mynick]> %s%s &#124;|'
			
}
local log_dir = Core.sMainDir..'logs/cfg/'
 

function OnStartup()
	if bot == '' then
		bot = Config.sHubBot
	end
	local tmp = io.open(log_dir.."tmp","w")
	if tmp then
		tmp:close()
		os.remove(log_dir.."tmp")
	else
		os.execute('mkdir \"'..log_dir..'\"')
		tmp2 = io.open(log_dir.."tmp","w")
		if tmp2 then
			tmp2:close()
			os.remove(log_dir.."tmp")
		else
			error(log_dir..' Permission denied')
		end
	end
end

function OnUserEnter(UID)
	if access_to[UID.iProfile] == 1 and commands['enusercommand'] then
		Core.SendToUser(UID,commands['usercommand']:format(commands['pref'],commands['setconfig'],commands['pref'],commands['getconfig']))
	end
end

function OnChat(UID,data)
local pre,cmd = data:match('^%b<>%s+(%p)(%S+)')
	local prm = data:match('^%b<>%s+%p%S+%s+(.+)')
	if pre == commands['pref'] then
		if cmd and cmd == commands['getconfig'] then
			if access_to[UID.iProfile] == 1 then
				local setlist ='\n'
				for _,item in pairs(Config.table()) do
					setlist = setlist..('[*] %s: --> \t%s\n'):format(item, Config[item])
				end
				Core.SendToUser(UID,setlist,bot,bot)
				logger(UID.sNick,UID.sNick..'-['..UID.sIP..']:[%s] �������� ������� ����')
			else
				Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", bot)
				logger(UID.sNick,UID.sNick..'-['..UID.sIP..']:[%s] ������� ��������� �������� ����')
				if send_report_if_not_access and sendreport_to[1] == 'nick' then
					Core.SendToUser(sendreport_to[2], UID.sNick..' ( '..UID.sIP..' ) : ������� ������� � ������� ��������� �������� ����',bot,bot)
				elseif send_report_if_not_access and sendreport_to[1] == 'prof' then
					Core.SendToProfile(sendreport_to[2],UID.sNick..' ( '..UID.sIP..' ) : ������� ������� � ������� ��������� �������� ����',bot,bot)
				end
			end
		return true
		elseif cmd and cmd == commands['setconfig'] then
			local var,value = prm:match("^(%S+)%s+(.*)")
			if access_to[UID.iProfile] == 1 then
				if not var then
					Core.SendToUser(UID,'����������� '..commands['pref']..commands['setconfig']..' <����������> <����� ��������>',bot)
				elseif forbid_var[var] then
					Core.SendToUser(UID,"��������� ���� ���������� �� ���� �� �������� ��� ���� ��������� ��������������� �������!",bot)
					logger(UID.sNick,UID.sNick..'-['..UID.sIP..']:[%s] ������� ��������� ������������ ��������� '..(var and var))
				elseif not Config[var] then
					Core.SendToUser(UID,'���� '..var..' �� ����������!',bot)
				else
					local get_from = Config[var]
					Config[var] = value
					Core.SendToUser(UID, '[������] '..var..' -- > � '..(get_from or '')..' �� '..value,bot)
					logger(UID.sNick,UID.sNick..'-['..UID.sIP..']:[%s] ��������� ���������� '..var..' � '..(get_from or '')..' �� '..value)
				end
			else
				logger(UID.sNick,UID.sNick..'-['..UID.sIP..']:[%s] ������� ��������� ��������:'..(var and '����������:'..var)..
						(get_from and '  ��������� ��������: '..get_from )..(value and '    ����� ��������: '..value))
				if send_report_if_not_access and sendreport_to[1] == 'nick' then
					Core.SendToUser(sendreport_to[2], UID.sNick..' ( '..UID.sIP..' ) : ������� ������� � ������� ��������� �������� ����',bot,bot)
				elseif send_report_if_not_access and sendreport_to[1] == 'prof' then
					Core.SendToProfile(sendreport_to[2],UID.sNick..' ( '..UID.sIP..' ) : ������� ������� � ������� ��������� �������� ����',bot,bot)
				end
			end
		return true
		end
	end
end
function logger(user,sdata)
	local os_date1,os_date2 = os.date('%x %X'),os.date('%y-%m-%d')
	local data = sdata:format(os_date1) 
	local file = io.open(log_dir..'['..os_date2..']-'..user..'.log','a+')
	if file then
		file:write(data..'\n')
		file:close()
	end
end

function OnError(s)
	Core.SendToProfile(0,s,'LuaErorr','LuaErorr')
end
