-- ⚡ XENO EXPLOIT - GUI DARK MODE ⚡
-- Script Premium para Roblox
-- Estilo: Preto e Branco com Design Xeno

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações do Script
local Config = {
    CamLockRadius = 300,
    SpeedBoostVelocity = 30,
    TeleportHeight = 30,
    ImageId = "rbxassetid://120019092103020"
}

-- Estado de todas as funções
local Features = {
    CustomHitbox = false,
    HitboxSize = 1,
    ESP = false,
    ESPDistance = false,
    CamLock = false,
    NoRecoil = false,
    SpeedBoost = false,
    TPPlayer = false,
    TPFly = false,
    Aimbot = false,
    God = false,
    Fly = false,
    Noclip = false
}

local GuiActive = true

-- ========== GUI SETUP ==========

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoExploit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Painel Principal com Design Xeno
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 320, 0, 600)
MainPanel.Position = UDim2.new(0.5, -160, 0.5, -300)
MainPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainPanel.BorderSizePixel = 0
MainPanel.Visible = true
MainPanel.Parent = ScreenGui

-- Corner arredondado
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainPanel

-- Borda branca elegante
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainPanel

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0
Header.Parent = MainPanel

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Logo/Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚡ XENO EXPLOIT"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextScaled = false
TitleLabel.Parent = Header

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 12)
Padding.Parent = TitleLabel

-- Botão Fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0.5, -17)
CloseButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    GuiActive = not GuiActive
    MainPanel.Visible = GuiActive
end)

-- Notificação de Carregamento
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "Notification"
NotificationFrame.Size = UDim2.new(1, -20, 0, 35)
NotificationFrame.Position = UDim2.new(0, 10, 0, 58)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Parent = MainPanel

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 8)
NotifCorner.Parent = NotificationFrame

local NotificationLabel = Instance.new("TextLabel")
NotificationLabel.Text = "✓ Script Carregado | ID: 120019092103020"
NotificationLabel.TextSize = 11
NotificationLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
NotificationLabel.BackgroundTransparency = 1
NotificationLabel.Font = Enum.Font.Gotham
NotificationLabel.Size = UDim2.new(1, 0, 1, 0)
NotificationLabel.Parent = NotificationFrame

-- ScrollFrame para conteúdo
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -10, 1, -120)
ScrollFrame.Position = UDim2.new(0, 5, 0, 105)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollFrame.Parent = MainPanel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- ========== FUNÇÕES DE UI ==========

local function CreateToggle(parent, name, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Name = name
    Toggle.Size = UDim2.new(1, 0, 0, 32)
    Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Toggle

    local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle

    local LabelPadding = Instance.new("UIPadding")
    LabelPadding.PaddingLeft = UDim.new(0, 10)
    LabelPadding.Parent = Label

    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(0, 45, 0, 24)
    Button.Position = UDim2.new(1, -55, 0.5, -12)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.TextColor3 = Color3.fromRGB(150, 150, 150)
    Button.TextSize = 10
    Button.Font = Enum.Font.GothamBold
    Button.Text = "OFF"
    Button.BorderSizePixel = 0
    Button.Parent = Toggle

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextColor3 = Color3.fromRGB(10, 10, 10)
        else
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        Button.Text = state and "ON" or "OFF"
        callback(state)
    end)

    return Toggle, Button
end

