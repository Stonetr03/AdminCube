-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MainMenus = Roact.Component:extend("MainMenus")
local Menus = Roact.Component:extend("Menus")

local Vis,SetVis = Roact.createBinding(true)

function MainMenus:init()
    self.partRef = Roact.createRef()
end

function MainMenus:render()
    local Buttons = {}
    for i,o in pairs(script.Parent.Menus:GetChildren()) do
        local Menu = require(o)
        Buttons[i] = Roact.createElement(Menu[1],{
            Vis = Vis;
            SetVis = SetVis;
        })
    end
    return Roact.createFragment(Buttons)
end

local BackCallBacks = {}
for i,o in pairs(script.Parent.Menus:GetChildren()) do
    local Menu = require(o)
    BackCallBacks[i] = Menu[3]

end

function Menus:init()
    self.partRef = Roact.createRef()
end

function Menus:render()
    local Frames = {}
    for i,o in pairs(script.Parent.Menus:GetChildren()) do
        local Menu = require(o)
        Frames[i] = Roact.createElement(Menu[2])
    end
    return Roact.createFragment(Frames)
end

return {MainMenus,Menus,BackCallBacks,SetVis}
