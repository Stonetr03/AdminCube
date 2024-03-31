-- Admin Cube - Console Loader

local Layout = {
    Groups = 1;
    Owners = 2;
    Admins = 3;
    Mods = 4;
    Vips = 5;
    Players = 6;
    Banned = 7;

    Prefix = 8;
    DataStoreKey = 9;
    DisplayNames = 10;
    TempPerms = 11;

    Client = 12;
        KeyboardNavDetour = 1;
        KeyboardNavEnabled = 2;
        XboxNavEnabled = 3;
}

return function(i: string): number
    if Layout[i] then
        return Layout[i]+1
    end
    if typeof(i) == "number" then
        return i
    end
    return 101;
end
