--[[
    MINI HUB - RETURN AUTO STEAL + PET ESP
    Movimento baseado no metodo completo do Open source completo.txt.

    Botoes:
    1. RETURN AUTO STEAL
    2. PET ESP

    O retorno usa:
    - prepareStealHumanoid
    - buildStealPath
    - humanoidStealMoveTo
    - stealAlong
    - groundedY
    - placeRoot
    - bypassMoveTo
    - getBasePosition

    O ESP usa os registros de AreaEggSlotsClient/EggState do jogo.
]]

local ENV = (getgenv and getgenv()) or _G

if ENV.__MINI_RETURN_ESP_SHUTDOWN then
    pcall(ENV.__MINI_RETURN_ESP_SHUTDOWN)
end

if ENV.__MINI_RETURN_ESP_RUNNING then
    return
end

ENV.__MINI_RETURN_ESP_RUNNING = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local alive = true
local connections = {}
local espEntries = {}
local espMarks = {}
local espEnabled = false
local moving = false
local moveSpeed = 700
local bypassSpeed = 800

local function track(c)
    table.insert(connections, c)
    return c
end

local function disconnectAll()
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(connections)
end

local function shutdown()
    alive = false
    espEnabled = false
    moving = false

    for key, entry in pairs(espEntries) do
        if entry.highlight then pcall(function() entry.highlight:Destroy() end) end
        if entry.billboard then pcall(function() entry.billboard:Destroy() end) end
        if entry.anchor then pcall(function() entry.anchor:Destroy() end) end
        espEntries[key] = nil
    end

    disconnectAll()

    if ENV.__MINI_RETURN_ESP_GUI then
        pcall(function() ENV.__MINI_RETURN_ESP_GUI:Destroy() end)
        ENV.__MINI_RETURN_ESP_GUI = nil
    end

    ENV.__MINI_RETURN_ESP_RUNNING = nil
    ENV.__MINI_RETURN_ESP_SHUTDOWN = nil
end

ENV.__MINI_RETURN_ESP_SHUTDOWN = shutdown

-- ============================================================
-- MODULE DISCOVERY
-- ============================================================

local function requirePath(root, timeout, ...)
    local obj = root
    for _, name in ipairs({...}) do
        if not obj then
            return nil
        end

        local child = obj:FindFirstChild(name)
        if not child then
            child = obj:WaitForChild(name, timeout or 4)
        end

        obj = child
    end

    if not obj then
        return nil
    end

    local ok, result = pcall(require, obj)
    return ok and result or nil
end

local function findModule(name)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name == name then
            local ok, result = pcall(require, obj)
            if ok then
                return result
            end
        end
    end
    return nil
end

local Save =
    requirePath(ReplicatedStorage, 6, "Shared", "Save")
    or findModule("Save")

local EggState =
    requirePath(ReplicatedStorage, 6, "Client", "EggState")
    or findModule("EggState")

local PlotState =
    requirePath(ReplicatedStorage, 6, "Client", "PlotState")
    or findModule("PlotState")

local Areas =
    requirePath(ReplicatedStorage, 4, "Data", "Areas")
    or findModule("Areas")

local Assets =
    requirePath(ReplicatedStorage, 4, "Data", "Assets")
    or findModule("Assets")

local AreaEggSlotIdentity =
    requirePath(
        ReplicatedStorage,
        4,
        "Shared",
        "Util",
        "AreaEggSlotIdentity"
    )
    or findModule("AreaEggSlotIdentity")

local function pickFn(tbl, ...)
    if typeof(tbl) ~= "table" then
        return nil
    end

    for i = 1, select("#", ...) do
        local name = select(i, ...)
        if typeof(tbl[name]) == "function" then
            return tbl[name]
        end
    end

    return nil
end

local GetAreaEggSnapshot =
    pickFn(EggState, "ReadFieldEggs", "GetAreaEggSnapshot")

local RequestAreaEggSnapshot =
    pickFn(EggState, "SyncFieldEggs", "RequestAreaEggSnapshot")

