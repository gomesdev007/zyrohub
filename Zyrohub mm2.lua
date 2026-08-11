--[[
	ZYRO HUB UNIVERSAL
	Criador: Gomes.wqq
	Script Simplificado e 100% Funcional
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if not LocalPlayer then
	warn("Erro: LocalPlayer não encontrado!")
	return
end

-- Criar Janela
local Window = Fluent:CreateWindow({
	Title = "ZYRO HUB UNIVERSAL",
	SubTitle = "by Gomes.wqq",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true,
	Theme = "Light",
	MinimizeKey = Enum.KeyCode.LeftControl
})

-- Abas
local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "zap" }),
	Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
	Teleport = Window:AddTab({ Title = "Teleport", Icon = "target" })
}

local Options = Fluent.Options

-- Estado das Funções
local Features = {
	CamLock = false,
	InfinityJump = false,
	JumpPower = 50,
	Fly = false,
	NoClip = false,
	TPPlayer = false,
	TPFly = false,
}

local flying = false
local canJump = true

-- ========== TAB MAIN ==========

Tabs.Main:AddParagraph({
	Title = "Bem-vindo",
	Content = "ZYRO HUB UNIVERSAL\nCriado por Gomes.wqq"
})

-- Cam Lock Toggle
local CamLockToggle = Tabs.Main:AddToggle("CamLock", {
	Title = "Cam-Lock [Z]",
	Default = false,
	Callback = function(Value)
		Features.CamLock = Value
	end
})

Tabs.Main:AddButton({
	Title = "Notificação de Teste",
	Description = "Clique para testar notificações",
	Callback = function()
		Fluent:Notify({
			Title = "✅ Script Ativo",
			Content = "ZYRO HUB UNIVERSAL está funcionando!",
			Duration = 3
		})
	end
})

-- ========== TAB MOVEMENT ==========

-- Infinity Jump Toggle
local InfinityJumpToggle = Tabs.Movement:AddToggle("InfinityJump", {
	Title = "Infinity Jump [I]",
	Default = false,
	Callback = function(Value)
		Features.InfinityJump = Value
	end
})

-- Jump Power Slider
local JumpPowerSlider = Tabs.Movement:AddSlider("JumpPower", {
	Title = "Velocidade do Jump",
	Description = "Ajuste a força do salto (10 a 150)",
	Default = 50,
	Min = 10,
	Max = 150,
	Rounding = 1,
	Callback = function(Value)
		Features.JumpPower = Value
	end
})

-- Fly Toggle
local FlyToggle = Tabs.Movement:AddToggle("Fly", {
	Title = "Fly [F]",
	Default = false,
	Callback = function(Value)
		Features.Fly = Value
	end
})

Tabs.Movement:AddParagraph({
	Title = "Controles do Fly",
	Content = "W/A/S/D - Mover\nSpace - Subir\nCtrl - Descer\nF - Ativar/Desativar"
})

-- No-Clip Toggle
local NoClipToggle = Tabs.Movement:AddToggle("NoClip", {
	Title = "No-Clip [N]",
	Default = false,
	Callback = function(Value)
		Features.NoClip = Value
	end
})

-- ========== TAB TELEPORT ==========

-- TP Player Button
Tabs.Teleport:AddButton({
	Title = "TP Player Mais Próximo [T]",
	Description = "Teleporta para o player mais próximo",
	Callback = function()
		TPToClosestPlayer()
	end
})

-- TP Fly Up Button
Tabs.Teleport:AddButton({
	Title = "TP Fly Up [Y]",
	Description = "Teleporta 40 studs para cima",
	Callback = function()
		TPFlyUp()
	end
})

Tabs.Teleport:AddParagraph({
	Title = "Informações",
	Content = "T - Teleporta para player mais próximo (Uma vez)\nY - Teleporta 40 studs para cima (Uma vez)"
})

-- ========== IMPLEMENTAÇÃO DAS FEATURES ==========

-- Infinity Jump
local jumped = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Space and Features.InfinityJump then
		if LocalPlayer.Character then
			local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			if hrp and humanoid then
				pcall(function()
					hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, Features.JumpPower, hrp.AssemblyLinearVelocity.Z)
				end)
			end
		end
	end
end)

