-- Admin Cube - Explorer

local Api = require(script.Parent.Parent:WaitForChild("Api"))

local Allowed = {}
Api:RegisterCommand("explorer","Explorer / Properties Window",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            if Allowed[p] then
                -- Already Has the Explorer
                return false
            end
            Allowed[p] = true
            local NewUi = script.ExplorerUi:Clone()
            NewUi.Parent = p:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main")
        end
    end)
    if not s then
        warn(e)
    end

end)

Api:RegisterCommand("ex","Explorer / Properties Window",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            if Allowed[p] then
                -- Already Has the Explorer
                return false
            end
            Allowed[p] = true
            local NewUi = script.ExplorerUi:Clone()
            NewUi.Parent = p:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main")
        end
    end)
    if not s then
        warn(e)
    end

end)

Api:ListenFunction("CubeExplorer",function(p,Args)
    if Allowed[p] then
        if Args[1] == "Exit" then
            Allowed[p] = nil
        end
        return
    end
    return false
end)

return true
