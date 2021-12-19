-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("kick","Kicks a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            if Target then
                local msg = ""
                table.remove(Args,1)
                for i,v in pairs(Args) do
                    msg = msg .. tostring(v)
                end
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

end)

return true