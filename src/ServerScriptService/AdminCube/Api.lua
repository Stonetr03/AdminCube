-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))
local Settings = require(script.Parent:WaitForChild("Settings"))

local Module = {}
local Commands = {}

function Module:GetRank(p)
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

function Module:InvalidPermissionsNotification(p)
    return true
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

return Module
