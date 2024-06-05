-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"));
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"));
local HttpService = game:GetService("HttpService");
local TextService = game:GetService("TextService");

local New = Fusion.New;
local Value = Fusion.Value;
local Event = Fusion.OnEvent;
local Computed = Fusion.Computed;
local Children = Fusion.Children;

local Data = HttpService:JSONDecode(script:WaitForChild("info").Value);

local Content, isReady = game.Players:GetUserThumbnailAsync(Data.UserId or 0,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)

local MaxSize = Value(Vector2.new(0,0));

local BanStat = "Ban Status: Not Banned";
local BanReason = "";
if Data.Banned then
    if Data.BanTime == -1 then
        BanStat = "Ban Status: Banned";
    else
        BanStat = "Ban Status: Banned until " .. os.date("%m/%d/%y %H:%M",Data.BanTime) .. " UTC";
    end
    if Data.BanReason then
        BanReason = "Reason: " .. Data.BanReason;
    else
        BanReason = "No Reason Provided";
    end
end
local StatSize = Value(Vector2.new(0,0));
local ReasSize = Value(Vector2.new(0,0));
Fusion.Observer(MaxSize):onChange(function()
    local Max = MaxSize:get()
    if typeof(Max) == "Vector2" then
        StatSize:set(TextService:GetTextSize(BanStat,24,Enum.Font.SourceSans,Vector2.new(Max.X-5,math.huge)));
        if BanReason ~= "" then
            ReasSize:set(TextService:GetTextSize(BanReason,24,Enum.Font.SourceSans,Vector2.new(Max.X-5,math.huge)));
        end
    end
end)

local Ranks = {
    [0] = "Player";
    [1] = "VIP";
    [2] = "Mod";
    [3] = "Admin";
    [4] = "Owner";
}
local RankStr = "Player"
if Data.Rank and Ranks[Data.Rank] then
    RankStr = Ranks[Data.Rank];
end

local WindowFrame = New "ScrollingFrame" {
    BackgroundTransparency = 1;
    BottomImage = "";
    ScrollBarThickness = 5;
    ScrollingDirection = Enum.ScrollingDirection.Y;
    Size = UDim2.new(1,0,1,0);
    TopImage = "";
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
    ScrollBarImageColor3 = Api.Style.TextColor;
    CanvasSize = Computed(function()
        local StatY = StatSize:get()
        local ReasY = ReasSize:get()
        local Y = 0
        if typeof(StatY) == "Vector2" and typeof(ReasY) == "Vector2" then
            Y = StatY.Y + ReasY.Y;
        end
        return UDim2.new(1,0,0,135 + Y);
    end);
    [Children] = {
        New "ImageLabel" {
            BackgroundColor3 = Api.Style.BackgroundSubSubColor;
            Image = isReady and Content or "rbxasset://textures/ui/GuiImagePlaceholder.png";
            Position = UDim2.new(0,3,0,3);
            Size = UDim2.new(0,94,0,94);
        };
        New "TextBox" {
            BackgroundTransparency = 1;
            ClearTextOnFocus = false;
            Font = Enum.Font.SourceSansBold;
            Position = UDim2.new(0,100,0,3);
            Selectable = false;
            Size = UDim2.new(1,-103,0,30);
            Text = Data.Name or "";
            TextColor3 = Api.Style.TextColor;
            TextEditable = false;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            [Children] = New "UITextSizeConstraint" {
                MaxTextSize = 24;
            };
        };
        New "TextBox" {
            BackgroundTransparency = 1;
            ClearTextOnFocus = false;
            Font = Enum.Font.SourceSans;
            Position = UDim2.new(0,100,0,33);
            Selectable = false;
            Size = UDim2.new(1,-103,0,30);
            Text = Data.UserId or "";
            TextColor3 = Api.Style.TextColor;
            TextEditable = false;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            [Children] = New "UITextSizeConstraint" {
                MaxTextSize = 23;
            };
        };
        New "TextLabel" {
            BackgroundTransparency = 1;
            Font = Enum.Font.SourceSans;
            Position = UDim2.new(0,100,0,63);
            Size = UDim2.new(1,-103,0,30);
            Text = RankStr;
            TextColor3 = Api.Style.TextColor;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            [Children] = New "UITextSizeConstraint" {
                MaxTextSize = 23;
            };
        };
        New "Frame" {
            BackgroundColor3 = Data.Banned and Color3.new(1,0,0) or Color3.new(0,1,0);
            BackgroundTransparency = Api.Style.ButtonTransparency;
            BorderSizePixel = 0;
            Position = UDim2.new(0,3,0,100);
            Size = Computed(function()
                local StatY = StatSize:get()
                local ReasY = ReasSize:get()
                local Y = 0
                if typeof(StatY) == "Vector2" and typeof(ReasY) == "Vector2" then
                    Y = StatY.Y + ReasY.Y;
                end
                return UDim2.new(1,-6,0,Y);
            end);
            [Fusion.Out "AbsoluteSize"] = MaxSize;
            [Children] = {
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSans;
                    Position = UDim2.new(0,5,0,0);
                    Size = Computed(function()
                        local StatY = StatSize:get()
                        local Y = 0
                        if typeof(StatY) == "Vector2" then
                            Y = StatY.Y;
                        end
                        return UDim2.new(1,-5,0,Y)
                    end);
                    Text = BanStat;
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 24;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                };
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSans;
                    Position = Computed(function()
                        local StatY = StatSize:get()
                        local Y = 0
                        if typeof(StatY) == "Vector2" then
                            Y = StatY.Y;
                        end
                        return UDim2.new(0,5,0,Y);
                    end);
                    Size = Computed(function()
                        local ReasY = ReasSize:get()
                        local Y = 0
                        if typeof(ReasY) == "Vector2" then
                            Y = ReasY.Y;
                        end
                        return UDim2.new(1,-5,0,Y);
                    end);
                    Text = BanReason;
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 24;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextYAlignment = Enum.TextYAlignment.Top;
                }
            }
        };
        New "TextButton" {
            BackgroundColor3 = Api.Style.ButtonColor;
            BackgroundTransparency = Api.Style.ButtonTransparency;
            Font = Enum.Font.SourceSans;
            Position = Computed(function()
                local StatY = StatSize:get()
                local ReasY = ReasSize:get()
                local Y = 0
                if typeof(StatY) == "Vector2" and typeof(ReasY) == "Vector2" then
                    Y = StatY.Y + ReasY.Y;
                end
                return UDim2.new(0,3,0,105 + Y)
            end);
            Size = UDim2.new(0,100,0,25);
            Text = Data.Banned and "Unban" or "Ban";
            TextColor3 = Api.Style.TextColor;
            TextSize = 22;
            [Event "MouseButton1Up"] = function()
                if Data.Banned then
                    Api:Fire("CmdBar","!unban " .. Data.Name);
                else
                    Api:Fire("CmdBar","!ban " .. Data.Name);
                end
            end;
        }

    }
};

local Window = Api:CreateWindow({
    Size = Vector2.new(300,200);
    Title = Data.Name and "Profile: " .. Data.Name or "Profile";
    ResizeableMinimum = Vector2.new(250,150);
    Resizeable = true;
},WindowFrame)
Window.SetVis(true)

Window.OnClose:Connect(function()
    Window.unmount()
    script:Destroy()
end)

