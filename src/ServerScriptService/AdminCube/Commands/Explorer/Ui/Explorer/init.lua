-- Admin Cube

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)
local Icons = require(script:WaitForChild("Icons"))
local SortOrder = require(script:WaitForChild("SortOrder"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {}

local ServicesToRender = {
    game.Workspace;
    game.Players;
    game.Lighting;
    game.ReplicatedFirst;
    game.ReplicatedStorage;
    game.StarterGui;
    game.StarterPack;
    game.StarterPlayer;
    game.Teams;
    game.SoundService;
}
local ServicesValue = Value(ServicesToRender)

function Module.Box(Object: Instance,Order: number,ObjectsOpen: table,Shared: table): GuiObject
    if Object == game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main") then return nil end
    local ScrollSize = Value(Vector2.new(0,0))
    local toRenderSort = Value(SortOrder:SortTable(Object:GetChildren()))
    local toRender = Value(Object:GetChildren())
    local Name = Value(Object.Name)
    local isOpen = Value(table.find(ObjectsOpen:get(),Object));
    local addCon = Object.ChildAdded:Connect(function()
        toRenderSort:set(SortOrder:SortTable(Object:GetChildren()))
        toRender:set(Object:GetChildren())
    end)
    local remCon = Object.ChildRemoved:Connect(function()
        toRenderSort:set(SortOrder:SortTable(Object:GetChildren()))
        toRender:set(Object:GetChildren())
    end)
    local openCon = Fusion.Observer(ObjectsOpen):onChange(function()
        local current = isOpen:get()
        if table.find(ObjectsOpen:get(),Object) then
            if current ~= true then
                isOpen:set(true)
            end
        else
            if current ~= false then
                isOpen:set(false)
            end
        end
    end)
    local nameCon = Object:GetPropertyChangedSignal("Name"):Connect(function()
        Name:set(Object.Name);
    end)
    return New "Frame" {
        Size = Computed(function()
            if ObjectsOpen and table.find(ObjectsOpen:get(),Object) and ScrollSize and typeof(ScrollSize:get()) == "Vector2" then
                return UDim2.new(1,0,0,20 + ScrollSize:get().Y)
            end
            return UDim2.new(1,0,0,20)
        end);
        BackgroundTransparency = 1;
        LayoutOrder = Order;
        [Fusion.Cleanup] = {ScrollSize,addCon,remCon,Name,nameCon,toRenderSort,toRender,isOpen,openCon};
        [Children] = {
            -- Select
            New "TextButton" {
                BackgroundTransparency = Computed(function()
                    if Shared.Selection:get() == Object then
                        return 0;
                    end
                    return 1;
                end);
                BackgroundColor3 = Color3.fromRGB(11,90,175);
                Text = "";
                Size = UDim2.new(1,0,0,20);
                ZIndex = -1;
                [Event "MouseButton1Up"] = function()
                    -- Select
                    Shared.Selection:set(Object)
                end;
            };
            -- Dropdown
            New "ImageButton" {
                BackgroundTransparency = 1;
                Image = "rbxassetid://9170684698";
                Position = UDim2.new(0,4,0,4);
                ScaleType = Enum.ScaleType.Fit;
                Size = UDim2.new(0,12,0,12);
                ImageColor3 = Api.Style.TextColor;
                Visible = Computed(function()
                    return #toRender:get() > 0;
                end);
                Rotation = Computed(function()
                    if ObjectsOpen and table.find(ObjectsOpen:get(),Object) then
                        return 90;
                    end
                    return 0;
                end);
                [Event "MouseButton1Up"] = function()
                    local tbl = ObjectsOpen:get()
                    if typeof(tbl) == "table" then
                        if table.find(tbl,Object) then
                            table.remove(tbl,table.find(tbl,Object))
                        else
                            table.insert(tbl,Object)
                        end
                        ObjectsOpen:set(tbl)
                    end
                end;
            };
            -- Icon
            New "ImageLabel" {
                BackgroundTransparency = 1;
                Image = Icons(Object);
                Position = UDim2.new(0,22,0,2);
                ResampleMode = Enum.ResamplerMode.Pixelated;
                Size = UDim2.new(0,16,0,16);
            };
            -- Title
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0,42,0,0);
                Size = UDim2.new(1,-42,0,20);
                TextColor3 = Api.Style.TextColor;
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Left;
                Text = Name;
                FontFace = Api.Style.Font;
            };
            -- Objects
            Computed(function()
                if isOpen and isOpen:get() and #toRender:get() > 0 then
                    return New "Frame" {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0,20,0,20);
                        Size = UDim2.new(1,-20,1,-20);
                        [Children] = {
                            New "UIListLayout" {
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                [Fusion.Out "AbsoluteContentSize"] = ScrollSize;
                            };
                            Fusion.ForPairs(toRender,function(i,o)
                                local LayoutSort = toRenderSort:get(false)
                                local LayoutOrder = if LayoutSort[o] then LayoutSort[o] else SortOrder.Max;
                                return i, Module.Box(o,LayoutOrder,ObjectsOpen,Shared);
                            end,Fusion.cleanup)
                        }
                    }
                end
                return nil;
            end,Fusion.cleanup)
        }
    }
end

function Module.Ui(Shared: table): GuiObject
    local ScrollSize = Value(Vector2.new(0,0));
    local ObjectsOpen = Value({})
    return New "ScrollingFrame" {
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
        ScrollBarThickness = 10;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        ScrollBarImageColor3 = Api.Style.TextColor;
        TopImage = "";
        BottomImage = "";
        CanvasSize = Computed(function()
            if ScrollSize and typeof(ScrollSize:get()) == "Vector2" then
                return UDim2.new(0,0,0,ScrollSize:get().Y);
            end
            return UDim2.new(0,0,0,0);
        end);
        [Fusion.Cleanup] = {ScrollSize,ObjectsOpen};
        [Children] = {
            New "UIListLayout" {
                SortOrder = Enum.SortOrder.LayoutOrder;
                [Fusion.Out "AbsoluteContentSize"] = ScrollSize;
            };
            Fusion.ForPairs(ServicesValue,function(i,o)
                return i, Module.Box(o,i,ObjectsOpen,Shared);
            end,Fusion.cleanup)
        }
    }
end

return Module
