-- Admin Cube - Client Api

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local Background, SetBackground = Roact.createBinding(Color3.new(0,0,0));
local BackgroundSubColor, SetBackgroundSubColor = Roact.createBinding(Color3.new(0,0,0));
local BackgroundSubSubColor, SetBackgroundSubSubColor = Roact.createBinding(Color3.new(0,0,0));
local ButtonColor, SetButtonColor = Roact.createBinding(Color3.new(1,1,1));
local TextColor, SetTextColor = Roact.createBinding(Color3.new(1,1,1));
local ButtonTransparency, SetButtonTransparency = Roact.createBinding(0.85);
local ButtonSubColor, SetButtonSubColor = Roact.createBinding(Color3.fromRGB(200,200,200))

local ThemeUpdateEvents = {}

local Api = {
    Settings = {
        CurrentTheme = "Dark"
    };
    Style = {
        Background = Background;
        ButtonColor = ButtonColor;
        BackgroundSubSubColor = BackgroundSubSubColor;
        TextColor = TextColor;
        ButtonTransparency = ButtonTransparency;
        ButtonSubColor = ButtonSubColor;
        BackgroundSubColor = BackgroundSubColor;
    }
}

local Themes = {}
local CurrentTheme = 0
for i,o in pairs(script:GetChildren()) do
    if string.sub(o.Name,1,11) == "Stylesheet." then
        Themes[i] = string.sub(o.Name,12)
        if string.sub(o.Name,12) == Api.Settings.CurrentTheme then
            CurrentTheme = i
        end
    end
end

local function UpdateTheme()
    local Style = require(script:FindFirstChild("Stylesheet." .. Api.Settings.CurrentTheme))
    if Style then
        SetBackground(Style.Background)
        SetButtonColor(Style.ButtonColor)
        SetTextColor(Style.TextColor)
        SetButtonTransparency(Style.ButtonTransparency)
        SetButtonSubColor(Style.ButtonSubColor)
        SetBackgroundSubColor(Style.BackgroundSubColor)
        SetBackgroundSubSubColor(Style.BackgroundSubSubColor)

        for i = 1,#ThemeUpdateEvents,1 do
            ThemeUpdateEvents[i]()
        end
    end
end

function Api:UpdateTheme(Theme)
    if Theme then
        Api.Settings.CurrentTheme = Theme
        UpdateTheme()
    else
        CurrentTheme = CurrentTheme + 1
        if CurrentTheme > #Themes then
            CurrentTheme = 1
        end

        Api.Settings.CurrentTheme = Themes[CurrentTheme]

        UpdateTheme()
    end
end

function Api:PushRemote(Key,Args)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireServer(Key,Args)
end

