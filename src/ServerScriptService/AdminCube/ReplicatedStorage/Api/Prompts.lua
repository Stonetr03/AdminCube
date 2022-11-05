-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local Boolean = Roact.Component:extend("PromptBoolean")

function Boolean:init(props)
    self.BackgroundColor,self.SetBackgroundColor = Roact.createBinding(Color3.fromRGB(0,207,0));
    self.DotPos,self.SetDotPos = Roact.createBinding(UDim2.new(0.05,0,0.5,0));

    if props.DefaultValue == true then
        self.SetBackgroundColor(Color3.fromRGB(0,207,0))
        self.SetDotPos(UDim2.new(0.05,0,0.5,0))
    else
        self.SetBackgroundColor(Color3.fromRGB(207, 0, 3))
        self.SetDotPos(UDim2.new(0.45,0,0.5,0))
    end
end

function Boolean:render()
    local props = self.props
    local Enabled = true
    return Roact.createElement("Frame",{
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = 20;
    },{
        Title = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(0.5,0,1,0);
            Font = Enum.Font.SourceSans;
            Text = props.Title;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            ZIndex = 21;
        });
        Tick = Roact.createElement("TextButton",{
            AnchorPoint = Vector2.new(0.5,0.5);
            BackgroundTransparency = 0;
            BackgroundColor3 = self.BackgroundColor;
            Position = UDim2.new(0.75,0,0.5,0);
            Size = UDim2.new(0.175,0,0.9,0);
            Text = "";
            ZIndex = 21;

            [Roact.Event.MouseButton1Up] = function()
                if Enabled == true then
                    Enabled = false
                    self.SetBackgroundColor(Color3.fromRGB(207, 0, 3))
                    self.SetDotPos(UDim2.new(0.45,0,0.5,0))
                    props.UpdateValue(false)
                else
                    Enabled = true
                    self.SetBackgroundColor(Color3.fromRGB(0,207,0))
                    self.SetDotPos(UDim2.new(0.05,0,0.5,0))
                    props.UpdateValue(true)
                end
            end
        },{
            UiCorner = Roact.createElement("UICorner",{
                CornerRadius = UDim.new(0.5,0);
            });
            Frame = Roact.createElement("Frame",{
                AnchorPoint = Vector2.new(0,0.5);
                BackgroundColor3 = props.Style.ButtonColor;
                Position = self.DotPos;
                Size = UDim2.new(0.5,0,0.9,0);
                ZIndex = 22;
            },{
                UiCorner = Roact.createElement("UICorner",{
                    CornerRadius = UDim.new(0.5,0);
                });
            })
        })
    })
end

local StringValue = Roact.Component:extend("PromptString")

function StringValue:init()
    self.StringRef = Roact.createRef()
end
function StringValue:render()
    local props = self.props
    local Text = ""
    if props.DefaultValue ~= nil and typeof(props.DefaultValue) == "string" then
        Text = props.DefaultValue
    end

    return Roact.createElement("Frame",{
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = 20;
    },{
        Title = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(0.5,0,1,0);
            Font = Enum.Font.SourceSans;
            Text = props.Title;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            ZIndex = 21;
        });
        Input = Roact.createElement("TextBox",{
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

            [Roact.Ref] = self.StringRef;
            [Roact.Event.FocusLost] = function()
                props.UpdateValue(self.StringRef.current.Text)
            end;
        })
    })
end

local DropdownMenu = Roact.Component:extend("PromptDropDown")

function DropdownMenu:init()
    self.SelectedText,self.SetSelectedText = Roact.createBinding("> Select")
    self.DropdownVis,self.SetDropdownVis = Roact.createBinding(false)
end

