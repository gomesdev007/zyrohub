-- Gomes Explorer
-- Explorer/Scanner completo
-- Feito para uso local no cliente

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local old = PlayerGui:FindFirstChild("GomesExplorer")
    if old then old:Destroy() end
end)

pcall(function()
    local old = CoreGui:FindFirstChild("GomesExplorer")
    if old then old:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "GomesExplorer"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(1,0)
Main.Position = UDim2.new(1,-8,0,8)
Main.Size = UDim2.new(0,430,1,-16)
Main.BackgroundColor3 = Color3.fromRGB(18,18,20)
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,10)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65,65,70)
Stroke.Transparency = 0.35
Stroke.Parent = Main

local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Size = UDim2.new(1,-90,0,34)
Header.Position = UDim2.new(0,12,0,7)
Header.BackgroundTransparency = 1
Header.Text = "GOMES EXPLORER"
Header.TextColor3 = Color3.fromRGB(240,240,240)
Header.TextSize = 14
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Main

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0,32,0,28)
Minimize.Position = UDim2.new(1,-40,0,8)
Minimize.BackgroundColor3 = Color3.fromRGB(38,38,42)
Minimize.BorderSizePixel = 0
Minimize.Text = "—"
Minimize.TextColor3 = Color3.fromRGB(230,230,230)
Minimize.TextSize = 16
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Main

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,7)
MinCorner.Parent = Minimize

local Search = Instance.new("TextBox")
Search.Name = "Search"
Search.Size = UDim2.new(1,-24,0,34)
Search.Position = UDim2.new(0,12,0,48)
Search.BackgroundColor3 = Color3.fromRGB(29,29,32)
Search.BorderSizePixel = 0
Search.PlaceholderText = "Pesquisar nome ou classe..."
Search.PlaceholderColor3 = Color3.fromRGB(125,125,130)
Search.Text = ""
Search.TextColor3 = Color3.fromRGB(235,235,235)
Search.TextSize = 12
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0,7)
SearchCorner.Parent = Search

local SourceBar = Instance.new("Frame")
SourceBar.Size = UDim2.new(1,-24,0,32)
SourceBar.Position = UDim2.new(0,12,0,88)
SourceBar.BackgroundTransparency = 1
SourceBar.Parent = Main

local function makeSmallButton(parent,text,x,w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,w,1,0)
    b.Position = UDim2.new(0,x,0,0)
    b.BackgroundColor3 = Color3.fromRGB(32,32,36)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(205,205,210)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = b

    return b
end

local WB = makeSmallButton(SourceBar,"WORKSPACE",0,100)
local RB = makeSmallButton(SourceBar,"REPLICATED",106,100)
local PB = makeSmallButton(SourceBar,"PLAYERS",212,78)

local ModeBar = Instance.new("Frame")
ModeBar.Size = UDim2.new(1,-24,0,32)
ModeBar.Position = UDim2.new(0,12,0,126)
ModeBar.BackgroundTransparency = 1
ModeBar.Parent = Main

local EB = makeSmallButton(ModeBar,"EXACT",0,75)
local AB = makeSmallButton(ModeBar,"APROX.",81,75)
local TB = makeSmallButton(ModeBar,"TUDO",162,75)

local Scan = makeSmallButton(ModeBar,"SCAN",243,75)
Scan.BackgroundColor3 = Color3.fromRGB(65,65,72)

local Clear = makeSmallButton(ModeBar,"LIMPAR",324,70)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,-24,0,24)
Status.Position = UDim2.new(0,12,0,164)
Status.BackgroundTransparency = 1
Status.Text = "Pronto"
Status.TextColor3 = Color3.fromRGB(145,145,150)
Status.TextSize = 10
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Results = Instance.new("ScrollingFrame")
Results.Name = "Results"
Results.Size = UDim2.new(1,-24,1,-198)
Results.Position = UDim2.new(0,12,0,190)
Results.BackgroundColor3 = Color3.fromRGB(14,14,16)
Results.BackgroundTransparency = 0.15
Results.BorderSizePixel = 0
Results.ScrollBarThickness = 5
Results.ScrollBarImageColor3 = Color3.fromRGB(80,80,85)
Results.CanvasSize = UDim2.new(0,0,0,0)
Results.Parent = Main

