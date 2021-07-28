-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))

local Module = {}

function Module:GetRank(p)
    local Data = DataStore:GetData(p.UserId)
    return Data.Rank
end

return Module
