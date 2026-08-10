-- Zyro Hub - Murders vs Xerife
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações do tema
WindUI:AddTheme({
    Name = "ZyroDark",
    Accent = Color3.fromHex("#ff0000"),
    Background = Color3.fromHex("#0d0d0d"),
    Outline = Color3.fromHex("#ff0000"),
    Text = Color3.fromHex("#ffffff"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#1a1a1a"),
    Icon = Color3.fromHex("#ff0000"),
})

-- Criar janela
local Window = WindUI:CreateWindow({
    Title   = "Zyro Hub",
    Author  = "by gomes.wqq",
    Folder  = "zyrohub",
    Icon    = "skull",
    Theme   = "ZyroDark",
    Acrylic = true,
    Transparent = true,
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
    Topbar = {
        Height      = 44,
        ButtonsType = "Default",
    },
    OpenButton = {
        Title = "Zyro Hub",
        Icon = "skull",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(
            Color3.fromHex("#ff0000"),
            Color3.fromHex("#8b0000")
        ),
    },
    User = {
        Enabled  = true,
        Anonymous = false,
        Callback = function()
            print("user panel clicked")
        end,
    },
})

-- Variáveis de controle
local killAllEnabled = false
local killSheriffEnabled = false
local aimbotEnabled = false
local autoCollectEnabled = false
local espMurderEnabled = false
local espSheriffEnabled = false
local antiAfkEnabled = false
local autoFarmEnabled = false
local infiniteJumpEnabled = false

-- Conexões
local connections = {}

-- Função para identificar papéis
local function getRole(player)
    local char = player.Character
    if not char then return nil end
    
    -- Verificar se é Murder (tem faca)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca") or tool.Name:lower():find("murder")) then
        return "Murder"
    end
    
    -- Verificar se é Xerife (tem arma)
    if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("arma") or tool.Name:lower():find("sheriff") or tool.Name:lower():find("xerife")) then
        return "Sheriff"
    end
    
    return "Innocent"
end

-- Função Kill All (Murder)
local function KillAll()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Pegar faca
    local knife = nil
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
            knife = tool
            break
        end
    end
    
    if not knife then
        -- Tentar pegar do inventário
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
                knife = tool
                break
            end
        end
    end
    
    -- Puxar todos para frente
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character.HumanoidRootPart
            local direction = (hrp.CFrame.LookVector * 10) + Vector3.new(0, 2, 0)
            target.CFrame = hrp.CFrame * CFrame.new(direction)
        end
    end
    
    -- Equipar faca
    if knife then
        char.Humanoid:EquipTool(knife)
        task.wait(0.1)
        
        -- Clicar
        local args = {
            [1] = Vector3.new(0, 0, 0),
            [2] = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 10)
        }
        
        -- Simular clique
        mouse1click()
    end
end

-- Função Kill Xerife
local function KillSheriff()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Pegar faca
    local knife = nil
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
            knife = tool
            break
        end
    end
    
    if not knife then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
                knife = tool
                break
            end
        end
    end
    
    -- Encontrar xerife
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if target then
                -- Puxar xerife para frente
                target.CFrame = hrp.CFrame * CFrame.new(0, 2, -5)
                
                -- Equipar faca
                if knife then
                    char.Humanoid:EquipTool(knife)
                    task.wait(0.1)
                    mouse1click()
                end
                break
            end
        end
    end
end

-- Função Aimbot
local function setupAimbot()
    connections.aimbot = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local closestTarget = nil
        local shortestDistance = 300
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHrp.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestTarget = targetHrp
                    end
                end
            end
        end
        
        if closestTarget then
            -- Mirar no peito
            local targetPos = closestTarget.Position + Vector3.new(0, 0.5, 0)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        end
    end)
end

-- Função Auto Collect Gun
local function setupAutoCollect()
    connections.autoCollect = RunService.RenderStepped:Connect(function()
        if not autoCollectEnabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Verificar se o xerife morreu
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and getRole(player) == "Sheriff" and not player.Character then
                -- Xerife morreu, procurar arma
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("arma")) then
                        -- Teleportar para a arma
                        local originalPos = hrp.Position
                        hrp.CFrame = v.CFrame
                        task.wait(1)
                        hrp.CFrame = CFrame.new(originalPos)
                        
                        -- Desativar função
                        autoCollectEnabled = false
                        break
                    end
                end
            end
        end
    end)
end


local function setupESPMurder()
    connections.espMurder = RunService.RenderStepped:Connect(function()
        if not espMurderEnabled then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and getRole(player) == "Murder" and player.Character then
                -- Destacar corpo em vermelho
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 0, 0)
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.2
                    end
                end
                
                -- Highlight para ver através de paredes
                local highlight = player.Character:FindFirstChildOfClass("Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Murder"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = player.Character
                end
            end
        end
    end)
end