local GetRespawnPointCFrame =
    pickFn(PlotState, "FindRespawnCFrame", "GetRespawnPointCFrame")

local GetPlotData =
    pickFn(PlotState, "ResolvePlot", "GetPlotData")

local GetRuntimeSnapshot =
    pickFn(findModule("RuntimeSnapshot"), "ReadSnapshot", "GetRuntimeSnapshot")
    or findModule("RuntimeSnapshot")

-- ============================================================
-- GAME HELPERS
-- ============================================================

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart") or nil
end

local function getAreaFolder()
    local objects = Workspace:FindFirstChild("__OBJECTS")
    return objects and objects:FindFirstChild("Areas")
end

local function getLaneY()
    local areas = getAreaFolder()

    if areas then
        local gameplayZ = areas:FindFirstChild("GameplayZ")
        if gameplayZ and gameplayZ:IsA("BasePart") then
            return gameplayZ.Position.Y + 3
        end
    end

    local root = getRoot()
    return root and root.Position.Y or 70
end

local function getLaneZ()
    local areas = getAreaFolder()

    if areas then
        local gameplayZ = areas:FindFirstChild("GameplayZ")
        if gameplayZ and gameplayZ:IsA("BasePart") then
            return gameplayZ.Position.Z
        end

        local separationLine = areas:FindFirstChild("SeparationLine")
        if separationLine and separationLine:IsA("BasePart") then
            return separationLine.Position.Z
        end
    end

    local root = getRoot()
    return root and root.Position.Z or 0
end

local function getAreaEggs()
    if not GetAreaEggSnapshot then
        return {}
    end

    local ok, snapshot = pcall(GetAreaEggSnapshot)

    if not ok or typeof(snapshot) ~= "table" or typeof(snapshot.Records) ~= "table" then
        if RequestAreaEggSnapshot then
            pcall(RequestAreaEggSnapshot)
        end

        ok, snapshot = pcall(GetAreaEggSnapshot)
    end

    if not ok or typeof(snapshot) ~= "table" or typeof(snapshot.Records) ~= "table" then
        return {}
    end

    local result = {}

    for _, record in pairs(snapshot.Records) do
        if typeof(record) == "table" and typeof(record.Uid) == "string" then
            table.insert(result, record)
        end
    end

    return result
end

local function resolveRarity(assetCategory)
    if typeof(assetCategory) ~= "string" then
        return nil
    end

    if not Assets or typeof(Assets.Directory) ~= "table" then
        return nil
    end

    local asset = Assets.Directory[assetCategory]
    local rarity = asset and asset.Rarity

    if not rarity then
        return nil
    end

    return rarity._id or rarity.DisplayName
end

local function assetName(assetCategory)
    if Assets and typeof(Assets.Directory) == "table" then
        local asset = Assets.Directory[assetCategory]

        if asset and asset.DisplayName then
            return asset.DisplayName
        end
    end

    return tostring(assetCategory or "Unknown")
end

-- ============================================================
-- MOVEMENT METHOD
-- Based on the complete Auto Steal movement chain.
-- ============================================================

local function stripCheatMovers(root)
    if not root then
        return
    end

    for _, obj in ipairs(root:GetChildren()) do
        local className = obj.ClassName

        if className == "BodyVelocity"
            or className == "BodyPosition"
            or className == "BodyGyro"
            or className == "BodyAngularVelocity"
            or className == "LinearVelocity"
            or className == "VectorForce"
            or className == "AlignOrientation" then

            pcall(function()
                obj:Destroy()
            end)
        end
    end
end

local function stopSoftMove(root)
    if not root then
        return
    end

    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("AlignPosition") then
            pcall(function()
                obj.Enabled = false
                obj:Destroy()
            end)
        end
    end
end

local lastDirectMove = 0

local function directRootMove(root, cf)
    if not root or not cf then
        return
    end

    local now = os.clock()

    if now - lastDirectMove < 1 / 45 then
        return
    end

    lastDirectMove = now

    pcall(function()
        root.CFrame = cf
    end)
end

