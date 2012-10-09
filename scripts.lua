--[[::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
						��������: Scripts 09/12/2010
						�����: Saymon ( ���� ���� ���������� ������� �� HubMenu for ProkaX 0.4.1.� by alex82 http://mydc.ru/topic1413.html )
				��������: ������ ���������� ���������
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::]]
local sBotName,sScriptsDir,sHubName,sLuaPluginVersion,HubPath = "RH_LuaManager",Core.sScriptsDir,Config.sHubName,Core.sLuaPluginVersion,Core.sMainDir -- ��� ����� ������ �� �������!

AdminMenu = "���� �������������\\"..sLuaPluginVersion -- ����
Prefix = "!"             --	������� ������ ����.

local Access = { -- �������, ���� ����� �������� ���������� ���������
    [0] = 1,	--	�������������
    [1] = 1,	--	������
    [2] = 0,	--	���������
    [3] = 0,	--	��������
    [4] = 0,	--	VIP ������������
    [5] = 0,	--	������������
    [-1] = 0,	--	�����
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
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\���������� ������$<%[mynick]> "..Prefix.."showlua&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\�������� ������ ������� (������ ��������)$<%[mynick]> "..Prefix.."lua_get_info %[line:��� ����� � �����������]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\������������� �������$<%[mynick]> "..Prefix.."reload_all_lua&#124;")
		Core.SendToUser(UID,"$UserCommand 0 3")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\�������$<%[mynick]> "..Prefix.."rh_lua_help&#124;")
		Core.SendToUser(UID,"$UserCommand 0 3")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\���������� (������ ��������)$<%[mynick]> "..Prefix.."reloadlua %[line:��� ����� � �����������]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\����� (������ ��������)$<%[mynick]> "..Prefix.."luastart %[line:��� ����� � �����������]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\���� (������ ��������)$<%[mynick]> "..Prefix.."luastop %[line:��� ����� � �����������]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\�������� ����� (������ ��������)$<%[mynick]> "..Prefix.."luaup %[line:��� ����� � �����������]&#124;")
		Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\�������������\\�������� ���� (������ ��������)$<%[mynick]> "..Prefix.."luadown %[line:��� ����� � �����������]&#124;")
		Core.SendToUser(UID,"$UserCommand 0 3")
		tScripts = Core.GetScripts()
		for script in pairs(tScripts) do
			local Script = tScripts[script].sName
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\����������$<%[mynick]> "..Prefix.."reloadlua "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\�������� ����������$<%[mynick]> "..Prefix.."lua_get_info "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\�����$<%[mynick]> "..Prefix.."luastart "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\����$<%[mynick]> "..Prefix.."luastop "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\�������� �����$<%[mynick]> "..Prefix.."luaup "..Script.."&#124;")
			Core.SendToUser(UID,"$UserCommand 1 3 "..AdminMenu.."\\"..Script.."\\�������� ����$<%[mynick]> "..Prefix.."luadown "..Script.."&#124;")
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
							Core.SendToUser(UID, "������ "..bPrm.." ��������� ����� �� ���� �������.", sBotName)
						else
							Core.SendToUser(UID,"������: ������ "..bPrm.." ����������� �� �������.", sBotName)
						end
					else
						Core.SendToUser(UID,"������. �� ������ ������� ��� �����.", sBotName)
					end
						else
						Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
					end
					return true
				elseif cmd and cmd == "scriptmovedown" or cmd and cmd == "luadown" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.MoveDownScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, " ������ "..bPrm.." ��������� ���� �� ���� �������.", sBotName)
						else
							Core.SendToUser(UID,"������: ������ "..bPrm.." ����������� �� �������.", sBotName)
						end
					else
						Core.SendToUser(UID,"������. �� ������ ������� ��� �����.", sBotName)
					end
					else
						Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
				return true
			elseif cmd == "showlua" or cmd == "����������" then
				if Access[UID.iProfile] == 1 then
					local Scripts = Core.GetScripts()
						local Message = "\n\t"..sHubName.." - ������ ��������:\n"..string.rep("-",70).."\n"
						local mem = 0
						for i, Scripts in ipairs(Scripts) do
							mem = mem + Scripts.iMemUsage
							Message = Message..(("� %s � � %s � = � %s � = %s \n"):format(i > 9 and i or "0"..i, Scripts.bEnabled and "ON" or "      ",Scripts.iMemUsage ~= 0 and (" %s ��"):format(Scripts.iMemUsage) or "      ",Scripts.sName))
						 end
						 Message = Message..(("%s\n�������� ������ ����: %s\n������� Lua �������: %s\n������ ������������� ������ ���������: %s��\n������, ���������� �������: %s\n+%s"):format(string.rep("-",70),Core.sHubVersion,Core.sLuaPluginVersion,mem,sScriptsDir,string.rep("-",70)))
						Core.SendToUser(UID, Message, sBotName)
			end
			return true
			elseif cmd and cmd == "luastart" or cmd and cmd == "��������" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.StartScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, UID.sNick..", "..bPrm.." ��� ������� �������!", sBotName)
						else
							Core.SendToUser(UID,"������: �� ������� ��������� ������ "..bPrm, sBotName)
						end
					end
					else
					Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
			return true
			elseif cmd and cmd == "luastop" or cmd and cmd == "�������" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.StopScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, UID.sNick..", "..bPrm.." ��� �������� �������!", sBotName)
						else
							Core.SendToUser(UID,"������: �� ������� ��������� ������ "..bPrm, sBotName)
						end
					end
					else
					Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
			return true
			elseif cmd and cmd == "reloadlua" or cmd and cmd == "���������" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						Scripts = Core.RestartScript(bPrm)
						if Scripts then
							Core.SendToUser(UID, UID.sNick..", "..bPrm.." ��� ����������� �������!", sBotName)
						else
							Core.SendToUser(UID,"������: �� ������� ������������� ������ "..bPrm, sBotName)
						end
					end
					else
					Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
			return true
			elseif cmd and cmd == "reload_all_lua" then
				if Access[UID.iProfile] == 1 then
					 Core.RestartScripts(0)
							Core.SendToUser(UID, UID.sNick..", ��� ������� ���� ������������!", sBotName)
				else
					Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
			return true
			elseif cmd == "lua_get_info" then
				if Access[UID.iProfile] == 1 then
					if bPrm then
						local Scripts =  Core.GetScript(bPrm)
						local sMsg = (("\n%s\n� ��������: %s \n� ������: %s\n� ������������� ������: %s ��\n%s"):format(string.rep("-",70),Scripts.sName,Scripts.bEnabled and "�������" or "�� �������",Scripts.iMemUsage or "",string.rep("-",70)))
						Core.SendToUser(UID, sMsg, sBotName)
					end
				else
				Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
			return true
			elseif cmd == "rh_lua_help" then
				if Access[UID.iProfile] == 1 then
						Core.SendToUser(UID, "\n\t"..string.rep("-",70).."\n\t������ �� �������� ����������:\n\t!scriptmoveup <��� �������>\t - ������� ������ (������������: !luaup )\n"..
						"\t!scriptmovedown <��� �������>\t - �������� ������ (������������: !luadown )\n"..
						"\t!showlua \t-�������� ������ �������� (������������: !����������)\n\t!luastart <��� �������> \t - ��������� ������ (������������: !��������)\n"..
                        "\t!luastop <��� �������> \t - ���������� ������ (�������������: !������� )\n\t!reloadlua <��� �������> \t - ������������� ������ (�����������: !��������� )\n\t!reload_all_lua \t - ������������� ��� �������\n\t!lua_get_info <��� �������> \t - �������� ������ �������\n\t!rh_lua_help \t- ��� �������\n\t"..string.rep("-",70), sBotName)
				else
				Core.SendToUser(UID, "������, � ��� ��� ���� ��� ������������� ���� �������!", sBotName)
				end
			return true
			
		end
	end
end

function OnError(LUA_errors_msg)
	Core.SendToProfile(0, "�������������� ������ � �������: "..LUA_errors_msg, sBotName)
end
