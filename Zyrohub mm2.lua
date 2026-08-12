-- Fluent UI Loader
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Control Variables: Movement
local TargetWalkSpeed = 16
local WalkSpeedEnabled = false
local InfJumpEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local BodyVelocity = nil
local BodyGyro = nil
local NoclipEnabled = false
local NoclipConnection = nil

-- Control Variables: Combat
local HitboxEnabled = false
local HitboxSize = 10
local ESPEnabled = false
local ESPLineEnabled = false
local SilentAimEnabled = false
local FOV_RADIUS = 340
local PredictionFactor = 0.22
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")
local ESPLines = {}

-- Control Variables: Underplayer
local UnderplayerEnabled = false
local SurfacePosition = nil
local VisualClones = {}

-- Main Window Creation
local Window = Fluent:CreateWindow({
    Title = "Zyro hub",
    SubTitle = "creator:gomes.wqq",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Light",
    MinimizeKey = Enum.KeyCode.X
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Movement", Icon = "plane" }),
    Combat = Window:AddTab({ Title = "Combat / TP", Icon = "crosshair" }),
    Under = Window:AddTab({ Title = "Underplayer", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ HELPER FUNCTIONS ]] --

local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

-- Reseta completamente a hitbox e juntas de um jogador para o padrão do Roblox
local function ResetPlayerHitbox(player)
    if player and player.Character then
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 1
            hrp.CanCollide = true
            hrp.Material = Enum.Material.Plastic

            local lowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
            if lowerTorso then
                local rootJoint = hrp:FindFirstChild("RootJoint") or lowerTorso:FindFirstChild("RootJoint")
                if rootJoint then
                    rootJoint.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(90), 0, math.rad(180))
                end
            end
        end
    end
end

-- Limpa todos os clones gerados no Workspace
local function CleanClones()
    for _, clone in pairs(VisualClones) do
        if clone and clone.Parent then
            clone:Destroy()
        end
    end
    VisualClones = {}

    for _, item in pairs(Workspace:GetChildren()) do
        if item.Name:sub(1, 11) == "UnderClone_" then
            item:Destroy()
        end
    end
end

-- Limpa as linhas de ESP
local function CleanESPLines()
    for _, line in pairs(ESPLines) do
        if line and line.Parent then
            line:Destroy()
        end
    end
    ESPLines = {}
end

local function ApplyHighlight(player)
    if not ESPEnabled or not IsEnemy(player) then return end
    local char = player.Character
    if char then
        local hl = char:FindFirstChild("ZyroHighlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "ZyroHighlight"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = char
        end
    end
end

local function RemoveHighlight(player)
    if player and player.Character then
        local hl = player.Character:FindFirstChild("ZyroHighlight")
        if hl then hl:Destroy() end
    end
end

-- [[ NOCLIP FUNCTION ]] --

local function ToggleNoclip(state)
    NoclipEnabled = state
    
    if NoclipEnabled then
        if NoclipConnection then
            NoclipConnection:Disconnect()
        end
        
        NoclipConnection = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Noclip Ativado!",
            Duration = 2
        })
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Noclip Desativado!",
            Duration = 2
        })
    end
end

-- [[ SILENT AIM FUNCTIONS ]] --

local function getClosestEnemy()
    local closestPart = nil
    local shortestDistance = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) then
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

-- [[ ESP LINE FUNCTION ]] --

local function CreateESPLine(player)
    if not ESPLineEnabled or not IsEnemy(player) then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    
    local line = Instance.new("Line")
    line.Transparency = 0
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 2
    
    ESPLines[player] = line
    
    RunService.RenderStepped:Connect(function()
        if not ESPLineEnabled or not line.Parent then return end
        if not char or not char:FindFirstChild("Head") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then
            if line.Parent then line:Destroy() end
            return
        end
        
        local screenSize = Camera.ViewportSize
        local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        
        line.From = screenCenter
        line.To = Camera:WorldToViewportPoint(char.Head.Position)
    end)
    
    line.Parent = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")
end

-- [[ MOVEMENT TAB ]] --

Tabs.Main:AddParagraph({
    Title = "Movement Controls",
    Content = "Hotkeys: F (Fly) | G (TP Up +40 studs) | X (Minimize UI)"
})

local SpeedToggle = Tabs.Main:AddToggle("SpeedToggle", {
    Title = "Enable WalkSpeed",
    Default = false
})

SpeedToggle:OnChanged(function(Value)
    WalkSpeedEnabled = Value
    if not Value then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
end)

Tabs.Main:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed Value",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        TargetWalkSpeed = Value
    end
})

local NoclipToggle = Tabs.Main:AddToggle("NoclipToggle", {
    Title = "Enable Noclip",
    Default = false
})

NoclipToggle:OnChanged(function(Value)
    ToggleNoclip(Value)
end)

