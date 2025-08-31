-- Admin Cube

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)
local strUi = require(script.Parent:WaitForChild("Primitive"):WaitForChild("string"))

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children

local Module = {}

local TypesUi = {
    Vector2 = {
        to = function(x: Vector2): string
            if typeof(x) ~= "Vector2" then return "" end
            return string.format("%d, %d",strUi.toString(x.X),strUi.toString(x.Y));
        end;
        from = function(str: string): Vector2
            local x,y = string.match(str,"([^,]+),([^,]+)")
            if x and y and tonumber(x) and tonumber(y) then
                return Vector2.new(tonumber(x),tonumber(y))
            end
            x = string.match(str,"([^,]+)")
            if x and tonumber(x) then
                return Vector2.new(tonumber(x),tonumber(x));
            end
            return nil;
        end;
    };
    Vector3 = {
        to = function(x: Vector3): string
            if typeof(x) ~= "Vector3" then return "" end
            return string.format("%d, %d, %d",strUi.toString(x.X),strUi.toString(x.Y),strUi.toString(x.Z));
        end;
        from = function(str: string): Vector3
            local x,y,z = string.match(str,"([^,]+),([^,]+),([^,]+)")
            if x and y and z and tonumber(x) and tonumber(y) and tonumber(z) then
                return Vector3.new(tonumber(x),tonumber(y),tonumber(z))
            end
            x = string.match(str,"([^,]+)")
            if x and tonumber(x) then
                return Vector3.new(tonumber(x),tonumber(x),tonumber(x));
            end
            return nil;
        end;
    };
    UDim = {
        to = function(x: UDim): string
            if typeof(x) ~= "UDim" then return "" end
            return string.format("%d, %d",strUi.toString(x.Scale),strUi.toString(x.Offset));
        end;
        from = function(str: string): UDim
            local x,y = string.match(str,"([^,]+),([^,]+)")
            if x and y and tonumber(x) and tonumber(y) then
                return UDim.new(tonumber(x),tonumber(y))
            end
            x = string.match(str,"([^,]+)")
            if x and tonumber(x) then
                if tonumber(x) > 1 then
                    return UDim.new(0,tonumber(x));
                end
                return UDim.new(tonumber(x),0);
            end
            return nil;
        end;
    };
    UDim2 = {
        to = function(x: UDim2): string
            if typeof(x) ~= "UDim2" then return "" end
            return string.format("{%d, %d},{%d, %d}",strUi.toString(x.X.Scale),strUi.toString(x.X.Offset),strUi.toString(x.Y.Scale),strUi.toString(x.Y.Offset));
        end;
        from = function(str: string): UDim2
            local x1,x2,y1,y2 = string.match(str,"([^,]+),([^,]+),([^,]+),([^,]+)")
            if x1 and x2 and y1 and y2 and tonumber(x1) and tonumber(x2) and tonumber(y1) and tonumber(y2) then
                return UDim2.new(tonumber(x1),tonumber(x2),tonumber(y1),tonumber(y2));
            end
            x1,x2,y1,y2 = string.match(str,"{([^,]+),([^,]+)},{([^,]+),([^,]+)}")
            if x1 and x2 and y1 and y2 and tonumber(x1) and tonumber(x2) and tonumber(y1) and tonumber(y2) then
                return UDim2.new(tonumber(x1),tonumber(x2),tonumber(y1),tonumber(y2));
            end
            return nil;
        end;
    };
    Rect = {
        to = function(x: Rect): string
            if typeof(x) ~= "Rect" then return "" end
            return string.format("%d, %d, %d, %d",strUi.toString(x.Min.X),strUi.toString(x.Min.Y),strUi.toString(x.Max.X),strUi.toString(x.Max.Y));
        end;
        from = function(str: string): Rect
            local x1,x2,y1,y2 = string.match(str,"([^,]+),([^,]+),([^,]+),([^,]+)")
            if x1 and x2 and y1 and y2 and tonumber(x1) and tonumber(x2) and tonumber(y1) and tonumber(y2) then
                return Rect.new(x1,x2,y1,y2);
            end
            local x = string.match(str,"([^,]+)")
            if x and tostring(x) then
                return Rect.new(x,x,x,x);
            end
            return nil;
        end;
    };
    Font = {
        to = function(x: Font): string
            if typeof(x) ~= "Font" then return "" end
            return string.format("%d, %d, %d", x.Family,string.split(tostring(x.Weight),",")[3],string.split(tostring(x.Style),",")[3])
        end;
        from = function(str: string): Font
            local split = string.split(str,",")
            local Weight = Enum.FontWeight[split[2]] or Enum.FontWeight.Regular;
            local Style = Enum.FontStyle[split[3]] or Enum.FontWeight.Regular;
            return Font.new(split[1],Weight,Style)
        end;
    };
    PhysicalProperties = {
        to = function(x: PhysicalProperties): string
            if typeof(x) ~= "PhysicalProperties" then return "" end
            return string.format("%s, %s, %s, %s, %s",strUi.toString(x.Density),strUi.toString(x.Elasticity),strUi.toString(x.ElasticityWeight),strUi.toString(x.Friction),strUi.toString(x.FrictionWeight));
        end;
        from = function(str: string): PhysicalProperties
            if Enum.Material[str] then
                return PhysicalProperties.new(Enum.Material[str])
            end
            local split = string.split(str,",");
            for i,o in pairs(split) do
                split[i] = tonumber(o)
            end
            return PhysicalProperties.new(table.unpack(split));
        end;
    };
    NumberRange = {
        to = function(x: NumberRange): string
            if typeof(x) ~= "NumberRange" then return "" end
            return string.format("[%d, %d]",strUi.toString(x.Min),strUi.toString(x.Max));
        end;
        from = function(str: string): NumberRange
            local x,y = string.match(str,"([^,]+),([^,]+)")
            if x and y and tonumber(x) and tonumber(y) then
                return NumberRange.new(x,y)
            end
            x,y = string.match(str,"%[([^,]+),([^,]+)%]")
            if x and y and tonumber(x) and tonumber(y) then
                return NumberRange.new(x,y)
            end
            x = string.match(str,"([^,]+)")
            if x and tonumber(x) then
                return NumberRange.new(x);
            end
            return nil;
        end;
    };
    ColorSequence = {
        to = function(x: ColorSequence): string
            if typeof(x) ~= "ColorSequence" then return "" end
            local str = ""
            for i,o: ColorSequenceKeypoint in pairs(x.Keypoints) do
                if i ~= 1 then
                    str = str .. ", "
                end
                str = str .. string.format("%s [%s, %s,%s]",strUi.toString(o.Time), math.ceil(o.Value.R * 255), math.ceil(o.Value.G * 255), math.ceil(o.Value.B * 255));
            end
            return str
        end;
        from = function(str: string): ColorSequence
            local colorKeyPoints = {} :: {[number]: ColorSequence};
            for match in string.gmatch(str, "%[(.-)%]") do
                local t, r, g, b = string.match(match, "(%d+)%s-%[(%d+)%s-, (%d+)%s-, (%d+)%s-]")
                if t and r and g and b and tonumber(t) and tonumber(r) and tonumber(g) and tonumber(b) then
                    local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                    table.insert(colorKeyPoints, ColorSequenceKeypoint.new(tonumber(t), color))
                end
            end
            return ColorSequence.new(colorKeyPoints)
        end;
    };
    NumberSequence = {
        to = function(x: NumberSequence): string
            if typeof(x) ~= "NumberSequence" then return "" end
            local str = ""
            for i,o: NumberSequenceKeypoint in pairs(x.Keypoints) do
                if i ~= 1 then
                    str = str .. "; "
                end
                str = str .. string.format("%s, %s, %s",strUi.toString(o.Time),strUi.toString(o.Value),strUi.toString(o.Envelope));
            end
            return str
        end;
        from = function(str: string): NumberSequence
            local split = string.split(str,",")
            local points = {}
            for _,o in pairs(split) do
                local x,y,z = string.match(o,"([^,]+),([^,]+),([^,]+)")
                if x and y and z and tonumber(x) and tonumber(y) and tonumber(z) then
                    table.insert(points,NumberSequenceKeypoint.new(x,y,z))
                elseif x and y and tonumber(x) and tonumber(y) and tonumber(z) then
                    table.insert(points,NumberSequenceKeypoint.new(x,y))
                elseif x and tonumber(x) and #split == 1 then
                    table.insert(points,NumberSequenceKeypoint.new(0,x))
                    table.insert(points,NumberSequenceKeypoint.new(1,x))
                end
            end
            return NumberSequence.new(points);
        end;
    };
    CFrame = {
        to = function(x: CFrame): string
            if typeof(x) ~= "CFrame" then return "" end
            local a,b,c = x:ToEulerAnglesYXZ();
            return string.format("{%s, %s, %s}, {%s, %s, %s}",strUi.toString(x.Position.X),strUi.toString(x.Position.Y),strUi.toString(x.Position.Z),strUi.toString(math.deg(a)),strUi.toString(math.deg(b)),strUi.toString(math.deg(c)))
        end;
        from = function(str: string): CFrame
            local x,y,z,a,b,c = string.match(str,"{([^,]+),([^,]+),([^,]+)},{([^,]+),([^,]+),([^,]+)}")
            if x and y and z and a and b and c and tonumber(x) and tonumber(y) and tonumber(z) and tonumber(a) and tonumber(b) and tonumber(c) then
                return CFrame.new(Vector3.new(x,y,z),Vector3.new(a,b,c))
            end
            x,y,z = string.match(str,"{([^,]+),([^,]+),([^,]+)}")
            if x and y and z and tonumber(x) and tonumber(y) and tonumber(z) then
                return CFrame.new(Vector3.new(x,y,z))
            end
            x,y,z = string.match(str,"([^,]+),([^,]+),([^,]+)")
            if x and y and z and tonumber(x) and tonumber(y) and tonumber(z) then
                return CFrame.new(Vector3.new(x,y,z))
            end
            return nil;
        end
    };
    -- Ui
    Color3 = {
        to = function(x: Color3): string
            if typeof(x) ~= "Color3" then return "" end
            return string.format("[%d, %d, %d]",math.ceil(x.R * 255),math.ceil(x.G * 255),math.ceil(x.B * 255));
        end;
        from = function(str: string): Color3
            local r,g,b = string.match(str,"([^,]+),([^,]+),([^,]+)")
            if r and g and b and tonumber(r) and tonumber(g) and tonumber(b) then
                if tonumber(r) <= 1 and tonumber(b) <= 1 and tonumber(b) <= 1 then
                    return Color3.new(tonumber(r),tonumber(g),tonumber(b));
                end
                return Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b));
            end
            r,g,b = string.match(str,"%[([^,]+),([^,]+),([^,]+)%]")
            if r and g and b and tonumber(r) and tonumber(g) and tonumber(b) then
                if tonumber(r) <= 1 and tonumber(b) <= 1 and tonumber(b) <= 1 then
                    return Color3.new(tonumber(r),tonumber(g),tonumber(b));
                end
                return Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b));
            end
            r = string.match(str,"([^,]+)")
            if r and tonumber(r) then
                if tonumber(r) <= 1 then
                    return Color3.new(tonumber(r),tonumber(r),tonumber(r));
                end
                return Color3.fromRGB(tonumber(r),tonumber(r),tonumber(r));
            end
            return nil;
        end;
    };
    BrickColor = {
        Ui = function(Shared: table, prop: string, CatTbl: table): GuiObject
            local obj = Shared.Selection:get(false)
            local Text = Value(obj[prop].Name);
            local Color = Value(Color3.new(obj[prop].r,obj[prop].g,obj[prop].b))
            local con = obj:GetPropertyChangedSignal(prop):Connect(function()
                Text:set(obj[prop].Name)
                Color:set(Color3.new(obj[prop].r,obj[prop].g,obj[prop].b))
            end)
            local Textbox = strUi.Box(Text,function(str: string)
                local new = BrickColor.new(str)
                if new then
                    obj[prop] = new;
                end
            end,{con,Text,Color});
            Textbox.Position = UDim2.new(0.5,25,0,0);
            Textbox.Size = UDim2.new(0.5,-26,1,0);
            return {Textbox, New "Frame" {
                BackgroundColor3 = Color;
                BorderColor3 = Api.Style.BackgroundSubSubColor;
                BorderMode = Enum.BorderMode.Outline;
                BorderSizePixel = 1;
                Position = UDim2.new(0.5,5,0,3);
                Size = UDim2.new(0,14,0,14);
            }};
        end;
    };
}

