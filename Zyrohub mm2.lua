-- ⚡ XENO EXPLOIT ROBLOX - VERSÃO 2.0 ⚡
-- Script Premium Corrigido e Funcional
-- Estilo: Xeno Dark Mode (Preto e Branco)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Verificar se LocalPlayer existe
if not LocalPlayer then
    warn("Erro: LocalPlayer não encontrado!")
    return
end

-- Configurações
local Config = {
    CamLockRadius = 300,
    SpeedBoostVelocity = 30,
    TeleportHeight = 30,
    ImageId = "120019092103020"
}

-- Estado das Funções
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
    Noclip = false,
    InfinityJump = false
}

local GuiActive = true
local espParts = {}
local flying = false

-- ========== GUI SETUP ==========

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoExploit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Painel Principal
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 340, 0, 650)
MainPanel.Position = UDim2.new(0.5, -170, 0.5, -325)
MainPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainPanel.BorderSizePixel = 0
MainPanel.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainPanel

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

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚡ XENO EXPLOIT"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 12)
TitlePadding.PaddingTop = UDim.new(0, 5)
TitlePadding.Parent = TitleLabel

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

-- Notificação
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

-- ScrollFrame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -10, 1, -120)
ScrollFrame.Position = UDim2.new(0, 5, 0, 105)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainPanel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 8)
UIPadding.Parent = ScrollFrame

-- ========== FUNÇÕES DE UI ==========

local function CreateToggle(parent, name, initialCallback)
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
        Button.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
        Button.TextColor3 = state and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(150, 150, 150)
        Button.Text = state and "ON" or "OFF"
        initialCallback(state)
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

    UserInputService.InputEnded:Connect(function(input)
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

local function CreateCategory(parent, name)
    local Category = Instance.new("Frame")
    Category.Name = name
    Category.Size = UDim2.new(1, 0, 0, 25)
    Category.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Category.BorderSizePixel = 0
    Category.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Text = "━━ " .. name .. " ━━"
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 10
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Category

    return Category
end

-- ========== CRIAR ITENS DO MENU ==========

CreateCategory(ScrollFrame, "COMBAT")
CreateToggle(ScrollFrame, "Custom Hitbox [X]", function(state) Features.CustomHitbox = state end)
CreateSlider(ScrollFrame, "Hitbox Size", 1, 50, function(value) Features.HitboxSize = value end)
CreateToggle(ScrollFrame, "Aimbot [A]", function(state) Features.Aimbot = state end)
CreateToggle(ScrollFrame, "No Recoil [R]", function(state) Features.NoRecoil = state end)

CreateCategory(ScrollFrame, "VISUAL")
CreateToggle(ScrollFrame, "ESP Player [E]", function(state) Features.ESP = state end)
CreateToggle(ScrollFrame, "ESP Distance [D]", function(state) Features.ESPDistance = state end)

CreateCategory(ScrollFrame, "MOVEMENT")
CreateToggle(ScrollFrame, "Speed Boost [V]", function(state) Features.SpeedBoost = state end)
CreateToggle(ScrollFrame, "Fly [F]", function(state) Features.Fly = state end)
CreateToggle(ScrollFrame, "No-Clip [N]", function(state) Features.Noclip = state end)
CreateToggle(ScrollFrame, "Infinity Jump [I]", function(state) Features.InfinityJump = state end)

CreateCategory(ScrollFrame, "TELEPORT")
CreateToggle(ScrollFrame, "TP Player [T]", function(state) Features.TPPlayer = state end)
CreateToggle(ScrollFrame, "TP Fly Up [Y]", function(state) Features.TPFly = state end)

CreateCategory(ScrollFrame, "SURVIVAL")
CreateToggle(ScrollFrame, "God Mode [G]", function(state) Features.God = state end)
CreateToggle(ScrollFrame, "Cam-Lock [Z]", function(state) Features.CamLock = state end)

-- ========== DRAG GUI ==========

local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Mouse.Position
        startPos = MainPanel.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
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

-- ========== KEYBINDS ==========

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Nine then
        GuiActive = not GuiActive
        MainPanel.Visible = GuiActive
    elseif input.KeyCode == Enum.KeyCode.X then
        Features.CustomHitbox = not Features.CustomHitbox
    elseif input.KeyCode == Enum.KeyCode.E then
        Features.ESP = not Features.ESP
    elseif input.KeyCode == Enum.KeyCode.D then
        Features.ESPDistance = not Features.ESPDistance
    elseif input.KeyCode == Enum.KeyCode.Z then
        Features.CamLock = not Features.CamLock
    elseif input.KeyCode == Enum.KeyCode.V then
        Features.SpeedBoost = not Features.SpeedBoost
    elseif input.KeyCode == Enum.KeyCode.F then
        Features.Fly = not Features.Fly
    elseif input.KeyCode == Enum.KeyCode.N then
        Features.Noclip = not Features.Noclip
    elseif input.KeyCode == Enum.KeyCode.A then
        Features.Aimbot = not Features.Aimbot
    elseif input.KeyCode == Enum.KeyCode.R then
        Features.NoRecoil = not Features.NoRecoil
    elseif input.KeyCode == Enum.KeyCode.G then
        Features.God = not Features.God
    elseif input.KeyCode == Enum.KeyCode.I then
        Features.InfinityJump = not Features.InfinityJump
    elseif input.KeyCode == Enum.KeyCode.T then
        Features.TPPlayer = true
    elseif input.KeyCode == Enum.KeyCode.Y then
        Features.TPFly = true
    end
end)