local function placeRoot(root, cf)
    if not root or not cf then
        return
    end

    stopSoftMove(root)
    stripCheatMovers(root)

    local character = getCharacter()

    if character and character.Parent then
        pcall(function()
            character:PivotTo(cf)
        end)
    else
        directRootMove(root, cf)
    end
end

local function groundedY(x, z, previousY)
    local laneY = getLaneY()
    local root = getRoot()
    local humanoid = getHumanoid()

    local hipHeight = 2

    if humanoid and humanoid.HipHeight > 0 then
        hipHeight = humanoid.HipHeight
    end

    local rootHalfHeight = root and root.Size.Y * 0.5 or 1
    local offset = hipHeight + rootHalfHeight
    local minimumGround = laneY + 1.5

    local ignore = {}

    if getCharacter() then
        table.insert(ignore, getCharacter())
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local rayStartY = laneY + 40
    local groundY

    for _ = 1, 20 do
        params.FilterDescendantsInstances = ignore

        local result = Workspace:Raycast(
            Vector3.new(x, rayStartY, z),
            Vector3.new(0, -160, 0),
            params
        )

        if not result then
            break
        end

        local hitY = result.Position.Y
        local name = result.Instance.Name
        local lowerName = string.lower(name)

        local isGround =
            name == "Ground"
            or string.find(lowerName, "ground", 1, true) ~= nil

        if isGround or hitY <= minimumGround then
            groundY = hitY
            break
        end

        table.insert(ignore, result.Instance)
    end

    if groundY then
        return math.clamp(
            groundY + offset,
            laneY - 2,
            laneY + 5
        )
    end

    if typeof(previousY) == "number" then
        return math.clamp(
            previousY,
            laneY - 2,
            laneY + 5
        )
    end

    return laneY + 3
end

local function swapStealHumanoid()
    local character = getCharacter()

    if not character then
        return false
    end

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("LocalScript")
            and string.find(obj.Name, "PushBack", 1, true) then

            pcall(function()
                obj.Disabled = true
                obj:Destroy()
            end)
        end
    end

    return true
end

local function prepareStealHumanoid()
    local character = getCharacter()

    if not character then
        return nil
    end

    local oldHumanoid = character:FindFirstChildOfClass("Humanoid")

    if not oldHumanoid then
        return nil
    end

    local camera = Workspace.CurrentCamera
    local cameraCFrame = camera and camera.CFrame or nil

    local humanoid = nil

    local ok, clone = pcall(function()
        oldHumanoid.Archivable = true
        return oldHumanoid:Clone()
    end)

    if ok and clone then
        humanoid = clone
        humanoid.Parent = character

        RunService.Heartbeat:Wait()

        pcall(function()
            if oldHumanoid and oldHumanoid.Parent then
                oldHumanoid:Destroy()
            end
        end)
    else
        humanoid = oldHumanoid
    end

    task.wait(0.1)

    humanoid =
        character:FindFirstChildOfClass("Humanoid")
        or humanoid

    if humanoid then
        humanoid.Sit = false
        humanoid.PlatformStand = false
        humanoid.WalkSpeed = moveSpeed
        humanoid.AutoRotate = true
    end

    if camera and humanoid then
        pcall(function()
            camera.CameraSubject = humanoid

            if cameraCFrame then
                camera.CFrame = cameraCFrame
            end
        end)
    end

    return humanoid
end

local function buildStealPath(fromPosition, destination)
    local laneZ = getLaneZ()
    local laneY = getLaneY()

    local path = {}

    if math.abs(fromPosition.Z - laneZ) > 3 then
        table.insert(
            path,
            Vector3.new(fromPosition.X, laneY, laneZ)
        )
    end

    if math.abs(fromPosition.X - destination.X) > 2 then
        table.insert(
            path,
            Vector3.new(destination.X, laneY, laneZ)
        )
    end

    table.insert(
        path,
        Vector3.new(destination.X, laneY, destination.Z)
    )

    return path
end

