--[[
    ╔════════════════════════════════════════════════════════════════════════════╗
    ║                                                                            ║
    ║                     🔥 ZYRO HUB - MURDERS VS SHERIFF 🔥                   ║
    ║                                                                            ║
    ║                    COMPLETE & PERFECT SCRIPT v3.0                         ║
    ║                     Desenvolvido por: gomes.wqq                           ║
    ║                                                                            ║
    ║  WARNING: This script has not been verified by ScriptBlox.                ║
    ║  Use at your own risk!                                                    ║
    ║                                                                            ║
    ╚════════════════════════════════════════════════════════════════════════════╝
]]

-- ======================= LOAD WINDUI =======================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua"))()

-- ======================= SERVICES =======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ======================= CHARACTER SETUP =======================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ======================= FEATURE VARIABLES =======================
local Features = {
    -- Combat
    KillAll = false,
    KillSheriff = false,
    
    -- Sheriff
    Aimbot = false,
    AutoCollectGun = false,
    
    -- ESP
    ESPMurders = false,
    ESPSheriff = false,
    
    -- Movement
    SpeedValue = 16,
    JumpPowerValue = 50,
    PouInfinito = false,
    
    -- Misc
    AntiAFK = false,
    AutoFarm = false,
    
    -- Settings
    AimbotFOV = 300,
    OriginalPosition = nil,
    SherifDead = false,
}

-- ======================= WINDUI THEME SETUP =======================
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

-- ======================= CREATE WINDOW =======================
local Window = WindUI:CreateWindow({
    Title = "ZYRO HUB",
    Author = "by gomes.wqq",
    Folder = "zyro_hub",
    Icon = "zap",
    Theme = "Dark",
    Acrylic = true,
    Transparent = true,
    Background = "rbxassetid://84152360484913",
    Size = UDim2.fromOffset(680, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    Resizable = true,
    AutoScale = true,
    NewElements = true,
    BackgroundImageTransparency = 0.65,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    SideBarWidth = 200,
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },
    OpenButton = {
        Title = "ZYRO HUB",
        Icon = "zap",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(
            Color3.fromHex("#000000"),
            Color3.fromHex("#000000")
        ),
    },
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "ZYRO HUB",
                Content = "Developed by gomes.wqq | Murders vs Sheriff",
            })
        end,
    },
})

-- ======================= COMBAT TAB =======================
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "target"
})

CombatTab:Label({
    Title = "Murder Functions",
})

