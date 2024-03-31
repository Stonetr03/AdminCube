-- Admin Cube - Console Loader

local Fusion = require(script.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))
local Layout = require(script.Parent:WaitForChild("Layout"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

return function(style,i,o,typ: "string" | "number" | "any"): GuiObject
    local Ref = Value()
    local IndRef = Value()
    return New "Frame" {
        BackgroundColor3 = style.ButtonColor;
        BackgroundTransparency = style.ButtonTransparency;
        Size = UDim2.new(1,0,0,20);
        LayoutOrder = Computed(function()
            if typeof(i) == "string" or typeof(i) == "number" then
                return Layout(i)
            end
            return Layout(i:get())
        end);
        [Fusion.Cleanup] = {Ref,IndRef,o};
        [Children] = {
            -- Index
            Computed(function()
                if typeof(i) == "string" or typeof(i) == "number" then
                    -- Non Editable String
                    return New "TextLabel" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSans;
                        Size = UDim2.new(0.5,0,1,0);
                        Text = i;
                        TextColor3 = style.TextColor;
                        TextSize = 20;
                    };
                end
                -- Editable String
                return New "TextBox" {
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(0.5,0,1,0);
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
            New "TextBox" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Size = UDim2.new(0.5,0,1,0);
                Position = UDim2.new(0.5,0,0,0);
                Text = Computed(function()
                    if typeof(o:get()) == "number" then
                        return tostring(o:get());
                    end
                    return '"' .. tostring(o:get()) .. '"';
                end);
                TextColor3 = style.TextColor;
                TextSize = 20;
                TextScaled = Computed(function()
                    local r = Ref:get()
                    if r and r.TextFits == true then
                        return false;
                    end
                    return true;
                end);
                ClearTextOnFocus = false;
                [Fusion.Ref] = Ref;
                [Event "FocusLost"] = function()
                    local txt = Ref:get().Text;
                    if typ == "number" then
                        if tonumber(txt) ~= nil then
                            -- Set Number
                            o:set(tonumber(txt))
                        else
                            Ref:get().Text = tostring(o:get());
                        end
                    elseif typ == "string" then
                        if (string.sub(txt,1,1) == '"' and string.sub(txt,string.len(txt)) == '"') or string.sub(txt,1,1) == "'" and string.sub(txt,string.len(txt)) == "'" then
                            -- Remove String, then set
                            txt = string.sub(txt,2,string.len(txt)-1);
                        end
                        o:set(txt);
                    else -- any typ
                        if tonumber(txt) ~= nil then
                            -- Set Number
                            o:set(tonumber(txt))
                        else
                            -- Set String
                            if (string.sub(txt,1,1) == '"' and string.sub(txt,string.len(txt)) == '"') or string.sub(txt,1,1) == "'" and string.sub(txt,string.len(txt)) == "'" then
                                -- Remove String, then set
                                txt = string.sub(txt,2,string.len(txt)-1);
                            end
                            o:set(txt);
                        end
                    end
                end
            };
        }
    }
end
