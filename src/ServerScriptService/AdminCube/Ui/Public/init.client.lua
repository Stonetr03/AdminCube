-- Admin Cube

task.wait(0.5)
script.Parent = game.Players.LocalPlayer.PlayerScripts
script.Name = "__AdminCube_Public"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
ScreenGui.Name = "__AdminCube_Main"
ScreenGui.ResetOnSpawn = false

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local CmdBar = require(script:WaitForChild("CmdBar"))
local Notification = require(script:WaitForChild("Notification"))

local CmdBarTree = Roact.createElement(CmdBar);

local NotificationTree = Roact.createElement(Notification.Comp)

local Alert = Roact.mount(NotificationTree,ScreenGui,"Notification")
Roact.mount(CmdBarTree,ScreenGui,"CmdBar")

Notification.ReloadFunc = function()
    Roact.update(Alert,Roact.createElement(Notification.Comp))
end

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local TestFrame = Roact.Component:extend("TestFrame")
function TestFrame:render()
    return Roact.createElement("TextLabel",{
        Size = UDim2.new(0.5,0,0.5,0)
    })
end
local Window = Api:CreateWindow({
    SizeX = 200;
    SizeY = 300;
    Title = "TestWindow";
    Buttons = {};

},TestFrame)
