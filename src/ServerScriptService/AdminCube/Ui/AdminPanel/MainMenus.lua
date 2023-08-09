-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local Value = Fusion.Value

local Vis = Value(true)
local SetVis = function(v)
    Vis:set(v)
end

function MainMenus()
    return Fusion.ForPairs(script.Parent.Menus:GetChildren(),function(i,o)
        local Menu = require(o)
        return i, Menu[1]({
            Vis = Vis;
            SetVis = SetVis;
        })
    end,Fusion.cleanup)
end

local BackCallBacks = {}
for i,o in pairs(script.Parent.Menus:GetChildren()) do
    local Menu = require(o)
    BackCallBacks[i] = Menu[3]

end

function Menus()
    return Fusion.ForPairs(script.Parent.Menus:GetChildren(),function(i,o)
        local Menu = require(o)
        return i, Menu[2]()
    end,Fusion.cleanup)
end

return {MainMenus,Menus,BackCallBacks,SetVis}
