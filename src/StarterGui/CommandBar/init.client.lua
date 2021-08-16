-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))

local ScreenGui = Roact.createElement("ScreenGui",{
    ResetOnSpawn = false;
    Name = "AdminCubeBar";
},{
    Frame = Roact.createElement("Frame",{
        Size = UDim2.new(1,0,0,40);
        Position = UDim2.new(0,0,0.9,0);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
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
            Text = "!";
            TextColor3 = Color3.new(1,1,1);
            Font = Enum.Font.SourceSans;
        })
    })
})

Roact.mount(ScreenGui,game.Players.LocalPlayer.PlayerGui)
