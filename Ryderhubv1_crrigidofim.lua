--//==================================================
--// RYDERHUB
--// MOVEMENT + AUTO RETURN + ANTI DROP
--// OWNER: gomescallpod
--//====================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--//====================================================
--// CONFIG
--//====================================================

local Speed = 16
local Jump = 50

local ReturnSpeed = 150
local ReturnPosition = Vector3.new(0.46, 1.06, -12.08)

local AutoReturn = false
local AntiDrop = false
local Returning = false

--// IDs DA BOLINHA
local BALL_IMAGE_1 = "rbxassetid://85225614638434"

--//====================================================
--// CHARACTER
--//====================================================

local Character
local Humanoid
local Root

local function UpdateCharacter()

    Character = Player.Character or Player.CharacterAdded:Wait()

    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")

    Humanoid.WalkSpeed = Speed

    if Humanoid.UseJumpPower then
        Humanoid.JumpPower = Jump
    else
        Humanoid.JumpHeight = Jump
    end
end

UpdateCharacter()

Player.CharacterAdded:Connect(function()

    task.wait(0.5)

    UpdateCharacter()
end)



--//==================================================
--// RYDER HUB — CUSTOM UI
--// creator: gomesemcall
--//==================================================

local UIS = UserInputService
local player = Player
local playerGui = player:WaitForChild("PlayerGui")