-- Fly System Melhorado
local function StartFly()
	if not LocalPlayer.Character then return end
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	flying = true
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = hrp

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not Features.Fly or not hrp or not hrp.Parent then
			connection:Disconnect()
			pcall(function() 
				bodyVelocity:Destroy()
				bodyGyro:Destroy()
			end)
			flying = false
			return
		end

		bodyGyro.CFrame = Camera.CFrame

		local moveDirection = Vector3.new(0, 0, 0)
		local flySpeed = 50

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + Camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - Camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - Camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + Camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end

		if moveDirection.Magnitude > 0 then
			bodyVelocity.Velocity = moveDirection.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

RunService.RenderStepped:Connect(function()
	if Features.Fly and not flying then
		StartFly()
	end
end)

-- No-Clip
RunService.RenderStepped:Connect(function()
	if Features.NoClip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function()
					part.CanCollide = false
				end)
			end
		end
	end
end)

-- Cam Lock
local function GetClosestPlayerInRadius()
	local closestPlayer = nil
	local closestDistance = 300

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
			local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			if targetHRP and playerHRP then
				local distance = (targetHRP.Position - playerHRP.Position).Magnitude

				if distance < closestDistance then
					pcall(function()
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
						raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

						local result = workspace:Raycast(playerHRP.Position, (targetHRP.Position - playerHRP.Position).Unit * 300, raycastParams)

						if not result or (result.Instance and result.Instance:IsDescendantOf(player.Character)) then
							closestDistance = distance
							closestPlayer = player
						end
					end)
				end
			end
		end
	end

	return closestPlayer
end

RunService.RenderStepped:Connect(function()
	if Features.CamLock then
		local target = GetClosestPlayerInRadius()
		if target and target.Character then
			local targetChest = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso")
			if targetChest then
				pcall(function()
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetChest.Position)
				end)
			end
		end
	end
end)

-- TP Player (Click Único)
function TPToClosestPlayer()
	local closestPlayer = nil
	local closestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = player.Character:FindFirstChild("Humanoid")
			local playerHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			if targetHRP and playerHRP and targetHumanoid and targetHumanoid.Health > 0 then
				local distance = (targetHRP.Position - playerHRP.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	if closestPlayer and closestPlayer.Character then
		local targetHRP = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
		local playerHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetHRP and playerHRP then
			pcall(function()
				playerHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 2)
			end)
			Fluent:Notify({
				Title = "✅ Teleportado",
				Content = "Você foi teleportado para " .. closestPlayer.Name,
				Duration = 3
			})
		end
	else
		Fluent:Notify({
			Title = "❌ Erro",
			Content = "Nenhum player próximo encontrado",
			Duration = 3
		})
	end
end

-- TP Fly Up (Click Único - Teleporta uma vez +40)
local tpFlyActive = false
function TPFlyUp()
	if tpFlyActive then return end
	tpFlyActive = true

	if LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			pcall(function()
				hrp.CFrame = hrp.CFrame + Vector3.new(0, 40, 0)
			end)
			Fluent:Notify({
				Title = "✅ Teleportado",
				Content = "Você foi teleportado 40 studs para cima",
				Duration = 3
			})
		end
	end

	task.wait(0.5)
	tpFlyActive = false
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Z then
		Features.CamLock = not Features.CamLock
		CamLockToggle:SetValue(Features.CamLock)
	elseif input.KeyCode == Enum.KeyCode.I then
		Features.InfinityJump = not Features.InfinityJump
		InfinityJumpToggle:SetValue(Features.InfinityJump)
	elseif input.KeyCode == Enum.KeyCode.F then
		Features.Fly = not Features.Fly
		FlyToggle:SetValue(Features.Fly)
	elseif input.KeyCode == Enum.KeyCode.N then
		Features.NoClip = not Features.NoClip
		NoClipToggle:SetValue(Features.NoClip)
	elseif input.KeyCode == Enum.KeyCode.T then
		TPToClosestPlayer()
	elseif input.KeyCode == Enum.KeyCode.Y then
		TPFlyUp()
	end
end)

-- Notificação de Carregamento
Window:SelectTab(1)

Fluent:Notify({
	Title = "✅ ZYRO HUB UNIVERSAL",
	Content = "Script carregado com sucesso!\nCriador: Gomes.wqq",
	Duration = 5
})

print("✅ ZYRO HUB UNIVERSAL CARREGADO!")
print("📋 Funções: Cam Lock | Infinity Jump | Fly | No-Clip | TP Player | TP Fly")
