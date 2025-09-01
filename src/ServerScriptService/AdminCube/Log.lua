-- Admin Cube - Log

local Create = require(script.Parent:WaitForChild("CreateModule"))

local Module = {}
local Log = {}
local Folder

function Module:init(f: Folder)
    if f:IsA("Folder") then
        Folder = f
    end
end

function Module:log(Type: "Command" | "CommandBlock" | "Warn" | "Error" | "Info", p: Player?, Text: string)
    if Folder then
        table.insert(Log,{
            Type = Type;
            Player = p;
            Text = Text;
        })
        local NewLog = Create("Folder",Folder,{Name = os.time()})
        Create("ObjectValue",NewLog,{Name = "Player", Value = p})
        Create("StringValue",NewLog,{Name = "Text",Value = Text})
        Create("StringValue",NewLog,{Name = "Type",Value = Type})
    end
end

return Module
