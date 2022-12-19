-- Admin Cube - Log List Component

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local LogFolder = game.ReplicatedStorage.AdminCube:WaitForChild("Log")

local List = Roact.Component:extend("LogList")
local ScrollBinding = Roact.createBinding(0)

local Log = LogFolder:GetChildren()

local Colors = {
    Command = Color3.new(0, .5, 1);
    Warn = Color3.new(1, 1, 0);
    Error = Color3.new(1, 0, 0);
};
local function GetColor(Type)
    if typeof(Type) == "string" then
        if Colors[Type] then
            return Colors[Type]
        end
    end
    return Color3.new(1,1,1)
end

function List:init()
	self:setState({
		log = Log;
	})
    LogFolder.ChildAdded:Connect(function()
        Log = LogFolder:GetChildren()
        self:setState({
            log = Log;
        })
    end)
end

function List:render()
	local labels = {}
	for i,NewLog in pairs(Log) do
		labels[i] = Roact.createElement("Frame",{
			Size = UDim2.new(1,0,0,20);
            BackgroundTransparency = 1;
		},{
            Time = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Text = NewLog.Name;
                TextSize = 8;
                Size = UDim2.new(0,80,1,0)
            });
            Player = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Text = NewLog:WaitForChild("Player").Value.Name;
                TextSize = 8;
                Size = UDim2.new(0,80,1,0);
                Position = UDim2.new(0,80,0,0);
            });
            Action = Roact.createElement("TextLabel",{
                BackgroundTransparency = 1;
                TextColor3 = Api.Style.TextColor;
                Text = NewLog:WaitForChild("Text").Value;
                TextSize = 8;
                Size = UDim2.new(0,190,1,0);
                Position = UDim2.new(0,160,0,0);
                TextXAlignment = Enum.TextXAlignment.Left;
            });
            ColorFrame = Roact.createElement("Frame",{
                Size = UDim2.new(0,3,1,-2);
                Position = UDim2.new(0,0,0.5,0);
                AnchorPoint = Vector2.new(0,0.5);
                BorderSizePixel = 0;
                BackgroundColor3 = GetColor(NewLog:WaitForChild("Type").Value)
            })
        })
	end
	return Roact.createFragment(labels)
end

return {List,ScrollBinding}
