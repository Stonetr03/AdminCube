-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local UserInputService = game:GetService("UserInputService")
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local CmdBar = Roact.Component:extend("Window")

function CmdBar:init()
    self.Visible, self.SetVisiblility = Roact.createBinding(false)
    self.InputRef = Roact.createRef()
    self.Text, self.SetText = Roact.createBinding("!")

    UserInputService.InputEnded:Connect(function(Input)
        if UserInputService:GetFocusedTextBox() == nil then
            if Input.KeyCode == Enum.KeyCode.BackSlash then
                self.SetVisiblility(true)
                self.SetText("!")
                self.InputRef.current:CaptureFocus()
            end
        end
    end)
end

function CmdBar:render()
    return Roact.createElement("Frame",{
        Size = UDim2.new(1,0,0,40);
        Position = UDim2.new(0,0,0.9,0);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
        Visible = self.Visible;
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
            Text = self.Text;
            TextColor3 = Color3.new(1,1,1);
            Font = Enum.Font.SourceSans;

            [Roact.Ref] = self.InputRef;
            [Roact.Event.FocusLost] = function(_,Enter)
                if Enter then
                    Api:PushRemote("CmdBar",self.InputRef.current.Text)
                    self.SetVisiblility(false)
                end
            end;
        })
    })
end

return CmdBar