local function humanoidStealMoveTo(destination, shouldContinue)
    if typeof(destination) ~= "Vector3" or not alive then
        return false
    end

    local character = getCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = getRoot()

    if not humanoid or not root then
        return false
    end

    humanoid.Sit = false
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    humanoid.WalkSpeed = moveSpeed

    local y = groundedY(
        destination.X,
        destination.Z,
        root.Position.Y
    )

    local target = Vector3.new(
        destination.X,
        y,
        destination.Z
    )

    local arriveDistance = 1.35

    if (root.Position - target).Magnitude <= arriveDistance then
        return true
    end

    local path = buildStealPath(root.Position, target)

    if #path == 0 then
        path = { target }
    end

    local counter = 0

    for _, waypoint in ipairs(path) do
        if not alive or (shouldContinue and not shouldContinue()) then
            return false
        end

        root = getRoot()

        if not root then
            return false
        end

        local waypointY = groundedY(
            waypoint.X,
            waypoint.Z,
            root.Position.Y
        )

        local finalWaypoint = Vector3.new(
            waypoint.X,
            waypointY,
            waypoint.Z
        )

        local timeout = os.clock() + 14

        while alive and os.clock() < timeout do
            if shouldContinue and not shouldContinue() then
                return false
            end

            root = getRoot()

            if not root then
                return false
            end

            local delta = finalWaypoint - root.Position
            local distance = delta.Magnitude

            if distance <= arriveDistance then
                break
            end

            local direction = delta.Unit
            local dt = math.clamp(
                RunService.Heartbeat:Wait(),
                0,
                1 / 30
            )

            local step = math.min(
                moveSpeed * dt,
                distance
            )

            local newPosition =
                root.Position
                + direction * step
                + Vector3.new(
                    (math.random() - 0.5) * 0.1,
                    0,
                    (math.random() - 0.5) * 0.1
                )

            local flatDirection =
                Vector3.new(
                    direction.X,
                    0,
                    direction.Z
                )

            local cf

            if flatDirection.Magnitude > 0.001 then
                cf = CFrame.lookAt(
                    newPosition,
                    newPosition + flatDirection.Unit
                )
            else
                cf = CFrame.new(newPosition)
            end

            directRootMove(root, cf)

            counter = counter + 1

            if counter % 4 == 0 then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end

    root = getRoot()

    if not root then
        return false
    end

    placeRoot(root, CFrame.new(target))

    return
        (root.Position - target).Magnitude
        <= math.max(3, arriveDistance + 1)
end

local function stealMoveTo(x, z, shouldContinue)
    local root = getRoot()

    if not root then
        return false
    end

    local y = groundedY(
        x,
        z,
        root.Position.Y
    )

    return humanoidStealMoveTo(
        Vector3.new(x, y, z),
        shouldContinue
    )
end

local function stealAlong(path, shouldContinue)
    for _, waypoint in ipairs(path) do
        if shouldContinue and not shouldContinue() then
            return false
        end

        if not stealMoveTo(
            waypoint.X,
            waypoint.Z,
            shouldContinue
        ) then
            return false
        end
    end

    return true
end

local function getBasePosition()
    if GetRespawnPointCFrame then
        local ok, cf = pcall(GetRespawnPointCFrame)

        if ok and cf then
            return cf.Position
        end
    end

    if not GetPlotData then
        return nil
    end

    local ok, plotData = pcall(GetPlotData)

    if not ok or not plotData then
        return nil
    end

    if plotData.CenterPoint then
        return plotData.CenterPoint.Position
    end

    if plotData.PetArea then
        return plotData.PetArea.Position
    end

    return nil
end

