-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("freeze","Freezes the Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            Target.Character.HumanoidRootPart.Anchored = true
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end)

Api:RegisterCommand("unfreeze","Unfreezes the Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            Target.Character.HumanoidRootPart.Anchored = false
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