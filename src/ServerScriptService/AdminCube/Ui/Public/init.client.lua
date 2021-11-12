-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local CmdBar = require(script:WaitForChild("CmdBar"))
local Notification = require(script:WaitForChild("Notification"))

local Folder = Instance.new("Folder");
Folder.Parent = game.Players.LocalPlayer.PlayerGui
Folder.Name = "AdminCube"

local ScreenGui = Roact.createElement("ScreenGui",{
    ResetOnSpawn = false;
    Name = "AdminCubeBar";
},{
    CmdBar = Roact.createElement(CmdBar);
})

local NotificationPanel = Roact.createElement("ScreenGui",{
    ResetOnSpawn = false;
},{
    Notification = Roact.createElement(Notification.Comp)
})

local Alert = Roact.mount(NotificationPanel,Folder)
Roact.mount(ScreenGui,Folder)

Notification.ReloadFunc = function()
    local New = Roact.createElement("ScreenGui",{
        ResetOnSpawn = false;
    },{
        Notification = Roact.createElement(Notification.Comp)
    })
    Roact.update(Alert,New)
end
