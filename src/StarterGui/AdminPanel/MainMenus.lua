-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MainMenus = Roact.Component:extend("MainMenus")

function MainMenus:init()
    self.partRef = Roact.createRef()
end

function MainMenus:render()
    local Menus = {}
    for i,o in pairs(script.Parent.Menus:GetChildren()) do
        local Menu = require(o)
        Menus[i] = Roact.createElement(Menu[1])
    end
    return Roact.createFragment(Menus)
end

return MainMenus
