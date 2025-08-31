-- Admin Cube

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Computed = Fusion.Computed
local Children = Fusion.Children

local RedColor = "#ff0000"
local YellowColor = "#ffaa00"
local GreenColor = "#00aa00"

local Tab = Value("");
local Format = {
    Fps = "Fps: %s%d%s";
    Mem = "Mem: %s%d%sMB";
    Ping = "Ping: %s%d%sms";
    Send = "Send: %s%.2f%sKB/s";
    Recv = "Recv: %s%.2f%sKB/s";
    Phy = "Physics%s%s%s";
    -- Physics
    CPU = "Heartbeat: %.2fms";
    GPU = "PhysicsStep: %.2fms";
    PhySend = "PhySend: %.2fKB/s";
    PhyRecv = "PhyRecv: %.2fKB/s";

    Cont = "Contacts: %d";
    Inst = "Instances: %d";
    Move = "Moving Parts: %d";
    Prim = "Parts: %d";
}
local Text = {
    Fps = Value(0);
    Mem = Value(0);
    Ping = Value(0);
    Send = Value(0);
    Recv = Value(0);
    Phy = Value("");
    -- Physics
    CPU = Value(0);
    GPU = Value(0);
    PhySend = Value(0);
    PhyRecv = Value(0);

    Cont = Value(0);
    Inst = Value(0);
    Move = Value(0);
    Prim = Value(0);
}
local Averages = {}
local Targets = {
    Fps = 60;
    Mem = 800;
    Ping = 100;
    Send = 50;
    Recv = 50;
}

for i,_ in pairs(Targets) do
    Averages[i] = table.create(25,0);
end
local AvgVal = Value(Averages)

function CheckTarget(Mark: string, Val: number): number -- 0: Normal, 1: Yellow, 2: red
    if Targets[Mark] then
        if Mark == "Fps" then
            if Val >= Targets[Mark] then
                return 0
            elseif Val >= Targets[Mark] * 2 / 3 then
                return 1
            else
                return 2
            end
        else
            if Val <= Targets[Mark] then
                return 0
            elseif Val <= Targets[Mark] * 1.333 then
                return 1
            else
                return 2
            end
        end
    end
    return 0
end

function GetText(Mark: string, Txt: string): string
    -- Check Colors
    local Color1 = ""
    local Color2 = ""
    local Col = CheckTarget(Mark,Txt)
    if Col == 1 then
        Color1 = "<font color=\"" .. YellowColor .. "\">"
        Color2 = "</font>"
    elseif Col == 2 then
        Color1 = "<font color=\"" .. RedColor .. "\">"
        Color2 = "</font>"
    end

    return string.format(Format[Mark],Color1,Txt,Color2);
end

function MainButton(Mark: string, Position: UDim2): GuiObject
    return New "TextButton" {
        BackgroundTransparency = 1;
        Size = UDim2.new(0,125,0,25);
        TextColor3 = Api.Style.TextColor;
        TextSize = 12;
        FontFace = Api.Style.Font;
        Position = Position;
        RichText = true;
        Text = Computed(function()
            return GetText(Mark,Text[Mark]:get());
        end);
        [Event "MouseButton1Up"] = function()
            if Tab:get() == Mark then
                Tab:set("")
            else
                Tab:set(Mark)
            end
        end;
        [Children] = New "Frame" {
            AnchorPoint = Vector2.new(0,1);
            BackgroundColor3 = Color3.fromRGB(0,170,255);
            Position = UDim2.new(0,0,1,0);
            Size = UDim2.new(1,0,0,3);
            Visible = Computed(function()
                return Tab:get() == Mark;
            end)
        }
    }
end
function PhyText(Mark: string, Position: UDim2): GuiObject
    return New "TextLabel" {
        BackgroundTransparency = 1;
        Size = UDim2.new(0.5,0,0,25);
        TextColor3 = Api.Style.TextColor;
        TextSize = 12;
        FontFace = Api.Style.Font;
        Position = Position;
        RichText = true;
        Text = Computed(function()
            return string.format(Format[Mark],Text[Mark]:get());
        end);
    }
end

function GetMax(Mark:string, t: table): number
    local m = t[1]
    for _,o in pairs(t) do
        if o > m then
            m = o
        end
    end
    return math.max(m, Targets[Mark]);
end

