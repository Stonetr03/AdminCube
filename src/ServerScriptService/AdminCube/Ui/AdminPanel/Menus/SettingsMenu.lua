-- Admin Cube - Settings Menu

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local SetVis

function MenuBtn(props)
    return New "TextButton" {
        Name = "Settings";
        Text = "Settings";
        LayoutOrder = 2;
        Visible = props.Vis;
        BackgroundTransparency = Api.Style.ButtonTransparency;
        Size = UDim2.new(0.5,-10,0,25);
        BorderSizePixel = 0;
        BackgroundColor3 = Api.Style.ButtonColor;
        TextColor3 = Api.Style.TextColor;
		TextSize = 8;
        Font = Enum.Font.Legacy;
        [Event "MouseButton1Up"] = function()
            SetVis(true)
            props.SetVis(false)
        end
    }
end

function BackCallBack()
    SetVis(false)
end

local Visible = Value(false)
local ThemeBtnText = Value(Api.Settings.CurrentTheme);

Api:ThemeUpdateEvent(function()
    ThemeBtnText:set(Api.Settings.CurrentTheme)
end)

SetVis = function(Vis)
    Visible:set(Vis)
end

function Menu()
	return New "Frame" {
		Name = "Settings";
		BackgroundColor3 = Api.Style.Background;
		BorderSizePixel = 0;
		Size = UDim2.new(1,0,1,0);
		Visible = Visible;
		ZIndex = 5;
		[Children] = {
			UiListLayout = New "UIListLayout" {
				Padding = UDim.new(0,5);
			};

			UiPadding = New "UIPadding" {
				PaddingTop = UDim.new(0,5);
				PaddingBottom = UDim.new(0,5);
				PaddingLeft = UDim.new(0,5);
				PaddingRight = UDim.new(0,5);
			};

			-- Theme button
			ThemeButton = New "TextButton" {
				ZIndex = 10;
				BackgroundColor3 = Api.Style.ButtonColor;
				BackgroundTransparency = Api.Style.ButtonTransparency;
				TextColor3 = Api.Style.TextColor;
				Size = UDim2.new(1,0,0,25);
				Text = Computed(function()
					return "Theme : " .. tostring(ThemeBtnText:get())
				end);
				TextSize = 8;
        		Font = Enum.Font.Legacy;

				[Event "MouseButton1Up"] = function()
					Api:UpdateTheme()
				end
			};
		}
	}
end

return {MenuBtn,Menu,BackCallBack}
