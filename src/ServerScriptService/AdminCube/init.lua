-- Admin Cube

local Settings = require(script:WaitForChild("Settings"))
local DataStoreModule = require(script:WaitForChild("DataStore"))
local Players = game:GetService("Players")

local ServerData = {}

local function CommandRunner(p,str)
    local PrefixLen = string.len(Settings.Prefix)
    local split = string.split(str," ")
    
    if string.sub(split[1],1,PrefixLen) == Settings.Prefix then
        
    end
end

Players.PlayerAdded:Connect(function(p)
    -- Get Data
    ServerData[p] = DataStoreModule:GetDataStore(p.UserId)
    p.Chatted:Connect(function(c)
        CommandRunner(p,c)
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    -- Save Data and Remove Server Copy of Data
    DataStoreModule:ExitDataStore(p.UserId, ServerData[p])
    ServerData[p] = nil

end)

return 1
