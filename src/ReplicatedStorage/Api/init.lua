-- Admin Cube - Client Api

local HttpService = game:GetService("HttpService")
local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Signal = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Signal"))
local WindowModule = require(script.Window)

local ScreenGui: ScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("__AdminCube_Main");

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children

local Background = Value(Color3.new(0,0,0));
local BackgroundSubColor = Value(Color3.fromRGB(49,49,49));
local BackgroundSubSubColor = Value(Color3.fromRGB(22,22,22));
local ButtonColor = Value(Color3.new(1,1,1));
local TextColor = Value(Color3.new(1,1,1));
local ButtonTransparency = Value(0.85);
local ButtonSubColor = Value(Color3.fromRGB(200,200,200))

local Api = {
    Settings = {
        Changed = Signal.new(); -- "Category", "SettingName", Value
        _modifiers = {};
    };
    Style = {
        Background = Background;
        ButtonColor = ButtonColor;
        BackgroundSubSubColor = BackgroundSubSubColor;
        TextColor = TextColor;
        ButtonTransparency = ButtonTransparency;
        ButtonSubColor = ButtonSubColor;
        BackgroundSubColor = BackgroundSubColor;
    };
    FocusedWindow = Value("");
}

-- Global Settings
local defaultSettings = require(script:WaitForChild("DefaultSettings"))
Api.Settings._modifiers = {["global"] = defaultSettings[2]}
for i,o in pairs(defaultSettings[1]) do
    if i ~= "Changed" then
        Api.Settings[i] = o;
    end
end

function Api:SetSetting(Setting: string, NewValue: string | number | any, Cat: string?)
    if typeof(Cat) ~= "string" then
        Cat = "global"
    end
    if Cat == "global" then
        if Setting == "Changed" then return end if Setting == "_modifiers" then return end
        if typeof(Api.Settings[Setting]) == "table" then
            warn("Invalid Setting Name: cannot be table") return
        elseif typeof(NewValue) == "table" then
            warn("Invalid Setting Value: cannot be table in global setting") return
        end
        -- Setting modifirers
        if Api.Settings._modifiers["global"][Setting] and Api.Settings._modifiers["global"][Setting].Check then
            NewValue = Api.Settings._modifiers["global"][Setting].Check(NewValue)
        end
        Api.Settings[Setting] = NewValue
        Api.Settings.Changed:Fire(Setting,NewValue,Cat)
    else
        if Cat == "Changed" then warn("Invalid Category Name") return end
        if typeof(Api.Settings[Cat]) == "table" then
        elseif typeof(Api.Settings[Cat]) == "nil" then
            Api.Settings[Cat] = {}
        else warn("Invalid Category: name cannot be same as global setting") return
        end
        -- Setting modifirers
        if Api.Settings._modifiers[Cat] and Api.Settings._modifiers[Cat][Setting] and Api.Settings._modifiers[Cat][Setting].Check then
            NewValue = Api.Settings._modifiers[Cat][Setting].Check(NewValue)
        end
        Api.Settings[Cat][Setting] = NewValue
        Api.Settings.Changed:Fire(Setting,NewValue,Cat)
    end
end
export type Modifier = {Text: string, Check: (Value: any) -> any}
function Api:SetSettingModifier(Setting: string,Mod: Modifier,Cat: string?)
    -- Validate
    if typeof(Mod) ~= "table" then
        warn("invalid modifier type") return
    end
    if typeof(Mod.Text) ~= "string" and typeof(Mod.Text) ~= "nil" then
        warn("invalid modifier type") return
    end
    if typeof(Mod.Check) ~= "function" and typeof(Mod.Check) ~= "nil" then
        warn("invalid modifier type") return
    end
    if typeof(Cat) ~= "string" then
        Cat = "global"
    end
    if typeof(Api.Settings._modifiers[Cat]) ~= "table" then
        Api.Settings._modifiers[Cat] = {}
    end
    if Cat == "global" then
        if Setting == "Changed" then return end if Setting == "_modifiers" then return end
    elseif Cat == "Changed" then warn("Invalid Category Name") return
    end
    -- Set Mod
    Api.Settings._modifiers[Cat][Setting] = Mod
end

-- Themes
local Themes = {}
local CurrentTheme = 0
for _,o in pairs(script:GetChildren()) do
    if string.sub(o.Name,1,11) == "Stylesheet." then
        table.insert(Themes,string.sub(o.Name,12))
        if string.sub(o.Name,12) == Api.Settings.CurrentTheme then
            CurrentTheme = table.find(Themes,string.sub(o.Name,12))
        end
    end
end

local function UpdateTheme()
    local Style = require(script:FindFirstChild("Stylesheet." .. Api.Settings.CurrentTheme))
    if Style then
        Background:set(Style.Background)
        ButtonColor:set(Style.ButtonColor)
        TextColor:set(Style.TextColor)
        ButtonTransparency:set(Style.ButtonTransparency)
        ButtonSubColor:set(Style.ButtonSubColor)
        BackgroundSubColor:set(Style.BackgroundSubColor)
        BackgroundSubSubColor:set(Style.BackgroundSubSubColor)
    end
