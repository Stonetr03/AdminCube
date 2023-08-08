-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("kick","Kicks a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local msg = ""
            table.remove(Args,1)
            for _,v in pairs(Args) do
                msg = msg .. tostring(v)
            end
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                Target:Kick(msg)
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[player];[string:Reason]")

return true