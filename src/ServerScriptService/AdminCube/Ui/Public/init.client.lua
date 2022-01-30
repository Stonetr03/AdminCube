-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local ScreenGui = script.Parent

local CmdBar = require(script:WaitForChild("CmdBar"))
local Notification = require(script:WaitForChild("Notification"))

local CmdBarTree = Roact.createElement(CmdBar);

local NotificationTree = Roact.createElement(Notification.Comp)

local Alert = Roact.mount(NotificationTree,ScreenGui,"Notification")
Roact.mount(CmdBarTree,ScreenGui,"CmdBar")

Notification.ReloadFunc = function()
    Roact.update(Alert,Roact.createElement(Notification.Comp))
end