local function CreateSlider(parent, name, min, max, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(1, -10, 0, 15)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, -20, 0, 3)
    SliderBar.Position = UDim2.new(0, 10, 0, 25)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 2)
    SliderCorner.Parent = SliderBar

    local Thumb = Instance.new("Frame")
    Thumb.Name = "Thumb"
    Thumb.Size = UDim2.new(0, 14, 0, 14)
    Thumb.Position = UDim2.new(0, 0, 0.5, -7)
    Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Thumb.BorderSizePixel = 0
    Thumb.Parent = SliderBar

    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(0, 7)
    ThumbCorner.Parent = Thumb

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = "1"
    ValueLabel.Size = UDim2.new(0, 35, 0, 15)
    ValueLabel.Position = UDim2.new(1, -45, 0, 25)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.TextSize = 10
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame

    local dragging = false
    local currentValue = min

    Thumb.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    Mouse.Move:Connect(function()
        if dragging then
            local barSize = SliderBar.AbsoluteSize.X
            local barPos = SliderBar.AbsolutePosition.X
            local mousePos = Mouse.X - barPos
            local percentage = math.max(0, math.min(1, mousePos / barSize))
            currentValue = math.floor(min + (max - min) * percentage)

            Thumb.Position = UDim2.new(percentage, -7, 0.5, -7)
            ValueLabel.Text = tostring(currentValue)
            callback(currentValue)
        end
    end)

    return SliderFrame
end

local function CreateCategory(parent, categoryName)
    local Category = Instance.new("Frame")
    Category.Name = categoryName
    Category.Size = UDim2.new(1, 0, 0, 25)
    Category.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Category.BorderSizePixel = 0
    Category.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Text = "━━ " .. categoryName .. " ━━"
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 10
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Category

    return Category
end

-- ========== CRIANDO ITEMS DO MENU ==========

-- Categoria Combat
CreateCategory(ScrollFrame, "COMBAT")

CreateToggle(ScrollFrame, "Custom Hitbox [X]", function(state)
    Features.CustomHitbox = state
end)

CreateSlider(ScrollFrame, "Hitbox Size", 1, 50, function(value)
    Features.HitboxSize = value
end)

CreateToggle(ScrollFrame, "Aimbot [A]", function(state)
    Features.Aimbot = state
end)

CreateToggle(ScrollFrame, "No Recoil [R]", function(state)
    Features.NoRecoil = state
end)

-- Categoria Visual
CreateCategory(ScrollFrame, "VISUAL")

CreateToggle(ScrollFrame, "ESP Player [E]", function(state)
    Features.ESP = state
end)

CreateToggle(ScrollFrame, "ESP Distance [D]", function(state)
    Features.ESPDistance = state
end)

-- Categoria Movement
CreateCategory(ScrollFrame, "MOVEMENT")

CreateToggle(ScrollFrame, "Speed Boost [V]", function(state)
    Features.SpeedBoost = state
end)

CreateToggle(ScrollFrame, "Fly [F]", function(state)
    Features.Fly = state
end)

CreateToggle(ScrollFrame, "No-Clip [N]", function(state)
    Features.Noclip = state
end)

CreateToggle(ScrollFrame, "TP Player [T]", function(state)
    Features.TPPlayer = state
end)

CreateToggle(ScrollFrame, "TP Fly [Y]", function(state)
    Features.TPFly = state
end)

-- Categoria Survival
CreateCategory(ScrollFrame, "SURVIVAL")

CreateToggle(ScrollFrame, "God Mode [G]", function(state)
    Features.God = state
end)

CreateToggle(ScrollFrame, "Cam-Lock [Z]", function(state)
    Features.CamLock = state
end)

