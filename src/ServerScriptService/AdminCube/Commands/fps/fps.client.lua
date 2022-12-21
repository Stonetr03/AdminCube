-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local RunService = game:GetService("RunService")

local Text,SetText = Roact.createBinding(1000)

local WindowFrame = Roact.Component:extend("AdminPanelWindow")
function WindowFrame:render()
    return Roact.createElement("TextLabel",{
        Visible = true;
        Position = UDim2.new(0,0,0,0);
        BorderSizePixel = 0;
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
        TextColor3 = Api.Style.TextColor;
        Text = Text:map(function(fps)
            return "Fps: " .. tostring(fps)
        end),
        TextSize = 12;
    });
end

local Window = Api:CreateWindow({
    SizeX = 100;
    SizeY = 25;
    Title = "Fps";
    Position = UDim2.new(0.5,-50,0,0);
},WindowFrame)
Window.SetVis(true)

Window.OnClose:Connect(function()
    Window.unmount()
    script:Destroy()
end)

local Heartbeat = game:GetService("RunService").Heartbeat

local LastIteration, Start
local FrameUpdateTable = {}

local function HeartbeatUpdate()
    LastIteration = tick()
    for Index = #FrameUpdateTable, 1, -1 do
        FrameUpdateTable[Index + 1] = (FrameUpdateTable[Index] >= LastIteration - 1) and FrameUpdateTable[Index] or nil
    end

    FrameUpdateTable[1] = LastIteration
    local CurrentFPS = (tick() - Start >= 1 and #FrameUpdateTable) or (#FrameUpdateTable / (tick() - Start))
    CurrentFPS = math.floor(CurrentFPS)
    SetText(CurrentFPS)
end

Start = tick()
Heartbeat:Connect(HeartbeatUpdate)
