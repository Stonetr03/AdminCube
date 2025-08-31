-- Admin Cube

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent

local Module = {}

function Module.Box(Text: any, UpdateText: (any) -> (), toClean: any): GuiObject
    local Input = Value()
    return New "TextBox" {
        BackgroundTransparency = 1;
        ClearTextOnFocus = false;
        FontFace = Api.Style.Font;
        Position = UDim2.new(0.5,5,0,0);
        Size = UDim2.new(0.5,-6,1,0);
        TextColor3 = Api.Style.TextColor;
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        Text = Text;
        [Fusion.Ref] = Input;
        [Event "FocusLost"] = function()
            pcall(function()
                UpdateText(Input:get().Text)
            end)
            Input:get().Text = Text:get()
        end;
        [Fusion.Cleanup] = {Input,toClean};
    }
end

function Module.toString(num: number): string
    if math.floor(num) == num then
        -- No Decimal
        return num
    elseif math.floor(num * 10) == num * 10 then
        -- Only 1 Decimal
        return string.format("%.1f",num)
    elseif math.floor(num * 100) == num * 100 then
        -- Only 2 Decimals
        return string.format("%.2f",num)
    end
    return string.format("%.3f",num)
end

function Module.Ui(Shared: table, prop: string): GuiObject
    local obj = Shared.Selection:get(false)
    local Text = Value(tostring(obj[prop]));
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(tostring(obj[prop]))
    end)
    return Module.Box(Text,function(str: string)
        pcall(function()
            obj[prop] = str;
        end);
    end,{con,Text});
end

return Module
