-- Admin Cube - Server Api

local DataStore = require(script.Parent:WaitForChild("DataStore"))
local Settings = require(script.Parent:WaitForChild("Settings"))
local Log = require(script.Parent:WaitForChild("Log"))

local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local CreateModule = require(script.Parent.CreateModule)

local Module = {}
local Commands = {} :: { -- List of commands that can be called from clients
    [string]: {
        Name: string,
        Desc: string,
        Run: (p: Player, Args: {string}) -> (),
        Args: string
    }
}
local CommandOrder = {} :: { -- Order that commands have been loaded, Used to call overwritten commands.
    [number]: {
        Name: string,
        Desc: string,
        Run: (p: Player, Args: {string}) -> (),
        Args: string
    }
}

local Aliases = {} :: {
    [string]: string; -- Alias: Command
}
local Hooks = {} :: {
    [string]: {
        pre: {
            (p: Player, args: string) -> (boolean)
        },
        post: {
            (p: Player, args: string) -> (boolean)
        }
    }
}

local RS = script.Parent.ReplicatedStorage
RS.Name = "AdminCube"
RS.Parent = game:GetService("ReplicatedStorage")
CreateModule("RemoteEvent",RS,{Name = "ACEvent"})
CreateModule("RemoteFunction",RS,{Name = "ACFunc"})
CreateModule("StringValue",RS,{Name = "ClientSettings",Value = HttpService:JSONEncode(Settings.Client)})

local LocalServer = false

--[[
    Returns a player's rank.

    @param p Player - Player to get rank.
    @return number - Rank of player.
]]
function Module:GetRank(p: Player): number
    local Data = DataStore.ServerData[p.UserId]
    return Data.Rank
end

--[[
    Gets a list of players from a given string.

    @param Text string - String to find players in.
    @param p Player - Player who sent the message.
    @return {Player} - Array of players. **Note**: It is possible that no players are returned.
]]
function Module:GetPlayer(Text: string,p: Player): {Player} -- Name Requested to Find, Player who Sent
    if Text == "" or Text == nil then
        Text = string.lower(p.Name)
    end
    -- Parse Players
    local SplitTexts = ".,;:-/"
    local Parse = {Text}
    for i = 1,string.len(SplitTexts),1 do
        local SplitSep = string.sub(SplitTexts,i,i)
        local New = {}
        for _,o in pairs(Parse) do
            local split = string.split(o,SplitSep)
            for _,a in pairs(split) do
                table.insert(New,a)
            end
        end
        Parse = New
    end
    -- Table
    local Plrs = {}
    for _,Name in pairs(Parse) do
        if Name == "me" then
            if table.find(Plrs,p) == nil then
                table.insert(Plrs,p)
            end
        elseif Name == "all" or Name == "everyone" then
            for _,Player in pairs(game.Players:GetPlayers()) do
                if table.find(Plrs,Player) == nil then
                    table.insert(Plrs,Player)
                end
            end
        else
            -- Match UserNames
            for _,o in pairs(game.Players:GetPlayers()) do
                if string.lower(o.Name) == Name then
                    if table.find(Plrs,o) == nil then
                        table.insert(Plrs,o)
                        break
                    end
                end
            end
            -- Match Display Names
            if Settings.DisplayNames == true then
                for _,o in pairs(game.Players:GetPlayers()) do
                    if string.lower(o.DisplayName) == Name then
                        if table.find(Plrs,o) == nil then
                            table.insert(Plrs,o)
                            break
                        end
                    end
                end
            end

            -- Match Username again
            for _,o in pairs(game.Players:GetPlayers()) do
                if string.find(string.lower(o.Name),Name) ~= nil then
                    if table.find(Plrs,o) == nil then
                        table.insert(Plrs,o)
                        break
                    end
                end
            end

            -- Match Display name again
            if Settings.DisplayNames == true then
                for _,o in pairs(game.Players:GetPlayers()) do
                    if string.find(string.lower(o.Name),Name) ~= nil then
                        if table.find(Plrs,o) == nil then
                            table.insert(Plrs,o)
                            break
                        end
                    end
                end
            end

        end
    end
    return Plrs
