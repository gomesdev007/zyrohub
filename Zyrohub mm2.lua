-- ==============================================================================
-- GOMES SYSTEM PRO - ULTIMATE EDITION (RE-WRITTEN FROM SCRATCH)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==============================================================================
-- ESTRUTURA DE DADOS
-- ==============================================================================
local Hub = {
    Enabled = {
        Hitbox = false,
        AutoGun = false,
        TeamCheck = false,
        CursorAutoClick = false
    },
    Settings = {
        Radius = 300,
        HitboxSize = Vector3.new(20, 20, 20)
    }
}

-- ==============================================================================
-- GUI BUILDER (DESIGN ARREDONDADO E PROFISSIONAL)
-- ==============================================================================
local Gui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
Gui.Name = "GomesSystemPro"

local Container = Instance.new("Frame", Gui)
Container.Size = UDim2.new(0, 280, 0, 360)
Container.Position = UDim2.new(0.5, -140, 0.4, -180)
Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Container.BorderSizePixel = 0
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 15)

-- Topbar
local TopBar = Instance.new("Frame", Container)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 15)
Instance.new("Frame", TopBar).Size = UDim2.new(1, 0, 0.5, 0); -- Corrige visual da parte de baixo da topbar

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "GOMES SYSTEM PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Criador de Botões Arredondados
local function CreateButton(Name, StateKey, YOffset)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0, 250, 0, 50)
    Btn.Position = UDim2.new(0, 15, 0, YOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Btn.Text = Name .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
    
    Btn.MouseButton1Click:Connect(function()
        Hub.Enabled[StateKey] = not Hub.Enabled[StateKey]
        local Active = Hub.Enabled[StateKey]
        Btn.BackgroundColor3 = Active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 55)
        Btn.Text = Name .. (Active and " [ON]" or " [OFF]")
    end)
end

CreateButton("Hitbox AutoClick", "Hitbox", 60)
CreateButton("Auto Collect Gun", "AutoGun", 120)
CreateButton("Team Check", "TeamCheck", 180)
CreateButton("Cursor Auto Click", "CursorAutoClick", 240)

local Info = Instance.new("TextLabel", Container)
Info.Size = UDim2.new(1, 0, 0, 30)
Info.Position = UDim2.new(0, 0, 0, 310)
Info.Text = "X: Toggle UI | Z: Dash | V: STOP ALL"
Info.TextColor3 = Color3.fromRGB(100, 100, 120)
Info.BackgroundTransparency = 1

-- ==============================================================================
-- LÓGICA DO SCRIPT (ENGINE)
-- ==============================================================================

-- Arrastar
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Container.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Sistema de Emergência (V) e Atalhos
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then Container.Visible = not Container.Visible end
    if input.KeyCode == Enum.KeyCode.V then
        for k, _ in pairs(Hub.Enabled) do Hub.Enabled[k] = false end
        for _, obj in pairs(Container:GetChildren()) do if obj:IsA("TextButton") then obj.Text = obj.Text:split(" ")[1] .. " [OFF]"; obj.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end end
    end
    if input.KeyCode == Enum.KeyCode.Z then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 2) end
    end
end)

-- Utilidades
local function isGuiBlocked(pos)
    return #UserInputService:GetGuiObjectsAtPosition(pos.X, pos.Y) > 0
end

-- Core Loop (Hitbox & AutoClick)
RunService.RenderStepped:Connect(function()
    if not Hub.Enabled.Hitbox then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Hub.Enabled.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetHRP = player.Character.HumanoidRootPart
            targetHRP.Size = Hub.Settings.HitboxSize
            targetHRP.Transparency = 0.5
            targetHRP.CanCollide = false
            
            -- Raycast Line of Sight
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {myChar, player.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(Camera.CFrame.Position, (targetHRP.Position - Camera.CFrame.Position).Unit * 500, rayParams)
            
            if not result then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
                if onScreen and not isGuiBlocked(Vector2.new(screenPos.X, screenPos.Y)) then
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- Auto Collect Gun Thread
task.spawn(function()
    while true do
        task.wait(0.5)
        if Hub.Enabled.AutoGun then
            local gun = Workspace:FindFirstChild("Gun") or Workspace:FindFirstChild("GunDrop")
            if gun and gun:IsA("BasePart") then
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    local saveCFrame = myHrp.CFrame
                    myHrp.CFrame = gun.CFrame
                    task.wait(0.5)
                    myHrp.CFrame = saveCFrame
                end
            end
        end
    end
end)

-- Auto Click Cursor Thread
task.spawn(function()
    while true do
        task.wait(0.8)
        if Hub.Enabled.CursorAutoClick then
            local pos = UserInputService:GetMouseLocation()
            if not isGuiBlocked(pos) then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end
        end
    end
end)
