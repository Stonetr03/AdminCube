-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local UserInputService = game:GetService("UserInputService")

local props = require(script.Parent.Parent:WaitForChild("Props"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {}

function Module.Ui(Shared: table, prop: string, CatTbl: table, AboveOthers: any): GuiObject
    local obj = Shared.Selection:get(false) :: Instance
    local Text = Value(string.split(tostring(obj[prop]),".")[3])
    local Visible = Value(false)
    local changed = obj:GetPropertyChangedSignal(prop):Connect(function()
        Text:set(string.split(tostring(obj[prop]),".")[3])
    end)
    local con
    return {
        New "TextButton" {
            BackgroundTransparency = 1;
            Font = Enum.Font.SourceSans;
            Position = UDim2.new(0.5,5,0,0);
            Size = UDim2.new(0.5,-6,1,0);
            TextColor3 = Api.Style.TextColor;
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            Text = Text;
            [Event "MouseButton1Up"] = function()
                Visible:set(not Visible:get())
                if Visible:get() == true then
                    AboveOthers:set(true)
                    if con then con:Disconnect() end
                    task.wait()
                    con = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            task.wait()
                            con:Disconnect()
                            Visible:set(false);
                            AboveOthers:set(false);
                        end
                    end)
                else
                    AboveOthers:set(false)
                end
            end;
            [Fusion.Cleanup] = {Text,Visible,changed,con,function()
                AboveOthers:set(false)
            end};
        };
        Computed(function()
            if Visible and Visible:get() then
                local ContentSize = Value(Vector2.new(0,0))
                return New "ScrollingFrame" {
                    BackgroundColor3 = Api.Style.BackgroundSubColor;
                    BorderColor3 = Api.Style.BackgroundSubSubColor;
                    BorderSizePixel = 1;
                    Position = UDim2.new(0.5,5,1,0);
                    Size = Computed(function()
                        if ContentSize and typeof(ContentSize:get()) == "Vector2" then
                            return UDim2.new(0.5,-10,0,ContentSize:get().Y);
                        end
                        return UDim2.new(0.5,-10,0,0)
                    end);
                    ScrollBarImageColor3 = Api.Style.TextColor;
                    BottomImage = "";
                    TopImage = "";
                    ScrollingDirection = Enum.ScrollingDirection.Y;
                    ScrollBarThickness = 5;
                    CanvasSize = Computed(function()
                        if ContentSize and typeof(ContentSize:get()) == "Vector2" then
                            return UDim2.new(0,0,0,ContentSize:get().Y);
                        end
                        return UDim2.new(0,0,0,0);
                    end);
                    ZIndex = 10;
                    [Fusion.Cleanup] = {ContentSize};
                    [Children] = {
                        New "UIListLayout" {
                            [Fusion.Out "AbsoluteContentSize"] = ContentSize;
                        };
                        New "UISizeConstraint" {
                            MaxSize = Vector2.new(math.huge,90);
                        };
                        Fusion.ForPairs(props.Enums[CatTbl.Name],function(i,o)
                            return i, New "TextButton" {
                                BackgroundTransparency = 1;
                                Font = Enum.Font.SourceSans;
                                Size = UDim2.new(1,0,0,20);
                                Text = i;
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 14;
                                TextXAlignment = Enum.TextXAlignment.Left;
                                [Event "MouseButton1Up"] = function()
                                    pcall(function()
                                        obj[prop] = o
                                    end)
                                end;
                            };
                        end,Fusion.cleanup)
                    }
                }
            end
            return nil
        end,Fusion.cleanup)
    }
end

return Module