pcall(function()
    local old = playerGui:FindFirstChild("RyderHub")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "RyderHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local RED = Color3.fromRGB(190,32,48)
local RED_DARK = Color3.fromRGB(105,23,35)
local BG = Color3.fromRGB(11,11,13)
local CARD = Color3.fromRGB(17,17,20)
local WHITE = Color3.fromRGB(245,245,245)
local MUTED = Color3.fromRGB(105,105,110)

--==================================================
-- MAIN
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(255,315)
main.Position = UDim2.new(.5,-127,.5,-157)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local mc = Instance.new("UICorner",main)
mc.CornerRadius = UDim.new(0,17)

local ms = Instance.new("UIStroke",main)
ms.Color = Color3.fromRGB(68,23,30)
ms.Thickness = 1
ms.Transparency = .1

local accent = Instance.new("Frame",main)
accent.AnchorPoint = Vector2.new(.5,0)
accent.Position = UDim2.new(.5,0,0,0)
accent.Size = UDim2.fromOffset(65,3)
accent.BackgroundColor3 = RED
accent.BorderSizePixel = 0
Instance.new("UICorner",accent).CornerRadius = UDim.new(1,0)

--==================================================
-- TITLE
--==================================================

local redTitle = Instance.new("TextLabel",main)
redTitle.BackgroundTransparency = 1
redTitle.Position = UDim2.new(.5,-55,0,15)
redTitle.Size = UDim2.fromOffset(55,27)
redTitle.Font = Enum.Font.GothamBold
redTitle.TextSize = 19
redTitle.Text = "Ryder"
redTitle.TextColor3 = RED
redTitle.TextXAlignment = Enum.TextXAlignment.Right

local whiteTitle = Instance.new("TextLabel",main)
whiteTitle.BackgroundTransparency = 1
whiteTitle.Position = UDim2.new(.5,0,0,15)
whiteTitle.Size = UDim2.fromOffset(55,27)
whiteTitle.Font = Enum.Font.GothamBold
whiteTitle.TextSize = 19
whiteTitle.Text = " hub"
whiteTitle.TextColor3 = WHITE
whiteTitle.TextXAlignment = Enum.TextXAlignment.Left

local creator = Instance.new("TextLabel",main)
creator.BackgroundTransparency = 1
creator.Position = UDim2.fromOffset(15,43)
creator.Size = UDim2.new(1,-30,0,15)
creator.Font = Enum.Font.Gotham
creator.TextSize = 9
creator.Text = "creator: gomesemcall"
creator.TextColor3 = MUTED
creator.TextXAlignment = Enum.TextXAlignment.Center

local divider = Instance.new("Frame",main)
divider.Position = UDim2.fromOffset(20,67)
divider.Size = UDim2.new(1,-40,0,1)
divider.BackgroundColor3 = Color3.fromRGB(35,35,38)
divider.BorderSizePixel = 0

--==================================================
-- CARD / TOGGLE
--==================================================

local function makeToggleCard(y,title)
    local card = Instance.new("Frame",main)
    card.Position = UDim2.fromOffset(16,y)
    card.Size = UDim2.new(1,-32,0,50)
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0

    Instance.new("UICorner",card).CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke",card)
    stroke.Color = Color3.fromRGB(34,34,38)
    stroke.Thickness = 1

    local dot = Instance.new("Frame",card)
    dot.Size = UDim2.fromOffset(5,5)
    dot.Position = UDim2.fromOffset(13,13)
    dot.BackgroundColor3 = Color3.fromRGB(75,75,80)
    dot.BorderSizePixel = 0
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

    local label = Instance.new("TextLabel",card)
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(25,7)
    label.Size = UDim2.new(1,-85,0,18)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.Text = title
    label.TextColor3 = Color3.fromRGB(235,235,238)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local status = Instance.new("TextLabel",card)
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(25,26)
    status.Size = UDim2.new(1,-85,0,14)
    status.Font = Enum.Font.Gotham
    status.TextSize = 8
    status.Text = "inactive"
    status.TextColor3 = Color3.fromRGB(95,95,100)
    status.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton",card)
    toggle.AnchorPoint = Vector2.new(1,.5)
    toggle.Position = UDim2.new(1,-12,.5,0)
    toggle.Size = UDim2.fromOffset(34,18)
    toggle.BackgroundColor3 = Color3.fromRGB(30,30,34)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    Instance.new("UICorner",toggle).CornerRadius = UDim.new(1,0)

    local toggleStroke = Instance.new("UIStroke",toggle)
    toggleStroke.Color = Color3.fromRGB(52,52,57)
    toggleStroke.Thickness = 1

    local knob = Instance.new("Frame",toggle)
    knob.Size = UDim2.fromOffset(12,12)
    knob.Position = UDim2.new(0,3,.5,-6)
    knob.BackgroundColor3 = Color3.fromRGB(130,130,135)
    knob.BorderSizePixel = 0
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    return toggle,dot,status,knob
end

local autoToggle,autoDot,autoStatus,autoKnob =
    makeToggleCard(82,"Auto Return")

local antiToggle,antiDot,antiStatus,antiKnob =
    makeToggleCard(139,"Anti Drop")

local footer = Instance.new("TextLabel",main)
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(15,294)
footer.Size = UDim2.new(1,-30,0,15)
footer.Font = Enum.Font.Gotham
footer.TextSize = 8
footer.Text = "ready"
footer.TextColor3 = Color3.fromRGB(75,75,80)
footer.TextXAlignment = Enum.TextXAlignment.Center

local function updateToggle(toggle,dot,status,knob,on,name)
    if on then
        TweenService:Create(toggle,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
            {BackgroundColor3=RED_DARK}):Play()
        TweenService:Create(knob,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Position=UDim2.new(1,-15,.5,-6),BackgroundColor3=WHITE}):Play()
        TweenService:Create(dot,TweenInfo.new(.2),{BackgroundColor3=RED}):Play()
        status.Text = "active"
        status.TextColor3 = RED
        footer.Text = string.lower(name).." active"
    else
        TweenService:Create(toggle,TweenInfo.new(.22),
            {BackgroundColor3=Color3.fromRGB(30,30,34)}):Play()
        TweenService:Create(knob,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Position=UDim2.new(0,3,.5,-6),BackgroundColor3=Color3.fromRGB(130,130,135)}):Play()
        TweenService:Create(dot,TweenInfo.new(.2),
            {BackgroundColor3=Color3.fromRGB(75,75,80)}):Play()
        status.Text = "inactive"
        status.TextColor3 = Color3.fromRGB(95,95,100)
        footer.Text = "ready"
    end
end

autoToggle.MouseButton1Click:Connect(function()
    AutoReturn = not AutoReturn
    updateToggle(autoToggle,autoDot,autoStatus,autoKnob,AutoReturn,"Auto Return")
end)

antiToggle.MouseButton1Click:Connect(function()
    AntiDrop = not AntiDrop
    updateToggle(antiToggle,antiDot,antiStatus,antiKnob,AntiDrop,"Anti Drop")
end)

--==================================================
-- SLIDER
--==================================================