local WindowFrame = New "Frame" {
    BackgroundTransparency = 1;
    Size = UDim2.new(1,0,1,0);
    [Children] = {
        MainButton("Fps",UDim2.fromOffset(0,0));
        MainButton("Mem",UDim2.fromOffset(125,0));
        MainButton("Ping",UDim2.fromOffset(250,0));
        MainButton("Send",UDim2.fromOffset(0,25));
        MainButton("Recv",UDim2.fromOffset(125,25));
        MainButton("Phy",UDim2.fromOffset(250,25));

        -- Physics Tab
        New "Frame" {
            Position = UDim2.new(0,0,1,1);
            Size = UDim2.new(1,0,0,100);
            BackgroundColor3 = Api.Style.Background;
            Visible = Computed(function()
                return Tab:get() == "Phy";
            end);
            [Children] = {
                PhyText("CPU",UDim2.new(0,0,0,0));
                PhyText("GPU",UDim2.new(0.5,0,0,0));
                PhyText("PhySend",UDim2.new(0,0,0,25));
                PhyText("PhyRecv",UDim2.new(0.5,0,0,25));

                PhyText("Cont",UDim2.new(0,0,0,50));
                PhyText("Inst",UDim2.new(0.5,0,0,50));
                PhyText("Move",UDim2.new(0,0,0,75));
                PhyText("Prim",UDim2.new(0.5,0,0,75));
            }
        };
        -- Tab
        New "Frame" {
            Position = UDim2.new(0,0,1,1);
            Size = UDim2.new(1,0,0,75);
            BackgroundColor3 = Api.Style.Background;
            Visible = Computed(function()
                return Tab:get() ~= "" and Tab:get() ~= "Phy";
            end);
            [Children] = {
                -- Title
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0,125,0,25);
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 12;
                    RichText = true;
                    FontFace = Api.Style.FontBold;
                    Text = Computed(function()
                        local txt = Format[Tab:get()]
                        if typeof(txt) == "string" then
                            return string.split(txt,":")[1]
                        end
                        return "";
                    end);
                };
                -- Target
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0,125,0,25);
                    Position = UDim2.new(0,0,0,25);
                    TextColor3 = Api.Style.TextColor;
                    TextScaled = true;
                    FontFace = Api.Style.Font;
                    Text = Computed(function()
                        local txt = Targets[Tab:get()]
                        if typeof(txt) == "number" then
                            local formatTxt = GetText(Tab:get(),txt)
                            return "Target:" .. string.sub(formatTxt, string.find(formatTxt," ") or 0)
                        end
                        return "Target";
                    end);
                    [Children] = New "UITextSizeConstraint" {MaxTextSize = 12};
                };
                -- Avg
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Size = UDim2.new(0,125,0,25);
                    Position = UDim2.new(0,0,0,50);
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 12;
                    RichText = true;
                    FontFace = Api.Style.Font;
                    Text = Computed(function()
                        local Avgs = AvgVal:get()
                        local TabTxt = Tab:get()
                        if Avgs[TabTxt] then
                            local Avg = 0
                            for _,o in pairs(Avgs[TabTxt]) do
                                Avg += o
                            end
                            Avg /= #Avgs[TabTxt];
                            local formatTxt = GetText(Tab:get(),Avg)
                            return "Avg:" .. string.sub(formatTxt, string.find(formatTxt," ") or 0 )
                        end
                        return "Avg"
                    end);
                };
                -- Graph
                New "Frame" {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0,125,0,0);
                    Size = Computed(function()
                        local txt = "0"
                        local Avgs = AvgVal:get()
                        local TabTxt = Tab:get()
                        if Avgs[TabTxt] then
                            txt = tostring(math.floor(GetMax(TabTxt,Avgs[TabTxt])))
                        end
                        local Size = TextService:GetTextSize(txt,8,Enum.Font.Legacy,Vector2.new(math.huge,math.huge));
                        return UDim2.new(0,246 - Size.X,0,75);
                    end);
                    [Children] = {
                        -- Max
                        New "TextLabel" {
                            BackgroundTransparency = 1;
                            Position = UDim2.new(1,2,0,1);
                            Size = UDim2.new(0,125,1,-1);
                            Text = Computed(function()
                                local Avgs = AvgVal:get()
                                local TabTxt = Tab:get()
                                if Avgs[TabTxt] then
                                    return tostring(math.floor(GetMax(TabTxt,Avgs[TabTxt])))
                                end
                                return "0"
                            end);
                            TextColor3 = Api.Style.TextColor;
                            TextSize = 8;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            TextYAlignment = Enum.TextYAlignment.Top;
                            FontFace = Api.Style.Font;
                        };
                        -- Min
                        New "TextLabel" {
                            BackgroundTransparency = 1;
                            Position = UDim2.new(1,2,0,1);
                            Size = UDim2.new(0,125,1,-1);
                            Text = "0";
                            TextColor3 = Api.Style.TextColor;
                            TextSize = 8;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            TextYAlignment = Enum.TextYAlignment.Bottom;
                            FontFace = Api.Style.Font;
                        };
                        New "Frame" {
                            Size = UDim2.new(1,0,1,0);
                            BackgroundTransparency = 1;
                            ClipsDescendants = true;
                            [Children] = {
                                -- Avg
                                New "Frame" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundColor3 = Api.Style.TextColor;
                                    Position = Computed(function()
                                        local Avgs = AvgVal:get()
                                        local TabTxt = Tab:get()
                                        local Max = 0
                                        if Avgs[TabTxt] then
                                            Max = math.floor(GetMax(TabTxt,Avgs[TabTxt]))
                                            local Avg = 0
                                            for _,o in pairs(Avgs[TabTxt]) do
                                                Avg += o
                                            end
                                            Avg /= #Avgs[TabTxt];
                                            return UDim2.new(0,0,1 - (Avg / Max),0);
                                        end
                                        return UDim2.new(0,0,0,0);
                                    end);
                                    Size = UDim2.new(1,0,0,3);
                                    ZIndex = 3;
                                };
                                -- Target Line
                                New "Frame" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundColor3 = Color3.new(0.5,0.5,0.5);
                                    Position = Computed(function()
                                        local Avgs = AvgVal:get()
                                        local TabTxt = Tab:get()
                                        local Max = 0
                                        if Avgs[TabTxt] then
                                            Max = math.floor(GetMax(TabTxt,Avgs[TabTxt]))
                                            
                                            return UDim2.new(0,0,1 - (Targets[TabTxt] / Max),0);
                                        end
                                        return UDim2.new(0,0,0,0);
                                    end);
                                    Size = UDim2.new(1,0,0,2);
                                    ZIndex = 2;
                                };
                                -- Bars
                                Fusion.ForPairs(Computed(function()
                                    local Avgs = AvgVal:get()
                                    local TabTxt = Tab:get()
                                    local Max = 0
                                    if Avgs[TabTxt] then
                                        return Avgs[TabTxt]
                                    end
                                    return {};
                                end),function(i,o)
                                    local TabTxt = Tab:get()
                                    local Max = 0
                                    if Averages[TabTxt] then
                                        Max = math.floor(GetMax(TabTxt,Averages[TabTxt]))
                                    end
                                    local ColVal = CheckTarget(Tab:get(),o);
                                    local Color = Color3.fromHex(GreenColor);
                                    if ColVal == 1 then
                                        Color = Color3.fromHex(YellowColor);
                                    elseif ColVal == 2 then
                                        Color = Color3.fromHex(RedColor);
                                    end
                                    return i, New "Frame" {
                                        BackgroundColor3 = Color;
                                        AnchorPoint = Vector2.new(1,1);
                                        Size = UDim2.new(1/25,0,(o / Max),0);
                                        Position = UDim2.new(1 - ((i-1) / 25),0,1,0);
                                    }
                                end,Fusion.cleanup);
                            }
                        }
                    }
                }
            }
        };
    }
};

