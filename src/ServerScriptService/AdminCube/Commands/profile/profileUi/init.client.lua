-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any;
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any;
local Markdown = require(script:WaitForChild("Markdown"));
local HttpService = game:GetService("HttpService");
local LocalizationService = game:GetService("LocalizationService");

local New = Fusion.New;
local Value = Fusion.Value;
local Event = Fusion.OnEvent;
local Computed = Fusion.Computed;
local Children = Fusion.Children;

local Data = HttpService:JSONDecode(script:WaitForChild("info").Value) :: {
    Name: string;
    UserId: number;
    Rank: number;
    FirstJoin: number;
    TimePlayed: number;
    TimeSession: number;
    Notes: string;
    Banned: number; -- 0:false, 1:true, -1:unknown/error
    Status: number;
    Page: {
        [number]: {
            Ban: boolean;
            PlaceId: number;
            PrivateReason: string;
            DisplayReason: string;
            Duration: number;
            StartTime: string;
        }
    };
    PageFinished: boolean;
};

local NotesValue = Value(Data.Notes);
local NotesEditing = Value(false);
local EditBoxRef = Value();

function FormatTime(sec: number): string
    local days = sec // 86400
    sec = sec % 86400

    local hours = sec // 3600
    sec = sec % 3600

    local minutes = sec // 60
    sec = sec % 60

    -- Pads single digits with leading zeros
    local function pad(n)
        return string.format("%02d", n)
    end

    local timeParts = { pad(sec) }

    if days > 0 then
        table.insert(timeParts, 1, pad(minutes))
        table.insert(timeParts, 1, pad(hours))
        table.insert(timeParts, 1, pad(days))
    elseif hours > 0 then
        table.insert(timeParts, 1, pad(minutes))
        table.insert(timeParts, 1, pad(hours))
    elseif minutes > 0 then
        table.insert(timeParts, 1, pad(minutes))
    end

    return table.concat(timeParts, ":")
end

local Content, isReady = game.Players:GetUserThumbnailAsync(Data.UserId or 0,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)

local Plr = game.Players:GetPlayerByUserId(Data.UserId);

local Ranks = {
    [0] = "Player";
    [1] = "VIP";
    [2] = "Mod";
    [3] = "Admin";
    [4] = "Owner";
}
local RankStr = "Player"
local FirstJoin = "";
local TimePlayed = "";

if Data.Rank and Ranks[Data.Rank] then
    RankStr = Ranks[Data.Rank];
end
if Data.FirstJoin and Data.FirstJoin > 0 then
    FirstJoin = "First Join on " .. DateTime.fromUnixTimestamp(Data.FirstJoin):FormatLocalTime("lll", LocalizationService.RobloxLocaleId);
