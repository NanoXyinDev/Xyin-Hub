-- ============================================
-- N4n0Xy1n Xy1nESP v3.0 - F1X3D G4C0R K1NG
-- @RukanooXD_YT // Pembuat Script
-- F34tur3s: ESP, K1ll 4ur4, T3l3p0rt H1d3r, 
-- C01n C0ll3ct, M0d3rn UI, Dr4gg4bl3 B0x
-- L4ngu4g3: 1nd0 + 3ngl15h + J4p4n353 + Ru5514n
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- S3TT1NGS (4LL F4L53 BY D3F4ULT)
-- ============================================
local Settings = {
    ESP_Enabled = false,
    Line_ESP = false,
    Box_ESP = false,
    Name_ESP = false,
    Distance_ESP = false,
    Health_ESP = false,
    TeamCheck = false,
    MaxDistance = 1000,
    LineOrigin = "Bottom",
    TextSize = 13,
    LineThickness = 1,
    BoxThickness = 1,
    -- K1ll 4ur4
    KillAura_Enabled = false,
    KillAura_Radius = 20,
    KillAura_Delay = 0.1,
    -- T3l3p0rt
    TeleportHider_Enabled = false,
    TeleportHider_Delay = 2,
    TeleportHider_Current = nil,
    -- C01n C0ll3ct
    AutoCoin_Enabled = false,
    AutoCoin_Delay = 0.5,
    -- C0l0r5
    LineColor = Color3.fromRGB(0, 255, 255),
    BoxColor = Color3.fromRGB(255, 0, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),
    DistanceColor = Color3.fromRGB(255, 255, 0),
    SeekerColor = Color3.fromRGB(255, 50, 50),
    HiderColor = Color3.fromRGB(50, 255, 50),
    DeadColor = Color3.fromRGB(100, 100, 100),
}

-- ============================================
-- DR4GG4BL3 B0X P0S1T10N
-- ============================================
local BoxOffset = {X = 0, Y = 0}
local IsDraggingBox = false
local DragStartPos = nil
local BoxStartOffset = nil

-- ============================================
-- DR4W1NG 0BJ3CT5 M4N4G3R
-- ============================================
local ESPObjects = {}

local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        pcall(function() drawing[property] = value end)
    end
    return drawing
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj then pcall(function() obj:Remove() end) end
        end
        ESPObjects[player] = nil
    end
end

local function CreateESPObjects(player)
    if ESPObjects[player] then RemoveESP(player) end
    
    ESPObjects[player] = {
        Line = CreateDrawing("Line", {Thickness = Settings.LineThickness, Color = Settings.LineColor, Transparency = 1, Visible = false, ZIndex = 1}),
        Box = CreateDrawing("Square", {Thickness = Settings.BoxThickness, Color = Settings.BoxColor, Transparency = 1, Filled = false, Visible = false, ZIndex = 2}),
        BoxFilled = CreateDrawing("Square", {Thickness = 1, Color = Settings.BoxColor, Transparency = 0.15, Filled = true, Visible = false, ZIndex = 1}),
        Name = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.NameColor, Transparency = 1, Visible = false, ZIndex = 3}),
        Distance = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.DistanceColor, Transparency = 1, Visible = false, ZIndex = 3}),
        Health = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.HealthColor, Transparency = 1, Visible = false, ZIndex = 3}),
        HealthBar = CreateDrawing("Line", {Thickness = 2, Color = Settings.HealthColor, Transparency = 1, Visible = false, ZIndex = 4}),
        HealthBarBG = CreateDrawing("Line", {Thickness = 4, Color = Color3.fromRGB(50, 50, 50), Transparency = 1, Visible = false, ZIndex = 3}),
        Role = CreateDrawing("Text", {Text = "", Size = Settings.TextSize + 2, Center = true, Outline = true, Color = Settings.HiderColor, Transparency = 1, Visible = false, ZIndex = 5}),
    }
end

-- ============================================
-- H1D3R/S33K3R D3T3CT10N - F1X3D
-- ============================================
local function IsPlayerAlive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function IsPlayerInGame(player)
    -- Ch3ck 1f pl4y3r 1s 1n g4m3 (n0t 1n l0bby 0r sp4wn)
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Ch3ck 1f pl4y3r 1s 1n sp4wn 4r34 (y c00rd1n4t3 t00 h1gh 0r t00 l0w)
    if hrp.Position.Y > 500 or hrp.Position.Y < -100 then return false end
    
    return true
end

local function GetPlayerRole(player)
    local character = player.Character
    if not character then return "Unknown" end
    
    -- M3th0d 1: Ch3ck 4ttribut3s
    if character:FindFirstChild("Seeker") or character:FindFirstChild("IsSeeker") then return "Seeker" end
    if character:FindFirstChild("Hider") or character:FindFirstChild("IsHider") then return "Hider" end
    
    -- M3th0d 2: Ch3ck f0ld3r n4m3 1n w0rksp4c3
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Folder") then
            local lowerName = obj.Name:lower()
            if lowerName:match("seeker") or lowerName:match("hunter") then
                if obj:FindFirstChild(player.Name) then return "Seeker" end
            end
            if lowerName:match("hider") or lowerName:match("hidden") then
                if obj:FindFirstChild(player.Name) then return "Hider" end
            end
        end
    end
    
    -- M3th0d 3: Ch3ck l34d3rst4ts
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            local statName = stat.Name:lower()
            if statName:match("seeker") or statName:match("hunter") or statName:match("tagger") then
                if stat.Value and tonumber(stat.Value) > 0 then return "Seeker" end
            end
            if statName:match("hider") or statName:match("hidden") then
                if stat.Value and tonumber(stat.Value) > 0 then return "Hider" end
            end
        end
    end
    
    -- M3th0d 4: Ch3ck pl4y3r t34m
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:match("seeker") or teamName:match("hunter") or teamName:match("tagger") then return "Seeker" end
        if teamName:match("hider") or teamName:match("hidden") then return "Hider" end
    end
    
    -- M3th0d 5: Ch3ck 1f pl4y3r h4s w34p0n/t00l (s33k3r5 0ft3n h4v3 w34p0n)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:match("sword") or toolName:match("bat") or toolName:match("tag") or toolName:match("seek") then
                    return "Seeker"
                end
            end
        end
    end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:match("sword") or toolName:match("bat") or toolName:match("tag") or toolName:match("seek") then
                return "Seeker"
            end
        end
    end
    
    -- M3th0d 6: Ch3ck 4n1m4t10n (s33k3r5 m1ght h4v3 d1ff3r3nt w4lk 4n1m)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.WalkSpeed > 25 then return "Seeker" end
    end
    
    -- D3f4ult: 1f l0c4l pl4y3r 1s s33k3r, 0th3r5 4r3 h1d3r5 4nd v1c3 v3rs4
    local localRole = GetPlayerRole(LocalPlayer)
    if localRole == "Seeker" then
        return "Hider"
    elseif localRole == "Hider" then
        return "Seeker"
    end
    
    return "Hider"
