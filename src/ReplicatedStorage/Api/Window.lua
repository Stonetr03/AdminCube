-- Admin Cube

local Module = {}

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children

function Module:CreateWindow(props)
    local ReturnTab = {
        SetVis = nil;
        OnClose = nil;
    }

    local DefaultPos = UDim2.new(0.5,-(props.SizeX/2),0.5,-(props.SizeY/2))
    local Visible = Value(true)
    local Position = Value(props.Position or DefaultPos)
    local CloseBtnTransparency = Value(1)
    local MinimizeBtnTransparency = Value(1)
    local BackBtnTransparency = Value(1)
    local Minimize = Value(true)
    local MiniText = Value("-")

    ReturnTab.SetVis = Visible

    -- Dragging
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        Position:set(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
    end

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Custom Buttons
    local CustomBtns = props.Btns
    if typeof(CustomBtns) ~= "table" then
        CustomBtns = {}
    end
    local Window = New "Frame" {
        -- Topbar Frame
        Parent = props.Parent;
        Visible = Visible;
        BackgroundColor3 = props.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(0,props.SizeX,0,20);
        Position = Position;
        ZIndex = props.ZIndex;
        Name = props.Name;

        -- Drag
        [Event "InputBegan"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Position:get()

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end;
        [Event "InputChanged"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end;

        [Children] = {
            -- Container Frame
            Frame = New "Frame" {
                Visible = Minimize;
                Position = UDim2.new(0,0,0,21);
                BorderSizePixel = 0;
                BackgroundColor3 = props.Style.Background;
                Size = UDim2.new(1,0,0,props.SizeY);
                ZIndex = props.ZIndex;
                [Children] = {
                    Main = props.Main
                }
            };
            -- Bar
            BarIcon = New "ImageLabel" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0,2,0,2);
                Size = UDim2.new(0,16,0,16);
                Image = "rbxassetid://6064221669";
                ZIndex = props.ZIndex;
            };
            -- 25
            Title = New "TextLabel" {
                Position = UDim2.new(0,25,0,0);
                Size = UDim2.new(1,-25,1,0);
                BackgroundTransparency = 1;
                TextColor3 = props.Style.ButtonColor;
                Text = props.Title;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = props.ZIndex;
            };

            CloseBtn = New "TextButton" {
                BackgroundColor3 = props.Style.ButtonColor;
                Size = UDim2.new(0,20,0,20);
                BackgroundTransparency = CloseBtnTransparency;
                Position = UDim2.new(1,-20,0,0);
                Text = "X";
                Font = Enum.Font.SourceSans;
                TextSize = 20;
                TextColor3 = props.Style.TextColor;
                AutoButtonColor = false;
                BorderSizePixel = 0;
                ZIndex = props.ZIndex;

                [Event "MouseEnter"] = function()
                    CloseBtnTransparency:set(0.85)
                end;
                [Event "MouseLeave"] = function()
                    CloseBtnTransparency:set(1)
                end;
                [Event "MouseButton1Up"] = function()
                    Visible:set(false)
                    if typeof(ReturnTab.OnClose) == "function" then
                        ReturnTab.OnClose()
                    end
                end;

            };
            MinimizeBtn = New "TextButton" {
                BackgroundColor3 = props.Style.ButtonColor;
                Size = UDim2.new(0,20,0,20);
                BackgroundTransparency = MinimizeBtnTransparency;
                Position = UDim2.new(1,-40,0,0);
                Text = MiniText;
                Font = Enum.Font.SourceSans;
                TextSize = 20;
                TextColor3 = props.Style.TextColor;
                AutoButtonColor = false;
                BorderSizePixel = 0;
                ZIndex = props.ZIndex;

                [Event "MouseEnter"] = function()
                    MinimizeBtnTransparency:set(0.85)
                end;
                [Event "MouseLeave"] = function()
                    MinimizeBtnTransparency:set(1)
                end;

                [Event "MouseButton1Up"] = function()
                    Minimize:set(not Minimize:get())

                    if Minimize:get() == true then
                        MiniText:set("-")
                    else
                        MiniText:set("+")
                    end
                end;
            };

            CustomButtons = Fusion.ForPairs(CustomBtns,function(i,o)
                local Transparency = Value(1)
                return i,New "TextButton" {
                    BackgroundColor3 = props.Style.ButtonColor;
                    Size = UDim2.new(0,20,0,20);
                    BackgroundTransparency = Transparency;
                    Position = UDim2.new(1,-((i*20)+40),0,0);
                    Text = o.Text;
                    Font = Enum.Font.SourceSans;
                    TextSize = 20;
                    TextColor3 = props.Style.TextColor;
                    AutoButtonColor = false;
                    BorderSizePixel = 0;
                    ZIndex = props.ZIndex;

                    [Event "MouseEnter"] = function()
                        Transparency:set(0.85)
                    end;
                    [Event "MouseLeave"] = function()
                        Transparency:set(1)
                    end;
                    [Event "MouseButton1Up"] = function()
                        o.Callback()
                    end;
                };
            end,function() end)
        }
    };

    return Window,ReturnTab
end

return Module
