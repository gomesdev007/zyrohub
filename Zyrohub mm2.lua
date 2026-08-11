local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove versão anterior
local oldGui = playerGui:FindFirstChild("ZyroHubAutoClickPC")
if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZyroHubAutoClickPC"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 230, 0, 125)
Main.Position = UDim2.new(0.5, -115, 0.5, -62)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(45, 45, 45)
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 7)
Title.BackgroundTransparency = 1
Title.Text = "Zyro Hub Auto Click PC"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--// Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Auto Click: OFF"
Status.TextColor3 = Color3.fromRGB(160, 160, 160)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--// Botão
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 34)
Toggle.Position = UDim2.new(0, 10, 0, 58)
Toggle.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
Toggle.BorderSizePixel = 0
Toggle.AutoButtonColor = false
Toggle.Text = "ACTIVATE"
Toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
Toggle.TextSize = 13
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

--// Créditos
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, -20, 0, 18)
Credits.Position = UDim2.new(0, 10, 1, -22)
Credits.BackgroundTransparency = 1
Credits.Text = "Creator by: gomez"
Credits.TextColor3 = Color3.fromRGB(95, 95, 95)
Credits.TextSize = 10
Credits.Font = Enum.Font.Gotham
Credits.TextXAlignment = Enum.TextXAlignment.Center
Credits.Parent = Main

local enabled = false
local interval = 0.5
local guiVisible = true

local function IsMouseOverGui()
    local mousePos = UserInputService:GetMouseLocation()

    local guiPos = Main.AbsolutePosition
    local guiSize = Main.AbsoluteSize

    return mousePos.X >= guiPos.X
        and mousePos.X <= guiPos.X + guiSize.X
        and mousePos.Y >= guiPos.Y
        and mousePos.Y <= guiPos.Y + guiSize.Y
end

local function SetAutoClick(state)
    enabled = state

    if enabled then
        Status.Text = "Auto Click: ON"
        Status.TextColor3 = Color3.fromRGB(80, 255, 130)

        Toggle.Text = "DEACTIVATE"
        Toggle.BackgroundColor3 = Color3.fromRGB(35, 100, 55)
    else
        Status.Text = "Auto Click: OFF"
        Status.TextColor3 = Color3.fromRGB(160, 160, 160)

        Toggle.Text = "ACTIVATE"
        Toggle.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    end
end

Toggle.MouseButton1Click:Connect(function()
    SetAutoClick(not enabled)
end)

--// Auto Click Loop
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(interval)

        if enabled and guiVisible and not IsMouseOverGui() then
            -- A ação de clique pode ser colocada aqui.
        end
    end
end)

--// Teclas X e Z
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType == Enum.UserInputType.Keyboard then

        -- X = abrir/fechar interface
        if input.KeyCode == Enum.KeyCode.X then
            guiVisible = not guiVisible
            Main.Visible = guiVisible
        end

        -- Z = ativar/desativar Auto Click
        if input.KeyCode == Enum.KeyCode.Z then
            SetAutoClick(not enabled)
        end
    end
end)

--// Sistema de arrastar
local dragging = false
local dragStart
local startPosition

local function UpdateDrag(input)
    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateDrag(input)
    end
end)

--// Animação de entrada
Main.Size = UDim2.new(0, 210, 0, 110)

task.spawn(function()
    for i = 1, 10 do
        Main.Size = UDim2.new(
            0,
            210 + (20 * (i / 10)),
            0,
            110 + (15 * (i / 10))
        )
        task.wait(0.02)
    end
end)
