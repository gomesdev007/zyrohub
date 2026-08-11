local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")

-- Interface Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZyroHubGui"
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "ZYRO HUB AUTO"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Botão de Disparo
local TestBtn = Instance.new("TextButton")
TestBtn.Size = UDim2.new(0, 180, 0, 45)
TestBtn.Position = UDim2.new(0.5, -90, 0.55, -22)
TestBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TestBtn.Text = "AUTO SHOOT: DESATIVADO"
TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 13
TestBtn.BorderSizePixel = 0
TestBtn.Parent = MainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(45, 20, 70)
stroke.Parent = TestBtn

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(0, 6)
cornerBtn.Parent = TestBtn

-- Lógica de Arrastar (Draggable)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Funções do Script
local AutoShootActive = false
local PredictionFactor = 0.22 
local TOOL_NAME = "Colt"

local function toggleShoot()
    AutoShootActive = not AutoShootActive
    if AutoShootActive then
        TestBtn.Text = "AUTO SHOOT: ATIVADO"
        stroke.Color = Color3.fromRGB(200, 30, 60)
        task.spawn(function()
            while AutoShootActive do
                -- Lógica interna de disparo
                local character = LocalPlayer.Character
                if character then
                    -- Auto Equip
                    if not character:FindFirstChild(TOOL_NAME) then
                        local tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(TOOL_NAME)
                        if tool then tool.Parent = character end
                    end
                    
                    -- Disparo
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local tool = character:FindFirstChild(TOOL_NAME) or character:FindFirstChildOfClass("Tool")
                    if rootPart and tool and tool:IsA("Tool") then
                        -- Encontrar alvo
                        local closestEnemy = nil
                        local shortestDist = math.huge
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                                local d = (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if d < shortestDist then shortestDist = d; closestEnemy = p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart end
                            end
                        end
                        
                        if closestEnemy then
                            local targetPos = closestEnemy.Position + (closestEnemy.Parent.HumanoidRootPart.Velocity * PredictionFactor)
                            rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z))
                            task.spawn(function() tool:Activate() end)
                            pcall(function() ShootRemote:FireServer(rootPart.Position, targetPos, closestEnemy, targetPos) end)
                        end
                    end
                end
                task.wait(0.10)
            end
        end)
    else
        TestBtn.Text = "AUTO SHOOT: DESATIVADO"
        stroke.Color = Color3.fromRGB(45, 20, 70)
    end
end

-- Eventos
TestBtn.MouseButton1Click:Connect(toggleShoot)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.X then
        toggleShoot()
    end
end)
