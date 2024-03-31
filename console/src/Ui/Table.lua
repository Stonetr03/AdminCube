-- Admin Cube - Console Loader

local Fusion = require(script.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))
local Layout = require(script.Parent:WaitForChild("Layout"))
local Util = require(script.Parent:WaitForChild("Util"))

local Boolean = require(script.Parent:WaitForChild("Boolean"))
local String = require(script.Parent:WaitForChild("String"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

function ui(style,i,o,editable: boolean): GuiObject -- Style Table, index, object, make descendants editable indexes
    local Vis = Value(false)
    local contentSize = Value(Vector2.new(0,0))
    local IndRef = Value()
    if typeof(editable) ~= "boolean" then
        editable = false;
    end
    return New "Frame" {
        BackgroundColor3 = style.ButtonColor;
        BackgroundTransparency = 1;
        Size = Computed(function()
            local size = 0
            if contentSize then
                size = contentSize:get()
            end
            if typeof(size) == "Vector2" then
                size = size.Y
            else
                size = 0
            end
            if Vis:get() == true then
               return UDim2.new(1,0,0,23 + size)
            end
            return UDim2.new(1,0,0,20)
        end);
        LayoutOrder = Computed(function()
            if typeof(i) == "string" or typeof(i) == "number" then
                return Layout(i)
            end
            return Layout(i:get())
        end);
        [Fusion.Cleanup] = {o,Vis,IndRef,contentSize};
        [Children] = {
            -- Index
            Computed(function()
                if typeof(i) == "string" or typeof(i) == "number" then
                    -- Non Editable String
                    return New "TextLabel" {
                        BackgroundTransparency = style.ButtonTransparency;
                        Font = Enum.Font.SourceSans;
                        Size = UDim2.new(0.5,0,0,20);
                        Text = i;
                        TextColor3 = style.TextColor;
                        TextSize = 20;
                    };
                end
                -- Editable String
                return New "TextBox" {
                    BackgroundTransparency = style.ButtonTransparency;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(0.5,0,0,20);
                    Text = Computed(function()
                        if typeof(i:get()) == "number" then
                            return tostring(i:get());
                        end
                        return '"' .. tostring(i:get()) .. '"';
                    end);
                    TextColor3 = style.TextColor;
                    TextSize = 20;
                    TextScaled = Computed(function()
                        local r = IndRef:get()
                        if r and r.TextFits == true then
                            return false;
                        end
                        return true;
                    end);
                    ClearTextOnFocus = false;
                    [Fusion.Ref] = IndRef;
                    [Event "FocusLost"] = function()
                        local txt = IndRef:get().Text;
                        if typeof(i:get()) == "number" then
                            if tonumber(txt) ~= nil then
                                -- Set Number
                                i:set(tonumber(txt))
                            else
                                IndRef:get().Text = tostring(i:get());
                            end
                        else
                            if (string.sub(txt,1,1) == '"' and string.sub(txt,string.len(txt)) == '"') or string.sub(txt,1,1) == "'" and string.sub(txt,string.len(txt)) == "'" then
                                -- Remove String, then set
                                txt = string.sub(txt,2,string.len(txt)-1);
                            end
                            i:set(txt);
                        end
                    end
                };
            end,Fusion.cleanup);
            -- Value
            New "TextButton" {
                BackgroundTransparency = style.ButtonTransparency;
                Font = Enum.Font.SourceSans;
                Size = UDim2.new(0.5,0,0,20);
                Position = UDim2.new(0.5,0,0,0);
                Text = Computed(function()
                    local txt = "+"
                    if Vis:get() then
                        txt = "-"
                    end
                    if Util.length(o:get()) > 0 then
                        return "{...}  " .. txt;
                    end
                    return "{}  " .. txt;
                end);
                TextColor3 = style.TextColor;
                TextSize = 20;
                [Event "MouseButton1Up"] = function()
                    Vis:set(not Vis:get())
                end;
            };
            New "Frame" {
                Visible = Vis;
                BackgroundTransparency = style.ButtonTransparency;
                Position = UDim2.new(0,1,0,23);
                Size = UDim2.new(0,3,1,-23);
            };
            New "Frame" {
                Visible = Vis;
                BackgroundTransparency = 1;
                Position = UDim2.new(0,7,0,23);
                Size = UDim2.new(1,-7,1,-26);
                [Children] = {
                    New "UIListLayout" {
                        Padding = UDim.new(0,3);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        [Fusion.Out "AbsoluteContentSize"] = contentSize;
                    };
                    Computed(function()
                        if typeof(i) == "string" and i == "Client" then
                            return Fusion.ForPairs(o:get(),function(i2,o2)
                                local val = Value(o2)
                                Fusion.Observer(val):onChange(function()
                                    o2 = val:get()
                                    local tmp = o:get()
                                    tmp[i2] = val:get()
                                    o:set(tmp)
                                end)
                                if typeof(o2) == "table" then
                                    return i2,ui(style,i2,val)
                                elseif typeof(o2) == "boolean" then
                                    return i2,Boolean(style,i2,val)
                                else
                                    local typ = "any"
                                    if typeof(o2) == "number" then
                                        typ = "number";
                                    elseif typeof(o2) == "string" then
                                        typ = "string";
                                    end
                                    return i2,String(style,i2,val,typ)
                                end
                            end,Fusion.cleanup);
                        else
                            return {
                                New "TextButton" {
                                    LayoutOrder = 2147483647;
                                    Size = UDim2.new(1,0,0,17);
                                    Font = Enum.Font.SourceSans;
                                    Text = "Add";
                                    TextColor3 = style.TextColor;
                                    BackgroundTransparency = style.ButtonTransparency;
                                    TextSize = 16;
                                    [Event "MouseButton1Up"] = function()
                                        if typeof(i) == "string" and i == "Groups" then
                                            local tmp = o:get()
                                            table.insert(tmp,{})
                                            o:set(tmp);
                                        else
                                            local tmp = o:get()
                                            table.insert(tmp,"")
                                            o:set(tmp);
                                        end
                                    end;
                                };
                                Fusion.ForPairs(o:get(),function(i2,o2)
                                    local i3 = i2
                                    local val = Value(o2)
                                    if typeof(i) == "string" and i == "Groups" or editable then
                                        i3 = Value(i2);
                                        Fusion.Observer(i3):onChange(function()
                                            local tmp = o:get()
                                            tmp[i2] = nil;
                                            tmp[i3:get()] = val:get();
                                            i2 = i3:get()
                                            o:set(tmp)
                                        end)
                                    end
                                    Fusion.Observer(val):onChange(function()
                                        o2 = val:get()
                                        local tmp = o:get()
                                        tmp[i2] = val:get()
                                        o:set(tmp)
                                    end)
                                    if typeof(o2) == "table" then
                                        return i2,ui(style,i3,val,typeof(i) == "string" and i == "Groups")
                                    else
                                        return i2,String(style,i3,val,"any")
                                    end
                                end,Fusion.cleanup)
                            }
                        end;
                    end,Fusion.cleanup);
                }
            }
        }
    }
end

return ui
