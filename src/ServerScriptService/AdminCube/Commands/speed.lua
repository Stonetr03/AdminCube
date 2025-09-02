-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("speed","Changes the WalkSpeed of a Player's Character",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 2 then
            if not tonumber(Args[2]) then
                Api:Notification(p, false, "Invalid speed value.")
            else
                for _,Target in pairs(Api:GetPlayer(Args[1],p)) do
                    Target.Character.Humanoid.WalkSpeed = tonumber(Args[2])
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

end,"2;*[players];[number:Speed]")

return true
