-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))
local Settings = require(script.Parent:WaitForChild("Settings"))

local MessagingService = game:GetService("MessagingService")
local CreateModule = require(script.Parent.CreateModule)

local Module = {}
local Commands = {}

local RS = script.Parent.ReplicatedStorage
RS.Name = "AdminCube"
RS.Parent = game:GetService("ReplicatedStorage")
CreateModule("RemoteEvent",RS,{Name = "ACEvent"})
CreateModule("RemoteFunction",RS,{Name = "ACFunc"})

function Module:GetRank(p)
    if p == "sudo" then
        return 5
    end
    local Data = DataStore:GetData(p.UserId)
    return Data.Rank
end

function Module:GetPlayer(Name,p) -- Name Requested to Find, Player who Sent 
    if Name == "me" then
        return p
    else
        -- Match UserNames
        for _,o in pairs(game.Players:GetPlayers()) do
            if string.lower(o.Name) == Name then
                print("Player Found " .. o.Name)
                return o
            end
        end
        -- Match Display Names
        if Settings.DisplayNames == true then
            for _,o in pairs(game.Players:GetPlayers()) do
                if string.lower(o.DisplayName) == Name then
                    print("Player Found " .. o.Name)
                    return o
                end
            end
        end

        -- Match Username again
        for _,o in pairs(game.Players:GetPlayers()) do
            if string.find(string.lower(o.Name),Name) ~= nil then
                print("Player Found " .. o.Name)
                return o
            end
        end
        
        -- Match Display name again
        if Settings.DisplayNames == true then
            for _,o in pairs(game.Players:GetPlayers()) do
                if string.find(string.lower(o.Name),Name) ~= nil then
                    print("Player Found " .. o.Name)
                    return o
                end
            end
        end
        
    end
end

function Module:RegisterCommand(Name,Desc,Run)
    print("Register Cmd " .. Name)
    Commands[Name] = {
        Name = Name;
        Desc = Desc;
        Run = Run;
    }
end

function Module:GetCommands()
    return Commands
end

function Module:PushRemote(p,Key,Args)
    if p == "all" then
        game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireAllClients(Key,Args)
    else
        game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireClient(p,Key,Args)
    end
end

function Module:ListenRemote(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent.OnServerEvent:Connect(function(p,CallingKey,Args)
        if CallingKey == Key then
            Callback(p,Args)
        end
    end)
end

function Module:PushFunction(p,Key,Args)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc:InvokeClient(p,Key,Args)
end

function Module:ListenFunction(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc.OnServerInvoke = function(p,CallingKey,Args)
        if CallingKey == Key then
            return Callback(p,Args)
        end
    end
end

function Module:AddPanelMenu(Menu)
    Menu.Parent = script.Parent.Ui.AdminPanel.Menus
end

local BroadcastCallbacks = {}

function Module:SubscribeBroadcast(Key,Callback)
    if BroadcastCallbacks[Key] == nil then
        BroadcastCallbacks[Key] = {}
    end
    BroadcastCallbacks[Key][#BroadcastCallbacks[Key] + 1] = Callback

    print(BroadcastCallbacks)
end

function Module:BroadcastMessage(Key,Message)
    print("BroadCast:" .. Key)
    MessagingService:PublishAsync("AdminCube",{Key = Key; Msg = Message;})
end

function Module:CreateRSFolder(FolderName)
    local Check = RS:FindFirstChild(FolderName)
    if Check then
        if Check:IsA("Folder") then
            return Check
        else
            warn("REQUESTED FOLDER ALREADY EXISTS, AND IS NOT A FOLDER")
            return nil
        end
    else
        return CreateModule("Folder",RS,{Name = FolderName})
    end
end

function Module:Notification(p,Image,Text)
    Module:PushRemote(p,"Notification",{Image = Image,Text = Text})
    return true
end

function Module:InvalidPermissionsNotification(p)
    Module:Notification(p,false,"Invalid Permissions")
    return true
end


task.spawn(function()
    MessagingService:SubscribeAsync("AdminCube",function(Data)
        print("Broadcast")
        print(Data)
        for i = 1,#BroadcastCallbacks[Data.Data.Key],1 do
            BroadcastCallbacks[Data.Data.Key][i](Data.Data.Msg)
        end
    end);

    Module:ListenFunction("Response",function()
        return true
    end)
end)

return Module
