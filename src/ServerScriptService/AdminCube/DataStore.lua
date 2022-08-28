-- Admin Cube - Data Store Controller / Handler

local DataStoreService = game:GetService("DataStoreService")
local Settings = require(script.Parent:WaitForChild("Settings"))
local DataStore = DataStoreService:GetDataStore(Settings.DataStoreKey)
local Create = require(script.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")

local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")

local Module = {
    ServerData = {};
}

local SavingFor = {}
local NeedsSaving = {}
local LastSave = {}
local StopSaving = {}

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
    Module.ServerData[Key] = NewData
    -- Save to Data Folder
    local EncodedValue = HttpService:JSONEncode(NewData)
    Create("StringValue",script.Parent.Data,{Name = tostring(Key),Value = EncodedValue})
    
    SavingFor[Key] = false
    NeedsSaving[Key] = false
    LastSave[Key] = os.time()

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
    local s,e = pcall(function()
        -- Update String Value
        local Checker = script.Parent.Data:FindFirstChild(tostring(Key))
        if Checker then
            Checker.Value = HttpService:JSONEncode(Module.ServerData[Key])
        end

        -- Save to DataStore
        DataStore:SetAsync(Key,Module.ServerData[Key])
    end)
    if not s then
        warn(e)
    else
        NeedsSaving[Key] = false
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
    NeedsSaving[Key] = false
    LastSave[Key] = false
    SavingFor[Key] = false

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

MessagingService:SubscribeAsync("AdminCube-Data-Update",function(Data)
    local Plr = Data.Data.Player
    for _,p in pairs(game.Players:GetPlayers()) do
        if p.UserId == Plr then
            -- Kick Player
            SavingFor[p.UserId] = true;
            task.wait(1)
            SavingFor[p.UserId] = true;

            p:Kick("Data updated by another server.")
        end
    end
end);


return Module
