-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("teleport","Teleports a player.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            if Args[2] == nil then
                p.Character:SetPrimaryPartCFrame(Target.Character.HumanoidRootPart.CFrame)
            else
                local Target2 = Api:GetPlayer(Args[2],p)
                Target.Character:SetPrimaryPartCFrame(Target2.Character.HumanoidRootPart.CFrame)
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
            local Target = Api:GetPlayer(Args[1],p)
            Target.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame)
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
            local Target = Api:GetPlayer(Args[1],p)
            p.Character:SetPrimaryPartCFrame(Target.Character.HumanoidRootPart.CFrame)
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
                    o.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame)
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

return true
