-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))

Api:SubscribeBroadcast("AdminChat",function()
    print("Subscribed")
end)

return true