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
                return o
            end
        end
        -- Match Display Names
        if Settings.DisplayNames == true then
            for _,o in pairs(game.Players:GetPlayers()) do
                if string.lower(o.DisplayName) == Name then
                    return o
                end
            end
        end
    end
end

function Module:RegisterCommand(Name,Desc,Run)
    print("Register Cmd" .. Name)
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

return Module
