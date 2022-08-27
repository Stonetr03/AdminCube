local Players = game:GetService("Players")
-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local DataStore = require(script.Parent.Parent:WaitForChild("DataStore"))

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
                            if typeof(BanTime) ~= "number" then
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

                            local Length = ""
                            if PermBan == true then
                                Length = "Perm Ban"
                            else
                                Length = tostring(BanTime)
                            end
                            task.wait(0.5)
                            print("Show Prompt")
                            Api:ShowPrompt(p,{
                                Title = "Confirm Ban";
                                Prompt = {
                                    [1] = {
                                        Title = "Player";
                                        Type = "Image";
                                        Image = Content,
                                        Text1 = Response[2][1],
                                        Text2 = tostring(UserId),
                                        Text3 = "Length : " .. Length,
                                        Text4 = "Reason : " .. tostring(Reason)
                                    };
                                };
                            },function(Response)
                                if Response[1] == true then
                                    
                                    -- Ban Player

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