function DropdownMenu:render()
    local props = self.props
    if props.DefaultValue == nil then
        table.insert(props.Value,1,"Select")
    end

    local DropdownList = Roact.Component:extend()
    local List = props.Value
    local UpdateText = self.SetSelectedText -- Pass through function to Fragment
    local UpdateDropVis = self.SetDropdownVis
    local UpdateValue = props.UpdateValue
    local ScrollingY = 0
    function DropdownList:render()
        local Frag = {}
        local Bindings = {}
        local Index = 1
        for i,v in pairs(List) do
            local Binding,SetBinding = Roact.createBinding(v)
            Bindings[i] = {SetBinding,v}
            local Button = Roact.createElement("TextButton",{
                BackgroundTransparency = .9;
                BackgroundColor3 = props.Style.ButtonSubColor;
                Size = UDim2.new(1,0,0,25);
                Font = Enum.Font.SourceSans;
                Text = Binding;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                LayoutOrder = Index;
                ZIndex = 25;

                [Roact.Event.MouseButton1Up] = function()
                    UpdateText("> " .. v)
                    for _,b in pairs(Bindings) do
                        b[1](b[2])
                    end
                    SetBinding("> " .. v)
                    UpdateDropVis(false)
                    UpdateValue(v)
                end
            })
            ScrollingY += 25
            Index += 1
            Frag[i] = Button
        end
        return Roact.createFragment(Frag)
    end
    

    return Roact.createElement("Frame",{
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,25);
        ZIndex = 20;
    },{
        Title = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(0.5,0,1,0);
            Font = Enum.Font.SourceSans;
            Text = props.Title;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            ZIndex = 21;
        });
        TextBtn = Roact.createElement("TextButton",{
            BackgroundColor3 = props.Style.ButtonColor;
            BackgroundTransparency = 0.95;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5,0,0,0);
            Size = UDim2.new(0.5,0,1,0);
            Font = Enum.Font.SourceSans;
            Text = self.SelectedText;
            TextColor3 = props.Style.TextColor;
            TextScaled = true;
            ZIndex = 21;

            [Roact.Event.MouseButton1Up] = function()
                self.SetDropdownVis(not self.DropdownVis:getValue())
            end
        },{
            ScrollingFrame = Roact.createElement("ScrollingFrame",{
                AnchorPoint = Vector2.new(0.5,0);
                BackgroundColor3 = props.Style.BackgroundSubSubColor;
                BorderSizePixel = 0;
                Position = UDim2.new(0.5,0,0,0);
                Size = UDim2.new(1,0,3,2);
                Visible = self.DropdownVis;
                BottomImage = "";
                CanvasSize = UDim2.new(0,0,0,ScrollingY);
                MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
                ScrollBarImageColor3 = props.Style.ButtonColor;
                ScrollBarThickness = 5;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                TopImage = "";
                ZIndex = 22;
            },{
                UIListLayout = Roact.createElement("UIListLayout",{
                    Padding = UDim.new(0,1);
                    FillDirection = Enum.FillDirection.Vertical;
                    HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalAlignment = Enum.VerticalAlignment.Top;
                });
                List = Roact.createElement(DropdownList)
            })
        })
    })
end


local ImageLabel = Roact.Component:extend("PromptImage")

function ImageLabel:init()
    self.StringRef = Roact.createRef()
end
function ImageLabel:render()
    local props = self.props

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


    return Roact.createElement("Frame",{
        BackgroundTransparency = 1;
        Position = UDim2.new(0,0,0,props.Y);
        Size = UDim2.new(1,0,0,100);
        ZIndex = 20;
    },{
        Image = Roact.createElement("ImageLabel",{
            AnchorPoint = Vector2.new(0,0.5);
            BackgroundTransparency = 1;
            ZIndex = 21;
            Position = UDim2.new(0,3,0.5,0);
            Size = UDim2.new(0,94,0,94);
            Image = Image;
            BorderSizePixel = 0;
        });
        Text1 = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,-100,0,25);
            Position = UDim2.new(0,100,0,0);
            Font = Enum.Font.SourceSans; 
            Text = Text1;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            TextScaled = true;
            ZIndex = 21;
        });
        Text2 = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,-100,0,25);
            Position = UDim2.new(0,100,0,25);
            Font = Enum.Font.SourceSans; 
            Text = Text2;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            TextScaled = true;
            ZIndex = 21;
        });
        Text3 = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,-100,0,25);
            Position = UDim2.new(0,100,0,50);
            Font = Enum.Font.SourceSans; 
            Text = Text3;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            TextScaled = true;
            ZIndex = 21;
        });
        Text4 = Roact.createElement("TextLabel",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,-100,0,25);
            Position = UDim2.new(0,100,0,75);
            Font = Enum.Font.SourceSans; 
            Text = Text4;
            TextColor3 = props.Style.TextColor;
            TextSize = 20;
            TextScaled = true;
            ZIndex = 21;
        });
    })
end


return {Boolean,StringValue,DropdownMenu,ImageLabel}