local function makeSlider(y,title,default,minValue,maxValue,callback)
    local titleLabel = Instance.new("TextLabel",main)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.fromOffset(19,y)
    titleLabel.Size = UDim2.fromOffset(100,17)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 10
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(190,190,195)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel",main)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1,-58,0,y)
    valueLabel.Size = UDim2.fromOffset(39,17)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = RED
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("TextButton",main)
    bar.Position = UDim2.fromOffset(20,y+29)
    bar.Size = UDim2.new(1,-40,0,5)
    bar.BackgroundColor3 = Color3.fromRGB(35,35,39)
    bar.BorderSizePixel = 0
    bar.Text = ""
    bar.AutoButtonColor = false
    Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame",bar)
    fill.BackgroundColor3 = Color3.fromRGB(175,30,45)
    fill.BorderSizePixel = 0
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame",bar)
    thumb.Size = UDim2.fromOffset(10,10)
    thumb.AnchorPoint = Vector2.new(.5,.5)
    thumb.BackgroundColor3 = Color3.fromRGB(235,235,238)
    thumb.BorderSizePixel = 0
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)

    local ts = Instance.new("UIStroke",thumb)
    ts.Color = RED
    ts.Thickness = 1.5

    local dragging = false

    local function setValue(x)
        local width = bar.AbsoluteSize.X
        if width <= 0 then return end

        local pct = math.clamp((x-bar.AbsolutePosition.X)/width,0,1)
        local value = math.floor(minValue+(maxValue-minValue)*pct+.5)

        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(pct,0,1,0)

        TweenService:Create(thumb,TweenInfo.new(.07,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position=UDim2.new(pct,0,.5,0)}):Play()

        callback(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            setValue(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType==Enum.UserInputType.MouseMovement
            or input.UserInputType==Enum.UserInputType.Touch) then
            setValue(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)

    task.defer(function()
        local pct=(default-minValue)/(maxValue-minValue)
        fill.Size=UDim2.new(pct,0,1,0)
        thumb.Position=UDim2.new(pct,0,.5,0)
    end)
end

makeSlider(197,"SPEED",Speed,1,500,function(value)
    Speed=value
    if Humanoid then Humanoid.WalkSpeed=value end
end)

makeSlider(247,"JUMP",Jump,1,500,function(value)
    Jump=value
    if Humanoid then
        if Humanoid.UseJumpPower then
            Humanoid.JumpPower=value
        else
            Humanoid.JumpHeight=value
        end
    end
end)

--==================================================
-- FLOATING IMAGE BUTTON
--==================================================

local floatButton = Instance.new("ImageButton",gui)
floatButton.Name = "RyderButton"
floatButton.Size = UDim2.fromOffset(52,52)
floatButton.Position = UDim2.new(0,12,.5,-26)
floatButton.BackgroundColor3 = Color3.fromRGB(12,12,14)
floatButton.BorderSizePixel = 0
floatButton.Image = "rbxassetid://85225614638434"
floatButton.ScaleType = Enum.ScaleType.Crop
floatButton.AutoButtonColor = false
floatButton.ZIndex = 50

local fc = Instance.new("UICorner",floatButton)
fc.CornerRadius = UDim.new(1,0)

local fs = Instance.new("UIStroke",floatButton)
fs.Color = RED
fs.Thickness = 1.5

local fscale = Instance.new("UIScale",floatButton)

--==================================================
-- MAIN DRAG
--==================================================

local mainDragging=false
local mainStart
local mainStartPos

local function startMainDrag(input)
    mainDragging=true
    mainStart=input.Position
    mainStartPos=main.Position
end

for _,obj in ipairs({redTitle,whiteTitle,creator}) do
    obj.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            startMainDrag(input)
        end
    end)
end

