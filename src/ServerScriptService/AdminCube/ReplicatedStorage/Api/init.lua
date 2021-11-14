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
        if CallingKey == Key then
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

return Api
