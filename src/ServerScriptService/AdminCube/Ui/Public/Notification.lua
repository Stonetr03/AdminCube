-- Admin Cube

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Value = Fusion.Value
local Event = Fusion.OnEvent

local Module = {}

-- Values
local ToRender = Value({})

Api:OnEvent("Notification",function(Args)
    -- Reload Notifications
    local Button = {}
    if Args.Button then
        Button = Args.Button
    end
    if not Args.Time then
        Args.Time = 10
    end
    local Tab = ToRender:get()
    table.insert(Tab,{
        Image = Args.Image;
        Text = Args.Text;
        TimePaused = false;
        Time = Args.Time;
        Button = Button;
    })
    ToRender:set(Tab)
end)

function Module.Ui(props)
    return New "Frame" {
        Size = UDim2.new(0,250,1,-5);
        Position = UDim2.new(1,-5,0,0);
        AnchorPoint = Vector2.new(1,0);
        BackgroundTransparency = 1;
        Parent = props.Parent;
        Name = "NotificationFrame";
        [Children] = {
            UIListLayout = New "UIListLayout" {
                Padding = UDim.new(0,5);
                FillDirection = Enum.FillDirection.Vertical;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            };
            List = Fusion.ForPairs(ToRender,function(i,v)
                if v.Image == true then
                    local content = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    v.Image = content;
                end
                local ButtonVis = false;
                local ButtonTxt = ""
                local ButtonUUID = ""
                if v.Button then
                    if typeof(v.Button[1]) == "string" and typeof(v.Button[2]) == "string" then
                        ButtonTxt = v.Button[1]
                        ButtonUUID = v.Button[2]
                        ButtonVis = true
                    end
                    if v.Image ~= false then
                        return i, New "Frame" {
                            BackgroundColor3 = Api.Style.BackgroundSubColor;
                            BorderSizePixel = 0;
                            Size = UDim2.new(0,250,0,110);
                            ZIndex = 1;

                            [Children] = {
                                Frame = New "Frame" {
                                    BackgroundColor3 = Api.Style.Background;
                                    BorderSizePixel = 0;
                                    AnchorPoint = Vector2.new(0.5,0.5);
                                    Position = UDim2.new(0.5,0,0.5,0);
                                    Size = UDim2.new(1,-4,1,-4);
                                    ZIndex = 3;

                                    [Event "MouseEnter"] = function()
                                        local tab = ToRender:get()
                                        tab[i].TimePaused = true
                                        ToRender:set(tab)
                                    end;
                                    [Event "MouseLeave"] = function()
                                        local tab = ToRender:get()
                                        if tab[i] then
                                            tab[i].TimePaused = false
                                            tab[i].Time = 10
                                            ToRender:set(tab)
                                        end
                                    end;

                                    [Children] = {
                                        CloseBtn = New "TextButton" {
                                            BackgroundColor3 = Api.Style.BackgroundSubColor;
                                            BorderSizePixel = 0;
                                            AnchorPoint = Vector2.new(1,0);
                                            Position = UDim2.new(1,0,0,0);
                                            Size = UDim2.new(0,16,0,16);
                                            ZIndex = 5;
                                            Font = Enum.Font.SourceSansBold;
                                            Text = "X";
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 16;
                                            [Event "MouseButton1Up"] = function()
                                                local tab = ToRender:get()
                                                tab[i] = nil
                                                ToRender:set(tab)
                                            end;
                                        };
                                        Image = New "ImageLabel" {
                                            BackgroundTransparency = 1;
                                            Position = UDim2.new(0,2,0,24);
                                            Size = UDim2.new(0,80,0,80);
                                            Image = v.Image;
                                            ZIndex = 5;
                                        };
                                        Body = New "TextLabel" {
                                            BackgroundTransparency = 1;
                                            Position = UDim2.new(0,84,0,24);
                                            Size = UDim2.new(0,160,0,80);
                                            ZIndex = 5;
                                            Font = Enum.Font.SourceSans;
                                            Text = v.Text;
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 16;
                                            TextWrapped = true;
                                            TextXAlignment = Enum.TextXAlignment.Left;
                                            TextYAlignment = Enum.TextYAlignment.Top;
                                        };
                                        Title = New "TextLabel" {
                                            BackgroundTransparency = 1;
                                            Position = UDim2.new(0,3,0,0);
                                            Size = UDim2.new(0.8,0,0,20);
                                            ZIndex = 5;
                                            Font = Enum.Font.SourceSans;
                                            Text = "Admin Cube";
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 15;
                                            TextXAlignment = Enum.TextXAlignment.Left;
                                            TextYAlignment = Enum.TextYAlignment.Center;
                                        };
                                        Button = New "TextButton" {
                                            AnchorPoint = Vector2.new(1,1);
                                            Position = UDim2.new(1,-2,1,-2);
                                            BackgroundColor3 = Api.Style.BackgroundSubColor;
                                            BorderSizePixel = 0;
                                            Size = UDim2.new(0, 100,0, 30);
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 12;
                                            ZIndex = 10;
                                            TextScaled = true;

                                            Text = ButtonTxt;
                                            Visible = ButtonVis;
                                            [Event "MouseButton1Up"] = function()
                                                Api:Fire("_NotificationCallback",ButtonUUID)
                                                local tab = ToRender:get()
                                                tab[i] = nil
                                                ToRender:set(tab)
                                            end;
                                        }
                                    };
                                }
                            }
                        }
                    else
                        return i, New "Frame" {
                            BackgroundColor3 = Api.Style.BackgroundSubColor;
                            BorderSizePixel = 0;
                            Size = UDim2.new(0,250,0,110);
                            ZIndex = 1;
                            [Children] = {
                                Frame = New "Frame" {
                                    BackgroundColor3 = Api.Style.Background;
                                    BorderSizePixel = 0;
                                    AnchorPoint = Vector2.new(0.5,0.5);
                                    Position = UDim2.new(0.5,0,0.5,0);
                                    Size = UDim2.new(1,-4,1,-4);
                                    ZIndex = 3;

                                    [Event "MouseEnter"] = function()
                                        local tab = ToRender:get()
                                        tab[i].TimePaused = true
                                        ToRender:set(tab)
                                    end;
                                    [Event "MouseLeave"] = function()
                                        local tab = ToRender:get()
                                        if tab[i] then
                                            tab[i].TimePaused = false
                                            tab[i].Time = 10
                                            ToRender:set(tab)
                                        end
                                    end;

                                    [Children] = {
                                        CloseBtn = New "TextButton" {
                                            BackgroundColor3 = Api.Style.BackgroundSubColor;
                                            BorderSizePixel = 0;
                                            AnchorPoint = Vector2.new(1,0);
                                            Position = UDim2.new(1,0,0,0);
                                            Size = UDim2.new(0,16,0,16);
                                            ZIndex = 5;
                                            Font = Enum.Font.SourceSansBold;
                                            Text = "X";
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 16;
                                            [Event "MouseButton1Up"] = function()
                                                local tab = ToRender:get()
                                                tab[i] = nil
                                                ToRender:set(tab)
                                            end;
                                        };
                                        Body = New "TextLabel" {
                                            BackgroundTransparency = 1;
                                            Position = UDim2.new(0,2,0,24);
                                            Size = UDim2.new(0,246,0,80);
                                            ZIndex = 5;
                                            Font = Enum.Font.SourceSans;
                                            Text = v.Text;
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 16;
                                            TextWrapped = true;
                                            TextXAlignment = Enum.TextXAlignment.Left;
                                            TextYAlignment = Enum.TextYAlignment.Top;
                                        };
                                        Title = New "TextLabel" {
                                            BackgroundTransparency = 1;
                                            Position = UDim2.new(0,3,0,0);
                                            Size = UDim2.new(0.8,0,0,20);
                                            ZIndex = 5;
                                            Font = Enum.Font.SourceSans;
                                            Text = "Admin Cube";
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 15;
                                            TextXAlignment = Enum.TextXAlignment.Left;
                                            TextYAlignment = Enum.TextYAlignment.Center;
                                        };
                                        Button = New "TextButton" {
                                            AnchorPoint = Vector2.new(1,1);
                                            Position = UDim2.new(1,-2,1,-2);
                                            BackgroundColor3 = Api.Style.BackgroundSubColor;
                                            BorderSizePixel = 0;
                                            Size = UDim2.new(0, 100,0, 30);
                                            TextColor3 = Api.Style.TextColor;
                                            TextSize = 12;
                                            ZIndex = 10;
                                            TextScaled = true;
        
                                            Text = ButtonTxt;
                                            Visible = ButtonVis;
                                            [Event "MouseButton1Up"] = function()
                                                Api:Fire("_NotificationCallback",ButtonUUID)
                                                local tab = ToRender:get()
                                                tab[i] = nil
                                                ToRender:set(tab)
                                            end;
                                        }
                                    }
                                }
                            }
                        }
                    end
                end
                return i,v
            end,Fusion.cleanup)
        }
    }
end

task.spawn(function()
    task.wait(1)
    while true do
        task.wait(1)
        local Tab = ToRender:get()
        for i,v in pairs(Tab) do
            if Tab[i].TimePaused == false then
                Tab[i].Time -= 1
                if Tab[i].Time <= 0 then
                    Tab[i] = nil
                end
            end
        end
        ToRender:set(Tab)
    end
end)

return Module
