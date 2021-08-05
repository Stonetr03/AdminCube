-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

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
