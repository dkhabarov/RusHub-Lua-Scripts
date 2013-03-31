-- ***************************************************************************
-- ipinfodb - This is a script for RusHub to get whois information about ip.
-- Copyright (c) 2013 Denis 'Saymon21' Khabarov (saymon@hub21.ru)

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License version 3
-- as published by the Free Software Foundation.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ***************************************************************************
def_config = {
	api_key = "",
	call_url="http://api.ipinfodb.com/v3/ip-city/?key=%s&ip=%s&format=json",
	allow_prefix = {["!"]=true,},
}

acl = {
	[0] = {
		["tcmds"] = {
			["ipinfodb"] = true,
		},
	},
}
local botname = Config.sHubBot
local http = require"socket.http"
local json = require"json" -- https://github.com/craigmj/json4lua/blob/master/json4lua/json/json.lua
http.TIMEOUT = 2


def_commands = {
	["ipinfodb"] = {
		["acl"] = function (UID, cmd, sData)
			return check_acl(UID, cmd)
		end,
	
		["cmd"] = function (UID, cmd, sData)
			if not sData or sData == "" then
				return true, "Error. See. +"..cmd.." -h for get more details."
			end
			if not is_ipv4(sData) then
				return true, "This is not IPv4 address"
			end
			local msg = query(sData)
			if msg then
				return true, msg
			else 
				return true, "?"
			end
		end,
	
		["man"] = function (UID, cmd, sData)
			 return true, "\r\nNAME:\r\n\t!"..cmd.."\r\nSYNOPSIS:\r\n\t!"..cmd.." [ -h ] ipaddress\r\nDESCRIPTION:\r\n\t"..cmd.." - command to information about 'ipaddress'.\r\nOPTIONS:\r\n\t-h\t Show this help\nEXAMPLE USAGE:\r\n\t!"..cmd.." 8.8.8.8\r\n"
		end,
	},
}


function query(where)
	local msg = ""
	local http_res, http_code = http.request(def_config.call_url:format(def_config.api_key, where))
	if http_code == 200 then
		local result = json.decode(http_res)
		if result and result.statusCode == "OK" then
			msg=msg..("IP Address: %s\r\nCountry Name: %s\r\nRegion: %s\r\nCity: %s\r\nTimeZone: %s"):format(result.ipAddress, result.countryName,result.regionName,result.cityName, result.timeZone)
		elseif result.statusCode ~= "OK" then
			msg=msg.."Service error: "..result.statusMessage
		end
	else 
		msg = msg.."Unable to get info: http error="..tostring(http_code)
	end
	return msg
end


function check_acl (UID, cmd)
	if cmd then
		local profile=UID.iProfile
		if acl[profile] and acl[profile].tcmds and acl[profile].tcmds[cmd] then
			return true
		else
			return false, "Access denied!" 
		end
	else
		error("Class 'account' function 'check_acl' 'cmd' is a nil value, but expected string")
	end
end

-- Handler data in chat.
function OnChat(UID, sData)
	local prefix, cmd = sData:match("^%b<>%s(%p)(%S+)")
	if prefix and cmd and def_config.allow_prefix[prefix] and def_commands[cmd] then		
		sData = sData:match("^%b<>%s%p%S+%s+(.+)")
		local aclbool, acl_reason = def_commands[cmd]["acl"](UID, cmd)
		if aclbool then
			local res, msg = def_commands[cmd][(sData and sData:find("^%-[Hh]$")) and "man" or "cmd"](UID, cmd, sData)
			if res then
				Core.SendToUser(UID, msg, botname)
			end
			collectgarbage("collect")
		else
			Core.SendToUser(UID, acl_reason, botname)
		end
		return 1
	end
end

function is_ipv4(str)
	if str:find("^%d+%.%d+%.%d+%.%d+$") then --can do better.
		return true
	end
end

function OnError(s)
	Core.SendToProfile(0,s)
end
