-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local strUi = require(script.Parent:WaitForChild("string"))

local Value = Fusion.Value;

local Module = {}

function Module.Ui(Shared: table, prop: string): GuiObject
    local obj = Shared.Selection:get(false)
    local Text = Value(strUi.toString(obj[prop]));
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(strUi.toString(obj[prop]))
    end)
    return strUi.Box(Text,function(str: string)
        local new = tonumber(str)
        if new then
            obj[prop] = new;
        end
    end,{con,Text});
end

return Module
