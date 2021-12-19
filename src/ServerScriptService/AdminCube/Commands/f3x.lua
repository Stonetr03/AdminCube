-- AdminCube

local InsertService = game:GetService("InsertService")

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:RegisterCommand("f3x","Building Tools.",function(p,Args)
    local s,e = pcall(function()
        if Api:GetRank(p) >= 4 then
            print("BUILDING TOOLS")
            local Target = Api:GetPlayer(Args[1],p)
            local Model = InsertService:LoadAsset(142785488)
            print(Model)
            local Tool = Model:FindFirstChildOfClass("Tool")
            if Tool then
                Tool.Parent = Target.Backpack
            end
            Model:Destroy()
        else
            -- Invalid Rank Notification
            Api:InvalidPermissionsNotification(p)
        end
    end)
    if not s then
        warn(e)
    end

end)

return true;