--[[
    ZYRO HUB - Murders vs Sheriff Script
    Créditos: gomes.wqq
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Variáveis de controle
local killAllActive = false
local killSherifActive = false
local aimbotActive = false
local autoCollectActive = false
local espMurdersActive = false
local espSherifActive = false
local pouInfinitoActive = false
local autoFarmActive = false
local playerSpeed = 16
local jumpPower = 50
local aimbotFOV = 300

local originalPosition = nil

-- Tema Dark
WindUI:AddTheme({
    Name = "Dark",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})

-- Janela Principal
local Window = WindUI:CreateWindow({
    Title   = "ZYRO HUB",
    Author  = "gomes.wqq",
    Folder  = "zyro_hub",
    Icon    = "zap",
    Theme   = "Dark",
    Acrylic = true,
    Transparent = true,
    Background = "rbxassetid://84152360484913",
    Size    = UDim2.fromOffset(680, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey  = Enum.KeyCode.RightShift,
    Resizable  = true,
    AutoScale  = true,
    NewElements = true,
    BackgroundImageTransparency = 0.65,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    SideBarWidth = 200,
})

-- ==================== ABA COMBAT ====================
local CombatTab = Window:Tab({ Title = "Combat", Icon = "target" })

CombatTab:Label({ Text = "Murder Functions" })

CombatTab:Button({
    Title = "Kill All",
    Callback = function()
        if killAllActive then return end
        killAllActive = true
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                
                if targetHRP then
                    -- Puxa o jogador para frente
                    local direction = (targetHRP.Position - RootPart.Position).Unit
                    targetHRP.CFrame = RootPart.CFrame + direction * 5
                    
                    -- Equipa a faca e clica
                    local knife = Character:FindFirstChild("Knife") or workspace:FindFirstChild("Knife")
                    if knife then
                        knife.Parent = Character
                    end
                    
                    -- Simula o clique
                    mouse1click()
                    wait(0.3)
                end
            end
        end
        
        killAllActive = false
        WindUI:Notify({ Title = "Kill All", Content = "Executado!" })
    end
})

CombatTab:Button({
    Title = "Kill Sheriff",
    Callback = function()
        if killSherifActive then return end
        killSherifActive = true
        
        for _, player in pairs(Players:GetPlayers()) do
            if player:FindFirstChild("Role") and player.Role.Value == "Sheriff" then
                local targetChar = player.Character
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                
                if targetHRP then
                    -- Puxa o xerife para frente
                    local direction = (targetHRP.Position - RootPart.Position).Unit
                    targetHRP.CFrame = RootPart.CFrame + direction * 5
                    
                    -- Equipa a faca
                    local knife = Character:FindFirstChild("Knife") or workspace:FindFirstChild("Knife")
                    if knife then
                        knife.Parent = Character
                    end
                    
                    -- Clica
                    mouse1click()
                    wait(0.3)
                end
                break
            end
        end
        
        killSherifActive = false
        WindUI:Notify({ Title = "Kill Sheriff", Content = "Executado!" })
    end
})

-- ==================== ABA SHERIFF ====================
local SherifTab = Window:Tab({ Title = "Sheriff", Icon = "shield" })

SherifTab:Label({ Text = "Sheriff Features" })

SherifTab:Toggle({
    Title = "Aimbot",
    Value = false,
    Callback = function(state)
        aimbotActive = state
        if aimbotActive then
            WindUI:Notify({ Title = "Aimbot", Content = "Ativado!" })
            
            RunService.RenderStepped:Connect(function()
                if not aimbotActive then return end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetChar = player.Character
                        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                        local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
                        
                        if targetHRP and targetTorso then
                            local distance = (targetHRP.Position - RootPart.Position).Magnitude
                            
                            if distance < aimbotFOV then
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetTorso.Position)
                            end
                        end
                    end
                end
            end)
        else
            WindUI:Notify({ Title = "Aimbot", Content = "Desativado!" })
        end
    end
})

SherifTab:Slider({
    Title = "Aimbot FOV",
    Min = 100,
    Max = 500,
    Default = 300,
    Callback = function(value)
        aimbotFOV = value
    end
})

SherifTab:Toggle({
    Title = "Auto Collect Gun",
    Value = false,
    Callback = function(state)
        autoCollectActive = state
        if autoCollectActive then
            WindUI:Notify({ Title = "Auto Collect", Content = "Monitorando xerife..." })
            
            RunService.Heartbeat:Connect(function()
                if not autoCollectActive then return end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player:FindFirstChild("Role") and player.Role.Value == "Sheriff" then
                        local sheriffChar = player.Character
                        
                        if sheriffChar and not sheriffChar:FindFirstChild("Humanoid") or sheriffChar.Humanoid.Health <= 0 then
                            -- Sheriff morreu
                            originalPosition = RootPart.CFrame
                            local deathPos = sheriffChar:FindFirstChild("HumanoidRootPart")
                            
                            if deathPos then
                                RootPart.CFrame = deathPos.CFrame
                                wait(1)
                                RootPart.CFrame = originalPosition
                                WindUI:Notify({ Title = "Auto Gun", Content = "Gun coletada!" })
                            end
                        end
                        break
                    end
                end
            end)
        else
            WindUI:Notify({ Title = "Auto Collect", Content = "Desativado!" })
        end
    end
})

-- ==================== ABA ESP ====================
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

ESPTab:Label({ Text = "Visual Features" })

ESPTab:Toggle({
    Title = "ESP Murders",
    Value = false,
    Callback = function(state)
        espMurdersActive = state
        if espMurdersActive then
            WindUI:Notify({ Title = "ESP Murders", Content = "Ativado!" })
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromRGB(255, 0, 0) -- Vermelho
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
})

ESPTab:Toggle({
    Title = "ESP Sheriff",
    Value = false,
    Callback = function(state)
        espSherifActive = state
        if espSherifActive then
            WindUI:Notify({ Title = "ESP Sheriff", Content = "Ativado!" })
            
            for _, player in pairs(Players:GetPlayers()) do
                if player:FindFirstChild("Role") and player.Role.Value == "Sheriff" then
                    local char = player.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromRGB(0, 100, 255) -- Azul
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end
    end
})

-- ==================== ABA MOVEMENT ====================
local MovementTab = Window:Tab({ Title = "Movement", Icon = "move" })

MovementTab:Label({ Text = "Speed Controls" })

MovementTab:Slider({
    Title = "Velocidade",
    Min = 1,
    Max = 100,
    Default = 16,
    Callback = function(value)
        playerSpeed = value
        Humanoid.WalkSpeed = playerSpeed
    end
})

MovementTab:Slider({
    Title = "Força do Pulo",
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(value)
        jumpPower = value
        Humanoid.JumpPower = jumpPower
    end
})

MovementTab:Toggle({
    Title = "Pou Infinito",
    Value = false,
    Callback = function(state)
        pouInfinitoActive = state
        if pouInfinitoActive then
            WindUI:Notify({ Title = "Pou Infinito", Content = "Ativado!" })
            
            RunService.Heartbeat:Connect(function()
                if not pouInfinitoActive then return end
                Humanoid.Jump = true
                RootPart.Velocity = Vector3.new(RootPart.Velocity.X, 0, RootPart.Velocity.Z)
            end)
        else
            WindUI:Notify({ Title = "Pou Infinito", Content = "Desativado!" })
        end
    end
})

-- ==================== ABA MISC ====================
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

MiscTab:Label({ Text = "Miscellaneous" })

local antiAFKActive = false
MiscTab:Toggle({
    Title = "Anti AFK",
    Value = false,
    Callback = function(state)
        antiAFKActive = state
        if antiAFKActive then
            WindUI:Notify({ Title = "Anti AFK", Content = "Ativado!" })
            
            RunService.Heartbeat:Connect(function()
                if not antiAFKActive then return end
                -- Simula movimento para não dar AFK
                game:GetService("Players"):FindFirstChild(LocalPlayer.Name).Parent = Players
            end)
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(state)
        autoFarmActive = state
        if autoFarmActive then
            WindUI:Notify({ Title = "Auto Farm", Content = "Personagem travado no céu!" })
            
            -- Trava o personagem no céu
            RootPart.CFrame = CFrame.new(RootPart.Position + Vector3.new(0, 100, 0))
            RootPart.Velocity = Vector3.new(0, 0, 0)
            
            RunService.Heartbeat:Connect(function()
                if not autoFarmActive then return end
                RootPart.Velocity = Vector3.new(0, 0, 0)
            end)
        end
    end
})

-- ==================== ABA SETTINGS ====================
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Dropdown({
    Title  = "Theme",
    Values = (function()
        local names = {}
        for name in pairs(WindUI:GetThemes()) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end)(),
    Value    = WindUI:GetCurrentTheme(),
    Callback = function(selected)
        WindUI:SetTheme(selected)
    end,
})

SettingsTab:Toggle({
    Title = "Transparent",
    Value = false,
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

-- Notificação de Boas-vindas
WindUI:Notify({
    Title = "ZYRO HUB",
    Content = "Bem-vindo! Script by gomes.wqq",
})

print("✓ ZYRO HUB Carregado com sucesso!")
