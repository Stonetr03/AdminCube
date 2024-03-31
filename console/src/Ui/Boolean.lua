-- Admin Cube - Console Loader

local Fusion = require(script.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))
local Layout = require(script.Parent:WaitForChild("Layout"))

local New = Fusion.New
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

return function(style,i,o): GuiObject
    return New "Frame" {
        BackgroundColor3 = style.ButtonColor;
        BackgroundTransparency = style.ButtonTransparency;
        Size = UDim2.new(1,0,0,20);
        LayoutOrder = Layout(i);
        [Fusion.Cleanup] = {o};
        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Size = UDim2.new(0.5,0,1,0);
                Text = i;
                TextColor3 = style.TextColor;
                TextSize = 20;
            };
            New "TextButton" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundTransparency = 0;
                BackgroundColor3 = Computed(function()
                    if o:get() == true then
                        return Color3.fromRGB(0,207,0);
                    end
                    return Color3.fromRGB(207,0,3);
                end);
                Position = UDim2.new(0.75,0,0.5,0);
                Size = UDim2.new(0.1,0,0.9,0);
                Text = "";
                ZIndex = 21;

                [Event "MouseButton1Up"] = function()
                    o:set(not o:get())
                end;
                [Children] = {
                    UiCorner = New "UICorner" {
                        CornerRadius = UDim.new(0.5,0);
                    };
                    Frame = New "Frame" {
                        AnchorPoint = Vector2.new(0,0.5);
                        BackgroundColor3 = style.ButtonColor;
                        Position = Computed(function()
                            if o:get() == true then
                                return UDim2.new(0.45,0,0.5,0);
                            end
                            return UDim2.new(0.05,0,0.5,0);
                        end);
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
