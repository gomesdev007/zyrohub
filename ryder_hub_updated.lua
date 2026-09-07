--// Ryder hub
--// creator: gomesemcall
--// UI + FUNCTIONS
--// UPDATED: Auto Jump +60 studs | Auto Slap System

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

pcall(function()
    local old = playerGui:FindFirstChild("RyderHub")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- CONFIG
--==================================================

local RETURN_POSITION = Vector3.new(5.12, 1.06, -5.56)
local RETURN_SPEED = 150

local selectedSpeed = 16
local selectedJump = 50

local autoReturnEnabled = false
local autoSlapEnabled = false
local instantPromptEnabled = false
local autoSlapTPEnabled = false
local selectedTargetPlayer = nil
local lastSafePosition = nil
local returning = false

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "RyderHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--==================================================
-- MAIN
--==================================================

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(255,410)
main.Position = UDim2.new(.5,-127,.5,-205)
main.BackgroundColor3 = Color3.fromRGB(11,11,13)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,17)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(68,23,30)
mainStroke.Thickness = 1
mainStroke.Transparency = .1
mainStroke.Parent = main

--==================================================
-- TOP ACCENT
--==================================================

local accent = Instance.new("Frame")
accent.AnchorPoint = Vector2.new(.5,0)
accent.Position = UDim2.new(.5,0,0,0)
accent.Size = UDim2.fromOffset(65,3)
accent.BackgroundColor3 = Color3.fromRGB(185,30,46)
accent.BorderSizePixel = 0
accent.Parent = main

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1,0)
accentCorner.Parent = accent

--==================================================
-- TITLE
--==================================================

local redTitle = Instance.new("TextLabel")
redTitle.BackgroundTransparency = 1
redTitle.Position = UDim2.new(.5,-55,0,15)
redTitle.Size = UDim2.fromOffset(55,27)
redTitle.Font = Enum.Font.GothamBold
redTitle.TextSize = 19
redTitle.Text = "Ryder"
redTitle.TextColor3 = Color3.fromRGB(190,32,48)
redTitle.TextXAlignment = Enum.TextXAlignment.Right
redTitle.Parent = main

local whiteTitle = Instance.new("TextLabel")
whiteTitle.BackgroundTransparency = 1
whiteTitle.Position = UDim2.new(.5,0,0,15)
whiteTitle.Size = UDim2.fromOffset(55,27)
whiteTitle.Font = Enum.Font.GothamBold
whiteTitle.TextSize = 19
whiteTitle.Text = " hub"
whiteTitle.TextColor3 = Color3.fromRGB(245,245,245)
whiteTitle.TextXAlignment = Enum.TextXAlignment.Left
whiteTitle.Parent = main

--==================================================
-- CREATOR
--==================================================

local creator = Instance.new("TextLabel")
creator.BackgroundTransparency = 1
creator.Position = UDim2.fromOffset(15,43)
creator.Size = UDim2.new(1,-30,0,15)
creator.Font = Enum.Font.Gotham
creator.TextSize = 9
creator.Text = "creator: gomesemcall"
creator.TextColor3 = Color3.fromRGB(105,105,110)
creator.TextXAlignment = Enum.TextXAlignment.Center
creator.Parent = main

--==================================================
-- DIVIDER
--==================================================

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(20,67)
divider.Size = UDim2.new(1,-40,0,1)
divider.BackgroundColor3 = Color3.fromRGB(35,35,38)
divider.BorderSizePixel = 0
divider.Parent = main

--==================================================
-- CARD CREATOR
--==================================================

