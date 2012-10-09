-- **********************************************
-- Simple account bridge rushub to livestreet.lua by Saymon21
-- required luasql & lua-md5
-- Fri Jan 27 20:10:20 CET 2012
-- **********************************************
_TRACEBACK = debug.traceback
require"luasql.mysql"
require"md5"
local err_return_true = false 
local env = luasql.mysql()
-- **********************************************
tdb={
        user = "livestreet",
        pass = "ololo",
        host = "mysql.domain.com",
        tcp_port ="3306",
        db = "livestret",
        pref = "social_",
        charet="cp1251" -- utf8
}
-- **********************************************
function OnStartup()
        connect_to_mysql()      
        Core.AddTimer(1,10*60000, "connect_to_mysql")
end

string.dbformat = function(self, ...)
  local t = {...}
  for k, v in ipairs(t) do
    t[k] = tostring(v):gsub("(['\\\"])", "\\%1")
  end
  return self:format(unpack(t))
end

function connect_to_mysql()
        if not conn or not conn:execute("USE "..tdb.db) then
                conn = assert(env:connect(tdb.db,tdb.user,tdb.pass,tdb.host,tdb.tcp_port))
                if conn then
                        conn:execute("SET NAMES "..tdb.charet)                          
                        return true
                end
        else
                return true
        end
end

function get_user_info(name)
        if name and name ~="" then
                local cur = assert(conn:execute("SELECT user_password FROM `"..tdb.pref.."user` WHERE `user_login`='"..name:dbformat().."'") )
                if cur:numrows() > 0 then
                        local row = cur:fetch({}, "a")
                        cur:close()
                        return true, row.user_password
                else 
                        cur:close()
                        return nil
                end
        end
end

function OnValidateNick(UID, sData)
        local info = get_user_info(UID.sNick)
        if info then
                Core.SendToUser(UID,UID.sNick..", Вы вошли под зарегистрированным аккаунтом. Пожалуйста, введите пароль.",Config.sHubBot)
                return true
        end
end

function OnMyPass(UID, sData) 
        local _,pass = get_user_info(UID.sNick)
        local cachepass = md5.sumhexa(sData:match "^.- (%S+)$" )
        if not cachepass or cachepass ~= pass then 
                Core.SendToUser(UID, "Bad password!\n", Config.sHubBot) 
                Core.SendToUser(UID, "$BadPass")
                Core.Disconnect(UID)
        else
                UID.iProfile = 3
        end
end

function OnError(s)
        print(s)
        if err_return_true then
                return true
        end
end
