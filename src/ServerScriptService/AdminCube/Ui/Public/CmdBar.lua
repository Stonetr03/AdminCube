-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")
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

if ClientSettings.KeyboardNavDetour and ClientSettings.KeyboardNavDetour == true then
    GuiService.AutoSelectGuiEnabled = false
end

local EnableNav = false
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Unknown then
		return
	end
    if ClientSettings.KeyboardNavDetour and ClientSettings.KeyboardNavDetour == true then
        if UserInputService:GetFocusedTextBox() == nil then

            if Input.KeyCode == Enum.KeyCode.BackSlash then
                if GuiService.SelectedObject == nil then
                    Visible:set(true)
                    Text:set("!")
                    InputRef:get().Text = "!"
                    EnableNav = true
                    task.wait()
                    InputRef:get():CaptureFocus()
                else
                    if ClientSettings.KeyboardNavEnabled and ClientSettings.KeyboardNavEnabled == true then
                        GuiService.SelectedObject = nil
                    end
                end
            elseif Input.KeyCode == Enum.KeyCode.Escape then
                if ClientSettings.KeyboardNavEnabled and ClientSettings.KeyboardNavEnabled == true then
                    if GuiService.SelectedObject ~= nil then
                        GuiService.SelectedObject = nil
                    end
                end
            end
        elseif UserInputService:GetFocusedTextBox() == InputRef:get() then
            if Input.KeyCode == Enum.KeyCode.BackSlash and EnableNav == true then
                InputRef:get():ReleaseFocus();
                EnableNav = false;
                Visible:set(false);
                if ClientSettings.KeyboardNavEnabled and ClientSettings.KeyboardNavEnabled == true then
                    if GuiService.SelectedObject == nil then
                        GuiService:Select(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
                    else
                        GuiService.SelectedObject = nil
                    end
                end
            else
                EnableNav = false
            end
        end

        if Input.KeyCode == Enum.KeyCode.ButtonSelect then
            if ClientSettings.XboxNavEnabled and ClientSettings.XboxNavEnabled == true then
                if GuiService.SelectedObject == nil then
                    GuiService:Select(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
                else
                    GuiService.SelectedObject = nil
                end
            end
        end

    else
        if Input.KeyCode == Enum.KeyCode.BackSlash then
            Visible:set(true)
            Text:set("!")
            InputRef:get().Text = "!"
            task.wait()
            InputRef:get():CaptureFocus()
        end
    end
end)

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
            }
        }
    }
end

return Module
