-- Admin Cube - All Rank commands (ex vip/unvip mod/unmod)

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local DataStore = require(script.Parent.Parent:WaitForChild("DataStore"))

-- Vip
Api:RegisterCommand("vip","Makes a player Vip",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Target = Api:GetPlayer(Args[1],p)[1]
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

end,"3;*[player]")

Api:RegisterCommand("unvip","Removes player's vip rank, makes them player rank.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Target = Api:GetPlayer(Args[1],p)[1]
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    if TargetRank == 1 then
                        -- Set rank to Vip
                        DataStore:UpdateData(Target.UserId,"Rank",0)

                        -- Notifications

                        Api:Notification(p,false,"You made " .. Target.Name .. " a player.")
                        Api:Notification(Target,true,"You are now a player.")

                        -- Remove Panel
                        Api:Fire(Target,"RemovePanel",true)
                        task.wait(0.5)
                        local Checker = Target.PlayerGui:FindFirstChild("__AdminCube_Main"):FindFirstChild("AdminPanel")
                        if Checker then
                            Checker:Destroy()
                        end

                    else
                        Api:Notification(p,false,Target.Name .. " Is not a Vip")
                    end
                else
                    Api:InvalidPermissionsNotification(p)
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

end,"3;*[player]")

-- Mod
Api:RegisterCommand("mod","Makes a player Mod",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Target = Api:GetPlayer(Args[1],p)[1]
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    DataStore:UpdateData(Target.UserId,"Rank",2)
                    -- Notifications

                    Api:Notification(p,false,"You made " .. Target.Name .. " a Mod.")
                    Api:Notification(Target,true,"You are now a Mod.")

                    -- Give Admin Panel
                    local ScreenGui = Target.PlayerGui:FindFirstChild("__AdminCube_Main")
                    local Checker = Target.PlayerGui:FindFirstChild("__AdminCube_Main"):FindFirstChild("AdminPanel")
                    if not Checker then
                        task.wait(3)
                        local Panel = script.Parent.Parent.Ui.AdminPanel:Clone()
                        Panel.Parent = ScreenGui
                    end
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

end,"3;*[player]")

Api:RegisterCommand("unmod","Removes player's mod rank, makes them player rank.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Target = Api:GetPlayer(Args[1],p)[1]
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    if TargetRank == 2 then
                        -- Set rank to Vip
                        DataStore:UpdateData(Target.UserId,"Rank",0)

                        -- Notifications

                        Api:Notification(p,false,"You made " .. Target.Name .. " a player.")
                        Api:Notification(Target,true,"You are now a player.")

                        -- Remove Panel
                        Api:Fire(Target,"RemovePanel",true)
                        task.wait(0.5)
                        local Checker = Target.PlayerGui:FindFirstChild("__AdminCube_Main"):FindFirstChild("AdminPanel")
                        if Checker then
                            Checker:Destroy()
                        end
                    else
                        Api:Notification(p,false,Target.Name .. " Is not a Mod")
                    end
                else
                    Api:InvalidPermissionsNotification(p)
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

end,"3;*[player]")

-- Admin
Api:RegisterCommand("admin","Makes a player Admin",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            local Target = Api:GetPlayer(Args[1],p)[1]
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    DataStore:UpdateData(Target.UserId,"Rank",3)
                    -- Notifications

                    Api:Notification(p,false,"You made " .. Target.Name .. " a Admin.")
                    Api:Notification(Target,true,"You are now a Admin.")

                    -- Give Admin Panel
                    local ScreenGui = Target.PlayerGui:FindFirstChild("__AdminCube_Main")
                    local Checker = Target.PlayerGui:FindFirstChild("__AdminCube_Main"):FindFirstChild("AdminPanel")
                    if not Checker then
                        task.wait(3)
                        local Panel = script.Parent.Parent.Ui.AdminPanel:Clone()
                        Panel.Parent = ScreenGui
                    end
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

end,"4;*[player]")

Api:RegisterCommand("unadmin","Removes player's admin rank, makes them player rank.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            local Target = Api:GetPlayer(Args[1],p)[1]
            if Target then
                local TargetRank = Api:GetRank(Target)
                if TargetRank < Api:GetRank(p) then
                    if TargetRank == 3 then
                        -- Set rank to Vip
                        DataStore:UpdateData(Target.UserId,"Rank",0)

                        -- Notifications

                        Api:Notification(p,false,"You made " .. Target.Name .. " a player.")
                        Api:Notification(Target,true,"You are now a player.")

                        -- Remove Panel
                        Api:Fire(Target,"RemovePanel",true)
                        task.wait(0.5)
                        local Checker = Target.PlayerGui:FindFirstChild("__AdminCube_Main"):FindFirstChild("AdminPanel")
                        if Checker then
                            Checker:Destroy()
                        end
                    else
                        Api:Notification(p,false,Target.Name .. " Is not a Admin")
                    end
                else
                    Api:InvalidPermissionsNotification(p)
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

end,"4;*[player]")

return true

