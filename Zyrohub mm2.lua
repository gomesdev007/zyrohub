-- [[ ZYRO HUB - CREDITS TO GOMES.WQQ ]] --

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Tema e Estilo Base
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

local Window = WindUI:CreateWindow({
    Title   = "Zyro Hub",
    Author  = "by gomes.wqq",
    Folder  = "zyrohub",
    Icon    = "swords",
    Theme   = "Dark",
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
        Icon = "zap",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(Color3.fromHex("#000000"), Color3.fromHex("#000000")),
    },
    User = {
        Enabled  = true,
        Anonymous = false,
        Callback = function() end,
    },
})

-- ==========================================
-- ABAS
-- ==========================================
local CombatMurderTab = Window:Tab({ Title = "Combat Murder", Icon = "skull" })
local SheriffTab      = Window:Tab({ Title = "Sheriff", Icon = "shield" })
local EspTab          = Window:Tab({ Title = "ESP", Icon = "eye" })
local MovementTab     = Window:Tab({ Title = "Movement", Icon = "move" })
local MiscTab         = Window:Tab({ Title = "Misc", Icon = "sparkles" })
local SettingsTab     = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ==========================================
-- FUNÇÕES AUXILIARES
-- ==========================================

-- Puxar Faca / Equipar Tool
local function equipTool()
    if LocalPlayer.Character then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = LocalPlayer.Character
                    break
                end
            end
        end
    end
end

-- Simular clique
local function clickTool()
    equipTool()
    task.wait(0.05)
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end

-- Puxar Personagem para a Frente
local function bringCharacter(targetChar)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local frontPos = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            targetChar.HumanoidRootPart.CFrame = frontPos
        end
    end
end

-- Busca o Xerife
local function getSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") or (p.Team and p.Team.Name:lower():find("sheriff")) then
                return p
            end
        end
    end
    return nil
end

-- Busca o Murderer
local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") or (p.Team and p.Team.Name:lower():find("murder")) then
                return p
            end
        end
    end
    return nil
end

-- ==========================================
-- 1. ABA COMBAT MURDER
-- ==========================================

CombatMurderTab:Button({
    Title = "Puxar Todos (Clique Único)",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                bringCharacter(p.Character)
            end
        end
        clickTool()
    end,
})

CombatMurderTab:Button({
    Title = "Puxar Xerife (Clique Único)",
    Callback = function()
        local sheriff = getSheriff()
        if sheriff and sheriff.Character then
            bringCharacter(sheriff.Character)
            clickTool()
        end
    end,
})

-- ==========================================
-- 2. ABA SHERIFF
-- ==========================================

local miraMagicaActive = false
SheriffTab:Toggle({
    Title = "Mira Mágica (Raio 300)",
    Value = false,
    Callback = function(v)
        miraMagicaActive = v
    end
})

RunService.RenderStepped:Connect(function()
    if miraMagicaActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        local closestTarget = nil
        local shortestDist = 300

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("UpperTorso") or (p.Character and p.Character:FindFirstChild("Torso")) then
                local chest = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                local dist = (chest.Position - myPos).Magnitude
                if dist <= shortestDist then
                    shortestDist = dist
                    closestTarget = chest
                end
            end
        end

        if closestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        end
    end
end)

-- Auto Collect Gun
local autoCollectActive = false
SheriffTab:Toggle({
    Title = "Auto Collect Gun",
    Value = false,
    Callback = function(v)
        autoCollectActive = v
    end
})

-- Monitoramento da Morte do Xerife
task.spawn(function()
    while task.wait(0.2) do
        if autoCollectActive then
            local sheriff = getSheriff()
            if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("Humanoid") then
                if sheriff.Character.Humanoid.Health <= 0 then
                    local deathPos = sheriff.Character.HumanoidRootPart.CFrame
                    local lastPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame
                    
                    if lastPos and deathPos then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = deathPos
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = lastPos
                        autoCollectActive = false
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 3. ABA ESP
-- ==========================================

local espMurder = false
local espSheriff = false

local function applyHighlight(char, color)
    if not char:FindFirstChild("ZyroHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "ZyroHighlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.2
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
end

local function removeHighlight(char)
    if char:FindFirstChild("ZyroHighlight") then
        char.ZyroHighlight:Destroy()
    end
end

EspTab:Toggle({
    Title = "ESP Murder (Vermelho)",
    Value = false,
    Callback = function(v)
        espMurder = v
    end
})

EspTab:Toggle({
    Title = "ESP Xerife (Azul)",
    Value = false,
    Callback = function(v)
        espSheriff = v
    end
})

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- ESP Murder
            local murder = getMurderer()
            if espMurder and murder and p == murder then
                applyHighlight(p.Character, Color3.fromRGB(255, 0, 0))
            elseif not espMurder and p == murder then
                removeHighlight(p.Character)
            end

            -- ESP Sheriff
            local sheriff = getSheriff()
            if espSheriff and sheriff and p == sheriff then
                applyHighlight(p.Character, Color3.fromRGB(0, 120, 255))
            elseif not espSheriff and p == sheriff then
                removeHighlight(p.Character)
            end
        end
    end
end)

-- ==========================================
-- 4. ABA MOVEMENT
-- ==========================================

MovementTab:Slider({
    Title = "Velocidade (Speed)",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

MovementTab:Toggle({
    Title = "Pulo Infinito",
    Value = false,
    Callback = function(v)
        _G.InfJump = v
    end
})

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MovementTab:Slider({
    Title = "Força do Pulo (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end
})

-- ==========================================
-- 5. ABA MISC
-- ==========================================

MiscTab:Toggle({
    Title = "Anti AFK",
    Value = true,
    Callback = function(v)
        _G.AntiAfk = v
    end
})

-- Anti AFK Event
LocalPlayer.Idled:Connect(function()
    if _G.AntiAfk then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- Auto Farm (Travado 100 stud no céu)
local autoFarmActive = false
MiscTab:Toggle({
    Title = "Auto Farm (Sky Freeze)",
    Value = false,
    Callback = function(v)
        autoFarmActive = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if v then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
            else
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================

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
    Title = "Acrylic",
    Value = WindUI:GetTransparency(),
    Callback = function()
        local isOn = WindUI.Window.Acrylic
        WindUI:ToggleAcrylic(not isOn)
    end,
})

SettingsTab:Toggle({
    Title = "Transparent",
    Value = WindUI:GetTransparency(),
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

local currentKey = Enum.KeyCode.RightShift

SettingsTab:Keybind({
    Title = "Toggle UI Key",
    Value = currentKey,
    Callback = function(v)
        currentKey = (typeof(v) == "EnumItem") and v or Enum.KeyCode[v]
        Window:SetToggleKey(currentKey)
    end,
})

-- Notify On Load
WindUI:Notify({
    Title = "Zyro Hub Loaded!",
    Content = "Script executado com sucesso! Criado por gomes.wqq.",
})
