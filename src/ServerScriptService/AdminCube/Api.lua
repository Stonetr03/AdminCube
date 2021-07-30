-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))

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
