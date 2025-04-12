-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService");
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Value = Fusion.Value
local Event = Fusion.OnEvent

local Module = {}

-- Values
local Visible = Value(false)
local Text = Value("!")
local InputRef = Value()

local ClientSettings = HttpService:JSONDecode(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("ClientSettings").Value)

local ShowTooltip = Value(ClientSettings.KeyboardNavDetour and ClientSettings.KeyboardNavDetour == true);
local last = 0;
ContextActionService:BindActionAtPriority("AdminCube-CommandBar",function(_: string, state: Enum.UserInputState, _: InputObject)
    if state == Enum.UserInputState.Begin then
        if ClientSettings.KeyboardNavDetour and ClientSettings.KeyboardNavDetour == true then
            -- Detour enabled
            if last > 0 then
                ShowTooltip:set(false);
            end
            if os.clock() - last > 3 then
                Visible:set(true)
                Text:set("!")
                InputRef:get().Text = "!"
                task.wait()
                InputRef:get():CaptureFocus()
                last = os.clock();
                return Enum.ContextActionResult.Sink;
            end
        else
            -- Detour Disabled
            Visible:set(true)
            Text:set("!")
            InputRef:get().Text = "!"
            task.wait()
            InputRef:get():CaptureFocus()
            return Enum.ContextActionResult.Sink;
        end
    end

    return Enum.ContextActionResult.Pass;
end,false,3000,Enum.KeyCode.BackSlash);

function Module.Ui(props)
    return New "Frame" {
        Parent = props.Parent;
        Size = UDim2.new(1,0,0,40);
        Position = UDim2.new(0,0,0.9,0);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
        Name = "CmdBar";
        Visible = Computed(function()
            return Visible:get()
        end);
        ZIndex = 3;
        [Children] = {
            TextBox = New "TextBox" {
                AnchorPoint = Vector2.new(0,0.5);
                Size = UDim2.new(1,0,0,30);
                Position = UDim2.new(0,0,0.5,0);
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.5;
                BorderSizePixel = 0;
                ClearTextOnFocus = false;
                TextSize = 20;
                Text = Computed(function()
                    return Text:get()
                end);
                TextColor3 = Color3.new(1,1,1);
                Font = Enum.Font.SourceSans;

                [Fusion.Ref] = InputRef;
                [Event "FocusLost"] = function(_,Enter)
                    if Enter then
                        Api:Fire("CmdBar",InputRef:get().Text)
                        Visible:set(false)
                    else
                        Visible:set(false)
                    end
                end
            };
            TextLabel = New "TextLabel" {
                Visible = ShowTooltip;
                AnchorPoint = Vector2.new(0,1);
                BackgroundTransparency = 1;
                TextColor3 = Color3.new(0.9,0.9,0.9);
                TextSize = 18;
                Size = UDim2.new(1,-10,0,20);
                RichText = true;
                Text = "For keyboard navigation, close and <i>`\\`</i>";
                TextXAlignment = Enum.TextXAlignment.Right;
            }
        }
    }
end

return Module
