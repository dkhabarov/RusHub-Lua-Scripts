-- ***************************************************************************
-- whois - This is a script for RusHub to get whois information about ip.
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
	rest={
		call_address="http://geoip-api.hub21.ru/%s",
	},
	allow_prefix = {["+"]=true,["!"]=true},
}

acl = {
	[0] = {
		["tcmds"] = {
			["whois"] = true,
		},
	},
}
local botname = Config.sHubBot
local http = require"socket.http"
local url = require"socket.url"
local json = require"json" -- https://github.com/craigmj/json4lua/blob/master/json4lua/json/json.lua
http.TIMEOUT = 5

def_commands = {
	["whois"] = {
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

function get_googlemap(lat,lon, city, country)
	if not country then country="" end
	if not city then city="" end
	if lat and lon then
		return "http://maps.google.ru/maps?hl=ru&ll="..lat..","..lon.."&q="..url.escape(city).."+"..url.escape(country).."&z=6&output=embed"
	end
end
--[[
JSON result:
{
	"city": "Cheboksary", 
	"region_name": "16", 
	"ipstart": "109.248.0.0", 
	"ipend": "109.248.255.255", 
	"area_code": 0, 
	"time_zone": "Europe/Samara", 
	"dma_code": 0, 
	"metro_code": null, 
	"country_code3": "RUS", 
	"latitude": 56.132200000000012, 
	"postal_code": "", 
	"longitude": 47.251900000000006, 
	"country_code": "RU", 
	"country_name": "Russian Federation", 
	"org": "AS43660 Shupashkartrans-K Ltd.", 
	"continent": "EU"
}

Lua table:

return {
	["country_name"] = "Russian Federation",
	["continent"] = "EU",
	["org"] = "AS43660 Shupashkartrans-K Ltd.",
	["dma_code"] = 0,
	["country_code"] = "RU",
	["longitude"] = 47,2519,
	["area_code"] = 0,
	["ipend"] = "109.248.255.255",
	["latitude"] = 56,1322,
	["city"] = "Cheboksary",
	["ipstart"] = "109.248.0.0",
	["region_name"] = "16",
	["time_zone"] = "Europe/Samara",
	["postal_code"] = "",
	["country_code3"] = "RUS",
}
]]

function query(where)
	local msg = ""
	local http_res, http_code = http.request(def_config.rest.call_address:format(where))
	if http_code == 200 then
		local result = json.decode(http_res)
		if result['status'] and result['status']=='error' then
				return "Error: "..result['message']
		elseif result ~= nil then
			msg = msg..("Result for: %s\r\n"):format(where)
			if result['country_name'] then
				msg=msg..("Country: %s\r\n"):format(result['country_name'])
			end
			if result['continent'] then
				msg=msg..("Continent: %s\r\n"):format(result['continent'])
			end
			if result['org'] then
				msg=msg..("ISP: %s\r\n"):format(result['org'])
			end
			if result['city'] then
				msg=msg..("City: %s\r\n"):format(result['city'])
			end
			if result['ipstart'] and result['ipend'] then
				msg=msg..("Network addressing: %s-%s\r\n"):format(result['ipstart'], result['ipend'])
			end
			if result['time_zone'] then
				msg=msg..("TimeZone: %s\r\n"):format(result['time_zone'])
			end
			if result['latitude'] and result['longitude'] then
				msg=msg..("Google map: %s\r\n"):format(get_googlemap(result['latitude'],result['longitude'],result['city'],result['country_name']))
			end
		end
	elseif http_code == 429 then -- RFC 6585.
		msg=msg.."[rate limiting] Too many requests. Please, try again later."
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

function OnError(msg)
	Core.SendToProfile(0, msg, botname)
end
