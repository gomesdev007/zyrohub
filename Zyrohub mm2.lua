-- [[ ZYRO HUB V2 (PC FIX) - CREDITS TO GOMES.WQQ ]] --

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
    ToggleKey  = Enum.KeyCode.X,
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
})

-- Atalho global para abrir/fechar com a tecla X
local currentKey = Enum.KeyCode.X

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == currentKey then
        Window:Toggle()
    end
end)

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

local function bringCharacter(targetChar)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local frontPos = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            targetChar.HumanoidRootPart.CFrame = frontPos
        end
    end
end

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

local miraConnection = nil
SheriffTab:Toggle({
    Title = "Mira Mágica (Raio 300 - Ignora Parede)",
    Value = false,
    Callback = function(v)
        if miraConnection then
            miraConnection:Disconnect()
            miraConnection = nil
        end
        
        if v then
            miraConnection = RunService.RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local closestTarget = nil
                    local shortestDist = 300

                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local chest = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                            if chest then
                                local dist = (chest.Position - myPos).Magnitude
                                if dist <= shortestDist then
                                    shortestDist = dist
                                    closestTarget = chest
                                end
                            end
                        end
                    end

                    if closestTarget then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
                    end
                end
            end)
        end
    end
})

local autoCollectTask = nil
SheriffTab:Toggle({
    Title = "Auto Collect Gun",
    Value = false,
    Callback = function(v)
        if autoCollectTask then
            task.cancel(autoCollectTask)
            autoCollectTask = nil
        end

        if v then
            autoCollectTask = task.spawn(function()
                while true do
                    task.wait(0.1)
                    local sheriff = getSheriff()
                    if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("Humanoid") then
                        if sheriff.Character.Humanoid.Health <= 0 then
                            local deathPos = sheriff.Character.HumanoidRootPart.CFrame
                            local lastPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame
                            
                            if lastPos and deathPos then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = deathPos
                                task.wait(1)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = lastPos
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- 3. ABA ESP
-- ==========================================

local espConnection = nil
local function applyHighlight(char, color)
    local hl = char:FindFirstChild("ZyroHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "ZyroHighlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.2
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    else
        hl.FillColor = color
    end
end

local function removeHighlight(char)
    if char and char:FindFirstChild("ZyroHighlight") then
        char.ZyroHighlight:Destroy()
    end
end

local espMurderState = false
local espSheriffState = false

local function updateEspLoop()
    if (espMurderState or espSheriffState) and not espConnection then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local murder = getMurderer()
                    local sheriff = getSheriff()

                    if espMurderState and murder and p == murder then
                        applyHighlight(p.Character, Color3.fromRGB(255, 0, 0))
                    elseif not espMurderState and p == murder then
                        removeHighlight(p.Character)
                    end

                    if espSheriffState and sheriff and p == sheriff then
                        applyHighlight(p.Character, Color3.fromRGB(0, 120, 255))
                    elseif not espSheriffState and p == sheriff then
                        removeHighlight(p.Character)
                    end
                end
            end
        end)
    elseif not espMurderState and not espSheriffState and espConnection then
        espConnection:Disconnect()
        espConnection = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then removeHighlight(p.Character) end
        end
    end
end

EspTab:Toggle({
    Title = "ESP Murder (Vermelho)",
    Value = false,
    Callback = function(v)
        espMurderState = v
        updateEspLoop()
    end
})

EspTab:Toggle({
    Title = "ESP Xerife (Azul)",
    Value = false,
    Callback = function(v)
        espSheriffState = v
        updateEspLoop()
    end
})

-- ==========================================
-- 4. ABA MOVEMENT (SLIDERS FIX & PC MOUSE)
-- ==========================================

MovementTab:Slider({
    Title = "Velocidade (Speed)",
    Min = 16,
    Max = 200,
    Default = 16,
    Step = 1,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

local infJumpConnection = nil
MovementTab:Toggle({
    Title = "Pulo Infinito",
    Value = false,
    Callback = function(v)
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
        if v then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

MovementTab:Slider({
    Title = "Força do Pulo (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Step = 1,
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

local afkConnection = nil
MiscTab:Toggle({
    Title = "Anti AFK",
    Value = false,
    Callback = function(v)
        if afkConnection then
            afkConnection:Disconnect()
            afkConnection = nil
        end
        if v then
            afkConnection = LocalPlayer.Idled:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end
})

local skyPlatform = nil
MiscTab:Toggle({
    Title = "Auto Farm (Sky Freeze)",
    Value = false,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if v then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0)
                task.wait(0.1)
                
                if not skyPlatform then
                    skyPlatform = Instance.new("Part")
                    skyPlatform.Size = Vector3.new(15, 1, 15)
                    skyPlatform.Anchored = true
                    skyPlatform.Transparency = 1
                    skyPlatform.Parent = Workspace
                end
                skyPlatform.CFrame = hrp.CFrame - Vector3.new(0, 3, 0)
                hrp.Anchored = true
            else
                hrp.Anchored = false
                if skyPlatform then
                    skyPlatform:Destroy()
                    skyPlatform = nil
                end
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

SettingsTab:Keybind({
    Title = "Toggle UI Key",
    Value = currentKey,
    Callback = function(v)
        currentKey = (typeof(v) == "EnumItem") and v or Enum.KeyCode[v]
        Window:SetToggleKey(currentKey)
    end,
})

WindUI:Notify({
    Title = "Zyro Hub V2 Ready!",
    Content = "Script atualizado e corrigido com sucesso para PC!",
})
