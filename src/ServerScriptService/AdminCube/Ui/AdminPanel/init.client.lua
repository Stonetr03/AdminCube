-- Admin Cube

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local New = Fusion.New
local Children = Fusion.Children

-- Topbar
local Topbar = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Topbar"))

local icon = Topbar.new()
icon:setImage("http://www.roblox.com/asset/?id=5010019455") -- 24x24
icon:setName("AdminCubeMainAdminPanel")
icon:setProperty("deselectWhenOtherIconSelected",false)

local NotificationEvent = Instance.new("BindableEvent")
NotificationEvent.Name = "NotificationEvent";
NotificationEvent.Parent = script
NotificationEvent.Event:Connect(function()
    icon:notify()
end)

local MainMenus = require(script.MainMenus)
local BackCallback = MainMenus[3]

local WindowFrame = New "Frame" {
    Visible = true;
    Position = UDim2.new(0,0,0,0);
    BorderSizePixel = 0;
    BackgroundTransparency = 1;
    Size = UDim2.new(1,0,1,0);
    [Children] = {
        -- Main Menus Frame
        MainMenu = New "Frame" {
            Size = UDim2.new(1,0,1,0);
            Name = "MainMenu";
            BackgroundTransparency = 1;
            [Children] = {
                Padding = New "UIPadding" {
                    PaddingBottom = UDim.new(0,5);
                    PaddingLeft = UDim.new(0,5);
                    PaddingRight = UDim.new(0,5);
                    PaddingTop = UDim.new(0,5);
                };
        
                Grid = New "UIGridLayout" {
                    CellPadding = UDim2.new(0,5,0,5);
                    CellSize = UDim2.new(0.5,-3,0,25);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                };
        
                Buttons = MainMenus[1]();
            }
        };
        OtherMenus = MainMenus[2]();
    }
};

local Window = Api:CreateWindow({
    Size = Vector2.new(350,250);
    Title = "Admin Panel";
    Buttons = {
        [1] = {
            Text = "<";
            Callback = function()
                for i = 1,#BackCallback,1 do
                    BackCallback[i]()
                    MainMenus[4](true)
                end
            end
        };
    };

},WindowFrame)
Window.SetVis(false)

Api:OnEvent("OpenPanel",function()
    Window.SetVis(true)
end)

Window.OnClose:Connect(function()
    icon:deselect()
end)

icon.selected:Connect(function()
    Window.SetVis(true)
    icon:clearNotices()
end)

icon.deselected:Connect(function()
    Window.SetVis(false)
end)

Api:OnEvent("RemovePanel",function()
    Window.unmount()
    icon:destroy()
end)