-- ========== KEYBINDS ==========

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- 9 = Fechar GUI
    if input.KeyCode == Enum.KeyCode.Nine then
        GuiActive = not GuiActive
        MainPanel.Visible = GuiActive
        return
    end

    -- X = Custom Hitbox
    if input.KeyCode == Enum.KeyCode.X then
        Features.CustomHitbox = not Features.CustomHitbox
    end

    -- E = ESP
    if input.KeyCode == Enum.KeyCode.E then
        Features.ESP = not Features.ESP
    end

    -- D = ESP Distance
    if input.KeyCode == Enum.KeyCode.D then
        Features.ESPDistance = not Features.ESPDistance
    end

    -- Z = CamLock
    if input.KeyCode == Enum.KeyCode.Z then
        Features.CamLock = not Features.CamLock
    end

    -- V = Speed Boost
    if input.KeyCode == Enum.KeyCode.V then
        Features.SpeedBoost = not Features.SpeedBoost
    end

    -- F = Fly
    if input.KeyCode == Enum.KeyCode.F then
        Features.Fly = not Features.Fly
    end

    -- N = No-Clip
    if input.KeyCode == Enum.KeyCode.N then
        Features.Noclip = not Features.Noclip
    end

    -- A = Aimbot
    if input.KeyCode == Enum.KeyCode.A then
        Features.Aimbot = not Features.Aimbot
    end

    -- R = No Recoil
    if input.KeyCode == Enum.KeyCode.R then
        Features.NoRecoil = not Features.NoRecoil
    end

    -- G = God Mode
    if input.KeyCode == Enum.KeyCode.G then
        Features.God = not Features.God
    end

    -- T = TP Player
    if input.KeyCode == Enum.KeyCode.T then
        Features.TPPlayer = true
    end

    -- Y = TP Fly
    if input.KeyCode == Enum.KeyCode.Y then
        Features.TPFly = true
    end
end)

-- ========== FUNÇÃO DE DRAG GUI ==========

local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Mouse.Position
        startPos = MainPanel.Position
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Mouse.Move:Connect(function()
    if dragging and dragStart then
        local delta = Mouse.Position - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== IMPLEMENTAÇÃO DAS FEATURES ==========

-- Custom Hitbox
RunService.RenderStepped:Connect(function()
    if Features.CustomHitbox and LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Size = Vector3.new(Features.HitboxSize, Features.HitboxSize, Features.HitboxSize)
        end
    end
end)

-- ESP System
local espParts = {}

local function UpdateESP()
    for _, part in pairs(espParts) do
        if part and part.Parent then
            pcall(function() part:Destroy() end)
        end
    end
    espParts = {}

    if not Features.ESP then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Adornee = humanoidRootPart
                espBox.Size = humanoidRootPart.Size + Vector3.new(0.1, 0.1, 0.1)
                espBox.Color3 = Color3.fromRGB(255, 255, 255)
                espBox.Transparency = 0.4
                espBox.Parent = humanoidRootPart
                table.insert(espParts, espBox)

                if Features.ESPDistance then
                    local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if playerHRP then
                        local distance = (humanoidRootPart.Position - playerHRP.Position).Magnitude
                        local distanceLabel = Instance.new("BillboardGui")
                        distanceLabel.Size = UDim2.new(2, 0, 2, 0)
                        distanceLabel.MaxDistance = math.huge
                        distanceLabel.Parent = humanoidRootPart

                        local label = Instance.new("TextLabel")
                        label.Text = tostring(math.floor(distance)) .. "m"
                        label.TextSize = 14
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.BackgroundTransparency = 1
                        label.Font = Enum.Font.GothamBold
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.Parent = distanceLabel

                        table.insert(espParts, distanceLabel)
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- Speed Boost
RunService.RenderStepped:Connect(function()
    if Features.SpeedBoost and LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity.Unit * 30
        end
    end
end)

-- Fly
local flying = false
local flySpeed = 50
local flyDirection = Vector3.new(0, 0, 0)

local function StartFly()
    if not LocalPlayer.Character then return end
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    flying = true
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart

    while Features.Fly and humanoidRootPart do
        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

        if moveDirection.Magnitude > 0 then
            bodyVelocity.Velocity = moveDirection.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end

        RunService.RenderStepped:Wait()
    end

    pcall(function() bodyVelocity:Destroy() end)
    flying = false
end

RunService.RenderStepped:Connect(function()
    if Features.Fly and not flying then
        StartFly()
    elseif not Features.Fly and flying then
        flying = false
    end
end)

-- No-Clip
RunService.RenderStepped:Connect(function()
    if Features.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Cam Lock com Wall Check
local function GetClosestPlayerInRadius()
    local closestPlayer = nil
    local closestDistance = 300

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if targetHRP and playerHRP then
                local distance = (targetHRP.Position - playerHRP.Position).Magnitude

       