local ResultsCorner = Instance.new("UICorner")
ResultsCorner.CornerRadius = UDim.new(0,8)
ResultsCorner.Parent = Results

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0,1)
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Results

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Results.CanvasSize = UDim2.new(0,0,0,List.AbsoluteContentSize.Y + 8)
end)

local selectedSource = "Workspace"
local selectedMode = "Exact"
local selectedObject = nil
local expanded = {}
local currentResults = {}
local minimized = false
local scanning = false

local function getSource()
    if selectedSource == "Workspace" then
        return workspace
    elseif selectedSource == "ReplicatedStorage" then
        return ReplicatedStorage
    elseif selectedSource == "Players" then
        return Players
    end
end

local meaningfulClasses = {
    Model=true,
    Folder=true,
    Configuration=true,
    Tool=true,
    RemoteEvent=true,
    RemoteFunction=true,
    BindableEvent=true,
    BindableFunction=true,
    ProximityPrompt=true,
    ClickDetector=true,
    Script=true,
    LocalScript=true,
    ModuleScript=true,
    StringValue=true,
    NumberValue=true,
    IntValue=true,
    BoolValue=true,
    ObjectValue=true,
    Vector3Value=true,
    CFrameValue=true,
    Color3Value=true,
    BrickColorValue=true,
    Humanoid=true,
    Animator=true,
    Animation=true,
    Sound=true,
    ParticleEmitter=true,
    Beam=true,
    Trail=true,
    Attachment=true,
    ScreenGui=true,
    Frame=true,
    TextLabel=true,
    TextButton=true,
    ImageLabel=true,
    ImageButton=true,
}

local function treeRelevant(obj)
    if not obj then return false end
    if obj:IsA("BasePart") then return false end
    return meaningfulClasses[obj.ClassName] == true
        or obj:IsA("Model")
        or obj:IsA("Folder")
        or obj:IsA("Configuration")
        or obj:IsA("Tool")
        or obj:IsA("GuiObject")
end

local function hasRelevantDescendant(obj)
    for _, child in ipairs(obj:GetChildren()) do
        if treeRelevant(child) or hasRelevantDescendant(child) then
            return true
        end
    end
    return false
end

local function iconFor(obj)
    local c = obj.ClassName
    if obj:IsA("BasePart") then return "▣" end
    if obj:IsA("Model") then return "▱" end
    if obj:IsA("Folder") then return "▰" end
    if c == "RemoteEvent" or c == "RemoteFunction" then return "⚡" end
    if c == "ProximityPrompt" then return "⌁" end
    if c == "Script" or c == "LocalScript" or c == "ModuleScript" then return "▤" end
    if obj:IsA("ValueBase") then return "◆" end
    if obj:IsA("GuiObject") then return "▧" end
    return "•"
end

local function objectPath(obj)
    if not obj then return "" end

    local parts = {}
    local current = obj

    while current and current ~= game do
        table.insert(parts,1,current.Name)
        current = current.Parent
    end

    return table.concat(parts,".")
end

