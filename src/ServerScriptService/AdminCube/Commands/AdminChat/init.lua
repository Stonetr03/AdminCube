-- Admin Cube

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local ChatService = game:GetService("Chat")
local HttpService = game:GetService("HttpService")

local Messages = {}

Api:AddPanelMenu(script.AdminChatMenu)

Api:OnEvent("AdminChat-Send",function(p,Msg)
    if Api:GetRank(p) >= 2 then
        local FilterMsg = ""
        local s,e = pcall(function()
            FilterMsg = ChatService:FilterStringForBroadcast(Msg,p)
        end)
        if s then
            -- Rich Text Filter
            local LessSplit = string.split(FilterMsg,"<")
			local LessText = ""
			if #LessSplit > 1 then
				for i = 1,#LessSplit,1 do
					if i == #LessSplit then
						LessText = LessText .. LessSplit[i]
					else
						LessText = LessText .. LessSplit[i] .. "&lt;"
					end
				end
			else
				LessText = LessSplit[1]
			end

			local GreaterSplit = string.split(LessText,">")
			local GreaterText = ""
			if #GreaterSplit > 1 then
				for i = 1, #GreaterSplit, 1 do
					if i == #GreaterSplit then
						GreaterText = GreaterText .. GreaterSplit[i]
					else
						GreaterText = GreaterText .. GreaterSplit[i] .. "&gt;"
					end
				end
			else
				GreaterText = GreaterSplit[1]
			end
			local Text = HttpService:JSONEncode({Name = p.Name, Msg = GreaterText})
            Api:BroadcastMessage("AdminChat",Text)
        end
    end
end)

Api:SubscribeBroadcast("AdminChat",function(Encoded)
    local Data = HttpService:JSONDecode(Encoded)
    table.insert(Messages,1,{Name = Data.Name,Msg = Data.Msg})
    -- Clear last message so we dont have 800 messages stored in memory
    if #Messages >= 18 then
        Messages[18] = nil
    end
    Api:Fire("all","AdminChat-Update")
end)

Api:OnInvoke("AdminChat-Get",function(p)
    if Api:GetRank(p) >= 2 then
        return Messages
    end
end)

return true