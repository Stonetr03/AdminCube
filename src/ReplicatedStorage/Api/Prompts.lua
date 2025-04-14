-- Admin Cube

local UserInputService = game:GetService("UserInputService");
local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local ScreenGui: ScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("__AdminCube_Main");

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

function Boolean(props)
    local BackgroundColor = Value(Color3.fromRGB(0,207,0));
    local DotPos = Value(UDim2.new(0.05,0,0.5,0));

    if props.DefaultValue == true then
        BackgroundColor:set(Color3.fromRGB(0,207,0))
        DotPos:set(UDim2.new(0.05,0,0.5,0))
    else
        BackgroundColor:set(Color3.fromRGB(207, 0, 3))
        DotPos:set(UDim2.new(0.45,0,0.5,0))
    end

    local Enabled = true
    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = props.ZIndex;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = props.Title;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
            Tick = New "TextButton" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundTransparency = 0;
                BackgroundColor3 = BackgroundColor;
                Position = UDim2.new(0.75,0,0.5,0);
                Size = UDim2.new(0.175,0,0.9,0);
                Text = "";
                ZIndex = 21;

                [Event "MouseButton1Up"] = function()
                    if Enabled == true then
                        Enabled = false
                        BackgroundColor:set(Color3.fromRGB(207, 0, 3))
                        DotPos:set(UDim2.new(0.45,0,0.5,0))
                        props.UpdateValue(false)
                    else
                        Enabled = true
                        BackgroundColor:set(Color3.fromRGB(0,207,0))
                        DotPos:set(UDim2.new(0.05,0,0.5,0))
                        props.UpdateValue(true)
                    end
                end;
                [Children] = {
                    UiCorner = New "UICorner" {
                        CornerRadius = UDim.new(0.5,0);
                    };
                    Frame = New "Frame" {
                        AnchorPoint = Vector2.new(0,0.5);
                        BackgroundColor3 = props.Style.ButtonColor;
                        Position = DotPos;
                        Size = UDim2.new(0.5,0,0.9,0);
                        ZIndex = 22;
                        [Children] = {
                            UiCorner = New "UICorner" {
                                CornerRadius = UDim.new(0.5,0);
                            };
                        }
                    }
                }
            }
        }
    }
end

function StringValue(props)
    local StringRef = Value()

    local Text = ""
    if props.DefaultValue ~= nil and typeof(props.DefaultValue) == "string" then
        Text = props.DefaultValue
    end
    local PlaceHolder = "Input"
    if props.PlaceholderValue ~= nil and typeof(props.PlaceholderValue) == "string" then
        PlaceHolder = props.PlaceholderValue
    end

    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = props.ZIndex;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = props.Title;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
            Input = New "TextBox" {
                BackgroundTransparency = 0.9;
                BackgroundColor3 = props.Style.ButtonColor;
                BorderSizePixel = 0;
                Position = UDim2.new(0.5,0,0,0);
                Size = UDim2.new(0.5,0,1,0);
                ClearTextOnFocus = false;
                Font = Enum.Font.SourceSans;
                TextColor3 = props.Style.TextColor;
                Text = Text;
                PlaceholderText = PlaceHolder;
                TextScaled = true;
                ZIndex = 21;

                [Fusion.Ref] = StringRef;
                [Event "FocusLost"] = function()
                    props.UpdateValue(StringRef:get().Text)
                end;
            }
        }
    }
end

