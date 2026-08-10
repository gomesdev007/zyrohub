-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local RADIUS = 300
local HITBOX_SIZE = Vector3.new(20, 20, 20)
local Enabled = false
local AutoCollectEnabled = false
local TeamCheckEnabled = false
local CursorClickEnabled = false

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GomesDarkGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or (syn and syn.protect_gui and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 23)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- ... (Manter a estrutura de UI que você já possui) ...
local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = MainFrame
local UIStroke = Instance.new("UIStroke"); UIStroke.Color = Color3.fromRGB(25, 40, 70); UIStroke.Thickness = 1.5; UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame"); TopBar.Size = UDim2.new(1, 0, 0, 32); TopBar.BackgroundColor3 = Color3.fromRGB(16, 22, 36); TopBar.Parent = MainFrame
local TitleLabel = Instance.new("TextLabel"); TitleLabel.Size = UDim2.new(1, -40, 1, 0); TitleLabel.Position = UDim2.new(0, 12, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "GOMES SYSTEM"; TitleLabel.TextColor3 = Color3.fromRGB(220, 230, 255); TitleLabel.TextSize = 12; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.Parent = TopBar
local MinimizeBtn = Instance.new("TextButton"); MinimizeBtn.Size = UDim2.new(0, 25, 0, 25); MinimizeBtn.Position = UDim2.new(1, -28, 0, 3); MinimizeBtn.BackgroundTransparency = 1; MinimizeBtn.Text = "-"; MinimizeBtn.TextColor3 = Color3.fromRGB(160, 180, 210); MinimizeBtn.Parent = TopBar

-- Criador de Toggles
local function createToggle(titleText, positionY, callback)
    local ToggleFrame = Instance.new("Frame"); ToggleFrame.Size = UDim2.new(0, 226, 0, 40); ToggleFrame.Position = UDim2.new(0.5, -113, 0, positionY); ToggleFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 32); ToggleFrame.Parent = MainFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
    local ToggleText = Instance.new("TextLabel", ToggleFrame); ToggleText.Size = UDim2.new(0, 150, 1, 0); ToggleText.Position = UDim2.new(0, 10, 0, 0); ToggleText.BackgroundTransparency = 1; ToggleText.Text = titleText; ToggleText.TextColor3 = Color3.fromRGB(200, 210, 235); ToggleText.TextSize = 10; ToggleText.Font = Enum.Font.GothamMedium
    
    local SwitchBG = Instance.new("TextButton", ToggleFrame); SwitchBG.Size = UDim2.new(0, 44, 0, 22); SwitchBG.Position = UDim2.new(1, -52, 0.5, -11); SwitchBG.BackgroundColor3 = Color3.fromRGB(30, 38, 55); SwitchBG.Text = ""
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)
    local SwitchCircle = Instance.new("Frame", SwitchBG); SwitchCircle.Size = UDim2.new(0, 16, 0, 16); SwitchCircle.Position = UDim2.new(0, 3, 0.5, -8); SwitchCircle.BackgroundColor3 = Color3.fromRGB(110, 125, 150); SwitchCircle.BorderSizePixel = 0
    Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)

    local isToggled = false
    SwitchBG.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        local color = isToggled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(30, 38, 55)
        local pos = isToggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = pos, BackgroundColor3 = isToggled and Color3.fromRGB(255,255,255) or Color3.fromRGB(110, 125, 150)}):Play()
        callback(isToggled)
    end)
end

-- Toggles (Reorganizados para caber)
createToggle("Hitbox 20 + Auto Click", 40, function(s) Enabled = s end)
createToggle("Auto Collect Gun", 85, function(s) AutoCollectEnabled = s end)
createToggle("Team Check", 130, function(s) TeamCheckEnabled = s end)
createToggle("Auto Click Cursor", 175, function(s) CursorClickEnabled = s end)

-- Funções Utilitárias
local function isGuiBlocking(pos)
    local objs = UserInputService:GetGuiObjectsAtPosition(pos)
    return #objs > 0
end

local function isVisible(targetPart)
    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, targetPart.Parent})
    return hit == nil
end

-- Dash na tecla Z
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Z then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 2) end
    end
end)

-- Tecla X para Abrir/Fechar
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.X then MainFrame.Visible = not MainFrame.Visible end
end)

-- Lógica de Auto Click (Targeting)
RunService.RenderStepped:Connect(function()
    if not Enabled then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not (TeamCheckEnabled and player.Team == LocalPlayer.Team) then
                local targetHRP = player.Character.HumanoidRootPart
                
                -- Aplica Hitbox e verifica visão
                targetHRP.Size = HITBOX_SIZE
                targetHRP.Transparency = 0.7
                
                if isVisible(targetHRP) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
                    if onScreen and not isGuiBlocking(Vector2.new(screenPos.X, screenPos.Y)) then
                        if tick() % 0.5 < 0.1 then -- Click Rate
                            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Click Cursor
task.spawn(function()
    while true do
        task.wait(1)
        if CursorClickEnabled then
            local pos = UserInputService:GetMouseLocation()
            if not isGuiBlocking(pos) then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end
        end
    end
end)
