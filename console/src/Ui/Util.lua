-- Admin Cube - Console Loader

local Module = {}

function Module.cloneTable(t: table): table
    local NewTab = {}
    for i,v in pairs(t) do
        if typeof(v) == "table" then
            NewTab[i] = Module.cloneTable(v)
        else
            NewTab[i] = v
        end
    end
    return NewTab
end

function Module.length(t: table): number
    local c = 0;
    for _,_ in pairs(t) do
        c+=1;
    end
    return c;
end

return Module
