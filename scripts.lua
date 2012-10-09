--[[::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
						Название: Scripts 09/12/2010
						Автор: Saymon ( Хотя пару фрагментов выдрано из HubMenu for ProkaX 0.4.1.Х by alex82 http://mydc.ru/topic1413.html )
				Описание: Скрипт управления скриптами
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]]
local sBotName,sScriptsDir,sHubName,sLuaPluginVersion,HubPath = "RH_LuaManager",Core.sScriptsDir,Config.sHubName,Core.sLuaPluginVersion,Core.sMainDir -- Тут лучше ничего не трогать!

AdminMenu = "Меню администрации\\"..sLuaPluginVersion -- Меню
Prefix = "!"             --	Префикс команд хаба.

local Access = { -- Профили, кому будет доступно управление скриптами
    [0] = 1,	--	Администратор
    [1] = 1,	--	Мастер
    [2] = 0,	--	Модератор
    [3] = 0,	--	Оператор
    [4] = 0,	--	VIP Пользователь
    [5] = 0,	--	Пользователь
    [-1] = 0,	--	Гость
}
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function OnStartup()
	if sBotName == "" then
		sBotName = Config.sHubBot
	end
end

function OnUserEnter(UID)
	if Access[UID.iProfile] == 1 then
		Core.SendToUser(UID,"$UserCommand 0 3")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Посмотреть список$<%[mynick]> "..Prefix.."showlua&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Показать статус скрипта (Ввести название)$<%[mynick]> "..Prefix.."lua_get_info %[line:Имя файла с расширением]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Перезапустить скрипты$<%[mynick]> "..Prefix.."reload_all_lua&#124;")
		Core.SendToUser(UID,"$UserCommand 0 3")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Справка$<%[mynick]> "..Prefix.."rh_lua_help&#124;")
		Core.SendToUser(UID,"$UserCommand 0 3")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Перезапуск (Ввести название)$<%[mynick]> "..Prefix.."reloadlua %[line:Имя файла с расширением]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Старт (Ввести название)$<%[mynick]> "..Prefix.."luastart %[line:Имя файла с расширением]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Стоп (Ввести название)$<%[mynick]> "..Prefix.."luastop %[line:Имя файла с расширением]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Сдвинуть вверх (Ввести название)$<%[mynick]> "..Prefix.."luaup %[line:Имя файла с расширением]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\Дополнительно\\Сдвинуть вниз (Ввести название)$<%[mynick]> "..Prefix.."luadown %[line:Имя файла с расширением]&#124;")
		Core.SendToUser(UID,"$UserCommand 0 3")
		tScripts = Core.GetScripts()
		for script in pairs(tScripts) do
			local Script = tScripts[script].sName
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\Перезапуск$<%[mynick]> "..Prefix.."reloadlua "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\Показать информацию$<%[mynick]> "..Prefix.."lua_get_info "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\Старт$<%[mynick]> "..Prefix.."luastart "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\Стоп$<%[mynick]> "..Prefix.."luastop "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\Сдвинуть вверх$<%[mynick]> "..Prefix.."luaup "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\Сдвинуть вниз$<%[mynick]> "..Prefix.."luadown "..Script.."&#124;")
		end
	end