end

local function IsHider(player)
    if player == LocalPlayer then return false end
    if not IsPlayerAlive(player) then return false end
    if not IsPlayerInGame(player) then return false end
    return GetPlayerRole(player) == "Hider"
end

local function IsSeeker(player)
    if player == LocalPlayer then return false end
    if not IsPlayerAlive(player) then return false end
    if not IsPlayerInGame(player) then return false end
    return GetPlayerRole(player) == "Seeker"
end

-- ============================================
-- 3SP L0G1C - F1X3D
-- ============================================
local function GetCharacter(player) return player.Character end
local function GetHumanoid(character) return character:FindFirstChildOfClass("Humanoid") end
local function GetRootPart(character) return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") end

local function UpdateESP()
    if not Settings.ESP_Enabled then
        for _, objects in pairs(ESPObjects) do
            for _, obj in pairs(objects) do pcall(function() obj.Visible = false end) end
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- SK1P D34D PL4Y3R5
        if not IsPlayerAlive(player) then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        -- SK1P PL4Y3R5 N0T 1N G4M3
        if not IsPlayerInGame(player) then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        local character = GetCharacter(player)
        if not character then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        local humanoid = GetHumanoid(character)
        local rootPart = GetRootPart(character)
        
        if not humanoid or not rootPart then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        -- T34m ch3ck
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        -- D15t4nc3 ch3ck
        local localHRP = GetRootPart(GetCharacter(LocalPlayer))
        if localHRP then
            local distance = (rootPart.Position - localHRP.Position).Magnitude
            if distance > Settings.MaxDistance then
                if ESPObjects[player] then
                    for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
                end
                continue
            end
        end
        
        local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
        if not rootVisible then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        if not ESPObjects[player] then CreateESPObjects(player) end
        
        local objects = ESPObjects[player]
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthPercent = health / maxHealth
        local role = GetPlayerRole(player)
        local isAlive = IsPlayerAlive(player)
        
        -- B0x c0l0r b4s3d 0n r0l3 4nd 4l1v3 st4tus
        local boxColor = Settings.BoxColor
        if not isAlive then
            boxColor = Settings.DeadColor
        elseif role == "Seeker" then
            boxColor = Settings.SeekerColor
        elseif role == "Hider" then
            boxColor = Settings.HiderColor
        end
        
        -- G3t b0und1ng b0x
        local cf, size = character:GetBoundingBox()
        if not cf then
            for _, obj in pairs(objects) do pcall(function() obj.Visible = false end) end
            continue
        end
        
        local topY = cf.Position.Y + (size.Y / 2)
        local bottomY = cf.Position.Y - (size.Y / 2)
        
        local topPos = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, topY, cf.Position.Z))
        local bottomPos = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, bottomY, cf.Position.Z))
        
        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
        local boxWidth = boxHeight * 0.6
        
        -- Dr4gg4bl3 0ffs3t
        local boxX = rootPos.X - (boxWidth / 2) + BoxOffset.X
        local boxY = topPos.Y + BoxOffset.Y
        
        -- L1N3 3SP
        if Settings.Line_ESP and objects.Line then
            local lineOrigin
            if Settings.LineOrigin == "Bottom" then lineOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Settings.LineOrigin == "Top" then lineOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
            else lineOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end
            
            objects.Line.From = lineOrigin
            objects.Line.To = Vector2.new(rootPos.X, rootPos.Y)
            objects.Line.Color = isAlive and Settings.LineColor or Settings.DeadColor
            objects.Line.Visible = true
        elseif objects.Line then objects.Line.Visible = false end
        
        -- B0X 3SP
        if Settings.Box_ESP and objects.Box and objects.BoxFilled then
            objects.Box.Size = Vector2.new(boxWidth, boxHeight)
            objects.Box.Position = Vector2.new(boxX, boxY)
            objects.Box.Color = boxColor
            objects.Box.Visible = true
            
            objects.BoxFilled.Size = Vector2.new(boxWidth, boxHeight)
            objects.BoxFilled.Position = Vector2.new(boxX, boxY)
            objects.BoxFilled.Color = boxColor
            objects.BoxFilled.Visible = true
        else
            if objects.Box then objects.Box.Visible = false end
            if objects.BoxFilled then objects.BoxFilled.Visible = false end
        end
        
        -- N4M3 3SP
        if Settings.Name_ESP and objects.Name then
            local status = isAlive and "" or " [DEAD]"
            objects.Name.Text = player.Name .. " [" .. role .. "]" .. status
            objects.Name.Position = Vector2.new(rootPos.X, topPos.Y - 20)
            objects.Name.Color = not isAlive and Settings.DeadColor or (role == "Seeker" and Settings.SeekerColor or Settings.NameColor)
            objects.Name.Visible = true
        elseif objects.Name then objects.Name.Visible = false end
        
        -- R0L3 T4G
        if objects.Role then
            objects.Role.Text = role .. (not isAlive and " 💀" or "")
            objects.Role.Position = Vector2.new(rootPos.X, topPos.Y - 35)
            objects.Role.Color = not isAlive and Settings.DeadColor or (role == "Seeker" and Settings.SeekerColor or Settings.HiderColor)
            objects.Role.Visible = true
        end
        
        -- D15T4NC3 3SP
        if Settings.Distance_ESP and objects.Distance and localHRP then
            local dist = math.floor((rootPart.Position - localHRP.Position).Magnitude)
            objects.Distance.Text = tostring(dist) .. "m"
            objects.Distance.Position = Vector2.new(rootPos.X, bottomPos.Y + 5)
            objects.Distance.Visible = true
        elseif objects.Distance then objects.Distance.Visible = false end
        
        -- H34LTH 3SP
        if Settings.Health_ESP and objects.Health and objects.HealthBar and objects.HealthBarBG then
            objects.Health.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
            objects.Health.Position = Vector2.new(rootPos.X, bottomPos.Y + 20)
            objects.Health.Visible = true
            
            local barX = boxX - 6
            local barTop = boxY
            local barBottom = boxY + boxHeight
            
            objects.HealthBarBG.From = Vector2.new(barX, barTop)
            objects.HealthBarBG.To = Vector2.new(barX, barBottom)
            objects.HealthBarBG.Visible = true
            
            local healthHeight = boxHeight * healthPercent
            objects.HealthBar.From = Vector2.new(barX, barBottom - healthHeight)
            objects.HealthBar.To = Vector2.new(barX, barBottom)
            
            if healthPercent > 0.6 then objects.HealthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then objects.HealthBar.Color = Color3.fromRGB(255, 255, 0)
            else objects.HealthBar.Color = Color3.fromRGB(255, 0, 0) end
            objects.HealthBar.Visible = true
        else
            if objects.Health then objects.Health.Visible = false end
            if objects.HealthBar then objects.HealthBar.Visible = false end
            if objects.HealthBarBG then objects.HealthBarBG.Visible = false end
        end
    end
