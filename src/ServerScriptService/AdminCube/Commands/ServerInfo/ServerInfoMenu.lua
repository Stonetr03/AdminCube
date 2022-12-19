-- Admin Cube - Admin Chat Menu

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local MenuBtn = Roact.Component:extend("SettingsBtn")
local Menu = Roact.Component:extend("SettingsMenu")

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local ServerStats = game.ReplicatedStorage.AdminCube:WaitForChild("ServerStats")
local RunService = game:GetService("RunService")

local Visible, SetVisiblility = Roact.createBinding(false)
local Fps, SetFps = Roact.createBinding("")
local Ping, SetPing = Roact.createBinding("")
local VisRef = Roact.createRef()

function MenuBtn:render()
    return Roact.createElement("TextButton",{
        Name = "ServerStats";
        Text = "Server Info";
        LayoutOrder = 4;
        Visible = self.props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        [Roact.Event.MouseButton1Up] = function()
            SetVisiblility(true)
            self.props.SetVis(false)
        end
    })
end

function BackCallBack()
    SetVisiblility(false)
end

local Stop

function Menu:render()
    local Last, Start = 0,0
    local Updates = {}
    
    local Next = 0
    
    Stop = RunService.Heartbeat:Connect(function()
        if VisRef:getValue().Visible == true then
            Last = tick()
            for Index = #Updates, 1, -1 do
                Updates[Index + 1] = (Updates[Index] >= Last - 1) and Updates[Index] or nil
            end
    
            Updates[1] = Last
            local CurrentFPS = (tick() - Start >= 1 and #Updates) or (#Updates / (tick() - Start))
            CurrentFPS = math.floor(CurrentFPS)
            SetFps("Fps : " .. CurrentFPS)
            
            
            if Next < tick() then
                Next = tick() + 5
                local St = tick()
                Api:Invoke("Response")
                local Re = tick()
                local Pi = tostring(math.floor((Re - St)*1000))
                SetPing("Ping : " .. Pi .. " ms")
            end
        end
    end)

    return Roact.createElement("Frame",{
        Name = "AdminChat";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        ZIndex = 5;

        [Roact.Ref] = VisRef;
    },{
        TitleTextBox1 = Roact.createElement("TextLabel",{
            Size = UDim2.new(1,0,0,20);
            Text = "- Server Info -";
            Font = Enum.Font.SourceSans;
            TextColor3 = Api.Style.TextColor;
            BackgroundTransparency = 1;
            TextSize = 25;
            ZIndex = 10;
        });
        Region = Roact.createElement("TextLabel",{
            Size = UDim2.new(1,0,0,20);
            Position = UDim2.new(0,0,0,20);
            Text = "Server Region : " .. ServerStats:WaitForChild("Region").Value .. ", " .. ServerStats:WaitForChild("Country").Value;
            Font = Enum.Font.SourceSans;
            TextColor3 = Api.Style.TextColor;
            BackgroundTransparency = 1;
            TextSize = 20;
            ZIndex = 10;
        });
        Fps = Roact.createElement("TextLabel",{
            Size = UDim2.new(1,0,0,20);
            Position = UDim2.new(0,0,0,40);
            Text = Fps;
            Font = Enum.Font.SourceSans;
            TextColor3 = Api.Style.TextColor;
            BackgroundTransparency = 1;
            TextSize = 20;
            ZIndex = 10;
        });
        Ping = Roact.createElement("TextLabel",{
            Size = UDim2.new(1,0,0,20);
            Position = UDim2.new(0,0,0,60);
            Text = Ping;
            Font = Enum.Font.SourceSans;
            TextColor3 = Api.Style.TextColor;
            BackgroundTransparency = 1;
            TextSize = 20;
            ZIndex = 10;
        });
        Version = Roact.createElement("TextLabel",{
            Size = UDim2.new(1,0,0,20);
            Position = UDim2.new(0,0,0,80);
            Text = "Admin Cube Version " .. ServerStats:WaitForChild("Version").Value;
            Font = Enum.Font.SourceSans;
            TextColor3 = Api.Style.TextColor;
            BackgroundTransparency = 1;
            TextSize = 20;
            ZIndex = 10;
        });
    })
end

Api:OnEvent("RemovePanel",function()
    Stop:Disconnect()
end)


return {MenuBtn,Menu,BackCallBack}

