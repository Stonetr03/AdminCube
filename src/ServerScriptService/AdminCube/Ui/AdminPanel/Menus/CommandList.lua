-- Admin Cube - Settings Menu

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)

local SetVis

local ListVis = Value(true)
local CmdVis = Value(false)
local CmdTitle = Value("Command")
local CmdBox = Value("[player]")

-- Search Functions --
local Search = Value()
local SearchText = Value("");
function CheckVisibility(tags: {string}): boolean
    local txt = tostring(SearchText:get()):lower():gsub("^%s+", ""):gsub("%s+$", "");
    if txt.len == 0 then
        return true;
    end
    for _,str in pairs(tags) do
        if string.find(tostring(str):lower(),txt) then
            return true;
        end
    end

    return false;
end
function ResetSearch()
    local box = Search:get();
    if box then
        box.Text = "";
    end
end

-- Ui Functions --
function Btns()
    local Cmds,Alias,Rank = Api:GetCommands()
    return Fusion.ForPairs(Cmds,function(i,o)
        return i, New "Frame" {
            BackgroundTransparency = 1;
            Name = o.Name;
            Size = UDim2.new(1,0,0,20);
            ZIndex = 10;
            Visible = Computed(function()
                local tags = {o.Name,o.Desc}
                for ali,cmd in pairs(Alias) do
                    if cmd == o.Name then
                        table.insert(tags,ali);
                    end
                end
                return CheckVisibility(tags);
            end);
            [Children] = {
                NameDisplay = New "TextButton" {
                    BackgroundTransparency = 1;
                    TextColor3 = Api.Style.TextColor;
                    Size = UDim2.new(0.3,0,1,0);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextSize = 16;
                    Text = o.Name;
                    ZIndex = 15;
                    FontFace = Api.Style.Font;

                    [Event "MouseButton1Up"] = function()
                        ResetSearch();
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
                            Api:PromptCommandRunner(o.Name,o.Args);
                        end
                    end;
                };
                Desc = New "TextLabel" {
                    BackgroundTransparency = 1;
                    TextColor3 = Api.Style.TextColor;
                    Size = UDim2.new(0.7,0,1,0);
                    Position = UDim2.new(0.3,0,0,0);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextSize = 16;
                    Text = o.Desc;
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    ZIndex = 15;
                    FontFace = Api.Style.Font;
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
        TextSize = 20;
        FontFace = Api.Style.Font;
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
    ResetSearch();
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
        Name = "Commands";
        [Children] = {
            Search = New "TextBox" {
                BackgroundColor3 = Api.Style.ButtonColor;
                BackgroundTransparency = Api.Style.ButtonTransparency;
                FontFace = Api.Style.Font;
                PlaceholderText = "Search";
                Size = UDim2.new(1,0,0,25);
                Text = "";
                TextColor3 = Api.Style.TextColor;
                PlaceholderColor3 = Api.Style.TextSubColor;
                TextSize = 18;
                TextWrapped = true;
                Visible = ListVis;
                [Fusion.Ref] = Search;
                [Fusion.Out "Text"] = SearchText;
            };

            List = New "ScrollingFrame" {
                Name = "Settings";
                BackgroundColor3 = Api.Style.Background;
                BorderSizePixel = 0;
                Size = UDim2.new(1,0,1,-25);
                Position = UDim2.new(0,0,0,25);
                Visible = ListVis;
                CanvasSize = UDim2.new(0,0,0,0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                TopImage = "";
                BottomImage = "";
                MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
                ScrollBarThickness = 10;
                ScrollBarImageColor3 = Api.Style.TextColor;
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
                        FontFace = Api.Style.Font;
                    };
                    Box = New "TextLabel" {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,25);
                        Position = UDim2.new(0,0,0,40);
                        Text = CmdBox;
                        TextColor3 = Api.Style.TextColor;
                        TextSize = 10;
                        FontFace = Api.Style.Font;
                    };
                }
            }
        }
    };
end

return {MenuBtn,Menu,BackCallBack}
