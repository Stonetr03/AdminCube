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
            local NewUi = script.Ui:Clone()
            NewUi.Parent = p:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main")
        end
    end)
    if not s then
        warn(e)
    end

end,"4;*[player]",{"ex"})

Api:OnInvoke("CubeExplorer",function(p,Args)
    if Allowed[p] then
        if Args[1] == "Exit" then
            Allowed[p] = nil
        end
        return
    end
    return false
end)

game.Players.PlayerRemoving:Connect(function(p)
    if Allowed[p] then
        Allowed[p] = nil
    end
end)

return true
