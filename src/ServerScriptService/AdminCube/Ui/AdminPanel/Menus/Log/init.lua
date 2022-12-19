-- Admin Cube - Log Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local MenuBtn = Roact.Component:extend("LogBtn")
local Menu = Roact.Component:extend("LogMenu")

local List = require(script.List)
local ScrollBinding = List[2]

local SetVis

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "Log";
        Text = "Log";
        Visible = self.props.Vis;
        LayoutOrder = 5;
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
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
        Visible = self.Visible;
    },{
        TitleBar = Roact.createElement("Frame",{
            BackgroundTransparency = 0.9;
            Size = UDim2.new(1,0,0,20);
        },{
            Time = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Text = "Time";
                TextSize = 8;
                Size = UDim2.new(0,80,1,0)
            });
            Player = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Text = "Player";
                TextSize = 8;
                Size = UDim2.new(0,80,1,0);
                Position = UDim2.new(0,80,0,0);
            });
            Action = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Text = "Action";
                TextSize = 8;
                Size = UDim2.new(0,190,1,0);
                Position = UDim2.new(0,160,0,0);
            })
        });
        ScrollingFrame = Roact.createElement("ScrollingFrame",{
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(1,0,1,-20);
            Position = UDim2.new(0,0,0,20);
            BottomImage = "";
            TopImage = "";
            ScrollBarThickness = 5;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            CanvasSize = ScrollBinding:map(function(y)
                return UDim2.new(0,0,0,y)
            end);
        },{
            UiListLayout = Roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder;
            });
            List = Roact.createElement(List[1]);
        })
    })

end

return {MenuBtn,Menu,BackCallBack}
