-- [[ GOMES HUB V2 - CODIFICAÇÃO COMPLETA E UNIFICADA ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local currentCamera = Workspace.CurrentCamera

-- Proteção contra múltiplas execuções
if CoreGui:FindFirstChild("GomesHubV2") then
    CoreGui:FindFirstChild("GomesHubV2"):Destroy()
end

local GomesGui = Instance.new("ScreenGui")
GomesGui.Name = "GomesHubV2"
GomesGui.Parent = CoreGui
GomesGui.ResetOnSpawn = false

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

-------------------------------------------------------------------------------
-- LÓGICA DE SILENT AIM (PRESERVADA)
-------------------------------------------------------------------------------
local silentAimEnabled = false
local FOV_RADIUS = 340 
local PredictionFactor = 0.22 
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")

local function getClosestEnemy()
    local closestPart = nil
    local shortestDistance = math.huge
    local center = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local screenPos = currentCamera:WorldToViewportPoint(char.Head.Position)
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
        local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local targetPart = getClosestEnemy()
        if targetPart then
            local targetPos = targetPart.Position
            local targetChar = targetPart.Parent
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                targetPos = targetPos + (targetChar.HumanoidRootPart.Velocity * PredictionFactor)
            end
            pcall(function()
                ShootRemote:FireServer(myRoot.Position, targetPos, targetPart, targetPos)
            end)
        end
    end
end)

-------------------------------------------------------------------------------
-- CONFIGURAÇÕES E GUI
-------------------------------------------------------------------------------
local Config = { SpeedValue = 32, HitboxValue = 23, SpeedEnabled = false, HitboxEnabled = false, ESPBoxEnabled = false, ESPNameEnabled = false, ChamsEnabled = false }
local HitboxCache, ESPCache, ChamsCache = {}, {}, {}

-------------------------------------------------------------------------------
-- PAINEL PRINCIPAL
-------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 450)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = GomesGui
addCorner(MainFrame, 16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(110, 40, 200)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Botão de Minimizar / Abrir
local isMinimized = false
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -40, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = MainFrame
addCorner(MinBtn, 8)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 340, 0, 45) or UDim2.new(0, 340, 0, 450)
    MinBtn.Text = isMinimized and "+" or "-"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = targetSize}):Play()
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(18, 14, 26)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
addCorner(Header, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GOMES HUB V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(110, 40, 200)
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 8)

-------------------------------------------------------------------------------
-- COMPONENTES DA UI
-------------------------------------------------------------------------------
local function createToggle(name, defaultStatus, callback)
    local state = defaultStatus
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -6, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(18, 15, 25)
    ToggleFrame.Parent = Container
    addCorner(ToggleFrame, 8)
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.Parent = ToggleFrame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 40, 0, 22)
    Switch.Position = UDim2.new(1, -52, 0.5, -11)
    Switch.BackgroundColor3 = state and Color3.fromRGB(110, 40, 200) or Color3.fromRGB(35, 30, 45)
    Switch.Text = ""
    Switch.Parent = ToggleFrame
    addCorner(Switch, 12)
    
    Switch.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(110, 40, 200) or Color3.fromRGB(35, 30, 45)}):Play()
    end)
end

-- Toggles de Funcionalidades
createToggle("Ativar Silent Aim", false, function(state) silentAimEnabled = state end)
createToggle("Ativar Speed", false, function(state) Config.SpeedEnabled = state end)
createToggle("Ativar Hitbox Custom", false, function(state) Config.HitboxEnabled = state end)
createToggle("ESP Box 2D", false, function(state) Config.ESPBoxEnabled = state end)

-- Loop de processamento
RunService.Heartbeat:Connect(function()
    if Config.SpeedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Config.SpeedValue
    end
end)
