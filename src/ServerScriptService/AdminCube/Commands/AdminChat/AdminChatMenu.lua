-- Admin Cube - Admin Chat Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn")
local Menu = Roact.Component:extend("SettingsMenu")

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Visible, SetVisiblility = Roact.createBinding(false)
local ChatText, SetChatText = Roact.createBinding("")
local InputText, SetInputText = Roact.createBinding("")
InputRef = Roact.createRef()
ChatRef = Roact.createRef()

local NotiVis, SetNotiVis = Roact.createBinding(false)
local NotiText, SetNotiText = Roact.createBinding("0")

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "AdminChat";
        Text = "Admin Chat";
        LayoutOrder = 3;
        Visible = self.props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        [Roact.Event.MouseButton1Up] = function()
            SetVisiblility(true)
            self.props.SetVis(false)
            -- Hide Notification
            SetNotiVis(false)
            SetNotiText("0")
        end
    },{
        TextLabel = Roact.createElement("TextLabel",{
            BackgroundColor3 = Color3.fromRGB(210, 0, 0);
            Size = UDim2.new(0,20,0,20);
            Position = UDim2.new(1,5,0,-5);
            AnchorPoint = Vector2.new(1,0);
            TextColor3 = Api.Style.TextColor;
            BorderSizePixel = 0;
            Text = NotiText;
            Visible  = NotiVis;
        },{
            UiCorner = Roact.createElement("UICorner",{
                CornerRadius = UDim.new(1,0)
            })
        });
    })
end

function BackCallBack()
    SetVisiblility(false)
end

local function Slice(Num)
    Num = Num * 255
    local Str = tostring(Num)
    local Sli = string.split(Str,".")
    return Sli[1]
end

local function ReloadText()
    local Msgs = Api:Invoke("AdminChat-Get")
    local LastText = " "
    for i = 1,#Msgs,1 do
        local NewText = LastText .. '<font color="rgb(' .. Slice(Api.Style.ButtonSubColor:getValue().R)  .. ',' .. Slice(Api.Style.ButtonSubColor:getValue().B ) .. ',' .. Slice(Api.Style.ButtonSubColor:getValue().B ) .. ')"> &lt;' .. Msgs[i].Name .. '&gt; </font><font color="rgb(' .. Slice(Api.Style.TextColor:getValue().R )  .. ',' .. Slice(Api.Style.TextColor:getValue().G ) .. ',' .. Slice(Api.Style.TextColor:getValue().B ) .. ')">' .. Msgs[i].Msg .. '</font>\n'
        SetChatText(NewText)


        if ChatRef.current.TextFits then
            LastText = NewText
        end
    end
    SetChatText(LastText)
end

Api:OnEvent("AdminChat-Update",function()
    ReloadText()

    -- Add Notification
    if Visible:getValue() == false then
        -- Add
        SetNotiVis(true)
        SetNotiText(tostring(tonumber(NotiText:getValue()) + 1))

        script.Parent.Parent.NotificationEvent:Fire()
    end
end)

function Menu:render()
    return Roact.createElement("Frame",{
        Name = "AdminChat";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        ZIndex = 5;
    },{
        TextLabel = Roact.createElement("TextLabel",{
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

            [Roact.Ref] = ChatRef;
        });
        InputBox = Roact.createElement("TextBox",{
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

            [Roact.Ref] = InputRef;
            [Roact.Event.FocusLost] = function(_,Enter)
                if Enter then
                    -- Send
                    Api:Fire("AdminChat-Send",InputRef.current.Text)
                    SetInputText("")
                end
            end
        })
    })
end

return {MenuBtn,Menu,BackCallBack}