end

--[[
    Registers a Command with the Command Runner.

    __**Command Argument String**__

    The command argument string allows the ui to prompt for the command to be ran.\
    Parameters are not checked for valididy before being passed to the callback function.
    
    The Argument String is separated by `;`.\
    The Argument String format is `Rank Numerical Requirement ; Command Parameters...`\
    Valid parameters types include `player`, `players`, `string`, and `number`.\
    Required fields are denoted by `*` before the brackets.\
    Custom field names can be included by following the type by `:` and the name of the field.\
    Example from Speed Command: `"2;*[players];[number:Speed]"`

    @param Name string - Name of the command.
    @param Desc string - Description of the command.
    @param Run (p: Player, Args: {string}) -> () - Callback function.
    @param Arg string - Command Argument String, see above.
    @param Alias {string} - Array of strings that are command aliases.
]]
function Module:RegisterCommand(Name: string, Desc: string, Run: (p: Player, Args: {string}) -> (), Arg: string, Alias: {string}?)
    if typeof(Commands[Name]) == "table" then
        Log:log("Info", nil, `Command {Name} has been overwritten.`);
    end
    Commands[Name] = {
        Name = Name;
        Desc = Desc;
        Run = Run;
        Args = Arg;
    }
    table.insert(CommandOrder,Commands[Name])
    if typeof(Alias) == "table" then
        for _,o in pairs(Alias) do
            Aliases[o] = Name
        end
    end
end

--[[
    Calls a command. Used to call commands that have been overwritten.

    @param Command string - Name of the command.
    @param p Player - Player Argument to be passed to command.
    @param args {string} - Array of strings to be passed to command.
    @param n number? - Optional (Default = 1), Occurance number, used if command has been overwritten multiple times.
    @return boolean - Successfully called a command.
]]
function Module:CallOriginalCommand(Command: string, p: Player, args: {string}, n: number?): boolean
    local c: number = (n :: number);
    if typeof(n) ~= "number" or n <= 0 then
        c = 1;
    end
    for _,cmd in pairs(CommandOrder) do
        if cmd.Name == Command then
            c = c - 1;

            if c == 0 then
                local str = `{Command} {table.concat(args," ")}`

                if typeof(Hooks[Command]) == "table" and typeof(Hooks[Command].pre) == "table" then
                    for _,f in pairs(Hooks[Command].pre) do
                        if f(p, args) == false then
                            Log:log("CommandBlock",p,"Blocked Original " .. str)
                            return false;
                        end
                    end
                end

                cmd.Run(p, args)
                Log:log("Command",p,"Original: " .. str)

                if typeof(Hooks[Command]) == "table" and typeof(Hooks[Command].post) == "table" then
                    for _,f in pairs(Hooks[Command].post) do
                        f(p, args)
                    end
                end

                return true;
            end
        end
    end
    return false
end

--[[
    Registers a PreHook.

    @param Command string
    @param Callback (p: Player, args: {string}) -> (boolean) - This must return a boolean value, true to continue with the command, or false to stop the command from running.
]]
function Module:PreHook(Command: string, Callback: (p: Player, args: {string}) -> (boolean))
    if typeof(Hooks[Command]) ~= "table" then
        Hooks[Command] = {
            pre = {},
            post = {}
        }
    end
    table.insert(Hooks[Command].pre,Callback)
end

--[[
    Registers a PostHook.

    @param Command string
    @param Callback (p: Player, args: {string}) -> ()
]]
function Module:PostHook(Command: string, Callback: (p: Player, args: {string}) -> ())
    if typeof(Hooks[Command]) ~= "table" then
        Hooks[Command] = {
            pre = {},
            post = {}
        }
    end
    table.insert(Hooks[Command].post,Callback)
end

