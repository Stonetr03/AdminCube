-- Admin Cube - Sudo Command

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Settings = require(script:WaitForChild("Settings"))
local HttpService = game:GetService("HttpService")

local function CommandRunner(str)
    local Commands = Api:GetCommands()
    local s,e = pcall(function()
        str = string.lower(str)
        local Split = str:split(" ")
        local PrefixCommand = Split[1]
        local cmd = PrefixCommand:split(Settings.Prefix)
        local Command = cmd[2]
        if Commands[Command] then
            local args = {}
            for i = 2, #Split,1 do
                table.insert(args,Split[i])
            end
            Commands[Command].Run("sudo",args)
        else
            -- Invalid Notification
        end
    end)
    if not s then warn("Command Runner Error : " .. e) end
end

Api:RegisterCommand("speed","Changes the WalkSpeed of a Player's Character",function(p,Args)
    if Settings.sudo == true then
        local s,e = pcall(function()
            if Api:GetRank(p) >= 4 then
                -- If Broadcast
                if Args[#Args] == "-p" then
                    -- Broadcast
                    Args[#Args] = nil
                    local msg = ""
                    for i = 1,#Args,1 do
                        msg = msg .. " " .. Args[i]
                    end
                    Api:BroadcastMessage("SudoBroadcast",HttpService:JSONEncode({
                        msg = msg
                    }))
                else
                    -- Run Command
                    local msg = ""
                    for i = 1,#Args,1 do
                        msg = msg .. " " .. Args[i]
                    end
                    CommandRunner(msg)
                end
            else
                -- Invalid Rank Notification
                Api:InvalidPermissionsNotification(p)
            end
        end)
        if not s then
            warn(e)
        end
    else
        Api:InvalidPermissionsNotification(p)
    end
end)

Api:SubscribeBroadcast("SudoBroadcast",function(Encoded)
    local Data = HttpService:JSONDecode(Encoded)
    CommandRunner(Data.msg)
end)

return true
