-- Admin Cube - Settings Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn");
local Menu = Roact.Component:extend("SettingsMenu")

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "Settings";
        Text = "Settings";
        Size = UDim2.new(0.5,-10,0,25);
        BackgroundColor3 = Color3.new(1,1,1);
        
    })
end

return {MenuBtn,Menu}
