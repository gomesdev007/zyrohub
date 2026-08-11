local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CORES E ESTILOS
-- ============================================================
local BG_COLOR = Color3.fromRGB(12, 8, 20)
local PURPLE_NEON = Color3.fromRGB(130, 40, 255)
local OFF_COLOR = Color3.fromRGB(60, 60, 60)
local BUTTON_COLOR = Color3.fromRGB(30, 25, 40)
local STROKE_COLOR = Color3.fromRGB(18, 12, 30)

-- ============================================================
-- GUI PRINCIPAL
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GomesHubCombat"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(1, -300, 0, 30)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = STROKE_COLOR
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 25)
TitleLabel.Position = UDim2.new(0, 10, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GOMES HUB - COMBAT"
TitleLabel.TextColor3 = PURPLE_NEON
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.Parent = MainFrame

-- Botão de Minimizar
local isMinimized = false
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 25)
MinButton.Position = UDim2.new(1, -35, 0, 8)
MinButton.BackgroundColor3 = BUTTON_COLOR
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 18
MinButton.BorderSizePixel = 0
MinButton.Parent = MainFrame

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = STROKE_COLOR
MinStroke.Thickness = 1
MinStroke.Parent = MinButton

MinButton.MouseButton1Down:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 60, 0, 40) or UDim2.new(0, 280, 0, 180)
    MinButton.Text = isMinimized and "+" or "-"
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = targetSize}):Play()
end)

-- Container para Botões
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, -20, 1, -45)
ButtonContainer.Position = UDim2.new(0, 10, 0, 40)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

local function createButton(name, text, layoutOrder)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = OFF_COLOR
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 11
    Button.BorderSizePixel = 0
    Button.LayoutOrder = layoutOrder
    Button.Parent = ButtonContainer
    Button.Name = name
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = STROKE_COLOR
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button
    
    return Button, ButtonStroke
end

-- ============================================================
-- SILENT AIM - BOTÃO COM TOGGLE
-- ============================================================
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

local SilentAimButton, SilentAimStroke = createButton("SilentAim", "SILENT AIM [OFF]", 1)

local function updateSilentAimUI()
    if silentAimEnabled then
        SilentAimButton.BackgroundColor3 = PURPLE_NEON
        SilentAimButton.Text = "SILENT AIM [ON]"
    else
        SilentAimButton.BackgroundColor3 = OFF_COLOR
        SilentAimButton.Text = "SILENT AIM [OFF]"
    end
end

SilentAimButton.MouseButton1Down:Connect(function()
    silentAimEnabled = not silentAimEnabled
    updateSilentAimUI()
end)

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

-- ============================================================
-- DISPARO AJUSTADO - BOTÃO COM CLIQUE
-- ============================================================

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

local DisparoButton, DisparoStroke = createButton("Disparo", "DISPARO ÚNICO", 2)

DisparoButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChildOfClass("Tool")
    
    if rootPart and tool then
        local targetPart = getClosestEnemyPart()
        local targetPos = targetPart and targetPart.Position or (rootPart.Position + rootPart.CFrame.LookVector * 50)
        local originPos = rootPart.Position
        
        task.spawn(function()
            tool:Activate()
        end)
        
        pcall(function()
            ShootRemote:FireServer(
                originPos,
                targetPos,
                targetPart or workspace,
                targetPos
            )
        end)
        
        -- Feedback visual
        DisparoButton.BackgroundColor3 = PURPLE_NEON
        task.wait(0.2)
        DisparoButton.BackgroundColor3 = OFF_COLOR
    end
end)

-- ============================================================
-- AIM KILL - BOTÃO COM MÚLTIPLOS DISPAROS
-- ============================================================

local AimKillButton, AimKillStroke = createButton("AimKill", "AIM KILL", 3)

AimKillButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChildOfClass("Tool")
    
    if rootPart and tool then
        local targetPart = getClosestEnemyPart()
        if not targetPart then return end
        
        local targetPos = targetPart.Position
        local originPos = rootPart.Position
        
        -- 4 disparos em 1 segundo
        for i = 1, 4 do
            task.wait(0.25)
            
            pcall(function()
                ShootRemote:FireServer(
                    originPos,
                    targetPos,
                    targetPart,
                    targetPos
                )
            end)
        end
        
        -- Feedback visual
        AimKillButton.BackgroundColor3 = PURPLE_NEON
        task.wait(0.3)
        AimKillButton.BackgroundColor3 = OFF_COLOR
    end
end)

-- ============================================================
-- NOTIFICAÇÃO DE CARREGAMENTO
-- ============================================================

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "GomesNotif"
NotifGui.ResetOnSpawn = false
NotifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NotifFrame = Instance.new("Frame")
NotifFrame.Size = UDim2.new(0, 300, 0, 60)
NotifFrame.Position = UDim2.new(0.5, -150, 0, 20)
NotifFrame.BackgroundColor3 = BG_COLOR
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = NotifGui

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = PURPLE_NEON
NotifStroke.Thickness = 2
NotifStroke.Parent = NotifFrame

local NotifLabel = Instance.new("TextLabel")
NotifLabel.Size = UDim2.new(1, 0, 1, 0)
NotifLabel.BackgroundTransparency = 1
NotifLabel.Text = "GOMES HUB CARREGADO"
NotifLabel.TextColor3 = PURPLE_NEON
NotifLabel.Font = Enum.Font.GothamBold
NotifLabel.TextSize = 14
NotifLabel.Parent = NotifFrame

-- Desaparecer após 3 segundos
task.wait(3)
TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
TweenService:Create(NotifStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
TweenService:Create(NotifLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()

print("[GOMES HUB] Script carregado com sucesso!")
