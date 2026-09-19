-- super mini travel hub
-- floating buttons only: titan, kitsune, anjel, cosmic
-- movement speed: 500

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local SPEED = 500

local AREAS = {
    titan = Vector3.new(4797.97, 70.57, -327.25),
    kitsune = Vector3.new(4826.58, 78.57, -396.11),
    anjel = Vector3.new(5662.18, 70.57, -330.12),
    cosmic = Vector3.new(3389.95, 78.57, -325.76),
}

local gui = Instance.new("ScreenGui")
gui.Name = "SuperMiniTravel"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then
    gui.Parent = Player:WaitForChild("PlayerGui")
end

local holder = Instance.new("Frame")
holder.Name = "FloatingButtons"
holder.Size = UDim2.fromOffset(150, 190)
holder.Position = UDim2.new(1, -165, 0.5, -95)
holder.BackgroundTransparency = 1
holder.Parent = gui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = holder

local function getRoot()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local moving = false
local moveConnection

local function stopMovement()
    moving = false
    if moveConnection then
        moveConnection:Disconnect()
        moveConnection = nil
    end

    local root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        local humanoid = root.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = false
        end
    end
end

local function moveToArea(name)
    local target = AREAS[name]
    if not target then return end

    stopMovement()

    local root = getRoot()
    if not root then return end

    moving = true
    moveConnection = RunService.Heartbeat:Connect(function(dt)
        if not moving then return end

        local currentRoot = getRoot()
        if not currentRoot then
            stopMovement()
            return
        end

        local offset = target - currentRoot.Position
        local distance = offset.Magnitude

        if distance <= 2 then
            currentRoot.CFrame = CFrame.new(target)
            currentRoot.AssemblyLinearVelocity = Vector3.zero
            currentRoot.AssemblyAngularVelocity = Vector3.zero
            local humanoid = currentRoot.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.AutoRotate = false end
            moving = false
            moveConnection:Disconnect()
            moveConnection = nil
            return
        end

        local step = math.min(SPEED * dt, distance)
        local nextPosition = currentRoot.Position + offset.Unit * step
        currentRoot.CFrame = CFrame.lookAt(nextPosition, target)
        currentRoot.AssemblyLinearVelocity = Vector3.zero
        currentRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function makeButton(name)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.fromOffset(145, 38)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    button.BackgroundTransparency = 0.05
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(235, 235, 235)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.35
    stroke.Parent = button

    button.Activated:Connect(function()
        moveToArea(name)
    end)
end

makeButton("titan")
makeButton("kitsune")
makeButton("anjel")
makeButton("cosmic")

-- draggable on PC and mobile
local dragging = false
local dragStart
local startPos
local dragInput

holder.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = holder.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

holder.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        holder.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

Player.CharacterAdded:Connect(stopMovement)
