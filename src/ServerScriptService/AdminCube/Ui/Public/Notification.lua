-- Admin Cube

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local HttpService = game:GetService("HttpService")

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Event = Fusion.OnEvent

local Module = {}

-- Values
local ActiveNotifications = {}
local ToRender = Value({})

local Debounce = false
Api:OnEvent("Notification",function(Args)
    repeat
        task.wait()
    until Debounce == false
    Debounce = true
    -- Reload Notifications
    local Button = {}
    if Args.Button then
        Button = Args.Button
    end
    if not Args.Time then
        Args.Time = 10
    end
    local UUID = HttpService:GenerateGUID()
    local Tab = ToRender:get()
    table.insert(Tab,{
        Image = Args.Image;
        Text = Args.Text;
        Button = Button;
        UUID = UUID;
    })
    ToRender:set(Tab)
    table.insert(ActiveNotifications,{
        TimePaused = false;
        Time = Args.Time;
        UUID = UUID;
    })
    Debounce = false;
end)

function Delete(UUID)
    for _,v in pairs(ActiveNotifications) do
        if v.UUID == UUID then
            table.remove(ActiveNotifications,table.find(ActiveNotifications,v))
        end
    end
    local tab = ToRender:get()
    for _,v in pairs(tab) do
        if v.UUID == UUID then
            table.remove(tab,table.find(tab,v))
        end
    end
    ToRender:set(tab)
end

function Module.Ui(props)
    return New "Frame" {
        Size = UDim2.new(0,250,1,-5);
        Position = UDim2.new(1,-5,0,0);
        AnchorPoint = Vector2.new(1,0);
        BackgroundTransparency = 1;
        Parent = props.Parent;
        Name = "NotificationFrame";
        ZIndex = 4;
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
                                        for _,w in pairs(ActiveNotifications) do
                                            if w.UUID == v.UUID then
                                                w.TimePaused = true
                                            end
                                        end
                                    end;
                                    [Event "MouseLeave"] = function()
                                        for _,w in pairs(ActiveNotifications) do
                                            if w.UUID == v.UUID then
                                                w.TimePaused = false
                                                w.Time = 10
                                            end
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
                                                Delete(v.UUID)
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
                                                Delete(v.UUID)
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
                                        for _,w in pairs(ActiveNotifications) do
                                            if w.UUID == v.UUID then
                                                w.TimePaused = true
                                            end
                                        end
                                    end;
                                    [Event "MouseLeave"] = function()
                                        for _,w in pairs(ActiveNotifications) do
                                            if w.UUID == v.UUID then
                                                w.TimePaused = false
                                                w.Time = 10
                                            end
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
                                                Delete(v.UUID)
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
                                                Delete(v.UUID)
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
        for _,v in pairs(ActiveNotifications) do
            if v.TimePaused == false then
                v.Time -= 1
                if v.Time <= 0 then
                    -- Delete
                    Delete(v.UUID)
                end
            end
        end
    end
end)

return Module