local InfJumpToggle = Tabs.Main:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Default = false
})

InfJumpToggle:OnChanged(function(Value)
    InfJumpEnabled = Value
end)

local function ToggleFly(state)
    FlyEnabled = state
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    if FlyEnabled then
        if not BodyGyro then
            BodyGyro = Instance.new("BodyGyro")
            BodyGyro.P = 9e4
            BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.CFrame = hrp.CFrame
            BodyGyro.Parent = hrp
        end

        if not BodyVelocity then
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity.Parent = hrp
        end

        humanoid.PlatformStand = true
    else
        if BodyGyro then 
            BodyGyro:Destroy() 
            BodyGyro = nil
        end
        if BodyVelocity then 
            BodyVelocity:Destroy() 
            BodyVelocity = nil
        end
        humanoid.PlatformStand = false
    end
end

local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Enable Fly",
    Default = false
})

FlyToggle:OnChanged(function(Value)
    ToggleFly(Value)
end)

Tabs.Main:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        FlySpeed = Value
    end
})

local function TeleportUp()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    hrp.CFrame = hrp.CFrame * CFrame.new(0, 40, 0)

    Fluent:Notify({
        Title = "Zyro hub",
        Content = "Teleported 40 studs up!",
        Duration = 2
    })
end

Tabs.Main:AddButton({
    Title = "TP Up (+40 Studs)",
    Description = "Instant upward teleport (Hotkey: G)",
    Callback = function()
        TeleportUp()
    end
})

-- [[ COMBAT / TP TAB ]] --

Tabs.Combat:AddParagraph({
    Title = "Combat Utilities",
    Content = "Hotkey: T (Teleport to nearest enemy)"
})

local SilentAimToggle = Tabs.Combat:AddToggle("SilentAimToggle", {
    Title = "Enable Silent Aim",
    Default = false
})

SilentAimToggle:OnChanged(function(Value)
    SilentAimEnabled = Value
    if Value then
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Silent Aim Ativado! Clique para disparar.",
            Duration = 2
        })
    else
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Silent Aim Desativado!",
            Duration = 2
        })
    end
end)

Tabs.Combat:AddSlider("FOVSlider", {
    Title = "Silent Aim FOV",
    Default = 340,
    Min = 100,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        FOV_RADIUS = Value
    end
})

Tabs.Combat:AddSlider("PredictionSlider", {
    Title = "Silent Aim Prediction",
    Default = 0.22,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        PredictionFactor = Value
    end
})

local ESPLineToggle = Tabs.Combat:AddToggle("ESPLineToggle", {
    Title = "Enable ESP Line",
    Default = false
})

ESPLineToggle:OnChanged(function(Value)
    ESPLineEnabled = Value
    if not Value then
        CleanESPLines()
    else
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "ESP Line Ativado! Linhas até a cabeça dos inimigos.",
            Duration = 2
        })
    end
end)

local HitboxToggle = Tabs.Combat:AddToggle("HitboxToggle", {
    Title = "Enable Custom Hitbox",
    Default = false
})

HitboxToggle:OnChanged(function(Value)
    HitboxEnabled = Value
    if not Value and not UnderplayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ResetPlayerHitbox(player)
            end
        end
    end
end)

Tabs.Combat:AddSlider("HitboxSlider", {
    Title = "Hitbox Size",
    Default = 10,
    Min = 2,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        HitboxSize = Value
    end
})

local ESPToggle = Tabs.Combat:AddToggle("ESPToggle", {
    Title = "Enable ESP Highlight",
    Default = false
})

ESPToggle:OnChanged(function(Value)
    ESPEnabled = Value
    for _, player in pairs(Players:GetPlayers()) do
        if Value then
            ApplyHighlight(player)
        else
            RemoveHighlight(player)
        end
    end
end)

