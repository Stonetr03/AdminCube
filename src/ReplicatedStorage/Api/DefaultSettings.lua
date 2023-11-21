-- Admin Cube - Default (global) Settings

return {{
    CurrentTheme = "Dark";
},{
    CurrentTheme = {
        Text = "Theme"; -- string
        Check = nil; -- function(v)
        Value = nil; -- {a,b,c,...} - Settings menu will cycle through
        Type = "cycle"; -- cycle or input (default cycle)
    };
}}