CombatTab:Button({
    Title = "Kill All",
    Desc = "Mata todos os jogadores",
    Callback = function()
        if Features.KillAll then
            Features.KillAll = false
            WindUI:Notify({
                Title = "Kill All",
                Content = "Desativado!",
            })
            return
        end
        
        Features.KillAll = true
        WindUI:Notify({
            Title = "Kill All",
            Content = "Executando...",
        })
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                
                if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
                    -- Puxa jogador para frente
                    local direction = (targetHRP.Position - RootPart.Position).Unit
                    local pushPos = RootPart.CFrame + RootPart.CFrame.LookVector * 10
                    targetHRP.CFrame = pushPos
                    
                    wait(0.1)
                    
                    -- Pega a faca
                    local knife = Character:FindFirstChild("Knife")
                    if not knife then
                        for _, tool in pairs(Character:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
                                knife = tool
                                break
                            end
                        end
                    end
                    
                    if knife then
                        knife.Parent = Character
                        knife.Grip = CFrame.new(0, 0, -5)
                    end
                    
                    wait(0.05)
                    
                    -- Simula clique
                    local clickEvent = knife and knife:FindFirstChild("Activated")
                    if knife and knife:FindFirstChild("Handle") then
                        Mouse.Target = targetHumanoid.Parent
                        wait(0.05)
                    end
                    
                    wait(0.2)
                end
            end
        end
        
        Features.KillAll = false
        WindUI:Notify({
            Title = "Kill All",
            Content = "Completo!",
        })
    end
})

CombatTab:Button({
    Title = "Kill Sheriff",
    Desc = "Mata apenas o xerife",
    Callback = function()
        if Features.KillSheriff then
            Features.KillSheriff = false
            WindUI:Notify({
                Title = "Kill Sheriff",
                Content = "Desativado!",
            })
            return
        end
        
        Features.KillSheriff = true
        WindUI:Notify({
            Title = "Kill Sheriff",
            Content = "Procurando xerife...",
        })
        
        for _, player in pairs(Players:GetPlayers()) do
            local role = player:FindFirstChild("Role")
            if role and role.Value == "Sheriff" then
                local targetChar = player.Character
                if targetChar then
                    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                    
                    if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
                        local direction = (targetHRP.Position - RootPart.Position).Unit
                        local pushPos = RootPart.CFrame + RootPart.CFrame.LookVector * 10
                        targetHRP.CFrame = pushPos
                        
                        wait(0.1)
                        
                        local knife = Character:FindFirstChild("Knife")
                        if not knife then
                            for _, tool in pairs(Character:GetChildren()) do
                                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
                                    knife = tool
                                    break
                                end
                            end
                        end
                        
                        if knife then
                            knife.Parent = Character
                            knife.Grip = CFrame.new(0, 0, -5)
                        end
                        
                        wait(0.05)
                        
                        if knife and knife:FindFirstChild("Handle") then
                            Mouse.Target = targetHumanoid.Parent
                            wait(0.05)
                        end
                        
                        wait(0.2)
                    end
                end
                break
            end
        end
        
        Features.KillSheriff = false
        WindUI:Notify({
            Title = "Kill Sheriff",
            Content = "Completo!",
        })
    end
})

-- ======================= SHERIFF TAB =======================
local SherifTab = Window:Tab({
    Title = "Sheriff",
    Icon = "shield"
})

SherifTab:Label({
    Title = "Sheriff Features",
})

SherifTab:Toggle({
    Title = "Aimbot",
    Value = false,
    Callback = function(state)
        Features.Aimbot = state
        
        if Features.Aimbot then
            WindUI:Notify({
                Title = "Aimbot",
                Content = "Ativado! FOV: " .. Features.AimbotFOV,
            })
            
            local AimbotConnection
            AimbotConnection = RunService.RenderStepped:Connect(function()
                if not Features.Aimbot then
                    AimbotConnection:Disconnect()
                    return
                end
                
                local closestPlayer = nil
                local closestDistance = Features.AimbotFOV
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        local targetTorso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        
                        if targetHRP and targetTorso and humanoid and humanoid.Health > 0 then
                            local distance = (targetHRP.Position - RootPart.Position).Magnitude
                            
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = targetTorso
                            end
                        end
                    end
                end
                
                if closestPlayer then
                    local newCFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Position + closestPlayer.CFrame.LookVector * 0.6)
                    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.08)
                end
            end)
        else
            WindUI:Notify({
                Title = "Aimbot",
                Content = "Desativado!",
            })
        end
    end
})

SherifTab:Slider({
    Title = "Aimbot FOV",
    Min = 50,
    Max = 500,
    Default = 300,
    Callback = function(value)
        Features.AimbotFOV = value
    end
})

