local e=game:GetService( "Players" )
local r=game:GetService( "Workspace" )
local y=game:GetService( "RunService" )
local u=game:GetService( "TweenService" )
local w=game:GetService( "UserInputService" )
local j=game:GetService( "ReplicatedStorage" )
local k=game:GetService( "ProximityPromptService" )
local a=game:GetService( "HttpService" )
local TeleportService=game:GetService( "TeleportService" )
local o=e.LocalPlayer
local Window=nil
local currentLang="EN"
local executorCheckCaller=typeof(checkcaller)=="function" and checkcaller or function() return false end
local safeNewCClosure=typeof(newcclosure)=="function" and newcclosure or function(fn) return fn end
local V=game:GetService( "ProximityPromptService" )pcall(function(...) V.PromptButtonHoldBegan :Connect(function(e,...) pcall(function(...)
            if typeof(fireproximityprompt)== "function" then
                fireproximityprompt(e)
            end
        end
        )
    end
    )
end
)
local H=function(...)
end
local t=function(...)
end
local s=nil pcall(function(...) s=require((j:WaitForChild( "Client" , 5 )):WaitForChild( "EggState" , 5 ))
end
)
if not s then
    pcall(function(...) s=require(j.Client.EggState )
    end
    )
end
local p=nil pcall(function(...) p=require(((j:WaitForChild( "Shared" , 5 )):WaitForChild( "Util" , 5 )):WaitForChild( "AssetItems" , 5 ))
end
)
if not p then
    pcall(function(...) p=require(j.Shared.Util .AssetItems )
    end
    )
end
local B=nil pcall(function(...) B=require((j:WaitForChild( "Shared" , 5 )):WaitForChild( "Remotes" , 5 ))
end
)
if not B then
    pcall(function(...) B=require(j.Shared.Remotes )
    end
    )
end
local function J(e,r,...)
    local y=(j:FindFirstChild( "Packages" )and j.Packages :FindFirstChild( "Networking" ))or j:FindFirstChild( "Network" )or j
    local u=y:FindFirstChild(e)or j:FindFirstChild(e)
    if u then
        return u
    end
    local w=y:FindFirstChild(e, true )or j:FindFirstChild(e, true )
    if w then
        return w
    end
    if r then
        local e=y:FindFirstChild(r)or j:FindFirstChild(r)
        if e then
            return e
        end
        local u=y:FindFirstChild(r, true )or j:FindFirstChild(r, true )
        if u then
            return u
        end
    end
    local k=string.match (e, "[^/]+$" )
    if k then
        local e=y:FindFirstChild(k, true )or j:FindFirstChild(k, true )
        if e then
            return e
        end
    end
    return nil
end

local K=J( "RF/EggWorld/AskPlaceEgg" , "AskPlaceEgg" ) 
local c=J( "RF/EggWorld/AskLiveSnapshot" , "AskLiveSnapshot" ) 
local v=J( "RF/Homestead/AskState" , "RF/Plots/AskState" )or J( "AskState" )
local i=J( "RF/EggWorld/AskFieldEggCarry" , "AskFieldEggCarry" ) 
local R=J( "RF/EggWorld/AskFieldEggSnapshot" , "AskFieldEggSnapshot" )or J( "Eggs: RequestAreaEggSnapshot" , "RequestAreaEggSnapshot" )
local g=J( "RF/EggWorld/AskHatch" , "AskHatch" )or J( "Eggs: RequestHatchEgg" )
local Q=J( "RF/EggWorld/AskFinishHatch" , "AskFinishHatch" )or J( "Eggs: RequestCompleteHatchEgg" )
local P=J( "RE/GuardPatrol/ForestStrike" , "ForestStrike" )or(B and(B.GuardPatrol and B.GuardPatrol.ForestStrike ))
local N=J( "SpeedTollOffer" , "RE/GuardPatrol/SpeedTollOffer" )or(B and(B.GuardPatrol and B.GuardPatrol.SpeedTollOffer ))
local U=J( "RF/Treadmill/AskDoff" , "AskDoff" )
local l=J( "RF/Treadmill/AskDon" , "AskDon" )or J( "RF/Treadmill/AskMount" , "AskMount" )
local D=J( "RF/Treadmill/AskTierRaise" , "Treadmills: RequestUpgrade" , "AskTierRaise" )
local C=J( "RF/Trailwear/AskPurchase" , "Trailwear: RequestPurchase" , "AskPurchase" )
local q=J( "RF/Trailwear/AskChoose" , "Trailwear: RequestEquip" , "AskChoose" )
local n=J( "RF/Trailwear/AskDoff" , "Trailwear: RequestUnequip" , "AskDoff" )H(string.format ( "[RemoteCheck] Carry: %s | Snapshot: %s | Place: %s | Hatch: %s | FinishHatch: %s | Strike: %s | Toll: %s | Doff: %s" ,tostring(i~=nil),tostring(R~=nil),tostring(K~=nil),tostring(g~=nil),tostring(Q~=nil),tostring(P~=nil),tostring(N~=nil),tostring(U~=nil)))

