-- Admin Cube - Server Info Menu

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

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

function FormatTime(time: number): string -- 94592
    time = math.floor(time)
    local day = math.floor(time / 86400)
    time = time % 86400
    local hrs = math.floor(time / 3600)
    time = time % 3600
    local min = math.floor(time / 60)
    local sec = time % 60
    if day > 0 then
        return string.format("%d:%.2d:%.2d:%.2d",day,hrs,min,sec)
    elseif hrs > 0 then
        return string.format("%d:%.2d:%.2d",hrs,min,sec)
    elseif min > 0 then
        return string.format("%d:%.2d",min,sec)
    else
        return tostring(sec);
    end
end

local Stop
local Running = true

function Menu()
    local Last, Start = 0,0
    local Updates = {}

    local Region = ServerStats:WaitForChild("Region").Value or ""
    local Country = ServerStats:WaitForChild("Country").Value or ""
    local StartTime = ServerStats:WaitForChild("Start").Value or 0
    local Uptime = Value("")
    local RegionText = "Server Region : unknown"
    if Region ~= "" or Country ~= "" then
        RegionText = "Server Region : " .. Region .. ", " .. Country
    end

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
        end
    end)

    task.spawn(function()
        while Running do
            task.wait(1)
            if VisRef:get().Visible == true then
                local Pi = tostring(math.floor(game.Players.LocalPlayer:GetNetworkPing()*1000))
                Ping:set("Ping : " .. Pi .. " ms")

                Uptime:set(FormatTime(os.time() - StartTime));
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
            Title = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Text = "Server Info";
                Font = Enum.Font.SourceSansBold;
                TextColor3 = Api.Style.TextColor;
                BackgroundColor3 = Api.Style.BackgroundSubSubColor;
                TextScaled = true;
                ZIndex = 10;
            };
            Region = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,20);
                Text = RegionText;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Uptime = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,40);
                Text = Computed(function()
                    return "Server Uptime : " .. Uptime:get();
                end);
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Fps = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,60);
                Text = Fps;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Ping = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,80);
                Text = Ping;
                Font = Enum.Font.SourceSans;
                TextColor3 = Api.Style.TextColor;
                BackgroundTransparency = 1;
                TextSize = 20;
                ZIndex = 10;
            };
            Version = New "TextLabel" {
                Size = UDim2.new(1,0,0,20);
                Position = UDim2.new(0,0,0,100);
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
    Running = false
end)

return {MenuBtn,Menu,BackCallBack}
