local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")

-- Tela Principal (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZyroHubAutoGui"
ScreenGui.ResetOnSpawn = false
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Janela Arrastável (GUI Dark Ampliada)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 165)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -82.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = Color3.fromRGB(110, 40, 200)
FrameStroke.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -24, 0, 30)
Title.Position = UDim2.new(0, 12, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Zyro hub auto"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Função Auxiliar para Criar Switches (Interruptores)
local function createSwitch(posY, labelText)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 24)
    Label.Position = UDim2.new(0, 12, 0, posY)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Size = UDim2.new(0, 44, 0, 22)
    SwitchBG.Position = UDim2.new(1, -56, 0, posY + 1)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    SwitchBG.Text = ""
    SwitchBG.Parent = MainFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 12)
    SwitchCorner.Parent = SwitchBG

    local SwitchBall = Instance.new("Frame")
    SwitchBall.Size = UDim2.new(0, 16, 0, 16)
    SwitchBall.Position = UDim2.new(0, 3, 0.5, -8)
    SwitchBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchBall.BorderSizePixel = 0
    SwitchBall.Parent = SwitchBG

    local BallCorner = Instance.new("UICorner")
    BallCorner.CornerRadius = UDim.new(0, 100)
    BallCorner.Parent = SwitchBall

    return SwitchBG, SwitchBall, Label
end

-- Switches
local AutoShootBtn, AutoShootBall, AutoShootLabel = createSwitch(38, "AUTO SHOOT [X]")
local HitboxBtn, HitboxBall, HitboxLabel = createSwitch(76, "HITBOX (18)")
local SpeedBtn, SpeedBall, SpeedLabel = createSwitch(114, "SPEED BOOST (23)")

-------------------------------------------------------------------------------
-- ESTADOS & CONFIGURAÇÕES
-------------------------------------------------------------------------------
local AutoShootActive = false
local HitboxActive = false
local SpeedActive = false

local PredictionFactor = 0.22 
local TOOL_NAME = "Colt"
local HitboxCache = {}

-------------------------------------------------------------------------------
-- LÓGICA DE SPEED BOOST (23)
-------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if SpeedActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 23
        end
    end
end)

-------------------------------------------------------------------------------
-- LÓGICA DE HITBOX (18)
-------------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        if HitboxActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if not HitboxCache[player] then
                        HitboxCache[player] = {
                            OriginalSize = hrp.Size,
                            OriginalTrans = hrp.Transparency,
                            OriginalCollide = hrp.CanCollide
                        }
                    end
                    hrp.Size = Vector3.new(18, 18, 18)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        else
            for player, data in pairs(HitboxCache) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = data.OriginalSize
                    hrp.Transparency = data.OriginalTrans
                    hrp.CanCollide = data.OriginalCollide
                end
            end
            table.clear(HitboxCache)
        end
    end
end)

-------------------------------------------------------------------------------
-- LÓGICA DE AUTO SHOOT
-------------------------------------------------------------------------------
local function autoEquip()
    local character = LocalPlayer.Character
    if not character then return end
    if character:FindFirstChild(TOOL_NAME) then return end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(TOOL_NAME)
        if tool and tool:IsA("Tool") then
            tool.Parent = character
        end
    end
end

local function getClosestEnemyPart()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:IsDescendantOf(workspace) then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and rootPart and head then
                    if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then 
                        local dist = (myRoot.Position - rootPart.Position).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestEnemy = head
                        end
                    end
                end
            end
        end
    end
    return closestEnemy
end

local function fireWeapon()
    autoEquip()
    if not ShootRemote or not LocalPlayer.Character then return end
    
    local character = LocalPlayer.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChild(TOOL_NAME) or character:FindFirstChildOfClass("Tool")
    
    if rootPart and tool and tool:IsA("Tool") then
        local targetPart = getClosestEnemyPart()
        if not targetPart then return end
        
        local targetPos = targetPart.Position
        local targetCharacter = targetPart.Parent
        if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
            local targetVelocity = targetCharacter.HumanoidRootPart.Velocity
            targetPos = targetPos + (targetVelocity * PredictionFactor)
        end
        
        local direction = (Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z) - rootPart.Position).Unit
        local newCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)
        rootPart.CFrame = newCFrame
        
        task.spawn(function()
            if tool and tool.Parent == character then
                tool:Activate()
            end
        end)
        
        pcall(function()
            ShootRemote:FireServer(
                rootPart.Position,
                targetPos,
                targetPart,
                targetPos
            )
        end)
    end
end

-------------------------------------------------------------------------------
-- CONTROLE DOS INTERRUPTORES (ANIMATION & TOGGLE)
-------------------------------------------------------------------------------
local function updateSwitch(active, ball, bg, label)
    local ballPos = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    local bgColor = active and Color3.fromRGB(110, 40, 200) or Color3.fromRGB(35, 30, 45)
    
    TweenService:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = ballPos}):Play()
    TweenService:Create(bg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = bgColor}):Play()
    label.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
end

-- Auto Shoot Toggle
local function toggleAutoShoot()
    AutoShootActive = not AutoShootActive
    updateSwitch(AutoShootActive, AutoShootBall, AutoShootBtn, AutoShootLabel)
    
    if AutoShootActive then
        task.spawn(function()
            while AutoShootActive do
                fireWeapon()
                task.wait(0.10)
            end
        end)
    end
end

AutoShootBtn.MouseButton1Click:Connect(toggleAutoShoot)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.X then
        toggleAutoShoot()
    end
end)

-- Hitbox Toggle
HitboxBtn.MouseButton1Click:Connect(function()
    HitboxActive = not HitboxActive
    updateSwitch(HitboxActive, HitboxBall, HitboxBtn, HitboxLabel)
end)

-- Speed Boost Toggle
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedActive = not SpeedActive
    updateSwitch(SpeedActive, SpeedBall, SpeedBtn, SpeedLabel)
    if not SpeedActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)
