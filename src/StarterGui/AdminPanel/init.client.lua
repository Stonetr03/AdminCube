-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Topbar = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Topbar"))

-- Topbar
local icon = Topbar.new()
icon:setImage("http://www.roblox.com/asset/?id=5010019455") -- 24x24

-- UI
local Window = require(script:WaitForChild("Window"))

local Ui = Roact.createElement("ScreenGui",{
    Name = "AdminCubePanel";
    ResetOnSpawn = false;
},{
    Panel = Roact.createElement(Window,{
        SizeX = 350;
        SizeY = 250;
    })
})

Roact.mount(Ui,game.Players.LocalPlayer.PlayerGui)
