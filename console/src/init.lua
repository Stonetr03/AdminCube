-- Admin Cube - Console Loader v3

-- v2 asset version: 13239621226

return function (pName: string)
    local p = game.Players:FindFirstChild(pName)
    if p then
        local RE = Instance.new("RemoteEvent")
        RE.Name = "__AdminCubeConsoleEvent";
        RE.Parent = game:GetService("ReplicatedStorage");

        script:WaitForChild("Packages").Parent = script:WaitForChild("Ui")
        script:WaitForChild("DefaultSettings").Parent = script.Ui
        local Ui = script.Ui:Clone();
        Ui.Parent = p:WaitForChild("PlayerGui");

        RE.OnServerEvent:Connect(function(plr: Player,Load: boolean,Settings: table)
            if plr == p then
                if Load == true then
                    -- Load AdminCube
                    _G.AdminCubeCustomSettings = Settings
                    require(script:WaitForChild("AdminCube"))()
                end
                -- Clean up
                RE:Destroy();
                script.Ui:Destroy();
                Ui:Destroy();
            end
        end)
    else
        warn("[Admin Cube Loader] Player Not Found");
    end
end