--[[
    Returns the commands and aliases registered with the command runner.

    @return Command List - {[string]: {Name: string, Desc: string, Run: (p: Player, Args: {string}) -> (), Args: string}}
    @return Alias List - {[string]: string} - Alias: Command
    @return Hooks List - {[string]: {pre: {(p: Player, args: string) -> (boolean)}, post: {(p: Player, args: string) -> (boolean)}}}
]]
function Module:GetCommands(): ({[string]: {Name: string, Desc: string, Run: (p: Player, Args: {string}) -> (), Args: string}}, {[string]: string}, {[string]: {pre: {(p: Player, args: string) -> (boolean)}, post: {(p: Player, args: string) -> (boolean)}}})
    return Commands,Aliases, Hooks
end

--[[
    Fires an event to a client, Sending remote event.

    @param p Player, {Players}, or "all" - Player to send event to.
    @param Key string - SendReceive Key
    @param ... parameters to send in the event.
]]
function Module:Fire(p: Player | {Player} | "all", Key: string, ...: any)
    if p == "all" then
        game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireAllClients(Key,...)
    elseif typeof(p) == "table" then
        for _,plr in pairs(p) do
            game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireClient(plr,Key,...)
        end
    else
        game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent:FireClient(p,Key,...)
    end
end

--[[
    Receives an event from a client, Receiving remote event.

    @param Key string - SendReceive Key
    @param Callback (p: Player, ...) -> () - Callback function
    @return {Disconnect: (self: any) -> ()} - Disconnect function
]]
function Module:OnEvent(Key: string, Callback: (p: Player, any) -> ()): {Disconnect: (self: any) -> ()}
    local con = game.ReplicatedStorage:WaitForChild("AdminCube").ACEvent.OnServerEvent:Connect(function(p,CallingKey,...)
        if CallingKey == Key then
            Callback(p,...)
        end
    end)
    local ReturnTab = {}
    function ReturnTab:Disconnect()
        con:Disconnect()
    end
    return ReturnTab
end

--[[
    Invokes a client, Sending remote function.

    @param p Player
    @param Key string - SendReceive Key
    @param ... parameters to send to client.
]]
function Module:Invoke(p: Player, Key: string, ...: any)
    return game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc:InvokeClient(p,Key,...)
end

local RemoteFunctions = {}
--[[
    Receives an invoke from a client, Receiving remote function.

    @parma Key string - SendReceive Key
    @param Callback (p: Player, any) -> (any)
    @return {Disconnect: (self: any) -> ()} - Disconnect function
]]
function Module:OnInvoke(Key: string, Callback: (p: Player, any) -> (any)): {Disconnect: (self: any) -> ()}
    local Tab = {
        Key = Key;
        Callback = Callback;
    }
    table.insert(RemoteFunctions,Tab)
    local ReturnTab = {}
    function ReturnTab:Disconnect()
        if table.find(RemoteFunctions,Tab) then
            table.remove(RemoteFunctions,table.find(RemoteFunctions,Tab))
        end
    end
    return ReturnTab
end
game.ReplicatedStorage:WaitForChild("AdminCube").ACFunc.OnServerInvoke = function(p,CallingKey,...)
    for _,o in pairs(RemoteFunctions) do
        if o.Key == CallingKey then
            return o.Callback(p,...)
        end
    end
    return
end

--[[
    Adds a AdminPanel Menu.

    @param Menu Instance
]]
function Module:AddPanelMenu(Menu: Instance)
    Menu.Parent = script.Parent.Ui.AdminPanel.Menus
end

local BroadcastCallbacks = {}

