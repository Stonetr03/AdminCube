-- Admin Cube - Data Store Controller / Handler

local DataStoreService = game:GetService("DataStoreService")
local Settings = require(script.Parent:WaitForChild("Settings"))
local DataStore
local Create = require(script.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local MessagingService = game:GetService("MessagingService")

local Module = {
    ServerData = {};
    ServerBans = {};
    isFake = false;
}

local RetryAmount = 3; -- Amount of times to retry when getting data errors

if RunService:IsStudio() then
    local s,_ = pcall(function()
        DataStore = DataStoreService:GetDataStore(Settings.DataStoreKey)
    end)
    if not s or not DataStore then
        -- No Access to Api Services
        Module.isFake = true;
    end
else
    DataStore = DataStoreService:GetDataStore(Settings.DataStoreKey)
end

local SavingFor = {}
local NeedsSaving = {}
local LastSave = {}
local StopSaving = {}
local KeyInfo = {}

local DefaultData = {
    Rank = 0; -- Player
    Banned = false; -- True / False
    BanTime = 0; -- UTC Unban Time
    BanReason = ""; -- Ban Reason
}

local function CheckData(Data)
    if typeof(Data) ~= "table" then
        Data = {}
    end

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
    local Data, tmpKeyInfo
    local try = 0
    while try < RetryAmount and Data == nil do
        local s,e = pcall(function()
            if Module.isFake then return end
            Data, tmpKeyInfo = DataStore:GetAsync(Key)
        end)
        if s then
            if Data == nil then
                Data = DefaultData
            end
        else
            -- No Data - Retry or Kick
            warn("Failed to get data, retry " .. try .. ", error:",e)
            task.wait(5);
        end
        try+=1;
    end
    if Data == nil then
        -- Something went wrong
        if Settings.KickOnDataFail then
            return false
        else
            StopSaving[Key] = true
            Data = DefaultData
        end
    end

    -- Check Data / Update Data
    local NewData = CheckData(Data)
    Module.ServerData[Key] = NewData
    -- Save to Data Folder
    local EncodedValue = HttpService:JSONEncode(NewData)
    Create("StringValue",script.Parent.Data,{Name = tostring(Key),Value = EncodedValue})

    SavingFor[Key] = false
    NeedsSaving[Key] = false
    LastSave[Key] = os.time()
    KeyInfo[Key] = tmpKeyInfo;

    return NewData
end

-- Save Data
function SaveDataStore(Key)
    if Settings.TempPerms == true then
        return false
    end
    if SavingFor[Key] == true then
        return false
    end
    SavingFor[Key] = true
    local newValue, newKeyInfo
    local s,e = pcall(function()
        -- Update String Value
        local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
        if Checker then
            Checker.Value = HttpService:JSONEncode(Module.ServerData[Key])
        end

        -- Save to DataStore
        if Module.isFake then return end
        if StopSaving[Key] == true then return end
        newValue, newKeyInfo = DataStore:UpdateAsync(Key,function(currentValue: any, currentKeyInfo: DataStoreKeyInfo): any | nil
            if KeyInfo[Key] and currentKeyInfo.UpdatedTime > KeyInfo[Key].UpdatedTime then
                -- Data was updated by another server
                Module.ServerData[Key] = currentValue;
                return nil;
            end
            -- Update Data
            return Module.ServerData[Key], {Key}
        end)
    end)
    if not s then
        warn(e)
    else
        NeedsSaving[Key] = false
        if newValue ~= nil and newKeyInfo ~= nil then
            Module.ServerData[Key] = newValue;
            KeyInfo[Key] = newKeyInfo;
        end
    end
    LastSave[Key] = os.time() + 60
    SavingFor[Key] = false
    return s
end

function Module:SaveData()
    for Key,ToUpdate in pairs(NeedsSaving) do
        if ToUpdate == true then

            if LastSave[Key] < os.time() then
                SaveDataStore(Key)
            end

        end
    end
end

-- Used for when Player is Leaving the server
function Module:ExitDataStore(Key)
    -- Remove Server Data
    local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
    if Checker then
        -- Remove the StringValue we created earlyer
        Checker:Destroy()
    end

    if NeedsSaving[Key] == true then
        SaveDataStore(Key)
    end

    Module.ServerData[Key] = nil
    NeedsSaving[Key] = nil
    LastSave[Key] = nil
    SavingFor[Key] = nil
    StopSaving[Key] = nil
    KeyInfo[Key] = nil

    return
end

function Module:UpdateData(Key,Name,Value)
    if Module.ServerData[Key][Name] == Value then
        return -- Already Current Value
    end

    Module.ServerData[Key][Name] = Value
    local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
        if Checker then
            Checker.Value = HttpService:JSONEncode(Module.ServerData[Key])
        end
    NeedsSaving[Key] = true
    Module:SaveData()
end

function Module:GetRecord(Key)
    local Data
    local s,e = pcall(function()
        if Module.isFake then warn("Unable to get record, no api services") return end
        Data = DataStore:GetAsync(Key)
    end)
    if not s then
        warn(e)
        -- No Data
    end
    return CheckData(Data)
end

function Module:UpdateRecord(Key,NewValue)
    if Module.ServerData[Key] == nil then

        local s,e = pcall(function()
            -- Save to DataStore
            if Module.isFake then warn("Unable to update record, no api services") return end
            if StopSaving[Key] == true then return end
            DataStore:SetAsync(Key,NewValue)
        end)
        if not s then
            warn(e)
            return false
        end

        -- Notify other server
        MessagingService:PublishAsync("AdminCube-Data-Update",{Player = Key})

        return true
    else

        Module.ServerData[Key] = NewValue
        NeedsSaving[Key] = true
        SaveDataStore(Key)
    end

end

function Module:ServerBan(Key, Banned)
    if Banned == true then
        Module.ServerBans[Key] = true
    else
        if Module.ServerBans[Key] then
            Module.ServerBans[Key] = nil
        end
    end
end

task.spawn(function()
    pcall(function()
        MessagingService:SubscribeAsync("AdminCube-Data-Update",function(Data)
            local Plr = Data.Data.Player
            for _,p in pairs(game.Players:GetPlayers()) do
                if p.UserId == Plr then
                    -- Kick Player
                    StopSaving[p.UserId] = true;

                    p:Kick("Data updated by another server.")
                end
            end
        end);
    end)
end)


return Module
