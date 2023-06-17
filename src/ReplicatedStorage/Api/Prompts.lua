-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

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
        ZIndex = 20;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = props.Title;
                TextColor3 = props.Style.TextColor;
                TextSize = 20;
                ZIndex = 21;
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

    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = 20;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = props.Title;
                TextColor3 = props.Style.TextColor;
                TextSize = 20;
                ZIndex = 21;
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
                PlaceholderText = "Input";
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

function DropdownMenu(props)
    local SelectedText = Value("> Select")
    local DropdownVis = Value(false)

    if props.DefaultValue == nil then
        table.insert(props.Value,1,"Select")
    end

    local List = props.Value
    local Bindings = {}

    for i,v in pairs(List) do
        local Binding = Value(v)
        Bindings[i] = {Binding,v}
    end

    return New "Frame" {
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = 20;
        [Children] = {
            Title = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = props.Title;
                TextColor3 = props.Style.TextColor;
                TextSize = 20;
                ZIndex = 21;
            };
            TextBtn = New "TextButton" {
                BackgroundColor3 = props.Style.ButtonColor;
                BackgroundTransparency = 0.95;
                BorderSizePixel = 0;
                Position = UDim2.new(0.5,0,0,0);
                Size = UDim2.new(0.5,0,1,0);
                Font = Enum.Font.SourceSans;
                Text = SelectedText;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                ZIndex = 21;
    
                [Event "MouseButton1Up"] = function()
                    DropdownVis:set(not DropdownVis:get())
                end;
                [Children] = {
                    ScrollingFrame = New "ScrollingFrame" {
                        AnchorPoint = Vector2.new(0.5,0);
                        BackgroundColor3 = props.Style.BackgroundSubSubColor;
                        BorderSizePixel = 0;
                        Position = UDim2.new(0.5,0,0,0);
                        Size = UDim2.new(1,0,3,2);
                        Visible = DropdownVis;
                        BottomImage = "";
                        CanvasSize = UDim2.new(0,0,0,0+(#List * 26));
                        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
                        ScrollBarImageColor3 = props.Style.ButtonColor;
                        ScrollBarThickness = 5;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        TopImage = "";
                        ZIndex = 22;
                        [Children] = {
                            UIListLayout = New "UIListLayout" {
                                Padding = UDim.new(0,1);
                                FillDirection = Enum.FillDirection.Vertical;
                                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                VerticalAlignment = Enum.VerticalAlignment.Top;
                            };
                            List = Fusion.ForPairs(List,function(i,v)
                                return i, New "TextButton" {
                                    BackgroundTransparency = .9;
                                    BackgroundColor3 = props.Style.ButtonSubColor;
                                    Size = UDim2.new(1,0,0,25);
                                    Font = Enum.Font.SourceSans;
                                    Text = Bindings[i][1];
                                    TextColor3 = props.Style.TextColor;
                                    TextScaled = true;
                                    LayoutOrder = i;
                                    ZIndex = 25;
                    
                                    [Event "MouseButton1Up"] = function()
                                        SelectedText:set("> " .. v)
                                        for _,b in pairs(Bindings) do
                                            b[1]:set(b[2])
                                        end
                                        Bindings[i][1]:set("> " .. v)
                                        DropdownVis:set(false)
                                        props.UpdateValue(v)
                                    end
                                }
                            end,Fusion.cleanup)
                        }
                    }
                }
            }
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
        ZIndex = 20;
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
                TextSize = 20;
                TextScaled = true;
                ZIndex = 21;
            };
            Text2 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,25);
                Font = Enum.Font.SourceSans; 
                Text = Text2;
                TextColor3 = props.Style.TextColor;
                TextSize = 20;
                TextScaled = true;
                ZIndex = 21;
            };
            Text3 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,50);
                Font = Enum.Font.SourceSans; 
                Text = Text3;
                TextColor3 = props.Style.TextColor;
                TextSize = 20;
                TextScaled = true;
                ZIndex = 21;
            };
            Text4 = New "TextLabel" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1,-100,0,25);
                Position = UDim2.new(0,100,0,75);
                Font = Enum.Font.SourceSans; 
                Text = Text4;
                TextColor3 = props.Style.TextColor;
                TextSize = 20;
                TextScaled = true;
                ZIndex = 21;
            };
        }
    }
end


return {Boolean,StringValue,DropdownMenu,ImageLabel}
