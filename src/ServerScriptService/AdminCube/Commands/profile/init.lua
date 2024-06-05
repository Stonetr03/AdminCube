-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"));
local Datastore = require(script.Parent.Parent:WaitForChild("DataStore"));
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players");

Api:RegisterCommand("profile","Shows a Player's profile.",function(p,args)
    if Api:GetRank(p) >= 2 and typeof(args[1]) == "string" then
        local Name
        local Id
        pcall(function()
            Name = Players:GetNameFromUserIdAsync(args[1]);
        end);
        if Name then
            Id = args[1]
        else
            pcall(function()
                Id = Players:GetUserIdFromNameAsync(args[1]);
            end);
            if Id then
                Name = args[1];
            end
        end;
        if Name and Id then
            local rank = 0
            local banned = false
            local banres = ""
            local bantime = 0;

            local plr = Players:GetPlayerByUserId(Id);
            -- Collect Info
            if plr then
                -- Player is in Server
                rank = Datastore.ServerData[plr.UserId].Rank
                banned = Datastore.ServerData[plr.UserId].Banned
                banres = Datastore.ServerData[plr.UserId].BanReason
                bantime = Datastore.ServerData[plr.UserId].BanTime
            else
                -- Get Record
                local data = Datastore:GetRecord(Id)
                if typeof(data) == "table" then
                    if data.rank then
                        rank = data.Rank
                    end
                    if data.Banned then
                        banned = data.Banned
                    end
                    if data.BanReason then
                        banres = data.BanReason
                    end
                    if data.BanTime then
                        bantime = data.BanTime
                    end
                end
            end
            local info = HttpService:JSONEncode({Name = Name, UserId = Id, Rank = rank, Banned = banned, BanReason = banres, BanTime = bantime});
            local NewUi = script.profileUi:Clone()
            NewUi.info.Value = info;
            local s,e = pcall(function()
                NewUi.Parent = p:FindFirstChild("PlayerGui"):FindFirstChild("__AdminCube_Main")
            end)
            if not s then
                warn(e)
            end
        else
            Api:Notification(p,false,args[1] .. " not found.");
        end
    end

end,"2;*[string:Player]")

return true