SherifTab:Toggle({
    Title = "Auto Collect Gun",
    Value = false,
    Callback = function(state)
        Features.AutoCollectGun = state
        Features.OriginalPosition = RootPart.CFrame
        Features.SherifDead = false
        
        if Features.AutoCollectGun then
            WindUI:Notify({
                Title = "Auto Collect Gun",
                Content = "Monitorando xerife...",
            })
            
            local CollectConnection
            CollectConnection = RunService.Heartbeat:Connect(function()
                if not Features.AutoCollectGun then
                    CollectConnection:Disconnect()
                    return
                end
                
                for _, player in pairs(Players:GetPlayers()) do
                    local role = player:FindFirstChild("Role")
                    if role and role.Value == "Sheriff" then
                        local targetChar = player.Character
                        if targetChar then
                            local humanoid = targetChar:FindFirstChild("Humanoid")
                            
                            if humanoid and humanoid.Health <= 0 and not Features.SherifDead then
                                Features.SherifDead = true
                                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                                
                                if targetHRP and Features.OriginalPosition then
                                    RootPart.CFrame = targetHRP.CFrame + Vector3.new(0, 2, 0)
                                    wait(1)
                                    RootPart.CFrame = Features.OriginalPosition
                                    
                                    WindUI:Notify({
                                        Title = "Auto Collect Gun",
                                        Content = "Gun coletada!",
                                    })
                                end
                            end
                        end
                        break
                    end
                end
            end)
        else
            WindUI:Notify({
                Title = "Auto Collect Gun",
                Content = "Desativado!",
            })
        end
    end
})

-- ======================= ESP TAB =======================
local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "eye"
})

ESPTab:Label({
    Title = "Visual Features",
})

ESPTab:Toggle({
    Title = "ESP Murders (RED)",
    Value = false,
    Callback = function(state)
        Features.ESPMurders = state
        
        if Features.ESPMurders then
            WindUI:Notify({
                Title = "ESP Murders",
                Content = "Ativado! Vermelho",
            })
            
            local ESPConnection
            ESPConnection = RunService.Heartbeat:Connect(function()
                if not Features.ESPMurders then
                    ESPConnection:Disconnect()
                    return
                end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local role = player:FindFirstChild("Role")
                        if role and role.Value == "Murderer" then
                            for _, part in pairs(player.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.fromRGB(255, 0, 0)
                                    part.Material = Enum.Material.Neon
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.CanCollide = true
                        end
                    end
                end
            end
            
            WindUI:Notify({
                Title = "ESP Murders",
                Content = "Desativado!",
            })
        end
    end
})

ESPTab:Toggle({
    Title = "ESP Sheriff (BLUE)",
    Value = false,
    Callback = function(state)
        Features.ESPSheriff = state
        
        if Features.ESPSheriff then
            WindUI:Notify({
                Title = "ESP Sheriff",
                Content = "Ativado! Azul",
            })
            
            local ESPConnection
            ESPConnection = RunService.Heartbeat:Connect(function()
                if not Features.ESPSheriff then
                    ESPConnection:Disconnect()
                    return
                end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local role = player:FindFirstChild("Role")
                        if role and role.Value == "Sheriff" then
                            for _, part in pairs(player.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.fromRGB(0, 100, 255)
                                    part.Material = Enum.Material.Neon
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.CanCollide = true
                        end
                    end
                end
            end
            
            WindUI:Notify({
                Title = "ESP Sheriff",
                Content = "Desativado!",
            })
        end
    end
})

-- ======================= MOVEMENT TAB =======================
local MovementTab = Window:Tab({
    Title = "Movement",
    Icon = "move"
})

MovementTab:Label({
    Title = "Speed Controls",
})

MovementTab:Slider({
    Title = "Player Speed",
    Min = 1,
    Max = 150,
    Default = 16,
    Callback = function(value)
        Features.SpeedValue = value
        if Humanoid then
            Humanoid.WalkSpeed = value
        end
    end
})

MovementTab:Slider({
    Title = "Jump Power",
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(value)
        Features.JumpPowerValue = value
        if Humanoid then
            Humanoid.JumpPower = value
        end
    end
})

MovementTab:Toggle({
    Title = "Infinite Jump (Pou)",
    Value = false,
    Callback = function(state)
        Features.PouInfinito = state
        
        if Features.PouInfinito then
            WindUI:Notify({
                Title = "Infinite Jump",
                Content = "Ativado! Pressione SPACE",
            })
            
            local PouConnection
            PouConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if not Features.PouInfinito then
                    PouConnection:Disconnect()
                    return
                end
                
                if input.KeyCode == Enum.KeyCode.Space then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            Wind
