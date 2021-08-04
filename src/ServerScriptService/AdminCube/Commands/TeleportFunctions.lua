-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("teleport","Teleports a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            if Args[2] == nil then
                p.Character.HumanoidRootPart.Position = Target.Character.HumanoidRootPart.Position
            else
                local Target2 = Api:GetPlayer(Args[2],p)
                Target.HumanoidRootPart.Position = Target2.HumanoidRootPart.Position
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

Api:RegisterCommand("tp","Teleports a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            if Args[2] == nil then
                p.Character.HumanoidRootPart.Position = Target.Character.HumanoidRootPart.Position
            else
                local Target2 = Api:GetPlayer(Args[2],p)
                Target.HumanoidRootPart.Position = Target2.HumanoidRootPart.Position
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

Api:RegisterCommand("bring","Teleports player to calling player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            Target.Character.HumanoidRootPart.Position = p.Character.HumanoidRootPart.Position
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end
end)

Api:RegisterCommand("goto","Teleports player to calling player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            p.Character.HumanoidRootPart.Position = Target.Character.HumanoidRootPart.Position
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end
end)

Api:RegisterCommand("summon","Teleports all players to calling player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,o in pairs(game.Players:GetPlayers()) do
                pcall(function()
                    o.Character.HumanoidRootPart.Position = p.Character.HumanoidRootPart.Position
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
end)

return true
