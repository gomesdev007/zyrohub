--[[
	XENO EXPLOIT - Script Completo com UI Library
	Apenas as funções solicitadas
]]

--// Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Verificação
if not LocalPlayer then
    warn("Erro: LocalPlayer não encontrado!")
    return
end

--// Carregar Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()

--// Criar Janela
local Window = Library:CreateWindow({
    Title = "XENO EXPLOIT",
    Theme = "Dark",
    Size = UDim2.fromOffset(570, 500),
    Transparency = 0.1,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

--// Estado das Funções
local Features = {
    CustomHitbox = false,
    HitboxSize = 1,
    CamLock = false,
    SpeedBoost = false,
    Fly = false,
    NoClip = false,
    TPPlayer = false,
    TPFly = false,
}

local flying = false

--// Tema Xeno (Preto e Branco)
local XenoTheme = {
    --// Frames:
    Primary = Color3.fromRGB(10, 10, 10),
    Secondary = Color3.fromRGB(15, 15, 15),
    Component = Color3.fromRGB(20, 20, 20),
    Interactables = Color3.fromRGB(25, 25, 25),

    --// Text:
    Tab = Color3.fromRGB(255, 255, 255),
    Title = Color3.fromRGB(255, 255, 255),
    Description = Color3.fromRGB(200, 200, 200),

    --// Outlines:
    Shadow = Color3.fromRGB(0, 0, 0),
    Outline = Color3.fromRGB(50, 50, 50),

    --// Image:
    Icon = Color3.fromRGB(255, 255, 255),
}

--// Aplicar Tema Xeno
Window:SetTheme(XenoTheme)

--// Adicionar Seções de Abas
Window:AddTabSection({
    Name = "Functions",
    Order = 1,
})

Window:AddTabSection({
    Name = "Settings",
    Order = 2,
})

--// Tab COMBAT
local Combat = Window:AddTab({
    Title = "Combat",
    Section = "Functions",
    Icon = "rbxassetid://11963373994"
})

Window:AddSection({ Name = "Custom Hitbox", Tab = Combat })

Window:AddToggle({
    Title = "Custom Hitbox",
    Description = "Ativa/Desativa o hitbox customizado",
    Tab = Combat,
    Callback = function(Boolean)
        Features.CustomHitbox = Boolean
    end,
})

Window:AddSlider({
    Title = "Tamanho do Hitbox",
    Description = "Ajuste o tamanho do seu hitbox (1-50)",
    Tab = Combat,
    MaxValue = 50,
    MinValue = 1,
    Default = 1,
    Callback = function(Amount)
        Features.HitboxSize = Amount
    end,
})

--// Tab MOVEMENT
local Movement = Window:AddTab({
    Title = "Movement",
    Section = "Functions",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Velocidade", Tab = Movement })

Window:AddToggle({
    Title = "Speed Boost [V]",
    Description = "Aumenta sua velocidade para 30",
    Tab = Movement,
    Callback = function(Boolean)
        Features.SpeedBoost = Boolean
    end,
})

Window:AddSection({ Name = "Voo", Tab = Movement })

Window:AddToggle({
    Title = "Fly [F]",
    Description = "Ativa/Desativa o modo voo (Use W/A/S/D)",
    Tab = Movement,
    Callback = function(Boolean)
        Features.Fly = Boolean
    end,
})

Window:AddSection({ Name = "Passagem", Tab = Movement })

Window:AddToggle({
    Title = "No-Clip [N]",
    Description = "Passa através de paredes e objetos",
    Tab = Movement,
    Callback = function(Boolean)
        Features.NoClip = Boolean
    end,
})

--// Tab TELEPORT
local Teleport = Window:AddTab({
    Title = "Teleport",
    Section = "Functions",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Teleportação", Tab = Teleport })

Window:AddButton({
    Title = "TP Player Mais Próximo [T]",
    Description = "Teleporta para o player mais próximo",
    Tab = Teleport,
    Callback = function()
        Features.TPPlayer = true
    end,
})

Window:AddButton({
    Title = "TP Fly Up [Y]",
    Description = "Teleporta 30 studs para cima",
    Tab = Teleport,
    Callback = function()
        Features.TPFly = true
    end,
})

--// Tab AIMING
local Aiming = Window:AddTab({
    Title = "Aiming",
    Section = "Functions",
    Icon = "rbxassetid://11963373994"
})

Window:AddSection({ Name = "Câmera", Tab = Aiming })

Window:AddToggle({
    Title = "Cam-Lock [Z]",
    Description = "Câmera gruda no alvo mais próximo (300 studs)",
    Tab = Aiming,
    Callback = function(Boolean)
        Features.CamLock = Boolean
    end,
})

--// Tab SETTINGS
local Settings = Window:AddTab({
    Title = "Settings",
    Section = "Settings",
    Icon = "rbxassetid://11293977610"
})

Window:AddSection({ Name = "Tema", Tab = Settings })

Window:AddDropdown({
    Title = "Escolha o Tema",
    Description = "Mude o tema da interface",
    Tab = Settings,
    Options = {
        ["Dark Mode"] = "Dark",
        ["Extra Dark"] = "ExtraDark",
    },
    Callback = function(Theme)
        if Theme == "Dark" then
            Window:SetTheme(XenoTheme)
        elseif Theme == "ExtraDark" then
            local ExtraDarkTheme = {
                Primary = Color3.fromRGB(5, 5, 5),
                Secondary = Color3.fromRGB(10, 10, 10),
                Component = Color3.fromRGB(15, 15, 15),
                Interactables = Color3.fromRGB(20, 20, 20),
                Tab = Color3.fromRGB(255, 255, 255),
                Title = Color3.fromRGB(255, 255, 255),
                Description = Color3.fromRGB(200, 200, 200),
                Shadow = Color3.fromRGB(0, 0, 0),
                Outline = Color3.fromRGB(40, 40, 40),
                Icon = Color3.fromRGB(255, 255, 255),
            }
            Window:SetTheme(ExtraDarkTheme)
        end
    end,
})

Window:AddToggle({
    Title = "Blur UI",
    Description = "Ativa/Desativa o efeito de blur",
    Tab = Settings,
    Default = true,
    Callback = function(Boolean)
        Window:SetSetting("Blur", Boolean)
    end,
})

Window:AddSlider({
    Title = "Transparência UI",
    Description = "Ajuste a transparência da interface",
    Tab = Settings,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(Amount)
        Window:SetSetting("Transparency", Amount)
    end,
})

--// Notificação de Carregamento
Window:Notify({
    Title = "✅ Script Carregado!",
    Description = "XENO EXPLOIT está funcionando! Pressione Left Alt para minimizar.",
    Duration = 5
})

--// ========== IMPLEMENTAÇÃO DAS FEATURES ==========

--// Custom Hitbox
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

--// Speed Boost
RunService.RenderStepped:Connect(function()
    if Features.SpeedBoost and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.AssemblyLinearVelocity then
            pcall(function()
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = vel.Unit * 30
                else
                    hrp.AssemblyLinearVelocity = Camera.CFrame.LookVector * 30
                end
            end)
        end
    end
end)

--// Fly System
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

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

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

--// No-Clip
RunService.RenderStepped:Connect(function()
    if Features.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = false
                end)
            end
        end
    end
end)

--// Cam Lock
local function GetClosestPlayerInRadius()
    local closestPlayer = nil
    local closestDistance = 300

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if targetHRP and playerHRP then
                local distance = (targetHRP.Position - playerHRP.Position).Magnitude

                if distance < closestDistance then
                    pcall(function()
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

                        local result = workspace:Raycast(playerHRP.Position, (targetHRP.Position - playerHRP.Position).Unit * 300, raycastParams)

                        if not result or (result.Instance and result.Instance:IsDescendantOf(player.Character)) then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end)
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if Features.CamLock then
        local target = GetClosestPlayerInRadius()
        if target and target.Character then
            local targetChest = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso")
            if targetChest then
                pcall(function()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetChest.Position)
                end)
            end
        end
    end
end)

--// TP Player
local function TPToClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if targetHRP and playerHRP and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (targetHRP.Position - playerHRP.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    if closestPlayer and closestPlayer.Character then
        local targetHRP = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        local playerHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and playerHRP then
            pcall(function()
                playerHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 2)
            end)
            Window:Notify({
                Title = "✅ Teleportado!",
                Description = "Você foi teleportado para " .. closestPlayer.Name,
                Duration = 3
            })
        end
    else
        Window:Notify({
            Title = "❌ Erro!",
            Description = "Nenhum player próximo encontrado",
            Duration = 3
        })
    end
end

--// TP Fly Up
local function TPFlyUp()
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
            end)
            Window:Notify({
                Title = "✅ Teleportado!",
                Description = "Você voou 30 studs para cima",
                Duration = 3
            })
        end
    end
end

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.V then
        Features.SpeedBoost = not Features.SpeedBoost
    elseif input.KeyCode == Enum.KeyCode.F then
        Features.Fly = not Features.Fly
    elseif input.KeyCode == Enum.KeyCode.N then
        Features.NoClip = not Features.NoClip
    elseif input.KeyCode == Enum.KeyCode.Z then
        Features.CamLock = not Features.CamLock
    elseif input.KeyCode == Enum.KeyCode.T then
        TPToClosestPlayer()
    elseif input.KeyCode == Enum.KeyCode.Y then
        TPFlyUp()
    end
end)

print("✅ XENO EXPLOIT CARREGADO COM SUCESSO!")
print("📋 Funcionalidades: Cam Lock | Custom Hitbox | Speed Boost | Fly | No-Clip | TP Player | TP Fly")
