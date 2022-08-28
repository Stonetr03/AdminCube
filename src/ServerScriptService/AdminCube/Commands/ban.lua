-- Admin Cube

local Players = game:GetService("Players")
local Api = require(script.Parent.Parent:WaitForChild("Api"))
local DataStore = require(script.Parent.Parent:WaitForChild("DataStore"))
local StrMod = require(script.Parent.Parent.StrMod)

local cache = {} -- https://developer.roblox.com/en-us/api-reference/function/Players/GetUserIdFromNameAsync
function getUserIdFromUsername(name)
	if cache[name] then return cache[name] end
	local player = game.Players:FindFirstChild(name)
	if player then
		cache[name] = player.UserId
		return player.UserId
	end 
	local id
	pcall(function ()
		id = game.Players:GetUserIdFromNameAsync(name) 
	end)
	cache[name] = id
	return id
end

-- Default Time = 1 Hour = 3600 Seconds
local Matches = {
    ["d"] = {"Day(s)",24};
    ["day"] = {"Day(s)",24};
    ["days"] = {"Day(s)",24};
    ["m"] = {"Month(s)",720};
    ["month"] = {"Month(s)",720};
    ["months"] = {"Month(s)",720};
    ["y"] = {"Year(s)",8760};
    ["year"] = {"Year(s)",8760};
    ["years"] = {"Year(s)",8760};
    ["h"] = {"Hour(s)",1};
    ["hour"] = {"Hour(s)",1};
    ["hours"] = {"Hour(s)",1};
    ["min"] = {"Minute(s)",0.016};
    ["mins"] = {"Minute(s)",0.016};
    ["minute"] = {"Minute(s)",0.016};
    ["minutes"] = {"Minute(s)",0.016};
}
local function MatchString(String)
    for i,o in pairs(Matches) do
        if i == string.lower(String) then
            return o
        end
    end
    return Matches.d
end

Api:RegisterCommand("ban","Opens ban prompt.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then

             -- Show Prompt
             Api:ShowPrompt(p,{
                Title = "Ban";
                Prompt = {
                    [1] = {
                        Title = "Player";
                        Type = "String";
                        DefaultValue = "roblox";
                    };
                    [2] = {
                        Title = "Permanent Ban";
                        Type = "Boolean";
                        DefaultValue = true;
                    };
                    [3] = {
                        Title = "Ban time";
                        Type = "String";
                        DefaultValue = "1d";
                    };
                    [4] = {
                        Title = "Ban Reason";
                        Type = "String";
                        DefaultValue = "The ban hammer has spoken.";
                    };
                };
            },function(Response)
                -- Resonse
                if typeof(Response) == "table" then
                    
                    if Response[1] == true then
                        
                        -- Todo
                        -- Check player name or Userid, Does not have to be in server.

                        local UserId = getUserIdFromUsername(Response[2][1])
                        if typeof(UserId) == "number" then
                            -- Is userid

                            -- New datastore functions GetRecord and UpdateRecord to change the datastore value of someone not in the server.
                            local PermBan = Response[2][2]
                            local BanTime = Response[2][3]
                            local Reason = Response[2][4]

                            if typeof(PermBan) ~= "boolean" then
                                Api:Notification(p,false,"Invalid Response, perm ban not boolean")
                                return false
                            end
                            if typeof(BanTime) ~= "string" then
                                if PermBan == false then
                                    Api:Notification(p,false,"Invalid Response, Ban time not given")
                                    return false
                                end
                            end
                            if typeof(Reason) ~= "string" then
                                Reason = "The ban hammer has spoken!"
                            end

                            -- New Prompt
                            local Content = Players:GetUserThumbnailAsync(UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)

                            local LengthUTC = 0
                            local LengthText = ""
                            if PermBan == true then
                                LengthText = "Perm Ban"
                            else

                                -- Get Numbers
                                local Numbers = StrMod:RemoveLetters(BanTime)
                                if typeof(Numbers) ~= "number" then
                                    Numbers = 1
                                end
                                -- Get Text
                                local Text = StrMod:RemoveSpaces(StrMod:RemoveNumbers(BanTime))
                                if typeof(Text) ~= "string" then
                                    Text = "d"
                                end
                                local Matched = MatchString(Text)
                                LengthText = Numbers .. " " .. Matched[1]

                                -- UTC Time
                                local SecondsToAdd = (Numbers * Matched[2]) * 3600
                                LengthUTC = os.time() + SecondsToAdd
                            end
                            task.wait(0.5)
                            Api:ShowPrompt(p,{
                                Title = "Confirm Ban";
                                Prompt = {
                                    [1] = {
                                        Title = "Player";
                                        Type = "Image";
                                        Image = Content,
                                        Text1 = Response[2][1],
                                        Text2 = tostring(UserId),
                                        Text3 = "Length : " .. LengthText,
                                        Text4 = "Reason : " .. tostring(Reason)
                                    };
                                };
                            },function(NewResponse)
                                if NewResponse[1] == true then

                                    -- Ban Player
                                    local Record = DataStore:GetRecord(UserId)
                                    Record.Banned = true;
                                    if PermBan == true then
                                        Record.BanTime = -1
                                    else
                                        Record.BanTime = LengthUTC
                                    end
                                    Record.BanReason = Reason

                                    -- Update Player
                                    DataStore:UpdateRecord(UserId,Record)

                                    -- Check if player is in server
                                    if Players:GetPlayerByUserId(UserId) then
                                        local FormatTime = os.date("!*t",LengthUTC)
                                        local CurrentBanReason = "\nYou are Banned from this game.\n" .. Reason .. "\nYou are banned until " .. FormatTime.month .. "/" .. FormatTime.day .. "/" .. FormatTime.year .. ", " .. FormatTime.hour .. ":" .. FormatTime.min .. " UTC."
                                        Players:GetPlayerByUserId(UserId):Kick(CurrentBanReason)
                                    end

                                    Api:Notification(p,Content,Response[2][1] .. " has been banned from the game.")

                                end
                            end)
                        end

                    end

                end
            end)

        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end)

return true
