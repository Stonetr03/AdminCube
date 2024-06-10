-- Admin Cube

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local Reflection = Api:Invoke("CubeExplorer","Reflection")
if typeof(Reflection) ~= "table" or not Reflection.Order or not Reflection.Max then
    Reflection = {Order = {}, Max = 0}
end

local Order = Reflection.Order
local Max = Reflection.Max

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
