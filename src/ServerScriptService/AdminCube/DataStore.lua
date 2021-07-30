-- Admin Cube - Data Store Controller / Handler

local DataStoreService = game:GetService("DataStoreService")
local Settings = require(script.Parent:WaitForChild("Settings"))
local DataStore = DataStoreService:GetDataStore(Settings.DataStoreKey)
local Create = require(script.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")

local Module = {}
local ServerData = {}

local DefaultData = {
    Rank = 0; -- Player
    Banned = false; -- True / False
    BanTime = 0; -- UTC Unban Time
    BanReason = ""; -- Ban Reason
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
    ServerData[Key] = Data
    -- Save to Data Folder
    local EncodedValue = HttpService:JSONEncode(NewData)
    Create("StringValue",script.Parent.Data,{Name = tostring(Key),Value = EncodedValue})
    
    return NewData
end

-- Save Data / Update Data
function Module:SaveDataStore(Key,Data)
    local s,e = pcall(function()
        -- Update String Value
        ServerData[Key] = Data
        local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
        if Checker then
            Checker.Value = HttpService:JSONEncode(Data)
        end

        -- Save to DataStore
        DataStore:SetAsync(Key,Data)
    end)
    if not s then
        warn(e)
    end
    return s
end

-- Used for when Player is Leaving the server
function Module:ExitDataStore(Key,Data)
    -- Save Data
    local s,e = pcall(function()
        DataStore:SetAsync(Key,Data)
    end)
    if not s then
        warn(e)
    end
    -- Remove Server Data
    ServerData[Key] = nil
    local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
    if Checker then
        -- Remove the StringValue we created earlyer
        Checker:Destroy()
    end
    return s
end

function Module:GetData(Key)
    return ServerData[Key]
end

return Module
