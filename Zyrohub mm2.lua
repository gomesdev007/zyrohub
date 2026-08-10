-- [[ ZYRO HUB V2 | MASTER EDITION | COMPLETO & ESTÁVEL ]] --

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuração da Janela (Sem botão flutuante para evitar bugs)
local Window = WindUI:CreateWindow({
    Title = "Zyro Hub V2 | Master Edition",
    Author = "by gomes.wqq",
    Folder = "zyrohub",
    Icon = "swords",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.X,
    OpenButton = { Enabled = false }, 
})

-- Gerenciador da Tecla X
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
        Window:Toggle()
    end
end)

-- ABAS
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local EspTab    = Window:Tab({ Title = "ESP", Icon = "eye" })
local MoveTab   = Window:Tab({ Title = "Movement", Icon = "move" })
local MiscTab   = Window:Tab({ Title = "Misc", Icon = "sparkles" })

-- ==========================================
-- FUNÇÕES CORE (REESCRITAS)
-- ==========================================

local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                return p
            end
        end
    end
    return nil
end

local function getSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Character:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then
                return p
            end
        end
    end
    return nil
end

-- ==========================================
-- COMBAT (AIMBOT)
-- ==========================================
local aimbotEnabled = false
CombatTab:Toggle({ Title = "Aimbot (Murderer/Sheriff)", Value = false, Callback = function(v) aimbotEnabled = v end })

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getMurderer() or getSheriff()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- ==========================================
-- ESP (HIGHLIGHT)
-- ==========================================
local espSettings = {murder = false, sheriff = false, innocent = false}
local highlights = {}

local function createHighlight(char, color)
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.Parent = char
    highlights[char] = hl
end

local function cleanHighlights()
    for _, hl in pairs(highlights) do hl:Destroy() end
    highlights = {}
end

EspTab:Toggle({ Title = "ESP Murderer", Value = false, Callback = function(v) espSettings.murder = v end })
EspTab:Toggle({ Title = "ESP Sheriff", Value = false, Callback = function(v) espSettings.sheriff = v end })

RunService.RenderStepped:Connect(function()
    cleanHighlights()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if espSettings.murder and getMurderer() == p then createHighlight(p.Character, Color3.new(1,0,0))
            elseif espSettings.sheriff and getSheriff() == p then createHighlight(p.Character, Color3.new(0,0,1)) end
        end
    end
end)

-- ==========================================
-- MOVEMENT (FLY / NOCLIP / SPEED)
-- ==========================================
local noclip = false
MoveTab:Toggle({ Title = "Noclip (Atravessar)", Value = false, Callback = function(v) noclip = v end })

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

MoveTab:Slider({ Title = "Speed", Min = 16, Max = 150, Default = 16, Callback = function(v) 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
end })

-- ==========================================
-- MISC (COINS / ANTI-AFK)
-- ==========================================
local autoFarm = false
MiscTab:Toggle({ Title = "Auto Collect Coins", Value = false, Callback = function(v) autoFarm = v end })

task.spawn(function()
    while true do
        task.wait(1)
        if autoFarm then
            for _, coin in pairs(Workspace:GetDescendants()) do
                if coin.Name == "Coin" and coin:FindFirstChild("TouchInterest") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                end
            end
        end
    end
end)

MiscTab:Toggle({ Title = "Anti AFK", Value = false, Callback = function(v)
    if v then
        LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    end
end })

WindUI:Notify({ Title = "Zyro Hub V2", Content = "Script Master Edition carregado. Tudo funcional!" })