UIS.InputChanged:Connect(function(input)
    if mainDragging and (
        input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-mainStart
        main.Position=UDim2.new(
            mainStartPos.X.Scale,mainStartPos.X.Offset+delta.X,
            mainStartPos.Y.Scale,mainStartPos.Y.Offset+delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
    or input.UserInputType==Enum.UserInputType.Touch then
        mainDragging=false
    end
end)

--==================================================
-- FLOAT BUTTON: DRAG OR CLICK
--==================================================

local open=true
local busy=false
local floatDragging=false
local floatMoved=false
local floatStart
local floatStartPos

local function openGui()
    if busy then return end
    busy=true
    open=true
    main.Visible=true
    main.Size=UDim2.fromOffset(0,0)
    TweenService:Create(main,
        TweenInfo.new(.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.fromOffset(255,315)}):Play()
    task.wait(.08)
    busy=false
end

local function closeGui()
    if busy then return end
    busy=true
    open=false
    local t=TweenService:Create(main,
        TweenInfo.new(.28,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
        {Size=UDim2.fromOffset(0,0)})
    t:Play()
    t.Completed:Wait()
    main.Visible=false
    busy=false
end

floatButton.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
    or input.UserInputType==Enum.UserInputType.Touch then
        floatDragging=true
        floatMoved=false
        floatStart=input.Position
        floatStartPos=floatButton.Position
        TweenService:Create(fscale,TweenInfo.new(.12),{Scale=1.08}):Play()
    end
end)

UIS.InputChanged:Connect(function(input)
    if not floatDragging then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement
    and input.UserInputType~=Enum.UserInputType.Touch then return end

    local delta=input.Position-floatStart
    if math.abs(delta.X)>5 or math.abs(delta.Y)>5 then
        floatMoved=true
    end

    floatButton.Position=UDim2.new(
        floatStartPos.X.Scale,floatStartPos.X.Offset+delta.X,
        floatStartPos.Y.Scale,floatStartPos.Y.Offset+delta.Y
    )
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1
    and input.UserInputType~=Enum.UserInputType.Touch then return end

    if floatDragging then
        floatDragging=false
        TweenService:Create(fscale,TweenInfo.new(.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Scale=1}):Play()

        if not floatMoved then
            if open then closeGui() else openGui() end
        end
    end
end)

--==================================================
-- INITIAL ANIMATION
--==================================================

main.Size=UDim2.fromOffset(0,0)
TweenService:Create(main,
    TweenInfo.new(.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.fromOffset(255,315)}):Play()


--//====================================================
--// ANTI DROP
--// DropEggRequest - Block From Firing
--//====================================================

local Remote =
    workspace:WaitForChild("Remotes")
    :WaitForChild("DropEggRequest")

local Blocked = false

-- Mantém o estado do bloqueio sincronizado com o toggle.
task.spawn(function()
    while task.wait(0.1) do
        Blocked = AntiDrop
    end
end)

local oldNamecall

oldNamecall =
    hookmetamethod(
        game,
        "__namecall",
        newcclosure(function(self, ...)
            local method = getnamecallmethod()

            -- Bloqueia SOMENTE o DropEggRequest quando
            -- ele tentar usar FireServer.
            if Blocked
                and self == Remote
                and method == "FireServer" then
                return nil
            end

            return oldNamecall(self, ...)
        end)
    )

print("DropEggRequest: monitorado.")

--//====================================================
--// AUTO RETURN
--//====================================================

ProximityPromptService.PromptTriggered:Connect(
    function(
        Prompt,
        PlayerWhoTriggered
    )

        if not AutoReturn then
            return
        end

        if PlayerWhoTriggered
            and
            PlayerWhoTriggered ~= Player then

            return
        end

        if Returning then
            return
        end

        local CharacterNow =
            Player.Character

        if not CharacterNow then
            return
        end

        local RootNow =
            CharacterNow:
            FindFirstChild(
                "HumanoidRootPart"
            )

        if not RootNow then
            return
        end

        Returning = true

        footer.Text = "prompt → retornando"

        local Distance =
            (
                RootNow.Position
                -
                ReturnPosition
            ).Magnitude

        local Duration =
            math.max(
                Distance / ReturnSpeed,
                0.05
            )

        local Tween =
            TweenService:Create(
                RootNow,
                TweenInfo.new(
                    Duration,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.Out
                ),
                {
                    CFrame =
                        CFrame.new(
                            ReturnPosition
                        )
                }
            )

        Tween:Play()
        Tween.Completed:Wait()

        Returning = false

        footer.Text = "na posição"
    end
)

--//====================================================
--// CONTROLE CONSTANTE
--//====================================================

task.spawn(function()

    while task.wait(0.5) do

        if Humanoid then

            -- Mantém o Speed escolhido
            -- mesmo se outro script tentar
            -- modificar o valor.

            if Humanoid.WalkSpeed ~= Speed then

                Humanoid.WalkSpeed =
                    Speed
            end


            -- Mantém o Jump escolhido.

            if Humanoid.UseJumpPower then

                if Humanoid.JumpPower ~= Jump then

                    Humanoid.JumpPower =
                        Jump
                end

            else

                if Humanoid.JumpHeight ~= Jump then

                    Humanoid.JumpHeight =
                        Jump
                end
            end
        end
    end
end)
