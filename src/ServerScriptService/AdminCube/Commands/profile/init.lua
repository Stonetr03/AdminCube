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
            Id = tonumber(args[1])
        else
            pcall(function()
                Id = Players:GetUserIdFromNameAsync(args[1]);
            end);
            if Id then
                Name = args[1];
                pcall(function()
                    Name = Players:GetNameFromUserIdAsync(Id);
                end);
            end
        end;
        if Name and Id then
            -- Datastore Items
            local rank = 0
            local firstJoin = 0;
            local timePlayed = 0;
            local timeSession = 0;
            local note = "";

            local plr = Players:GetPlayerByUserId(Id);
            -- Collect Info
            if plr then
                -- Player is in Server
                rank = Datastore.ServerData[plr.UserId].Rank
                firstJoin = Datastore.ServerData[plr.UserId].FirstJoin
                timePlayed = Datastore.ServerData[plr.UserId].TimePlayed
                timeSession = DateTime.now().UnixTimestamp - Datastore.TimeTrack[plr.UserId].stamp
                note = Datastore.ServerData[plr.UserId].Notes
            else
                -- Get Record
                local data = Datastore:GetRecord(Id)
                if typeof(data) == "table" then
                    if data.rank then
                        rank = data.Rank
                    end
                    if data.FirstJoin then
                        firstJoin = data.FirstJoin
                    end
                    if data.TimePlayed then
                        timePlayed = data.TimePlayed
                    end
                    if data.Notes then
                        note = data.Notes
                    end
                end
            end

            -- Ban Items
            local Banned = 0; -- 0:false, 1:true, -1:unknown
            local BanStatus = 0;
            local Page = {};
            local PageEnd = true;
            local BHP: BanHistoryPages
            local success,err = pcall(function()
                BHP = game.Players:GetBanHistoryAsync(Id)
            end);
            if success and BHP then
                local priors = BHP:GetCurrentPage();
                Page = priors;
                PageEnd = BHP.IsFinished;
                if #priors > 0 then
                    local last = priors[1] :: {Ban: boolean, Duration: number, StartTime: string, DisplayReason: string, PrivateReason: string}
                    if last.Ban then
                        -- Possibly already banned
                        local End: number = DateTime.fromIsoDate(last.StartTime).UnixTimestamp + last.Duration;
                        local Now: number = DateTime.now().UnixTimestamp;
                        if last.Duration == -1 or Now < End then
                            -- User is already banned;
                            Banned = 1;
                            BanStatus = last.Duration == -1 and -1 or DateTime.fromIsoDate(last.StartTime).UnixTimestamp + last.Duration;
                        end
                    end
                end
            else
                warn("Error getting BanPages:",err);
                Banned = -1;
            end

            local info = HttpService:JSONEncode({Name = Name, UserId = Id, Rank = rank, FirstJoin = firstJoin, TimePlayed = timePlayed, TimeSession = timeSession, Notes = note, Banned = Banned, Page = Page, PageFinished = PageEnd, Status = BanStatus});
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

Api:OnInvoke("Profile-EditNote", function(p: Player, id: number, text: string)
    if Api:GetRank(p) >= 2 and typeof(id) == "number" and typeof(text) == "string" then
        -- Edit
        local plr = game.Players:GetPlayerByUserId(id);
        if plr then
            -- Is In Server
            Datastore:UpdateData(id, "Notes", text);
        else
            -- Not in server
            local data = Datastore:GetRecord(id);
            if data.Notes ~= text then
                data.Notes = text;
                Datastore:UpdateRecord(id,data);
            end
        end
        return true
    end
    return false
end)

return true