local function createCard(y, name, initialStatus)

    local card = Instance.new("Frame")
    card.Position = UDim2.fromOffset(16,y)
    card.Size = UDim2.new(1,-32,0,50)
    card.BackgroundColor3 = Color3.fromRGB(17,17,20)
    card.BorderSizePixel = 0
    card.Parent = main

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0,12)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(34,34,38)
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(5,5)
    dot.Position = UDim2.fromOffset(13,13)
    dot.BackgroundColor3 = Color3.fromRGB(75,75,80)
    dot.BorderSizePixel = 0
    dot.Parent = card

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1,0)
    dotCorner.Parent = dot

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(25,7)
    label.Size = UDim2.new(1,-85,0,18)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.Text = name
    label.TextColor3 = Color3.fromRGB(235,235,238)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(25,26)
    status.Size = UDim2.new(1,-85,0,14)
    status.Font = Enum.Font.Gotham
    status.TextSize = 8
    status.Text = initialStatus or "inactive"
    status.TextColor3 = Color3.fromRGB(95,95,100)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = card

    local toggle = Instance.new("TextButton")
    toggle.AnchorPoint = Vector2.new(1,.5)
    toggle.Position = UDim2.new(1,-12,.5,0)
    toggle.Size = UDim2.fromOffset(34,18)
    toggle.BackgroundColor3 = Color3.fromRGB(30,30,34)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = card

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1,0)
    toggleCorner.Parent = toggle

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(52,52,57)
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggle

    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.fromOffset(12,12)
    toggleDot.Position = UDim2.new(0,3,.5,-6)
    toggleDot.BackgroundColor3 = Color3.fromRGB(130,130,135)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggle

    local toggleDotCorner = Instance.new("UICorner")
    toggleDotCorner.CornerRadius = UDim.new(1,0)
    toggleDotCorner.Parent = toggleDot

    local enabled = false

    toggle.MouseButton1Click:Connect(function()

        enabled = not enabled

        if enabled then

            TweenService:Create(
                toggle,
                TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(105,23,35)}
            ):Play()

            TweenService:Create(
                toggleDot,
                TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(1,-15,.5,-6),
                    BackgroundColor3 = Color3.fromRGB(255,255,255)
                }
            ):Play()

            TweenService:Create(
                dot,
                TweenInfo.new(.2),
                {BackgroundColor3 = Color3.fromRGB(195,32,48)}
            ):Play()

            status.Text = "active"
            status.TextColor3 = Color3.fromRGB(185,32,48)

        else

            TweenService:Create(
                toggle,
                TweenInfo.new(.22),
                {BackgroundColor3 = Color3.fromRGB(30,30,34)}
            ):Play()

            TweenService:Create(
                toggleDot,
                TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(0,3,.5,-6),
                    BackgroundColor3 = Color3.fromRGB(130,130,135)
                }
            ):Play()

            TweenService:Create(
                dot,
                TweenInfo.new(.2),
                {BackgroundColor3 = Color3.fromRGB(75,75,80)}
            ):Play()

            status.Text = "inactive"
            status.TextColor3 = Color3.fromRGB(95,95,100)

        end

        if name == "Auto Return" then
            autoReturnEnabled = enabled
        elseif name == "Auto Slap" then
            autoSlapEnabled = enabled
        elseif name == "Instant Prompt" then
            instantPromptEnabled = enabled
            -- Desativa/ativa todos os ProximityPrompts
            local promptService = game:GetService("ProximityPromptService")
            for _, prompt in pairs(promptService:FindLocalPrompts()) do
                prompt.Enabled = not enabled
                if enabled then
                    prompt.HoldDuration = 0
                end
            end
        end
    end)

    return card
end

--==================================================
-- AUTO RETURN
--==================================================

local autoCard = createCard(82,"Auto Return","inactive")

--==================================================
-- AUTO SLAP (NOVO)
--==================================================

local slapCard = createCard(140,"Auto Slap","inactive")

--==================================================
-- INSTANT PROMPT
--==================================================

local instantPromptCard = createCard(197,"Instant Prompt","inactive")

--==================================================
-- SLIDER CREATOR
--==================================================