local function clearResults()
    for _, child in ipairs(Results:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function setStatus(text)
    Status.Text = tostring(text)
end

local function selectObject(obj)
    selectedObject = obj

    for _, child in ipairs(Results:GetChildren()) do
        if child:IsA("TextButton") then
            local ref = child:GetAttribute("ObjectPath")
            if ref and ref == objectPath(obj) then
                child.BackgroundColor3 = Color3.fromRGB(58,58,66)
            else
                child.BackgroundColor3 = Color3.fromRGB(24,24,27)
            end
        end
    end
end

local openInfo
local closeInfo

local function makeTreeButton(obj,depth)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,-6,0,26)
    button.BackgroundColor3 = Color3.fromRGB(24,24,27)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = #Results:GetChildren()
    button.Parent = Results
    button:SetAttribute("ObjectPath",objectPath(obj))

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-8,1,0)
    label.Position = UDim2.new(0,4 + depth*16,0,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(215,215,220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local prefix = ""
    if #obj:GetChildren() > 0 then
        prefix = expanded[obj] and "▼ " or "▶ "
    else
        prefix = "  "
    end

    label.Text = prefix .. iconFor(obj) .. "  " .. obj.Name .. "  [" .. obj.ClassName .. "]"
    label.Parent = button

    button.MouseEnter:Connect(function()
        if selectedObject ~= obj then
            button.BackgroundColor3 = Color3.fromRGB(34,34,38)
        end
    end)

    button.MouseLeave:Connect(function()
        if selectedObject ~= obj then
            button.BackgroundColor3 = Color3.fromRGB(24,24,27)
        end
    end)

    local lastClick = 0

    button.MouseButton1Click:Connect(function()
        local now = os.clock()
        local double = now - lastClick <= 0.3
        lastClick = now

        selectObject(obj)

        if double then
            openInfo(obj)
            return
        end

        if selectedMode == "All" and #obj:GetChildren() > 0 then
            expanded[obj] = not expanded[obj]
            task.defer(function()
                if Search.Text == "" then
                    renderExplorer()
                end
            end)
        end
    end)

    return button
end

function renderExplorer()
    clearResults()

    local root = getSource()
    if not root then
        setStatus("Fonte inválida")
        return
    end

    local children = root:GetChildren()

    table.sort(children,function(a,b)
        return a.Name:lower() < b.Name:lower()
    end)

    local count = 0

    local function addNode(obj,depth)
        if count >= 1500 then return end
        if not treeRelevant(obj) and not hasRelevantDescendant(obj) then
            return
        end

        count += 1
        makeTreeButton(obj,depth)

        if expanded[obj] then
            local sub = obj:GetChildren()

            table.sort(sub,function(a,b)
                return a.Name:lower() < b.Name:lower()
            end)

            for _, child in ipairs(sub) do
                addNode(child,depth+1)
            end
        end
    end

    for _, obj in ipairs(children) do
        addNode(obj,0)
    end

    setStatus(getSource().Name .. " • " .. tostring(count) .. " exibido(s)")
end

local function searchObjects(text)
    local root = getSource()
    if not root then return {} end

    text = tostring(text or ""):lower()
    if text == "" then return {} end

    local result = {}

    for _, obj in ipairs(root:GetDescendants()) do
        local name = obj.Name:lower()
        local class = obj.ClassName:lower()
        local match = false

        if selectedMode == "Exact" then
            match = name == text
        elseif selectedMode == "Approximate" then
            match = name:find(text,1,true) ~= nil
        else
            match = name:find(text,1,true) ~= nil
                or class:find(text,1,true) ~= nil
        end

        if match then
            table.insert(result,obj)
        end
    end

    table.sort(result,function(a,b)
        return a.Name:lower() < b.Name:lower()
    end)

    return result
end

local function renderSearch(results)
    clearResults()
    currentResults = results or {}

    for _, obj in ipairs(currentResults) do
        if obj and obj.Parent then
            makeTreeButton(obj,0)
        end
    end

    setStatus(tostring(#currentResults) .. " resultado(s)")
end

local function runScan()
    if scanning then return end
    scanning = true

    clearResults()
    selectedObject = nil

    local text = Search.Text

    task.wait()

    if text == "" then
        renderExplorer()
    else
        renderSearch(searchObjects(text))
    end

    scanning = false
end

local function updateSourceButtons()
    local buttons = {
        Workspace=WB,
        ReplicatedStorage=RB,
        Players=PB
    }

    for name,button in pairs(buttons) do
        button.BackgroundColor3 =
            name == selectedSource
            and Color3.fromRGB(65,65,72)
            or Color3.fromRGB(32,32,36)
    end
end

local function updateModeButtons()
    local map = {
        Exact=EB,
        Approximate=AB,
        All=TB
    }

    for name,button in pairs(map) do
        button.BackgroundColor3 =
            name == selectedMode
            and Color3.fromRGB(65,65,72)
            or Color3.fromRGB(32,32,36)
    end
end

local function sourceName()
    return selectedSource
end

local function setSource(name)
    selectedSource = name
    expanded = {}
    currentResults = {}
    selectedObject = nil
    Search.Text = ""
    updateSourceButtons()
    Header.Text = "GOMES EXPLORER  •  " .. sourceName()
    renderExplorer()
end

local function setMode(mode)
    selectedMode = mode
    expanded = {}
    updateModeButtons()

    if Search.Text == "" then
        renderExplorer()
    else
        renderSearch(searchObjects(Search.Text))
    end
end

WB.MouseButton1Click:Connect(function() setSource("Workspace") end)
RB.MouseButton1Click:Connect(function() setSource("ReplicatedStorage") end)
PB.MouseButton1Click:Connect(function() setSource("Players") end)

EB.MouseButton1Click:Connect(function() setMode("Exact") end)
AB.MouseButton1Click:Connect(function() setMode("Approximate") end)
TB.MouseButton1Click:Connect(function() setMode("All") end)

Scan.MouseButton1Click:Connect(runScan)

Clear.MouseButton1Click:Connect(function()
    Search.Text = ""
    currentResults = {}
    selectedObject = nil
    expanded = {}
    renderExplorer()
end)

Search.FocusLost:Connect(function(enter)
    if enter then
        runScan()
    end
end)

local InfoGui
local InfoFrame
local InfoList
local Viewport
local ViewportCamera
local ViewportWorld
local ViewportModel
local viewerYaw = 0
local viewerPitch = 0
local viewerDistance = 8
local viewerDragging = false
local viewerLast = nil
local viewerConnections = {}

local function disconnectViewer()
    for _, c in ipairs(viewerConnections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(viewerConnections)
end

local function destroyViewer()
    disconnectViewer()

    if ViewportModel then
        pcall(function() ViewportModel:Destroy() end)
        ViewportModel = nil
    end

    if ViewportWorld then
        pcall(function() ViewportWorld:Destroy() end)
        ViewportWorld = nil
    end

    if Viewport then
        pcall(function() Viewport:Destroy() end)
        Viewport = nil
    end
end

local function addInfo(text)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1,-8,0,30)
    row.BackgroundColor3 = Color3.fromRGB(28,28,32)
    row.BorderSizePixel = 0
    row.Text = tostring(text)
    row.TextColor3 = Color3.fromRGB(215,215,220)
    row.TextSize = 11
    row.Font = Enum.Font.Gotham
    row.TextWrapped = true
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = InfoList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,5)
    corner.Parent = row
end

local function safeProperty(obj,prop)
    local ok,value = pcall(function()
        return obj[prop]
    end)

    if ok then
        return value
    end
end

local function createViewport(obj,parent)
    destroyViewer()

    local vp = Instance.new("ViewportFrame")
    vp.Name = "Viewer"
    vp.Size = UDim2.new(1,-16,1,-48)
    vp.Position = UDim2.new(0,8,0,40)
    vp.BackgroundColor3 = Color3.fromRGB(10,10,12)
    vp.BorderSizePixel = 0
    vp.Ambient = Color3.fromRGB(190,190,190)
    vp.LightColor = Color3.fromRGB(255,255,255)
    vp.LightDirection = Vector3.new(-1,-1,-1)
    vp.Parent = parent
    Viewport = vp

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,7)
    corner.Parent = vp

    local world = Instance.new("WorldModel")
    world.Parent = vp
    ViewportWorld = world

    local camera = Instance.new("Camera")
    camera.Parent = vp
    vp.CurrentCamera = camera
    ViewportCamera = camera

    local clone

    pcall(function()
        clone = obj:Clone()
    end)

    if not clone then
        local unavailable = Instance.new("TextLabel")
        unavailable.Size = UDim2.new(1,-20,0,50)
        unavailable.Position = UDim2.new(0,10,0.5,-25)
        unavailable.BackgroundTransparency = 1
        unavailable.Text = "Visualização 3D indisponível"
        unavailable.TextColor3 = Color3.fromRGB(150,150,155)
        unavailable.TextSize = 12
        unavailable.Font = Enum.Font.Gotham
        unavailable.Parent = vp
        return
    end

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Script")
            or d:IsA("LocalScript")
            or d:IsA("ModuleScript")
            or d:IsA("ProximityPrompt")
            or d:IsA("ClickDetector") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
        end
    end

    clone.Parent = world
    ViewportModel = clone

    local cf,size

    pcall(function()
        if clone:IsA("Model") then
            cf,size = clone:GetBoundingBox()
        elseif clone:IsA("BasePart") then
            cf = clone.CFrame
            size = clone.Size
        end
    end)

    if not cf or not size then
        local unavailable = Instance.new("TextLabel")
        unavailable.Size = UDim2.new(1,-20,0,50)
        unavailable.Position = UDim2.new(0,10,0.5,-25)
        unavailable.BackgroundTransparency = 1
        unavailable.Text = "Objeto sem geometria 3D"
        unavailable.TextColor3 = Color3.fromRGB(150,150,155)
        unavailable.TextSize = 12
        unavailable.Font = Enum.Font.Gotham
        unavailable.Parent = vp
        return
    end

    local center = cf.Position
    local maxSize = math.max(size.X,size.Y,size.Z)
    viewerDistance = math.max(4,maxSize*2.5)
    viewerYaw = 0
    viewerPitch = 0

    pcall(function()
        if clone:IsA("Model") then
            clone:PivotTo(CFrame.new(-center) * clone:GetPivot())
        else
            clone.CFrame = CFrame.new(-center) * clone.CFrame
        end
    end)

    local function updateCamera()
        local rotation =
            CFrame.Angles(0,viewerYaw,0)
            * CFrame.Angles(viewerPitch,0,0)

        local direction = rotation.LookVector
        camera.CFrame = CFrame.lookAt(
            Vector3.zero - direction * viewerDistance,
            Vector3.zero
        )
    end

    updateCamera()

    table.insert(viewerConnections,
        vp.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                viewerDragging = true
                viewerLast = input.Position
            end
        end)
    )

    table.insert(viewerConnections,
        vp.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then

                if viewerDragging and viewerLast then
                    local delta = input.Position - viewerLast
                    viewerLast = input.Position

                    viewerYaw -= delta.X * 0.012
                    viewerPitch = math.clamp(
                        viewerPitch - delta.Y * 0.012,
                        -1.45,
                        1.45
                    )

                    updateCamera()
                end
            end
        end)
    )

    table.insert(viewerConnections,
        vp.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                viewerDragging = false
                viewerLast = nil
            end
        end)
    )

    table.insert(viewerConnections,
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                viewerDistance = math.clamp(
                    viewerDistance - input.Position.Z * 1.2,
                    math.max(2,maxSize * 0.7),
                    math.max(20,maxSize * 8)
                )

                updateCamera()
            end
        end)
    )
