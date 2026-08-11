local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CORES
local BG_COLOR = Color3.fromRGB(12, 8, 20)
local PURPLE_NEON = Color3.fromRGB(130, 40, 255)
local OFF_COLOR = Color3.fromRGB(60, 60, 60)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 110)
MainFrame.Position = UDim2.new(1, -270, 0, 30)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(18, 12, 30)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- X FECHAR/ABRIR
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame

local isHidden = false
CloseButton.MouseButton1Click:Connect(function()
    isHidden = not isHidden
    MainFrame.Visible = not isHidden
end)

-- BOTÃO SILENT AIM
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

local SilentAimBtn = Instance.new("TextButton")
SilentAimBtn.Size = UDim2.new(0, 110, 0, 40)
SilentAimBtn.Position = UDim2.new(0, 10, 0, 40)
SilentAimBtn.BackgroundColor3 = OFF_COLOR
SilentAimBtn.Text = "SILENT AIM"
SilentAimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimBtn.Font = Enum.Font.GothamBold
SilentAimBtn.TextSize = 11
SilentAimBtn.BorderSizePixel = 0
SilentAimBtn.Parent = MainFrame

local SilentCorner = Instance.new("UICorner")
SilentCorner.CornerRadius = UDim.new(0, 6)
SilentCorner.Parent = SilentAimBtn

local SilentStroke = Instance.new("UIStroke")
SilentStroke.Color = Color3.fromRGB(18, 12, 30)
SilentStroke.Thickness = 1
SilentStroke.Parent = SilentAimBtn

SilentAimBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        SilentAimBtn.BackgroundColor3 = PURPLE_NEON
    else
        SilentAimBtn.BackgroundColor3 = OFF_COLOR
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not silentAimEnabled or processed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

-- BOTÃO DISPARO AJUSTADO
local function getClosestEnemyPart()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestEnemy = player.Character:FindFirstChild("Head") or player.Character.HumanoidRootPart
                end
            end
        end
    end
    return closestEnemy
end

local DisparoBtn = Instance.new("TextButton")
DisparoBtn.Size = UDim2.new(0, 110, 0, 40)
DisparoBtn.Position = UDim2.new(0, 130, 0, 40)
DisparoBtn.BackgroundColor3 = OFF_COLOR
DisparoBtn.Text = "DISPARO"
DisparoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DisparoBtn.Font = Enum.Font.GothamBold
DisparoBtn.TextSize = 11
DisparoBtn.BorderSizePixel = 0
DisparoBtn.Parent = MainFrame

local DisparoCorner = Instance.new("UICorner")
DisparoCorner.CornerRadius = UDim.new(0, 6)
DisparoCorner.Parent = DisparoBtn

local DisparoStroke = Instance.new("UIStroke")
DisparoStroke.Color = Color3.fromRGB(18, 12, 30)
DisparoStroke.Thickness = 1
DisparoStroke.Parent = DisparoBtn

local disparoEnabled = false

DisparoBtn.MouseButton1Click:Connect(function()
    disparoEnabled = not disparoEnabled
    if disparoEnabled then
        DisparoBtn.BackgroundColor3 = PURPLE_NEON
    else
        DisparoBtn.BackgroundColor3 = OFF_COLOR
    end
end)

-- FUNÇÃO DE DISPARO
local function executarDisparo()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChildOfClass("Tool")
    
    if rootPart and tool then
        local targetPart = getClosestEnemyPart()
        local targetPos = targetPart and targetPart.Position or (rootPart.Position + rootPart.CFrame.LookVector * 50)
        local originPos = rootPart.Position
        
        tool:Activate()
        
        pcall(function()
            ShootRemote:FireServer(
                originPos,
                targetPos,
                targetPart or workspace,
                targetPos
            )
        end)
    end
end

-- LOOP PARA DISPARO CONTÍNUO
game:GetService("RunService").RenderStepped:Connect(function()
    if disparoEnabled then
        executarDisparo()
        wait(0.1)
    end
end)

print("[GOMES HUB] Carregado - X para fechar/abrir")
