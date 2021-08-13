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

return Api
