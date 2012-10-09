--[[
��������: AntiTor
����: RoLex
�����: Tsd � 15.03.2012 
������� ��� RusHub � ���������: Saymon21
����/����� �����������: 16/03/2012 19:35:20
������ �������: 1.0.1
��������: http://mydc.ru/topic5239.html

��� ������ ������� ����� ������ Ban.

�������� �������: ������ �� ��� ����� �� ��� �������������, ������������ ���������� https://ru.wikipedia.org/wiki/Tor.
����� ������, ��� ���������� ������ �� ������� ������������ �� ��� ����� ������, �� ����� �����������.

�������������� �� Debian GNU/Linux 6.0.4, RusHub 2.3.9, LuaPlugin 2.8

������� ���� ������:

1) curl ������ ���������� �� �� �������. ���� �������� ������� �� ���������� �� ����� ��������� �����������. �������� cron. ��� ����� ���� ������. ���� ��� ���� � ���� ������ �����������. google://.
������ ������ ��� cron: 

$ crontab -l |grep curl
*/50 * * * * /usr/bin/curl -L --retry 3 --connect-timeout 5 -m 15 -s -o "/usr/local/etc/rushub/scripts/AntiTor/torlist.txt" "http://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv"
������ curl ����� ����� ������������ wget, fetch ��� bsd, libwww-perl � �.�.

2) � Ban ���� ��� ExecuteOnTor (����������� ������� ��� ���, ��� ����� � tor'��) ��������� ����������� ������ iptables, ipfw, route, ipchains (����� ������� ����� ����� ������). � ������������ �������� ������� ��������� ������ � ���. ��� �����: google://wipfw. ��� ������� � ��������� ������, sudo, fw, google:// ����������.

3) ��������� ����������� ���������� ����/������� tor-������, �� ������ ���� ���-�� ����� ��� ����� ������� ���� ������, �� ����� ��� ����� �����.
�� ��� ��� ���� ����������� ����� ����������. (�� �������������) 

4) ��������� �������� ���� ������ ������ �� ����������� � Tor ��� ������ ������� � ��� ���������� ������ �������.

5) ��������� �������� OnMCTo. (������������ ��������� � ������� ����). ��������� ����� ��, ��� � ��� ����/��.
]]
		------------ Config ------------
local iUpTimer = 1		-- ������ ���������� Tor ����� � ������� ���������� (� �����).
local bMess = true		-- �������� ��� ��������� ������/���������� ? (true = ��, false = ���).
	-- ��� ������ ����. ���� ������ �������, �� ��� ���������� �������� ���� ��������� �����
	-- ��������� ���� ����������, � ��������� ������ ������ ��� ���������� ����.
local sAdmin = ""
	-- ������� ���������:
local sBanRsn = "���� IP ������������ �.�. �� ����������� Tor."
local iBanMode = 5 -- ����� ��� ��������� ������������?
				-- 0 = ��������� IP
				-- 1 = ��������� ��� �� IP �� ����� � iBanTime
				-- 2 = ���������� � ���� � ��������
				-- 3 = ����� systools_for_blocked
				-- 4 = ���������� � ���� ��� ��������� � ������� �����������.
				-- > 4 = ���������� ����
local iBanTime = iUpTimer*60 -- ����� ���� � ������� ��� iBanMode = 1. �� ��������� ����� ������� ������� ����������, ����� ������� ������.

local check_tor_conn_onstartup = true -- ��������� ��� ����� ���� ������������� �� ����������� � Tor.
local block_chat_mode=2 -- ���� ���� ����� �������� �� ���, �� ����� ����������� ��� ��� � �����. ������: 1 - ����������� � ��������� ����������� � ����������. 2 - ������������ ����� ����������.
local snd_rpt_to_op_for_blocked_msg=true -- ���� ���/�� ��� ����� �������������, ����� ���������� ����������� ���������� � ���, ��� ���� ������� ���-�� �������� � ���/��.

local systools_for_blocked="/usr/bin/sudo /sbin/iptables -A INPUT -p tcp -i eth0 -s %s -j DROP" -- ����� "������ ���������". ������� � ��������� sudo. fw ����������� � google:// ��� /dev/null.
--local systools_for_blocked="/sbin/ipfw add 1 deny all from %s:255.255.255.255 to any" -- ��� �����: google://wipfw.
--local systools_for_blocked="/sbin/ipchains -I input -s %s -j DENY"
--local systools_for_blocked="route add -net %s -netmask 255.255.255.255 127.0.0.1 -blackhole"

