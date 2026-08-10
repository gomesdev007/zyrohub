-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local RADIUS = 300
local HITBOX_SIZE = Vector3.new(20, 20, 20)
local Enabled = false
local AutoCollectEnabled = false
local TeamCheckEnabled = false
local CursorClickEnabled = false

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GomesDarkGUI"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 250) -- Expandido para as novas funções
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 23)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(25, 40, 70)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Top Bar (Barra de Arraste)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 22, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GOMES SYSTEM"
TitleLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Botão Minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -28, 0, 3)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(160, 180, 210)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

-- Criador de Toggles
local function createToggle(titleText, positionY, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0, 226, 0, 40)
    ToggleFrame.Position = UDim2.new(0.5, -113, 0, positionY)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = MainFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame

    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0, 150, 1, 0)
    ToggleText.Position = UDim2.new(0, 10, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = titleText
    ToggleText.TextColor3 = Color3.fromRGB(200, 210, 235)
    ToggleText.TextSize = 10
    ToggleText.Font = Enum.Font.GothamMedium
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Size = UDim2.new(0, 44, 0, 22)
    SwitchBG.Position = UDim2.new(1, -52, 0.5, -11)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(30, 38, 55)
    SwitchBG.Text = ""
    SwitchBG.AutoButtonColor = false
    SwitchBG.Parent = ToggleFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBG

    local SwitchCircle = Instance.new("Frame")
    SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
    SwitchCircle.Position = UDim2.new(0, 3, 0.5, -8)
    SwitchCircle.BackgroundColor3 = Color3.fromRGB(110, 125, 150)
    SwitchCircle.BorderSizePixel = 0
    SwitchCircle.Parent = SwitchBG

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = SwitchCircle

    local isToggled = false
    
    local function setVisual(state)
        isToggled = state
        local targetCirclePos = isToggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetCircleColor = isToggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(110, 125, 150)
        local targetBGColor = isToggled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(30, 38, 55)

        TweenService:Create(SwitchCircle, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = targetCirclePos,
            BackgroundColor3 = targetCircleColor
        }):Play()

        TweenService:Create(SwitchBG, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetBGColor
        }):Play()
    end

    SwitchBG.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        setVisual(isToggled)
        callback(isToggled, setVisual)
    end)

    return setVisual
end

-- Toggles
createToggle("Hitbox 20 + Auto Click 300", 40, function(state)
    Enabled = state
end)

local setAutoCollectVisual
setAutoCollectVisual = createToggle("Auto Collect Gun (Sheriff)", 90, function(state)
    AutoCollectEnabled = state
end)

createToggle("Team Check", 140, function(state)
    TeamCheckEnabled = state
end)

createToggle("Auto Click Cursor (1 sec)", 190, function(state)
    CursorClickEnabled = state
end)

-- Sistema de Arraste da Interface
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tecla X para Abrir/Fechar a GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Minimizar
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 250, 0, 32) or UDim2.new(0, 250, 0, 250)
    
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize
    }):Play()
    MinimizeBtn.Text = isMinimized and "+" or "-"
end)

-- Auto Collect Gun
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoCollectEnabled then
            local droppedGun = Workspace:FindFirstChild("GunDrop") or Workspace:FindFirstChild("Gun") or Workspace:FindFirstChild("GunServer")
            if not droppedGun then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Tool") or obj.Name:lower():find("gun") then
                        if not obj.Parent:FindFirstChildOfClass("Humanoid") then
                            droppedGun = obj
                            break
                        end
                    end
                end
            end

            if droppedGun then
                local myChar = LocalPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local savedCFrame = myHRP.CFrame
                    local targetPos = droppedGun:IsA("BasePart") and droppedGun.CFrame or (droppedGun:FindFirstChildOfClass("BasePart") and droppedGun:FindFirstChildOfClass("BasePart").CFrame)

                    if targetPos then
                        myHRP.CFrame = targetPos
                        task.wait(1)
                        if myHRP then myHRP.CFrame = savedCFrame end
                        AutoCollectEnabled = false
                        if setAutoCollectVisual then setAutoCollectVisual(false) end
                    end
                end
            end
        end
    end
end)

-- Auto Click no Cursor a cada 1 segundo
task.spawn(function()
    while true do
        task.wait(1)
        if CursorClickEnabled then
            local mousePos = UserInputService:GetMouseLocation()
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
        end
    end
end)

-- Loop Principal (Hitbox + Auto Click Preciso com Team Check)
local lastClick = 0

RunService.RenderStepped:Connect(function()
    if not Enabled then return end
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Aplica Team Check
            if not (TeamCheckEnabled and player.Team == LocalPlayer.Team) then
                local targetHRP = player.Character.HumanoidRootPart
                
                -- Aplica Hitbox 20
                targetHRP.Size = HITBOX_SIZE
                targetHRP.Transparency = 0.7
                targetHRP.Color = Color3.fromRGB(0, 120, 255)
                targetHRP.Material = Enum.Material.ForceField
                targetHRP.CanCollide = false
                
                -- Verificação da distância de 300 studs
                local distance = (targetHRP.Position - myPos).Magnitude
                if distance <= RADIUS then
                    -- Converte a posição exata da Hitbox na tela
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetHRP.Position)
                    
                    if onScreen then
                        if tick() - lastClick >= 0.08 then
                            lastClick = tick()
                            -- Clique direto nas coordenadas X e Y centrais do alvo na tela
                            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                        end
                    end
                end
            end
        end
    end
end)
