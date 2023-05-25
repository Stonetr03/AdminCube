-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local CmdBar = Roact.Component:extend("Window")

local Visible, SetVisiblity = Roact.createBinding(false)
local InputRef = Roact.createRef()
local Text, SetText = Roact.createBinding("!")

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
                    SetVisiblity(true)
                    SetText("!")
                    EnableNav = true
                    task.wait()
                    InputRef.current:CaptureFocus()
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
        elseif UserInputService:GetFocusedTextBox() == InputRef.current then
            if Input.KeyCode == Enum.KeyCode.BackSlash and EnableNav == true then
                InputRef.current:ReleaseFocus();
                EnableNav = false;
                SetVisiblity(false);
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
            SetVisiblity(true)
            SetText("!")
            task.wait()
            InputRef.current:CaptureFocus()
        end
    end
end)

function CmdBar:render()
    return Roact.createElement("Frame",{
        Size = UDim2.new(1,0,0,40);
        Position = UDim2.new(0,0,0.9,0);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
        Visible = Visible;
    },{
        TextBox = Roact.createElement("TextBox",{
            AnchorPoint = Vector2.new(0,0.5);
            Size = UDim2.new(1,0,0,30);
            Position = UDim2.new(0,0,0.5,0);
            BackgroundColor3 = Color3.new(0,0,0);
            BackgroundTransparency = 0.5;
            BorderSizePixel = 0;
            ClearTextOnFocus = false;
            TextSize = 20;
            Text = Text;
            TextColor3 = Color3.new(1,1,1);
            Font = Enum.Font.SourceSans;

            [Roact.Ref] = InputRef;
            [Roact.Event.FocusLost] = function(_,Enter)
                if Enter then
                    Api:Fire("CmdBar",InputRef.current.Text)
                    SetVisiblity(false)
                else
                    SetVisiblity(false)
                end
            end;
        })
    })
end

return CmdBar
