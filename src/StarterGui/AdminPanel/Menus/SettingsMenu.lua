-- Admin Cube - Settings Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn")
local Menu = Roact.Component:extend("SettingsMenu")

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Style = Api:GetStyle()

local SetVis

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "Settings";
        Text = "Settings";
        Size = UDim2.new(0.5,-10,0,25);
        BackgroundColor3 = Color3.new(1,1,1);
        [Roact.Event.MouseButton1Up] = function()
            SetVis(true)
        end
    })
end

function BackCallBack()
    SetVis(false)
end

function Menu:init()
    self.Visible, self.SetVisiblility = Roact.createBinding(false)

    SetVis = function(Vis)
        self.SetVisiblility(Vis)
    end
end

function Menu:render()
    return Roact.createElement("Frame",{
        Name = "Settings";
        BackgroundColor3 = Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = self.Visible;
        ZIndex = 5;
    })
end

return {MenuBtn,Menu,BackCallBack}
