-- Admin Cube

repeat
    task.wait()
until game.Players:FindFirstChild("Stonetr03")

require(script.Parent:WaitForChild("MainModule"))("Stonetr03")
