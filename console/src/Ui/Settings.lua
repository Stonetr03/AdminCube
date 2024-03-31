-- Admin Cube - Console Loader - Settings Menu

local Fusion = require(script.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))
local Boolean = require(script.Parent:WaitForChild("Boolean"))
local String = require(script.Parent:WaitForChild("String"))
local Table = require(script.Parent:WaitForChild("Table"))

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {
    CurrentSettings = nil;
    Visible = nil;
}

function Module.Ui(style)
    local canvasSize = Value(Vector2.new(0,0))

    return New "ScrollingFrame" {
        Visible = Module.Visible;
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
        TopImage = "";
        BottomImage = "";
        ScrollBarImageColor3 = style.TextColor;
        ScrollBarThickness = 5;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        VerticalScrollBarInset = Enum.ScrollBarInset.None;
        CanvasSize = Computed(function()
            local size = 0
            if canvasSize then
                size = canvasSize:get()
            end
            if typeof(size) == "Vector2" then
                size = size.Y
            else
                size = 0
            end
            return UDim2.new(1,0,0,size + 6)
        end);

        [Children] = {
            New "UIListLayout" {
                Padding = UDim.new(0,3);
                SortOrder = Enum.SortOrder.LayoutOrder;
                [Fusion.Out "AbsoluteContentSize"] = canvasSize;
            };
            New "UIPadding" {
                PaddingBottom = UDim.new(0,3);
                PaddingLeft = UDim.new(0,3);
                PaddingRight = UDim.new(0,8);
                PaddingTop = UDim.new(0,3);
            };
            -- Header
            New "TextLabel" {
                BackgroundColor3 = style.ButtonColor;
                BackgroundTransparency = style.ButtonTransparency;
                Font = Enum.Font.SourceSans;
                Size = UDim2.new(1,0,0,30);
                Text = "Admin Cube Settings";
                TextColor3 = style.TextColor;
                TextSize = 22;
            };
            -- Settings
            Fusion.ForPairs(Module.CurrentSettings,function(i,o)
                local val = Value(o)
                Fusion.Observer(val):onChange(function()
                    o = val:get()
                    local tmp = Module.CurrentSettings:get()
                    tmp[i] = val:get()
                    Module.CurrentSettings:set(tmp)
                end)
                if typeof(o) == "table" then
                    return i,Table(style,i,val)
                elseif typeof(o) == "boolean" then
                    return i,Boolean(style,i,val)
                else
                    local typ = "any"
                    if typeof(o) == "number" then
                        typ = "number";
                    elseif typeof(o) == "string" then
                        typ = "string";
                    end
                    return i,String(style,i,val,typ)
                end
            end,Fusion.cleanup);
        }
    }
end

return Module
