-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local CmdBar = require(script.CmdBar)

local ScreenGui = Roact.createElement("ScreenGui",{
    ResetOnSpawn = false;
    Name = "AdminCubeBar";
},{
    CmdBar = Roact.createElement(CmdBar);
})

Roact.mount(ScreenGui,game.Players.LocalPlayer.PlayerGui)
