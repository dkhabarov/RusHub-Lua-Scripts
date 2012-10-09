--::::::::::::::::::::::::::::::: Copyright (c) 2010 by Saymon ::::::::::::::::::::::::::::::::::::::::::
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--       * Название: RHWarnings Users
--       * Этот скрипт для RusHub - http://rushub.org/
--       * Версия: 0.1
--       * Дата/Время: 13.01.2011/23:41
--       * Автор: Saymon
--       * Хаб автора: dchub://dc.hub21.ru - dchub://dc-lan.hub21.ru
--       * Описание: Скрипт предупреждений юзера с возможностью отправки в бан после bMaxWarningNumber предупреждений.
--       * Для работы скрипта нужен модуль банов.
--       * Протестирован на: RusHub 2.2.14[beta] Lua plugin 1.33[beta] - Windows XP.
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
tbSetMan={
    sHubBot = Config.sHubBot,-- имя бота
    bMaxWarningNumber=3,--максимум предупреждений
    bBannedTime="1m",--время бана
    bSendAllForWarningUser=true,--сообщать ли в чате всем, что юзер получил предупреждение
    tAccessProfilesForWaring={--таблица профилей, кто будет иметь доступ к командам предупреждения
    [0]=true,[1]=true,
   },
    sCmdWarn = "warninguser",--команда предупреждения юзера
    sMenu="Команды оператора\\Предупреждения юзеров\\",
    sMenu2="Юзер\\Предупредить этого"
}
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
tWarnNumbers = {{"первое","второе","третье","четвёртое","пятое","шестое","седьмое","восьмое","девятое",},}
--::::::::::::::::::::::::::::::::::
require"Ban"
tbWarnUsers={}
--::::::::::::::::::::::::::::::::::
function OnUserEnter(UID)
    if tbSetMan.tAccessProfilesForWaring[UID.iProfile] then
        Core.SendToUser(UID,"$UserCommand 1 3 "..tbSetMan.sMenu.."Предупредить юзера$<%[mynick]> !"..tbSetMan.sCmdWarn.." %[line:Введите ник] %[line:Причина]&#124;")
        Core.SendToUser(UID,"$UserCommand 1 2 "..tbSetMan.sMenu2.."$<%[mynick]> !"..tbSetMan.sCmdWarn.." %[nick] %[line:Введите причину] &#124;")
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
				  Core.SendToUser(sNick,"\nВы были временно забанены на этом хабе.\n\tПричина: "..(sReason or "").."\n\tВремя бана: "..tbSetMan.bBannedTime,tbSetMan.sHubBot)
				  Core.SendToProfile({0,1}, "Юзер "..sNick.." был временно забанен после нескольких предупреждений. \nБан выставил: "..UID.sNick,tbSetMan.sHubBot)
				  Ban.BanUser(sNick, tbSetMan.bBannedTime, "", sReason)
				  Core.Disconnect(sNick)
                    else
			 Core.SendToProfile({0,1},UID.sNick.." предупредил юзера "..sNick.." по причине: "..(sReason or "")..".",tbSetMan.sHubBot)
                         Core.SendToUser(sNick,"Вы получили "..tWarnNumbers[1][tbWarnUsers[sNick]].." предупреждение по причине: "..(sReason or "")..". При повторных нарушениях возможен кик с хаба!",tbSetMan.sHubBot,tbSetMan.sHubBot)
			 if tbSetMan.bSendAllForWarningUser then
			    Core.SendToAll("Пользователь с ником "..sNick.." получил "..tWarnNumbers[1][tbWarnUsers[sNick]].." предупреждение "..("по причине: "..sReason or "")..".При повторных нарушениях возможен кик с хаба!",tbSetMan.sHubBot)
			 end
		    end
		    else
                        Core.SendToUser(UID,"ОШИБКА!!! Юзера с указанным ником нет на хабе!",tbSetMan.sHubBot)
                     end
                else
                    Core.SendToUser(UID,"ОШИБКА!!! Возможно Вы забыли указать ник юзера!",tbSetMan.sHubBot)
                end
                
            end
        else
           Core.SendToUser(UID,"ОШИБКА!!! У Вас нет прав на использование этой команды!",tbSetMan.sHubBot)
        end
	return true
     end
end