local function TeleportToNearestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local myHrp = myChar.HumanoidRootPart
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local char = player.Character
            if char and char:IsDescendantOf(Workspace) then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")

                if humanoid and humanoid.Health > 0 and hrp then
                    local distance = (myHrp.Position - hrp.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = hrp
                    end
                end
            end
        end
    end

    if closestPlayer then
        myHrp.CFrame = closestPlayer.CFrame * CFrame.new(0, 0, 3)
        Fluent:Notify({ Title = "Zyro hub", Content = "Teleported to nearest enemy!", Duration = 2 })
    else
        Fluent:Notify({ Title = "Zyro hub", Content = "No valid enemy found.", Duration = 3 })
    end
end

Tabs.Combat:AddButton({
    Title = "Teleport to Nearest Enemy (Hotkey: T)",
    Callback = function()
        TeleportToNearestPlayer()
    end
})

-- [[ UNDERPLAYER TAB ]] --

Tabs.Under:AddParagraph({
    Title = "Underplayer Mode",
    Content = "Hotkey: R (Entra -7 studs debaixo da terra, congela e coloca hitbox 20 no pé dos inimigos. Pressionar R novamente desativa e restaura tudo)."
})

local UnderToggle

local function ToggleUnderplayer(state)
    UnderplayerEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if UnderplayerEnabled then
        if HitboxEnabled then
            HitboxToggle:SetValue(false)
        end

        SurfacePosition = hrp.CFrame
        hrp.CFrame = SurfacePosition * CFrame.new(0, -7, 0)
        hrp.Anchored = true

        Fluent:Notify({ Title = "Zyro hub", Content = "Underplayer Ativado (-7 studs).", Duration = 2 })
    else
        if SurfacePosition then
            hrp.CFrame = SurfacePosition
            SurfacePosition = nil
        end

        hrp.Anchored = false

        CleanClones()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ResetPlayerHitbox(player)
            end
        end

        Fluent:Notify({ Title = "Zyro hub", Content = "Underplayer Desativado! Tudo restaurado.", Duration = 2 })
    end
end

UnderToggle = Tabs.Under:AddToggle("UnderToggle", {
    Title = "Enable Underplayer (Hotkey: R)",
    Default = false
})

UnderToggle:OnChanged(function(Value)
    if Value ~= UnderplayerEnabled then
        ToggleUnderplayer(Value)
    end
end)

-- [[ SETTINGS TAB ]] --

local ThemeDropdown = Tabs.Settings:AddDropdown("ThemeManager", {
    Title = "Interface Theme",
    Values = {"Light", "Dark", "Darker", "Aqua", "Amethyst"},
    Multi = false,
    Default = "Light",
})

ThemeDropdown:OnChanged(function(Value)
    Fluent:SetTheme(Value)
end)

-- [[ RESPAWN & CHARACTER MANAGEMENT ]] --

local function BindCharacterEvents(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        char:WaitForChild("HumanoidRootPart")

        task.wait(0.5)

        if player == LocalPlayer then
            if FlyEnabled then
                ToggleFly(true)
            end
        else
            if ESPEnabled then
                ApplyHighlight(player)
            end
            if ESPLineEnabled then
                CreateESPLine(player)
            end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    BindCharacterEvents(player)
end

Players.PlayerAdded:Connect(function(player)
    BindCharacterEvents(player)
end)

-- [[ LOOPS AND CONNECTIONS ]] --

RunService.RenderStepped:Connect(function()
    -- Aplicar WalkSpeed personalizado
    if WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = TargetWalkSpeed
    end

    -- Loop do Fly
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local camera = Workspace.CurrentCamera
        local moveDir = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if BodyVelocity and BodyGyro then
            BodyVelocity.Velocity = moveDir * FlySpeed
            BodyGyro.CFrame = camera.CFrame
        end
    end

    -- Loop do ESP
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character then
                ApplyHighlight(player)
            else
                RemoveHighlight(player)
            end
        end
    end

    -- Loop de ESP Line
    if ESPLineEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character then
                if not ESPLines[player] then
                    CreateESPLine(player)
                end
            end
        end
    end

    -- Loop de Hitbox Padrão (só roda se Underplayer estiver DESATIVADO)
    if HitboxEnabled and not UnderplayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

                if humanoid and humanoid.Health > 0 then
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end

    -- Loop do Underplayer (Apenas se ativado)
    if UnderplayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character then
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                if hrp and humanoid and humanoid.Health > 0 then
                    hrp.Size = Vector3.new(20, 20, 20)
                    hrp.Transparency = 0.6
                    hrp.BrickColor = BrickColor.new("Cyan")
                    hrp.Material = Enum.Material.ForceField
                    hrp.CanCollide = false

                    local lowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
                    if lowerTorso then
                        local rootJoint = hrp:FindFirstChild("RootJoint") or lowerTorso:FindFirstChild("RootJoint")
                        if rootJoint then
                            rootJoint.C0 = CFrame.new(0, -7, 0) * CFrame.Angles(-math.rad(90), 0, math.rad(180))
                        end
                    end
                end
            end
        end
    end
end)

-- Infinite Jump Request
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Silent Aim Input
UserInputService.InputBegan:Connect(function(input, processed)
    if not SilentAimEnabled or processed then return end
    
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

-- Atalhos de Teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.T then
        TeleportToNearestPlayer()
    elseif input.KeyCode == Enum.KeyCode.F then
        FlyToggle:SetValue(not FlyEnabled)
    elseif input.KeyCode == Enum.KeyCode.R then
        UnderToggle:SetValue(not UnderplayerEnabled)
    elseif input.KeyCode == Enum.KeyCode.G then
        TeleportUp()
    end
end)

-- Seleção inicial de aba
Window:SelectTab(1)

Fluent:Notify({
    Title = "Zyro hub",
    Content = "Zyro Hub atualizado com Noclip e ESP Line!",
    Duration = 5
})
