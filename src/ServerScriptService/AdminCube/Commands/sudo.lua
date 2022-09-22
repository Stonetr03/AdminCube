-- Admin Cube - Sudo Command

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Settings = require(script.Parent.Parent:WaitForChild("Settings"))
local HttpService = game:GetService("HttpService")

local function CommandRunner(p,str)
    local Commands,Aliases = Api:GetCommands()
    print(Commands)
    local s,e = pcall(function()
        str = string.lower(str)
        local Split = str:split(" ")
        print(Split)
        local Command = Split[1]
        if Commands[Command] then
            local args = {}
            for i = 2, #Split,1 do
                table.insert(args,Split[i])
            end
            Commands[Command].Run("sudo",args)
        elseif Aliases[Command] then
            local args = {}
            for i = 2, #Split,1 do
                table.insert(args,Split[i])
            end
            Commands[Aliases[Command]].Run("sudo",args)
        else
            Api:Notification(p,false,"Invalid Command")
        end
    end)
    if not s then warn("Command Runner Error : " .. e) end
end

Api:RegisterCommand("sudo","Run commands in other servers and with Root permissions",function(p,Args)
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
                    print("sudo")
                    print(Args)
                    -- Run Command
                    local msg = Args[1]
                    for i = 2,#Args,1 do
                        msg = msg .. " " .. Args[i]
                    end
                    CommandRunner(p,msg)
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
    CommandRunner(nil,Data.msg)
end)

return true
