-- ==============================================================================
-- GOMES SYSTEM HUB - PRO EDITION
-- Versão Completa e Estável
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
-- CONFIGURAÇÕES E ESTADO (HUB)
-- ==============================================================================
local HubState = {
    HitboxEnabled = false,
    AutoCollectEnabled = false,
    TeamCheckEnabled = false,
    CursorClickEnabled = false,
    UIHidden = false
}

-- ==============================================================================
-- INTERFACE GRÁFICA (GUI BUILDER)
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GomesHubPro"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "GOMES SYSTEM HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Funções de botões
local function CreateButton(Name, StateField, YPos)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0, 240, 0, 45)
    Btn.Position = UDim2.new(0, 10, 0, YPos)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Btn.Text = Name .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        HubState[StateField] = not HubState[StateField]
        Btn.Text = Name .. (HubState[StateField] and ": ON" or ": OFF")
        Btn.BackgroundColor3 = HubState[StateField] and Color3.fromRGB(0, 85, 255) or Color3.fromRGB(25, 25, 40)
    end)
end

CreateButton("Hitbox + AutoClick", "HitboxEnabled", 50)
CreateButton("Auto Collect Gun", "AutoCollectEnabled", 100)
CreateButton("Team Check", "TeamCheckEnabled", 150)
CreateButton("Cursor AutoClick", "CursorClickEnabled", 200)

local Info = Instance.new("TextLabel", MainFrame)
Info.Size = UDim2.new(1, 0, 0, 40)
Info.Position = UDim2.new(0, 0, 0, 260)
Info.Text = "X: Hide GUI | Z: Dash | V: Emergency Stop"
Info.TextColor3 = Color3.fromRGB(100, 100, 100)
Info.BackgroundTransparency = 1
Info.TextSize = 10

-- ==============================================================================
-- LÓGICA E UTILIDADES
-- ==============================================================================
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function IsGuiBlocked(Pos)
    local Objects = UserInputService:GetGuiObjectsAtPosition(Pos.X, Pos.Y)
    return #Objects > 0
end

local function EmergencyStop()
    for Key, _ in pairs(HubState) do
        if Key ~= "UIHidden" then HubState[Key] = false end
    end
    for _, Child in pairs(MainFrame:GetChildren()) do
        if Child:IsA("TextButton") then
            Child.Text = Child.Text:split(":")[1] .. ": OFF"
            Child.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then MainFrame.Visible = not MainFrame.Visible end
    if input.KeyCode == Enum.KeyCode.V then EmergencyStop() end
    if input.KeyCode == Enum.KeyCode.Z then 
        local Hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Hrp then Hrp.CFrame = Hrp.CFrame + (Hrp.CFrame.LookVector * 2) end
    end
end)

-- ==============================================================================
-- LOOP PRINCIPAL DE EXECUÇÃO
-- ==============================================================================
RunService.RenderStepped:Connect(function()
    -- 1. HITBOX + AUTO CLICK
    if HubState.HitboxEnabled then
        local MyChar = LocalPlayer.Character
        if MyChar and MyChar:FindFirstChild("HumanoidRootPart") then
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if HubState.TeamCheckEnabled and Player.Team == LocalPlayer.Team then continue end
                    
                    local TargetHrp = Player.Character.HumanoidRootPart
                    TargetHrp.Size = Vector3.new(20, 20, 20)
                    TargetHrp.Transparency = 0.6
                    TargetHrp.CanCollide = false
                    
                    -- Check Visibilidade
                    local RayParams = RaycastParams.new()
                    RayParams.FilterDescendantsInstances = {MyChar, Player.Character}
                    RayParams.FilterType = Enum.RaycastFilterType.Exclude
                    local Result = Workspace:Raycast(Camera.CFrame.Position, (TargetHrp.Position - Camera.CFrame.Position).Unit * 500, RayParams)
                    
                    if not Result then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetHrp.Position)
                        if OnScreen and not IsGuiBlocked(Vector2.new(ScreenPos.X, ScreenPos.Y)) then
                            VirtualInputManager:SendMouseButtonEvent(ScreenPos.X, ScreenPos.Y, 0, true, game, 0)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(ScreenPos.X, screenPos.Y, 0, false, game, 0)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
    end
end)

-- 2. AUTO COLLECT GUN
task.spawn(function()
    while true do
        task.wait(1)
        if HubState.AutoCollectEnabled then
            local Gun = Workspace:FindFirstChild("Gun") or Workspace:FindFirstChild("GunDrop")
            if Gun and Gun:IsA("BasePart") then
                local MyHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if MyHrp then
                    local OldPos = MyHrp.CFrame
                    MyHrp.CFrame = Gun.CFrame
                    task.wait(0.5)
                    MyHrp.CFrame = OldPos
                end
            end
        end
    end
end)

-- 3. AUTO CLICK CURSOR (MOUSE)
task.spawn(function()
    while true do
        task.wait(1)
        if HubState.CursorClickEnabled then
            local Pos = UserInputService:GetMouseLocation()
            if not IsGuiBlocked(Pos) then
                VirtualInputManager:SendMouseButtonEvent(Pos.X, Pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(Pos.X, Pos.Y, 0, false, game, 0)
            end
        end
    end
end)
