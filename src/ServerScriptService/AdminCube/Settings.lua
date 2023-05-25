-- Admin Cube - Merge Custom Settings with Default Settings

local DefaultSettings = require(script.Parent.DefaultSettings)
local CustomSettings = _G.AdminCubeCustomSettings

local Settings = {}

if typeof(CustomSettings) == "table" then
    -- Custom Settings are Provided, Compile Settings (Fill in any Missing ones)
    for o,i in pairs(DefaultSettings) do
        if o == "Client" then
            if typeof(CustomSettings.Client) == "table" then
                Settings.Client = {}
                for ind,v in pairs(DefaultSettings.Client) do
                    if CustomSettings.Client[ind] then
                        Settings.Client[ind] = CustomSettings.Client[ind]
                    else
                        Settings.Client[ind] = v
                    end
                end
            else
                Settings.Client = DefaultSettings.Client
            end
        else
            if CustomSettings[o] then
                Settings[o] = CustomSettings[o]
            else
                Settings[o] = i
            end
        end
    end
else
    -- No Custom Settings, Use Default Settings
    Settings = DefaultSettings
end

return Settings
