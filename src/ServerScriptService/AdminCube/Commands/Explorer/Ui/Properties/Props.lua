-- Admin Cube

local HttpService = game:GetService("HttpService")
local Dump = HttpService:JSONDecode( require(script.Parent:WaitForChild("dump")) )

local Module = {
    Enums = {}
}

for _,tbl: {Name: string,Items: table} in pairs(Dump.Enums) do
    Module.Enums[tbl.Name] = {}
    for _,i: {Name: string, Value: number} in pairs(tbl.Items) do
        Module.Enums[tbl.Name][i.Name] = i.Value;
    end
end

export type Category = {
    [string]: { -- Name of Property
        Category: string;
        Name: string;
    }
}

--[[
    Returns a list of Properties for the given Instance

    @param Obj Instance\
    @return table
]]
function Module:GetProperties(Obj: Instance): Category
    local Members = {}

    local ClassToFind = Obj.ClassName
    repeat

        local found = false
        for _,o in pairs(Dump.Classes) do
            if o.Name == ClassToFind then
                found = true
                ClassToFind = o.Superclass

                for _,m in pairs(o.Members) do
                    if m.MemberType == "Property" then
                        local Rep = true
                        if m.Tags then
                            if table.find(m.Tags,"Hidden") or table.find(m.Tags,"Deprecated") or table.find(m.Tags,"NotScriptable") then
                                Rep = false
                            end --  or table.find(m.Tags,"NotReplicated") -- or table.find(m.Tags,"ReadOnly")
                        end
                        if m.Security and m.Security.Write then
                            if m.Security.Write == "PluginSecurity" or m.Security.Write == "RobloxScriptSecurity" or m.Security.Write == "LocalUserSecurity" then
                                Rep = false
                            end
                        end
                        if m.Security and m.Security.Read then
                            if m.Security.Read == "PluginSecurity" or m.Security.Read == "RobloxScriptSecurity" or m.Security.Read == "LocalUserSecurity" then
                                Rep = false
                            end
                        end

                        if Rep then
                            table.insert(Members,m);
                        end
                    end
                end

            end
        end
        if not found then
            -- Possible Infinite Loop
            ClassToFind = "<<<ROOT>>>"
        end

    until ClassToFind == "<<<ROOT>>>"

    -- Sort Members into Categories
    local Cats = {} :: Category
    for _,m in pairs(Members) do
        if not Cats[m.Category] then
            Cats[m.Category] = {}
        end
        if m.Tags then
            m.ValueType.Tags = m.Tags;
        end
        Cats[m.Category][m.Name] = m.ValueType
    end
    return Cats
end

return Module
