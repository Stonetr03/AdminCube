-- Admin Cube - Admin Chat Menu

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local GuiService = game:GetService("GuiService")

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Visible = Value(false)
local ChatText = Value("")
local InputText = Value("")
local InputRef = Value()
local ChatRef = Value()

local NotiVis = Value(false)
local NotiText = Value("0")

function MenuBtn(props)
    return New "TextButton" {
        Name = "AdminChat";
        Text = "Admin Chat";
        LayoutOrder = 3;
        Visible = props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        TextSize = 8;
        Font = Enum.Font.Legacy;
        [Event "MouseButton1Up"] = function()
            Visible:set(true)
            props.SetVis(false)
            -- Hide Notification
            NotiVis:set(false)
            NotiText:set("0")
        end;

        [Children] = {
            TextLabel = New "TextLabel" {
                BackgroundColor3 = Color3.fromRGB(210, 0, 0);
                Size = UDim2.new(0,20,0,20);
                Position = UDim2.new(1,5,0,-5);
                AnchorPoint = Vector2.new(1,0);
                TextColor3 = Api.Style.TextColor;
                BorderSizePixel = 0;
                Text = NotiText;
                Visible  = NotiVis;
                [Children] = {
                    UiCorner = New "UICorner" {
                        CornerRadius = UDim.new(1,0)
                    }
                };
            }
        }
    }
end

function BackCallBack()
    Visible:set(false)
end

local function Slice(Num)
    Num = Num * 255
    local Str = tostring(Num)
    local Sli = string.split(Str,".")
    return Sli[1]
end

local function ReloadText()
    local Msgs = Api:Invoke("AdminChat-Get")
    local LastText = ""
    for i = 1,#Msgs,1 do
        local NewText = LastText .. '<font color="rgb(' .. Slice(Api.Style.ButtonSubColor:get().R)  .. ',' .. Slice(Api.Style.ButtonSubColor:get().B ) .. ',' .. Slice(Api.Style.ButtonSubColor:get().B ) .. ')"> &lt;' .. Msgs[i].Name .. '&gt; </font><font color="rgb(' .. Slice(Api.Style.TextColor:get().R )  .. ',' .. Slice(Api.Style.TextColor:get().G ) .. ',' .. Slice(Api.Style.TextColor:get().B ) .. ')">' .. Msgs[i].Msg .. '</font>\n'
        ChatText:set(NewText)

        LastText = NewText
    end
    ChatText:set(LastText)
end

Api:OnEvent("AdminChat-Update",function()
    ReloadText()

    -- Add Notification
    if Visible:get() == false then
        -- Add
        NotiVis:set(true)
        NotiText:set(tostring(tonumber(NotiText:get()) + 1))

        script.Parent.Parent.NotificationEvent:Fire()
    end
end)

function Menu()
    --if GuiService:IsTenFootInterface() == true then
        return New "TextLabel" {
            BackgroundColor3 = Api.Style.Background;
            Size = UDim2.new(1,0,1,0);
            TextSize = 15;
            TextWrapped = true;
            TextColor3 = Api.Style.TextColor;
            Text = "Admin Chat is disabled due to Roblox now requiring the use of TextChatService, Admin Chat will be removed in a future update.\n\nSee Roblox's devforum post for information on the update.";
            ZIndex = 10;
            Font = Enum.Font.SourceSans;
            ClipsDescendants = true;
            Visible = Visible;
        }
    --[[end
    return New "Frame" {
        Name = "AdminChat";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        ZIndex = 5;
        [Children] = {
            TextLabel = New "TextLabel"{
                BorderSizePixel = 0;
                BackgroundTransparency = 1;
                Size = UDim2.new(1,0,1,-40);
                RichText = true;
                TextSize = 15;
                TextWrapped = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                TextColor3 = Color3.new(1,1,1);
                Text = ChatText;
                ZIndex = 10;
                Font = Enum.Font.SourceSans;
                ClipsDescendants = true;

                [Fusion.Ref] = ChatRef;
            };
            InputBox = New "TextBox" {
                BackgroundTransparency = .85;
                BackgroundColor3 = Api.Style.ButtonColor;
                BorderSizePixel = 1;
                Position = UDim2.new(0, 5,1, -35);
                Size = UDim2.new(1, -10,0, 30);
                ZIndex = 10;
                PlaceholderText = "Type here to send a message";
                PlaceholderColor3 = Color3.fromRGB(178, 178, 178);
                Text = InputText;
                TextColor3 = Api.Style.TextColor;
                TextSize = 16;
                Font = Enum.Font.SourceSans;

                [Fusion.Ref] = InputRef;
                [Event "FocusLost"] = function(Enter)
                    if Enter then
                        -- Send
                        Api:Fire("AdminChat-Send",InputRef:get().Text)
                        InputRef:get().Text = ""
                    end
                end
            }
        }
    }]]
end

return {MenuBtn,Menu,BackCallBack}

