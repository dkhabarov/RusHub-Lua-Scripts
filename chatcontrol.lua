--/*************************************************************************************************/
--/*************************************************************************************************/
--* Название: ChatControl
--* Описание: Скрипт аварийной заглушки чата хаба 
--* для тех случаев, когда нет иного способа присечь например флуд.
--* Есть возможность заглушить чать отдельно для незарегистрированных юзеров или всех, кроме операторов. 
--* Версия: 0.1 
--* Хабсофт: RusHub - http://rushub.org
--* Протестирован на: Ubuntu 10.10 GNU/Linux, RusHub 2.3.0, LuaScripts 2.0
--* Ревизия от: №1/ 02.05.2011 22:20 (Мск)
--* Автор: Saymon
--* Хаб автора: dchub://dc.hub21.ru / dchub://dc-lan.hub21.ru
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
	[1] = 'Главный чат был отключен! Возможно, пришло время побыть в тишине?!',
	[2] = 'Главный чат был отлючен для незарегистрированных пользователей!',
	[3] = 'ОШИБКА!!! Команда должна содержать аргументы: !chatcontrol <on&#124;off&#124;regs>',
	[4] = '<%s> --> Главный чат был включен!',
	[5] = 'ОШИБКА!!! Чат итак включен!',
	[6] = '<%s> --> Главный чат был отключен!',
	[7] = 'ОШИБКА!!! Главный чат итак отключен!',
	[8] = '<%s> -- > Главный чат был отключен для незарегистрированных пользователей!',
	[9] = 'ОШИБКА!!! Главный чат итак доступен только для зарегистрированных юзеров!',
	[10] = 'У вас нет прав для использования этой команды!'
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
		Core.SendToUser(uid,'$UserCommand 1 3 Меню администрации\\Режим чата\\Нормальный$<%[mynick]> !chat on&#124;')
		Core.SendToUser(uid,'$UserCommand 1 3 Меню администрации\\Режим чата\\Только для ОПераторов$<%[mynick]> !chat off&#124;')
		Core.SendToUser(uid,'$UserCommand 1 3 Меню администрации\\Режим чата\\Только для зарегистрированных$<%[mynick]> !chat regs&#124;')
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