--[[
    Subscribes to a message broadcast

    @param Key string - SendReceive key
    @param Callback (any) -> ()
]]
function Module:SubscribeBroadcast(Key: string, Callback: (any) -> ())
    if BroadcastCallbacks[Key] == nil then
        BroadcastCallbacks[Key] = {}
    end
    BroadcastCallbacks[Key][#BroadcastCallbacks[Key] + 1] = Callback

end

--[[
    Broadcasts a message to other servers.

    @param Key string - SendReceive key
    @param Message any
]]
function Module:BroadcastMessage(Key: string, Message: any)
    if LocalServer == true then
        for i = 1,#BroadcastCallbacks[Key],1 do
            BroadcastCallbacks[Key][i](Message)
        end
    else
        MessagingService:PublishAsync("AdminCube",{Key = Key; Msg = Message;})
    end
end

--[[
    Creates a folder in ReplicatedStorage

    @param FolderName string
    @return Folder | nil - Returns nil if a instance exists with the same name, and isn't a folder.
]]
function Module:CreateRSFolder(FolderName: string): Folder?
    local Check = RS:FindFirstChild(FolderName)
    if Check then
        if Check:IsA("Folder") then
            return Check
        else
            warn("REQUESTED FOLDER ALREADY EXISTS, AND IS NOT A FOLDER")
            return nil
        end
    else
        return CreateModule("Folder",RS,{Name = FolderName})
    end
end

Log:init((Module:CreateRSFolder("Log") :: Folder))

--[[
    Sends a notification to a player

    @param p Player
    @param Image string | boolean, true for player's headshot, false for no image, or string
    @param Text string - Text to show in notification
    @param ButtonText string? - Text to show on notification button
    @param ButtonFunc () -> ()? - Callback function when button is pressed
    @param Time number? - Time to display notification, maximum of 119 seconds.
]]
function Module:Notification(p: Player, Image: string | boolean, Text: string, ButtonText: string?, ButtonFunc: (p: Player) -> ()?, Time: number?)
    local Button = {}
    if typeof(Time) == "number" then
        if Time > 119 then
            Time = 119
        end
        if Time < 0 then
            Time = 119
        end
    end
    if typeof(ButtonText) == "string" and typeof(ButtonFunc) == "function" then
        local UUID = HttpService:GenerateGUID(false)
        Button = {ButtonText,UUID}
        local con
        con = Module:OnEvent("_NotificationCallback",function(plr,Id)
            if typeof(Id) == "string" and UUID == Id and p == plr then
                ButtonFunc(p)
                con:Disconnect()
            end
        end)
        task.delay(120,function()
            if con then
                con:Disconnect()
            end
        end)
    end
    Module:Fire(p,"Notification",{Image = Image,Text = Text,Button = Button,Time = Time})
    return true
end

--[[
    Sends a invalid permissions notification to the given player.

    @param p Player
]]
function Module:InvalidPermissionsNotification(p: Player)
    Module:Notification(p,false,"Invalid Permissions")
    return true
end

-- Prompts
local OpenPrompts = {}
function Module:ShowPrompt(p: Player, Prompts: {}, Response: ({}) -> ()): boolean
    if OpenPrompts[p] ~= nil then
        -- Another prompt is open
        return false
    end
    OpenPrompts[p] = {Prompts,Response}

    Module:Fire(p,"Prompts",Prompts)
    return true
end
Module:OnEvent("Prompts",function(p,Results)
    if OpenPrompts[p] ~= nil then
        -- Prompt is open
        task.spawn(function()
            OpenPrompts[p][2](Results)
        end)
        OpenPrompts[p] = nil
    end
end)

Module:OnInvoke("GetCommands",function(p)
    if Module:GetRank(p) >= 2 then
        local Cmd,Alias = Module:GetCommands()
        local Rank = Module:GetRank(p)
        return Cmd,Alias,Rank
    end
    return {},{},0;
end)

task.spawn(function()
    local s,_ = pcall(function()
        MessagingService:SubscribeAsync("AdminCube",function(Data)
            for i = 1,#BroadcastCallbacks[Data.Data.Key],1 do
                BroadcastCallbacks[Data.Data.Key][i](Data.Data.Msg)
            end
        end);
    end)

    if s == false then
        LocalServer = true
    end
end)

return Module
