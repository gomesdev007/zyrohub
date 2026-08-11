local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")

-- Tela Principal (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GmesAutoShootGui"
ScreenGui.ResetOnSpawn = false
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Janela Arrastável (GUI Pequena Dark)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 75)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -37)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Bordas Arredondadas e UIStroke
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = Color3.fromRGB(110, 40, 200)
FrameStroke.Parent = MainFrame

-- Botão de Ativação
local TestBtn = Instance.new("TextButton")
TestBtn.Size = UDim2.new(0, 190, 0, 45)
TestBtn.Position = UDim2.new(0.5, -95, 0.5, -22.5)
TestBtn.BackgroundColor3 = Color3.fromRGB(18, 15, 25)
TestBtn.Text = "AUTO SHOOT: DESATIVADO"
TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 12
TestBtn.BorderSizePixel = 0
TestBtn.Parent = MainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(45, 20, 70)
stroke.Parent = TestBtn

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = TestBtn

-------------------------------------------------------------------------------
-- LÓGICA DE AUTO SHOOT (PRESERVADA INTEGRALMENTE)
-------------------------------------------------------------------------------
local AutoShootActive = false
local PredictionFactor = 0.22 
local TOOL_NAME = "Colt"

local function autoEquip()
    local character = LocalPlayer.Character
    if not character then return end
    
    if character:FindFirstChild(TOOL_NAME) then return end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(TOOL_NAME)
        if tool and tool:IsA("Tool") then
            tool.Parent = character
        end
    end
end

local function getClosestEnemyPart()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            
            if char and char:IsDescendantOf(workspace) then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and rootPart and head then
                    if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then 
                        local dist = (myRoot.Position - rootPart.Position).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestEnemy = head
                        end
                    end
                end
            end
        end
    end
    return closestEnemy
end

local function fireWeapon()
    autoEquip()
    
    if not ShootRemote or not LocalPlayer.Character then return end
    
    local character = LocalPlayer.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChild(TOOL_NAME) or character:FindFirstChildOfClass("Tool")
    
    if rootPart and tool and tool:IsA("Tool") then
        local targetPart = getClosestEnemyPart()
        if not targetPart then return end
        
        local targetPos = targetPart.Position
        
        local targetCharacter = targetPart.Parent
        if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
            local targetVelocity = targetCharacter.HumanoidRootPart.Velocity
            targetPos = targetPos + (targetVelocity * PredictionFactor)
        end
        
        local direction = (Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z) - rootPart.Position).Unit
        local newCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)
        rootPart.CFrame = newCFrame
        
        task.spawn(function()
            if tool and tool.Parent == character then
                tool:Activate()
            end
        end)
        
        pcall(function()
            ShootRemote:FireServer(
                rootPart.Position,
                targetPos,
                targetPart,
                targetPos
            )
        end)
    end
end

TestBtn.MouseButton1Click:Connect(function()
    AutoShootActive = not AutoShootActive
    
    if AutoShootActive then
        TestBtn.Text = "AUTO SHOOT: ATIVADO"
        stroke.Color = Color3.fromRGB(200, 30, 60)
        
        task.spawn(function()
            while AutoShootActive do
                fireWeapon()
                task.wait(0.10)
            end
        end)
    else
        TestBtn.Text = "AUTO SHOOT: DESATIVADO"
        stroke.Color = Color3.fromRGB(45, 20, 70)
    end
end)
