-- Admin Cube

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)
local RunService = game:GetService("RunService")

local New = Fusion.New
local Value = Fusion.Value
local Computed = Fusion.Computed

local Text = Value(1000)

local WindowFrame = New "TextLabel" {
    Visible = true;
    Position = UDim2.new(0,0,0,0);
    BorderSizePixel = 0;
    BackgroundTransparency = 1;
    Size = UDim2.new(1,0,1,0);
    TextColor3 = Api.Style.TextColor;
    Text = Computed(function()
        return "Fps: " .. tostring(Text:get())
    end);
    TextSize = 22;
    FontFace = Api.Style.Font;
};

local Window = Api:CreateWindow({
    Size = Vector2.new(100,25);
    Title = "Fps";
    Position = UDim2.new(0.5,-50,0,0);
},WindowFrame)
Window.SetVis(true)

Window.OnClose:Connect(function()
    Window.unmount()
    script:Destroy()
end)

local Heartbeat = RunService.Heartbeat

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
    Text:set(CurrentFPS)
end

Start = tick()
Heartbeat:Connect(HeartbeatUpdate)
