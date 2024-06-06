-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Value = Fusion.Value

local Explorer = require(script:WaitForChild("Explorer"))
local Properties = require(script:WaitForChild("Properties"))

local ScreenGuiSize = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main").AbsoluteSize

local Shared = {
    Selection = Value();
    Search = Value("");
}

local PropertiesWindow = Api:CreateWindow({
    Size = Vector2.new(300,(ScreenGuiSize.Y - 20) / 2 - 20);
    Title = "Properties";
    Position = UDim2.new(1,-320,0,ScreenGuiSize.Y / 2);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(150,150);
},Properties.Ui(Shared))

local ExplorerWindow = Api:CreateWindow({
    Size = Vector2.new(300,(ScreenGuiSize.Y - 20) / 2 - 20);
    Title = "Explorer";
    Position = UDim2.new(1,-320,0,0);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(150,150);
    Buttons = {
        [1] = {
            Text = "rbxassetid://11326672569";
            Callback = function()
                PropertiesWindow.SetVis(true)
            end;
            Padding = 2;
            Type = "Image";
        };
    }
},Explorer.Ui(Shared))
ExplorerWindow.SetVis(true)

ExplorerWindow.OnClose:Connect(function()
    ExplorerWindow.unmount()
    PropertiesWindow.unmount()
    Fusion.cleanup(Shared)
    script:Destroy()
end)