local tOpProfiles={ -- ������������ �������.
	[0] = true,
	[1] = true,
	[2] = false,
	[3] = false,
	[-1] = false,
}
		------------ End config ------------
if iBanMode == 0 or iBanMode == 1 then
require"Ban" -- ������� ����� ������ Ban � Ban Manager
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
	sMsg = "������������� "..tostring(c).." TOR-��������."
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
			Core.SendToUser(UID,"��� ��������� ������������ ��� ���� �� ������� ������������� Tor.",sBot)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("���� "..UID.sNick.." ("..UID.sIP..") ��������� �������� � ���: "..(message and message or "").."\n�� ��������� �� ���� ���������, �.� �� ���������� Tor")
			end
			return true
		elseif block_chat_mode == 2 then
			Core.SendToUser(UID,message,UID.sNick)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("���� "..UID.sNick.." ("..UID.sIP..") ��������� �������� � ���: "..(message and message or "").."\n�� ��������� �� ���� ���������, �.� �� ���������� Tor")
			end
			return true
		end
	end
	

end


function OnTo(UID,sData)
	local s,e,to,from,sNick,message = string.find(sData, "%$To:%s(%S+)%sFrom:%s(%S+)%s$<(%S+)%>%s(.*)$")
	if is_tor_connection(UID.sIP) then
		if block_chat_mode == 1 then
			Core.SendToUser(UID,"��� ��������� ������������ ������ ��������� �� ������� ������������� ���� Tor.",sBot,to)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("���� "..UID.sNick.." ("..UID.sIP.." ��������� ��������� �� ����� "..to..", �� ��������� �� ���������, �.� �� ���������� Tor.")
			end
			return true
		elseif block_chat_mode == 2 then
			Core.SendToUser(UID,message,UID.sNick,to)
			if snd_rpt_to_op_for_blocked_msg then
				MsgToOPs("���� "..UID.sNick.." ("..UID.sIP.." ��������� ��������� �� ����� "..to..", �� ��������� �� ���������, �.� �� ���������� Tor.")
			end
			return true
		end
	end
end

function  OnMCTo(UID,sData)
	local to, from, sMsg = sData:match('^$MCTo:%s(%S+)%s$(%S+)(.+)$')
		if is_tor_connection(UID.sIP) then
			if block_chat_mode == 1 then
				Core.SendToUser(UID,"��� ��������� ������������ ������������ ��������� �� ������� ������������� ���� Tor.",sBot)
				if snd_rpt_to_op_for_blocked_msg then
					MsgToOPs("���� "..UID.sNick.." ("..UID.sIP.." ��������� ��������� ������������ ��������� � ������� ���� ����� "..to..", �� ��������� �� ���������, �.� �� ���������� Tor.")
				end
				return true
			elseif block_chat_mode == 2 then
				Core.SendToUser(UID,sMsg,UID.sNick)
				if snd_rpt_to_op_for_blocked_msg then
					MsgToOPs("���� "..UID.sNick.." ("..UID.sIP.." ��������� ��������� ������������ ��������� � ������� ���� ����� "..to..", �� ��������� �� ���������, �.� �� ���������� Tor.")
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
				MsgToOPs("���������� ������ Tor-�������� ���������. � ���������� ���������� ���� ��������� "..tostring(c).." ��������.")
				for i,v in pairs(Core.GetUsers() or {}) do
					if is_tor_connection(v.sIP) then
						ExecuteOnTor(v.UID)
					end
				end
			end
		else
			MsgToOPs("������ ���������� IP tor. ���������� ������� ����.")
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
	local rptmsg = "���������� ������� ������������� TOR-�������. ���� "..user.sNick.." ["..ip.."]. ��������: "
	if iBanMode == 0 then 
			Ban.BanUser(ip,"full", sBot, sBanRsn)
			MsgToOPs(rptmsg.." ��������� ���. ")
		elseif iBanMode == 1 then 
			Ban.BanUser(ip,iBanTime.."m",sBot,sBanRsn)
			MsgToOPs(rptmsg.." ��������� ������� �� IP �� "..iBanTime.." �����. ")
		elseif iBanMode == 2 then 
			Core.SendToUser(user,sBanRsn)
			Core.Disconnect(user)
		elseif iBanMode == 3 then
		os.execute(systools_for_blocked:format(ip))
		MsgToOPs(rptmsg.." ������������ �� ��������. ")
	end	
	if iBanMode == 4 then 
		MsgToOPs(rptmsg.." �������� �� ����. ")
		Core.Disconnect(user)
	end
end

function OnError(msg)
	MsgToOPs(msg)
end
