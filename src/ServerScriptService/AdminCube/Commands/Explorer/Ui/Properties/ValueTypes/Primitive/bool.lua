-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Computed = Fusion.Computed

local Module = {}

function Module.Ui(Shared: table, prop: string): GuiObject
    local obj = Shared.Selection:get(false)
    local Visible = Value(obj[prop]);
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Visible:set(obj[prop])
    end)
    return New "ImageButton" {
        BackgroundColor3 = Api.Style.BackgroundSubSubColor;
        BorderColor3 = Color3.fromRGB(34,34,34);
        BorderMode = Enum.BorderMode.Outline;
        BorderSizePixel = 1;
        Image = "rbxassetid://9207768534";
        ImageColor3 = Color3.fromRGB(53,181,255);
        Position = UDim2.new(0.5,5,0,3);
        ScaleType = Enum.ScaleType.Crop;
        Size = UDim2.new(0,14,0,14);
        SliceCenter = Rect.new(0,0,64,64);
        ImageTransparency = Computed(function()
            if Visible and Visible:get() then
                return 0
            end
            return 1
        end);
        [Event "MouseButton1Up"] = function()
            pcall(function()
                obj[prop] = not obj[prop]
            end)
        end;
        [Fusion.Cleanup] = {Visible,con}
    }
end

return Module
