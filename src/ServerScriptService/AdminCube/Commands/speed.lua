-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

local Command = {}

Command.Name = "Speed"
Command.Desc = "Changes the WalkSpeed of a Player's Character"

function Command:Run(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            Target.Character.Humanoid.WalkSpeed = tonumber(Args[2])
        else
            -- Invalid Rank Notification
            print("Invalid Permissions ")
        end
    end)
    if not s then
        warn(e)
    end

end

return Command
