-- Stonetr03

function Create(InstanceName,Parent,Properties)
	local Object = Instance.new(InstanceName)
	Object.Parent = Parent

	if typeof(Properties) == "table" then
		for o,i in pairs(Properties) do
			Object[o] = i
		end
	end

	return Object
end

return Create
