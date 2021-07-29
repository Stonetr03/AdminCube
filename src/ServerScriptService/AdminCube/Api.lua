-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))

local Module = {}

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

return Module