end

Api.Settings.Changed:Connect(function(Setting,Theme,Cat)
    if Cat == "global" and Setting == "CurrentTheme" then
        UpdateTheme()
    end
end)
Api:SetSettingModifier("CurrentTheme",{
    Text = "Theme";
    Check = function(Theme)
        if Theme then
            if table.find(Themes,Theme) then
                return Theme
            end
        end
        CurrentTheme += 1
        if CurrentTheme > #Themes then
            CurrentTheme = 1
        end

        return Themes[CurrentTheme]
    end
})

UpdateTheme()

-- Remote Events
function Api:Fire(Key,...)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireServer(Key,...)
end

function Api:OnEvent(Key,Callback)
    local con = game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent.OnClientEvent:Connect(function(CallingKey,...)
        if CallingKey == Key and typeof(Callback) == "function" then
            Callback(...)
        end
    end)
    local ReturnTab = {}
    function ReturnTab:Disconnect()
        con:Disconnect()
    end
    return ReturnTab
end

function Api:Invoke(Key,...)
    return game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc:InvokeServer(Key,...)
end

function Api:OnInvoke(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc.OnClientInvoke = function(CallingKey,...)
        if CallingKey == Key then
            Callback(...)
        end
    end
end

-- Focusing
local WindowIds = {}
function Api:FocusWindow(id: string): nil
    if table.find(WindowIds,id) then
        Api.FocusedWindow:set(id)
    else
        warn("id " .. id .. " not found")
    end
end
function Api:GetFocusedWindow(): string
    return Api.FocusedWindow:get()
end

-- Commands
function Api:GetCommands()
    local Cmds,Alias,Rank = Api:Invoke("GetCommands")
    return Cmds,Alias,Rank
end

-- Window
function Api:CreateWindow(Props: {
    Buttons: {};
    Size: Vector2;
    Title: string;
    ZIndex: number;
    Position: UDim2;
    Resizeable: boolean;
    ResizeableMinimum: Vector2;
    ResizeableMaximum: Vector2;
    Draggable: boolean;
    HideTopbar: boolean;
}, Component: GuiBase)
    local id = HttpService:GenerateGUID(true)
    table.insert(WindowIds,id)
    Props = WindowModule:CheckTable(Props)
    local Window,Functions = WindowModule:CreateWindow({
        Focus = Api.FocusedWindow;
        id = id;
        Btns = Props.Buttons;
        Size = Props.Size;
        Main = Component;
        Title = Props.Title;
        Style = Api.Style;
        Position = Props.Position;
        Parent = ScreenGui;
        Name = "Window-" .. Props.Title;
        Resizeable = Props.Resizeable;
        ResizeableMinimum = Props.ResizeableMinimum;
        ResizeableMaximum = Props.ResizeableMaximum;
        Draggable = Props.Draggable;
        HideTopbar = Props.HideTopbar;
        FocusWindow = Api.FocusWindow;
    })
    local ReturnTab = {
        id = id;
        OnClose = {}
    }

    local Close = {}
    function ReturnTab.unmount()
        Window:Destroy()

        Close = nil
    end

    function ReturnTab.OnClose:Connect(f)
        if typeof(f) == "function" then
            Close[#Close+1] = f
        end

    end

    Functions.OnClose = function()
        for _,f in pairs(Close) do
            f()
        end
    end

    ReturnTab.SetVis = function(Vis: boolean)
        Functions.SetVis:set(Vis)
        if Vis == true then
            Api:FocusWindow(id)
        end
    end
    ReturnTab.SetSize = Functions.SetSize
    ReturnTab.SetPosition = Functions.SetPosition

    Api:FocusWindow(id)

    return ReturnTab
end

-- Prompts
local PromptItems = require(script.Prompts)
local PromptBoolean,PromptString,PromptDropdown,PromptImage,PromptInfo,DropdownList = PromptItems[1],PromptItems[2],PromptItems[3],PromptItems[4],PromptItems[5],PromptItems[6]

local PromptOpen = false
local Promptlocal = false
local localresponse

function ShowPrompt(Prompts)
    PromptOpen = true
    -- Generate Uis
    local Window
    local CurrentValues = {}
    local Y = 27
    local ButtonFragments = {}

    local DropdownObj

    local Added = 0
    for i,o in pairs(Prompts.Prompt) do
        if o.Type == "Image" then
            Added += 75
        end
    end
    for i,o in pairs(Prompts.Prompt) do
        if o.Type == "Boolean" then
            ButtonFragments[i] = PromptBoolean({
                Style = Api.Style;
                Y = Y;
                Title = o.Title;
                DefaultValue = o.DefaultValue;
                UpdateValue = function(NewValue)
                    CurrentValues[i] = NewValue
                end;
                ZIndex = #Prompts.Prompt - i + 20
            })
            CurrentValues[i] = o.DefaultValue
        elseif o.Type == "String" then
            ButtonFragments[i] = PromptString({
                Style = Api.Style;
                Y = Y;
                Title = o.Title;
                DefaultValue = o.DefaultValue;
                PlaceholderValue = o.PlaceholderValue;
                UpdateValue = function(NewValue)
                    CurrentValues[i] = NewValue
                end;
                ZIndex = #Prompts.Prompt - i + 20
            })
            CurrentValues[i] = o.DefaultValue
        elseif o.Type == "Dropdown" then
            if not DropdownObj then
                DropdownObj = DropdownList({
                    Style = Api.Style;
                });
            end
            ButtonFragments[i] = PromptDropdown({
                Style = Api.Style;
                Y = Y;
                Title = o.Title;
                Value = o.Value;
                Dropdown = DropdownObj;
                DefaultValue = o.DefaultValue;
                UpdateValue = function(NewValue)
                    CurrentValues[i] = NewValue
                end;
                ZIndex = #Prompts.Prompt - i + 20
            })
            CurrentValues[i] = o.DefaultValue

        elseif o.Type == "Image" then
            ButtonFragments[i] = PromptImage({
                Style = Api.Style;
                Y = Y;
                Image = o.Image;
                Text1 = o.Text1;
                Text2 = o.Text2;
                Text3 = o.Text3;
                Text4 = o.Text4;
                ZIndex = #Prompts.Prompt - i + 20
            })
            Y += 75
        elseif o.Type == "Info" then
            ButtonFragments[i] = PromptInfo({
                Style = Api.Style;
                Y = Y;
                Text = o.Text;
                ZIndex = #Prompts.Prompt - i + 20
            })
        end
        Y += 25
    end

    local PromptComp = {
        New "ScrollingFrame" {
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,1,0);
            BottomImage = "";
            CanvasSize = UDim2.new(0,0,0,Y+25);
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
            ScrollBarImageColor3 = Api.Style.ButtonColor;
            ScrollBarThickness = 5;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            TopImage = "";
            [Children] = {
                Title = New "TextLabel" {
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = 0.9;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1,0,0,25);
                    Font = Enum.Font.SourceSans;
                    Text = Prompts.Title;
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 25;
                    LayoutOrder = 1;
                    ZIndex = 20;
                };
                Buttons = ButtonFragments;
                Frame = New "Frame" {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0,0,0, (#Prompts.Prompt * 25) +27 + Added);
                    Size = UDim2.new(1,0,0,25);
                    [Children] = {
                        Confirm = New "TextButton" {
                            BackgroundColor3 = Api.Style.ButtonColor;
                            BackgroundTransparency = Api.Style.ButtonTransparency;
                            BorderSizePixel = 0;
                            Size = UDim2.new(0.5,-1,1,0);
                            Font = Enum.Font.SourceSans;
                            Text = "Confirm";
                            TextColor3 = Api.Style.TextColor;
                            TextSize = 22;
                            ZIndex = 20;

                            [Event "MouseButton1Up"] = function()

                                if Promptlocal == true then
                                    if typeof(localresponse) == "function" then
                                        localresponse({true,CurrentValues})
                                    end
                                else
                                    Api:Fire("Prompts",{true,CurrentValues})
                                end

                                Window.unmount()
                                PromptOpen = false
                            end;
                        };
                        Cancel = New "TextButton" {
                            BackgroundColor3 = Api.Style.ButtonColor;
                            BackgroundTransparency = Api.Style.ButtonTransparency;
                            BorderSizePixel = 0;
                            Size = UDim2.new(0.5,-1,1,0);
                            Position = UDim2.new(0.5,1,0,0);
                            Font = Enum.Font.SourceSans;
                            Text = "Cancel";
                            TextColor3 = Api.Style.TextColor;
                            TextSize = 22;
                            ZIndex = 20;

                            [Event "MouseButton1Up"] = function()

                                if Promptlocal == true then
                                    if typeof(localresponse) == "function" then
                                        localresponse({false})
                                    end
                                else
                                    Api:Fire("Prompts",{false})
                                end

                                Window.unmount()
                                PromptOpen = false
                            end;
                        }
                    }
                }
            }
        };
        DropdownObj and DropdownObj.Ui();
    }

    Window = Api:CreateWindow({
        Size = Vector2.new(250,math.min(((#Prompts.Prompt * 25) + 4 + 50 + Added), ScreenGui.AbsoluteSize.Y));
        Title = "Prompt";
    },PromptComp)
end

Api:OnEvent("Prompts",function(Prompts)
    if PromptOpen == false then
        Promptlocal = false
        ShowPrompt(Prompts)
    end
end)

function Api:Prompt(Prompts,Response)
    if not typeof(Response) == "function" then
        return false
    end
    if PromptOpen == false then
        Promptlocal = true
        ShowPrompt(Prompts)
        localresponse = Response
    end
end

return Api
