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

-- Save Data / Update Data
function Module:SaveDataStore(Key,Data)
    local s,e = pcall(function()
        DataStore:SetAsync(Key,Data)
        -- Update String Value
        local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
        if Checker then
            Checker.Value = HttpService:JSONEncode(Data)
        end
    end)
    if not s then
        warn(e)
    end
    return s
end

-- Used for when Player is Leaving the server
function Module:ExitDataStore(Key,Data)
    local s,e = pcall(function()
        DataStore:SetAsync(Key,Data)
    end)
    if not s then
        warn(e)
    end
    local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
    if Checker then
        -- Remove the StringValue we created earlyer
        Checker:Destroy()
    end
    return s
end

return Module
