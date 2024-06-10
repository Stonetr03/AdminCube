-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local strUi = require(script.Parent:WaitForChild("Primitive"):WaitForChild("string"))

local Value = Fusion.Value

local Module = {}

function Module.Ui(Shared: table, prop: string): GuiObject
    local obj = Shared.Selection:get(false)
    local Text = Value(if tostring(obj[prop]) == "nil" then "" else tostring(obj[prop]));
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(if tostring(obj[prop]) == "nil" then "" else tostring(obj[prop]))
    end)
    return strUi.Box(Text,function(str: string)
        pcall(function()
            obj[prop] = str;
        end)
    end,{con,Text});
end

return Module
