-- Admin Cube - Stonetr03 - Place List

local Fusion = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion")) :: any)
local Api = (require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api")) :: any)
local MarketplaceService = game:GetService("MarketplaceService");

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

export type placeId = number;

local Places = Api:Invoke("Places-get-list") :: {[placeId]: string};
local icons = {} :: {[placeId]: string}
if typeof(Places) ~= "table" then
    Places = {[game.PlaceId] = game.Name};
end
for i: placeId, o: string in pairs(Places) do
    icons[i] = "";
    pcall(function()
        local data = MarketplaceService:GetProductInfo(i);
        if data and data.IconImageAssetId then
            icons[i] = "rbxassetid://" .. data.IconImageAssetId;
        end
    end)
end

-- Search Functions --
local Search = Value()
local SearchText = Value("");
function CheckVisibility(tags: {string}): boolean
    local txt = tostring(SearchText:get()):lower():gsub("^%s+", ""):gsub("%s+$", "");
    if txt.len == 0 then
        return true;
    end
    for _,str in pairs(tags) do
        if string.find(tostring(str):lower(),txt) then
            return true;
        end
    end

    return false;
end
function ResetSearch()
    local box = Search:get();
    if box then
        box.Text = "";
    end
end

-- Ui --
local Frame = New "Frame" {
    BackgroundTransparency = 1;
    Size = UDim2.new(1,0,1,0);
    [Children] = {
        New "TextBox" {
            BackgroundColor3 = Api.Style.ButtonColor;
            BackgroundTransparency = Api.Style.ButtonTransparency;
            FontFace = Api.Style.Font;
            PlaceholderText = "Search";
            Size = UDim2.new(1,0,0,25);
            Text = "";
            TextColor3 = Api.Style.TextColor;
            PlaceholderColor3 = Api.Style.TextSubColor;
            TextSize = 18;
            TextWrapped = true;
            [Fusion.Ref] = Search;
            [Fusion.Out "Text"] = SearchText;
        };
        New "ScrollingFrame" {
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            CanvasSize = UDim2.new(0,0,0,0);
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,1,-25);
            Position = UDim2.new(0,0,0,25);
            ScrollBarThickness = 10;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            ScrollBarImageColor3 = Api.Style.TextColor;
            TopImage = "";
            BottomImage = "";
            [Children] = {
                New "UIListLayout" {
                    SortOrder = Enum.SortOrder.Name;
                };
                Fusion.ForPairs(Places,function(i: placeId,o: string)
                    local hover = Value(false);
                    return i, New "TextButton" {
                        BackgroundColor3 = Api.Style.ButtonColor;
                        BackgroundTransparency = Computed(function()
                            return hover:get() and Api.Style.ButtonTransparency:get() or 1;
                        end);
                        Text = "";
                        Size = UDim2.new(1,0,0,0);
                        AutomaticSize = Enum.AutomaticSize.Y;
                        Visible = Computed(function()
                            return CheckVisibility({tostring(i),o});
                        end);
                        [Children] = {
                            New "ImageLabel" {
                                BackgroundTransparency = 1;
                                Image = icons[i];
                                Position = UDim2.new(0,1,0,1);
                                Size = UDim2.new(0,24,0,24);
                            };
                            New "TextLabel" {
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundTransparency = 1;
                                FontFace = Api.Style.Font;
                                Position = UDim2.new(0,27,0,0);
                                RichText = true;
                                Size = UDim2.new(1,-28,0,25);
                                Text = `{o}  <font color="#{Api.Style.TextSubColor:get():ToHex():upper()}">{i}</font>`;
                                TextColor3 = Api.Style.TextColor;
                                TextSize = 18;
                                TextWrapped = true;
                                TextXAlignment = Enum.TextXAlignment.Left;
                            }
                        };
                        [Fusion.Cleanup] = hover;
                        [Event "MouseEnter"] = function()
                            hover:set(true);
                        end;
                        [Event "MouseLeave"] = function()
                            hover:set(false);
                        end;
                        [Event "MouseButton1Up"] = function()
                            ResetSearch();
                            Api:PromptCommandRunner("place",`3;*[players];*[number:PlaceId:{i}]`);
                        end;
                    }
                end,Fusion.cleanup);
            }
        }
    }
}

-- Window --
local Window = Api:CreateWindow({
    Size = Vector2.new(250,300);
    Title = "Places";
    Position = UDim2.new(0.5,-125,0.5,-150);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(150,150);
},Frame)
Window.SetVis(true)

Window.OnClose:Connect(function()
    Window.unmount()
    -- This delays the script from being deleted if a prompt is open
    -- If the script is deleted while prompt is open, the prompt freezes and cannot continue.
    if Api.PromptOpen then
        repeat
        task.wait();
        until not Api.PromptOpen;
    end
    script:Destroy()
end)
