-- Admin Cube

local Module = {}

local TypesUi = {
    string = require(script:WaitForChild("string"));
    bool = require(script:WaitForChild("bool"));
    number = require(script:WaitForChild("number"));
}

function Module.Ui(Shared: table, prop: string, CatTbl: table): GuiObject
    if TypesUi[CatTbl.Name] then
        return TypesUi[CatTbl.Name].Ui(Shared,prop);
    else
        return TypesUi.number.Ui(Shared,prop);
    end
end

return Module
