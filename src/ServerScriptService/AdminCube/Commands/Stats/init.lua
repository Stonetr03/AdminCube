-- AdminCube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("stats","Opens a stats window.",function(p)
    local s,e = pcall(function()
        script.stats:Clone().Parent = p.PlayerGui:FindFirstChild("__AdminCube_Main")
    end)
    if not s then
        warn(e)
    end

end,"0;[player]",{"performancestats","pf","performance"})

return true