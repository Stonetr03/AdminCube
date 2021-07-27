-- Admin Cube - Data Store Controller / Handler

local DataStoreService = game:GetService("DataStoreService")
local Settings = require(script.Parent:WaitForChild("Settings"))
local DataStore = DataStoreService:GetDataStore(Settings.DataStoreKey)
local Create = require(script.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")

local Module = {}

local DefaultData = {
    Rank = 0; -- Player
}

local function CheckData(Data)
    local NewData = {}
    for o,i in pairs(DefaultData) do
        if Data[o] then
            NewData[o] = Data[o]
        else
            NewData[o] = i
        end
    end
    return NewData
end

function Module:GetDataStore(Key)
    local Data
    local s,e = pcall(function()
        Data = DataStore:GetAsync(Key)
    end)
    if not s then
        warn(e)
        -- No Data
    end
    if Data == nil then
        Data = DefaultData
    end

    -- Check Data / Update Data
    local NewData = CheckData(Data)

    -- Save to Data Folder
    local EncodedValue = HttpService:JSONEncode(NewData)
    Create("StringValue",script.Parent.Data,{Name = tostring(Key),Value = EncodedValue})
    
    return NewData
end

return Module
