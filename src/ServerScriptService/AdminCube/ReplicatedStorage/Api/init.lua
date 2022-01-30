-- Admin Cube - Client Api

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local Background, SetBackground = Roact.createBinding(Color3.new(0,0,0));
local BackgroundSubColor, SetBackgroundSubColor = Roact.createBinding(Color3.new(0,0,0));
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
    local ReturnTab = {}

    function ReturnTab.unmount()
        Roact.unmount(Tree)
    end

    ReturnTab.SetVis = Functions.SetVis

    return ReturnTab
end

return Api
