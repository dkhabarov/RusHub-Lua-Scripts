--[[
Название: AntiTor
Идея: RoLex
Автор: Tsd © 15.03.2012 
Перевод под RusHub и доработка: Saymon21
Дата/Время модификации: 16/03/2012 19:35:20
Версия скрипта: 1.0.1
Оригинал: http://mydc.ru/topic5239.html

Для работы скрипта нужен модуль Ban.

Описание скрипта: Скрипт не даёт зайти на хаб пользователям, использующим технологию https://ru.wikipedia.org/wiki/Tor.
Проще говоря, эта технология похожа на коннект пользователя на хаб через прокси, но более продвинутая.

Протестировано на Debian GNU/Linux 6.0.4, RusHub 2.3.9, LuaPlugin 2.8

Отличия этой версии:

1) curl теперь вызывается не из скрипта. Надо подумать зарание об обновлении бд через сторонний планировщик. Например cron. Под венду были сборки. Хотя там есть и куча других альтернатив. google://.
Пример задачи для cron: 

$ crontab -l |grep curl
*/50 * * * * /usr/bin/curl -L --retry 3 --connect-timeout 5 -m 15 -s -o "/usr/local/etc/rushub/scripts/AntiTor/torlist.txt" "http://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv"
Вместо curl также можно использовать wget, fetch аля bsd, libwww-perl и т.п.

2) в Ban ныне она ExecuteOnTor (карательная функция для тех, кто лезет с tor'ом) добавлена возможность вызова iptables, ipfw, route, ipchains (Можно вписать вызов любых утилит). В комментариях показаны примеры некоторых правил к ним. Под венду: google://wipfw. Все вопросы о настройке утилит, sudo, fw, google:// пожалуйста.

3) Добавлена возможность блокировки чата/привата tor-юзерам, на случай если кто-то решит что лучше пускать всех подряд, но пусть они сидят молча.
Из фич тут есть возможность тихой блокировки. (Не тестировалось) 

4) Добавлена проверка всех онлайн юзеров на подключение с Tor при старте скрипта и при обновления списка адресов.

5) Добавлена проверка OnMCTo. (Персональные сообщения в главном чате). Настройки такие же, как и для чата/лс.
]]
		------------ Config ------------
local iUpTimer = 1		-- Таймер обновления Tor листа с сервера обновлений (в часах).
local bMess = true		-- Отсылать все сообщения админу/операторам ? (true = да, false = нет).
	-- Ник админа хаба. Если пустые кавычки, то при включенных функциях выше сообщения будут
	-- приходить всем операторам, в противном случае только для указанного ника.
local sAdmin = ""
	-- Причина наказания:
local sBanRsn = "Этот IP заблокирован т.к. вы используете Tor."
local iBanMode = 5 -- Какой вид наказания использовать?
				-- 0 = Перманент IP
				-- 1 = Временный бан по IP на время в iBanTime
				-- 2 = Дисконнект с хаба с причиной
				-- 3 = Вызов systools_for_blocked
				-- 4 = Дисконнект с хаба без сообщения о причине дисконнекта.
				-- > 4 = Блокировка чата
local iBanTime = iUpTimer*60 -- Время бана в минутах для iBanMode = 1. По умолчанию равно времени таймера обновления, можно указать другое.

local check_tor_conn_onstartup = true -- Проверять при старе всех пользователей на подключение с Tor.
local block_chat_mode=2 -- Если юзер будет пропущен на хаб, то можем блокировать ему Чат и личку. Режимы: 1 - Блокировать с отправкой уведомления о блокировке. 2 - Использовать тихую блокировку.
local snd_rpt_to_op_for_blocked_msg=true -- Если чат/лс для юзера заблокированы, будем отправлять уведомление операторам о том, что юзер пытался что-то написать в чат/лс.

local systools_for_blocked="/usr/bin/sudo /sbin/iptables -A INPUT -p tcp -i eth0 -s %s -j DROP" -- Можно "банить файрволом". Вопросы о настройке sudo. fw направляйте в google:// или /dev/null.
--local systools_for_blocked="/sbin/ipfw add 1 deny all from %s:255.255.255.255 to any" -- Под венду: google://wipfw.
--local systools_for_blocked="/sbin/ipchains -I input -s %s -j DENY"
--local systools_for_blocked="route add -net %s -netmask 255.255.255.255 127.0.0.1 -blackhole"

local tOpProfiles={ -- Операторские профили.
	[0] = true,
	[1] = true,
	[2] = false,
	[3] = false,
	[-1] = false,
}
		------------ End config ------------
if iBanMode == 0 or iBanMode == 1 then
require"Ban" -- Скрипту нужен модуль Ban и Ban Manager
end

function OnStartup()
	sBot = Config.sHubBot
	sPath = Core.sScriptsDir.."AntiTor/"
	sTorFile = sPath.."torlist.txt"
	Core.AddTimer(1, iUpTimer*3600000)
	tTorList = {}
	--local f = io.open(sTorFile,"r")
	local c = 0
	for l in io.lines(sTorFile) do
		if string.find(l,"^%d+%.%d+%.%d+%.%d+$") then
			if GetIdx(l) == 0 then
				c = c + 1
				table.insert(tTorList,l)
			end
		end
	end
	sMsg = "Импортировано "..tostring(c).." TOR-серверов."
	MsgToOPs(sMsg)
	OnTimer()
	if check_tor_conn_onstartup then
		for i,v in pairs(Core.GetUsers() or {}) do
			if is_tor_connection(v.sIP) then
				ExecuteOnTor(v.UID)
			end
		end
	end
end

function is_tor_connection(ip)
	local fl=false
	for i,v in pairs(tTorList) do
		if ip == v then
			fl= true
			break
		end	
	end
	return fl
