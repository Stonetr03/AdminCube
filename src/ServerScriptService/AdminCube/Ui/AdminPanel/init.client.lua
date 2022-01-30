-- Admin Cube

local Roact = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Roact"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

-- Topbar
local TopbarPath = game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Topbar")
local TBCheck = game.ReplicatedStorage:FindFirstChild("TopbarPlusReference")
if TBCheck then
    TopbarPath = TBCheck.Value
end
local Topbar = require(TopbarPath)

local icon = Topbar.new()
icon:setImage("http://www.roblox.com/asset/?id=5010019455") -- 24x24
icon:setName("AdminCubeMainAdminPanel")
icon:setProperty("deselectWhenOtherIconSelected",false)

local MainMenus = require(script.MainMenus)
local BackCallback = MainMenus[3]

local WindowFrame = Roact.Component:extend("AdminPanelWindow")
function WindowFrame:render()
    return Roact.createElement("Frame",{
        Visible = true;
        Position = UDim2.new(0,0,0,0);
        BorderSizePixel = 0;
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,1,0);
    },{
        -- Main Menus Frame
        MainMenu = Roact.createElement("Frame",{
            Size = UDim2.new(1,0,1,0);
            Name = "MainMenu";
            BackgroundTransparency = 1;
        },{
            Padding = Roact.createElement("UIPadding",{
                PaddingBottom = UDim.new(0,5);
                PaddingLeft = UDim.new(0,5);
                PaddingRight = UDim.new(0,5);
                PaddingTop = UDim.new(0,5);
            });
    
            Grid = Roact.createElement("UIGridLayout",{
                CellPadding = UDim2.new(0,5,0,5);
                CellSize = UDim2.new(0.5,-3,0,25);
            });
    
            Buttons = Roact.createElement(MainMenus[1]);
        });
        OtherMenus = Roact.createElement(MainMenus[2]);
    });
end

local Window = Api:CreateWindow({
    SizeX = 350;
    SizeY = 250;
    Title = "Admin Panel";
    Buttons = {
        [1] = {
            Text = "<";
            Callback = function()
                print("Back Clicked")
                for i = 1,#BackCallback,1 do
                    BackCallback[i]()
                    MainMenus[4](true)
                end
            end
        };
    };

},WindowFrame)