local f={[ "Light Dark" ]= 1300 ,[ "LightDark" ]= 1300 ;
[ "Titan Temple" ]= 1100 ,[ "Cherry Blossom" ]= 1000 ,[ "Cosmic" ]= 900 ;
[ "Prehistoric" ]= 800 ;
[ "Abyss Ocean" ]= 700 ,[ "Volcano" ]= 600 ;
[ "Snow" ]= 500 ,[ "Jungle" ]= 400 ;
[ "Desert" ]= 300 ,[ "Lake" ]= 200 ;
[ "Forest" ]= 100 }
local M={ "Light Dark" ;
"Titan Temple" ;
"Cherry Blossom" , "Cosmic" ;
"Prehistoric" , "Abyss Ocean" ;
"Volcano" ;
"Snow" , "Jungle" , "Desert" , "Lake" ;
"Forest" }
local I={[ "Light Dark" ]= 420 ,[ "LightDark" ]= 420 ;
[ "Titan Temple" ]= 380 ,[ "Cherry Blossom" ]= 330 ,[ "Cosmic" ]= 280 ;
[ "Prehistoric" ]= 240 ,[ "Abyss Ocean" ]= 200 ;
[ "Volcano" ]= 180 ;
[ "Snow" ]= 160 ,[ "Jungle" ]= 140 ;
[ "Desert" ]= 130 ,[ "Lake" ]= 125 ,[ "Forest" ]= 125 }
local L= -360
local E= 525
local b= 620
local A= 130
local S=CFrame.new ( 4773.7587890625 , 70.392112731934 , -315.73501586914 )

local Z= "DiceHub_FlightSpeed.txt"
local z= "DiceHub_EggSelectConfig.json"
local d={[ "Light Dark" ]=Color3.fromRGB ( 168 , 85 , 247 ),[ "Titan Temple" ]=Color3.fromRGB ( 245 , 158 , 11 );
[ "Cherry Blossom" ]=Color3.fromRGB ( 236 , 72 , 153 );
[ "Cosmic" ]=Color3.fromRGB ( 6 , 182 , 212 ),[ "Prehistoric" ]=Color3.fromRGB ( 16 , 185 , 129 ),[ "Abyss Ocean" ]=Color3.fromRGB ( 59 , 130 , 246 );
[ "Volcano" ]=Color3.fromRGB ( 239 , 68 , 68 ),[ "Snow" ]=Color3.fromRGB ( 147 , 197 , 253 ),[ "Jungle" ]=Color3.fromRGB ( 34 , 197 , 94 ),[ "Desert" ]=Color3.fromRGB ( 234 , 179 , 8 ),[ "Lake" ]=Color3.fromRGB ( 20 , 184 , 166 ),[ "Forest" ]=Color3.fromRGB ( 22 , 163 , 74 )}