end

-- ============================================
-- K1LL 4UR4 L0G1C - F1X3D
-- ============================================
local KillAuraConnection = nil

local function StartKillAura()
    if KillAuraConnection then return end
    
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not Settings.KillAura_Enabled then return end
        
        local localChar = GetCharacter(LocalPlayer)
        if not localChar then return end
        
        local localHRP = GetRootPart(localChar)
        if not localHRP then return end
        
        -- G3t 4ct1v3 t00l (w34p0n)
        local activeTool = nil
        for _, child in ipairs(localChar:GetChildren()) do
            if child:IsA("Tool") then
                activeTool = child
                break
            end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not IsHider(player) then continue end
            
            local character = GetCharacter(player)
            if not character then continue end
            
            local hrp = GetRootPart(character)
            local humanoid = GetHumanoid(character)
            if not hrp or not humanoid then continue end
            
            local distance = (hrp.Position - localHRP.Position).Magnitude
            if distance <= Settings.KillAura_Radius then
                -- M3th0d 1: D1r3ct hum4n01d d4m4g3
                pcall(function()
                    humanoid:TakeDamage(100)
                end)
                
                -- M3th0d 2: F1r3 t0uch 1nt3r3st w1th l0c4l pl4y3r p4rt5
                pcall(function()
                    for _, part in ipairs(localChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            firetouchinterest(part, hrp, 0)
                            task.wait(0.03)
                            firetouchinterest(part, hrp, 1)
                        end
                    end
                end)
                
                -- M3th0d 3: F1r3 t0uch w1th t00l h4ndl3
                if activeTool then
                    pcall(function()
                        local handle = activeTool:FindFirstChild("Handle")
                        if handle then
                            firetouchinterest(handle, hrp, 0)
                            task.wait(0.03)
                            firetouchinterest(handle, hrp, 1)
                        end
                    end)
                end
                
                -- M3th0d 4: T3l3p0rt t00l t0 h1d3r
                if activeTool then
                    pcall(function()
                        local handle = activeTool:FindFirstChild("Handle")
                        if handle then
                            local oldCFrame = handle.CFrame
                            handle.CFrame = hrp.CFrame
                            task.wait(0.05)
                            handle.CFrame = oldCFrame
                        end
                    end)
                end
            end
            
            task.wait(Settings.KillAura_Delay)
        end
    end)
end

-- ============================================
-- T3L3P0RT T0 H1D3R L0G1C - F1X3D
-- ============================================
local TeleportHiderConnection = nil
local HiderList = {}
local CurrentHiderIndex = 1

local function UpdateHiderList()
    HiderList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsHider(player) then
            table.insert(HiderList, player)
        end
    end
end

local function StartTeleportHider()
    if TeleportHiderConnection then return end
    
    TeleportHiderConnection = task.spawn(function()
        while true do
            if not Settings.TeleportHider_Enabled then
                task.wait(1)
                continue
            end
            
            UpdateHiderList()
            
            if #HiderList > 0 then
                CurrentHiderIndex = (CurrentHiderIndex % #HiderList) + 1
                local target = HiderList[CurrentHiderIndex]
                
                -- V3r1fy t4rg3t 1s st1ll v4l1d
                if target and target.Character and IsHider(target) then
                    local targetHRP = GetRootPart(target.Character)
                    local localChar = GetCharacter(LocalPlayer)
                    local localHRP = localChar and GetRootPart(localChar)
                    
                    if targetHRP and localHRP then
                        -- V3r1fy t4rg3t 1s n0t 1n sp4wn/h0m3
                        if targetHRP.Position.Y > -50 and targetHRP.Position.Y < 500 then
                            Settings.TeleportHider_Current = target.Name
                            -- T3l3p0rt w1th 0ffs3t t0 4v01d st4ck1ng
                            localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 4)
                        end
                    end
                end
            end
            
            task.wait(Settings.TeleportHider_Delay)
        end
    end)
end

-- ============================================
-- 4UT0 C01N C0LL3CT L0G1C - F1X3D
-- ============================================
local AutoCoinConnection = nil

local function FindCoins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            local name = obj.Name:lower()
            -- Br04d3r c01n d3t3ct10n
            if name:match("coin") or name:match("money") or name:match("gold") or 
               name:match("cash") or name:match("collect") or name:match("gem") or
               name:match("token") or name:match("point") or name:match("star") or
               name:match("reward") or name:match("drop") then
                
                -- SK1P 1f 1n sp4wn 4r34
                if obj.Position.Y > -50 and obj.Position.Y < 500 then
                    if obj:FindFirstChildWhichIsA("TouchInterest") or obj:FindFirstChild("TouchInterest") then
                        table.insert(coins, obj)
                    end
                end
            end
        end
    end
    return coins
end

local function StartAutoCoin()
    if AutoCoinConnection then return end
    
    AutoCoinConnection = task.spawn(function()
        while true do
            if not Settings.AutoCoin_Enabled then
                task.wait(1)
                continue
            end
            
            local coins = FindCoins()
            local localChar = GetCharacter(LocalPlayer)
            local localHRP = localChar and GetRootPart(localChar)
            
            if localHRP then
                for _, coin in ipairs(coins) do
                    if not Settings.AutoCoin_Enabled then break end
                    
                    -- SK1P 1f c01n 1s t00 f4r 0r 1n sp4wn
                    if coin and coin.Parent then
                        local dist = (coin.Position - localHRP.Position).Magnitude
                        if dist < 500 and coin.Position.Y > -50 and coin.Position.Y < 500 then
                            pcall(function()
                                -- T3l3p0rt t0 c01n
                                localHRP.CFrame = coin.CFrame
                                task.wait(0.1)
                                
                                -- F1r3 t0uch
                                firetouchinterest(localHRP, coin, 0)
                                task.wait(0.05)
                                firetouchinterest(localHRP, coin, 1)
                                
                                -- F1r3 t0uch w1th 4ll p4rt5
                                for _, part in ipairs(localChar:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        firetouchinterest(part, coin, 0)
                                        task.wait(0.02)
                                        firetouchinterest(part, coin, 1)
                                    end
                                end
                            end)
                        end
                    end
                    
                    task.wait(Settings.AutoCoin_Delay)
                end
            end
            
            task.wait(0.5)
        end
    end)
end

-- ============================================
-- PL4Y3R 3V3NT5
-- ============================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESPObjects(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESPObjects(player) end
end

-- ============================================
-- R3ND3R L00P
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
StartKillAura()
StartTeleportHider()
StartAutoCoin()

-- ============================================
-- M0D3RN UI + L04D1NG SCR33N 2026
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NX_" .. tostring(math.random(100000, 999999))
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- L04D1NG SCR33N - M0D3RN 2026
-- ============================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 1000
LoadingFrame.Parent = ScreenGui

-- 4n1m4t3d gr4d13nt b4ckgr0und
local LoadingGradient = Instance.new("UIGradient")
LoadingGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(15, 5, 30)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(5, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))
})
LoadingGradient.Rotation = 45
LoadingGradient.Parent = LoadingFrame

