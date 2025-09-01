-- Admin Cube

local Players = game:GetService("Players")
local Api = require(script.Parent.Parent:WaitForChild("Api"))
local DataStore = require(script.Parent.Parent:WaitForChild("DataStore"))
local GroupService = game:GetService("GroupService")
local StrMod = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("StrMod")) :: any
local Log = require(script.Parent.Parent:WaitForChild("Log"))

local cache = {} -- https://developer.roblox.com/en-us/api-reference/function/Players/GetUserIdFromNameAsync
function getUserIdFromUsername(name: string): number
    if cache[name] then return cache[name] end
    local player = game.Players:FindFirstChild(name)
    if player then
        cache[name] = player.UserId
        return player.UserId
    end
    local id
    local s,_ = pcall(function()
        id = game.Players:GetUserIdFromNameAsync(name)
    end)
    if s then
        cache[name] = id
        return id
    end
    -- UserId not found
    return 0;
end
local cache2 = {}
function getNameFromUserId(UserId: number | string): string
    if tonumber(UserId) == nil then return "" end;
    if typeof(UserId) ~= "number" then UserId = tonumber(UserId) :: number end
    if cache2[UserId] then return cache2[UserId] end
    local player = game.Players:GetPlayerByUserId(UserId)
    if player then
        cache2[UserId] = player.Name;
        return player.Name
    end
    local name
    local s,_ = pcall(function()
        name = game.Players:GetNameFromUserIdAsync(UserId);
    end)
    if s then
        return name
    end
    -- Name not found
    return "";
end

-- Default Time = 1 Hour = 3600 Seconds
local Matches = {
    ["d"] = {"Day(s)",86400};
    ["day"] = {"Day(s)",86400};
    ["days"] = {"Day(s)",86400};
    ["m"] = {"Month(s)",86400};
    ["month"] = {"Month(s)",2592000};
    ["months"] = {"Month(s)",2592000};
    ["y"] = {"Year(s)",31536000};
    ["year"] = {"Year(s)",31536000};
    ["years"] = {"Year(s)",31536000};
    ["h"] = {"Hour(s)",3600};
    ["hour"] = {"Hour(s)",3600};
    ["hours"] = {"Hour(s)",3600};
    ["min"] = {"Minute(s)",60};
    ["mins"] = {"Minute(s)",60};
    ["minute"] = {"Minute(s)",60};
    ["minutes"] = {"Minute(s)",60};
    ["s"] = {"Second(s)",1};
    ["sec"] = {"Second(s)",1};
    ["second"] = {"Second(s)",1};
    ["seconds"] = {"Second(s)",1}
}
local function MatchString(String)
    for i,o in pairs(Matches) do
        if i == string.lower(String) then
            return o
        end
    end
    return Matches.d
end

