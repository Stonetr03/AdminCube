-- Admin Cube

local ReflectionMetaData: string = require(script.Parent:WaitForChild("reflection"))

local Order = {}
local Max = 0
for m in string.gmatch(ReflectionMetaData,"<Properties>(.-)</Properties>") do
    local Prop = string.match(m,'<string name="Name">(.-)</string>')
    local Sort = string.match(m,'<string name="ExplorerOrder">(.-)</string>')
    if typeof(Prop) == "string" and tonumber(Sort) then
        Order[Prop] = tonumber(Sort)
        if tonumber(Sort) > Max then
            Max = tonumber(Sort)
        end
    end
end

local Module = {
    Max = (Max+1)*1000
}

function Module:SortTable(tbl: {[number]: Instance}): {[Instance]: number}
    -- Break tbl into different classes
    local Classes = {} :: {[string]: {[number]: Instance}} -- Instances sorted by ClassName
    for _,o in pairs(tbl) do
        if not Classes[o.ClassName] then Classes[o.ClassName] = {} end
        table.insert(Classes[o.ClassName],o);
    end
    -- Sort Classes Table
    for _,t in pairs(Classes) do
        table.sort(t,function(a,b)
            return a.Name < b.Name;
        end)
    end
    local sorted = {}
    for cName,t in pairs(Classes) do
        local LayoutOrder = (if Order[cName] then Order[cName] else Max+1) * 1000
        for i,o in pairs(t) do
            sorted[o] = LayoutOrder+i;
        end
    end
    return sorted
end

return Module
