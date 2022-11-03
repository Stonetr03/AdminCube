-- AdminCube

-- All Credit for the F3X building tools goes to the F3xTeam, get the model at https://www.roblox.com/library/142785488/Building-Tools-by-F3X

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("f3x","Building Tools.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            local Target = Api:GetPlayer(Args[1],p)
            local Tool = script:FindFirstChild("Tools"):Clone()
            if Tool then
                Tool.Parent = Target.Backpack
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"4;*[player]")

return true;