-- P4rt1cl3 3ff3ct (s1mul4t3d w1th fr4m3s)
for i = 1, 20 do
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    particle.BackgroundTransparency = math.random(3, 8) / 10
    particle.BorderSizePixel = 0
    particle.ZIndex = 1001
    particle.Parent = LoadingFrame
    
    local particleCorner = Instance.new("UICorner")
    particleCorner.CornerRadius = UDim.new(1, 0)
    particleCorner.Parent = particle
    
    -- 4n1m4t3 p4rt1cl3
    task.spawn(function()
        while particle and particle.Parent do
            local tween = TweenService:Create(particle, TweenInfo.new(math.random(2, 5)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(3, 9) / 10
            })
            tween:Play()
            task.wait(math.random(2, 5))
        end
    end)
end

-- L0g0/T1tl3
local LoadLogo = Instance.new("TextLabel")
LoadLogo.Size = UDim2.new(0, 500, 0, 60)
LoadLogo.Position = UDim2.new(0.5, -250, 0.35, 0)
LoadLogo.BackgroundTransparency = 1
LoadLogo.Text = "N4n0Xy1n"
LoadLogo.TextColor3 = Color3.fromRGB(0, 255, 255)
LoadLogo.TextSize = 48
LoadLogo.Font = Enum.Font.GothamBlack
LoadLogo.Parent = LoadingFrame

-- Gl0w 3ff3ct
local LoadLogoGlow = Instance.new("TextLabel")
LoadLogoGlow.Size = UDim2.new(0, 500, 0, 60)
LoadLogoGlow.Position = UDim2.new(0.5, -248, 0.35, 2)
LoadLogoGlow.BackgroundTransparency = 1
LoadLogoGlow.Text = "N4n0Xy1n"
LoadLogoGlow.TextColor3 = Color3.fromRGB(0, 255, 255)
LoadLogoGlow.TextSize = 48
LoadLogoGlow.Font = Enum.Font.GothamBlack
LoadLogoGlow.TextTransparency = 0.7
LoadLogoGlow.Parent = LoadingFrame

-- Subt1tl3
local LoadSub = Instance.new("TextLabel")
LoadSub.Size = UDim2.new(0, 500, 0, 25)
LoadSub.Position = UDim2.new(0.5, -250, 0.42, 0)
LoadSub.BackgroundTransparency = 1
LoadSub.Text = "Xy1nESP v3.0 // プレイヤーESP // Игрок ESP"
LoadSub.TextColor3 = Color3.fromRGB(150, 150, 170)
LoadSub.TextSize = 13
LoadSub.Font = Enum.Font.Gotham
LoadSub.Parent = LoadingFrame

-- V3r510n
local LoadVersion = Instance.new("TextLabel")
LoadVersion.Size = UDim2.new(0, 200, 0, 20)
LoadVersion.Position = UDim2.new(0.5, -100, 0.46, 0)
LoadVersion.BackgroundTransparency = 1
LoadVersion.Text = "by @RukanooXD_YT"
LoadVersion.TextColor3 = Color3.fromRGB(0, 200, 255)
LoadVersion.TextSize = 11
LoadVersion.Font = Enum.Font.GothamBold
LoadVersion.Parent = LoadingFrame

-- L04d1ng B4r C0nt41n3r
local LoadBarContainer = Instance.new("Frame")
LoadBarContainer.Size = UDim2.new(0, 350, 0, 8)
LoadBarContainer.Position = UDim2.new(0.5, -175, 0.55, 0)
LoadBarContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
LoadBarContainer.BorderSizePixel = 0
LoadBarContainer.ZIndex = 1002
LoadBarContainer.Parent = LoadingFrame

local LoadBarContainerCorner = Instance.new("UICorner")
LoadBarContainerCorner.CornerRadius = UDim.new(0, 4)
LoadBarContainerCorner.Parent = LoadBarContainer

-- L04d1ng B4r F1ll
local LoadBarFill = Instance.new("Frame")
LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
LoadBarFill.BorderSizePixel = 0
LoadBarFill.ZIndex = 1003
LoadBarFill.Parent = LoadBarContainer

local LoadBarFillCorner = Instance.new("UICorner")
LoadBarFillCorner.CornerRadius = UDim.new(0, 4)
LoadBarFillCorner.Parent = LoadBarFill

-- L04d1ng B4r Gl0w
local LoadBarGlow = Instance.new("Frame")
LoadBarGlow.Size = UDim2.new(0, 0, 1, 0)
LoadBarGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
LoadBarGlow.BackgroundTransparency = 0.5
LoadBarGlow.BorderSizePixel = 0
LoadBarGlow.ZIndex = 1002
LoadBarGlow.Parent = LoadBarContainer

local LoadBarGlowCorner = Instance.new("UICorner")
LoadBarGlowCorner.CornerRadius = UDim.new(0, 4)
LoadBarGlowCorner.Parent = LoadBarGlow

-- L04d1ng P3rc3nt
local LoadPercent = Instance.new("TextLabel")
LoadPercent.Size = UDim2.new(0, 100, 0, 25)
LoadPercent.Position = UDim2.new(0.5, -50, 0.57, 5)
LoadPercent.BackgroundTransparency = 1
LoadPercent.Text = "0%"
LoadPercent.TextColor3 = Color3.fromRGB(0, 255, 255)
LoadPercent.TextSize = 16
LoadPercent.Font = Enum.Font.GothamBlack
LoadPercent.Parent = LoadingFrame

-- L04d1ng St4tus
local LoadStatus = Instance.new("TextLabel")
LoadStatus.Size = UDim2.new(0, 400, 0, 20)
LoadStatus.Position = UDim2.new(0.5, -200, 0.62, 0)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "Initializing..."
LoadStatus.TextColor3 = Color3.fromRGB(100, 100, 120)
LoadStatus.TextSize = 11
LoadStatus.Font = Enum.Font.Gotham
LoadStatus.Parent = LoadingFrame

