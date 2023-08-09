-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("jumppower","Changes the JumpPower of a Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                if Target.Character.Humanoid.UseJumpPower == true then
                    Target.Character.Humanoid.JumpPower = tonumber(Args[2])
                else
                    Target.Character.Humanoid.JumpHeight = tonumber(Args[2])
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

end,"2;*[player];[number:Jump Power]")

return true