function Api:ListenRemote(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent.OnClientEvent:Connect(function(CallingKey,Args)
        if CallingKey == Key and typeof(Callback) == "function" then
            Callback(Args)
        end
    end)
end

function Api:PushFunction(Key,Args)
    return game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc:InvokeServer(Key,Args)
end

function Api:ListenFunction(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc.OnClientInvoke = function(CallingKey,Args)
        if CallingKey == Key then
            Callback(Args)
        end
    end
end

function Api:ThemeUpdateEvent(Func)
    ThemeUpdateEvents[#ThemeUpdateEvents+1] = Func
end

function Api:GetCommands()
    local Cmds = Api:PushFunction("GetCommands")
    print("GET CMDS")
    print(Cmds)
    return Cmds
end

function Api:CreateWindow(Props,Component)
    local WindowModule = require(script.Window)
    local WindowComp,Functions = WindowModule:CreateWindow()
    local WindowFrame = Roact.createElement(WindowComp,{
        Btns = Props.Buttons;
        SizeX = Props.SizeX;
        SizeY = Props.SizeY;
        Main = Component;
        Title = Props.Title;
        Style = Api.Style;
    })
    local Tree = Roact.mount(WindowFrame,game.Players.LocalPlayer.PlayerGui:FindFirstChild("__AdminCube_Main"),"Window-" .. Props.Title)
    local ReturnTab = {
        OnClose = {}
    }

    local Close = {}
    function ReturnTab.unmount()
        Roact.unmount(Tree)

        Close = nil
    end

    function ReturnTab.OnClose:Connect(f)
        if typeof(f) == "function" then
            Close[#Close+1] = f
        end
        
    end

    Functions.OnClose = function()
        for _,f in pairs(Close) do
            f()
        end
    end
    
    ReturnTab.SetVis = Functions.SetVis

    return ReturnTab
end

-- Prompts
local PromptBoolean,PromptString,PromptDropdown = require(script.Prompts)
Api:ListenRemote("Prompts",function(Prompts)
    -- Generate Uis
    local Window
    local CurrentValues = {}
    local Y = 2
    local ButtonFragments = {}
    for i,o in pairs(Prompts.Prompts) do
        if o.Type == "Boolean" then
            local Button = Roact.createElement(PromptBoolean,{
                Style = Api.Style;
                Y = Y;
                Title = o.Title;
                DefaultValue = o.DefaultValue;
                UpdateValue = function(NewValue)
                    CurrentValues[i] = NewValue
                end
            })
            CurrentValues[i] = o.DefaultValue
            ButtonFragments[i] = Button

        elseif o.Type == "String" then
            local Button = Roact.createElement(PromptString,{
                Style = Api.Style;
                Y = Y;
                Title = o.Title;
                DefaultValue = o.DefaultValue;
                UpdateValue = function(NewValue)
                    CurrentValues[i] = NewValue
                end
            })
            CurrentValues[i] = ""
            ButtonFragments[i] = Button

        elseif o.Type == "Dropdown" then
            local Button = Roact.createElement(PromptDropdown,{
                Style = Api.Style;
                Y = Y;
                Title = o.Title;
                Value = o.Value;
                DefaultValue = o.DefaultValue;
                UpdateValue = function(NewValue)
                    CurrentValues[i] = NewValue
                end
            })
            CurrentValues[i] = ""
            ButtonFragments[i] = Button
        end
        Y += 25
    end
    local Buttons = Roact.createFragment(ButtonFragments)

    local PromptComp = Roact.Component:extend("PromptComp")
    function PromptComp:render()
        return Roact.createElement("ScrollingFrame",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,1,0);
            BottomImage = "";
            CanvasSize = UDim2.new(0,0,0,Y+50);
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
            ScrollBarImageColor3 = Api.Style.ButtonColor;
            ScrollBarThickness = 5;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            TopImage = "";
        },{
            Title = Roact.createElement("TextLabel",{
                BackgroundColor3 = Api.Style.ButtonColor;
                BackgroundTransparency = 0.9;
                BorderSizePixel = 0;
                Size = UDim2.new(1,0,0,25);
                Font = Enum.Font.SourceSans;
                Text = Prompts.Title;
                TextColor3 = Api.Style.TextColor;
                TextSize = 25;
                LayoutOrder = 1;
            });
            Buttons = Roact.createElement(Buttons);
            Frame = Roact.createElement("Frame",{
                BackgroundTransparency = 1;
                Position = UDim2.new(0,0,0,Y+25);
                Size = UDim2.new(1,0,0,25);
            },{
                Confirm = Roact.createElement("TextButton",{
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    BorderSizePixel = 0;
                    Size = UDim2.new(0.5,-1,1,0);
                    Font = Enum.Font.SourceSans;
                    Text = "Confirm";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;

                    [Roact.Event.MouseButton1Up] = function()
                        Api:PushRemote("Prompts",{true,CurrentValues})
                        Window.unmount()
                    end;
                });
                Cancel = Roact.createElement("TextButton",{
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    BorderSizePixel = 0;
                    Size = UDim2.new(0.5,-1,1,0);
                    Position = UDim2.new(0.5,1,0,0);
                    Font = Enum.Font.SourceSans;
                    Text = "Cancel";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;

                    [Roact.Event.MouseButton1Up] = function()
                        Api:PushRemote("Prompts",{false})
                        Window.unmount()
                    end;
                })
            })
        })
    end

    Window = Api:CreateWindow({
        SizeX = 250;
        SizeY = Y+50;
        Title = "Prompt";
    })
end)

return Api
