-- Admin Cube - Client Api

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local Background, SetBackground = Roact.createBinding(Color3.new(0,0,0));
local BackgroundSubColor, SetBackgroundSubColor = Roact.createBinding(Color3.fromRGB(49,49,49));
local BackgroundSubSubColor, SetBackgroundSubSubColor = Roact.createBinding(Color3.fromRGB(22,22,22));
local ButtonColor, SetButtonColor = Roact.createBinding(Color3.new(1,1,1));
local TextColor, SetTextColor = Roact.createBinding(Color3.new(1,1,1));
local ButtonTransparency, SetButtonTransparency = Roact.createBinding(0.85);
local ButtonSubColor, SetButtonSubColor = Roact.createBinding(Color3.fromRGB(200,200,200))

local ThemeUpdateEvents = {}

local Api = {
    Settings = {
        CurrentTheme = "Dark"
    };
    Style = {
        Background = Background;
        ButtonColor = ButtonColor;
        BackgroundSubSubColor = BackgroundSubSubColor;
        TextColor = TextColor;
        ButtonTransparency = ButtonTransparency;
        ButtonSubColor = ButtonSubColor;
        BackgroundSubColor = BackgroundSubColor;
    }
}

local Themes = {}
local CurrentTheme = 0
for i,o in pairs(script:GetChildren()) do
    if string.sub(o.Name,1,11) == "Stylesheet." then
        Themes[i] = string.sub(o.Name,12)
        if string.sub(o.Name,12) == Api.Settings.CurrentTheme then
            CurrentTheme = i
        end
    end
end

local function UpdateTheme()
    local Style = require(script:FindFirstChild("Stylesheet." .. Api.Settings.CurrentTheme))
    if Style then
        SetBackground(Style.Background)
        SetButtonColor(Style.ButtonColor)
        SetTextColor(Style.TextColor)
        SetButtonTransparency(Style.ButtonTransparency)
        SetButtonSubColor(Style.ButtonSubColor)
        SetBackgroundSubColor(Style.BackgroundSubColor)
        SetBackgroundSubSubColor(Style.BackgroundSubSubColor)

        for i = 1,#ThemeUpdateEvents,1 do
            ThemeUpdateEvents[i]()
        end
    end
end

function Api:UpdateTheme(Theme)
    if Theme then
        Api.Settings.CurrentTheme = Theme
        UpdateTheme()
    else
        CurrentTheme = CurrentTheme + 1
        if CurrentTheme > #Themes then
            CurrentTheme = 1
        end

        Api.Settings.CurrentTheme = Themes[CurrentTheme]

        UpdateTheme()
    end
end
UpdateTheme()

function Api:Fire(Key,Args)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireServer(Key,Args)
end

function Api:OnEvent(Key,Callback)
    local con = game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent.OnClientEvent:Connect(function(CallingKey,Args)
        if CallingKey == Key and typeof(Callback) == "function" then
            Callback(Args)
        end
    end)
    local ReturnTab = {}
    function ReturnTab:Disconnect()
        con:Disconnect()
    end
    return ReturnTab
end

function Api:Invoke(Key,Args)
    return game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc:InvokeServer(Key,Args)
end

function Api:OnInvoke(Key,Callback)
    game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc.OnClientInvoke = function(CallingKey,Args)
        if CallingKey == Key then
            Callback(Args)
        end
    end
end

