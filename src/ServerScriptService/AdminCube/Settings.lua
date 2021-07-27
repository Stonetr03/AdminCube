-- Admin Cube - Merge Custom Settings with Default Settings

local DefaultSettings = require(script.Parent.DefaultSettings)
local CustomSettings = _G.AdminCubeCustomSettings

local Settings = {}

if typeof(CustomSettings) == "table" then
    -- Custom Settings are Provided, Compile Settings (Fill in any Missing ones)
    for o,i in pairs(DefaultSettings) do
        if CustomSettings[o] then
            Settings[o] = CustomSettings[o]
        else
            Settings[o] = i
        end
    end
else
    -- No Custom Settings, Use Default Settings
    Settings = DefaultSettings
end

return Settings
