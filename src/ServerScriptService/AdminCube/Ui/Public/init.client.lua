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

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local TestFrame = Roact.Component:extend("TestFrame")
function TestFrame:render()
    return Roact.createElement("TextButton",{
        Size = UDim2.new(0.5,0,0.5,0);

        [Roact.Event.MouseButton1Up] = function()
            print("Clicked")
        end
    })
end
local Window = Api:CreateWindow({
    SizeX = 200;
    SizeY = 300;
    Title = "TestWindow";
    Buttons = {
        [1] = {
            Text = "<";
            Callback = function()
                print("Top bar Btn Clicked")
            end
        };
    };

},TestFrame)