function Api:ThemeUpdateEvent(Func)
    ThemeUpdateEvents[#ThemeUpdateEvents+1] = Func
end

function Api:GetCommands()
    local Cmds,Alias,Rank = Api:Invoke("GetCommands")
    return Cmds,Alias,Rank
end

function Api:CreateWindow(Props,Component)
    if Props.ZIndex == nil then
        Props.ZIndex = 1
    end
    local WindowModule = require(script.Window)
    local WindowComp,Functions = WindowModule:CreateWindow()
    local WindowFrame = Roact.createElement(WindowComp,{
        Btns = Props.Buttons;
        SizeX = Props.SizeX;
        SizeY = Props.SizeY;
        Main = Component;
        Title = Props.Title;
        Style = Api.Style;
        ZIndex = Props.ZIndex;
    })
    local Tree = Roact.mount(WindowFrame,game.Players.LocalPlayer.PlayerGui:FindFirstChild("__AdminCube_Main"),"Window-" .. Props.Title)
    local ReturnTab = {
        OnClose = {}
    }

    local Close = {}
    function ReturnTab.unmount()
        Roact.unmount(Tree)

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
    
    ReturnTab.SetVis = Functions.SetVis

    return ReturnTab
end

-- Prompts
local PromptItems = require(script.Prompts)
local PromptBoolean,PromptString,PromptDropdown,PromptImage = PromptItems[1],PromptItems[2],PromptItems[3],PromptItems[4]

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
    local ButtonsComp = Roact.Component:extend("PromptButtonsComp")

    local Added = 0
    for i,o in pairs(Prompts.Prompt) do
        if o.Type == "Image" then
            Added += 75
        end
    end
    function ButtonsComp:render()
        for i,o in pairs(Prompts.Prompt) do
            if o.Type == "Boolean" then
                ButtonFragments[i] = Roact.createElement(PromptBoolean,{
                    Style = Api.Style;
                    Y = Y;
                    Title = o.Title;
                    DefaultValue = o.DefaultValue;
                    UpdateValue = function(NewValue)
                        CurrentValues[i] = NewValue
                    end
                })
                CurrentValues[i] = o.DefaultValue
            elseif o.Type == "String" then
                ButtonFragments[i] = Roact.createElement(PromptString,{
                    Style = Api.Style;
                    Y = Y;
                    Title = o.Title;
                    DefaultValue = o.DefaultValue;
                    UpdateValue = function(NewValue)
                        CurrentValues[i] = NewValue
                    end
                })
                CurrentValues[i] = o.DefaultValue
            elseif o.Type == "Dropdown" then
                ButtonFragments[i] = Roact.createElement(PromptDropdown,{
                    Style = Api.Style;
                    Y = Y;
                    Title = o.Title;
                    Value = o.Value;
                    DefaultValue = o.DefaultValue;
                    UpdateValue = function(NewValue)
                        CurrentValues[i] = NewValue
                    end
                })
                CurrentValues[i] = o.DefaultValue

            elseif o.Type == "Image" then
                ButtonFragments[i] = Roact.createElement(PromptImage,{
                    Style = Api.Style;
                    Y = Y;
                    Image = o.Image;
                    Text1 = o.Text1;
                    Text2 = o.Text2;
                    Text3 = o.Text3;
                    Text4 = o.Text4;
                })
                Y += 75
            end
            Y += 25
        end
        return Roact.createFragment(ButtonFragments)
    end
    
    local PromptComp = Roact.Component:extend("PromptComp")
    function PromptComp:render()
        return Roact.createElement("ScrollingFrame",{
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,1,0);
            BottomImage = "";
            CanvasSize = UDim2.new(0,0,0,Y+50);
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
            ScrollBarImageColor3 = Api.Style.ButtonColor;
            ScrollBarThickness = 5;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            TopImage = "";
            ClipsDescendants = false;
       },{
            Title = Roact.createElement("TextLabel",{
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
            });
            Buttons = Roact.createElement(ButtonsComp);
            Frame = Roact.createElement("Frame",{
                BackgroundTransparency = 1;
                Position = UDim2.new(0,0,0, (#Prompts.Prompt * 25) +27 + Added);
                Size = UDim2.new(1,0,0,25);
            },{
                Confirm = Roact.createElement("TextButton",{
                    BackgroundColor3 = Api.Style.ButtonColor;
                    BackgroundTransparency = Api.Style.ButtonTransparency;
                    BorderSizePixel = 0;
                    Size = UDim2.new(0.5,-1,1,0);
                    Font = Enum.Font.SourceSans;
                    Text = "Confirm";
                    TextColor3 = Api.Style.TextColor;
                    TextSize = 22;
                    ZIndex = 20;

                    [Roact.Event.MouseButton1Up] = function()

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
                });
                Cancel = Roact.createElement("TextButton",{
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

                    [Roact.Event.MouseButton1Up] = function()
                        
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
                })
			})
        })
    end

    Window = Api:CreateWindow({
        SizeX = 250;
        SizeY = ((#Prompts.Prompt * 25) + 4 + 50 + Added);
        Title = "Prompt";
        ZIndex = 19
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
