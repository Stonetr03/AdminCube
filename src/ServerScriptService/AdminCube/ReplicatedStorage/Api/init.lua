-- Admin Cube - Client Api

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local Background, SetBackground = Roact.createBinding(Color3.new(0,0,0));
local ButtonColor, SetButtonColor = Roact.createBinding(Color3.new(1,1,1));
local TextColor, SetTextColor = Roact.createBinding(Color3.new(1,1,1));
local ButtonTransparency, SetButtonTransparency = Roact.createBinding(0.85);

local Api = {
    Settings = {
        CurrentTheme = "Dark"
    };
    Style = {
        Background = Background;
        ButtonColor = ButtonColor;
        TextColor = TextColor;
        ButtonTransparency = ButtonTransparency;
    }
}

local function UpdateTheme()
    local Style = require(script:FindFirstChild("Stylesheet." .. Api.Settings.CurrentTheme))
    if Style then
        SetBackground(Style.Background)
        SetButtonColor(Style.ButtonColor)
        SetTextColor(Style.TextColor)
        SetButtonTransparency(Style.ButtonTransparency)
    end
end

function Api:UpdateTheme(Theme)
    if Theme then
        Api.Settings.CurrentTheme = Theme
        UpdateTheme()
    else
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

return Api
