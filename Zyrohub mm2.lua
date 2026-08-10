-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configurações de Estado
local States = {
    HitboxEnabled = false,
    AutoCollectEnabled = false,
    TeamCheckEnabled = false,
    CursorClickEnabled = false
}

-- Interface
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GomesHubRefined"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

-- Arraste da GUI
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

-- Botões
local function createButton(name, stateKey, yPos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 230, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        States[stateKey] = not States[stateKey]
        btn.Text = name .. (States[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = States[stateKey] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 40)
    end)
    return btn
end

createButton("Hitbox+AutoClick", "HitboxEnabled", 40)
createButton("Auto Collect Gun", "AutoCollectEnabled", 90)
createButton("Team Check", "TeamCheckEnabled", 140)
createButton("Cursor Auto Click", "CursorClickEnabled", 190)

-- Teclas
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then MainFrame.Visible = not MainFrame.Visible end
    if input.KeyCode == Enum.KeyCode.Z then -- Dash
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 2) end
    end
end)

-- Funções Auxiliares
local function isPositionBlocked(pos)
    local objects = UserInputService:GetGuiObjectsAtPosition(pos.X, pos.Y)
    return #objects > 0
end

-- Loop Principal (Hitbox + Auto Click)
RunService.RenderStepped:Connect(function()
    if not States.HitboxEnabled then return end
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Team Check
            if States.TeamCheckEnabled and player.Team == LocalPlayer.Team then continue end
            
            local targetHRP = player.Character.HumanoidRootPart
            targetHRP.Size = Vector3.new(20, 20, 20)
            targetHRP.Transparency = 0.5
            targetHRP.CanCollide = false
            
            -- Raycast Line of Sight
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(Camera.CFrame.Position, (targetHRP.Position - Camera.CFrame.Position).Unit * 500, rayParams)
            
            if not result then -- Se não bateu em nada (visível)
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
                if onScreen and not isPositionBlocked(Vector2.new(screenPos.X, screenPos.Y)) then
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
                    task.wait(0.1) -- Delay seguro
                end
            end
        end
    end
end)

-- Auto Collect Gun (Thread separada)
task.spawn(function()
    while true do
        task.wait(1)
        if States.AutoCollectEnabled then
            local gun = Workspace:FindFirstChild("Gun") or Workspace:FindFirstChild("GunDrop")
            if gun and gun:IsA("BasePart") then
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local oldPos = myHRP.CFrame
                    myHRP.CFrame = gun.CFrame
                    task.wait(0.5)
                    myHRP.CFrame = oldPos
                end
            end
        end
    end
end)

-- Auto Click Cursor
task.spawn(function()
    while true do
        task.wait(1)
        if States.CursorClickEnabled then
            local pos = UserInputService:GetMouseLocation()
            if not isPositionBlocked(pos) then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end
        end
    end
end)
