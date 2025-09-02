-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("freeze","Freezes the Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                Target.Character.HumanoidRootPart.Anchored = true
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[players]")

Api:RegisterCommand("unfreeze","Unfreezes the Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                Target.Character.HumanoidRootPart.Anchored = false
            end            
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[players]")

return true