-- 4n1m4t3 l04d1ng
task.spawn(function()
    local stages = {
        {pct = 15, text = "Initializing Core..."},
        {pct = 30, text = "Loading ESP Module..."},
        {pct = 45, text = "Loading Combat Module..."},
        {pct = 60, text = "Loading Teleport Module..."},
        {pct = 75, text = "Loading Auto Collect..."},
        {pct = 85, text = "Building UI..."},
        {pct = 95, text = "Finalizing..."},
        {pct = 100, text = "Ready!"},
    }
    
    local currentPct = 0
    for _, stage in ipairs(stages) do
        while currentPct < stage.pct do
            currentPct = currentPct + math.random(1, 3)
            if currentPct > stage.pct then currentPct = stage.pct end
            
            LoadBarFill.Size = UDim2.new(currentPct / 100, 0, 1, 0)
            LoadBarGlow.Size = UDim2.new(currentPct / 100, 0, 1, 0)
            LoadPercent.Text = currentPct .. "%"
            LoadStatus.Text = stage.text
            
            task.wait(0.05)
        end
        task.wait(0.2)
    end
    
    task.wait(0.5)
    
    -- F4d3 0ut l04d1ng
    local fadeTween = TweenService:Create(LoadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
    fadeTween:Play()
    
    for _, child in pairs(LoadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            local t = TweenService:Create(child, TweenInfo.new(0.8), {TextTransparency = 1, BackgroundTransparency = 1})
            t:Play()
        end
    end
    
    task.wait(1.2)
    LoadingFrame:Destroy()
end)

-- ============================================
-- M41N M3NU - M0D3RN D3S1GN 2026
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- Gr4d13nt b4ckgr0und
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 22)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 12, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 22))
})
MainGradient.Rotation = 135
MainGradient.Parent = MainFrame

-- Sh4d0w
local MainShadow = Instance.new("ImageLabel")
MainShadow.Size = UDim2.new(1, 50, 1, 50)
MainShadow.Position = UDim2.new(0, -25, 0, -25)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://5554236805"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.4
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(23, 23, 277, 277)
MainShadow.ZIndex = -1
MainShadow.Parent = MainFrame

-- T1tl3 B4r
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 14)
TitleBarCorner.Parent = TitleBar

-- T1tl3 T3xt
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -100, 0, 25)
TitleText.Position = UDim2.new(0, 18, 0, 5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Xy1nESP v3.0"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(1, -100, 0, 15)
TitleSub.Position = UDim2.new(0, 18, 0, 28)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "プレイヤーESP // Игрок ESP"
TitleSub.TextColor3 = Color3.fromRGB(100, 100, 120)
TitleSub.TextSize = 9
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = TitleBar

-- M1n1m1z3 Bttn
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -72, 0, 9)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinBtn

-- Cl0s3 Bttn
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -36, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

-- T4b Syst3m
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 38)
TabFrame.Position = UDim2.new(0, 10, 0, 52)
TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabFrameCorner = Instance.new("UICorner")
TabFrameCorner.CornerRadius = UDim.new(0, 10)
TabFrameCorner.Parent = TabFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabFrame

local Tabs = {}
local TabContents = {}

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 95, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(130, 130, 150)
    TabBtn.TextSize = 10
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = TabFrame
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 8)
    TabBtnCorner.Parent = TabBtn
    
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "Content"
    Content.Size = UDim2.new(1, -20, 1, -105)
    Content.Position = UDim2.new(0, 10, 0, 95)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    Content.CanvasSize = UDim2.new(0, 0, 0, 700)
    Content.Visible = false
    Content.Parent = MainFrame
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content
    
    table.insert(Tabs, TabBtn)
    TabContents[name] = Content
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(Tabs) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            btn.TextColor3 = Color3.fromRGB(130, 130, 150)
        end
        for _, content in pairs(TabContents) do
            content.Visible = false
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Content.Visible = true
    end)
    
    return Content
end

local ESPContent = CreateTab("ESP", "👁️")
local CombatContent = CreateTab("Combat", "⚔️")
local MiscContent = CreateTab("Misc", "🛠️")

-- D3f4ult t4b
Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
ESPContent.Visible = true

-- ============================================
-- T0GGL3 CR34T0R - M0D3RN 2026
-- ============================================
local function CreateModernToggle(parent, text, settingKey, color, description)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    Frame.BorderSizePixel = 0
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, -10, 0, 22)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(0.6, -10, 0, 16)
        Desc.Position = UDim2.new(0, 12, 0, 28)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = Color3.fromRGB(90, 90, 110)
        Desc.TextSize = 9
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.Parent = Frame
    end
    
    -- T0ggl3 Sw1tch
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(0, 48, 0, 24)
    ToggleBG.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleBG.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = Frame
    
    local ToggleBGCorner = Instance.new("UICorner")
    ToggleBGCorner.CornerRadius = UDim.new(1, 0)
    ToggleBGCorner.Parent = ToggleBG
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBG
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle
    
    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Frame
    
    local function UpdateToggle()
        if Settings[settingKey] then
            TweenService:Create(ToggleBG, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = color or Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 26, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(ToggleBG, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        end
    end
    
    ClickArea.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        UpdateToggle()
    end)
    
    UpdateToggle()
    Frame.Parent = parent
    return Frame
end

-- ============================================
-- SL1D3R CR34T0R - M0D3RN
-- ============================================
local function CreateSlider(parent, text, settingKey, min, max, suffix)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    Frame.BorderSizePixel = 0
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, -10, 0, 22)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 22)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Settings[settingKey]) .. (suffix or "")
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -24, 0, 6)
    SliderBG.Position = UDim2.new(0, 12, 0, 38)
    SliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Frame
    
    local SliderBGCorner = Instance.new("UICorner")
    SliderBGCorner.CornerRadius = UDim.new(0, 3)
    SliderBGCorner.Parent = SliderBG
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Settings[settingKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 3)
    SliderFillCorner.Parent = SliderFill
    
    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 14, 0, 14)
    SliderKnob.Position = UDim2.new((Settings[settingKey] - min) / (max - min), -7, 0.5, -7)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnob.BorderSizePixel = 0
    SliderKnob.Parent = SliderBG
    
    local SliderKnobCorner = Instance.new("UICorner")
    SliderKnobCorner.CornerRadius = UDim.new(1, 0)
    SliderKnobCorner.Parent = SliderKnob
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 0, 30)
    SliderBtn.Position = UDim2.new(0, 0, 0, 25)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = Frame
    
    local dragging = false
    
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X - SliderBG.AbsolutePosition.X
            local scale = math.clamp(pos / SliderBG.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (scale * (max - min)))
            Settings[settingKey] = value
            SliderFill.Size = UDim2.new(scale, 0, 1, 0)
            SliderKnob.Position = UDim2.new(scale, -7, 0.5, -7)
            ValueLabel.Text = tostring(value) .. (suffix or "")
        end
    end)
    
    Frame.Parent = parent
    return Frame
