-- Admin Cube

local ScreenGui = script.Parent

local CmdBar = require(script:WaitForChild("CmdBar"))
local Notification = require(script:WaitForChild("Notification"))

CmdBar.Ui({Parent = ScreenGui})
Notification.Ui({Parent = ScreenGui})