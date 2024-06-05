-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local TeleportService = game:GetService("TeleportService");

Api:RegisterCommand("teleport","Teleports a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target2 = Api:GetPlayer(Args[2],p)[1]
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                if Target2 then
                    Target.Character:PivotTo(Target2.Character.HumanoidRootPart.CFrame)
                else
                    p.Character:PivotTo(Target.Character.HumanoidRootPart.CFrame)
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

end,"2;*[player];[player]",{"tp"})

Api:RegisterCommand("bring","Teleports player to calling player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                Target.Character:PivotTo(p.Character.HumanoidRootPart.CFrame)
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

Api:RegisterCommand("goto","Teleports player to calling player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)[1]
            if Target then
                p.Character:PivotTo(Target.Character.HumanoidRootPart.CFrame)
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

Api:RegisterCommand("summon","Teleports all players to calling player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,o in pairs(game.Players:GetPlayers()) do
                pcall(function()
                    o.Character:PivotTo(p.Character.HumanoidRootPart.CFrame)
                end)
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end
end,"2")

Api:RegisterCommand("place","Teleports a player to another place.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Targets = Api:GetPlayer(Args[1],p);
            local PlaceId = tonumber(Args[2])
            if Targets and #Targets > 0 and PlaceId then
                TeleportService:TeleportAsync(PlaceId,Targets);
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"3;*[player];*[number:PlaceId]")

return true