local function createSlider(y,titleText,defaultValue,onChanged)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(19,y)
    title.Size = UDim2.fromOffset(100,17)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 10
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(190,190,195)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1,-58,0,y)
    valueLabel.Size = UDim2.fromOffset(39,17)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Color3.fromRGB(190,32,48)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = main

    local slider = Instance.new("TextButton")
    slider.Position = UDim2.fromOffset(20,y+29)
    slider.Size = UDim2.new(1,-40,0,4)
    slider.BackgroundColor3 = Color3.fromRGB(35,35,39)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.AutoButtonColor = false
    slider.Parent = main

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1,0)
    sliderCorner.Parent = slider

    local percent = defaultValue / 500

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(175,30,45)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.fromOffset(10,10)
    thumb.AnchorPoint = Vector2.new(.5,.5)
    thumb.Position = UDim2.new(percent,0,.5,0)
    thumb.BackgroundColor3 = Color3.fromRGB(235,235,238)
    thumb.BorderSizePixel = 0
    thumb.Parent = slider

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1,0)
    thumbCorner.Parent = thumb

    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Color = Color3.fromRGB(175,30,45)
    thumbStroke.Thickness = 1.5
    thumbStroke.Parent = thumb

    local sliding = false

    local function setSlider(x)

        local left = slider.AbsolutePosition.X
        local width = slider.AbsoluteSize.X

        local p = math.clamp((x-left)/width,0,1)
        local value = math.floor(p*500+.5)

        valueLabel.Text = tostring(value)

        fill.Size = UDim2.new(p,0,1,0)
        thumb.Position = UDim2.new(p,0,.5,0)

        onChanged(value)
    end

    slider.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            sliding = true
            setSlider(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)

        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            setSlider(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            sliding = false
        end
    end)
end

--==================================================
-- SPEED / JUMP
--==================================================

createSlider(262,"Speed",selectedSpeed,function(value)
    selectedSpeed = value
end)

createSlider(310,"Jump",selectedJump,function(value)
    selectedJump = value
end)

--==================================================
-- AUTO SLAP TP SELECTOR SLIDER
--==================================================

local slapTPTitle = Instance.new("TextLabel")
slapTPTitle.BackgroundTransparency = 1
slapTPTitle.Position = UDim2.fromOffset(19,358)
slapTPTitle.Size = UDim2.fromOffset(100,17)
slapTPTitle.Font = Enum.Font.GothamSemibold
slapTPTitle.TextSize = 10
slapTPTitle.Text = "Auto Slap TP"
slapTPTitle.TextColor3 = Color3.fromRGB(190,190,195)
slapTPTitle.TextXAlignment = Enum.TextXAlignment.Left
slapTPTitle.Parent = main

local slapTPStatus = Instance.new("TextLabel")
slapTPStatus.BackgroundTransparency = 1
slapTPStatus.Position = UDim2.new(1,-58,0,358)
slapTPStatus.Size = UDim2.fromOffset(39,17)
slapTPStatus.Font = Enum.Font.GothamBold
slapTPStatus.TextSize = 10
slapTPStatus.Text = selectedTargetPlayer and selectedTargetPlayer.Name or "None"
slapTPStatus.TextColor3 = Color3.fromRGB(190,32,48)
slapTPStatus.TextXAlignment = Enum.TextXAlignment.Right
slapTPStatus.Parent = main

local slapTPButton = Instance.new("TextButton")
slapTPButton.Position = UDim2.fromOffset(20,375)
slapTPButton.Size = UDim2.new(1,-40,0,24)
slapTPButton.BackgroundColor3 = Color3.fromRGB(35,35,39)
slapTPButton.BorderSizePixel = 0
slapTPButton.Text = selectedTargetPlayer and ("Target: " .. selectedTargetPlayer.Name) or "Click to select target"
slapTPButton.Font = Enum.Font.GothamSemibold
slapTPButton.TextSize = 10
slapTPButton.TextColor3 = Color3.fromRGB(190,190,195)
slapTPButton.AutoButtonColor = false
slapTPButton.Parent = main

local slapTPCorner = Instance.new("UICorner")
slapTPCorner.CornerRadius = UDim.new(0,8)
slapTPCorner.Parent = slapTPButton

local slapTPStroke = Instance.new("UIStroke")
slapTPStroke.Color = Color3.fromRGB(52,52,57)
slapTPStroke.Thickness = 1
slapTPStroke.Parent = slapTPButton

slapTPButton.MouseButton1Click:Connect(function()
    showPlayerList()
end)

slapTPButton.MouseEnter:Connect(function()
    TweenService:Create(
        slapTPButton,
        TweenInfo.new(.1),
        {BackgroundColor3 = Color3.fromRGB(45,45,50)}
    ):Play()
end)

slapTPButton.MouseLeave:Connect(function()
    TweenService:Create(
        slapTPButton,
        TweenInfo.new(.1),
        {BackgroundColor3 = Color3.fromRGB(35,35,39)}
    ):Play()
end)

