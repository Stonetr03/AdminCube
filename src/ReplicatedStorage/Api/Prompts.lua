-- Admin Cube

local UserInputService = game:GetService("UserInputService");
local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any);

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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
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

function DropdownList(props: {Style: {[string]: any}}): {Show: (Options: {string}, Selected: number, Button: TextButton, Select: (any) -> (), Players: boolean, Multi: boolean) -> (), Close: () -> (), Ui: () -> (GuiObject)}
    local r = {} :: any;
    local Visible = Value(false);
    local Position = Value(UDim2.new(0,0,0,0));
    local List = Value({});
    local Picked = Value(0);
    local PlayerList = Value(false);
    local MultiSelect = Value(false);

    local Search = Value();
    local SearchText = Value("");

    local SelFunc: (any) -> ();

    local con: RBXScriptConnection;

    local Ui: Frame = New "Frame" {
        BackgroundColor3 = props.Style.BackgroundSubSubColor;
        Position = Position;
        Size = Computed(function()
            if PlayerList:get() then
                return UDim2.new(1,0,0,math.min(#List:get() * 41 + 27 + (MultiSelect:get() and 26 or 0), ScreenGui.AbsoluteSize.Y - 30))
            else
                return UDim2.new(0.5,0,0,math.min(#List:get() * 26 + 2, ScreenGui.AbsoluteSize.Y - 30))
            end
        end);
        Visible = Visible;
        [Children] = {
            New "UIPadding" {
                PaddingTop = UDim.new(0,1);
                PaddingBottom = UDim.new(0,1);
                PaddingLeft = UDim.new(0,1);
                PaddingRight = UDim.new(0,1);
            };
            -- Search Box
            New "TextBox" {
                BackgroundColor3 = props.Style.ButtonColor;
                BackgroundTransparency = props.Style.ButtonTransparency;
                FontFace = props.Style.Font;
                PlaceholderText = "Search";
                Size = UDim2.new(1,0,0,25);
                Text = "";
                TextColor3 = props.Style.TextColor;
                PlaceholderColor3 = props.Style.TextSubColor;
                TextSize = 18;
                TextWrapped = true;
                Visible = PlayerList;
                [Fusion.Ref] = Search;
                [Fusion.Out "Text"] = SearchText;
                [Children] = New "TextButton" {
                    AnchorPoint = Vector2.new(1,0);
                    BackgroundColor3 = props.Style.ButtonColor;
                    BackgroundTransparency = props.Style.ButtonTransparency;
                    FontFace = props.Style.Font;
                    Position = UDim2.new(1,-2,0,2);
                    Size = UDim2.new(0,30,1,-4);
                    Text = "All";
                    TextColor3 = props.Style.TextColor;
                    TextSize = 18;
                    Visible = MultiSelect;
                    [Event "MouseButton1Click"] = function()
                        local t = List:get();
                        if typeof(SelFunc) == "function" then
                            if #t == #string.split(Picked:get(),",") and Picked:get() ~= "" then
                                SelFunc("");
                                Picked:set("");
                            else
                                local str = "";
                                for _,o: Player in pairs(t) do
                                    str = str .. o.Name .. ",";
                                end
                                SelFunc(str:sub(1,str:len() - 1));
                                Picked:set(str:sub(1,str:len() - 1));
                            end
                        end
                    end;
                }
            };
            -- Confirm Button
            New "TextButton" {
                BackgroundColor3 = props.Style.ButtonColor;
                BackgroundTransparency = props.Style.ButtonTransparency;
                FontFace = props.Style.Font;
                LayoutOrder = 10000;
                Size = UDim2.new(1,0,0,25);
                Position = UDim2.new(0,0,1,-25);
                Text = "Confirm";
                TextColor3 = props.Style.TextColor;
                TextSize = 22;
                Visible = Computed(function()
                    return MultiSelect:get() and PlayerList:get();
                end);
                [Event "MouseButton1Click"] = function()
                    r.Close();
                end;
            };
            -- Scrolling Frame
            New "ScrollingFrame" {
                BackgroundTransparency = 1;
                BottomImage = "";
                CanvasSize = Computed(function()
                    return UDim2.new(0,0,0,#List:get() * 26 + 2)
                end);
                Position = Computed(function()
                    return PlayerList:get() and UDim2.new(0,0,0,26) or UDim2.new(0,0,0,0);
                end);
                Size = Computed(function()
                    return PlayerList:get() and UDim2.new(1,0,1,-(MultiSelect:get() and 52 or 26)) or UDim2.new(1,0,1,0);
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
                    Fusion.ForPairs(List,function(i: number, v: string | Player)
                        if PlayerList:get() then
                            local img = game:GetService("Players"):GetUserThumbnailAsync((v :: Player).UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48);
                            local Labels = {};
                            if (v :: Player).DisplayName == (v :: Player).Name then
                                Labels = New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    FontFace = props.Style.Font;
                                    Position = UDim2.new(0,40,0,10);
                                    Size = UDim2.new(1,-40,0,20);
                                    Text = `@{(v :: Player).Name}`;
                                    TextColor3 = props.Style.TextColor;
                                    TextScaled = true;
                                }
                            else
                                Labels = {
                                    New "TextLabel" {
                                        BackgroundTransparency = 1;
                                        FontFace = props.Style.Font;
                                        Position = UDim2.new(0,40,0,0);
                                        Size = UDim2.new(1,-40,0,20);
                                        Text = (v :: Player).DisplayName;
                                        TextColor3 = props.Style.TextColor;
                                        TextScaled = true;
                                    };
                                    New "TextLabel" {
                                        BackgroundTransparency = 1;
                                        FontFace = props.Style.Font;
                                        Position = UDim2.new(0,40,0,20);
                                        Size = UDim2.new(1,-40,0,20);
                                        Text = `@{(v :: Player).Name}`;
                                        TextColor3 = props.Style.TextColor;
                                        TextScaled = true;
                                    };
                                }
                            end
                            return i, New "TextButton" {
                                Visible = Computed(function()
                                    local txt = SearchText:get();
                                    if typeof(txt) ~= "string" then return true end;
                                    if txt == "" or string.find((v :: Player).Name,txt) or string.find((v :: Player).DisplayName,txt) then
                                        return true;
                                    end
                                    return false;
                                end);
                                BackgroundColor3 = Computed(function()
                                    -- if selected
                                    local selected = string.split(Picked:get(),",");
                                    for _,selectedPlayer: string in pairs(selected) do
                                        if selectedPlayer == (v :: Player).Name then
                                            return props.Style.Selection:get()
                                        end
                                    end

                                    return props.Style.ButtonSubColor:get()
                                end);
                                BackgroundTransparency = Computed(function()
                                    -- if selected
                                    local selected = string.split(Picked:get(),",");
                                    for _,selectedPlayer: string in pairs(selected) do
                                        if selectedPlayer == (v :: Player).Name then
                                            return 0;
                                        end
                                    end

                                    return props.Style.ButtonTransparency:get();
                                end);
                                LayoutOrder = i;
                                Size = UDim2.new(1,0,0,40);
                                [Event "MouseButton1Click"] = function()
                                    if MultiSelect:get() == false then
                                        r.Close();
                                        SelFunc((v :: Player).Name)
                                        Picked:set((v :: Player).Name)
                                        return;
                                    end

                                    -- if selected
                                    local selected = string.split(Picked:get(),",");
                                    if #selected == 1 and selected[1] == "" then
                                        selected = {};
                                    end
                                    for _,selectedPlayer: string in pairs(selected) do
                                        if selectedPlayer == (v :: Player).Name then
                                            -- Deselect
                                            table.remove(selected,table.find(selected,v));
                                            SelFunc(table.concat(selected,","));
                                            Picked:set(table.concat(selected,","))
                                            return;
                                        end
                                    end
                                    table.insert(selected,(v :: Player).Name);
                                    SelFunc(table.concat(selected,","));
                                    Picked:set(table.concat(selected,","))
                                end;
                                [Children] = {
                                    -- Thumbnail
                                    New "ImageLabel" {
                                        BackgroundColor3 = props.Style.BackgroundSubSubColor;
                                        Image = img;
                                        Position = UDim2.new(0,1,0,1);
                                        Size = UDim2.new(0,38,0,38);
                                    };
                                    Labels;
                                }
                            }
                        end
                        return i, New "TextButton" {
                            BackgroundTransparency = props.Style.ButtonTransparency;
                            BackgroundColor3 = props.Style.ButtonSubColor;
                            Size = UDim2.new(1,0,0,25);
                            FontFace = props.Style.Font;
                            Text = Computed(function()
                                return Picked:get() == i and "> " .. (v :: string) or v;
                            end);
                            TextColor3 = props.Style.TextColor;
                            TextScaled = true;
                            LayoutOrder = i;
                            ZIndex = 25;

                            [Event "MouseButton1Click"] = function()
                                r.Close();
                                if typeof(SelFunc) == "function" then
                                    SelFunc(i);
                                    Picked:set(i);
                                end
                            end
                        }
                    end,Fusion.cleanup);
                }
            }
        }
    }

    con = UserInputService.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1 then
            if Visible:get() then
                if input.Position.X >= Ui.AbsolutePosition.X and input.Position.X <= Ui.AbsolutePosition.X + Ui.AbsoluteSize.X and
                   input.Position.Y >= Ui.AbsolutePosition.Y and input.Position.Y <= Ui.AbsolutePosition.Y + Ui.AbsoluteSize.Y then
                    -- Click is within frame, do nothing
                else
                    -- Hide Menu
                    Visible:set(false);
                end
                
            end
        end
    end)

    function r.Show(Options: {string}, Selected: number, Button: TextButton, Select: (any) -> (), Players: boolean, Multi: boolean)
        PlayerList:set(Players);
        MultiSelect:set(Multi);
        Visible:set(true);
        List:set(Options);
        Picked:set(Selected);
        SelFunc = Select;
        -- Position
        local RelPos: Vector2 = (Ui.Parent :: GuiObject).AbsolutePosition;
        local y = Button.AbsolutePosition.Y - RelPos.Y;
        local ListSize = math.min(Players and (#List:get() * 41 + 27 + (Multi and 26 or 0)) or (#List:get() * 26 + 2), ScreenGui.AbsoluteSize.Y - 30);
        if RelPos.Y + ListSize >= ScreenGui.AbsoluteSize.Y - 15 then
            y = math.max(ScreenGui.AbsoluteSize.Y - 1 - ListSize - RelPos.Y, 15 - RelPos.Y);
        end
        Position:set(UDim2.new(0,Button.AbsolutePosition.X - RelPos.X,0,y));
        -- Reset Search Options
        if Search:get() then
            Search:get().Text = "";
        end
    end

    function r.Close()
        Visible:set(false);
    end

    function r.Ui(): GuiObject
        return Ui;
    end

    return r :: any;
end

function DropdownMenu(props: {
    Style: {[string]: any};
    Y: number;
    Title: string;
    Value: {string} | {Player};
    Dropdown: {Show: (Options: {string}, Selected: number, Button: TextButton, Select: (any) -> (), Players: boolean, Multi: boolean) -> (), Close: () -> (), Ui: () -> (GuiObject)};
    DefaultValue: string;
    UpdateValue: (NewValue: string) -> ();
    ZIndex: number;
    Player: boolean;
    MultiSelect: boolean;
})
    local Selected = Value(1);

    if props.Player then
        Selected:set(props.DefaultValue or "");
    else
        if props.DefaultValue == nil then
            table.insert(props.Value,1,"Select")
        end
    end

    local List = props.Value

    local TextBtn
    TextBtn = New "TextButton" {
        BackgroundColor3 = props.Style.ButtonColor;
        BackgroundTransparency = 0.95;
        BorderSizePixel = 0;
        Position = UDim2.new(0.5,0,0,0);
        Size = UDim2.new(0.5,0,1,0);
        FontFace = props.Style.Font;
        Text = Computed(function()
            if props.Player then
                if Selected:get() == "" then
                    return "> Select";
                else
                    return "> " .. Selected:get();
                end
            end
            return "> " .. List[Selected:get()];
        end);
        TextColor3 = props.Style.TextColor;
        TextScaled = true;
        ZIndex = 21;

        [Event "MouseButton1Up"] = function()
            task.wait();
            props.Dropdown.Show(List,Selected:get(),TextBtn,function(i: number | string)
                Selected:set(i);
                if props.Player then
                    props.UpdateValue((i :: string));
                else
                    props.UpdateValue(List[(i :: number)]);
                end
            end,props.Player,props.MultiSelect);
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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
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
                FontFace = props.Style.Font;
                Text = Text;
                TextColor3 = props.Style.TextColor;
                TextScaled = true;
                RichText = props.RichText;
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
