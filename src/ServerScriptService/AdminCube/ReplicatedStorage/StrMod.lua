-- String Module - Created by Stonetr03, GPLv3 License, Source on Github.

local Numbers = {"1","2","3","4","5","6","7","8","9","0"}
local ValidChar = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"," "}

local Module = {}

local function RemoveNumbers(Input)
	for i = 1,#ValidChar,1 do
		if string.lower(Input) == ValidChar[i] then
			-- Valid Character
			return Input
		end
	end
	-- Not Valid Character
	return ""
end

function Module:RemoveNumbers(Input)
	if typeof(Input) == "string" then
		local Split = string.split(Input,"")
		local NewString = ""
		for i = 1,#Split,1 do
			local AddString = RemoveNumbers(Split[i])
			NewString = NewString .. AddString
		end
		return NewString
	else
		warn("Given Value is not string, Returning Empty String")
		return ""
	end
end

local function RemoveLetters(Input)
	for i = 1,#Numbers,1 do
		if Input == Numbers[i] then
			-- Is a Number
			return Input
		end
	end
	-- Not a Number
	return ""
end

function Module:RemoveLetters(Input)
	if typeof(Input) == "number" then
		return Input
	elseif typeof(Input) == "string" then
		local Split = string.split(Input,"")
		local NewString = ""
		for i = 1,#Split,1 do
			local AddString = RemoveLetters(Split[i])
			NewString = NewString .. tostring(AddString)
		end
		local NumberString = tonumber(NewString)
		return NumberString
	else
		warn("Given Value is not string or number, Returning Empty String")
		return 0
	end
end

local function RemoveSymbols(Text)
	for n = 1,#Numbers,1 do
		if Text == Numbers[n] then
			-- Valid Character
			return Text
		end
	end
	for c = 1,#ValidChar,1 do
		if string.lower(Text) == ValidChar[c] then
			-- Valid Character
			return Text
		end
	end
	-- Not Valid Character
	return ""
end

function Module:RemoveSymbols(Input)
	if typeof(Input) == "number" or typeof(Input) == "string" then
		local Split = string.split(Input,"")
		local NewString = ""
		for i = 1,#Split,1 do
			local AddString = RemoveSymbols(Split[i])
			NewString = NewString .. AddString
		end
		return NewString
	else
		warn("Given Value is not string or number, Returning Empty String")
		return ""
	end
end

function Module:RemoveSpaces(Input)
	if typeof(Input) == "string" then
		local Split = string.split(Input,"")
		local NewString = ""
		for i = 1,#Split,1 do
			if Split[i] ~= " " then
				NewString = NewString .. Split[i]
			end
		end
		return NewString
	else
		warn("Given Value is not string, Returning Empty String")
		return ""
	end
end

return Module
