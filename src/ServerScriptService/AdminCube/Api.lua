-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))
local Settings = require(script.Parent:WaitForChild("Settings"))

local MessagingService = game:GetService("MessagingService")
local CreateModule = require(script.Parent.CreateModule)

local Module = {}
local Commands = {}
local Aliases = {}

local RS = script.Parent.ReplicatedStorage
RS.Name = "AdminCube"
RS.Parent = game:GetService("ReplicatedStorage")
CreateModule("RemoteEvent",RS,{Name = "ACEvent"})
CreateModule("RemoteFunction",RS,{Name = "ACFunc"})

function Module:GetRank(p)
    if p == "sudo" then
        return 5
    end
    local Data = DataStore.ServerData[p.UserId]
    return Data.Rank
end

function Module:GetPlayer(Name,p) -- Name Requested to Find, Player who Sent 
    if Name == "me" then
        return p
    elseif Name == nil then
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

function Module:RegisterCommand(Name,Desc,Run,Arg,Alias) -- Arg {[Player],[String],etc} -- Alias {"A","B", etc}
    print("Register Cmd " .. Name)
    Commands[Name] = {
        Name = Name;
        Desc = Desc;
        Run = Run;
        Args = Arg;
    }
    if Alias then
        Aliases[Alias] = Name
    end
end

function Module:GetCommands()
    return Commands,Aliases
end

function Module:Fire(p,Key,Args)
    if p == "all" then
        game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireAllClients(Key,Args)
    else
        game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireClient(p,Key,Args)
    end
end

function Module:OnEvent(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent.OnServerEvent:Connect(function(p,CallingKey,Args)
        if CallingKey == Key then
            Callback(p,Args)
        end
    end)
end

function Module:Invoke(p,Key,Args)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc:InvokeClient(p,Key,Args)
end

local RemoteFunctions = {}
function Module:OnInvoke(Key,Callback)
    print("Listen " .. Key)
    table.insert(RemoteFunctions,{
        Key = Key;
        Callback = Callback;
    })
end
game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc.OnServerInvoke = function(p,CallingKey,Args)
    for _,o in pairs(RemoteFunctions) do
        if o.Key == CallingKey then
            return o.Callback(p,Args)            
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

function Module:Notification(p,Image,Text) -- Image - True for Headshot, False for No-Image, Other for image
    Module:Fire(p,"Notification",{Image = Image,Text = Text})
    return true
end

function Module:InvalidPermissionsNotification(p)
    Module:Notification(p,false,"Invalid Permissions")
    return true
end

-- Prompts
local OpenPrompts = {}
function Module:ShowPrompt(p,Prompts,Response)
    if OpenPrompts[p] ~= nil then
        -- Another prompt is open
        return false
    end
    OpenPrompts[p] = {Prompts,Response}

    Module:Fire(p,"Prompts",Prompts)
end
Module:OnEvent("Prompts",function(p,Results)
    if OpenPrompts[p] ~= nil then
        -- Prompt is open
        task.spawn(function()
            OpenPrompts[p][2](Results)
        end)
        OpenPrompts[p] = nil
    end
end)

Module:OnInvoke("GetCommands",function(p)
    if Module:GetRank(p) >= 2 then
        local Cmd = Module:GetCommands()
        return Cmd
    end
end)

task.spawn(function()
    MessagingService:SubscribeAsync("AdminCube",function(Data)
        print("Broadcast")
        print(Data)
        for i = 1,#BroadcastCallbacks[Data.Data.Key],1 do
            BroadcastCallbacks[Data.Data.Key][i](Data.Data.Msg)
        end
    end);

    Module:OnInvoke("Response",function()
        return true
    end)
end)

return Module
