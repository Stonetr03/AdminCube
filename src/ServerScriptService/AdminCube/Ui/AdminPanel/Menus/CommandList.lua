-- Admin Cube - Settings Menu

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local StrMod = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("StrMod"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local SetVis

local CanvisSize = Value(UDim2.new(0,0,0,0))

local ListVis = Value(true)
local CmdVis = Value(false)
local CmdTitle = Value("Command")
local CmdBox = Value("[player]")

function Btns()
    local Cmds,Alias,Rank = Api:GetCommands()
    local Size = 0
    for _,_ in pairs(Cmds) do
        Size += 25
    end
    CanvisSize:set(UDim2.new(0,0,0,Size))
    return Fusion.ForPairs(Cmds,function(i,o)
        return i, New "Frame" {
            BackgroundTransparency = 1;
            Name = o.Name;
            Size = UDim2.new(1,0,0,20);
            ZIndex = 10;
            [Children] = {
                NameDisplay = New "TextButton" {
                    BackgroundTransparency = 1;
                    TextColor3 = Api.Style.TextColor;
                    Size = UDim2.new(0.3,0,1,0);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextSize = 8;
                    Text = o.Name;
                    ZIndex = 15;
                    Font = Enum.Font.Legacy;

                    [Event "MouseButton1Up"] = function()
                        local Invalid = false
                        if typeof(tonumber(string.sub(o.Args,1,1))) == "number" then
                            if tonumber(string.sub(o.Args,1,1)) > Rank then
                                -- Invalid Permissions
                                CmdBox:set("Invalid Permissions")
                                Invalid = true
                                task.spawn(function()

                                    ListVis:set(false)
                                    CmdVis:set(true)
                                    CmdTitle:set(o.Name)
                                    task.wait(2);
                                    ListVis:set(true)
                                    CmdVis:set(false)
                                end)
                            end
                        end
                        if Invalid == false then
                            -- Get Args
                            --[[
                                Valid Args = 
                                [player]
                                [string]
                                [number]
                            ]]
                            local Split = string.split(o.Args,";")
                            local PromptInfo = {}
                            local PromptNames = {}
                            if #Split >= 2 then else
                                return false
                            end
                            for i = 2,#Split,1 do
                                if string.sub(Split[i],1,2) == "*[" and string.sub(Split[i],string.len(Split[i])) == "]" then
                                    -- Required
                                    local Ident = string.sub(Split[i],3,string.len(Split[i]) - 1)
                                    local SubSplit = string.split(Ident,":")

                                    local Title = ""
                                    local Type = "String"
                                    local DefaultValue = ""

                                    if SubSplit[1] == "player" then
                                        local plrlist = {}
                                        for _,op in pairs(game.Players:GetPlayers()) do
                                            table.insert(plrlist,op.Name)
                                        end

                                        table.insert(PromptInfo,{
                                            Title = "*Player";
                                            Type = "Dropdown";
                                            Value = plrlist;
                                        })

                                        table.insert(PromptNames,SubSplit[1])

                                    else
                                        if SubSplit[1] == "string" then
                                            Title = "*String"
                                            Type = "String"
                                            DefaultValue = ""

                                            if SubSplit[2] and typeof(SubSplit[2]) == "string" then
                                                Title = "*" .. SubSplit[2]
                                            end

                                        elseif SubSplit[1] == "number" then
                                            Title = "*Number"
                                            Type = "String"
                                            DefaultValue = ""

                                            if SubSplit[2] and typeof(SubSplit[2]) == "string" then
                                                Title = "*" .. SubSplit[2]
                                            end

                                        end

                                        table.insert(PromptInfo,{
                                            Title = Title;
                                            Type = Type;
                                            DefaultValue = DefaultValue;
                                        })
                                        table.insert(PromptNames,SubSplit[1])

                                    end

                                elseif string.sub(Split[i],1,1) == "[" and string.sub(Split[i],string.len(Split[i])) == "]" then
                                    -- Not Required

                                    local Ident = string.sub(Split[i],2,string.len(Split[i]) - 1)
                                    local SubSplit = string.split(Ident,":")

                                    local Title = ""
                                    local Type = "String"
                                    local DefaultValue = ""

                                    if SubSplit[1] == "player" then
                                        local plrlist = {}
                                        for _,op in pairs(game.Players:GetPlayers()) do
                                            table.insert(plrlist,op.Name)
                                        end

                                        table.insert(PromptInfo,{
                                            Title = "Player";
                                            Type = "Dropdown";
                                            Value = plrlist;
                                        })
                                        table.insert(PromptNames,SubSplit[1])

                                    else
                                        if SubSplit[1] == "string" then
                                            Title = "String"
                                            Type = "String"
                                            DefaultValue = ""

                                            if SubSplit[2] and typeof(SubSplit[2]) == "string" then
                                                Title = "" .. SubSplit[2]
                                            end

                                        elseif SubSplit[1] == "number" then
                                            Title = "Number"
                                            Type = "String"
                                            DefaultValue = ""

                                            if SubSplit[2] and typeof(SubSplit[2]) == "string" then
                                                Title = "" .. SubSplit[2]
                                            end

                                        end

                                        table.insert(PromptInfo,{
                                            Title = Title;
                                            Type = Type;
                                            DefaultValue = DefaultValue;
                                        })
                                        table.insert(PromptNames,SubSplit[1])
                                    end

                                end
                            end

                            -- Show Prompt
                            Api:Prompt({
                                Title = o.Name;
                                Prompt = PromptInfo;
                            },function(Results)

                                if Results[1] == true then
                                    -- Run
                                    local Command = "!" .. o.Name

                                    for index, v in PromptNames do
                                        if v == "player" then
                                            local ToAdd = game.Players.LocalPlayer.Name
                                            if Results[2][index] and Results[2][index] ~= "Select" then
                                                local Target = game.Players:FindFirstChild(Results[2][index])
                                                if Target then
                                                    ToAdd = Target.Name
                                                end
                                            end
                                            Command = Command .. " " .. ToAdd

                                        elseif v == "string" then
                                            Command = Command .. " " .. Results[2][index]

                                        elseif v == "number" then
                                            local ToAdd = StrMod:RemoveLetters(Results[2][index])
                                            Command = Command .. " " .. ToAdd
                                        end
                                    end

                                    -- Run Command
                                    Api:Fire("CmdBar",Command)

                                end

                            end)
                        end
                    end;
                };
                Desc = New "TextLabel" {
                    BackgroundTransparency = 1;
                    TextColor3 = Api.Style.TextColor;
                    Size = UDim2.new(0.7,0,1,0);
                    Position = UDim2.new(0.3,0,0,0);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextSize = 8;
                    Text = o.Desc;
                    TextWrapped = true;
                    ZIndex = 15;
                    Font = Enum.Font.Legacy;
                };
            };
        }
    end,Fusion.cleanup)
end

function MenuBtn(props)
    return New "TextButton" {
        Name = "Commands";
        Text = "Commands";
        LayoutOrder = 1;
        Visible = props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
        TextSize = 8;
        Font = Enum.Font.Legacy;
        [Event "MouseButton1Up"] = function()
            SetVis(true)
            ListVis:set(true)
            CmdVis:set(false)
            props.SetVis(false)
        end
    }
end

function BackCallBack()
    SetVis(false)
end

local Visible = Value(false)

SetVis = function(Vis)
    Visible:set(Vis)
end

function Menu()
    return New "Frame" {
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
        Visible = Visible;
        [Children] = {
            List = New "ScrollingFrame" {
                Name = "Settings";
                BackgroundColor3 = Api.Style.Background;
                BorderSizePixel = 0;
                Size = UDim2.new(1,0,1,0);
                Visible = ListVis;
                CanvasSize = CanvisSize;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                TopImage = "";
                BottomImage = "";
                MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
                ScrollBarThickness = 5;
                ZIndex = 5;
                [Children] = {
                    UiListLayout = New "UIListLayout" {
                        Padding = UDim.new(0,5);
                    };
            
                    UiPadding = New "UIPadding" {
                        PaddingTop = UDim.new(0,5);
                        PaddingBottom = UDim.new(0,5);
                        PaddingLeft = UDim.new(0,5);
                        PaddingRight = UDim.new(0,5);
                    };
            
                    Btns = Btns();
                }
            };
    
            Command = New "Frame" {
                BackgroundColor3 = Api.Style.Background;
                BorderSizePixel = 0;
                Size = UDim2.new(1,0,1,0);
                Visible = CmdVis;
                [Children] = {
                    Title = New "TextLabel" {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,30);
                        Text = CmdTitle;
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 15;
                        Font = Enum.Font.Arial;
                    };
                    Box = New "TextLabel" {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,25);
                        Position = UDim2.new(0,0,0,40);
                        Text = CmdBox;
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 10;
                        Font = Enum.Font.Arial;
                    };
                }
            }
        }
    };
end

return {MenuBtn,Menu,BackCallBack}