--==================================================
-- FOOTER
--==================================================

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(15,386)
footer.Size = UDim2.new(1,-30,0,15)
footer.Font = Enum.Font.Gotham
footer.TextSize = 8
footer.Text = "ready"
footer.TextColor3 = Color3.fromRGB(75,75,80)
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = main

--==================================================
-- PLAYER LIST UI
--==================================================

local function showPlayerList()

    local listGui = Instance.new("ScreenGui")
    listGui.Name = "PlayerListGui"
    listGui.ResetOnSpawn = false
    listGui.IgnoreGuiInset = true
    listGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    listGui.Parent = playerGui

    -- Fundo transparente para detectar cliques fora
    local backgroundClick = Instance.new("Frame")
    backgroundClick.Size = UDim2.fromScale(1,1)
    backgroundClick.BackgroundColor3 = Color3.fromRGB(0,0,0)
    backgroundClick.BackgroundTransparency = 0.5
    backgroundClick.BorderSizePixel = 0
    backgroundClick.ZIndex = 1
    backgroundClick.Parent = listGui

    backgroundClick.MouseButton1Click:Connect(function()
        listGui:Destroy()
    end)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.fromOffset(200,250)
    listFrame.Position = UDim2.new(.5,-100,.5,-125)
    listFrame.BackgroundColor3 = Color3.fromRGB(11,11,13)
    listFrame.BorderSizePixel = 0
    listFrame.ZIndex = 2
    listFrame.Parent = listGui

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0,12)
    listCorner.Parent = listFrame

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(68,23,30)
    listStroke.Thickness = 1
    listStroke.Transparency = .1
    listStroke.Parent = listFrame

    local listTitle = Instance.new("TextLabel")
    listTitle.BackgroundTransparency = 1
    listTitle.Size = UDim2.new(1,0,0,30)
    listTitle.Font = Enum.Font.GothamBold
    listTitle.TextSize = 14
    listTitle.Text = "Select Target"
    listTitle.TextColor3 = Color3.fromRGB(190,32,48)
    listTitle.ZIndex = 3
    listTitle.Parent = listFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Position = UDim2.fromOffset(0,30)
    scrollFrame.Size = UDim2.new(1,0,1,-30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ZIndex = 3
    scrollFrame.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0,5)
    listLayout.Parent = scrollFrame

    local function createPlayerButton(targetPlayer)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-10,0,30)
        btn.Position = UDim2.fromOffset(5,0)
        btn.BackgroundColor3 = Color3.fromRGB(17,17,20)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 11
        btn.Text = targetPlayer.Name
        btn.TextColor3 = Color3.fromRGB(235,235,238)
        btn.AutoButtonColor = false
        btn.ZIndex = 3
        btn.Parent = scrollFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0,8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            selectedTargetPlayer = targetPlayer
            lastSafePosition = player.Character:FindFirstChild("HumanoidRootPart").Position
            autoSlapTPEnabled = true
            slapTPStatus.Text = targetPlayer.Name
            slapTPButton.Text = "Target: " .. targetPlayer.Name
            listGui:Destroy()
        end)

        btn.MouseEnter:Connect(function()
            TweenService:Create(
                btn,
                TweenInfo.new(.1),
                {BackgroundColor3 = Color3.fromRGB(25,25,28)}
            ):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(
                btn,
                TweenInfo.new(.1),
                {BackgroundColor3 = Color3.fromRGB(17,17,20)}
            ):Play()
        end)
    end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            createPlayerButton(targetPlayer)
        end
    end

    scrollFrame.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 10)
    listLayout.Changed:Connect(function()
        scrollFrame.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 10)
    end)

end

--==================================================
-- AUTO SLAP TP FUNCTION
--==================================================