local X={ "Divine" , "Eternal" , "Secret" ;
"Cosmic" , "Mythic" , "Legendary" ;
"Epic" ;
"Rare" ;
"Uncommon" ;
"Common" }
local G={[ "Divine" ]=Color3.fromRGB ( 244 , 63 , 94 );
[ "Eternal" ]=Color3.fromRGB ( 217 , 70 , 239 ),[ "Secret" ]=Color3.fromRGB ( 249 , 115 , 22 ),[ "Cosmic" ]=Color3.fromRGB ( 6 , 182 , 212 ),[ "Mythic" ]=Color3.fromRGB ( 139 , 92 , 246 ),[ "Legendary" ]=Color3.fromRGB ( 251 , 191 , 36 );
[ "Epic" ]=Color3.fromRGB ( 168 , 85 , 247 );
[ "Rare" ]=Color3.fromRGB ( 59 , 130 , 246 );
[ "Uncommon" ]=Color3.fromRGB ( 34 , 197 , 94 ),[ "Common" ]=Color3.fromRGB ( 148 , 163 , 184 )}
local F={[ "Divine" ]= 6 ;
[ "Eternal" ]= 5 ;
[ "Secret" ]= 4 ,[ "Cosmic" ]= 3 ;
[ "Mythic" ]= 2 ;
[ "Legendary" ]= 1 ,[ "Epic" ]= 0.5 ,[ "Rare" ]= 0.3 ,[ "Uncommon" ]= 0.1 ;
[ "Common" ]= 0 }
local h

-- ========================================
-- AUTO EQUIP BEST - Extracted & Standalone
-- ========================================
local AutoEquipBest = false
local AutoEquipBestRunning = true

local function getRemoteAutoEquip(path)
    local Networking = (j:FindFirstChild("Packages") and j.Packages:FindFirstChild("Networking")) or j:FindFirstChild("Network") or j
    local remote = Networking:FindFirstChild(path) or j:FindFirstChild(path)
    if remote then
        return remote
    end
    local remote2 = Networking:FindFirstChild(path, true) or j:FindFirstChild(path, true)
    if remote2 then
        return remote2
    end
    return nil
end

local function characterReadyAutoEquip()
    local character = o and o.Character
    if not character then
        return false
    end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

local function wearBest()
    local remote = getRemoteAutoEquip("RF/Haul/WearBest")
    if not remote then
        return nil
    end
    if remote:IsA("RemoteFunction") then
        local ok, result = pcall(function()
            return remote:InvokeServer()
        end)
        return ok and result or nil
    end
    if remote:IsA("RemoteEvent") then
        local ok = pcall(function()
            remote:FireServer()
        end)
        return ok
    end
    return nil
end

local function setAutoEquipBest(enabled)
    AutoEquipBest = enabled == true
end

local function equipBestNow()
    return wearBest()
end

-- Auto Equip Best Loop
task.spawn(function()
    while AutoEquipBestRunning do
        if AutoEquipBest and characterReadyAutoEquip() then
            wearBest()
        end
        task.wait(6)
    end
end)

-- ========================================
-- END AUTO EQUIP BEST
-- ========================================

local function O(...)
    local e= 600 pcall(function(...)
        local r= false
        if isfile then
            r=isfile(Z)
        elseif readfile then
            local e,y=pcall(readfile,Z)r=e and(y~=nil)
        end
        if r and readfile then
            local r=readfile(Z)
            local u=tonumber(r)
            if u and(u>= 100 and u<= 1000 )then
                e=math.floor (u)
            end
        end
    end
    )
    return e
end
local function Y(e,...) pcall(function(...)
        if writefile then
            local y=math.clamp (math.floor (tonumber(e)or 600 ), 100 , 1000 )writefile(Z,tostring(y))
        end
    end
    )