end

-- ============================================
-- 3SP T4B C0NT3NT
-- ============================================
CreateModernToggle(ESPContent, "ESP Master", "ESP_Enabled", Color3.fromRGB(0, 255, 255), "Aktifkan semua ESP")
CreateModernToggle(ESPContent, "Line ESP", "Line_ESP", Color3.fromRGB(0, 200, 255), "Garis ke player")
CreateModernToggle(ESPContent, "Box ESP", "Box_ESP", Color3.fromRGB(255, 0, 255), "Kotak di sekitar player")
CreateModernToggle(ESPContent, "Name ESP", "Name_ESP", Color3.fromRGB(255, 255, 255), "Nama player")
CreateModernToggle(ESPContent, "Distance ESP", "Distance_ESP", Color3.fromRGB(255, 255, 0), "Jarak ke player")
CreateModernToggle(ESPContent, "Health ESP", "Health_ESP", Color3.fromRGB(0, 255, 100), "Health bar")
CreateModernToggle(ESPContent, "Team Check", "TeamCheck", Color3.fromRGB(255, 100, 100), "Sembunyikan tim sendiri")
CreateSlider(ESPContent, "Max Distance", "MaxDistance", 50, 2000, "m")

-- ============================================
-- C0MB4T T4B C0NT3NT
-- ============================================
CreateModernToggle(CombatContent, "Kill Aura", "KillAura_Enabled", Color3.fromRGB(255, 50, 50), "Auto attack hider // キルオーラ // Килл Аура")
CreateSlider(CombatContent, "Kill Aura Radius", "KillAura_Radius", 5, 50, " studs")
CreateSlider(CombatContent, "Kill Aura Delay", "KillAura_Delay", 0.05, 1, "s")

CreateModernToggle(CombatContent, "Teleport Hider", "TeleportHider_Enabled", Color3.fromRGB(255, 150, 0), "Teleport ke hider // テレポート // Телепорт")
CreateSlider(CombatContent, "Teleport Delay", "TeleportHider_Delay", 0.5, 5, "s")

-- ============================================
-- M1SC T4B C0NT3NT
-- ============================================
CreateModernToggle(MiscContent, "Auto Collect Coin", "AutoCoin_Enabled", Color3.fromRGB(255, 215, 0), "Auto ambil coin // コイン収集 // Сбор монет")
CreateSlider(MiscContent, "Coin Collect Delay", "AutoCoin_Delay", 0.1, 2, "s")

-- Dr4g B0x T0ggl3
local DragBoxToggle = Instance.new("TextButton")
DragBoxToggle.Size = UDim2.new(1, 0, 0, 45)
DragBoxToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
DragBoxToggle.Text = "🖱️ Drag Box Mode: OFF (Klik untuk aktifkan)"
DragBoxToggle.TextColor3 = Color3.fromRGB(130, 130, 150)
DragBoxToggle.TextSize = 11
DragBoxToggle.Font = Enum.Font.GothamBold
DragBoxToggle.Parent = MiscContent

local DragBoxCorner = Instance.new("UICorner")
DragBoxCorner.CornerRadius = UDim.new(0, 10)
DragBoxCorner.Parent = DragBoxToggle

local DragBoxEnabled = false
DragBoxToggle.MouseButton1Click:Connect(function()
    DragBoxEnabled = not DragBoxEnabled
    if DragBoxEnabled then
        DragBoxToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        DragBoxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DragBoxToggle.Text = "🖱️ Drag Box Mode: ON (Drag box ESP dengan mouse)"
    else
        DragBoxToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        DragBoxToggle.TextColor3 = Color3.fromRGB(130, 130, 150)
        DragBoxToggle.Text = "🖱️ Drag Box Mode: OFF (Klik untuk aktifkan)"
    end
end)

-- ============================================
-- DR4G M3NU L0G1C
-- ============================================
local draggingMenu = false
local dragStartMenu = nil
local startPosMenu = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true
        dragStartMenu = input.Position
        startPosMenu = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMenu
        MainFrame.Position = UDim2.new(startPosMenu.X.Scale, startPosMenu.X.Offset + delta.X, startPosMenu.Y.Scale, startPosMenu.Y.Offset + delta.Y)
    end
end)

-- ============================================
-- DR4G B0X 3SP L0G1C
-- ============================================
UserInputService.InputBegan:Connect(function(input)
    if not DragBoxEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingBox = true
        DragStartPos = input.Position
        BoxStartOffset = {X = BoxOffset.X, Y = BoxOffset.Y}
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingBox = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsDraggingBox and DragBoxEnabled and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStartPos
        BoxOffset.X = BoxStartOffset.X + delta.X
        BoxOffset.Y = BoxStartOffset.Y + delta.Y
    end
end)

-- ============================================
-- T0GGL3 M3NU BUTT0N - M0D3RN
-- ============================================
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Name = "MenuToggle"
ToggleMenuBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleMenuBtn.Position = UDim2.new(0, 18, 0.5, -27)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
ToggleMenuBtn.Text = "👁️"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleMenuBtn.TextSize = 26
ToggleMenuBtn.Font = Enum.Font.GothamBlack
ToggleMenuBtn.Parent = ScreenGui

local MenuBtnCorner = Instance.new("UICorner")
MenuBtnCorner.CornerRadius = UDim.new(0, 14)
MenuBtnCorner.Parent = ToggleMenuBtn

local MenuBtnStroke = Instance.new("UIStroke")
MenuBtnStroke.Color = Color3.fromRGB(0, 255, 255)
MenuBtnStroke.Thickness = 2
MenuBtnStroke.Parent = ToggleMenuBtn

-- Gl0w 3ff3ct
local MenuBtnGlow = Instance.new("ImageLabel")
MenuBtnGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
MenuBtnGlow.Position = UDim2.new(-0.3, 0, -0.3, 0)
MenuBtnGlow.BackgroundTransparency = 1
MenuBtnGlow.Image = "rbxassetid://10822646370"
MenuBtnGlow.ImageColor3 = Color3.fromRGB(0, 255, 255)
MenuBtnGlow.ImageTransparency = 0.7
MenuBtnGlow.Parent = ToggleMenuBtn

-- Puls3 4n1m4t10n
task.spawn(function()
    while ToggleMenuBtn and ToggleMenuBtn.Parent do
        local tween = TweenService:Create(MenuBtnGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.4
        })
        tween:Play()
        task.wait(1.5)
        
        local tween2 = TweenService:Create(MenuBtnGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.8
        })
        tween2:Play()
        task.wait(1.5)
    end
