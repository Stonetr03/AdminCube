-- Stonetr03

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Notifications = Roact.Component:extend("NotificationMain")
local ToRender = {}

local Tab = {
    ReloadFunc = nil;
    Comp = Notifications;
}

Api:OnEvent("Notification",function(Args)
    -- Reload Notifications
    local Button = {}
    if Args.Button then
        Button = Args.Button
    end
    table.insert(ToRender,{
        Image = Args.Image;
        Text = Args.Text;
        TimePaused = false;
        Time = 10;
        Button = Button;
    })
    Tab.ReloadFunc()
end)

local NotificationList = Roact.Component:extend("NotificationList")

function NotificationList:render()
    local List = {}
    for i,o in pairs(ToRender) do
        if ToRender[i].Image == true then
            local content = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            ToRender[i].Image = content;
        end
        local ButtonVis = false;
        local ButtonTxt = ""
        local ButtonUUID = ""
        if ToRender[i].Button then
            if typeof(ToRender[i].Button[1]) == "string" and typeof(ToRender[i].Button[2]) == "string" then
                ButtonTxt = ToRender[i].Button[1]
                ButtonUUID = ToRender[i].Button[2]
                ButtonVis = true
            end
        end
        if ToRender[i].Image ~= false then
            List[i] = Roact.createElement("Frame",{
                BackgroundColor3 = Api.Style.BackgroundSubColor;
                BorderSizePixel = 0;
                Size = UDim2.new(0,250,0,110);
                ZIndex = 1;
            },{
                Frame = Roact.createElement("Frame",{
                    BackgroundColor3 = Api.Style.Background;
                    BorderSizePixel = 0;
                    AnchorPoint = Vector2.new(0.5,0.5);
                    Position = UDim2.new(0.5,0,0.5,0);
                    Size = UDim2.new(1,-4,1,-4);
                    ZIndex = 3;

                    [Roact.Event.MouseEnter] = function()
                        ToRender[i].TimePaused = true
                    end;
                    [Roact.Event.MouseLeave] = function()
                        ToRender[i].TimePaused = false
                        ToRender[i].Time = 10
                    end;
                },{
                    CloseBtn = Roact.createElement("TextButton",{
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
                        
                        [Roact.Event.MouseButton1Up] = function()
                            ToRender[i] = nil
                            Tab.ReloadFunc()
                        end
                    });
                    Image = Roact.createElement("ImageLabel",{
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0,2,0,24);
                        Size = UDim2.new(0,80,0,80);
                        Image = ToRender[i].Image;
                        ZIndex = 5;
                    });
                    Body = Roact.createElement("TextLabel",{
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0,84,0,24);
                        Size = UDim2.new(0,160,0,80);
                        ZIndex = 5;
                        Font = Enum.Font.SourceSans;
                        Text = ToRender[i].Text;
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 16;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;
                    });
                    Title = Roact.createElement("TextLabel",{
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
                    });
                    Button = Roact.createElement("TextButton",{
                        AnchorPoint = Vector2.new(1,1);
                        Position = UDim2.new(1,-2,1,-2);
                        BackgroundColor3 = Api.Style.BackgroundSubColor;
                        BorderSizePixel = 0;
                        Size = UDim2.new(0, 100,0, 30);
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 12;
                        ZIndex = 10;

                        Text = ButtonTxt;
                        Visible = ButtonVis;
                        [Roact.Event.MouseButton1Up] = function()
                            Api:Fire("_NotificationCallback",ButtonUUID)
                        end;
                    });
                })
            })
        else
            List[i] = Roact.createElement("Frame",{
                BackgroundColor3 = Api.Style.BackgroundSubColor;
                BorderSizePixel = 0;
                Size = UDim2.new(0,250,0,110);
                ZIndex = 1;
            },{
                Frame = Roact.createElement("Frame",{
                    BackgroundColor3 = Api.Style.Background;
                    BorderSizePixel = 0;
                    AnchorPoint = Vector2.new(0.5,0.5);
                    Position = UDim2.new(0.5,0,0.5,0);
                    Size = UDim2.new(1,-4,1,-4);
                    ZIndex = 3;
                },{
                    CloseBtn = Roact.createElement("TextButton",{
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

                        [Roact.Event.MouseButton1Up] = function()
                            ToRender[i] = nil
                            Tab.ReloadFunc()
                        end
                    });
                    Body = Roact.createElement("TextLabel",{
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0,2,0,24);
                        Size = UDim2.new(0,246,0,80);
                        ZIndex = 5;
                        Font = Enum.Font.SourceSans;
                        Text = ToRender[i].Text;
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 16;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;
                    });
                    Title = Roact.createElement("TextLabel",{
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
                    });
                    Button = Roact.createElement("TextButton",{
                        AnchorPoint = Vector2.new(1,1);
                        Position = UDim2.new(1,-2,1,-2);
                        BackgroundColor3 = Api.Style.BackgroundSubColor;
                        BorderSizePixel = 0;
                        Size = UDim2.new(0, 100,0, 30);
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 12;
                        ZIndex = 10;

                        Text = ButtonTxt;
                        Visible = ButtonVis;
                        [Roact.Event.MouseButton1Up] = function()
                            Api:Fire("_NotificationCallback",ButtonUUID)
                        end;
                    });
                })
            })
        end
    end
    return Roact.createFragment(List)
end

function Notifications:render()
    return Roact.createElement("Frame",{
        Size = UDim2.new(0,250,1,-5);
        Position = UDim2.new(1,-5,0,0);
        AnchorPoint = Vector2.new(1,0);
        BackgroundTransparency = 1;
    },{
        UiListLayout = Roact.createElement("UIListLayout",{
            Padding = UDim.new(0,5);
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        });
        List = Roact.createElement(NotificationList)
    })
end

task.spawn(function()
    task.wait(1)
    while true do
        task.wait(1)
        for i,v in pairs(ToRender) do
            if ToRender[i].TimePaused == false then
                ToRender[i].Time -= 1
                if ToRender[i].Time <= 0 then
                    ToRender[i] = nil
                    Tab.ReloadFunc()
                end
            end
        end
    end
end)

return Tab
