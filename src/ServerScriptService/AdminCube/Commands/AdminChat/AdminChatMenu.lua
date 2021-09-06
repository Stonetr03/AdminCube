-- Admin Cube - Admin Chat Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn")
local Menu = Roact.Component:extend("SettingsMenu")

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Visible, SetVisiblility = Roact.createBinding(false)
local ChatText, SetChatText = Roact.createBinding("a\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\n")
local InputText, SetInputText = Roact.createBinding("")
InputRef = Roact.createRef()
ChatRef = Roact.createRef()

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "AdminChat";
        Text = "Admin Chat";
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        [Roact.Event.MouseButton1Up] = function()
            SetVisiblility(true)
        end
    })
end

function BackCallBack()
    SetVisiblility(false)
end

local function ReloadText()
    local Msgs = Api:PushFunction("AdminChat-Get")
    local LastText = " "
    for i = 1,#Msgs,1 do
        local NewText = LastText .. '<font color="rgb(200,200,200)"> &lt;' .. Msgs[i].Name .. '&gt; </font><font color="rgb(255,255,255)">' .. Msgs[i].Msg .. '</font>\n'
        SetChatText(NewText)

        print("Text Fits :")
        print(ChatRef.current.TextFits)

        if ChatRef.current.TextFits then
            LastText = NewText
        end
    end
    SetChatText(LastText)
end

Api:ListenRemote("AdminChat-Update",function()
    ReloadText()
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
                    print("SEND")
                    Api:PushRemote("AdminChat-Send",InputRef.current.Text)
                    SetInputText("")
                end
            end
        })
    })
end

return {MenuBtn,Menu,BackCallBack}
