-- Admin Cube

local Settings = require(script:WaitForChild("Settings"))
local DataStoreModule = require(script:WaitForChild("DataStore"))
local Players = game:GetService("Players")
local Api = require(script:WaitForChild("Api"))

local ConnectedPlrs = {}

local function CommandRunner(p,str)
    if string.sub(str,1,1) == Settings.Prefix then else
        return
    end

    local Commands,Aliases = Api:GetCommands()
    local s,e = pcall(function()
        str = string.lower(str)
        local Split = str:split(" ")
        local PrefixCommand = Split[1]
        local cmd = PrefixCommand:split(Settings.Prefix)
        local Command = cmd[2]
        if Commands[Command] then
            local args = {}
            for i = 2, #Split,1 do
                table.insert(args,Split[i])
            end
            Commands[Command].Run(p,args)
        elseif Aliases[Command] then
            local args = {}
            for i = 2, #Split,1 do
                table.insert(args,Split[i])
            end
            Commands[Aliases[Command]].Run(p,args)
        else
            Api:Notification(p,false,"Invalid Command")
        end
    end)
    if not s then warn("Command Runner Error : " .. e) end
end

local function PlayerJoined(p)
    if ConnectedPlrs[p] ~= true then
        -- Server Ban
        if DataStoreModule.ServerBans[p.UserId] then
            p:Kick("You are banned from this server.")
        end

        ConnectedPlrs[p] = true
        -- Get Data
        local TempData = DataStoreModule:GetDataStore(p.UserId)
        p.Chatted:Connect(function(c)
            CommandRunner(p,c)
        end)

        -- Check Ban 
        if DataStoreModule.ServerData[p.UserId].Banned == true then
            if DataStoreModule.ServerData[p.UserId].BanTime == -1 then
                -- Perm Ban
                p:Kick("\nYou are Banned from this game.\n" .. DataStoreModule.ServerData[p.UserId].BanReason)
            elseif DataStoreModule.ServerData[p.UserId].BanTime > os.time() then
                -- Ban > current time
                local FormatTime = os.date("!*t",DataStoreModule.ServerData[p.UserId].BanTime)
                local Reason = "\nYou are Banned from this game.\n" .. DataStoreModule.ServerData[p.UserId].BanReason .. "\nYou are banned until " .. FormatTime.month .. "/" .. FormatTime.day .. "/" .. FormatTime.year .. ", " .. FormatTime.hour .. ":" .. FormatTime.min .. " UTC."
                p:Kick(Reason)
            else
                -- Ban < Current Time, Unban
                DataStoreModule.ServerData[p.UserId].Banned = false
            end
        end
        -- Check if on Ban List
        for i = 1,#Settings.Banned,1 do
            if Settings.Banned[i] == p.UserId or Settings.Banned[i] == p.Name then
                p:Kick("You are Banned from this game.")
            end
        end

        -- Ui
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "__AdminCube_Main"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.DisplayOrder = 10;
        ScreenGui.Parent = p:WaitForChild("PlayerGui")
        local NewUi = script.Ui.Public:Clone()
        NewUi.Parent = ScreenGui

        -- Temp Perms
        if Settings.TempPerms == true then
            DataStoreModule:UpdateData(p.UserId,"Rank",0)
        end

        -- Update Rank if on Settings
        -- Group Settings
        for id,g in pairs(Settings.Groups) do
            if p:IsInGroup(id) then
                local Role = p:GetRankInGroup(id)

                for gRank,aRank in pairs(g) do
                    if aRank < 0 then
                        aRank = 0
                    elseif aRank > 4 then
                        aRank = 4
                    end
                    if gRank == Role then
                        -- Is in Group, And is role
                        DataStoreModule:UpdateData(p.UserId,"Rank",aRank)
                    end
                end

            end
        end
        -- Is on Defined Players list
        for i = 1,#Settings.Players,1 do
            if Settings.Players[i] == p.UserId or Settings.Players[i] == p.Name then
                DataStoreModule:UpdateData(p.UserId,"Rank",0)
            end
        end
        -- Is on Defined Vips List
        for i = 1,#Settings.Vips,1 do
            if Settings.Vips[i] == p.UserId or Settings.Vips[i] == p.Name then
                DataStoreModule:UpdateData(p.UserId,"Rank",1)
            end
        end
        -- Is on Defined Mods List
        for i = 1,#Settings.Mods,1 do
            if Settings.Mods[i] == p.UserId or Settings.Mods[i] == p.Name then
                DataStoreModule:UpdateData(p.UserId,"Rank",2)
            end
        end
        -- Is on Defined Admins List
        for i = 1,#Settings.Admins,1 do
            if Settings.Admins[i] == p.UserId or Settings.Admins[i] == p.Name then
                DataStoreModule:UpdateData(p.UserId,"Rank",3)
            end
        end
        -- Is on Defined Owners List
        for i = 1,#Settings.Owners,1 do
            if Settings.Owners[i] == p.UserId or Settings.Owners[i] == p.Name then
                DataStoreModule:UpdateData(p.UserId,"Rank",4)
            end
        end

        task.spawn(function()
            task.wait(5)
            if Api:GetRank(p) == 1 then
                Api:Notification(p,true,"You're a VIP")
            elseif Api:GetRank(p) == 2 then
                Api:Notification(p,true,"You're a Mod")
            elseif Api:GetRank(p) == 3 then
                Api:Notification(p,true,"You're a Admin")
            elseif Api:GetRank(p) == 4 then
                Api:Notification(p,true,"You're a Owner")
            end
        end)

        -- Admin Panel
        if DataStoreModule.ServerData[p.UserId].Rank >= 2 then
            local Panel = script.Ui.AdminPanel:Clone()
            Panel.Parent = ScreenGui
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    PlayerJoined(p)
end)

Players.PlayerRemoving:Connect(function(p)
    -- Save Data and Remove Server Copy of Data
    if ConnectedPlrs[p] ~= nil then
        ConnectedPlrs[p] = nil
        DataStoreModule:ExitDataStore(p.UserId)
    end
end)

game:BindToClose(function()
    for _,p in pairs(game.Players:GetPlayers()) do
        DataStoreModule:ExitDataStore(p.UserId)
    end
    task.wait(5)
end)

-- Register All Commands
for _,o in pairs(script.Commands:GetChildren()) do
    if o:IsA("ModuleScript") then
        require(o)
    end
end
script.Commands.ChildAdded:Connect(function(o)
    if o:IsA("ModuleScript") then
        require(o)
    end
end)

-- Cmd Bar
Api:OnEvent("CmdBar",function(p,c)
    CommandRunner(p,c)
end)

-- Early Joiners
task.delay(1,function()
    for _,p in pairs(game.Players:GetPlayers()) do
        PlayerJoined(p)
    end
end)

return function (Commands)
    pcall(function()
        for _,i in pairs(Commands:GetChildren()) do
            if i:IsA("ModuleScript") then
                i.Parent = script.Commands
            end
        end
    end)
end