end
function OnChat(UID,data)
	local pre,cmd = data:match("^%b<>%s+(%p)(%S+)")
	local bPrm = data:match("^%b<>%s+%p%S+%s+(.+)")
	if pre == Prefix then
				if cmd and cmd == "scriptmoveup" or cmd == "luaup" then
					if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.MoveUpScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, "Скрипт "..bPrm.." перемещён вверх на одну позицию.", sBotName)
						else
							Core.SendToUser(UID,"Ошибка: скрипт "..bPrm.." переместить не удалось.", sBotName)
						end
					else
						Core.SendToUser(UID,"Ошибка. Вы должны указать имя файла.", sBotName)
					end
						else
						Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
					end
					return true
				elseif cmd and cmd == "scriptmovedown" or cmd and cmd == "luadown" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.MoveDownScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, " Скрипт "..bPrm.." перемещён вниз на одну позицию.", sBotName)
						else
							Core.SendToUser(UID,"Ошибка: скрипт "..bPrm.." переместить не удалось.", sBotName)
						end
					else
						Core.SendToUser(UID,"Ошибка. Вы должны указать имя файла.", sBotName)
					end
					else
						Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
				return true
			elseif cmd == "showlua" or cmd == "луаскрипты" then
				if Access[UID.iProfile] == 1 then
					local Scripts = Core.GetScripts()
						local Message = "\n\t"..sHubName.." - Список скриптов:\n"..string.rep("-",70).."\n"
						local mem = 0
						for i, Scripts in ipairs(Scripts) do
							mem = mem + Scripts.iMemUsage
							Message = Message..(("¦ %s ¦ ¦ %s ¦ = ¦ %s ¦ = %s \n"):format(i > 9 and i or "0"..i, Scripts.bEnabled and "ON" or "      ",Scripts.iMemUsage ~= 0 and (" %s Кб"):format(Scripts.iMemUsage) or "      ",Scripts.sName))
						 end
						 Message = Message..(("%s\n¦Текущая версия хаба: %s\n¦Версия Lua плагина: %s\n¦Общее использование памяти скриптами: %sКб\n¦Папка, содержащая скрипты: %s\n+%s"):format(string.rep("-",70),Core.sHubVersion,Core.sLuaPluginVersion,mem,sScriptsDir,string.rep("-",70)))
						Core.SendToUser(UID, Message, sBotName)
			end
			return true
			elseif cmd and cmd == "luastart" or cmd and cmd == "стартлуа" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.StartScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, UID.sNick..", "..bPrm.." был успешно запущен!", sBotName)
						else
							Core.SendToUser(UID,"Ошибка: Не удалось запустить скрипт "..bPrm, sBotName)
						end
					end
					else
					Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
			return true
			elseif cmd and cmd == "luastop" or cmd and cmd == "луастоп" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.StopScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, UID.sNick..", "..bPrm.." был выгружен успешно!", sBotName)
						else
							Core.SendToUser(UID,"Ошибка: Не удалось выгрузить скрипт "..bPrm, sBotName)
						end
					end
					else
					Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
			return true
			elseif cmd and cmd == "reloadlua" or cmd and cmd == "луарелоад" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.RestartScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, UID.sNick..", "..bPrm.." был перезапущен успешно!", sBotName)
						else
							Core.SendToUser(UID,"Ошибка: Не удалось перезапустить скрипт "..bPrm, sBotName)
						end
					end
					else
					Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
			return true
			elseif cmd and cmd == "reload_all_lua" then
				if Access[UID.iProfile] == 1 then
					 Core.RestartScripts(0)
							Core.SendToUser(UID, UID.sNick..", все скрипты были перезапущены!", sBotName)
				else
					Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
			return true
			elseif cmd == "lua_get_info" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						local Scripts =  Core.GetScript(bPrm)
						local sMsg = (("\n%s\n¦ Название: %s \n¦ Статус: %s\n¦ Использование памяти: %s кб\n%s"):format(string.rep("-",70),Scripts.sName,Scripts.bEnabled and "Запущен" or "Не запущен",Scripts.iMemUsage or "",string.rep("-",70)))
						Core.SendToUser(UID, sMsg, sBotName)
					end
				else
				Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
			return true
			elseif cmd == "rh_lua_help" then
				if Access[UID.iProfile] == 1 then
						Core.SendToUser(UID, "\n\t"..string.rep("-",70).."\n\tПомощь по командам управления:\n\t!scriptmoveup <Имя скрипта>\t - Поднять скрипт (Альтернативы: !luaup )\n"..
						"\t!scriptmovedown <Имя скрипта>\t - Опустить скрипт (Альтернативы: !luadown )\n"..
						"\t!showlua \t-Показать список скриптов (Альтернативы: !луаскрипты)\n\t!luastart <Имя скрипта> \t - Запустить скрипт (Альтернативы: !стартлуа)\n"..
                        "\t!luastop <Имя скрипта> \t - Остановить скрипт (Альтеранативы: !луастоп )\n\t!reloadlua <Имя скрипта> \t - Перезапустить скрипт (Альтеративы: !луарелоад )\n\t!reload_all_lua \t - Перезапустить все скрипты\n\t!lua_get_info <Имя скрипта> \t - Показать статус скрипта\n\t!rh_lua_help \t- Эта справка\n\t"..string.rep("-",70), sBotName)
				else
				Core.SendToUser(UID, "Ошибка, у вас нет прав для использования этой команды!", sBotName)
				end
			return true
			
		end
	end
end

function OnError(LUA_errors_msg)
	Core.SendToProfile(0, "Синтаксическая ошибка в скрипте: "..LUA_errors_msg, sBotName)
end
