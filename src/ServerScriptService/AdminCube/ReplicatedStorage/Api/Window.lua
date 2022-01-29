-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local UserInputService = game:GetService("UserInputService")

local Window = Roact.Component:extend("Window")

function Window:init()
	self.Visible, self.SetVisiblility = Roact.createBinding(true)
    self.Position, self.SetPosition = Roact.createBinding(UDim2.new(0.5,-(self.props.SizeX/2),0.5,-(self.props.SizeY/2)))
    self.CloseBtnTransparency, self.SetCloseBtnTransparency = Roact.createBinding(1)
    self.MinimizeBtnTransparency, self.SetMinimizeBtnTransparency = Roact.createBinding(1)
    self.BackBtnTransparency, self.SetBackBtnTransparency = Roact.createBinding(1)
    self.Minimize, self.SetMinimize = Roact.createBinding(true)
    self.MiniText, self.SetMiniText = Roact.createBinding("-")
end

function Window:render()
    -- Dragging
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

    -- Custom Buttons
    local CustomBtnsList = Roact.Component:extend("CustomBtns")
    function CustomBtnsList:render()
        if typeof(self.props.Btns) ~= "table" then
            self.props.Btns = {}
        end

        local Btns = {}
        for i,o in pairs(self.props.Btns) do
            local Transparency, SetTransparency = Roact.createBinding(1)
            Btns[i] = Roact.createElement("TextButton",{
                BackgroundColor3 = self.props.Style.ButtonColor;
                Size = UDim2.new(0,20,0,20);
                BackgroundTransparency = Transparency;
                Position = UDim2.new(1,-((i*20)+40),0,0);
                Text = o.Text;
                Font = Enum.Font.SourceSans;
                TextSize = 20;
                TextColor3 = self.props.Style.TextColor;
                AutoButtonColor = false;
                BorderSizePixel = 0;
    
                [Roact.Event.MouseEnter] = function()
                    SetTransparency(0.85)
                end;
                [Roact.Event.MouseLeave] = function()
                    self.SetCloseBtnTransparency(1)
                end;
                [Roact.Event.MouseButton1Up] = function()
                    o.Callback()
                end;
                
            });
        end
        return Roact.createFragment(Btns)
    end

	return Roact.createElement("Frame",{
        -- Topbar Frame
        Visible = self.Visible;
        BackgroundColor3 = self.props.Style.Background;
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
            BackgroundColor3 = self.props.Style.Background;
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

            },{
                Main = Roact.createElement(self.props.Main)
            });
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
            TextColor3 = self.props.Style.ButtonColor;
            Text = self.props.Title;
            TextXAlignment = Enum.TextXAlignment.Left;
        });

        CloseBtn = Roact.createElement("TextButton",{
            BackgroundColor3 = self.props.Style.ButtonColor;
            Size = UDim2.new(0,20,0,20);
            BackgroundTransparency = self.CloseBtnTransparency;
            Position = UDim2.new(1,-20,0,0);
            Text = "X";
            Font = Enum.Font.SourceSans;
            TextSize = 20;
            TextColor3 = self.props.Style.TextColor;
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
            end;
            
        });
        MinimizeBtn = Roact.createElement("TextButton",{
            BackgroundColor3 = self.props.Style.ButtonColor;
            Size = UDim2.new(0,20,0,20);
            BackgroundTransparency = self.MinimizeBtnTransparency;
            Position = UDim2.new(1,-40,0,0);
            Text = self.MiniText;
            Font = Enum.Font.SourceSans;
            TextSize = 20;
            TextColor3 = self.props.Style.TextColor;
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

        CustomButtons = Roact.createElement(CustomBtnsList);
    })
end



return Window