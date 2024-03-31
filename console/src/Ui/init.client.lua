-- Admin Cube - Console Loader

local Fusion = require(script:WaitForChild("Packages"):WaitForChild("Fusion"))
local Window = require(script:WaitForChild("Window"))
local Util = require(script:WaitForChild("Util"))
local SettingsUi = require(script:WaitForChild("Settings"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local SettingsVisible = Value(false)
local CurrentSettings = Value(Util.cloneTable(require(script:WaitForChild("DefaultSettings"))))

SettingsUi.Visible = SettingsVisible
SettingsUi.CurrentSettings = CurrentSettings

local Cleanup

local Style = {
    Background = Color3.new(0,0,0);
    ButtonColor = Color3.new(1,1,1);
    BackgroundSubSubColor = Color3.fromRGB(22,22,22);
    TextColor = Color3.new(1,1,1);
    ButtonTransparency = 0.85;
    ButtonSubColor = Color3.fromRGB(200,200,200);
    BackgroundSubColor = Color3.fromRGB(49,49,49);
};

local ScreenGui = New "ScreenGui" {
    ResetOnSpawn = false;
    Name = "__AdminCube_Loader";
    DisplayOrder = 11;
    Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui");
}

local Ui,Func = Window:CreateWindow({
    Btns = {
        [1] = {
            Text = "<";
            Callback = function()
                SettingsVisible:set(false);
            end
        };
    };
    Size = Vector2.new(350,250);
    Main = New "Frame" {
        Size = UDim2.new(1,0,1,0);
        BackgroundTransparency = 1;
        [Children] = {
            New "Frame" {
                Visible = Computed(function()
                    return not SettingsVisible:get()
                end);
                Size = UDim2.new(1,0,1,0);
                BackgroundTransparency = 1;
                [Children] = {
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0,10,0,0);
                        Size = UDim2.new(1,0,0.125,0);
                        Text = "Load Admin Cube";
                        TextColor3 = Style.TextColor;
                        TextScaled = true;
                        TextXAlignment = Enum.TextXAlignment.Left
                    };
                    New "TextButton" {
                        AnchorPoint = Vector2.new(0.5,0.5);
                        BackgroundColor3 = Color3.fromRGB(26,26,26);
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0.5,0,0.4,0);
                        Size = UDim2.new(0.4,0,0.125,0);
                        Text = "Settings";
                        TextColor3 = Style.TextColor;
                        TextSize = 24;
                        [Event "MouseButton1Up"] = function()
                            SettingsVisible:set(true);
                        end;
                    };
                    New "TextButton" {
                        AnchorPoint = Vector2.new(0.5,0.5);
                        BackgroundColor3 = Color3.fromRGB(26,26,26);
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0.5,0,0.6,0);
                        Size = UDim2.new(0.4,0,0.125,0);
                        Text = "Load";
                        TextColor3 = Style.TextColor;
                        TextSize = 24;
                        [Event "MouseButton1Up"] = function()
                            Cleanup()
                            game:GetService("ReplicatedStorage"):WaitForChild("__AdminCubeConsoleEvent"):FireServer(true,CurrentSettings:get())
                        end;
                    }
                }
            };
            SettingsUi.Ui(Style);
        }
    };
    Title = "Load Admin Cube";
    Style = Style;
    Position = UDim2.new(0.5,-(350/2),0.5,-(250/2));
    Parent = ScreenGui;
    Name = "Window-Loader";
    Draggable = true;
    Resizeable = false;
    ResizeableMinimum = Vector2.new(25,25);
    HideTopbar = false;
})

Cleanup = function()
    Ui:Destroy();
    ScreenGui:Destroy();
end

Func.OnClose = function()
    -- Cleanup
    Cleanup();
    game:GetService("ReplicatedStorage"):WaitForChild("__AdminCubeConsoleEvent"):FireServer(false,{})
end
