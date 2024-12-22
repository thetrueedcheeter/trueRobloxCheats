-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Player
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables
local aimbotEnabled = false
local target = nil
local buttonSize = UDim2.new(0, 120, 0, 50)

-- GUI Setup
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local toggleButton = Instance.new("TextButton", screenGui)

toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Size = buttonSize
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Aimbot OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = false

-- Recursive search function to find valid targets (including nested folders)
local function getValidTargets()
    local validTargets = {}

    -- Add players (exclude the local player)
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(validTargets, otherPlayer.Character)
        end
    end

    -- Search all models in Workspace (excluding the local player's character)
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") 
            and descendant:FindFirstChild("Humanoid") 
            and descendant:FindFirstChild("HumanoidRootPart") 
            and descendant ~= player.Character then
            table.insert(validTargets, descendant)
        end
    end

    return validTargets
end

-- Find the closest target
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local validTargets = getValidTargets()

    for _, potentialTarget in pairs(validTargets) do
        local humanoidRootPart = potentialTarget:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestTarget = potentialTarget
            end
        end
    end

    return closestTarget
end

-- Draw polygon (simple rectangle for this example)
local function createPolygonOnTarget(targetModel)
    local highlight = Instance.new("BoxHandleAdornment")
    highlight.Adornee = targetModel.HumanoidRootPart
    highlight.Parent = targetModel.HumanoidRootPart
    highlight.Color3 = Color3.new(1, 0, 0)
    highlight.AlwaysOnTop = true
    highlight.ZIndex = 5
    highlight.Size = targetModel.HumanoidRootPart.Size + Vector3.new(0.2, 0.2, 0.2)
    highlight.Name = "AimbotHighlight"

    return highlight
end

-- Toggle Aimbot
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    toggleButton.Text = aimbotEnabled and "Aimbot ON" or "Aimbot OFF"

    if not aimbotEnabled and target then
        if target:FindFirstChild("HumanoidRootPart") and target.HumanoidRootPart:FindFirstChild("AimbotHighlight") then
            target.HumanoidRootPart.AimbotHighlight:Destroy()
        end
        target = nil
    end
end

-- Button Events
toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
end)

toggleButton.MouseLeave:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
end)

toggleButton.MouseButton1Click:Connect(toggleAimbot)

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        target = getClosestTarget()
        if target and target:FindFirstChild("HumanoidRootPart") then
            -- Lock Camera
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, target.HumanoidRootPart.Position)

            -- Draw Polygon
            if not target.HumanoidRootPart:FindFirstChild("AimbotHighlight") then
                createPolygonOnTarget(target)
            end
        end
    end
end)
