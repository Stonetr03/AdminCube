-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Searching = {}

Api:RegisterCommand("find","Checks if a Player is in the game.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            -- Find Player
            if Args[1] then
                local UserId = 0

                local Id
                pcall(function()
                    Id = Players:GetUserIdFromNameAsync(Args[1])
                end)
                if Id ~= nil then
                    UserId = Id
                else
                    local Name
                    pcall(function()
                        Name = Players:GetNameFromUserIdAsync(Args[1])
                    end)
                    if Name ~= nil then
                        UserId = Args[1]
                    else
                        -- Does Not Exist
                        Api:Notification(p,false,string.format("Player %s does not exist.",tostring(Args[1])))
                    end
                end
                if UserId ~= 0 then
                    -- Find
                    local UUID = HttpService:GenerateGUID(false)
                    table.insert(Searching,{
                        UUID = UUID;
                        UserId = UserId;
                        Time = os.time();
                        Player = p;
                    })
                    local Encoded = HttpService:JSONEncode({UserId = UserId, UUID =  UUID;})
                    Api:BroadcastMessage("FindPlayer",Encoded)
                end
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"2;*[string:player];")

Api:SubscribeBroadcast("FindPlayer",function(Encoded)
    local Data = HttpService:JSONDecode(Encoded)
    local Checker = Players:GetPlayerByUserId(Data.UserId)
    if Checker then
        local Msg = HttpService:JSONEncode({UserId = Data.UserId, UUID = Data.UUID, Place = game.PlaceId, Job = game.JobId})
        Api:BroadcastMessage("ReceivePlayer",Msg)
    end
end)

Api:SubscribeBroadcast("ReceivePlayer",function(Encoded)
    local Data = HttpService:JSONDecode(Encoded)
    local UUID,UserId,Place,Job = Data.UUID,Data.UserId,Data.Place,Data.Job
    for _,o in pairs(Searching) do
        if o.UUID == UUID and o.UserId == UserId then
            -- Correct Broadcast
            local p = o.Player
            local Username = ""
            pcall(function()
                Username = Players:GetNameFromUserIdAsync(UserId)
            end)
            if Username == "" then
                Username = tostring(UserId)
            end
            Api:Notification(p,false,Username .. " is in place " .. tostring(Place) .. ";" .. tostring(Job),"Teleport to Server",function()
                -- Teleport to Server
                local Options = Instance.new("TeleportOptions")
                Options.ServerInstanceId = Job
                Options.ShouldReserveServer = false;
                TeleportService:TeleportAsync(Place,{p},Options)
            end)
        end
    end
end)

return true
