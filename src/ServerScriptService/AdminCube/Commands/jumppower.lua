-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("jumppower","Changes the JumpPower of a Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            local Target = Api:GetPlayer(Args[1],p)
            Target.Character.Humanoid.JumpPower = tonumber(Args[2])
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