local function autoSlapTP()
    if not autoSlapTPEnabled or not selectedTargetPlayer then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local targetCharacter = selectedTargetPlayer.Character
    
    if not root or not targetCharacter then
        return
    end

    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    -- Usa a última posição segura conhecida
    local returnPos = lastSafePosition
    
    -- Teletransporta atrás do player (offset de 3 studs)
    local behindOffset = (targetRoot.CFrame.LookVector * -3)
    local tpPos = targetRoot.Position + behindOffset
    root.CFrame = CFrame.new(tpPos)

    -- Aguarda um frame para o teleporte processar
    task.wait(0.05)

    -- Dispara o remote
    local event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if event then
        local slapRemote = event:FindFirstChild("SlapHand")
        if slapRemote then
            pcall(function()
                slapRemote:FireServer(selectedTargetPlayer)
            end)
        end
    end

    -- Aguarda um frame
    task.wait(0.05)

    -- Volta para a posição anterior
    root.CFrame = CFrame.new(returnPos)
end

--==================================================
-- INSTANT PROMPT FUNCTION
--==================================================

local function updateInstantPrompts()
    local promptService = game:GetService("ProximityPromptService")
    for _, prompt in pairs(promptService:FindLocalPrompts()) do
        prompt.HoldDuration = 0
        prompt.Enabled = not instantPromptEnabled
    end
end

--==================================================
-- AUTO SLAP FUNCTION
--==================================================

local function autoSlap()
    if not autoSlapEnabled then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    -- Procura por todos os players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherCharacter = otherPlayer.Character
            if otherCharacter then
                local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
                if otherRoot then
                    -- Calcula distância
                    local distance = (root.Position - otherRoot.Position).Magnitude

                    -- Se estiver a menos de 3 studs, executa o slap
                    if distance < 3 then
                        local event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if event then
                            local slapRemote = event:FindFirstChild("SlapHand")
                            if slapRemote then
                                pcall(function()
                                    slapRemote:FireServer(otherPlayer)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

--==================================================
-- AUTO RETURN WITH JUMP BOOST
--==================================================

local function autoReturn()

    if not autoReturnEnabled then
        return
    end

    if returning then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    returning = true

    local distance = (root.Position - RETURN_POSITION).Magnitude
    local duration = math.max(distance / RETURN_SPEED, 0.03)

    local tween = TweenService:Create(
        root,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        ),
        {
            CFrame = CFrame.new(RETURN_POSITION)
        }
    )

    tween:Play()

    -- Loop de saltos a cada 40 studs percorridos
    local jumpCycle = 0
    local lastPosition = root.Position
    local cycleUp = true -- true = subir, false = descer

    local jumpConnection
    jumpConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not tween.Playing then
            jumpConnection:Disconnect()
            return
        end

        -- Calcula distância percorrida
        local distanceTraveled = (lastPosition - root.Position).Magnitude
        jumpCycle = jumpCycle + distanceTraveled
        lastPosition = root.Position

        if jumpCycle >= 40 then
            jumpCycle = 0

            if cycleUp then
                -- Sobe +60 studs
                local newPos = root.Position + Vector3.new(0, 60, 0)
                root.CFrame = CFrame.new(newPos)
                cycleUp = false
            else
                -- Desce -30 studs
                local newPos = root.Position - Vector3.new(0, 30, 0)
                root.CFrame = CFrame.new(newPos)
                cycleUp = true
            end
        end
    end)

    tween.Completed:Connect(function()
        returning = false
        if jumpConnection then
            jumpConnection:Disconnect()
        end
    end)
end

--==================================================
-- PROMPT COMPLETED
--==================================================

ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)

    if triggeringPlayer and triggeringPlayer ~= player then
        return
    end

    if autoReturnEnabled then
        task.spawn(autoReturn)
    end

end)

--==================================================
-- AUTO SLAP LOOP
--==================================================

task.spawn(function()
    while gui.Parent do
        task.wait(0.1)
        autoSlap()
    end
end)

--==================================================
-- AUTO SLAP TP LOOP (A CADA 4 SEGUNDOS)
--==================================================

task.spawn(function()
    while gui.Parent do
        task.wait(4)
        if autoSlapTPEnabled and selectedTargetPlayer then
            autoSlapTP()
        end
    end
end)

--==================================================
-- SAFE POSITION UPDATE LOOP (A CADA 1 SEGUNDO)
--==================================================

task.spawn(function()
    while gui.Parent do
        task.wait(1)
        if autoSlapTPEnabled and selectedTargetPlayer then
            local character = player.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    lastSafePosition = root.Position
                end
            end
        end
    end
end)