Api:RegisterCommand("ban","Bans a player.",function(p: Player, args: {string})
    if Api:GetRank(p) >= 3 then
        local Target = args[1]
        local player = ""
        if Target and typeof(Target) == "string" then
            player = Target
        end

        -- Prompt
        Api:ShowPrompt(p,{
            Title = "Ban";
            Prompt = {
                [1] = {
                    Title = "Player";
                    Type = "String";
                    DefaultValue = player;
                };
                [2] = {
                    Title = "Permanent Ban";
                    Type = "Boolean";
                    DefaultValue = true;
                };
                [3] = {
                    Title = "Duration";
                    Type = "String";
                    DefaultValue = "1d";
                };
                [4] = {
                    Title = "Display Reason";
                    Type = "String";
                    DefaultValue = "The ban hammer has spoken.";
                };
                [5] = {
                    Title = "Private Reason";
                    Type = "String";
                    DefaultValue = "";
                    PlaceholderValue = "Hidden from player";
                };
                [6] = {
                    Title = "Apply to All Places";
                    Type = "Boolean";
                    DefaultValue = true;
                };
                [7] = {
                    Title = "Ban Alt Accounts";
                    Type = "Boolean";
                    DefaultValue = true;
                };
            };
        },function(Response)
            -- Resonse
            if typeof(Response) == "table" and Response[1] == true then
                -- Validate Response
                local NameInput = Response[2][1];
                local PermBan = Response[2][2];
                local Duration = Response[2][3];
                local DisplayReason = Response[2][4];
                local PrivateReason = Response[2][5];
                local AllPlaces = Response[2][6];
                local Alts = Response[2][7];
                -- Check Types
                if typeof(NameInput) ~= "string" or typeof(PermBan) ~= "boolean" or typeof(Duration) ~= "string" or typeof(DisplayReason) ~= "string" or typeof(PrivateReason) ~= "string" or typeof(AllPlaces) ~= "boolean" or typeof(Alts) ~= "boolean" then
                    Api:Notification(p,false,"Invalid Ban Entry");
                    return;
                end
                -- Get UserId
                local UserId
                local UserName
                local Length
                local LengthText
                local testId = getNameFromUserId(NameInput)
                if testId ~= "" then
                    -- Found UserId
                    UserId = tonumber(NameInput);
                    UserName = testId
                else
                    -- Check UserName
                    local testName = getUserIdFromUsername(NameInput)
                    if testName ~= 0 then
                        UserId = tonumber(testName);
                        UserName = getNameFromUserId(UserId);
                    else
                        Api:Notification(p,false,string.format("Player \"%s\" could not be found",NameInput));
                        return false
                    end
                end
                -- Anti-Softlock
                if game.CreatorType == Enum.CreatorType.User then
                    if UserId == game.CreatorId then
                        Api:Notification(p,false,string.format("Player \"%s\" cannot be banned.",UserName));
                        return false
                    end
                elseif game.CreatorType == Enum.CreatorType.Group then
                    local Groups = GroupService:GetGroupsAsync(UserId)
                    for _,g in pairs(Groups) do
                        if g.Id == game.CreatorId and g.Rank == 255 then
                            Api:Notification(p,false,string.format("Player \"%s\" cannot be banned.",UserName));
                            return false
                        end
                    end
                end
                -- Get Length
                if PermBan then
                    Length = -1;
                    LengthText = "Permanent Ban";
                else
                    -- Get Numbers
                    local Numbers = StrMod:RemoveLetters(Duration)
                    if typeof(Numbers) ~= "number" then
                        Numbers = 1
                    end
                    -- Get Text
                    local Text = StrMod:RemoveSpaces(StrMod:RemoveNumbers(Duration))
                    if typeof(Text) ~= "string" then
                        Text = "d"
                    end
                    local Matched = MatchString(Text)
                    LengthText = Numbers .. " " .. Matched[1];
                    Length = Numbers * Matched[2];
                end
                -- Check Reason
                if string.len(DisplayReason) <= 0 then
                    Api:Notification(p,false,"Invalid display reason: must provide a display reason.");
                    return false
                elseif string.len(DisplayReason) > 400 then
                    Api:Notification(p,false,"Invalid display reason: display reason cannot be more than 400 characters.");
                    return false
                elseif string.len(PrivateReason) > 1000 then
                    Api:Notification(p,false,"Invalid display reason: private reason cannot be more than 1000 characters.");
                    return false
                end
                -- Check if already banned
                local Content = Players:GetUserThumbnailAsync(UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
                local BHP: BanHistoryPages
                local success,err = pcall(function()
                    BHP = game.Players:GetBanHistoryAsync(UserId)
                end);
                if success and BHP then
                    local priors = BHP:GetCurrentPage();
                    if #priors > 0 then
                        local last = priors[1] :: {Ban: boolean, Duration: number, StartTime: string, DisplayReason: string, PrivateReason: string}
                        if last.Ban then
                            -- Possibly already banned
                            local End: number = DateTime.fromIsoDate(last.StartTime).UnixTimestamp + last.Duration;
                            local Now: number = DateTime.now().UnixTimestamp;
                            if last.Duration == -1 or Now < End then
                                -- User is already banned;
                                local Cont = false;
                                local EndString = DateTime.fromUnixTimestamp(End):FormatUniversalTime("lll","en-us");
                                Api:ShowPrompt(p,{
                                    Title = "Confirm User";
                                    Prompt = {
                                        [1] = {
                                            Type = "Info";
                                            Text = "<b>This user is already banned.</b>";
                                            RichText = true;
                                        };
                                        [2] = {
                                            Type = "Info";
                                            Text = "Are you sure you want to to ban again?";
                                        };
                                        [3] = {
                                            Title = "Player";
                                            Type = "Image";
                                            Image = Content,
                                            Text1 = UserName,
                                            Text2 = last.Duration == -1 and "Permanent Ban" or `Until {EndString} utc`,
                                            Text3 = "Reason: " .. last.DisplayReason,
                                            Text4 = "Private Reason: " .. last.PrivateReason,
                                        };
                                    }
                                },function(res)
                                    if res[1] == true then
                                        Cont = true;
                                    end
                                end);
                                if not Cont then
                                    return false;
                                end
                            end
                        end
                    end
                else
                    warn("Error getting BanPages:",err);
                end

                -- Confirmation Prompt
                local Box2 = {
                    Type = "Info";
                    Text = "Note: The Display Reason is subject to Roblox's text filtering."
                }
                local Box3 = nil;
                if PrivateReason ~= "" then
                    Box3 = Box2;
                    Box2 = {
                        Type = "Info";
                        Text = "Private Reason: " .. PrivateReason
                    }
                end
                task.wait(0.5)

                Api:ShowPrompt(p, {
                    Title = "Confirm Ban";
                    Prompt = {
                        [1] = {
                            Title = "Player";
                            Type = "Image";
                            Image = Content,
                            Text1 = UserName,
                            Text2 = tostring(UserId),
                            Text3 = "Length: " .. LengthText,
                            Text4 = DisplayReason == "" and "No reason provided." or "Reason: " .. DisplayReason
                        };
                        [2] = Box2;
                        [3] = Box3;
                    };
                }, function(NewResponse: {})
                    if NewResponse[1] == true then
                        -- Ban User
                        local s,e = pcall(function()
                            game.Players:BanAsync({
                                UserIds = {UserId};
                                ApplyToUniverse = AllPlaces;
                                Duration = Length;
                                DisplayReason = DisplayReason;
                                PrivateReason = PrivateReason;
                                ExcludeAltAccounts = not Alts;
                            })
                        end)
                        if s then
                            Log:log("Warn", p, UserName .. " was banned from the game.");
                            Api:Notification(p,Content,UserName .. " has been banned from the game.");
                        else
                            Api:Notification(p,false,string.format("There was a problem while banning %s, %s.",UserName,e));
                        end
                    end
                end)
                
            end
            return true
        end)


    end
    return false;
end,"3;[string:Player]")

Api:RegisterCommand("unban","Unbans a player.",function(p: Player, args: {string})
    local Target = args[1]
    local player = ""
    if Target and typeof(Target) == "string" then
        player = Target
    end

    Api:ShowPrompt(p,{
        Title = "Unban";
        Prompt = {
            [1] = {
                Title = "Player";
                Type = "String";
                DefaultValue = player;
            };
            [2] = {
                Title = "Apply to All Places";
                Type = "Boolean";
                DefaultValue = true;
            };
        }
    },function(Response)
        if typeof(Response) == "table" and Response[1] == true then
            -- Validate Response
            local NameInput = Response[2][1];
            local AllPlaces = Response[2][2];
            -- Check Types
            if typeof(NameInput) ~= "string" or typeof(AllPlaces) ~= "boolean" then
                Api:Notification(p, false, "Invalid Unban Entry");
                return;
            end
            -- Get UserId
            local UserId
            local UserName
            local testId = getNameFromUserId(NameInput)
            if testId ~= "" then
                -- Found UserId
                UserId = tonumber(NameInput);
                UserName = testId
            else
                -- Check UserName
                local testName = getUserIdFromUsername(NameInput)
                if testName ~= 0 then
                    UserId = tonumber(testName);
                    UserName = getNameFromUserId(UserId);
                else
                    Api:Notification(p,false,string.format("Player \"%s\" could not be found",NameInput));
                    return false
                end
                local Content = Players:GetUserThumbnailAsync(UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100);
                local IsBan = false;
                local EndString = ""
                local Reason = "";
                local Private = "";
                local BHP: BanHistoryPages
                local success,err = pcall(function()
                    BHP = game.Players:GetBanHistoryAsync(UserId)
                end);
                if success and BHP then
                    local priors = BHP:GetCurrentPage();
                    if #priors > 0 then
                        local last = priors[1] :: {Ban: boolean, Duration: number, StartTime: string, DisplayReason: string, PrivateReason: string}
                        if last.Ban then
                            -- Possibly already banned
                            local End: number = DateTime.fromIsoDate(last.StartTime).UnixTimestamp + last.Duration;
                            local Now: number = DateTime.now().UnixTimestamp;
                            if last.Duration == -1 or Now < End then
                                -- User is already banned;
                                IsBan = true;
                                if last.Duration == -1 then
                                    EndString = "Permanent Ban"
                                else
                                    EndString = `Until {DateTime.fromUnixTimestamp(End):FormatUniversalTime("lll","en-us")} utc`
                                end
                                Reason = last.DisplayReason
                                Private = last.PrivateReason
                            end
                        end
                    end
                else
                    warn("Error getting BanPages:",err);
                end

                if not IsBan and DataStore.ServerBans[UserId] == true then
                    -- Unserver Ban
                    Api:ShowPrompt(p,{
                        Title = "Confirm Server Unban";
                        Prompt = {
                            [1] = {
                                Title = "Player";
                                Type = "Image";
                                Image = Content,
                                Text1 = UserName,
                                Text2 = tostring(UserId),
                                Text3 = "Server Banned",
                                Text4 = "User is not banned from the game."
                            };
                        };
                    },function(NewResponse)
                        if NewResponse[1] == true then
                            -- Unban Player
                            DataStore:ServerBan(UserId,false)
                            Api:Notification(p,Content,Response[2][1] .. " has been unbanned from the server.")
                            Log:log("Warn", p, UserName .. " was unbanned from the server.");
                        end
                    end)
                else
                    -- Unban
                    local Box2 = nil;
                    if Private ~= "" and IsBan then
                        Box2 = {
                            Type = "Info";
                            Text = "Private Reason: " .. Private
                        }
                    end
                    Api:ShowPrompt(p, {
                        Title = "Confirm Unban";
                        Prompt = {
                            [1] = {
                                Title = "Player";
                                Type = "Image";
                                Image = Content,
                                Text1 = UserName,
                                Text2 = tostring(UserId),
                                Text3 = IsBan and EndString,
                                Text4 = IsBan and (Reason == "" and "No reason provided." or "Reason: " .. Reason)
                            };
                            [2] = Box2;
                        };
                    }, function(NewResponse: {})
                        if NewResponse[1] == true then
                            -- Ban User
                            local s,e = pcall(function()
                                game.Players:UnbanAsync({
                                    UserIds = {UserId};
                                    ApplyToUniverse = AllPlaces;
                                })
                            end)
                            if s then
                                Log:log("Warn", p, UserName .. " was unbanned from the game.");
                                Api:Notification(p,Content,UserName .. " has been unbanned from the game.");
                            else
                                Api:Notification(p,false,string.format("There was a problem while unbanning %s, %s.",UserName,e));
                            end
                        end
                    end)
                end

            end
        end
        return;
    end)
end,"3;[string:Player]")

Api:RegisterCommand("serverban", "Bans a player from the server.", function(p: Player, args: {string})
    if Api:GetRank(p) >= 3 then
        local Target = args[1];
        local player = "";
        if Target and typeof(Target) == "string" then
            player = Target;
        end

        -- Prompt
        Api:ShowPrompt(p, {
            Title = "Server Ban";
            Prompt = {
                [1] = {
                    Title = "Player";
                    Type = "String";
                    DefaultValue = player;
                }
            }
        }, function(Response)
            if typeof(Response) == "table" and Response[1] == true then
                -- Validate Response
                local NameInput = Response[2][1];
                -- Check Types
                if typeof(NameInput) ~= "string" then
                    Api:Notification(p, false, "Invalid Ban Entry");
                    return;
                end
                -- Get UserId
                local UserId
                local UserName
                local testId = getNameFromUserId(NameInput);
                if testId ~= "" then
                    -- Found UserId
                    UserId = tonumber(NameInput);
                    UserName = testId
                else
                    -- Check UserName
                    local testName = getUserIdFromUsername(NameInput)
                    if testName ~= 0 then
                        UserId = tonumber(testName);
                        UserName = getNameFromUserId(UserId);
                    else
                        Api:Notification(p,false,string.format("Player \"%s\" could not be found",NameInput));
                        return false
                    end
                end
                -- Anti-Softlock
                if game.CreatorType == Enum.CreatorType.User then
                    if UserId == game.CreatorId then
                        Api:Notification(p,false,string.format("Player \"%s\" cannot be banned.",UserName));
                        return false
                    end
                elseif game.CreatorType == Enum.CreatorType.Group then
                    local Groups = GroupService:GetGroupsAsync(UserId)
                    for _,g in pairs(Groups) do
                        if g.Id == game.CreatorId and g.Rank == 255 then
                            Api:Notification(p,false,string.format("Player \"%s\" cannot be banned.",UserName));
                            return false
                        end
                    end
                end
                -- Confirmation Prompt
                local Content = Players:GetUserThumbnailAsync(UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100);

                Api:ShowPrompt(p,{
                    Title = "Confirm Server Ban";
                    Prompt = {
                        [1] = {
                            Title = "Player";
                            Type = "Image";
                            Image = Content,
                            Text1 = UserName,
                            Text2 = tostring(UserId),
                            Text3 = "User will only be banned from this server.",
                            Text4 = "User will not be banned from the game."
                        };
                    };
                },function(NewResponse)
                    if NewResponse[1] == true then
                        -- Update Player
                        DataStore:ServerBan(UserId,true)
                        -- Check if player is in server
                        if Players:GetPlayerByUserId(UserId) then
                            local CurrentBanReason = "\nYou are Banned from this server, please join a different server."
                            Players:GetPlayerByUserId(UserId):Kick(CurrentBanReason)
                        end

                        Log:log("Warn", p, UserName .. " was banned from the server.");
                        Api:Notification(p,Content,UserName .. " has been banned from the server.")

                    end
                end)

            end
            return;
        end);
    end
end, "3;[string:Player]")

return true
