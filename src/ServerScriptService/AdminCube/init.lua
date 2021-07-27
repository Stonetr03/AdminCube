-- Admin Cube

local Settings = require(script:WaitForChild("Settings"))
local DataStoreModule = require(script:WaitForChild("DataStore"))
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(p)
    DataStoreModule:GetDataStore(p.UserId)
end)

return
