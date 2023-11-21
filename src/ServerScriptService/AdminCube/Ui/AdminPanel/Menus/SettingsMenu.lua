-- Admin Cube - Settings Menu

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Visible = Value(false)
local Render = Value(Api.Settings)
local CurrentSet = Value("global")

Api.Settings.Changed:Connect(function()
    Render:set(table.clone(Api.Settings))
end)

local SetVis = function(Vis)
    Visible:set(Vis)
end

function MenuBtn(props)
    return New "TextButton" {
        Name = "Settings";
        Text = "Settings";
        LayoutOrder = 2;
        Visible = props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        TextSize = 8;
        Font = Enum.Font.Legacy;
        [Event "MouseButton1Up"] = function()
            SetVis(true)
            props.SetVis(false)
        end
    }
end

function BackCallBack()
    if CurrentSet:get() == "global" then
        SetVis(false)
    else
        CurrentSet:set("global")
    end
end


function Menu()
    return New "Frame" {
        Name = "Settings";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        ZIndex = 5;
        [Children] = {
            UiListLayout = New "UIListLayout" {
                Padding = UDim.new(0,5);
            };

            UiPadding = New "UIPadding" {
                PaddingTop = UDim.new(0,5);
                PaddingBottom = UDim.new(0,5);
                PaddingLeft = UDim.new(0,5);
                PaddingRight = UDim.new(0,5);
            };

            -- Buttons
            Fusion.ForPairs(Computed(function()
                local set = CurrentSet:get()
                local ren = Render:get()
                if set == "global" then
                    return ren
                end
                if ren[set] and typeof(ren[set]) == "table" then
                    return ren[set]
                end
            end),function(i,o)
                if i == "Changed" or i == "_modifiers" then
                    return i,nil;
                end
                local set2 = CurrentSet:get()
                if Api.Settings._modifiers and Api.Settings._modifiers[set2] and Api.Settings._modifiers[set2][i] and Api.Settings._modifiers[set2][i].Type == "input" then
                    local txtIn = Value("")
                    return i, New "TextBox" {
                        ZIndex = 10;
                        BackgroundColor3 = Api.Style.ButtonColor;
                        BackgroundTransparency = Api.Style.ButtonTransparency;
                        TextColor3 = Api.Style.TextColor;
                        Size = UDim2.new(1,0,0,25);
                        ClearTextOnFocus = false;
                        PlaceholderColor3 = Api.Style.TextColor;
                        PlaceholderText = Computed(function()
                            local set = CurrentSet:get()
                            if typeof(o) == "table" and set == "global" then
                                return i .. " Settings"
                            end
                            local name = i
                            if Api.Settings._modifiers and Api.Settings._modifiers[set] and Api.Settings._modifiers[set][i] and Api.Settings._modifiers[set][i].Text then
                                name = Api.Settings._modifiers[set][i].Text
                            end
                            return name .. " : " .. tostring(o)
                        end);
                        TextSize = 8;
                        Font = Enum.Font.Legacy;
                        Name = Computed(function()
                            if typeof(o) == "table" then
                                return 2 .. i
                            end
                            return 1 .. i
                        end);

                        [Fusion.Ref] = txtIn;
                        [Event "FocusLost"] = function(enter)
                            local input = txtIn:get().Text
                            txtIn:get().Text = ""
                            if enter == true then
                                Api:SetSetting(i,input,CurrentSet:get())
                            end
                        end
                    };
                else
                    return i, New "TextButton" {
                        ZIndex = 10;
                        BackgroundColor3 = Api.Style.ButtonColor;
                        BackgroundTransparency = Api.Style.ButtonTransparency;
                        TextColor3 = Api.Style.TextColor;
                        Size = UDim2.new(1,0,0,25);
                        Text = Computed(function()
                            local set = CurrentSet:get()
                            if typeof(o) == "table" and set == "global" then
                                return i .. " Settings"
                            end
                            local name = i
                            if Api.Settings._modifiers and Api.Settings._modifiers[set] and Api.Settings._modifiers[set][i] and Api.Settings._modifiers[set][i].Text then
                                name = Api.Settings._modifiers[set][i].Text
                            end
                            return name .. " : " .. tostring(o)
                        end);
                        TextSize = 8;
                        Font = Enum.Font.Legacy;
                        Name = Computed(function()
                            if typeof(o) == "table" then
                                return 2 .. i
                            end
                            return 1 .. i
                        end);

                        [Event "MouseButton1Up"] = function()
                            local set = CurrentSet:get()
                            if set == "global" and typeof(o) == "table" then
                                CurrentSet:set(i)
                            else
                                local v = nil;
                                if Api.Settings._modifiers and Api.Settings._modifiers[set] and Api.Settings._modifiers[set][i] and Api.Settings._modifiers[set][i].Value and typeof(Api.Settings._modifiers[set][i].Value) == "table" then
                                    pcall(function()
                                        if table.find(Api.Settings._modifiers[set][i].Value,o) then
                                            local k = table.find(Api.Settings._modifiers[set][i].Value,o) + 1
                                            if k > #Api.Settings._modifiers[set][i].Value then
                                                k = 1;
                                            end
                                            v = Api.Settings._modifiers[set][i].Value[k]
                                        end
                                    end)
                                end
                                Api:SetSetting(i,v,set)
                            end
                        end
                    };
                end
            end,Fusion.cleanup);
        }
    }
end

return {MenuBtn,Menu,BackCallBack}
