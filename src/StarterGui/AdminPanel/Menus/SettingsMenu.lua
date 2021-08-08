-- Admin Cube - Settings Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn");
local Menu = Roact.Component:extend("SettingsMenu")

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "Settings";
        Text = "Settings";
    })
end

return {MenuBtn,Menu}
