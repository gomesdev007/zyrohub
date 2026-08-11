local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Cores Dark Purple
local BG_COLOR = Color3.fromRGB(12, 8, 20)
local PURPLE_NEON = Color3.fromRGB(130, 40, 255)
local OFF_COLOR = Color3.fromRGB(60, 60, 60)

-- GUI Wide
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GomesSilentReal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 75)
MainFrame.Position = UDim2.new(1, -280, 0, 30)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(18, 12, 30)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Botão de Minimizar / Abrir
local isMinimized = false
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -35, 0, 5)
MinButton.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 20
MinButton.Parent = MainFrame

MinButton.MouseButton1Down:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 40, 0, 40) or UDim2.new(0, 260, 0, 75)
    MinButton.Text = isMinimized and "+" or "-"
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = targetSize}):Play()
end)

-- Botão de Toggle
local ToggleBG = Instance.new("TextButton")
ToggleBG.Size = UDim2.new(0, 55, 0, 28)
ToggleBG.Position = UDim2.new(0, 20, 0.5, -14)
ToggleBG.BackgroundColor3 = OFF_COLOR
ToggleBG.Text = ""
ToggleBG.Parent = MainFrame

local ToggleBall = Instance.new("Frame")
ToggleBall.Size = UDim2.new(0, 22, 0, 22)
ToggleBall.Position = UDim2.new(0, 3, 0.5, -11)
ToggleBall.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
ToggleBall.Parent = ToggleBG

-- LÓGICA DE SILENT AIM (INALTERADA)
local silentAimEnabled = false
local FOV_RADIUS = 340 
local PredictionFactor = 0.22 
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")

local function getClosestEnemy()
    local closestPart = nil
    local shortestDistance = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                
                local screenPos = Camera:WorldToViewportPoint(char.Head.Position)
                local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                
                if distFromCenter <= FOV_RADIUS then
                    if distFromCenter < shortestDistance then
                        shortestDistance = distFromCenter
                        closestPart = char.Head
                    end
                end
            end
        end
    end
    return closestPart
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not silentAimEnabled or processed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        local targetPart = getClosestEnemy()
        
        if targetPart then
            local targetPos = targetPart.Position
            local targetChar = targetPart.Parent
            
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                targetPos = targetPos + (targetChar.HumanoidRootPart.Velocity * PredictionFactor)
            end
            
            pcall(function()
                ShootRemote:FireServer(
                    myRoot.Position,
                    targetPos,
                    targetPart,
                    targetPos
                )
            end)
        end
    end
end)

ToggleBG.MouseButton1Down:Connect(function()
    silentAimEnabled = not silentAimEnabled
    local targetPos = silentAimEnabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    local color = silentAimEnabled and PURPLE_NEON or OFF_COLOR
    TweenService:Create(ToggleBall, TweenInfo.new(0.2), {Position = targetPos}):Play()
    TweenService:Create(ToggleBG, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
end)