end)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        MenuBtnStroke.Color = Color3.fromRGB(0, 255, 150)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 340, 0, 480)})
        tween:Play()
    else
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
        MenuBtnStroke.Color = Color3.fromRGB(0, 255, 255)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    MenuBtnStroke.Color = Color3.fromRGB(0, 255, 255)
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    MenuBtnStroke.Color = Color3.fromRGB(0, 255, 255)
end)

-- ============================================
-- K3YB04RD SH0RTCUT5
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        else
            ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.ESP_Enabled = not Settings.ESP_Enabled
    end
    
    if input.KeyCode == Enum.KeyCode.Home then
        Settings.KillAura_Enabled = not Settings.KillAura_Enabled
    end
    
    if input.KeyCode == Enum.KeyCode.PageUp then
        Settings.TeleportHider_Enabled = not Settings.TeleportHider_Enabled
    end
    
    if input.KeyCode == Enum.KeyCode.End then
        Settings.AutoCoin_Enabled = not Settings.AutoCoin_Enabled
    end
end)

-- ============================================
-- 4NT1-D3T3CT10N
-- ============================================
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FindFirstChild" or method == "WaitForChild" then
                local args = {...}
                if args[1] and (args[1]:match("ESP") or args[1]:match("NanoXyin") or args[1]:match("Xyin")) then
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

-- ============================================
-- N4n0Xy1n Xy1nESP v3.0 - F1X3D G4C0R K1NG
-- @RukanooXD_YT // Pembuat Script
-- L4njut4n d4r1 k0d3 y4ng t3rp0t0ng
-- ============================================

-- (K0D3 S3B3LUMNY4 S4M4, L4NJUT D4R1 N0T1F1C4T10N)

-- ============================================
-- N0T1F1C4T10N 0N L04D - L4NJUT4N
-- ============================================
task.delay(4, function()
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 380, 0, 70)
    NotifFrame.Position = UDim2.new(0.5, -190, 0, -80)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 12)
    NotifCorner.Parent = NotifFrame
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(0, 255, 255)
    NotifStroke.Thickness = 1
    NotifStroke.Parent = NotifFrame
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -20, 0.4, 0)
    NotifText.Position = UDim2.new(0, 10, 0, 8)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = "Xy1nESP v3.0 G4C0R K1NG Aktif!"
    NotifText.TextColor3 = Color3.fromRGB(0, 255, 255)
    NotifText.TextSize = 15
    NotifText.Font = Enum.Font.GothamBlack
    NotifText.Parent = NotifFrame
    
    local NotifSub = Instance.new("TextLabel")
    NotifSub.Size = UDim2.new(1, -20, 0.35, 0)
    NotifSub.Position = UDim2.new(0, 10, 0.4, 2)
    NotifSub.BackgroundTransparency = 1
    NotifSub.Text = "by @RukanooXD_YT | ロード完了 | Загружено"
    NotifSub.TextColor3 = Color3.fromRGB(0, 200, 255)
    NotifSub.TextSize = 11
    NotifSub.Font = Enum.Font.GothamBold
    NotifSub.Parent = NotifFrame
    
    local NotifKeys = Instance.new("TextLabel")
    NotifKeys.Size = UDim2.new(1, -20, 0.25, 0)
    NotifKeys.Position = UDim2.new(0, 10, 0.7, 0)
    NotifKeys.BackgroundTransparency = 1
    NotifKeys.Text = "R1ghtAlt: M3nu | 1ns3rt: ESP | H0m3: K1ll 4ur4 | PgUp: T3l3p0rt | 3nd: C01n"
    NotifKeys.TextColor3 = Color3.fromRGB(150, 150, 150)
    NotifKeys.TextSize = 9
    NotifKeys.Font = Enum.Font.Gotham
    NotifKeys.Parent = NotifFrame
    
    -- Sl1d3 1n w1th 4n1m4t10n
    NotifFrame:TweenPosition(UDim2.new(0.5, -190, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6)
    
    task.delay(6, function()
        NotifFrame:TweenPosition(UDim2.new(0.5, -190, 0, -80), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5)
        task.wait(0.6)
        NotifFrame:Destroy()
    end)
end)

-- ============================================
-- 4DD1T10N4L F1X: S33K3R S3LF-D3T3CT10N
-- ============================================
-- F1x: K4l4u l0c4l pl4y3r 4d4l4h s33k3r, j4ng4n t4g s3b4g41 h1d3r
local function AmISeeker()
    local myRole = GetPlayerRole(LocalPlayer)
    return myRole == "Seeker"
end

local function AmIHider()
    local myRole = GetPlayerRole(LocalPlayer)
    return myRole == "Hider"
end

-- ============================================
-- F1X3D K1LL 4UR4: H4NY4 T4RG3T H1D3R Y4NG H1DUP
-- ============================================
local function FixedKillAura()
    if KillAuraConnection then return end
    
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not Settings.KillAura_Enabled then return end
        if AmIHider() then return end -- H1d3r g4 b1s4 p4k41 k1ll 4ur4
        
        local localChar = GetCharacter(LocalPlayer)
        if not localChar then return end
        
        local localHRP = GetRootPart(localChar)
        if not localHRP then return end
        
        local activeTool = nil
        for _, child in ipairs(localChar:GetChildren()) do
            if child:IsA("Tool") then
                activeTool = child
                break
            end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            -- SK1P 1f n0t h1d3r 0r d34d 0r 1n sp4wn
            if not IsHider(player) then continue end
            
            local character = GetCharacter(player)
            if not character then continue end
            
            local hrp = GetRootPart(character)
            local humanoid = GetHumanoid(character)
            if not hrp or not humanoid then continue end
            
            local distance = (hrp.Position - localHRP.Position).Magnitude
            if distance <= Settings.KillAura_Radius then
                -- F1r3 4ll m3th0d5
                pcall(function() humanoid:TakeDamage(100) end)
                
                pcall(function()
                    for _, part in ipairs(localChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            firetouchinterest(part, hrp, 0)
                            task.wait(0.02)
                            firetouchinterest(part, hrp, 1)
                        end
                    end
                end)
                
                if activeTool then
                    pcall(function()
                        local handle = activeTool:FindFirstChild("Handle")
                        if handle then
                            firetouchinterest(handle, hrp, 0)
                            task.wait(0.02)
                            firetouchinterest(handle, hrp, 1)
                        end
                    end)
                end
            end
            
            task.wait(Settings.KillAura_Delay)
        end
    end)
end

