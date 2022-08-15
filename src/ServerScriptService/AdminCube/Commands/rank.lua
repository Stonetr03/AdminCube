-- Admin Cube - All Rank commands (ex vip/unvip mod/unmod)

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local DataStore = require(script.Parent.Parent:WaitForChild("DataStore"))

-- Vip
Api:RegisterCommand("vip","Makes a player Vip",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Target = Api:GetPlayer(Args[1],p)
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    DataStore:UpdateData(Target.UserId,"Rank",1)
                    -- Notifications

                    Api:Notification(p,false,"You made " .. Target.Name .. " a Vip.")
                    Api:Notification(Target,true,"You are now a Vip.")
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

end)

Api:RegisterCommand("unvip","Removes player's vip rank, makes them player rank.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Target = Api:GetPlayer(Args[1],p)
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    -- Set rank to Vip
                    DataStore:UpdateData(Target.UserId,"Rank",0)

                    -- Notifications

                    Api:Notification(p,false,"You made " .. Target.Name .. " a player.")
                    Api:Notification(Target,true,"You are now a player.")
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

end)

return true

