-- Admin Cube - Explorer

local Api = require(script.Parent.Parent:WaitForChild("Api"));
local HttpService = game:GetService("HttpService");

local ApiDump = nil
local EnumList = nil
local Reflection = nil

local Debounce = false
function GetData()
    if Debounce then return end
    if HttpService.HttpEnabled == false then
        ApiDump = {}
        EnumList = {}
        Reflection = {}
        return
    end
    Debounce = true

    local tmpApi
    local tmpRef
    -- Get Api Dump
    local s,e = pcall(function()
        tmpApi = HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json")
    end)
    if s then
        tmpApi = HttpService:JSONDecode(tmpApi);
        if typeof(tmpApi) == "table" and tmpApi.Enums and tmpApi.Classes then
            local tmpEnum = {}
            ApiDump = tmpApi.Classes
            for _,tbl: {Name: string,Items: table} in pairs(tmpApi.Enums) do
                tmpEnum[tbl.Name] = {}
                for _,i: {Name: string, Value: number} in pairs(tbl.Items) do
                    tmpEnum[tbl.Name][i.Name] = i.Value;
                end
            end
            EnumList = tmpEnum
        end
    else
        warn("Error getting ApiDump",e);
    end
    -- Get Reflection
    local s2,e2 = pcall(function()
        tmpRef = HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml")
    end)
    if s2 then
        if typeof(tmpRef) == "string" then
            -- Parse String
            local Order = {}
            local Max = 0
            for m in string.gmatch(tmpRef,"<Properties>(.-)</Properties>") do
                local Prop = string.match(m,'<string name="Name">(.-)</string>')
                local Sort = string.match(m,'<string name="ExplorerOrder">(.-)</string>')
                if typeof(Prop) == "string" and tonumber(Sort) then
                    Order[Prop] = tonumber(Sort)
                    if tonumber(Sort) > Max then
                        Max = tonumber(Sort)
                    end
                end
            end
            Reflection = {Order = Order, Max = Max};
        end
    else
        warn("Error getting Reflection",e2)
    end

    Debounce = false
end

local Allowed = {}
Api:RegisterCommand("explorer","Explorer / Properties Window",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            if Allowed[p] then
                -- Already Has the Explorer
                Api:Notification(p,false,"Explorer Already Detected!")
                return false
            end
            -- Get ApiDump / Reflection if needed
            if not ApiDump or not EnumList or not Reflection then
                GetData();
            end

            -- Give Ui
            Allowed[p] = true
            local NewUi = script.Ui:Clone()
            NewUi.Parent = p:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main")
        end
    end)
    if not s then
        warn(e)
    end

end,"4;*[player]",{"ex"})

Api:OnInvoke("CubeExplorer",function(p,Arg)
    if Allowed[p] then
        if Arg == "Exit" then
            Allowed[p] = nil

        elseif Arg == "Classes" then
            return ApiDump;
        elseif Arg == "Enums" then
            return EnumList;
        elseif Arg == "Reflection" then
            return Reflection;
        end
        return
    end
    return false
end)

game.Players.PlayerRemoving:Connect(function(p)
    if Allowed[p] then
        Allowed[p] = nil
    end
end)

return true
