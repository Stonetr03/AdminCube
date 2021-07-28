-- Admin Cube

local Settings = require(script:WaitForChild("Settings"))
local DataStoreModule = require(script:WaitForChild("DataStore"))
local Players = game:GetService("Players")
local Api = require(script:WaitForChild("Api"))

local ServerData = {}

Players.PlayerAdded:Connect(function(p)
    -- Get Data
    ServerData[p] = DataStoreModule:GetDataStore(p.UserId)

end)

Players.PlayerRemoving:Connect(function(p)
    -- Save Data and Remove Server Copy of Data
    DataStoreModule:ExitDataStore(p.UserId, ServerData[p])
    ServerData[p] = nil
    
end)

return 1
