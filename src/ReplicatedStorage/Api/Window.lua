-- Admin Cube

local Module = {}

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

function Module:CreateWindow(props)

    local Visible = Value(true)
    local Position = Value(props.Position)
    local CloseBtnTransparency = Value(1)
    local MinimizeBtnTransparency = Value(1)
    local Minimize = Value(true)
    local MiniText = Value("-")
    local Size = Value(props.Size)
    local TopbarVis = not props.HideTopbar
    local TopbarBG = 0
    if TopbarVis == false then
        TopbarBG = 1;
    end

    local ReturnTab = {
        SetVis = Visible;
        OnClose = nil;
        SetSize = function(NewSize: Vector2)
            Size:set(NewSize)
        end;
        SetPosition = function(NewPos: UDim2)
            Position:set(NewPos)
        end;
    }

    -- Window Resize
    local ResizeWindow = nil
    if props.Resizeable == true then
        -- Resizeing
        local resizeing
        local resizeInput
        local resizeStart
        local startPos
        local function update(input)
            -- Update Size
            local delta = input.Position - resizeStart
            local newSize = Vector2.new(startPos.X + delta.X, startPos.Y + delta.Y)

            if newSize.X < props.ResizeableMinimum.X then
                newSize = Vector2.new(props.ResizeableMinimum.X,newSize.Y)
            end
            if newSize.Y < props.ResizeableMinimum.Y then
                newSize = Vector2.new(newSize.X,props.ResizeableMinimum.Y)
            end
            Size:set(newSize)
        end
        UserInputService.InputChanged:Connect(function(input)
            if input == resizeInput and resizeing then
                update(input)
            end
        end)
        ResizeWindow = New "ImageButton" {
            AnchorPoint = Vector2.new(1,1);
            Size = UDim2.new(0,20,0,20);
            Position = UDim2.new(1,-1,1,-1);
            BackgroundTransparency = 1;
            Image = "rbxassetid://14811373126"; -- images/Triangle.png;
            ImageColor3 = props.Style.BackgroundSubColor;
            ResampleMode = Enum.ResamplerMode.Pixelated;
            ZIndex = 101;
            [Event "InputBegan"] = function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and props.Draggable == true then
                    resizeing = true
                    resizeStart = input.Position
                    startPos = Size:get()

                    local con
                    con = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            resizeing = false
                            con:Disconnect()
                        end
                    end)
                end
            end;
            [Event "InputChanged"] = function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    resizeInput = input
                end
            end;
        }
    end

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
    for i,o in pairs(CustomBtns) do
        if typeof(o) ~= "table" then
            CustomBtns[i] = nil;
        end
        if typeof(o.Type) ~= "string" then
            o.Type = "Text";
        end
        if typeof(o.Padding) ~= "number" then
            o.Padding = 0;
        end
    end
    local Window = New "Frame" {
        -- Topbar Frame
        Parent = props.Parent;
        Visible = Visible;
        BackgroundColor3 = props.Style.Background;
        BackgroundTransparency = TopbarBG;
        BorderSizePixel = 0;
        Size = Computed(function()
            return UDim2.new(0,Size:get().X,0,20);
        end);
        Position = Position;
        ZIndex = props.ZIndex;
        Name = props.Name;

        -- Drag
        [Event "InputBegan"] = function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and props.Draggable == true then
                dragging = true
                dragStart = input.Position
                startPos = Position:get()

                local con
                con = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        con:Disconnect()
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
                Size = Computed(function()
                    return UDim2.new(1,0,0,Size:get().Y);
                end);
                ZIndex = props.ZIndex;
                [Children] = {
                    Main = props.Main;
                    ResizeWindow;
                }
            };
            -- Bar
            BarIcon = New "ImageLabel" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0,2,0,2);
                Size = UDim2.new(0,16,0,16);
                Image = "rbxassetid://6064221669";
                ZIndex = props.ZIndex;
                Visible = TopbarVis;
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
                Visible = TopbarVis;
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
                Visible = TopbarVis;

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
                Visible = TopbarVis;

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
                local Chi = nil;
                if o.Type == "Image" then
                    Chi = {New "ImageLabel" {
                        AnchorPoint = Vector2.new(0.5,0.5);
                        Position = UDim2.new(0.5,0,0.5,0);
                        Size = UDim2.new(1,-o.Padding*2,1,-o.Padding*2);
                        BackgroundTransparency = 1;
                        Image = o.Text;
                    }};
                    o.Text = ""
                end
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
                    Visible = TopbarVis;

                    [Event "MouseEnter"] = function()
                        Transparency:set(0.85)
                    end;
                    [Event "MouseLeave"] = function()
                        Transparency:set(1)
                    end;
                    [Event "MouseButton1Up"] = function()
                        o.Callback()
                    end;
                    [Children] = Chi;
                };
            end,Fusion.cleanup)
        }
    };

    return Window,ReturnTab
end

local defaultProps = { -- These also need to be added to src/ReplicatedStorage/Api/init.lua
    Buttons = {};
    Size = Vector2.new(125,125);
    Title = "Window";
    ZIndex = 1;
    --Position = UDim2.new(0.5,-(props.Size.X/2),0.5,-(props.Size.Y/2))
    Resizeable = false;
    ResizeableMinimum = Vector2.new(25,25);
    Draggable = true;
    HideTopbar = false;
}
function Module:CheckTable(t: table): table
    if typeof(t) ~= "table" then
        t = {}
    end
    local newTab = {}
    for o,i in pairs(defaultProps) do
        if t[o] ~= nil then
            newTab[o] = t[o]
        else
            newTab[o] = i
        end
    end
    if newTab.HideTopbar == true then
        newTab.Draggable = false
    end
    if t.Position ~= nil then
        newTab.Position = t.Position;
    else
        newTab.Position = UDim2.new(0.5,-(newTab.Size.X/2),0.5,-(newTab.Size.Y/2))
    end
    return newTab
end

return Module
