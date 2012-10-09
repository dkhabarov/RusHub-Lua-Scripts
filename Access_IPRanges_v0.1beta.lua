--[[:::::::::::: (c) 2010 by Saymon ::::::::::::::::::::::::
Название: Access IPRanges beta 
Автор: Saymon
Помог с написанием под PtokaX - Nickolya
Перевод под RusHub by Saymon
Описание: Скрипт проверяет айпи адрес юзера и если тот не соответствует диапазонам которые указаны в таблице, отключает с хаба.

Скрипт написан специально администратором Saymon для EW DCMagnet's HuB (PtokaX 0.4.1.2). 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]]

--[::::::::::: Настройки скрипта. :::::::::::::::::::::::::::]
Provider = "Etherway"                                  -- Название нашего интернет провайдера.
ProviderSite = "http://etherway.ru"                    -- Вэб сайт нашего интернет провайдера.
AdminMail = "ewmagnet@mail.ru"                         -- E-Mail администратора хаба.                                   
NickReport = {                                         -- Ники администраторов хаба. 
"Saymon","тут можно написать второй ник",
}

tLocal = { --Таблица с диапазонами нашего провайдера
    {"10.0.0.0","10.255.255.255",},       -- Локальная сеть Etherway.ru
	{"109.248.128.0","109.248.255.255",}, -- Etherway VPN
	{"127.0.0.1","127.255.255.1",},       -- localhost
}

sBot = Core.GetConfig("sHubBot")     -- Получаем имя  бота с конфига хаба
HubName = Core.GetConfig("sHubName") -- Получаем имя хаба с конфига сервера
--[::::::::::::: Конец настроек. Далее основной код скрипта. Если нет знаний Lua, то лучше ничего не трогать!! ::]
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
		  Core.SendToNicks(NickReport, "Была пресечена попытка входа для юзера ["..UID.sNick.." - "..UID.sIP.."]. Причина: IP адрес пользователя не соответствует диапазаону провайдера "..Provider..".", sBot)
          Core.SendToUser(UID,"\t\t"..HubName.."\r\n\n"..
              "\tIP Адрес: ["..UID.sIP.."] непрошёл проверку с таблицей диапазонов\r\n"..
			  "\tДля IP адресов интернет провайдера "..Provider.." "..ProviderSite.." .\r\n\t"..string.rep("•", 70).."\n"..
			  "\tЕсли всё же ваш провайдер "..Provider..", то свяжитесь пожалуйста с администратором хаба.\n\t"..
			  "\tСделать это можно написав на E-Mail: "..AdminMail.."\n\t"..
			  "\n\t"..string.rep("•", 70).."\n\tAccess IPRanges v "..Version..". © 2009-2010 by Saymon.", sBot) 
		  Core.Disconnect(UID)
	end
	Core.SendToUser(UID,"Проверка IP адреса ["..UID.sIP.."] на пренадлежность к интернет провайдеру "..Provider.." пройдена успешно. Доступ разрешён.", sBot)
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