-- ============================================
-- F1X3D T3L3P0RT: H4NY4 H1D3R Y4NG H1DUP D4N 1N G4M3
-- ============================================
local function FixedTeleportHider()
    if TeleportHiderConnection then return end
    
    TeleportHiderConnection = task.spawn(function()
        while true do
            if not Settings.TeleportHider_Enabled then
                task.wait(1)
                continue
            end
            
            -- SK1P 1f h1d3r
            if AmIHider() then
                task.wait(1)
                continue
            end
            
            UpdateHiderList()
            
            if #HiderList > 0 then
                CurrentHiderIndex = (CurrentHiderIndex % #HiderList) + 1
                local target = HiderList[CurrentHiderIndex]
                
                -- D0ubl3 ch3ck t4rg3t 1s st1ll v4l1d
                if target and target.Character and IsHider(target) and IsPlayerAlive(target) and IsPlayerInGame(target) then
                    local targetHRP = GetRootPart(target.Character)
                    local localChar = GetCharacter(LocalPlayer)
                    local localHRP = localChar and GetRootPart(localChar)
                    
                    if targetHRP and localHRP then
                        -- V3r1fy t4rg3t 1s n0t 1n sp4wn/h0m3 4r34
                        local targetY = targetHRP.Position.Y
                        if targetY > -50 and targetY < 500 then
                            Settings.TeleportHider_Current = target.Name
                            localHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-2, 2), 0, math.random(3, 5))
                        end
                    end
                end
            end
            
            task.wait(Settings.TeleportHider_Delay)
        end
    end)
end

-- ============================================
-- F1X3D 4UT0 C01N: SK1P C01N D1 SP4WN
-- ============================================
local function FixedAutoCoin()
    if AutoCoinConnection then return end
    
    AutoCoinConnection = task.spawn(function()
        while true do
            if not Settings.AutoCoin_Enabled then
                task.wait(1)
                continue
            end
            
            local coins = FindCoins()
            local localChar = GetCharacter(LocalPlayer)
            local localHRP = localChar and GetRootPart(localChar)
            
            if localHRP then
                for _, coin in ipairs(coins) do
                    if not Settings.AutoCoin_Enabled then break end
                    
                    if coin and coin.Parent then
                        local coinY = coin.Position.Y
                        local dist = (coin.Position - localHRP.Position).Magnitude
                        
                        -- SK1P c01n 1n sp4wn 0r t00 f4r
                        if dist < 300 and coinY > -50 and coinY < 500 then
                            pcall(function()
                                -- T3l3p0rt t0 c01n
                                localHRP.CFrame = coin.CFrame
                                task.wait(0.1)
                                
                                -- F1r3 t0uch w1th mult1pl3 p4rt5
                                firetouchinterest(localHRP, coin, 0)
                                task.wait(0.03)
                                firetouchinterest(localHRP, coin, 1)
                                
                                for _, part in ipairs(localChar:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        firetouchinterest(part, coin, 0)
                                        task.wait(0.01)
                                        firetouchinterest(part, coin, 1)
                                    end
                                end
                            end)
                        end
                    end
                    
                    task.wait(Settings.AutoCoin_Delay)
                end
            end
            
            task.wait(0.5)
        end
    end)
end

-- ============================================
-- 4DD1T10N4L: 4UT0 T4G H1D3R (F0R S33K3R)
-- ============================================
Settings.AutoTag_Enabled = false

local function AutoTagHider()
    task.spawn(function()
        while true do
            if not Settings.AutoTag_Enabled then
                task.wait(1)
                continue
            end
            
            if AmIHider() then
                task.wait(1)
                continue
            end
            
            local localChar = GetCharacter(LocalPlayer)
            local localHRP = localChar and GetRootPart(localChar)
            if not localHRP then continue end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not IsHider(player) then continue end
                
                local character = GetCharacter(player)
                if not character then continue end
                
                local hrp = GetRootPart(character)
                if not hrp then continue end
                
                local dist = (hrp.Position - localHRP.Position).Magnitude
                if dist <= 8 then
                    -- T3l3p0rt r1ght 0n t0p 0f h1d3r t0 t4g
                    pcall(function()
                        localHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 0)
                    end)
                end
            end
            
            task.wait(0.1)
        end
    end)
end

-- ============================================
-- 4DD1T10N4L: H1D3R W4RN1NG (F0R H1D3R)
-- ============================================
Settings.SeekerWarning_Enabled = false

local function SeekerWarning()
    local WarningText = CreateDrawing("Text", {
        Text = "",
        Size = 24,
        Center = true,
        Outline = true,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 1,
        Visible = false,
        ZIndex = 10
    })
    
    RunService.RenderStepped:Connect(function()
        if not Settings.SeekerWarning_Enabled then
            WarningText.Visible = false
            return
        end
        
        if AmISeeker() then
            WarningText.Visible = false
            return
        end
        
        local localChar = GetCharacter(LocalPlayer)
        local localHRP = localChar and GetRootPart(localChar)
        if not localHRP then return end
        
        local nearestSeeker = nil
        local nearestDist = math.huge
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not IsSeeker(player) then continue end
            
            local character = GetCharacter(player)
            if not character then continue end
            
            local hrp = GetRootPart(character)
            if not hrp then continue end
            
            local dist = (hrp.Position - localHRP.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestSeeker = player
            end
        end
        
        if nearestSeeker and nearestDist < 50 then
            WarningText.Text = "⚠️ S33K3R N34RBY! " .. math.floor(nearestDist) .. "m ⚠️"
            WarningText.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 100)
            WarningText.Visible = true
            
            -- Fl4sh 3ff3ct
            local flash = math.abs(math.sin(tick() * 5))
            WarningText.Color = Color3.fromRGB(255, 255 * flash, 0)
        else
            WarningText.Visible = false
        end
    end)
end

-- ============================================
-- 1N1T14L1Z3 4DD1T10N4L F34TUR35
-- ============================================
AutoTagHider()
SeekerWarning()

-- ============================================
-- M0R53 C0D3 F1N4L
-- ============================================
print("[N4n0Xy1n] Xy1nESP v3.0 F1X3D G4C0R K1NG")
print("[N4n0Xy1n] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")
print("[N4n0Xy1n] プレイヤーESP v3.0 修正完了")
print("[N4n0Xy1n] Игрок ESP v3.0 исправлено")
print("[N4n0Xy1n] @RukanooXD_YT")
print("[N4n0Xy1n] K1ll 4ur4: F1X3D")
print("[N4n0Xy1n] T3l3p0rt H1d3r: F1X3D")
print("[N4n0Xy1n] 4ut0 C01n: F1X3D")
print("[N4n0Xy1n] S33k3r D3t3ct10n: F1X3D")
print("[N4n0Xy1n] D34d Pl4y3r F1lt3r: F1X3D")
