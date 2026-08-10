--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                           ZYRO HUB - V2.0                                 ║
    ║                    Murders vs Sheriff Ultimate Script                     ║
    ║                         Créditos: gomes.wqq                               ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
    WARNING: Use at your own risk!
]]

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ==================== CORE VARIABLES ====================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local ScriptEnabled = true
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

-- ==================== FEATURE FLAGS ====================
local Features = {
    KillAll = false,
    KillSheriff = false,
    Aimbot = false,
    AutoCollectGun = false,
    ESPMurders = false,
    ESPSheriff = false,
    PouInfinito = false,
    AutoFarm = false,
    AntiAFK = false,
    SpeedBoost = 16,
    JumpPower = 50,
    AimbotFOV = 300,
    OriginalPos = nil,
    SherifDead = false,
}

-- ==================== SIMPLE UI LIBRARY ====================
local UILib = {}
UILib.Windows = {}
UILib.Connections = {}

function UILib:CreateWindow(Config)
    Config = Config or {}
    local WindowName = Config.Title or "Window"
    local Author = Config.Author or "Unknown"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZyroHubGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndex = 999
    ScreenGui.Parent = game.CoreGui
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 550)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -275)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Draggable = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    
    -- Corner Radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 150)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ ZYRO HUB ⚡"
    Title.Parent = TopBar
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -30, 0, 20)
    Subtitle.Position = UDim2.new(0, 15, 0, 28)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
    Subtitle.TextScaled = true
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "by " .. Author .. " | Murders vs Sheriff"
    Subtitle.Parent = TopBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextScaled = true
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.Parent = TopBar
    CloseBtn.BorderSizePixel = 0
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 8)
    CloseBtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Size = UDim2.new(0.25, 0, 1, -50)
    TabsContainer.Position = UDim2.new(0, 0, 0, 50)
    TabsContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainFrame
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(0.75, 0, 1, -50)
    ContentContainer.Position = UDim2.new(0.25, 0, 0, 50)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    -- Scroll View for Tabs
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = "TabsScroll"
    TabsScroll.Size = UDim2.new(1, 0, 1, 0)
    TabsScroll.BackgroundTransparency = 1
    TabsScroll.ScrollBarThickness = 6
    TabsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabsScroll.Parent = TabsContainer
    
    local TabsListLayout = Instance.new("UIListLayout")
    TabsListLayout.Padding = UDim.new(0, 5)
    TabsListLayout.FillDirection = Enum.FillDirection.Vertical
    TabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsListLayout.Parent = TabsScroll
    
    -- Scroll View for Content
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Size = UDim2.new(1, -10, 1, -10)
    ContentScroll.Position = UDim2.new(0, 5, 0, 5)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.ScrollBarThickness = 8
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.Parent = ContentContainer
    
    local ContentListLayout = Instance.new("UIListLayout")
    ContentListLayout.Padding = UDim.new(0, 10)
    ContentListLayout.FillDirection = Enum.FillDirection.Vertical
    ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentListLayout.Parent = ContentScroll
    
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TopBar = TopBar,
        TabsContainer = TabsContainer,
        TabsScroll = TabsScroll,
        ContentContainer = ContentContainer,
        ContentScroll = ContentScroll,
        Tabs = {},
    }
    
    function Window:Tab(TabConfig)
        TabConfig = TabConfig or {}
        local TabName = TabConfig.Title or "Tab"
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(0.9, 0, 0, 45)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextScaled = true
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "📌 " .. TabName
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabsScroll
        TabButton.LayoutOrder = #Window.Tabs + 1
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton
        
        -- Tab Content Frame
        local TabContent = Instance.new("Frame")
        TabContent.Name = TabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 0, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Parent = ContentScroll
        TabContent.Visible = false
        TabContent.LayoutOrder = #Window.Tabs + 1
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Padding = UDim.new(0, 8)
        TabContentLayout.FillDirection = Enum.FillDirection.Vertical
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Parent = TabContent
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Frame.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        local TabObj = {
            Button = TabButton,
            Frame = TabContent,
            Elements = {},
        }
        
        table.insert(Window.Tabs, TabObj)
        
        function TabObj:Label(Config)
            Config = Config or {}
            local LabelText = Config.Text or "Label"
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, 0, 0, 35)
            Label.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            Label.TextColor3 = Color3.fromRGB(255, 255, 100)
            Label.TextScaled = true
            Label.Font = Enum.Font.GothamBold
            Label.Text = "► " .. LabelText
            Label.BorderSizePixel = 0
            Label.Parent = TabContent
            
            local LabelCorner = Instance.new("UICorner")
            LabelCorner.CornerRadius = UDim.new(0, 6)
            LabelCorner.Parent = Label
            
            return Label
        end
        
        function TabObj:Button(Config)
            Config = Config or {}
            local ButtonText = Config.Title or "Button"
            local Callback = Config.Callback or function() end
            
            local Button = Instance.new("TextButton")
            Button.Name = ButtonText
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextScaled = true
            Button.Font = Enum.Font.GothamBold
            Button.Text = "▶ " .. ButtonText
            Button.BorderSizePixel = 0
            Button.Parent = TabContent
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 8)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                Button.BackgroundColor3 = Color3.fromRGB(30, 150, 100)
                Callback()
                wait(0.1)
                Button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            end)
            
            return Button
        end
        
        function TabObj:Toggle(Config)
            Config = Config or {}
            local ToggleText = Config.Title or "Toggle"
            local DefaultValue = Config.Value or false
            local Callback = Config.Callback or function() end
            
            local Container = Instance.new("Frame")
            Container.Name = ToggleText
            Container.Size = UDim2.new(1, 0, 0, 45)
            Container.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            Container.BorderSizePixel = 0
            Container.Parent = TabContent
            
            local ContainerCorner = Instance.new("UICorner")
            ContainerCorner.CornerRadius = UDim.new(0, 8)
            ContainerCorner.Parent = Container
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextScaled = true
            Label.Font = Enum.Font.Gotham
            Label.Text = "◆ " .. ToggleText
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "Toggle"
            ToggleButton.Size = UDim2.new(0, 50, 0, 30)
            ToggleButton.Position = UDim2.new(1, -60, 0.5, -15)
            ToggleButton.BackgroundColor3 = DefaultValue and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.TextScaled = true
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.Text = DefaultValue and "ON" or "OFF"
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Parent = Container
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleButton
            
            local ToggleState = DefaultValue
            
            ToggleButton.MouseButton1Click:Connect(function()
                ToggleState = not ToggleState
                ToggleButton.BackgroundColor3 = ToggleState and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
                ToggleButton.Text = ToggleState and "ON" or "OFF"
                Callback(ToggleState)
            end)
            
            return {Button = ToggleButton, GetState = function() return ToggleState end}
        end
        
        function TabObj:Slider(Config)
            Config = Config or {}
            local SliderText = Config.Title or "Slider"
            local MinVal = Config.Min or 0
            local MaxVal = Config.Max or 100
            local DefaultVal = Config.Default or MinVal
            local Callback = Config.Callback or function() end
            
            local Container = Instance.new("Frame")
            Container.Name = SliderText
            Container.Size = UDim2.new(1, 0, 0, 70)
            Container.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            Container.BorderSizePixel = 0
            Container.Parent = TabContent
            
            local ContainerCorner = Instance.new("UICorner")
            ContainerCorner.CornerRadius = UDim.new(0, 8)
            ContainerCorner.Parent = Container
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, 0, 0, 25)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextScaled = true
            Label.Font = Enum.Font.Gotham
            Label.Text = "📊 " .. SliderText .. ": " .. tostring(DefaultVal)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container
            
            local SliderBackground = Instance.new("Frame")
            SliderBackground.Name = "Background"
            SliderBackground.Size = UDim2.new(1, -20, 0, 8)
            SliderBackground.Position = UDim2.new(0, 10, 0, 35)
            SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            SliderBackground.BorderSizePixel = 0
            SliderBackground.Parent = Container
            
            local SliderBackgroundCorner = Instance.new("UICorner")
            SliderBackgroundCorner.CornerRadius = UDim.new(0, 4)
            SliderBackgroundCorner.Parent = SliderBackground
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new((DefaultVal - MinVal) / (MaxVal - MinVal), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBackground
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(0, 4)
            SliderFillCorner.Parent = SliderFill
            
            local CurrentValue = DefaultVal
            
            local function UpdateSlider(input)
                local relativeX = input.Position.X - SliderBackground.AbsolutePosition.X
                local percentage = math.clamp(relativeX / SliderBackground.AbsoluteSize.X, 0, 1)
                CurrentValue = math.floor(MinVal + (MaxVal - MinVal) * percentage)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                Label.Text = "📊 " .. SliderText .. ": " .. tostring(CurrentValue)
                Callback(CurrentValue)
            end
            
            SliderBackground.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    UpdateSlider(input)
                    local Connection
                    Connection = Mouse.Move:Connect(function()
                        if Mouse.X and Mouse.Y then
                            UpdateSlider({Position = Vector3.new(Mouse.X, Mouse.Y, 0)})
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                            Connection:Disconnect()
                        end
                    end)
                end
            end)
            
            return {GetValue = function() return CurrentValue end}
        end
        
        return TabObj
    end
    
    return Window
end

-- ==================== CREATE WINDOW ====================
local Window = UILib:CreateWindow({
    Title = "ZYRO HUB",
    Author = "gomes.wqq"
})

-- ==================== COMBAT TAB ====================
local CombatTab = Window:Tab({Title = "🔫 COMBAT"})

CombatTab:Label({Text = "Murder Functions"})

local KillAllBtn = CombatTab:Button({
    Title = "KILL ALL",
    Callback = function()
        if Features.KillAll then
            Features.KillAll = false
            return
        end
        Features.KillAll = true
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                
                if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
                    -- Puxa para frente
                    local direction = (targetHRP.Position - RootPart.Position).Unit
                    local pushPos = RootPart.CFrame + RootPart.CFrame.LookVector * 10
                    targetHRP.CFrame = pushPos
                    
                    wait(0.05)
                    
                    -- Pega a faca
                    local knife = Character:FindFirstChild("Knife")
                    if not knife then
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj.Name == "Knife" and obj:IsDescendantOf(Character) then
                                knife = obj
                                break
                            end
                        end
                    end
                    
                    if knife then
                        knife.Parent = Character
                    end
                    
                    wait(0.05)
                    
                    -- Click
                    Mo
