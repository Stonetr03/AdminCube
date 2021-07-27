-- Admin Cube - Data Store Controller / Handler

local DataStoreService = game:GetService("DataStoreService")
local Settings = require(script.Parent.Settings)
local DataStore = DataStoreService:GetDataStore(Settings.DataStoreKey)

local Module = {}

function Module:GetDataStore(Key)
    local Data
    local s,e = pcall(function()
        Data = DataStore:GetAsync(Key)
    end)
end

return Module
