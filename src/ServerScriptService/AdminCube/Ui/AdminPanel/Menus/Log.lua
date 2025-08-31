-- Admin Cube - Log Menu

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed
local Observer = Fusion.Observer

local SetVis

function MenuBtn(props)
    return New "TextButton" {
        Name = "Log";
        Text = "Log";
        Visible = props.Vis;
        LayoutOrder = 5;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        TextSize = 20;
        FontFace = Api.Style.Font;
        [Event "MouseButton1Up"] = function()
            SetVis(true)
            props.SetVis(false)
        end
    }
end

function BackCallBack()
    SetVis(false)
end

local Visible = Value(false)

SetVis = function(Vis)
    Visible:set(Vis)
end

local Colors = {
    Command = Color3.new(0, .5, 1);
    Warn = Color3.new(1, 1, 0);
    Error = Color3.new(1, 0, 0);
};
local function GetColor(Type)
    if typeof(Type) == "string" then
        if Colors[Type] then
            return Colors[Type]
        end
    end
    return Color3.new(1,1,1)
end

local ScrollBinding = Value(0)

local LogFolder = game.ReplicatedStorage.AdminCube:WaitForChild("Log")

local log = Value(LogFolder:GetChildren())
LogFolder.ChildAdded:Connect(function()
    log:set(LogFolder:GetChildren(),true)
end)

local observer = Observer(log)
observer:onChange(function()
    local y = 0
    for _,_ in pairs(log:get()) do
        y += 20
    end
    ScrollBinding:set(y)
    return y
end)

function Menu()
    return New "Frame" {
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        Name = "log";
        [Children] = {
            TitleBar = New "Frame" {
                BackgroundTransparency = 0.9;
                Size = UDim2.new(1,0,0,20);
                [Children] = {
                    {
                        Time = New "TextLabel" {
                            BackgroundTransparency = 1;
                            TextColor3 = Api.Style.TextColor;
                            Text = "Time";
                            TextScaled = true;
                            Size = UDim2.new(0,80,1,0);
                            FontFace = Api.Style.FontBold;
                        };
                        Player = New "TextLabel" {
                            BackgroundTransparency = 1;
                            TextColor3 = Api.Style.TextColor;
                            Text = "Player";
                            TextScaled = true;
                            Size = UDim2.new(0,80,1,0);
                            Position = UDim2.new(0,80,0,0);
                            FontFace = Api.Style.FontBold;
                        };
                        Action = New "TextLabel" {
                            BackgroundTransparency = 1;
                            TextColor3 = Api.Style.TextColor;
                            Text = "Action";
                            TextScaled = true;
                            Size = UDim2.new(0,190,1,0);
                            Position = UDim2.new(0,160,0,0);
                            FontFace = Api.Style.FontBold;
                        };
                    }
                }
            };
            ScrollingFrame = New "ScrollingFrame" {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = UDim2.new(1,0,1,-20);
                Position = UDim2.new(0,0,0,20);
                BottomImage = "";
                TopImage = "";
                ScrollBarThickness = 5;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                CanvasSize = Computed(function()
                    return UDim2.new(0,0,0,ScrollBinding:get())
                end);
                [Children] = {
                    UiListLayout = New "UIListLayout" {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    };
                    List = Fusion.ForPairs(log,function(i,NewLog)
                        return i, New "Frame" {
                            Size = UDim2.new(1,0,0,20);
                            BackgroundTransparency = 1;
                            [Children] = {
                                Time = New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    TextColor3 = Api.Style.TextColor;
                                    Text = os.date("%X",tonumber(NewLog.Name));
                                    TextSize = 20;
                                    Size = UDim2.new(0,80,1,0);
                                    FontFace = Api.Style.Font;
                                };
                                Player = New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    TextColor3 = Api.Style.TextColor;
                                    Text = NewLog:WaitForChild("Player").Value.Name;
                                    TextSize = 20;
                                    Size = UDim2.new(0,80,1,0);
                                    Position = UDim2.new(0,80,0,0);
                                    FontFace = Api.Style.Font;
                                };
                                Action = New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    TextColor3 = Api.Style.TextColor;
                                    Text = NewLog:WaitForChild("Text").Value;
                                    TextSize = 20;
                                    Size = UDim2.new(0,190,1,0);
                                    Position = UDim2.new(0,160,0,0);
                                    TextXAlignment = Enum.TextXAlignment.Left;
                                    FontFace = Api.Style.Font;
                                };
                                ColorFrame = New "Frame" {
                                    Size = UDim2.new(0,3,1,-2);
                                    Position = UDim2.new(0,0,0.5,0);
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BorderSizePixel = 0;
                                    BackgroundColor3 = GetColor(NewLog:WaitForChild("Type").Value)
                                };
                            }
                        };
                    end,Fusion.cleanup);
                };
            }
        }
    }

end

return {MenuBtn,Menu,BackCallBack}