end
if Data.TimePlayed and Data.TimePlayed > 0 then
    TimePlayed = "Time Played: " .. FormatTime(Data.TimePlayed);
    if Data.TimeSession and Data.TimeSession > 0 then
        TimePlayed = TimePlayed .. " (This Session: " .. FormatTime(Data.TimeSession) .. ")";
    end
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
    CanvasSize = UDim2.new(0,0,0,0);
    AutomaticCanvasSize = Enum.AutomaticSize.Y;
    [Children] = {
        New "UIListLayout" {
            Padding = UDim.new(0,3);
            SortOrder = Enum.SortOrder.LayoutOrder;
        };
        New "UIPadding" {
            PaddingTop = UDim.new(0,3);
            PaddingRight = UDim.new(0,3);
            PaddingLeft = UDim.new(0,3);
            PaddingBottom = UDim.new(0,3);
        };
        -- Thumbnail/Username/id/Rank
        New "Frame" {
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,0,94);
            LayoutOrder = 1;
            [Children] = {
                -- Thumbnail
                New "ImageLabel" {
                    BackgroundColor3 = Api.Style.BackgroundSubSubColor;
                    Image = isReady and Content or "rbxasset://textures/ui/GuiImagePlaceholder.png";
                    Size = UDim2.new(0,94,0,94);
                };
                -- Username
                New "TextBox" {
                    BackgroundTransparency = 1;
                    ClearTextOnFocus = false;
                    Font = Enum.Font.SourceSansBold;
                    Position = UDim2.new(0,100,0,0);
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
                -- UserId
                New "TextBox" {
                    BackgroundTransparency = 1;
                    ClearTextOnFocus = false;
                    Font = Enum.Font.SourceSans;
                    Position = UDim2.new(0,100,0,32);
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
                -- Rank
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
            }
        };
        -- First Join
        FirstJoin ~= "" and New "TextBox" {
            LayoutOrder = 2;
            BackgroundTransparency = 1;
            ClearTextOnFocus = false;
            Font = Enum.Font.SourceSans;
            Selectable = false;
            Size = UDim2.new(1,0,0,0);
            AutomaticSize = Enum.AutomaticSize.Y;
            Text = FirstJoin;
            TextColor3 = Api.Style.TextColor;
            TextEditable = false;
            TextSize = 23;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            [Children] = New "UISizeConstraint" {
                MinSize = Vector2.new(0,25);
            };
        } or nil;
        -- Time Played
        TimePlayed ~= "" and New "TextBox" {
            LayoutOrder = 3;
            BackgroundTransparency = 1;
            ClearTextOnFocus = false;
            Font = Enum.Font.SourceSans;
            Selectable = false;
            Size = UDim2.new(1,0,0,0);
            AutomaticSize = Enum.AutomaticSize.Y;
            Text = TimePlayed;
            TextColor3 = Api.Style.TextColor;
            TextEditable = false;
            TextSize = 23;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            [Children] = New "UISizeConstraint" {
                MinSize = Vector2.new(0,25);
            };
        } or nil;
        -- Ban Status
        New "TextBox" {
            LayoutOrder = 4;
            BackgroundColor3 = (Data.Banned == 0 and Color3.new(0,1,0)) or (Data.Banned == 1 and Color3.new(1,0,0)) or Color3.new(0.5,0.5,0.5);
            BackgroundTransparency = 0.85;
            ClearTextOnFocus = false;
            Font = Enum.Font.SourceSans;
            Selectable = false;
            Size = UDim2.new(1,0,0,0);
            AutomaticSize = Enum.AutomaticSize.Y;
            Text = "Ban Status: " .. ((Data.Banned == 0 and "Not Banned") or (Data.Banned == 1 and (Data.Status == -1 and "Permanently Banned" or `Banned until {DateTime.fromUnixTimestamp(Data.Status):FormatLocalTime("lll",LocalizationService.RobloxLocaleId)}`)) or "Unknown");
            TextColor3 = Api.Style.TextColor;
            TextEditable = false;
            TextSize = 24;
            TextWrapped = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            [Children] = {
                New "UISizeConstraint" {
                    MinSize = Vector2.new(0,25);
                };
                New "UIPadding" {
                    PaddingLeft = UDim.new(0,5);
                };
            };
        };
        -- Ban History
        #Data.Page > 0 and New "Frame" {
            LayoutOrder = 5;
            Size = UDim2.new(1,0,0,0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            [Children] = {
                New "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0,1);
                };
                Fusion.ForPairs(Data.Page,function(i: number,o: {Ban: boolean, PlaceId: number, PrivateReason: string, DisplayReason: string, Duration: number, StartTime: string})
                    return i, New "Frame" {
                        BackgroundColor3 = (i == 1 and o.Ban) and Api.Style.BackgroundSubColor or Api.Style.BackgroundSubSubColor;
                        Size = UDim2.new(1,0,0,0);
                        AutomaticSize = Enum.AutomaticSize.Y;
                        LayoutOrder = i;
                        [Children] = {
                            New "UIListLayout" {};
                            -- Title
                            New "TextLabel" {
                                LayoutOrder = 1;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundTransparency = 1;
                                Font = Enum.Font.SourceSansBold;
                                Size = UDim2.new(1,0,0,0);
                                Text = o.Ban == true and (o.Duration == -1 and "Permanently Banned" or "Banned for " .. FormatTime(o.Duration)) or "Unbanned";
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 20;
                                TextWrapped = true;
                                TextXAlignment = Enum.TextXAlignment.Left;
                            };
                            -- Time
                            New "TextLabel" {
                                LayoutOrder = 2;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundTransparency = 1;
                                Font = Enum.Font.SourceSans;
                                Size = UDim2.new(1,0,0,0);
                                Text = `{o.Ban and "Banned" or "Unbanned"} on {DateTime.fromIsoDate(o.StartTime):FormatLocalTime("lll", LocalizationService.RobloxLocaleId)}`;
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 18;
                                TextWrapped = true;
                                TextXAlignment = Enum.TextXAlignment.Left;
                            };
                            -- Public Reason
                            o.Ban and New "TextLabel" {
                                LayoutOrder = 3;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundTransparency = 1;
                                Font = Enum.Font.SourceSans;
                                Size = UDim2.new(1,0,0,0);
                                Text = "Public reason: " .. o.DisplayReason;
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 18;
                                TextWrapped = true;
                                TextXAlignment = Enum.TextXAlignment.Left;
                            } or nil;
                            -- Private Reason
                            o.Ban and New "TextLabel" {
                                LayoutOrder = 4;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundTransparency = 1;
                                Font = Enum.Font.SourceSans;
                                Size = UDim2.new(1,0,0,0);
                                Text = "Private reason: " .. o.PrivateReason;
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 18;
                                TextWrapped = true;
                                TextXAlignment = Enum.TextXAlignment.Left;
                            } or nil;
                            -- Places
                            o.Ban and New "TextLabel" {
                                LayoutOrder = 5;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundTransparency = 1;
                                Font = Enum.Font.SourceSans;
                                Size = UDim2.new(1,0,0,0);
                                Text = "Places: " .. (o.PlaceId == -1 and "All places" or tostring(o.PlaceId));
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 18;
                                TextWrapped = true;
                                TextXAlignment = Enum.TextXAlignment.Left;
                            } or nil;
                        }
                    }
                end,Fusion.cleanup);
                New "TextLabel" {
                    LayoutOrder = #Data.Page + 1;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(1,0,0,0);
                    Text = Data.PageFinished and "End" or "Page 1";
                    TextTransparency = 0.5;
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 18;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                }
            }
        } or nil;
        -- Notes
        New "Frame" {
            LayoutOrder = 6;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = Api.Style.BackgroundSubColor;
            Size = UDim2.new(1,0,0,0);
            [Children] = {
                -- Title Bar
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSansBold;
                    Position = UDim2.new(0,3,0,0);
                    Size = UDim2.new(1,-26,0,20);
                    Text = "Moderation Notes";
                    TextSize = 20;
                    TextColor3 = Api.Style.TextColor;
                    TextXAlignment = Enum.TextXAlignment.Left;
                };
                -- Edit
                New "ImageButton" {
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://11326670192";
                    Position = UDim2.new(1,-20,0,0);
                    Size = UDim2.new(0,20,0,20);
                    Visible = Computed(function()
                        return not NotesEditing:get();
                    end);
                    [Event "MouseButton1Up"] = function()
                        NotesEditing:set(true);
                    end;
                };
                -- Display Text
                New "TextBox" {
                    BackgroundTransparency = 1;
                    ClearTextOnFocus = false;
                    Font = Enum.Font.SourceSans;
                    Selectable = false;
                    Size = UDim2.new(1,0,0,0);
                    Position = UDim2.new(0,0,0,21);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    Text = Computed(function()
                        return Markdown.ToRichText(NotesValue:get());
                    end);
                    RichText = true;
                    TextColor3 = Api.Style.TextColor;
                    TextEditable = false;
                    TextSize = 18;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    Visible = Computed(function()
                        return not NotesEditing:get();
                    end);
                };
                -- Edit Button
                New "TextButton" {
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    Font = Enum.Font.SourceSansBold;
                    Position = UDim2.new(1,-55,0,1);
                    Size = UDim2.new(0,50,0,19);
                    Text = "Save";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 19;
                    Visible = NotesEditing;
                    ZIndex = 2;
                    [Children] = New "UICorner" {CornerRadius = UDim.new(0,5)};
                    [Event "MouseButton1Up"] = function()
                        -- Save
                        local Text: string = EditBoxRef:get().Text;
                        local Saved = Api:Invoke("Profile-EditNote",Data.UserId,Text);
                        if Saved then
                            NotesValue:set(Text);
                        else
                            EditBoxRef:get().Text = NotesValue:get();
                        end
                        NotesEditing:set(false);
                    end
                };
                -- Edit Text
                New "TextBox" {
                    BackgroundTransparency = 1;
                    ClearTextOnFocus = false;
                    Font = Enum.Font.SourceSans;
                    Selectable = false;
                    Size = UDim2.new(1,0,0,30);
                    Position = UDim2.new(0,0,0,21);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    Text = NotesValue;
                    TextColor3 = Api.Style.TextColor;
                    TextEditable = true;
                    TextSize = 18;
                    TextWrapped = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    Visible = NotesEditing;
                    [Fusion.Ref] = EditBoxRef;
                };

            }
        };

        -- Buttons
        New "Frame" {
            LayoutOrder = 7;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,0,0);
            [Children] = {
                New "UIListLayout" {
                    FillDirection = Enum.FillDirection.Horizontal;
                    Padding = UDim.new(0,3);
                    Wraps = true;
                };
                -- Ban
                New "TextButton" {
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(0,100,0,25);
                    Text = Data.Banned == 1 and "Unban" or "Ban";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;
                    [Event "MouseButton1Up"] = function()
                        if Data.Banned then
                            Api:Fire("CmdBar","!unban " .. Data.Name);
                        else
                            Api:Fire("CmdBar","!ban " .. Data.Name);
                        end
                    end;
                };
                -- Find
                New "TextButton" {
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(0,100,0,25);
                    Text = "Find";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;
                    [Event "MouseButton1Up"] = function()
                        Api:Fire("CmdBar","!find " .. Data.Name);
                    end;
                };
                -- Kick
                Plr and New "TextButton" {
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(0,100,0,25);
                    Text = "Kick";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;
                    [Event "MouseButton1Up"] = function()
                        Api:Fire("CmdBar","!kick " .. Data.Name);
                    end;
                } or nil;
                -- Goto
                Plr and New "TextButton" {
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    Font = Enum.Font.SourceSans;
                    Size = UDim2.new(0,100,0,25);
                    Text = "Goto";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;
                    [Event "MouseButton1Up"] = function()
                        Api:Fire("CmdBar","!goto " .. Data.Name);
                    end;
                } or nil;
            }
        }
    };
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

