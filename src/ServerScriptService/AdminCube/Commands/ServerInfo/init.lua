-- Admin Cube - Server Stats

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local HttpService = game:GetService("HttpService")
local CreateModule = require(script.Parent.Parent.CreateModule)

Api:AddPanelMenu(script.ServerInfoMenu)

-- Info
local RS = Api:CreateRSFolder("ServerStats")

local Response 
local s,e = pcall(function()
    Response = HttpService:GetAsync("http://ip-api.com/json/?fields=16393&lang=en")
end)
local Tab
if s then
    print("HTTP SUCCESS")
    print(Response)
    Tab = HttpService:JSONDecode(Response)
    if Tab.status == "fail" then
        Tab = {
            country = "Http Error";
            regionName = "Http Error";
        }
    end
else
    print("HTTP ERROR")
    print(e)
    print(Response)
    Tab = {
        country = "Http Error";
        regionName = "Http Error";
    }
end

CreateModule("StringValue",RS,{Name = "Country", Value = Tab.country})
CreateModule("StringValue",RS,{Name = "Region",Value = Tab.regionName})

return true
