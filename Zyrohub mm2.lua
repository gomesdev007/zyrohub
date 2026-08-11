-- Carregamento da Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Variáveis de Controle: Movimento
local TargetWalkSpeed = 16
local InfJumpEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local BodyVelocity = nil
local BodyGyro = nil

-- Variáveis de Controle: Combate
local HitboxEnabled = false
local HitboxSize = 10
local ESPEnabled = false

-- Variáveis de Controle: Underplayer
local UnderplayerEnabled = false
local SurfacePosition = nil
local VisualClones = {}

-- Criando a Janela
local Window = Fluent:CreateWindow({
    Title = "Zyro hub",
    SubTitle = "creator:gomes.wqq",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Light",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Criando Abas
local Tabs = {
    Main = Window:AddTab({ Title = "Movimento", Icon = "plane" }),
    Combat = Window:AddTab({ Title = "Combate / TP", Icon = "crosshair" }),
    Under = Window:AddTab({ Title = "Underplayer", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
}

-- [[ ABA MOVIMENTO ]] --

Tabs.Main:AddParagraph({
    Title = "Controles de Movimentação",
    Content = "Atalhos: F (Fly) | G (TP Up +40 studs)"
})

-- Speed Hack
Tabs.Main:AddSlider("WalkSpeedSlider", {
    Title = "Velocidade de Caminhada (WalkSpeed)",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        TargetWalkSpeed = Value
    end
})

-- Pulo Infinito
local InfJumpToggle = Tabs.Main:AddToggle("InfJumpToggle", {
    Title = "Pulo Infinito",
    Default = false
})

InfJumpToggle:OnChanged(function(Value)
    InfJumpEnabled = Value
end)

-- Sistema de Fly
local function ToggleFly(state)
    FlyEnabled = state
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    if FlyEnabled then
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.P = 9e4
        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.CFrame = hrp.CFrame
        BodyGyro.Parent = hrp

        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Parent = hrp

        humanoid.PlatformStand = true
    else
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
        humanoid.PlatformStand = false
    end
end

local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Ativar Fly",
    Default = false
})

FlyToggle:OnChanged(function(Value)
    ToggleFly(Value)
end)

Tabs.Main:AddSlider("FlySpeedSlider", {
    Title = "Velocidade do Fly",
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
        Content = "Teleportado 40 studs para cima!",
        Duration = 2
    })
end

Tabs.Main:AddButton({
    Title = "TP Up (+40 Studs)",
    Description = "Subir 40 studs (Atalho: G)",
    Callback = function()
        TeleportUp()
    end
})

-- [[ ABA COMBATE / TP ]] --

Tabs.Combat:AddParagraph({
    Title = "Funções de Combate",
    Content = "Atalho: T (Teleportar para jogador mais próximo)"
})

-- Hitbox Customizada
local HitboxToggle = Tabs.Combat:AddToggle("HitboxToggle", {
    Title = "Ativar Hitbox Customizada",
    Default = false
})

HitboxToggle:OnChanged(function(Value)
    HitboxEnabled = Value
    if not Value then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = 1
                player.Character.HumanoidRootPart.CanCollide = true
            end
        end
    end
end)

Tabs.Combat:AddSlider("HitboxSlider", {
    Title = "Tamanho da Hitbox",
    Default = 10,
    Min = 2,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        HitboxSize = Value
    end
})

-- ESP Highlight
local ESPToggle = Tabs.Combat:AddToggle("ESPToggle", {
    Title = "Ativar ESP (Wallhack)",
    Default = false
})

ESPToggle:OnChanged(function(Value)
    ESPEnabled = Value
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Value then
                if not player.Character:FindFirstChild("ZyroHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ZyroHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = player.Character
                end
            else
                local hl = player.Character:FindFirstChild("ZyroHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
end)

-- TP Player
local function TeleportToNearestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local myHrp = myChar.HumanoidRootPart
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
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
        Fluent:Notify({ Title = "Zyro hub", Content = "Teleportado para o jogador!", Duration = 2 })
    else
        Fluent:Notify({ Title = "Zyro hub", Content = "Nenhum jogador válido encontrado.", Duration = 3 })
    end
end

Tabs.Combat:AddButton({
    Title = "Teleportar para Jogador Próximo (Atalho: T)",
    Callback = function()
        TeleportToNearestPlayer()
    end
})

-- [[ ABA UNDERPLAYER ]] --

Tabs.Under:AddParagraph({
    Title = "Modo Underplayer",
    Content = "Atalho: R (Desce -10 studs da posição da superfície e congela. Ao desativar, retorna exatamente para onde ativou)."
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
        -- Guarda a posição EXATA da superfície
        SurfacePosition = hrp.CFrame
        
        -- Move 10 studs para baixo e congela
        hrp.CFrame = SurfacePosition * CFrame.new(0, -10, 0)
        hrp.Anchored = true

        Fluent:Notify({ Title = "Zyro hub", Content = "Underplayer Ativado! Posição salva.", Duration = 2 })
    else
        -- Descongela e volta EXATAMENTE para o local onde foi ativado na superfície
        hrp.Anchored = false
        if SurfacePosition then
            hrp.CFrame = SurfacePosition
            SurfacePosition = nil
        end
        CleanClones()

        -- Restaura Hitboxes
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = 1
            end
        end

        Fluent:Notify({ Title = "Zyro hub", Content = "Underplayer Desativado! Retornado à superfície.", Duration = 2 })
    end
end

local UnderToggle = Tabs.Under:AddToggle("UnderToggle", {
    Title = "Ativar Underplayer (Atalho: R)",
    Default = false
})

UnderToggle:OnChanged(function(Value)
    if Value ~= UnderplayerEnabled then
        ToggleUnderplayer(Value)
    end
end)

-- [[ ABA CONFIGURAÇÕES ]] --

local ThemeDropdown = Tabs.Settings:AddDropdown("ThemeManager", {
    Title = "Tema da Interface",
    Values = {"Light", "Dark", "Darker", "Aqua", "Amethyst"},
    Multi = false,
    Default = "Light",
})

ThemeDropdown:OnChanged(function(Value)
    Fluent:SetTheme(Value)
end)

-- [[ LOOPS E ATALHOS ]] --

RunService.RenderStepped:Connect(function()
    -- Aplica Velocidade Personalizada
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
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

    -- Loop de Hitbox Padrão
    if HitboxEnabled and not UnderplayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

    -- Loop do Underplayer (Hitbox 20 no pé + Clone 8 studs abaixo)
    if UnderplayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
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

-- Pulo Infinito
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Atribuição dos Atalhos de Teclado
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

-- Seleção da Aba Inicial
Window:SelectTab(1)

Fluent:Notify({
    Title = "Zyro hub",
    Content = "Zyro Hub carregado! Teclas: T (TP) | F (Fly) | R (Under) | G (TP Up)",
    Duration = 5
})