local function bypassMoveTo(destination, shouldContinue, speed)
    if typeof(destination) ~= "Vector3" or not alive then
        return false
    end

    speed = math.clamp(
        tonumber(speed) or bypassSpeed,
        16,
        2000
    )

    local root = getRoot()

    if not root then
        return false
    end

    stripCheatMovers(root)
    stopSoftMove(root)

    local humanoid = getHumanoid()

    if humanoid then
        humanoid.Sit = false
        humanoid.PlatformStand = true
    end

    local y = groundedY(
        destination.X,
        destination.Z,
        root.Position.Y
    )

    local target = Vector3.new(
        destination.X,
        y,
        destination.Z
    )

    local arriveDistance = 4

    if (root.Position - target).Magnitude <= arriveDistance then
        if humanoid then
            humanoid.PlatformStand = false
        end

        return true
    end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "MiniReturnBypassMove"
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.P = 1250
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "MiniReturnBypassGyro"
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.P = 3000
    bodyGyro.D = 50
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    local arrived = false
    local timeout = os.clock() + 15

    while alive and os.clock() < timeout do
        if shouldContinue and not shouldContinue() then
            break
        end

        root = getRoot()

        if not root then
            break
        end

        local delta = target - root.Position
        local distance = delta.Magnitude

        if distance <= arriveDistance then
            arrived = true
            break
        end

        local direction = delta.Unit

        bodyVelocity.Velocity = direction * speed

        local flatDirection = Vector3.new(
            direction.X,
            0,
            direction.Z
        )

        if flatDirection.Magnitude > 0.001 then
            bodyGyro.CFrame = CFrame.lookAt(
                root.Position,
                root.Position + flatDirection.Unit
            )
        end

        RunService.Heartbeat:Wait()
    end

    if bodyVelocity and bodyVelocity.Parent then
        bodyVelocity:Destroy()
    end

    if bodyGyro and bodyGyro.Parent then
        bodyGyro:Destroy()
    end

    root = getRoot()

    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        if arrived then
            placeRoot(
                root,
                CFrame.new(
                    target.X,
                    y,
                    target.Z
                )
            )
        end
    end

    humanoid = getHumanoid()

    if humanoid then
        humanoid.PlatformStand = false
    end

    return arrived
end

local function returnAutoSteal()
    if moving then
        return
    end

    local base = getBasePosition()

    if not base then
        return
    end

    moving = true

    task.spawn(function()
        pcall(function()
            swapStealHumanoid()

            if not prepareStealHumanoid() then
                return
            end

            local root = getRoot()

            if not root then
                return
            end

            -- Primeiro aplica a cadeia principal do movimento do Auto Steal.
            local path = buildStealPath(
                root.Position,
                base
            )

            if #path > 0 then
                stealAlong(path, function()
                    return alive and moving
                end)
            end

            if not alive or not moving then
                return
            end

            -- Correção final usando groundedY + placeRoot.
            root = getRoot()

            if root then
                local y = groundedY(
                    base.X,
                    base.Z,
                    root.Position.Y
                )

                placeRoot(
                    root,
                    CFrame.new(base.X, y, base.Z)
                )
            end

            if not alive or not moving then
                return
            end

            -- Bypass completo de retorno da open source.
            bypassMoveTo(
                base,
                function()
                    return alive and moving
                end,
                bypassSpeed
            )

            -- Correção final exata.
            root = getRoot()

            if root then
                local y = groundedY(
                    base.X,
                    base.Z,
                    root.Position.Y
                )

                placeRoot(
                    root,
                    CFrame.new(base.X, y, base.Z)
                )
            end
        end)

        moving = false
    end)
end

-- ============================================================
-- PET ESP
-- ============================================================

local espFolder = Workspace:FindFirstChild("MiniReturnPetESP")

if espFolder then
    pcall(function()
        espFolder:Destroy()
    end)
end

espFolder = Instance.new("Folder")
espFolder.Name = "MiniReturnPetESP"
espFolder.Parent = Workspace

local rarityColors = {
    Common = Color3.fromRGB(190, 200, 215),
    Uncommon = Color3.fromRGB(110, 195, 255),
    Rare = Color3.fromRGB(110, 195, 255),
    Epic = Color3.fromRGB(180, 110, 255),
    Legendary = Color3.fromRGB(255, 190, 80),
    Mythic = Color3.fromRGB(255, 90, 90),
    Secret = Color3.fromRGB(255, 120, 255),
}

local function getEspColor(rarity)
    return rarityColors[rarity] or Color3.fromRGB(190, 200, 215)
end

