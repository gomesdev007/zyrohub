-- [[ GOMES HUB V2: DISPARO ÚNICO AUTOMATIZADO COM EFEITO VISUAL ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local ShootRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")

-- Criação da Interface de Teste Segura
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GmesTestGui"
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local TestBtn = Instance.new("TextButton")
TestBtn.Size = UDim2.new(0, 160, 0, 45)
TestBtn.Position = UDim2.new(0.5, -80, 0.4, -22)
TestBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TestBtn.Text = "DISPARAR AJUSTADO"
TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 13
TestBtn.BorderSizePixel = 0
TestBtn.Parent = ScreenGui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(45, 20, 70) -- Padrão Dark Purple
stroke.Parent = TestBtn

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = TestBtn

-- Função para achar o alvo mais próximo
local function getClosestEnemyPart()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestEnemy = player.Character:FindFirstChild("Head") or player.Character.HumanoidRootPart
                end
            end
        end
    end
    return closestEnemy
end

-- Evento de Clique
TestBtn.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = character:FindFirstChildOfClass("Tool") -- Detecta a arma na sua mão
    
    if rootPart and tool then
        local targetPart = getClosestEnemyPart()
        local targetPos = targetPart and targetPart.Position or (rootPart.Position + rootPart.CFrame.LookVector * 50)
        local originPos = rootPart.Position
        
        -- 1. Força o jogo a simular a ativação física da Tool (Gera animação/efeito na sua tela)
        task.spawn(function()
            tool:Activate()
        end)
        
        -- 2. Envia o pacote de rede exatamente no formato esperado
        pcall(function()
            ShootRemote:FireServer(
                originPos,
                targetPos,
                targetPart or workspace,
                targetPos
            )
        end)
        
        print("[GOMES HUB] Disparo simulado e enviado.")
    else
        print("[GOMES HUB] Certifique-se de que a arma está equipada na sua mão!")
    end
end)