local Window = Api:CreateWindow({
    Size = Vector2.new(375,50);
    Title = "Stats";
    Position = UDim2.new(0.5,-187,0,-32);
},WindowFrame)
Window.SetVis(true)

-- Stats
local Fps = 0
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
    Fps = math.floor(CurrentFPS)
end

Start = tick()
local HBCon = Heartbeat:Connect(HeartbeatUpdate)

local Updating = true

Window.OnClose:Connect(function()
    Updating = false
    HBCon:Disconnect()
    Window.unmount()
    script:Destroy()
end)

function UpdateAvgs()
    for i,o: table in pairs(Averages) do
        for j = #o,2,-1 do
            o[j] = o[j-1];
        end
        o[1] = Text[i]:get()
    end
    AvgVal:set(Averages);
end

while Updating do
    Text.Fps:set(Fps);
    Text.Mem:set(math.floor(Stats:GetTotalMemoryUsageMb()));
    Text.Ping:set(math.floor(game.Players.LocalPlayer:GetNetworkPing()*1000))

    Text.Send:set(Stats.DataSendKbps);
    Text.Recv:set(Stats.DataReceiveKbps);

    -- Physics
    if Tab:get() == "Phy" then
        Text.PhySend:set(Stats.PhysicsSendKbps);
        Text.PhyRecv:set(Stats.PhysicsReceiveKbps);
        Text.CPU:set(Stats.HeartbeatTimeMs);
        Text.GPU:set(Stats.PhysicsStepTimeMs);

        Text.Cont:set(Stats.ContactsCount);
        Text.Inst:set(Stats.InstanceCount);
        Text.Move:set(Stats.MovingPrimitivesCount);
        Text.Prim:set(Stats.PrimitivesCount);
    end

    UpdateAvgs();

    task.wait(1)
end
