-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local Window = Roact.Component:extend("Window")

function Window:render()
	return Roact.createElement("Frame",{
        -- Drag
        Draggable = true;
        Active = true;
        Selectable = true;

        -- Visual
        BackgroundColor3 = Color3.new(0,0,0);
        BorderSizePixel = 0;
        Size = UDim2.new(0,self.props.SizeX,0,20);
    })
end

return Window