--==================================================
-- INSTANT PROMPT MONITORING LOOP
--==================================================

task.spawn(function()
    while gui.Parent do
        task.wait(0.1)
        if instantPromptEnabled then
            updateInstantPrompts()
        end
    end
end)

--==================================================
-- FORCE SPEED / JUMP
--==================================================

task.spawn(function()

    while gui.Parent do

        local character = player.Character

        if character then

            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then

                -- força velocidade escolhida
                humanoid.WalkSpeed = selectedSpeed

                -- força pulo escolhido
                if humanoid.UseJumpPower then
                    humanoid.JumpPower = selectedJump
                else
                    humanoid.JumpHeight = selectedJump
                end

            end

        end

        task.wait(.05)
    end

end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function(character)

    local humanoid = character:WaitForChild("Humanoid",5)

    if humanoid then

        task.wait(.15)

        humanoid.WalkSpeed = selectedSpeed

        if humanoid.UseJumpPower then
            humanoid.JumpPower = selectedJump
        else
            humanoid.JumpHeight = selectedJump
        end

    end
end)

--==================================================
-- FLOATING BUTTON
--==================================================

local floatButton = Instance.new("ImageButton")
floatButton.Name = "RyderButton"
floatButton.Size = UDim2.fromOffset(48,48)
floatButton.Position = UDim2.new(0,12,.5,-24)
floatButton.BackgroundColor3 = Color3.fromRGB(12,12,14)
floatButton.BorderSizePixel = 0
floatButton.Image = "rbxassetid://85225614638434"
floatButton.ScaleType = Enum.ScaleType.Crop
floatButton.AutoButtonColor = false
floatButton.Visible = true
floatButton.ZIndex = 50
floatButton.Parent = gui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1,0)
floatCorner.Parent = floatButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(150,28,43)
floatStroke.Thickness = 1.5
floatStroke.Parent = floatButton

--==================================================
-- FLOAT BUTTON
--==================================================

local open = true
local busy = false

floatButton.MouseButton1Click:Connect(function()

    if busy then
        return
    end

    busy = true

    if open then

        open = false

        local closeTween = TweenService:Create(
            main,
            TweenInfo.new(.28,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
            {
                Size = UDim2.fromOffset(0,0)
            }
        )

        closeTween:Play()
        closeTween.Completed:Wait()

        main.Visible = false

    else

        open = true
        main.Visible = true
        main.Size = UDim2.fromOffset(0,0)

        TweenService:Create(
            main,
            TweenInfo.new(.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {
                Size = UDim2.fromOffset(255,410)
            }
        ):Play()
    end

    task.wait(.08)
    busy = false
end)

--==================================================
-- DRAG MAIN
--==================================================

local dragging = false
local dragStart
local startPosition

local function beginDrag(input)

    dragging = true
    dragStart = input.Position
    startPosition = main.Position

end

local function moveDrag(input)

    if not dragging then
        return
    end

    local delta = input.Position - dragStart

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end

local function endDrag()
    dragging = false
end

redTitle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        beginDrag(input)
    end

end)

whiteTitle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        beginDrag(input)
    end

end)

creator.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        beginDrag(input)
    end

end)

UIS.InputChanged:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        moveDrag(input)
    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        endDrag()
    end

end)

--==================================================
-- DRAG FLOAT BUTTON
--==================================================

local floatDragging = false
local floatMoved = false
local floatStart
local floatStartPos

floatButton.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        floatDragging = true
        floatMoved = false
        floatStart = input.Position
        floatStartPos = floatButton.Position
    end

end)

UIS.InputChanged:Connect(function(input)

    if not floatDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - floatStart

        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            floatMoved = true
        end

        floatButton.Position = UDim2.new(
            floatStartPos.X.Scale,
            floatStartPos.X.Offset + delta.X,
            floatStartPos.Y.Scale,
            floatStartPos.Y.Offset + delta.Y
        )
    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        floatDragging = false
    end

end)

--==================================================
-- INITIAL ANIMATION
--==================================================

main.Size = UDim2.fromOffset(0,0)

TweenService:Create(
    main,
    TweenInfo.new(.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {
        Size = UDim2.fromOffset(255,410)
    }
):Play()
