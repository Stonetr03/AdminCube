-- Admin Cube - Admin Chat Menu

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local ServerStats = game.ReplicatedStorage.AdminCube:WaitForChild("ServerStats")
local RunService = game:GetService("RunService")

local Visible = Value(false)
local Fps = Value("")
local Ping = Value("")
local VisRef = Value()

function MenuBtn(props)
    return New "TextButton" {
        Name = "ServerStats";
        Text = "Server Info";
        LayoutOrder = 4;
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
        end
    }
end

function BackCallBack()
    Visible:set(false)
end

local Stop

function Menu()
    local Last, Start = 0,0
    local Updates = {}

    local Next = 0

    Stop = RunService.Heartbeat:Connect(function()
        if VisRef:get().Visible == true then
            Last = tick()
            for Index = #Updates, 1, -1 do
                Updates[Index + 1] = (Updates[Index] >= Last - 1) and Updates[Index] or nil
            end

            Updates[1] = Last
            local CurrentFPS = (tick() - Start >= 1 and #Updates) or (#Updates / (tick() - Start))
            CurrentFPS = math.floor(CurrentFPS)
            Fps:set("Fps : " .. CurrentFPS)

            if Next < tick() then
                Next = tick() + 5
                local St = tick()
                Api:Invoke("Response")
                local Re = tick()
                local Pi = tostring(math.floor((Re - St)*1000))
                Ping:set("Ping : " .. Pi .. " ms")
            end
        end
    end)

    return New "Frame" {
        Name = "ServerInfo";
        BackgroundColor3 = Api.Style.Background;
        BorderSizePixel = 0;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        ZIndex = 5;

        [Fusion.Ref] = VisRef;

        [Children] = {
            TitleTextBox1 = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Text = "- Server Info -";
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 25;
                ZIndex = 10;
            };
            Region = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,20);
                Text = "Server Region : " .. ServerStats:WaitForChild("Region").Value .. ", " .. ServerStats:WaitForChild("Country").Value;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Fps = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,40);
                Text = Fps;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Ping = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,60);
                Text = Ping;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Version = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,80);
                Text = "Admin Cube Version " .. ServerStats:WaitForChild("Version").Value;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
        }
    }
end

Api:OnEvent("RemovePanel",function()
    Stop:Disconnect()
end)


return {MenuBtn,Menu,BackCallBack}

