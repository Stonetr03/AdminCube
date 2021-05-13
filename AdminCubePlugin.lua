-- Admin Cube - Stonetr03 Studios - Plugin allows Better Chat to work with Admin Cube

API = nil;
return function()
	shared.better_chat.API = API;
	
	local RSFolder = game.ReplicatedStorage:WaitForChild("AdminCube")
	local Event = Instance.new("BindableEvent",RSFolder)
	Event.Name = "BetterChatEvent"
	
	API.Chatted:Connect(function(p,d)
		Event:Fire(p,d.unfilteredMessage)
	end)
end
