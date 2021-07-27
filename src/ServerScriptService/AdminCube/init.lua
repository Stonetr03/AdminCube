-- Admin Cube

local Settings = require(script:WaitForChild("Settings"))
local DataStoreModule = require(script:WaitForChild("DataStore"))
local Players = game:GetService("Players")

local ServerData = {}

Players.PlayerAdded:Connect(function(p)
    ServerData[p] = DataStoreModule:GetDataStore(p.UserId)
    
end)

return 1
