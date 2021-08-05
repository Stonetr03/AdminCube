-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Topbar = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Topbar"))
local UserInputService = game:GetService("UserInputService")

-- Topbar
local icon = Topbar.new()
icon:setImage("http://www.roblox.com/asset/?id=5010019455") -- 24x24

local Window = Roact.Component:extend("Window")

function Window:init()
	self.Visible, self.SetVisiblility = Roact.createBinding(true)
    self.Position, self.SetPosition = Roact.createBinding(UDim2.new(0,100,0,100))
end

function Window:render()
    icon.selected:Connect(function()
        self.SetVisiblility(true)
    end)

    icon.deselected:Connect(function()
        self.SetVisiblility(false)
    end)

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        self.SetPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
    end

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

	return Roact.createElement("Frame",{
        -- Visual
        Visible = self.Visible;
        BackgroundColor3 = Color3.new(0,0,0);
        BorderSizePixel = 0;
        Size = UDim2.new(0,self.props.SizeX,0,20);
        Position = self.Position;

         -- Drag
        [Roact.Event.InputBegan] = function(_,input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = self.Position:getValue()

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end;
        [Roact.Event.InputChanged] = function(_,input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end;

    },{
        -- Container
        Frame = Roact.createElement("Frame",{
            Position = UDim2.new(0,0,0,21);
            BorderSizePixel = 0;
            BackgroundColor3 = Color3.new(0,0,0);
            Size = UDim2.new(1,0,0,self.props.SizeY);
        })
    })
end

return Window
