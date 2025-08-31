-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("kick","Kicks a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local targets = Api:GetPlayer(Args[1],p)
            local msg = ""
            table.remove(Args,1)
            for _,v in pairs(Args) do
                msg = msg .. tostring(v)
            end
            for _,Target in pairs(targets) do
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

end,"2;*[players];[string:Reason]")

return true