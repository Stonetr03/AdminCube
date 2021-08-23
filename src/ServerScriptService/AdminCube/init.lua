-- Admin Cube

local Settings = require(script:WaitForChild("Settings"))
local DataStoreModule = require(script:WaitForChild("DataStore"))
local Players = game:GetService("Players")
local Api = require(script:WaitForChild("Api"))
local CreateModule = require(script.CreateModule)

local ConnectedPlrs = {}
local ServerData = {}

local RS = script.ReplicatedStorage
RS.Name = "AdminCube"
RS.Parent = game:GetService("ReplicatedStorage")
CreateModule("RemoteEvent",RS,{Name = "ACEvent"})

local function CommandRunner(p,str)
    local Commands = Api:GetCommands()
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
        else
            -- Invalid Notification
        end
    end)
    if not s then warn("Command Runner Error : " .. e) end
end

local function PlayerJoined(p)
    if ConnectedPlrs[p] ~= true then
        ConnectedPlrs[p] = true
        -- Get Data
        ServerData[p] = DataStoreModule:GetDataStore(p.UserId)
        p.Chatted:Connect(function(c)
            CommandRunner(p,c)
        end)

        -- Check Ban 
        if ServerData[p].Banned == true then
            if ServerData[p].BanTime == -1 then
                -- Perm Ban
                p:Kick("\nYou are Banned from this game.\n" .. ServerData[p].BanReason)
            elseif ServerData[p].BanTime > tick() then
                -- Ban > current time
                p:Kick("\nYou are Banned from this game.\n" .. ServerData[p].BanReason)
            else
                -- Ban < Current Time, Unban
                ServerData[p].Banned = false
            end
        end
        -- Check if on Ban List
        for i = 1,#Settings.Banned,1 do
            if Settings.Banned[i] == p.UserId or Settings.Banned[i] == p.Name then
                p:Kick("You are Banned from this game.")
            end
        end

        -- Ui
        print("NewUi")
        local NewUi = script.Ui.Public:Clone()
        NewUi.Parent = p:WaitForChild("Backpack")

        -- Temp Perms
        if Settings.TempPerms == true then
            ServerData[p].Rank = 0
        end

        -- Update Rank if on Settings
        -- Is on Defined Players list
        for i = 1,#Settings.Players,1 do
            if Settings.Players[i] == p.UserId or Settings.Players[i] == p.Name then
                ServerData[p].Rank = 0
                DataStoreModule:SaveDataStore(p.UserId,ServerData[p])
            end
        end
        -- Is on Defined Vips List
        for i = 1,#Settings.Vips,1 do
            if Settings.Vips[i] == p.UserId or Settings.Vips[i] == p.Name then
                ServerData[p].Rank = 1
                DataStoreModule:SaveDataStore(p.UserId,ServerData[p])
            end
        end
        -- Is on Defined Mods List
        for i = 1,#Settings.Mods,1 do
            if Settings.Mods[i] == p.UserId or Settings.Mods[i] == p.Name then
                ServerData[p].Rank = 2
                DataStoreModule:SaveDataStore(p.UserId,ServerData[p])
            end
        end
        -- Is on Defined Admins List
        for i = 1,#Settings.Admins,1 do
            if Settings.Admins[i] == p.UserId or Settings.Admins[i] == p.Name then
                ServerData[p].Rank = 3
                DataStoreModule:SaveDataStore(p.UserId,ServerData[p])
            end
        end
        -- Is on Defined Owners List
        for i = 1,#Settings.Owners,1 do
            if Settings.Owners[i] == p.UserId or Settings.Owners[i] == p.Name then
                ServerData[p].Rank = 4
                DataStoreModule:SaveDataStore(p.UserId,ServerData[p])
            end
        end

        -- Admin Panel
        if ServerData[p].Rank >= 2 then
            print("Give Panel")
            local Panel = script.Ui.AdminPanel:Clone()
            Panel.Parent = p:WaitForChild("Backpack")
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    PlayerJoined(p)
end)

Players.PlayerRemoving:Connect(function(p)
    -- Save Data and Remove Server Copy of Data
    DataStoreModule:ExitDataStore(p.UserId, ServerData[p])
    ServerData[p] = nil
    ConnectedPlrs[p] = nil
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
Api:ListenRemote("CmdBar",function(p,c)
    CommandRunner(p,c)
end)

return 1