end
local function T(...)
    local e=nil pcall(function(...)
        local r= false
        if isfile then
            r=isfile(z)
        elseif readfile then
            local e,y=pcall(readfile,z)r=e and(y~=nil)
        end
        if r and(readfile and a)then
            local r=readfile(z)
            if r and r~= "" then
                local u=a:JSONDecode(r)
                if type(u)== "table" then
                    e=u
                end
            end
        end
    end
    )
    local r={[ "Light Dark" ]= true ,[ "Titan Temple" ]= true ,[ "Cherry Blossom" ]= true ;
    [ "Cosmic" ]= false ;
    [ "Prehistoric" ]= false ,[ "Abyss Ocean" ]= false ;
    [ "Volcano" ]= false ,[ "Snow" ]= false ;
    [ "Jungle" ]= false ,[ "Desert" ]= false ;
    [ "Lake" ]= false ,[ "Forest" ]= false }
    local y={[ "Divine" ]= true ,[ "Eternal" ]= true ,[ "Secret" ]= true ,[ "Cosmic" ]= true ,[ "Mythic" ]= true ;
    [ "Legendary" ]= false ,[ "Epic" ]= false ,[ "Rare" ]= false ;
    [ "Uncommon" ]= false ;
    [ "Common" ]= false }
    if type(e)~= "table" then
        e={[ "selectedZones" ]=r;
        [ "selectedRarities" ]=y,[ "alwaysCollectSecretPlus" ]= true ,[ "minRarityTier" ]= 2 ;
        [ "autoTreadmill" ]= true ;
        [ "autoUpgradeTreadmill" ]= true ,[ "autoBuyTrails" ]= true ;
        [ "hideNotEnoughMoney" ]= true ;
        [ "performanceMode" ]= false ,[ "disable3D" ]= false ,[ "antiAFK" ]= true ,[ "language" ]= "EN" }
    else
        if type(e.selectedZones )~= "table" then
            e.selectedZones =r
        end
        if type(e.selectedRarities )~= "table" then
            e.selectedRarities =y
        else
            for r,w in ipairs(X)do
                if e.selectedRarities [w]==nil then
                    e.selectedRarities [w]=(y[w]== true )
                end
            end
        end
        if e.alwaysCollectSecretPlus ==nil then
            e.alwaysCollectSecretPlus = true
        end
        if e.minRarityTier ==nil then
            e.minRarityTier = 2
        end
        if e.autoTreadmill ==nil then
            e.autoTreadmill = true
        end
        if e.autoUpgradeTreadmill ==nil then
            e.autoUpgradeTreadmill = true
        end
        if e.autoBuyTrails ==nil then
            e.autoBuyTrails = true
        end
        if e.hideNotEnoughMoney ==nil then
            e.hideNotEnoughMoney = true
        end
        if e.performanceMode ==nil then
            e.performanceMode = false
        end
        if e.disable3D ==nil then
            e.disable3D = false
        end
        if e.antiAFK ==nil then
            e.antiAFK = true
        end
        if e.language ==nil then
            e.language = "EN"
        end
    end
    return e
end
local function x(...)
    if not p or not B then
        return
    end
    local e= T()h=e or {}
    local r = game:GetService("HttpService"):JSONEncode(h)
    if writefile then
        writefile(z, r)
    end
end

x()

-- Inicializar h se vazio
if not h or type(h) ~= "table" then
    h = T()
end

-- Função para enviar arquivo (mock se writefile não existir)
local function saveSettings()
    pcall(function()
        if writefile then
            local r = game:GetService("HttpService"):JSONEncode(h)
            writefile(z, r)
        end
    end)
end

-- Godmode Functions
local godmodeEnabled = false
local originalProximityPrompts = {}

local function enableDesyncGodmode()
    godmodeEnabled = true
    pcall(function()
        local ProximityPromptService = game:GetService("ProximityPromptService")
        ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
            if godmodeEnabled and typeof(fireproximityprompt) == "function" then
                fireproximityprompt(prompt)
            end
        end)
    end)
end

local function disableDesyncGodmode()
    godmodeEnabled = false
end

