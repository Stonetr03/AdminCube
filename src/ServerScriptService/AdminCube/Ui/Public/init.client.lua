-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local CmdBar = require(script:WaitForChild("CmdBar"))
local Notification = require(script:WaitForChild("Notification"))

local ScreenGui = Roact.createElement("ScreenGui",{
    Name = "AdminCubeBar";
    ResetOnSpawn = false;
},{
    CmdBar = Roact.createElement(CmdBar);
})

local NotificationPanel = Roact.createElement("ScreenGui",{
    ResetOnSpawn = false;
},{
    Notification = Roact.createElement(Notification.Comp)
})

local Alert = Roact.mount(NotificationPanel,game.Players.LocalPlayer.PlayerGui)
Roact.mount(ScreenGui,game.Players.LocalPlayer.PlayerGui)

Notification.ReloadFunc = function()
    local New = Roact.createElement("ScreenGui",{
        ResetOnSpawn = false;
    },{
        Notification = Roact.createElement(Notification.Comp)
    })
    Roact.update(Alert,New)
end
