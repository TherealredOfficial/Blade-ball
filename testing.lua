local isDebugMode = false
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local player = players.LocalPlayer or players.PlayerAdded:Wait()
local remotes = replicatedStorage:WaitForChild("Remotes", 9e9)
local balls = workspace:WaitForChild("Balls", 9e9)

local function debugPrint(...)
    if isDebugMode then
        warn(...)
    end
end

local function isValidProjectile(ball)
    return typeof(ball) == "Instance" and ball:IsA("BasePart") and ball:IsDescendantOf(balls) and ball:GetAttribute("realBall") == true
end

local function isPlayerTargeted()
    return player.Character and player.Character:FindFirstChild("Highlight")
end

local function performParry()
    remotes:WaitForChild("ParryButtonPress"):Fire()
end

balls.ChildAdded:Connect(function(ball)
    if not isValidProjectile(ball) then
        return
    end
    
    debugPrint("Ball Spawned:", ball)
    
    local oldPosition = ball.Position
    local oldTick = tick()
    
    local function handleBallPositionChange()
        if isPlayerTargeted() then
            local distance = (ball.Position - workspace.CurrentCamera.Focus.Position).Magnitude
            local velocity = (oldPosition - ball.Position).Magnitude
            
            debugPrint("Distance:", distance, "\nVelocity:", velocity, "\nTime:", distance / velocity)
        
            if (distance / velocity) <= 10 then
                performParry()
            end
        end
        
        if (tick() - oldTick >= 1/60) then
            oldTick = tick()
            oldPosition = ball.Position
        end
    end

    ball:GetPropertyChangedSignal("Position"):Connect(handleBallPositionChange)
end)
