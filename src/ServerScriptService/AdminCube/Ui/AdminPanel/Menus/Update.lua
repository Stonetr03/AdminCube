-- Admin Cube - Settings Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn")
local Menu = Roact.Component:extend("SettingsMenu")

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local SetVis

function MenuBtn:render()
    return Roact.createElement("Frame",{
        Name = "Warn";
        LayoutOrder = 6;
        Visible = self.props.Vis;
        BackgroundTransparency = 1;--Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
    },{
        Frame = Roact.createElement("TextButton",{
            BackgroundColor3 = Color3.fromRGB(255,165,2);
            BackgroundTransparency = 0.7;
            Position = UDim2.new(-1,-5,5,5);
            Size = UDim2.new(2,5,2,0);
            Text = "";
            [Roact.Event.MouseButton1Up] = function()
                SetVis(true)
                self.props.SetVis(false)
            end
        },{
            UICorner = Roact.createElement("UICorner",{
                CornerRadius = UDim.new(0,7);
            });
            UIStroke = Roact.createElement("UIStroke",{
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Color = Color3.fromRGB(255,165,2);
            });
            Title = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                Position = UDim2.new(0,5,0,0);
                Size = UDim2.new(1,0,0.33,0);
                FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal);
                TextColor3 = Api.Style.TextColor;
                Text = "Admin Cube v2";
                TextSize = 10;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextWrapped = true;
            });
            Body = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                Position = UDim2.new(0,5,0.33,0);
                Size = UDim2.new(1,-10,0.66,0);
                TextColor3 = Api.Style.TextColor;
                Text = "v2 will be removing roact, all custom roact ui will need to be moved to fusion when v2 is released.";
                TextSize = 10;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextWrapped = true;
            });
        })
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
        Name = "Warn";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = self.Visible;
        ZIndex = 5;
    },{
        Title = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Position = UDim2.new(0,5,0,0);
            Size = UDim2.new(1,0,0,17);
            FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal);
            TextColor3 = Api.Style.TextColor;
            Text = "Admin Cube v2";
            TextSize = 10;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 10;
            TextYAlignment = Enum.TextYAlignment.Top;
        });
        Body = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Position = UDim2.new(0,5,0,17);
            Size = UDim2.new(1,-10,1,-17);
            TextColor3 = Api.Style.TextColor;
            Text = "Admin Cube v2 is switching from Roact to Fusion v0.2 by Elttob, All custom ui using roact will need to be moved to a new framework. Please view examples of the new ui in the repo in the v2 Branch.\nIf you do not want to use fusion, return a Ui instance in the functions.\n\nThere is currently no set release date.\nv1.2.4 is the last release until v2"; -- Could be better, but eh.
            TextSize = 10;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 10;
            TextYAlignment = Enum.TextYAlignment.Top;
        });
    })
end

return {MenuBtn,Menu,BackCallBack}