local function formatNumber(n)
    n = tonumber(n) or 0
    local suffix = {"", "K", "M", "B", "T", "Qa", "Qi"}
    local i = 1
    while n >= 1000 and i < #suffix do
        n = n / 1000
        i = i + 1
    end
    if i == 1 then
        return string.format("%d", n)
    end
    return string.format("%.2f%s", n, suffix[i])
end

local function ensureEspEntry(id, color)
    local entry = espEntries[id]
    if entry then
        return entry
    end

    local anchor = Instance.new("Part")
    anchor.Name = "PetESPAnchor"
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.CanTouch = false
    anchor.Transparency = 1
    anchor.Size = Vector3.new(0.2, 0.2, 0.2)
    anchor.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESPInfo"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(250, 58)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = anchor
    billboard.Parent = anchor

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextWrapped = true
    label.TextStrokeTransparency = 0.35
    label.TextColor3 = color
    label.Parent = billboard

    local icon = Instance.new("ImageLabel")
    icon.Name = "PetImage"
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.fromOffset(0, 0)
    icon.Visible = false
    icon.Parent = billboard

    entry = {
        anchor = anchor,
        billboard = billboard,
        label = label,
        icon = icon,
        highlight = nil,
    }

    espEntries[id] = entry
    return entry
end

local function releaseEsp(id)
    local entry = espEntries[id]
    if not entry then
        return
    end

    if entry.highlight then
        pcall(function() entry.highlight:Destroy() end)
    end
    if entry.billboard then
        pcall(function() entry.billboard:Destroy() end)
    end
    if entry.anchor then
        pcall(function() entry.anchor:Destroy() end)
    end

    espEntries[id] = nil
end

local function clearEsp()
    for id in pairs(espEntries) do
        releaseEsp(id)
    end
    table.clear(espMarks)
end

local function collectPetRecords()
    local runtimeRecords = {}
    local snapshot = nil

    pcall(function()
        if GetRuntimeSnapshot then
            snapshot = GetRuntimeSnapshot()
        end
    end)

    if typeof(snapshot) == "table" then
        for _, group in pairs(snapshot) do
            if typeof(group) == "table" and typeof(group.Records) == "table" then
                for uid, record in pairs(group.Records) do
                    runtimeRecords[uid] = record
                end
            end
        end
    end

    return runtimeRecords
end

local function updatePetESP()
    if not espEnabled then
        clearEsp()
        return
    end

    table.clear(espMarks)

    local rendered = Workspace:FindFirstChild("ClientRenderedAssets")
    if not rendered then
        clearEsp()
        return
    end

    local saveData = nil
    pcall(function()
        if Save and typeof(Save.Get) == "function" then
            saveData = Save.Get()
        end
    end)

    local inventory = saveData and saveData.Inventory or {}
    local runtimeRecords = collectPetRecords()
    local root = getRoot()

    for _, petModel in ipairs(rendered:GetChildren()) do
        local uid = petModel:GetAttribute("UID")

        if typeof(uid) == "string" then
            local ok, pivot = pcall(function()
                return petModel:GetPivot()
            end)

            if ok and pivot then
                local position = pivot.Position
                local inRange = root and (root.Position - position).Magnitude <= 2000

                if inRange then
                    local inventoryRecord = inventory[uid]
                    local runtimeRecord = runtimeRecords[uid]

                    local category
                    if typeof(inventoryRecord) == "table" then
                        category = inventoryRecord.Category
                    end

                    local moneyPerSecond
                    local mutation
                    local scale

                    if typeof(runtimeRecord) == "table" then
                        if not category and typeof(runtimeRecord.ItemData) == "table" then
                            category = runtimeRecord.ItemData.Category
                        end

                        moneyPerSecond = tonumber(runtimeRecord.MoneyPerSecond)
                        mutation = runtimeRecord.Mutation
                        scale = runtimeRecord.Scale
                    end

                    local rarity = resolveRarity(category)
                    local petName = assetName(category)

                    local lines = {
                        string.format("%s [%s]", petName, tostring(rarity or "?"))
                    }

                    if mutation and tostring(mutation) ~= "" then
                        table.insert(lines, "Mutation: " .. tostring(mutation))
                    end

                    if scale then
                        table.insert(lines, "Scale: " .. tostring(scale))
                    end

                    if moneyPerSecond then
                        table.insert(lines, formatNumber(moneyPerSecond) .. "/s")
                    end

                    local id = "pet_" .. petModel.Name
                    local color = getEspColor(rarity)
                    local entry = ensureEspEntry(id, color)

                    entry.anchor.CFrame = CFrame.new(position)
                    entry.label.Text = table.concat(lines, "\n")
                    entry.label.TextColor3 = color

                    -- Usa o proprio pet renderizado como o "desenho/fotinha"
                    -- do ESP, exatamente no estilo do Pet ESP da open source.
                    if not entry.highlight then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "PetESPHighlight"
                        highlight.FillTransparency = 0.6
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = espFolder
                        entry.highlight = highlight
                    end

                    entry.highlight.Adornee = petModel
                    entry.highlight.FillColor = color
                    entry.highlight.OutlineColor = color

                    espMarks[id] = true
                end
            end
        end
    end

    for id in pairs(espEntries) do
        if not espMarks[id] then
            releaseEsp(id)
        end
    end
