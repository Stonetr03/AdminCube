-- Admin Cube - Client Api

local Api = {
    Settings = {
        CurrentTheme = "Dark"
    }
}

function Api:GetStyle()
    local StyleSheet = script:FindFirstChild("Stylesheet." .. Api.Settings.CurrentTheme)
    if StyleSheet then
        return require(StyleSheet)
    else
        return require(script["Stylesheet.Dark"])
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
