--[[
	XENO EXPLOIT - Fluent UI
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
	Title = "XENO EXPLOIT",
	SubTitle = "by Xeno",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

-- Abas
local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "zap" }),
	Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
	Teleport = Window:AddTab({ Title = "Teleport", Icon = "target" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Estado das Funções
local Features = {
	CustomHitbox = false,
	HitboxSize = 1,
	CamLock = false,
	SpeedBoost = false,
	Fly = false,
	NoClip = false,
	TPPlayer = false,
	TPFly = false,
}

local flying = false

-- ========== TAB MAIN ==========

Tabs.Main:AddParagraph({
	Title = "Bem-vindo",
	Content = "XENO EXPLOIT\nScript simplificado com Fluent UI"
})

-- Custom Hitbox Toggle
local HitboxToggle = Tabs.Main:AddToggle("CustomHitbox", {
	Title = "Custom Hitbox",
	Default = false,
	Callback = function(Value)
		Features.CustomHitbox = Value
	end
})

-- Hitbox Size Slider
local HitboxSlider = Tabs.Main:AddSlider("HitboxSize", {
	Title = "Tamanho do Hitbox",
	Description = "Ajuste de 1 a 50",
	Default = 1,
	Min = 1,
	Max = 50,
	Rounding = 1,
	Callback = function(Value)
		Features.HitboxSize = Value
	end
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
			Content = "XENO EXPLOIT está funcionando!",
			Duration = 3
		})
	end
})

-- ========== TAB MOVEMENT ==========

-- Speed Boost Toggle
local SpeedToggle = Tabs.Movement:AddToggle("SpeedBoost", {
	Title = "Speed Boost [V]",
	Default = false,
	Callback = function(Value)
		Features.SpeedBoost = Value
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
	Content = "W/A/S/D - Mover\nSpace - Subir\nCtrl - Descer"
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
		Features.TPPlayer = true
		TPToClosestPlayer()
	end
})

-- TP Fly Up Button
Tabs.Teleport:AddButton({
	Title = "TP Fly Up [Y]",
	Description = "Teleporta 30 studs para cima",
	Callback = function()
		Features.TPFly = true
		TPFlyUp()
	end
})

Tabs.Teleport:AddParagraph({
	Title = "Informações",
	Content = "T - Teleporta para player mais próximo\nY - Teleporta 30 studs para cima"
})

-- ========== TAB SETTINGS ==========

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("XenoExploit")
SaveManager:SetFolder("XenoExploit/save")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ========== IMPLEMENTAÇÃO DAS FEATURES ==========

-- Custom Hitbox
RunService.RenderStepped:Connect(function()
	if Features.CustomHitbox and LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			pcall(function()
				hrp.Size = Vector3.new(Features.HitboxSize, Features.HitboxSize, Features.HitboxSize)
			end)
		end
	end
end)

-- Speed Boost
RunService.RenderStepped:Connect(function()
	if Features.SpeedBoost and LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp.AssemblyLinearVelocity then
			pcall(function()
				local vel = hrp.AssemblyLinearVelocity
				if vel.Magnitude > 0 then
					hrp.AssemblyLinearVelocity = vel.Unit * 30
				else
					hrp.AssemblyLinearVelocity = Camera.CFrame.LookVector * 30
				end
			end)
		end
	end
end)

-- Fly System
local function StartFly()
	if not LocalPlayer.Character then return end
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	flying = true
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = hrp

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not Features.Fly or not hrp or not hrp.Parent then
			connection:Disconnect()
			pcall(function() bodyVelocity:Destroy() end)
			flying = false
			return
		end

		local moveDirection = Vector3.new(0, 0, 0)

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
			bodyVelocity.Velocity = moveDirection.Unit * 50
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

-- TP Player
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

-- TP Fly Up
function TPFlyUp()
	if LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			pcall(function()
				hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
			end)
			Fluent:Notify({
				Title = "✅ Teleportado",
				Content = "Você voou 30 studs para cima",
				Duration = 3
			})
		end
	end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Z then
		Features.CamLock = not Features.CamLock
		CamLockToggle:SetValue(Features.CamLock)
	elseif input.KeyCode == Enum.KeyCode.V then
		Features.SpeedBoost = not Features.SpeedBoost
		SpeedToggle:SetValue(Features.SpeedBoost)
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
	Title = "✅ XENO EXPLOIT",
	Content = "Script carregado com sucesso!\nPressione LeftControl para minimizar",
	Duration = 5
})

print("✅ XENO EXPLOIT CARREGADO!")
print("📋 Funções: Cam Lock | Custom Hitbox | Speed Boost | Fly | No-Clip | TP Player | TP Fly")