-- ========== FEATURES IMPLEMENTATION ==========

-- Custom Hitbox
RunService.RenderStepped:Connect(function()
    if Features.CustomHitbox and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.Size = Vector3.new(Features.HitboxSize, Features.HitboxSize, Features.HitboxSize)
            end)
        end
    end
end)

-- ESP
local function UpdateESP()
    for _, part in pairs(espParts) do
        pcall(function() part:Destroy() end)
    end
    espParts = {}

    if not Features.ESP then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Adornee = targetHRP
                espBox.Size = targetHRP.Size + Vector3.new(0.1, 0.1, 0.1)
                espBox.Color3 = Color3.fromRGB(255, 255, 255)
                espBox.Transparency = 0.4
                espBox.Parent = targetHRP
                table.insert(espParts, espBox)

                if Features.ESPDistance then
                    local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if playerHRP then
                        local distance = (targetHRP.Position - playerHRP.Position).Magnitude
                        local billboardGui = Instance.new("BillboardGui")
                        billboardGui.Size = UDim2.new(2, 0, 2, 0)
                        billboardGui.MaxDistance = math.huge
                        billboardGui.Parent = targetHRP

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Text = tostring(math.floor(distance)) .. "m"
                        textLabel.TextSize = 14
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.Parent = billboardGui

                        table.insert(espParts, billboardGui)
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
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.AssemblyLinearVelocity then
            pcall(function()
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = vel.Unit * 30
                end
            end)
        end
    end
end)

-- Fly
local function StartFly()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flying = true
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = hrp

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Features.Fly or not hrp or not hrp.Parent then
            connection:Disconnect()
            pcall(function() bodyVelocity:Destroy() end)
            flying = false
            return
        end

        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

        if moveDirection.Magnitude > 0 then
            bodyVelocity.Velocity = moveDirection.Unit * 50
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Features.Fly and not flying then
        StartFly()
    end
end)

-- No-Clip
RunService.RenderStepped:Connect(function()
    if Features.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)

-- Infinity Jump
local canJump = true
UserInputService.InputBegan:Connect(function(input)
    if Features.InfinityJump and input.KeyCode == Enum.KeyCode.Space then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
            end)
        end
    end
end)

-- Cam Lock
local function GetClosestPlayerInRadius()
    local closestPlayer = n
