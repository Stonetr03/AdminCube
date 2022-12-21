-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("fps","Opens a fps counter window.",function(p)
    local s,e = pcall(function()
        script.fps:Clone().Parent = p.PlayerGui:FindFirstChild("__AdminCube_Main")
    end)
    if not s then
        warn(e)
    end

end,"0;[player]")

return true