end

function OnChat(UID,sData)
	local message = sData:match("%b<>%s*(.+)$")
	if is_tor_connection(UID.sIP) then
		if block_chat_mode == 1 then
			Core.SendToUser(UID,"Вам запрещено использовать чат хаба по причине использования Tor.",sBot)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("Юзер "..UID.sNick.." ("..UID.sIP..") попытался написать в чат: "..(message and message or "").."\nНо сообщение не было пропущено, т.к он использует Tor")
			end
			return true
		elseif block_chat_mode == 2 then
			Core.SendToUser(UID,message,UID.sNick)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("Юзер "..UID.sNick.." ("..UID.sIP..") попытался написать в чат: "..(message and message or "").."\nНо сообщение не было пропущено, т.к он использует Tor")
			end
			return true
		end
	end
	

end


function OnTo(UID,sData)
	local s,e,to,from,sNick,message = string.find(sData, "%$To:%s(%S+)%sFrom:%s(%S+)%s$<(%S+)%>%s(.*)$")
	if is_tor_connection(UID.sIP) then
		if block_chat_mode == 1 then
			Core.SendToUser(UID,"Вам запрещено использовать личные сообщения по причине использования Вами Tor.",sBot,to)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("Юзер "..UID.sNick.." ("..UID.sIP.." попытался отправить ЛС юзеру "..to..", но сообщение не пропущено, т.к он использует Tor.")
			end
			return true
		elseif block_chat_mode == 2 then
			Core.SendToUser(UID,message,UID.sNick,to)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("Юзер "..UID.sNick.." ("..UID.sIP.." попытался отправить ЛС юзеру "..to..", но сообщение не пропущено, т.к он использует Tor.")
			end
			return true
		end
	end
end

function  OnMCTo(UID,sData)
	local to, from, sMsg = sData:match('^$MCTo:%s(%S+)%s$(%S+)(.+)$')
		if is_tor_connection(UID.sIP) then
			if block_chat_mode == 1 then
				Core.SendToUser(UID,"Вам запрещено использовать персональные сообщения по причине использования Вами Tor.",sBot)
				if snd_rpt_to_op_for_blocked_msg then
					MsgToOPs("Юзер "..UID.sNick.." ("..UID.sIP.." попытался отправить персональное сообщение в главном чате юзеру "..to..", но сообщение не пропущено, т.к он использует Tor.")
				end
				return true
			elseif block_chat_mode == 2 then
				Core.SendToUser(UID,sMsg,UID.sNick)
				if snd_rpt_to_op_for_blocked_msg then
					MsgToOPs("Юзер "..UID.sNick.." ("..UID.sIP.." попытался отправить персональное сообщение в главном чате юзеру "..to..", но сообщение не пропущено, т.к он использует Tor.")
				end
				return true
			end
		
	end
end

function OnUserEnter(UID)
	if is_tor_connection(UID.sIP) then
		ExecuteOnTor(UID)
	end
end

function OnTimer()

		local f = io.open(sTorFile,"r")
		if f then
			local c,d = 0,0
			for k in io.lines(sTorFile) do
				if string.find(k,"^%d+%.%d+%.%d+%.%d+$") then
					if GetIdx(k) == 0 then
						d = 1
						break
					end	
				end		
			end			
			if d == 1 then
				tTorList = {}
				for l in io.lines(sTorFile) do
					if GetIdx(l) == 0 then
						c = c + 1
						table.insert(tTorList,l)
					end	
				end
				MsgToOPs("Обновление списка Tor-серверов завершено. В результате обновления было добавлено "..tostring(c).." серверов.")
				for i,v in pairs(Core.GetUsers() or {}) do
					if is_tor_connection(v.sIP) then
						ExecuteOnTor(v.UID)
					end
				end
			end
		else
			MsgToOPs("Ошибка обновления IP tor. Невозможно открыть файл.")
		end

	collectgarbage("collect")
end

function GetIdx(i)
	local r = 0
	for k, v in pairs (tTorList) do
		if v == i then
			r = k
			break
		end
	end
	return r
end

function GetOps()
	local t = {}
	for _,u in ipairs(Core.GetUsers()) do
		if tOpProfiles[u.iProfile] then
			table.insert(t, u.sNick)
		end
	end
	return t
end

function MsgToOPs(sMsg)
	if bMess then
		if sAdmin == "" then
			Core.SendToUser(GetOps(),sMsg,sBot,sBot)
		else
			if Core.GetUser(sAdmin) then
				Core.SendToUser(sAdmin,sMsg,sBot,sBot)
			end
	
		end
	end
end

function ExecuteOnTor(user)	
	local ip = Core.GetUser(user).sIP
	local rptmsg = "Обнаружена попытка использования TOR-сервера. Юзер "..user.sNick.." ["..ip.."]. Действие: "
	if iBanMode == 0 then 
			Ban.BanUser(ip,"full", sBot, sBanRsn)
			MsgToOPs(rptmsg.." перманент бан. ")
		elseif iBanMode == 1 then 
			Ban.BanUser(ip,iBanTime.."m",sBot,sBanRsn)
			MsgToOPs(rptmsg.." временный забанен по IP на "..iBanTime.." минут. ")
		elseif iBanMode == 2 then 
			Core.SendToUser(user,sBanRsn)
			Core.Disconnect(user)
		elseif iBanMode == 3 then
		os.execute(systools_for_blocked:format(ip))
		MsgToOPs(rptmsg.." заблокирован на файрволе. ")
	end	
	if iBanMode == 4 then 
		MsgToOPs(rptmsg.." отключен от хаба. ")
		Core.Disconnect(user)
	end
end

function OnError(msg)
	MsgToOPs(msg)
end
