-- Fluent UI Loader
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Control Variables: Movement
local TargetWalkSpeed = 16
local WalkSpeedEnabled = false
local InfJumpEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local BodyVelocity = nil
local BodyGyro = nil

-- Control Variables: Combat
local HitboxEnabled = false
local HitboxSize = 10
local ESPEnabled = false
local SilentAimEnabled = false
local FOV_RADIUS = 340
local PredictionFactor = 0.22
local AimKillEnabled = false
local AimKillCooldown = false

-- Control Variables: Underplayer
local UnderplayerEnabled = false
local SurfacePosition = nil
local VisualClones = {}

-- Safe Remote Reference
local ShootRemote = nil
pcall(function()
    ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")
end)

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

-- [[ SILENT AIM FUNCTIONS ]] --

local function GetClosestEnemyInFOV()
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

-- [[ AIM KILL FUNCTIONS ]] --

local function GetClosestEnemyPart()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
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

local function ExecuteAimKill()
    if AimKillCooldown then return end
    AimKillCooldown = true
    
    local character = LocalPlayer.Character
    if not character then 
        AimKillCooldown = false
        return 
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChildOfClass("Tool")
    
    if not rootPart or not tool then
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Equipe uma arma primeiro!",
            Duration = 2
        })
        AimKillCooldown = false
        return
    end
    
    local targetPart = GetClosestEnemyPart()
    local targetPos = targetPart and targetPart.Position or (rootPart.Position + rootPart.CFrame.LookVector * 50)
    local originPos = rootPart.Position
    
    -- 4 Disparos em loop (1 segundo total)
    for i = 1, 4 do
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
        
        task.wait(0.25) -- 250ms entre disparos = 4 disparos em 1 segundo
    end
    
    Fluent:Notify({
        Title = "Zyro hub",
        Content = "Aim Kill executado! (4x disparos)",
        Duration = 1
    })
    
    -- Libera o botão após 1 segundo total
    task.wait(1)
    AimKillCooldown = false
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
    Content = "Hotkey: T (Teleport to nearest enemy) | Click para disparar"
})

-- Silent Aim Toggle
local SilentAimToggle = Tabs.Combat:AddToggle("SilentAimToggle", {
    Title = "Enable Silent Aim",
    Default = false
})

SilentAimToggle:OnChanged(function(Value)
    SilentAimEnabled = Value
    if Value then
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Silent Aim ativado! Click para disparar.",
            Duration = 2
        })
    else
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Silent Aim desativado.",
            Duration = 2
        })
    end
end)

-- FOV Slider
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

-- Prediction Slider
Tabs.Combat:AddSlider("PredictionSlider", {
    Title = "Silent Aim Prediction",
    Default = 0.22,
    Min = 0.1,
    Max = 1.0,
    Rounding = 2,
    Callback = function(Value)
        PredictionFactor = Value
    end
})

-- Aim Kill Toggle
local AimKillToggle = Tabs.Combat:AddToggle("AimKillToggle", {
    Title = "Enable Aim Kill (One Click = 4x Shots)",
    Default = false
})

AimKillToggle:OnChanged(function(Value)
    AimKillEnabled = Value
    if Value then
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Aim Kill ativado! Click para disparar 4x.",
            Duration = 2
        })
    else
        Fluent:Notify({
            Title = "Zyro hub",
            Content = "Aim Kill desativado.",
            Duration = 2
        })
        end
         end
end)

-- Aim Kill Button
Tabs.Combat:AddButton({
    Title = "Execute Aim Kill (Hotkey: C)",
    Description = "Click único = 4 disparos em 1 segundo",
    Callback = function()
        if AimKillEnabled then
            ExecuteAimKill()
        else
            Fluent:Notify({
                Title = "Zyro hub",
                Content = "Ative Aim Kill primeiro!",
                Duration = 2
            })
        end
    end
})

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
    Title = "Enable ESP (Team Check)",
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
    -- WalkSpeed
    if WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = TargetWalkSpeed
    end

    -- Fly Loop
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local moveDir = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if BodyVelocity and BodyGyro then
            BodyVelocity.Velocity = moveDir * FlySpeed
            BodyGyro.CFrame = Camera.CFrame
        end
    end

    -- ESP Loop
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character then
                ApplyHighlight(player)
            else
                RemoveHighlight(player)
            end
        end
    end

    -- Hitbox Loop
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

    -- Underplayer Loop
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Silent Aim - Disparo ao clicar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Silent Aim Logic
    if SilentAimEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        local targetPart = GetClosestEnemyInFOV()
        
        if targetPart and ShootRemote then
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

    -- Hotkeys
    if input.KeyCode == Enum.KeyCode.T then
        TeleportToNearestPlayer()
    elseif input.KeyCode == Enum.KeyCode.F then
        FlyToggle:SetValue(not FlyEnabled)
    elseif input.KeyCode == Enum.KeyCode.R then
        UnderToggle:SetValue(not UnderplayerEnabled)
    elseif input.KeyCode == Enum.KeyCode.G then
        TeleportUp()
    elseif input.KeyCode == Enum.KeyCode.C then
        if AimKillEnabled then
            ExecuteAimKill()
        end
    end
end)

-- Initial Tab
Window:SelectTab(1)

Fluent:Notify({
    Title = "Zyro hub",
    Content = "Zyro Hub com Silent Aim + Aim Kill carregado!",
    Duration = 5
})
