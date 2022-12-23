-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("panel","Opens Admin Panel from chat.",function(p)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            Api:Fire(p,"OpenPanel")
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;[player]",{"openpanel"})

return true
