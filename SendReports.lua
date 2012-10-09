--[[::::::::::::::::::::::::::::::::: Copyright (c) 2010 by Saymon ::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	    * Название: SendReports
	    * Ревизия от: 12/02/2010
	    * Автор: Saymon
	    * Этот скрипт для RusHub - http://rushub.org
	         * Описание: Скрипт позволяет отправить жалобу на юзера администрации хаба.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]]

local sHubBot = ""                            -- Имя бота. Если "" то получим с настроек хаба. При этом жалобы будем отправлять в Лс профилям 0,1
local iSendRoportTo = "pmprofile"                -- Куда будем отсылать жалобы. pmprofile - в личку для Profiles. opchat как будто бы в Easy OPChat
local EnabledRH_OPChat = false                 -- Скрипт Easy OPChat установлен? true - Да. false - нет. 
                                              -- Easy OPChat должен стоять в списке выше этого. ( Сам скрипт Easy OPChat можно взять тут - http://mydc.ru/topic3838.html )
local RH_OPchat_LuaName = "EasyChat.lua"      -- Имя файла скрипта Easy OPChat в папке scripts 
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
  if Command and Command == "report" or Command and Command == "жалоба" then
    if UID.iProfile > 1 or UID.iProfile == -1 then
      if f then
        local _,_,sNick,Reason=f:find"(%S+)%s+(.*)"
        if sNick and sNick~="" then
          if Core.GetUser(sNick) then
              Core.SendToUser(UID,"Ваша жалоба на пользователя <"..sNick.."> отправлена всем ОПераторам и Администратору хаба. Причина: "..(Reason or ""),sHubBot)
             if iSendRoportTo == "opchat" then
                 Core.SendToProfile({0,1},"Поступила жалоба от юзера ' "..UID.sNick.." ' на юзера ' "..sNick.." '. Причина: '"..(Reason or "").."'", sChatName,sChatName)
             elseif iSendRoportTo == "pmprofile" then
                 Core.SendToProfile({0,1}, "Поступила жалоба от юзера '"..UID.sNick.."' на юзера '"..sNick.."'. Причина: '"..(Reason or "").."'", sHubBot, sHubBot)
             end
          else
            Core.SendToUser(UID,"Пользователя с ником <"..sNick.."> нет на хабе.",sHubBot)
          end
        end
      else
        Core.SendToUser(UID,"Вы не ввели ник.",sHubBot)
      end
    else
      Core.SendToUser(UID,"Нет прав на использование этой команды.",sHubBot)
    end
    return true
  end
end
function OnUserEnter(UID)
     if UID.iProfile > 1 or UID.iProfile == -1 then
       local MenuReport = "$UserCommand 1 2 Отправить жалобу на этого юзера $<%[mynick]> !report %[nick] %[line:Введите причину]&#124;|"..
                           "$UserCommand 1 3 Отправить жалобу на юзера $<%[mynick]> !report %[line:Введите ник] %[line:Введите причину]&#124;"
        Core.SendToUser(UID,MenuReport)
	end
end