end

-- ============================================================
-- UI
-- ============================================================

local oldGui = CoreGui:FindFirstChild("MiniReturnAutoSteal")
if oldGui then
    pcall(function()
        oldGui:Destroy()
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "MiniReturnAutoSteal"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

ENV.__MINI_RETURN_ESP_GUI = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(240, 150)
main.Position = UDim2.new(0.5, -120, 0.5, -75)
main.BackgroundColor3 = Color3.fromRGB(17, 17, 22)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 85)
stroke.Thickness = 1
stroke.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.fromOffset(10, 6)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.Text = "Mini Auto Steal"
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(1, -20, 0, 20)
subtitle.Position = UDim2.fromOffset(10, 32)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextColor3 = Color3.fromRGB(145, 145, 160)
subtitle.Text = "Movement + Egg ESP"
subtitle.Parent = main

local function createButton(name, text, y)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 38)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(31, 31, 40)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(235, 235, 240)
    button.Text = text
    button.Parent = main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = button

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(65, 65, 80)
    s.Thickness = 1
    s.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            {BackgroundColor3 = Color3.fromRGB(42, 42, 54)}
        ):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            {BackgroundColor3 = Color3.fromRGB(31, 31, 40)}
        ):Play()
    end)

    return button
end

local returnButton = createButton(
    "ReturnAutoSteal",
    "RETURN AUTO STEAL",
    58
)

local espButton = createButton(
    "EspPets",
    "PET ESP: OFF",
    104
)

returnButton.MouseButton1Click:Connect(function()
    if moving then
        return
    end

    returnButton.Text = "RETURNING..."

    task.spawn(function()
        returnAutoSteal()

        task.wait(0.15)

        if alive then
            returnButton.Text = "RETURN AUTO STEAL"
        end
    end)
end)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled

    if espEnabled then
        espButton.Text = "PET ESP: ON"
        espButton.BackgroundColor3 = Color3.fromRGB(45, 70, 48)
    else
        espButton.Text = "PET ESP: OFF"
        espButton.BackgroundColor3 = Color3.fromRGB(31, 31, 40)
        clearEsp()
    end
end)

-- Drag support
do
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        dragInput = input
    end

    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragInput = nil
        end
    end

    title.InputBegan:Connect(beginDrag)
    title.InputEnded:Connect(endDrag)

    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end))
end

-- PET ESP update loop
track(RunService.Heartbeat:Connect(function()
    if not alive then
        return
    end

    if espEnabled then
        updatePetESP()
    end
end))

-- Character respawn support
track(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)

    if espEnabled then
        clearEsp()
    end
end))

-- Clean shutdown if GUI is removed manually.
track(gui.AncestryChanged:Connect(function(_, parent)
    if parent == nil and alive then
        shutdown()
    end
end))