-- Função ESP Xerife
local function setupESPSheriff()
    connections.espSheriff = RunService.RenderStepped:Connect(function()
        if not espSheriffEnabled then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and getRole(player) == "Sheriff" and player.Character then
                -- Destacar corpo em azul
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(0, 0, 255)
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.2
                    end
                end
                
                -- Highlight para ver através de paredes
                local highlight = player.Character:FindFirstChildOfClass("Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Sheriff"
                    highlight.FillColor = Color3.fromRGB(0, 0, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 255)
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = player.Character
                end
            end
        end
    end)
end

-- Função Anti AFK
local function setupAntiAfk()
    connections.antiAfk = RunService.RenderStepped:Connect(function()
        if not antiAfkEnabled then return end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

-- Função Auto Farm
local function setupAutoFarm()
    connections.autoFarm = RunService.RenderStepped:Connect(function()
        if not autoFarmEnabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Ficar 100 studs no céu sem cair
        local targetPos = hrp.Position + Vector3.new(0, 100, 0)
        hrp.CFrame = CFrame.new(targetPos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
end

-- Função Infinite Jump
local function setupInfiniteJump()
    connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
        if not infiniteJumpEnabled then return end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Criar abas
local CombatTab = Window:Tab({ Title = "Combat", Icon = "sword" })
local SheriffTab = Window:Tab({ Title = "Xerife", Icon = "shield" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local MovementTab = Window:Tab({ Title = "Movimentação", Icon = "person-running" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })

-- Aba Combat (Murder)
CombatTab:Section({ Title = "Murder" })

CombatTab:Button({
    Title = "Kill All",
    Description = "Puxa todos e mata com a faca",
    Callback = function()
        KillAll()
    end
})

CombatTab:Button({
    Title = "Kill Xerife",
    Description = "Puxa o xerife e mata",
    Callback = function()
        KillSheriff()
    end
})

-- Aba Xerife
SheriffTab:Section({ Title = "Xerife" })

SheriffTab:Toggle({
    Title = "Aimbot",
    Description = "Mira automática no peito (FOV 300)",
    Value = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then
            setupAimbot()
        elseif connections.aimbot then
            connections.aimbot:Disconnect()
            connections.aimbot = nil
        end
    end
})

SheriffTab:Toggle({
    Title = "Auto Collect Gun",
    Description = "Pega a arma quando o xerife morre",
    Value = false,
    Callback = function(state)
        autoCollectEnabled = state
        if state then
            setupAutoCollect()
        elseif connections.autoCollect then
            connections.autoCollect:Disconnect()
            connections.autoCollect = nil
        end
    end
})

-- Aba ESP
ESPTab:Section({ Title = "ESP" })

ESPTab:Toggle({
    Title = "ESP Murders",
    Description = "Corpo vermelho visível através de paredes",
    Value = false,
    Callback = function(state)
        espMurderEnabled = state
        if state then
            setupESPMurder()
        elseif connections.espMurder then
            connections.espMurder:Disconnect()
            connections.espMurder = nil
        end
    end
})

ESPTab:Toggle({
    Title = "ESP Xerife",
    Description = "Corpo azul visível através de paredes",
    Value = false,
    Callback = function(state)
        espSheriffEnabled = state
        if state then
            setupESPSheriff()
        elseif connections.espSheriff then
            connections.espSheriff:Disconnect()
            connections.espSheriff = nil
        end
    end
})

-- Aba Movimentação
MovementTab:Section({ Title = "Movimentação" })

local walkSpeedValue = 16
local jumpPowerValue = 50

MovementTab:Slider({
    Title = "Velocidade",
    Description = "Controle sua velocidade",
    Min = 1,
    Max = 200,
    Value = 16,
    Callback = function(value)
        walkSpeedValue = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

MovementTab:Toggle({
    Title = "Pulo Infinito",
    Description = "Pule infinitamente no ar",
    Value = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        if state then
            setupInfiniteJump()
        elseif connections.infiniteJump then
            connections.infiniteJump:Disconnect()
            connections.infiniteJump = nil
        end
    end
})

MovementTab:Slider({
    Title = "Força do Pulo",
    Description = "Controle a força do pulo",
    Min = 10,
    Max = 300,
    Value = 50,
    Callback = function(value)
        jumpPowerValue = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

-- Aba Misc
MiscTab:Section({ Title = "Misc" })

MiscTab:Toggle({
    Title = "Anti AFK",
    Description = "Evita ser desconectado por inatividade",
    Value = false,
    Callback = function(state)
        antiAfkEnabled = state
        if state then
            setupAntiAfk()
        elseif connections.antiAfk then
            connections.antiAfk:Disconnect()
            connections.antiAfk = nil
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Farm",
    Description = "Fica 100 studs no céu sem cair",
    Value = false,
    Callback = function(state)
        autoFarmEnabled = state
        if state then
            setupAutoFarm()
        elseif connections.autoFarm then
            connections.autoFarm:Disconnect()
            connections.autoFarm = nil
        end
    end
})

-- Notificação inicial
WindUI:Notify({
    Title = "Zyro Hub",
    Content = "Zyro Hub carregado! Créditos: gomes.wqq",
})