end

local function buildInfo(obj)
    if not obj then return end

    if InfoGui then
        InfoGui:Destroy()
        InfoGui = nil
    end

    local camera = workspace.CurrentCamera
    local viewportSize = camera and camera.ViewportSize or Vector2.new(900,600)

    local width = math.min(700,math.max(320,viewportSize.X-24))
    local height = math.min(560,math.max(420,viewportSize.Y-24))

    InfoGui = Instance.new("ScreenGui")
    InfoGui.Name = "GomesExplorerInfo"
    InfoGui.ResetOnSpawn = false
    InfoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    InfoGui.Parent = Gui

    InfoFrame = Instance.new("Frame")
    InfoFrame.AnchorPoint = Vector2.new(0.5,0.5)
    InfoFrame.Position = UDim2.new(0.5,0,0.5,0)
    InfoFrame.Size = UDim2.new(0,width,0,height)
    InfoFrame.BackgroundColor3 = Color3.fromRGB(18,18,20)
    InfoFrame.BorderSizePixel = 0
    InfoFrame.Parent = InfoGui

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = InfoFrame

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(65,65,70)
    s.Transparency = 0.3
    s.Parent = InfoFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-90,0,34)
    title.Position = UDim2.new(0,12,0,7)
    title.BackgroundTransparency = 1
    title.Text = obj.Name
    title.TextColor3 = Color3.fromRGB(240,240,240)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = InfoFrame

    local class = Instance.new("TextLabel")
    class.Size = UDim2.new(1,-90,0,20)
    class.Position = UDim2.new(0,12,0,34)
    class.BackgroundTransparency = 1
    class.Text = obj.ClassName
    class.TextColor3 = Color3.fromRGB(135,135,140)
    class.TextSize = 10
    class.Font = Enum.Font.Gotham
    class.TextXAlignment = Enum.TextXAlignment.Left
    class.Parent = InfoFrame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,32,0,28)
    close.Position = UDim2.new(1,-40,0,8)
    close.BackgroundColor3 = Color3.fromRGB(45,45,49)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(235,235,235)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = InfoFrame

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0,7)
    cc.Parent = close

    close.MouseButton1Click:Connect(function()
        closeInfo()
    end)

    local copy = Instance.new("TextButton")
    copy.Size = UDim2.new(0,75,0,28)
    copy.Position = UDim2.new(1,-122,0,8)
    copy.BackgroundColor3 = Color3.fromRGB(35,35,39)
    copy.BorderSizePixel = 0
    copy.Text = "COPY"
    copy.TextColor3 = Color3.fromRGB(225,225,230)
    copy.TextSize = 10
    copy.Font = Enum.Font.GothamBold
    copy.Parent = InfoFrame

    local cpc = Instance.new("UICorner")
    cpc.CornerRadius = UDim.new(0,7)
    cpc.Parent = copy

    copy.MouseButton1Click:Connect(function()
        local text = objectPath(obj)
        pcall(function()
            if setclipboard then
                setclipboard(text)
            elseif toclipboard then
                toclipboard(text)
            end
        end)
        setStatus("Caminho copiado")
    end)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1,-24,0,1)
    divider.Position = UDim2.new(0,12,0,66)
    divider.BackgroundColor3 = Color3.fromRGB(55,55,60)
    divider.BorderSizePixel = 0
    divider.Parent = InfoFrame

    local leftWidth = math.floor(width * 0.42)

    local left = Instance.new("ScrollingFrame")
    left.Name = "InfoList"
    left.Size = UDim2.new(0,leftWidth,1,-82)
    left.Position = UDim2.new(0,8,0,74)
    left.BackgroundTransparency = 1
    left.BorderSizePixel = 0
    left.ScrollBarThickness = 4
    left.Parent = InfoFrame
    InfoList = left

    local infoLayout = Instance.new("UIListLayout")
    infoLayout.Padding = UDim.new(0,4)
    infoLayout.Parent = left

    infoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        left.CanvasSize = UDim2.new(0,0,0,infoLayout.AbsoluteContentSize.Y + 8)
    end)

    addInfo("Name: " .. obj.Name)
    addInfo("Class: " .. obj.ClassName)
    addInfo("Path: " .. objectPath(obj))
    addInfo("Parent: " .. (obj.Parent and obj.Parent.Name or "nil"))
    addInfo("Children: " .. tostring(#obj:GetChildren()))
    addInfo("Descendants: " .. tostring(#obj:GetDescendants()))

    local archivable = safeProperty(obj,"Archivable")
    if archivable ~= nil then
        addInfo("Archivable: " .. tostring(archivable))
    end

    if obj:IsA("BasePart") then
        addInfo("Position: " .. tostring(obj.Position))
        addInfo("Size: " .. tostring(obj.Size))
        addInfo("Orientation: " .. tostring(obj.Orientation))
        addInfo("Anchored: " .. tostring(obj.Anchored))
        addInfo("CanCollide: " .. tostring(obj.CanCollide))
        addInfo("Transparency: " .. tostring(obj.Transparency))
        addInfo("Material: " .. tostring(obj.Material))
        addInfo("Color: " .. tostring(obj.Color))
    end

    if obj:IsA("Model") then
        addInfo("PrimaryPart: " .. tostring(obj.PrimaryPart))
        local pivot = safeProperty(obj,"WorldPivot")
        if pivot then
            addInfo("WorldPivot: " .. tostring(pivot))
        end
    end

    if obj:IsA("ProximityPrompt") then
        addInfo("ActionText: " .. tostring(obj.ActionText))
        addInfo("ObjectText: " .. tostring(obj.ObjectText))
        addInfo("HoldDuration: " .. tostring(obj.HoldDuration))
        addInfo("MaxDistance: " .. tostring(obj.MaxActivationDistance))
        addInfo("Enabled: " .. tostring(obj.Enabled))
        addInfo("KeyboardKey: " .. tostring(obj.KeyboardKeyCode))
    end

    if obj:IsA("Sound") then
        addInfo("SoundId: " .. tostring(obj.SoundId))
        addInfo("Volume: " .. tostring(obj.Volume))
        addInfo("Playing: " .. tostring(obj.Playing))
    end

    local attributes = obj:GetAttributes()
    local attrCount = 0

    for name,value in pairs(attributes) do
        attrCount += 1
        addInfo("Attribute • " .. name .. " = " .. tostring(value))
    end

    if attrCount == 0 then
        addInfo("Attributes: nenhum")
    end

    local rightX = leftWidth + 16
    local rightW = width - rightX - 8

    local viewerPanel = Instance.new("Frame")
    viewerPanel.Size = UDim2.new(0,rightW,1,-82)
    viewerPanel.Position = UDim2.new(0,rightX,0,74)
    viewerPanel.BackgroundTransparency = 1
    viewerPanel.Parent = InfoFrame

    local viewerTitle = Instance.new("TextLabel")
    viewerTitle.Size = UDim2.new(1,0,0,32)
    viewerTitle.BackgroundTransparency = 1
    viewerTitle.Text = "3D VIEWER"
    viewerTitle.TextColor3 = Color3.fromRGB(190,190,195)
    viewerTitle.TextSize = 10
    viewerTitle.Font = Enum.Font.GothamBold
    viewerTitle.TextXAlignment = Enum.TextXAlignment.Left
    viewerTitle.Parent = viewerPanel

    createViewport(obj,viewerPanel)
end

function openInfo(obj)
    if not obj then return end
    selectedObject = obj
    buildInfo(obj)
end

function closeInfo()
    disconnectViewer()

    if InfoGui then
        InfoGui:Destroy()
        InfoGui = nil
    end

    InfoFrame = nil
    InfoList = nil
    Viewport = nil
    ViewportCamera = nil
    ViewportWorld = nil
    ViewportModel = nil
end

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Escape then
        if InfoGui then
            closeInfo()
        end
    end

    if input.KeyCode == Enum.KeyCode.F5 then
        runScan()
    end

    if input.KeyCode == Enum.KeyCode.F6 then
        Search.Text = ""
        renderExplorer()
    end
end)

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        Main.Size = UDim2.new(0,180,0,48)
        Main.Position = UDim2.new(1,-8,0,8)

        for _, child in ipairs(Main:GetChildren()) do
            if child ~= Header
                and child ~= Minimize
                and child ~= Stroke
                and child ~= MainCorner then
                if child:IsA("GuiObject") then
                    child.Visible = false
                end
            end
        end

        Header.Size = UDim2.new(1,-48,0,34)
        Minimize.Text = "+"
    else
        Main.Size = UDim2.new(0,430,1,-16)
        Main.Position = UDim2.new(1,-8,0,8)

        for _, child in ipairs(Main:GetChildren()) do
            if child ~= Header
                and child ~= Minimize
                and child ~= Stroke
                and child ~= MainCorner then
                if child:IsA("GuiObject") then
                    child.Visible = true
                end
            end
        end

        Header.Size = UDim2.new(1,-90,0,34)
        Minimize.Text = "—"
        renderExplorer()
    end
end)

workspace.ChildAdded:Connect(function()
    if Search.Text ~= "" then
        task.defer(runScan)
    end
end)

workspace.ChildRemoved:Connect(function()
    if Search.Text ~= "" then
        task.defer(runScan)
    end
end)

ReplicatedStorage.ChildAdded:Connect(function()
    if Search.Text ~= "" and selectedSource == "ReplicatedStorage" then
        task.defer(runScan)
    end
end)

ReplicatedStorage.ChildRemoved:Connect(function()
    if Search.Text ~= "" and selectedSource == "ReplicatedStorage" then
        task.defer(runScan)
    end
end)

Players.PlayerAdded:Connect(function()
    if selectedSource == "Players" then
        task.defer(renderExplorer)
    end
end)

Players.PlayerRemoving:Connect(function()
    if selectedSource == "Players" then
        task.defer(renderExplorer)
    end
end)

updateSourceButtons()
updateModeButtons()
renderExplorer()
setStatus("Gomes Explorer pronto")