function DropdownList(props): {Show: (Options: {string}, Selected: number) -> (), Close: () -> (), Ui: () -> (GuiObject)}
    local r = {};
    local Visible = Value(false);
    local Position = Value(UDim2.new(0,0,0,0));
    local List = Value({});
    local Picked = Value(0);

    local SelFunc: (any) -> ();

    local con = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1 then
            if Visible:get() then
                Visible:set(false);
            end
        end
    end)

    local Ui = New "ScrollingFrame" {
        BackgroundColor3 = props.Style.BackgroundSubSubColor;
        BorderSizePixel = 0;
        Position = Position;
        Size = Computed(function()
            return UDim2.new(0.5,0,0,math.min(#List:get() * 26 + 2, ScreenGui.AbsoluteSize.Y - 30))
        end);
        Visible = Visible;
        BottomImage = "";
        CanvasSize = Computed(function()
            return UDim2.new(0,0,0,#List:get() * 26 + 2)
        end);
        ScrollBarImageColor3 = props.Style.ButtonColor;
        ScrollBarThickness = 5;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        TopImage = "";
        ZIndex = 22;
        [Fusion.Cleanup] = {Visible, Position, List, Picked, con};
        [Children] = {
            New "UIListLayout" {
                Padding = UDim.new(0,1);
                FillDirection = Enum.FillDirection.Vertical;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalAlignment = Enum.VerticalAlignment.Top;
            };
            New "UIPadding" {
                PaddingTop = UDim.new(0,1);
                PaddingBottom = UDim.new(0,1);
                PaddingLeft = UDim.new(0,1);
                PaddingRight = UDim.new(0,1);
            };
            Fusion.ForPairs(List,function(i,v: string)
                return i, New "TextButton" {
                    BackgroundTransparency = .9;
                    BackgroundColor3 = props.Style.ButtonSubColor;
                    Size = UDim2.new(1,0,0,25);
                    Font = Enum.Font.SourceSans;
                    Text = Computed(function()
                        return Picked:get() == i and "> " .. v or v;
                    end);
                    TextColor3 = props.Style.TextColor;
                    TextScaled = true;
                    LayoutOrder = i;
                    ZIndex = 25;

                    [Event "MouseButton1Up"] = function()
                        r.Close();
                        if typeof(SelFunc) == "function" then
                            SelFunc(i);
                        end
                    end
                }
            end,Fusion.cleanup);
        }
    }

    function r.Show(Options: {string}, Selected: number, Button: TextButton, Select: (any) -> ())
        Visible:set(true);
        List:set(Options);
        Picked:set(Selected);
        SelFunc = Select;
        -- Position
        local RelPos: Vector2 = Ui.Parent.AbsolutePosition;
        local y = Button.AbsolutePosition.Y - RelPos.Y;
        local ListSize = math.min(#List:get() * 26 + 2, ScreenGui.AbsoluteSize.Y - 30);
        if RelPos.Y + ListSize >= ScreenGui.AbsoluteSize.Y - 15 then
            y = math.max(ScreenGui.AbsoluteSize.Y - 1 - ListSize - RelPos.Y, 15 - RelPos.Y);
        end
        Position:set(UDim2.new(0,Button.AbsolutePosition.X - RelPos.X,0,y));
    end

    function r.Close()
        Visible:set(false);
    end

    function r.Ui(): GuiObject
        return Ui;
    end

    return r;
end

function DropdownMenu(props)
    local Selected = Value(1);

    if props.DefaultValue == nil then
        table.insert(props.Value,1,"Select")
    end

    local List = props.Value

    local TextBtn
    TextBtn = New "TextButton" {
        BackgroundColor3 = props.Style.ButtonColor;
        BackgroundTransparency = 0.95;
        BorderSizePixel = 0;
        Position = UDim2.new(0.5,0,0,0);
        Size = UDim2.new(0.5,0,1,0);
        Font = Enum.Font.SourceSans;
        Text = Computed(function()
            return "> " .. List[Selected:get()];
        end);
        TextColor3 = props.Style.TextColor;
        TextScaled = true;
        ZIndex = 21;

        [Event "MouseButton1Up"] = function()
            task.wait();
            props.Dropdown.Show(List,Selected:get(),TextBtn,function(i: number)
                Selected:set(i);
                props.UpdateValue(List[i]);
            end);
        end;
    }

    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = props.ZIndex;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = props.Title;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
            TextBtn;
        }
    }
end

function ImageLabel(props)
    --[[
        Props = {
            Image = "",
            Text1 = "",
            Text2 = "",
            Text3 = "",
            Text4 = ""
        }
    ]]
    local Image = ""
    local Text1 = ""
    local Text2 = ""
    local Text3 = ""
    local Text4 = ""
    if props.Image ~= nil and typeof(props.Image) == "string" then
        Image = props.Image
    end
    if props.Text1 ~= nil and typeof(props.Text1) == "string" then
        Text1 = props.Text1
    end
    if props.Text2 ~= nil and typeof(props.Text2) == "string" then
        Text2 = props.Text2
    end
    if props.Text3 ~= nil and typeof(props.Text3) == "string" then
        Text3 = props.Text3
    end
    if props.Text4 ~= nil and typeof(props.Text4) == "string" then
        Text4 = props.Text4
    end


    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,100);
        ZIndex = props.ZIndex;
        [Children] = {
            Image = New "ImageLabel" {
                AnchorPoint = Vector2.new(0,0.5);
                BackgroundTransparency = 1;
                ZIndex = 21;
                Position = UDim2.new(0,3,0.5,0);
                Size = UDim2.new(0,94,0,94);
                Image = Image;
                BorderSizePixel = 0;
            };
            Text1 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,0);
                Font = Enum.Font.SourceSans; 
                Text = Text1;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
            Text2 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,25);
                Font = Enum.Font.SourceSans; 
                Text = Text2;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
            Text3 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,50);
                Font = Enum.Font.SourceSans; 
                Text = Text3;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
            Text4 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,75);
                Font = Enum.Font.SourceSans; 
                Text = Text4;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
        }
    }
end

function InfoValue(props)
    local Text = ""
    if props.Text ~= nil and typeof(props.Text) == "string" then
        Text = props.Text
    end

    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = props.ZIndex;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = Text;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
                [Children] = {
                    New "UITextSizeConstraint" {
                        MaxTextSize = 20;
                    };
                }
            };
        }
    }
end

return {Boolean,StringValue,DropdownMenu,ImageLabel,InfoValue,DropdownList}
