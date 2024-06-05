-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("heal","Heals Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                if Target.Character and Target.Character.Humanoid then
                    Target.Character.Humanoid.Health = Target.Character.Humanoid.MaxHealth
                end
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[player]")

Api:RegisterCommand("health","Sets a Player's Health",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                if Target.Character and Target.Character.Humanoid and tonumber(Args[2]) then
                    Target.Character.Humanoid.Health = tonumber(Args[2])
                end
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[player];*[number:Health]")

Api:RegisterCommand("damage","Damages a Player's Health",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                if Target.Character and Target.Character.Humanoid and tonumber(Args[2]) then
                    Target.Character.Humanoid.Health -= tonumber(Args[2])
                end
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[player];*[number:Damage]")

return true