-- WindUI Loading
local success, WindUI = pcall(require, game:GetService("CoreGui"):WaitForChild("WindUI", 5))
if not success or not WindUI then
    print("[ERROR] WindUI not found!")
    return
end

-- Create Main Window
local Window = WindUI:CreateWindow({
    Title="Dice Hub x WindUI v42.64",
    Author="By DiceHub",
    Size=UDim2.new(0,600,0,400),
})

-- Create Tabs
local FarmTab = Window:CreateTab("Farm")
local SettingsTab = Window:CreateTab("Settings")

-- ========================================
-- FARM TAB
-- ========================================

-- Auto Steal Toggle
pcall(function()
    FarmTab:Toggle({
        Title="Auto Steal",
        Desc="Automatically steal eggs from the field",
        Value=h.autoSteal==true,
        Callback=function(value)
            h.autoSteal=value==true
        end,
    })
end)

-- Auto Steal Teleport Toggle
pcall(function()
    FarmTab:Toggle({
        Title="Auto Steal (Teleport)",
        Desc="Steal eggs using teleportation method",
        Value=h.autoStealTeleport==true,
        Callback=function(value)
            h.autoStealTeleport=value==true
        end,
    })
end)

-- Auto Place Toggle
pcall(function()
    FarmTab:Toggle({
        Title="Auto Place",
        Desc="Return home every 5 steals and place the stored eggs",
        Value=h.autoPlaceEvery5==true,
        Callback=function(value)
            h.autoPlaceEvery5=value==true
            if not value then h.batchStealCount=0 end
        end,
    })
end)

-- Auto Return Toggle
pcall(function()
    FarmTab:Toggle({
        Title="Auto Return",
        Desc="Automatically return to the safe area after stealing",
        Value=h.autoGlide==true,
        Callback=function(value)
            h.autoGlide=value==true
        end,
    })
end)

-- Godmode Toggle
pcall(function()
    FarmTab:Toggle({
        Title="Godmode",
        Desc="Enable the original desync godmode protection",
        Value=h.godmode==true,
        Callback=function(value)
            if value then
                pcall(enableDesyncGodmode)
            else
                pcall(disableDesyncGodmode)
            end
        end,
    })
end)

-- Auto Equip Best Toggle
pcall(function()
    FarmTab:Toggle({
        Title="Auto Equip Best",
        Desc="Automatically equip the best pets every 6 seconds",
        Value=AutoEquipBest,
        Callback=function(value)
            setAutoEquipBest(value==true)
        end,
    })
end)

-- Auto Equip Best Button
pcall(function()
    FarmTab:Button({
        Title="Equip Best Now",
        Desc="Manually equip the best pets immediately",
        Icon="zap",
        Callback=function()
            equipBestNow()
            WindUI:Notify({Title="Dice Hub",Content="Equipped best pets",Duration=2})
        end,
    })
end)

-- Selected Zones Dropdown
local zoneValues={
    "Light Dark","Titan Temple","Cherry Blossom","Cosmic",
    "Prehistoric","Abyss Ocean","Volcano","Snow",
    "Jungle","Desert","Lake","Forest"
}
local selectedZones={}
for _,zone in ipairs(zoneValues) do
    if h.selectedZones and h.selectedZones[zone]==true then
        table.insert(selectedZones,zone)
    end
end

pcall(function()
    FarmTab:Dropdown({
        Title="Selected Zones",
        Desc="Choose which zones can be farmed",
        Values=zoneValues,
        Value=selectedZones,
        Multi=true,
        AllowNone=true,
        SearchBarEnabled=true,
        Callback=function(value)
            local selected={}
            if type(value)=="table" then
                for _,item in ipairs(value) do
                    if type(item)=="string" then selected[item]=true end
                end
                for key,item in pairs(value) do
                    if type(key)=="string" and item==true then selected[key]=true end
                end
            elseif type(value)=="string" then
                selected[value]=true
            end
            h.selectedZones=selected
            saveSettings()
        end,
    })
end)