TypesUi.Color3.Ui = function(Shared: table, prop: string, CatTbl: table): GuiObject
    local obj = Shared.Selection:get(false)
    local Text = Value(TypesUi.Color3.to(obj[prop]));
    local Color = Value(obj[prop])
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(TypesUi.Color3.to(obj[prop]))
        Color:set(obj[prop])
    end)
    local Textbox = strUi.Box(Text,function(str: string)
        local new = TypesUi[CatTbl.Name].from(string.gsub(str,"%s",""));
        if new then
            obj[prop] = new;
        end
    end,{con,Text,Color});
    Textbox.Position = UDim2.new(0.5,25,0,0);
    Textbox.Size = UDim2.new(0.5,-26,1,0);
    return {Textbox, New "Frame" {
        BackgroundColor3 = Color;
        BorderColor3 = Api.Style.BackgroundSubSubColor;
        BorderMode = Enum.BorderMode.Outline;
        BorderSizePixel = 1;
        Position = UDim2.new(0.5,5,0,3);
        Size = UDim2.new(0,14,0,14);
    }};
end;
TypesUi.ColorSequence.Ui = function(Shared: table, prop: string, CatTbl: table): GuiObject
    local obj = Shared.Selection:get(false)
    local Text = Value(TypesUi.ColorSequence.to(obj[prop]));
    local Color = Value(obj[prop]) :: ColorSequence
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(TypesUi.ColorSequence.to(obj[prop]))
        Color:set(obj[prop])
    end)
    local Textbox = strUi.Box(Text,function(str: string)
        local new = TypesUi.ColorSequence.from(string.gsub(str,"%s",""));
        if new then
            obj[prop] = new;
        end
    end,{con,Text,Color});
    Textbox.Position = UDim2.new(0.5,25,0,0);
    Textbox.Size = UDim2.new(0.5,-26,1,0);
    return {Textbox, New "Frame" {
        BackgroundColor3 = Color3.new(1,1,1);
        BorderColor3 = Api.Style.BackgroundSubSubColor;
        BorderMode = Enum.BorderMode.Outline;
        BorderSizePixel = 1;
        Position = UDim2.new(0.5,5,0,3);
        Size = UDim2.new(0,14,0,14);
        [Children] = {
            New "UIGradient" {
                Color = Color;
            }
        }
    }};
end;

function Module.Ui(Shared: table, prop: string, CatTbl: table): GuiObject
    if TypesUi[CatTbl.Name] then
        if TypesUi[CatTbl.Name].Ui then
            return TypesUi[CatTbl.Name].Ui(Shared,prop,CatTbl);
        else
            local obj = Shared.Selection:get(false)
            local Text = Value(TypesUi[CatTbl.Name].to(obj[prop]));
            local con = obj:GetPropertyChangedSignal(prop):Connect(function()
                Text:set(TypesUi[CatTbl.Name].to(obj[prop]))
            end)
            return strUi.Box(Text,function(str: string)
                local new = TypesUi[CatTbl.Name].from(string.gsub(str,"%s",""));
                if new then
                    pcall(function()
                        obj[prop] = new;
                    end)
                end
            end,{con,Text});
        end
    end
    local obj = Shared.Selection:get(false)
    local Text = Value(tostring(obj[prop]));
    local con = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(tostring(obj[prop]))
    end)
    return strUi.Box(Text,function(str: string)
        pcall(function()
            obj[prop] = str;
        end)
    end,{con,Text});
end

return Module
