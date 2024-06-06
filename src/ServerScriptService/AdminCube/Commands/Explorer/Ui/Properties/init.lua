-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local props = require(script:WaitForChild("Props"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {}

local ValueTypesUi = {
    Primitive = require(script:WaitForChild("ValueTypes"):WaitForChild("Primitive"));
    DataType = require(script:WaitForChild("ValueTypes"):WaitForChild("DataType"));
    Enum = require(script:WaitForChild("ValueTypes"):WaitForChild("Enum"));
    Class = require(script:WaitForChild("ValueTypes"):WaitForChild("Class"));
}

function Module.Category(Shared: table,Cat: string,Props: table): GuiObject
    local ScrollSize = Value(Vector2.new(0,0))
    local Visible = Value(true)
    local Above = Value(false)
    return New "Frame" {
        BackgroundTransparency = 1;
        Size = Computed(function()
            if ScrollSize and typeof(ScrollSize:get()) == "Vector2" then
                return UDim2.new(1,0,0,ScrollSize:get().Y)
            end
            return UDim2.new(1,0,0,0);
        end);
        ZIndex = Computed(function()
            if Above and Above:get() then
                return 2;
            end
            return 1;
        end);
        Visible = Computed(function()
            local toSearch = string.lower(string.gsub(Shared.Search:get(),"%s",""))
            if toSearch == "" then
                return true
            else
                for i,_ in pairs(Props) do
                    if string.find(string.lower(string.gsub(i,"%s","")),toSearch) then
                        return true
                    end
                end
                return false
            end
        end);
        [Fusion.Cleanup] = {ScrollSize,Visible,Above};
        [Children] = {
            New "UIListLayout" {
                SortOrder = Enum.SortOrder.Name;
                [Fusion.Out "AbsoluteContentSize"] = ScrollSize;
            };
            New "Frame" {
                Name = "00Title";
                Size = UDim2.new(1,0,0,20);
                BackgroundTransparency = Computed(function()
                    return Api.Style.ButtonTransparency:get() * 1.12
                end);
                [Children] = {
                    New "ImageButton" {
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://9170684698";
                        Position = UDim2.new(0,4,0,4);
                        ScaleType = Enum.ScaleType.Fit;
                        Size = UDim2.new(0,12,0,12);
                        ImageColor3 = Api.Style.TextColor;
                        Rotation = Computed(function()
                            if Visible and Visible:get() then
                                return 90;
                            end
                            return 0;
                        end);
                        [Event "MouseButton1Up"] = function()
                            Visible:set(not Visible:get())
                        end;
                    };
                    New "TextLabel" {
                        Size = UDim2.new(1,-20,1,0);
                        Position = UDim2.new(0,20,0,0);
                        BackgroundTransparency = 1;
                        TextColor3 = Api.Style.TextColor;
                        Font = Enum.Font.SourceSansBold;
                        TextSize = 14;
                        Text = Cat;
                        TextXAlignment = Enum.TextXAlignment.Left;
                    }
                }
            };
            Computed(function()
                if Visible and Visible:get() then
                    return Fusion.ForPairs(Computed(function()
                        local toSearch = string.lower(string.gsub(Shared.Search:get(),"%s",""))
                        if toSearch == "" then
                            return Props
                        else
                            local newProps = {}
                            for i,o in pairs(Props) do
                                if string.find(string.lower(string.gsub(i,"%s","")),toSearch) then
                                    newProps[i] = o;
                                end
                            end
                            return newProps
                        end
                    end),function(i: string,o: table) -- Property Name, ValueType Table:: {Category: string, Name: string}
                        -- Properties List
                        local PropUi
                        local AboveOthers = Value(false)
                        Fusion.Observer(AboveOthers):onChange(function()
                            Above:set(AboveOthers:get());
                        end);
                        if ValueTypesUi[o.Category] then
                            PropUi = ValueTypesUi[o.Category].Ui(Shared,i,o,AboveOthers)
                        end
                        local ReadOnly
                        if o.Tags and table.find(o.Tags,"ReadOnly") then
                            ReadOnly = New "Frame" {
                                Size = UDim2.new(1,0,1,0);
                                BackgroundTransparency = 0.5;
                                BackgroundColor3 = Api.Style.Background;
                                ZIndex = 10;
                            }
                        end
                        return i, New "Frame" {
                            BackgroundColor3 = Api.Style.Background;
                            BorderColor3 = Api.Style.BackgroundSubSubColor;
                            BorderMode = Enum.BorderMode.Outline;
                            BorderSizePixel = 1;
                            Size = UDim2.new(1,0,0,20);
                            Name = i;
                            ZIndex = Computed(function()
                                if AboveOthers and AboveOthers:get() then
                                    return 2;
                                end
                                return 1;
                            end);
                            [Fusion.Cleanup] = {AboveOthers,function()
                                Above:set(false)
                            end};
                            [Children] = {
                                -- Line
                                New "Frame" {
                                    BackgroundColor3 = Api.Style.BackgroundSubSubColor;
                                    Position = UDim2.new(0.5,0,0,0);
                                    Size = UDim2.new(0,1,1,0);
                                };
                                -- Name
                                New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    Font = Enum.Font.SourceSans;
                                    Position = UDim2.new(0,20,0,0);
                                    Size = UDim2.new(0.5,-20,1,0);
                                    TextColor3 = Api.Style.TextColor;
                                    TextSize = 14;
                                    TextTruncate = Enum.TextTruncate.AtEnd;
                                    TextXAlignment = Enum.TextXAlignment.Left;
                                    Text = i;
                                };
                                PropUi;
                                ReadOnly;
                            }
                        }
                    end,Fusion.cleanup)
                end
                return nil
            end,Fusion.cleanup)
        }
    }
end

function Module.Ui(Shared: table): GuiObject
    local ScrollSize = Value(Vector2.new(0,0));
    return {
        -- Search Box
        New "TextBox" {
            BackgroundTransparency = Api.Style.ButtonTransparency;
            BackgroundColor3 = Api.Style.ButtonColor;
            Size = UDim2.new(1,0,0,25);
            Font = Enum.Font.SourceSans;
            TextSize = 16;
            PlaceholderText = "Filter Properties";
            TextColor3 = Api.Style.TextColor;
            ClearTextOnFocus = true;
            [Fusion.OnChange "Text"] = function(txt)
                if txt then
                    Shared.Search:set(txt);
                end
            end;
        };
        -- List
        New "ScrollingFrame" {
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,1,-25);
            Position = UDim2.new(0,0,0,25);
            ScrollBarThickness = 10;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            ScrollBarImageColor3 = Api.Style.TextColor;
            TopImage = "";
            BottomImage = "";
            CanvasSize = Computed(function()
                if ScrollSize and typeof(ScrollSize:get()) == "Vector2" then
                    return UDim2.new(0,0,0,ScrollSize:get().Y);
                end
                return UDim2.new(0,0,0,0);
            end);
            [Fusion.Cleanup] = ScrollSize;
            [Children] = {
                New "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    [Fusion.Out "AbsoluteContentSize"] = ScrollSize;
                };
                Fusion.ForPairs(Computed(function()
                    local obj = Shared.Selection:get()
                    if obj then
                        return props:GetProperties(obj)
                    end
                    return {}
                end),function(i,o)
                    return i,Module.Category(Shared,i,o);
                end,Fusion.cleanup);
            }
        }
    }
end

return Module
