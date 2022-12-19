-- Admin Cube - Settings Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn")
local Menu = Roact.Component:extend("SettingsMenu")

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local SetVis

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "Settings";
        Text = "Settings";
        LayoutOrder = 2;
        Visible = self.props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        [Roact.Event.MouseButton1Up] = function()
            SetVis(true)
            self.props.SetVis(false)
        end
    })
end

function BackCallBack()
    SetVis(false)
end

function Menu:init()
    self.Visible, self.SetVisiblility = Roact.createBinding(false)
    self.ThemeBtnText, self.SetThemeBtnText = Roact.createBinding("Theme : " .. Api.Settings.CurrentTheme);

    Api:ThemeUpdateEvent(function()
        self.SetThemeBtnText("Theme : " .. Api.Settings.CurrentTheme)
    end)

    SetVis = function(Vis)
        self.SetVisiblility(Vis)
    end
end

function Menu:render()
    return Roact.createElement("Frame",{
        Name = "Settings";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = self.Visible;
        ZIndex = 5;
    },{
        UiListLayout = Roact.createElement("UIListLayout",{
            Padding = UDim.new(0,5);
        });

        UiPadding = Roact.createElement("UIPadding",{
            PaddingTop = UDim.new(0,5);
            PaddingBottom = UDim.new(0,5);
            PaddingLeft = UDim.new(0,5);
            PaddingRight = UDim.new(0,5);
        });

        -- Theme button
        ThemeButton = Roact.createElement("TextButton",{
            ZIndex = 10;
            BackgroundColor3 = Api.Style.ButtonColor;
            BackgroundTransparency = Api.Style.ButtonTransparency;
            TextColor3 = Api.Style.TextColor;
            Size = UDim2.new(1,0,0,25);
            Text = self.ThemeBtnText;

            [Roact.Event.MouseButton1Up] = function()
                Api:UpdateTheme()
            end
        })
    })
end

return {MenuBtn,Menu,BackCallBack}
