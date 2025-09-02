-- Admin Cube - Stonetr03

local AssetService = game:GetService("AssetService");
local TeleportService = game:GetService("TeleportService");

local Api = require(script.Parent.Parent:WaitForChild("Api"))

local placeList: {[number]: string} = {};
local cache = 0;
function GetPlaces(): {[number]: string}
    if cache < os.time() then
        local pages: StandardPages = AssetService:GetGamePlacesAsync();
        placeList = {};
        cache = os.time() + 5*60;
        while true do
            for _,p: {Name: string, PlaceId: number} in pages:GetCurrentPage() do
                placeList[p.PlaceId] = p.Name;
            end
            if pages.IsFinished then
                break;
            end
            pages:AdvanceToNextPageAsync();
        end
    end
    return placeList;
end

Api:RegisterCommand("place","Teleports a player to another place.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 3 then
            local Targets = Api:GetPlayer(Args[1],p);
            local PlaceId = tonumber(Args[2])
            if Targets and #Targets > 0 then
                if PlaceId then
                    -- Placeid was given
                    local s,e = pcall(function()
                        for _,p in pairs(Targets) do
                            Api:Notification(p,false,"Teleporting...");
                        end
                        TeleportService:TeleportAsync(PlaceId,Targets);
                    end)
                    if not s then
                        Api:Notification(p, false, `There was an error teleporting to place {PlaceId}, {e}`);
                    end
                elseif #Args >= 2 then
                    local places = GetPlaces();
                    local placeName = "";
                    for i = 2,#Args,1 do
                        if i > 2 then
                            placeName = placeName .. " ";
                        end
                        placeName = placeName .. Args[i];
                    end
                    -- Check
                    local f = false;
                    for id,nm in pairs(places) do
                        if nm == placeName then
                            -- Found place name;
                            f = true;
                            local s,e = pcall(function()
                                for _,p in pairs(Targets) do
                                    Api:Notification(p,false,"Teleporting...");
                                end
                                TeleportService:TeleportAsync(id,Targets);
                            end)
                            if not s then
                                Api:Notification(p, false, `There was an error teleporting to place "{nm}": {id}, {e}`);
                            end
                            break;
                        end
                    end
                    if not f then
                        Api:Notification(p, false, `Unable to find place "{placeName}"`);
                    end
                else
                    Api:Notification(p, false, "Invalid placeId");
                end
            else
                Api:Notification(p, false, "Invalid targets");
            end
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end,"3;*[players];*[number:PlaceId]")

Api:RegisterCommand("places","Opens the place list window.",function(p)
    if Api:GetRank(p) >= 3 then
        local s,e = pcall(function()
            script.places:Clone().Parent = p.PlayerGui:FindFirstChild("__AdminCube_Main")
        end)
        if not s then
            warn(e)
        end
    else
        Api:InvalidPermissionsNotification(p);
    end
end,"3")

Api:OnInvoke("Places-get-list", function(p: Player)
    if Api:GetRank(p) >= 3 then
        return GetPlaces();
    end
    return {}
end)

return true;
