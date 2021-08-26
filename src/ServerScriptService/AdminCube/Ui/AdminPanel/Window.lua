-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Topbar = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Topbar"))
local UserInputService = game:GetService("UserInputService")
local MainMenus = require(script.Parent.MainMenus)

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

-- Topbar
local icon = Topbar.new()
icon:setImage("http://www.roblox.com/asset/?id=5010019455") -- 24x24
icon:setName("AdminCubeMainAdminPanel")
icon:setProperty("deselectWhenOtherIconSelected",false)

local Window = Roact.Component:extend("Window")

local BackCallback = MainMenus[3]

function Window:init()
	self.Visible, self.SetVisiblility = Roact.createBinding(false)
    self.Position, self.SetPosition = Roact.createBinding(UDim2.new(0,100,0,100))
    self.CloseBtnTransparency, self.SetCloseBtnTransparency = Roact.createBinding(1)
    self.MinimizeBtnTransparency, self.SetMinimizeBtnTransparency = Roact.createBinding(1)
    self.BackBtnTransparency, self.SetBackBtnTransparency = Roact.createBinding(1)
    self.Minimize, self.SetMinimize = Roact.createBinding(true)
    self.MiniText, self.SetMiniText = Roact.createBinding("-")
end

function Window:render()
    icon.selected:Connect(function()
        self.SetVisiblility(true)
    end)

    icon.deselected:Connect(function()
        self.SetVisiblility(false)
    end)

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        self.SetPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
    end

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

	return Roact.createElement("Frame",{
        -- Topbar Frame
        Visible = self.Visible;
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(0,self.props.SizeX,0,20);
        Position = self.Position;

         -- Drag
        [Roact.Event.InputBegan] = function(_,input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = self.Position:getValue()

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end;
        [Roact.Event.InputChanged] = function(_,input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end;

    },{
        -- Container Frame
        Frame = Roact.createElement("Frame",{
            Visible = self.Minimize;
            Position = UDim2.new(0,0,0,21);
            BorderSizePixel = 0;
            BackgroundColor3 = Api.Style.Background;
            Size = UDim2.new(1,0,0,self.props.SizeY);
        },{
            -- Main Menus Frame
            MainMenu = Roact.createElement("Frame",{
                Size = UDim2.new(1,0,1,0);
                Name = "MainMenu";
                BackgroundTransparency = 1;
            },{
                Padding = Roact.createElement("UIPadding",{
                    PaddingBottom = UDim.new(0,5);
                    PaddingLeft = UDim.new(0,5);
                    PaddingRight = UDim.new(0,5);
                    PaddingTop = UDim.new(0,5);
                });

                Grid = Roact.createElement("UIGridLayout",{
                    CellPadding = UDim2.new(0,5,0,5);
                    CellSize = UDim2.new(0.5,-3,0,25);
                });

                Buttons = Roact.createElement(MainMenus[1]);
            });
            OtherMenus = Roact.createElement(MainMenus[2]);
        });
        -- Bar
        BarIcon = Roact.createElement("ImageLabel",{
            BackgroundTransparency = 1;
            Position = UDim2.new(0,2,0,2);
            Size = UDim2.new(0,16,0,16);
            Image = "rbxassetid://6064221669";
        });
        -- 25
        Title = Roact.createElement("TextLabel",{
            Position = UDim2.new(0,25,0,0);
            Size = UDim2.new(1,-25,1,0);
            BackgroundTransparency = 1;
            TextColor3 = Api.Style.ButtonColor;
            Text = "Admin Cube";
            TextXAlignment = Enum.TextXAlignment.Left;
        });

        CloseBtn = Roact.createElement("TextButton",{
            BackgroundColor3 = Api.Style.ButtonColor;
            Size = UDim2.new(0,20,0,20);
            BackgroundTransparency = self.CloseBtnTransparency;
            Position = UDim2.new(1,-20,0,0);
            Text = "X";
            Font = Enum.Font.SourceSans;
            TextSize = 20;
            TextColor3 = Api.Style.TextColor;
            AutoButtonColor = false;
            BorderSizePixel = 0;

            [Roact.Event.MouseEnter] = function()
                self.SetCloseBtnTransparency(0.85)
            end;
            [Roact.Event.MouseLeave] = function()
                self.SetCloseBtnTransparency(1)
            end;
            [Roact.Event.MouseButton1Up] = function()
                self.SetVisiblility(false)
                icon:deselect()
            end;
            
        });
        MinimizeBtn = Roact.createElement("TextButton",{
            BackgroundColor3 = Api.Style.ButtonColor;
            Size = UDim2.new(0,20,0,20);
            BackgroundTransparency = self.MinimizeBtnTransparency;
            Position = UDim2.new(1,-40,0,0);
            Text = self.MiniText;
            Font = Enum.Font.SourceSans;
            TextSize = 20;
            TextColor3 = Api.Style.TextColor;
            AutoButtonColor = false;
            BorderSizePixel = 0;

            [Roact.Event.MouseEnter] = function()
                self.SetMinimizeBtnTransparency(0.85)
            end;
            [Roact.Event.MouseLeave] = function()
                self.SetMinimizeBtnTransparency(1)
            end;

            [Roact.Event.MouseButton1Up] = function()
                self.SetMinimize(not self.Minimize:getValue())

                if self.Minimize:getValue() == true then
                    self.SetMiniText("-")
                else
                    self.SetMiniText("+")
                end
            end;
        });

        BackBtn = Roact.createElement("TextButton",{
            BackgroundColor3 = Api.Style.ButtonColor;
            Size = UDim2.new(0,20,0,20);
            BackgroundTransparency = self.BackBtnTransparency;
            Position = UDim2.new(1,-60,0,0);
            Text = "<";
            Font = Enum.Font.SourceSans;
            TextSize = 20;
            TextColor3 = Api.Style.TextColor;
            AutoButtonColor = false;
            BorderSizePixel = 0;

            [Roact.Event.MouseEnter] = function()
                self.SetBackBtnTransparency(0.85)
            end;
            [Roact.Event.MouseLeave] = function()
                self.SetBackBtnTransparency(1)
            end;

            [Roact.Event.MouseButton1Up] = function()
                for i = 1,#BackCallback,1 do
                    BackCallback[i]()
                end
            end;
        })
    })
end

return Window
