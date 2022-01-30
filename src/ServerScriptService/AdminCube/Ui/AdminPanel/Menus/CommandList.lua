-- Admin Cube - Settings Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("CommandsBtn")
local Menu = Roact.Component:extend("CommandsMenu")
local Btns = Roact.Component:extend("CommandsList")

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local SetVis

local CanvisSize, SetCanvisSize = Roact.createBinding(UDim2.new(0,0,0,0))

function Btns:render()
    local Cmds = Api:GetCommands()
    local Frames = {}
    local Size = 0
    for i,o in pairs(Cmds) do
        Size += 25
        Frames[i] = Roact.createElement("Frame",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,0,20);
            ZIndex = 10;
        },{
            NameDisplay = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Size = UDim2.new(0.3,0,1,0);
                TextXAlignment = Enum.TextXAlignment.Left;
                TextSize = 8;
                Text = o.Name;
                ZIndex = 15;
            });
            Desc = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Size = UDim2.new(0.7,0,1,0);
                Position = UDim2.new(0.3,0,0,0);
                TextXAlignment = Enum.TextXAlignment.Left;
                TextSize = 8;
                Text = o.Desc;
                TextWrapped = true;
                ZIndex = 15;
            })
        })
    end
    SetCanvisSize(UDim2.new(0,0,0,Size))
    return Roact.createFragment(Frames)
end

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "Commands";
        Text = "Commands";
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
    return Roact.createElement("ScrollingFrame",{
        Name = "Settings";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = self.Visible;
        CanvasSize = CanvisSize;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        TopImage = "";
        BottomImage = "";
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
        ScrollBarThickness = 5;
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

        Btns = Roact.createElement(Btns);
    })
end

return {MenuBtn,Menu,BackCallBack}
