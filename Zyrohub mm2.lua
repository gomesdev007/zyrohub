-- Fluent UI Loader
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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
    MinimizeKey = Enum.KeyCode.LeftControl
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
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Transparency = 1
        hrp.CanCollide = true
        hrp.Material = Enum.Material.Plastic
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

-- [[ MOVEMENT TAB ]] --

Tabs.Main:AddParagraph({
    Title = "Movement Controls",
    Content = "Hotkeys: F (Fly) | G (TP Up +40 studs)"
})

-- WalkSpeed Toggle
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

-- Infinite Jump Toggle
local InfJumpToggle = Tabs.Main:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Default = false
})

InfJumpToggle:OnChanged(function(Value)
    InfJumpEnabled = Value
end)

-- Fly System
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

-- TP Up
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

-- Custom Hitbox
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

-- ESP Highlight with Team Check
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

-- TP Player with Team Check
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
    Content = "Hotkey: R (Teleports -10 studs under surface position and freezes. Disabling restores surface position)."
})

local function CleanClones()
    for _, clone in pairs(VisualClones) do
        if clone and clone.Parent then
            clone:Destroy()
        end
    end
    VisualClones = {}
end

local function ToggleUnderplayer(state)
    UnderplayerEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if UnderplayerEnabled then
        SurfacePosition = hrp.CFrame
        hrp.CFrame = SurfacePosition * CFrame.new(0, -10, 0)
        hrp.Anchored = true

        Fluent:Notify({ Title = "Zyro hub", Content = "Underplayer Enabled! Position saved.", Duration = 2 })
    else
        hrp.Anchored = false
        if SurfacePosition then
            hrp.CFrame = SurfacePosition
            SurfacePosition = nil
        end
        CleanClones()

        if not HitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    ResetPlayerHitbox(player)
                end
            end
        end

        Fluent:Notify({ Title = "Zyro hub", Content = "Underplayer Disabled! Returned to surface.", Duration = 2 })
    end
end

local UnderToggle = Tabs.Under:AddToggle("UnderToggle", {
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
    -- Apply Custom WalkSpeed
    if WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = TargetWalkSpeed
    end

    -- Fly Loop
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

    -- ESP Re-validation Loop
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character then
                ApplyHighlight(player)
            else
                RemoveHighlight(player)
            end
        end
    end

    -- Standard Custom Hitbox Loop
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

                    local cloneName = "UnderClone_" .. player.Name
                    local clonePart = Workspace:FindFirstChild(cloneName)

                    if not clonePart then
                        clonePart = Instance.new("Part")
                        clonePart.Name = cloneName
                        clonePart.Size = Vector3.new(2, 4, 2)
                        clonePart.BrickColor = BrickColor.new("Bright red")
                        clonePart.Material = Enum.Material.Neon
                        clonePart.Anchored = true
                        clonePart.CanCollide = false
                        clonePart.Parent = Workspace
                        table.insert(VisualClones, clonePart)
                    end

                    clonePart.CFrame = hrp.CFrame * CFrame.new(0, -8, 0)
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

-- Hotkey Binds
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

-- Default Initial Tab Selection
Window:SelectTab(1)

Fluent:Notify({
    Title = "Zyro hub",
    Content = "Zyro Hub loaded! Persist/Team Check Active. Hotkeys: T (TP) | F (Fly) | R (Under) | G (TP Up)",
    Duration = 5
})