-- Selected Rarities Dropdown
local rarityValues={
    "Divine","Eternal","Secret","Cosmic","Mythic",
    "Legendary","Epic","Rare","Uncommon","Common"
}
local selectedRarities={}
for _,rarity in ipairs(rarityValues) do
    if h.selectedRarities and h.selectedRarities[rarity]==true then
        table.insert(selectedRarities,rarity)
    end
end

pcall(function()
    FarmTab:Dropdown({
        Title="Selected Rarities",
        Desc="Choose which egg rarities can be farmed",
        Values=rarityValues,
        Value=selectedRarities,
        Multi=true,
        AllowNone=true,
        SearchBarEnabled=true,
        Callback=function(value)
            local selected={}
            if type(value)=="table" then
                for _,item in ipairs(value) do
                    if type(item)=="string" then selected[item]=true end
                end
                for key,item in pairs(value) do
                    if type(key)=="string" and item==true then selected[key]=true end
                end
            elseif type(value)=="string" then
                selected[value]=true
            end
            h.selectedRarities=selected
            saveSettings()
        end,
    })
end)

-- Always Steal Secret+
pcall(function()
    FarmTab:Toggle({
        Title="Always Steal Secret+",
        Desc="Always target Secret, Eternal and Divine eggs",
        Value=h.alwaysCollectSecretPlus~=false,
        Callback=function(value)
            h.alwaysCollectSecretPlus=value==true
            saveSettings()
        end,
    })
end)

-- Flight Speed Slider
local speedSlider
pcall(function()
    speedSlider=FarmTab:Slider({
        Title="Flight Speed",
        Desc="Control the flight speed used by the Auto Farm",
        Step=1,
        Value={
            Min=100,
            Max=1000,
            Default=math.clamp(tonumber(h.glideSpeed) or 600,100,1000),
        },
        IsTooltip=true,
        IsTextbox=true,
        Callback=function(value)
            value=math.clamp(math.floor(tonumber(value) or 600),100,1000)
            h.glideSpeed=value
            Y(value)
        end,
    })
end)

-- Refresh Settings Button
pcall(function()
    FarmTab:Button({
        Title="Refresh Settings",
        Desc="Apply the current zone and rarity settings",
        Icon="refresh-cw",
        Callback=function()
            saveSettings()
            WindUI:Notify({Title="Dice Hub",Content="Settings refreshed",Duration=2})
        end,
    })
end)

-- ========================================
-- SETTINGS TAB
-- ========================================

-- Performance Mode
pcall(function()
    SettingsTab:Toggle({
        Title="Performance Mode",
        Desc="Disable some visual effects to improve performance",
        Value=h.performanceMode==true,
        Callback=function(value)
            h.performanceMode=value==true
            saveSettings()
        end,
    })
end)

-- Disable 3D
pcall(function()
    SettingsTab:Toggle({
        Title="Disable 3D Rendering",
        Desc="Disable 3D rendering for better performance",
        Value=h.disable3D==true,
        Callback=function(value)
            h.disable3D=value==true
            if value then
                pcall(function()
                    y:Set3dRenderingEnabled(false)
                end)
            else
                pcall(function()
                    y:Set3dRenderingEnabled(true)
                end)
            end
            saveSettings()
        end,
    })
end)

-- Anti AFK
pcall(function()
    SettingsTab:Toggle({
        Title="Anti-AFK",
        Desc="Prevent being kicked for inactivity",
        Value=h.antiAFK==true,
        Callback=function(value)
            h.antiAFK=value==true
            saveSettings()
        end,
    })
end)

-- Notification
pcall(function()
    WindUI:Notify({Title="Dice Hub",Content="Auto Farm loaded with Auto Equip Best",Duration=3})
end)

-- Set notification position
pcall(function() WindUI:SetNotificationLower(true) end)

-- Select Farm Tab by default
pcall(function() FarmTab:Select() end)

H( "[+] Dice Hub v42.64 Ready! Auto Equip Best Integrated! All-In-One Built-in Anti-AFK & Prometheus Ready!" )
