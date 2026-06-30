-- ============================================
-- N4n0Xy1n Xy1nESP v5.0 - B&W 3D1T10N
-- @RukanooXD_YT // Pembuat Script
-- F34tur3s: ESP, K1ll 4ur4, T3l3p0rt, Byp4ss C01n,
-- Sp33d, Jump, 4ut0 S4f3, M0d3rn B&W UI
-- L4ngu4g3: 1nd0 + 3ngl15h + J4p4n353 + Ru5514n
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- D3V1C3 D3T3CT10N
-- ============================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScale = IsMobile and 0.85 or 1

-- ============================================
-- S3TT1NGS - B&W TH3M3
-- ============================================
local Settings = {
    -- ESP
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
    LineThickness = 1.5,
    BoxThickness = 1.5,
    -- C0l0r5 B&W
    LineColor = Color3.fromRGB(255, 255, 255),
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(200, 200, 200),
    DistanceColor = Color3.fromRGB(180, 180, 180),
    SeekerColor = Color3.fromRGB(255, 255, 255),
    HiderColor = Color3.fromRGB(150, 150, 150),
    DeadColor = Color3.fromRGB(80, 80, 80),
    -- C0mb4t
    KillAura_Enabled = false,
    KillAura_Radius = 25,
    KillAura_Delay = 0.05,
    FastKill = false,
    -- T3l3p0rt
    TeleportHider_Enabled = false,
    TeleportHider_Delay = 1.5,
    -- C01n Byp4ss
    AutoCoin_Enabled = false,
    AutoCoin_Delay = 0.1,
    CoinBypass = true,
    -- Sp33d & Jump
    SpeedHack = false,
    SpeedValue = 100,
    JumpHack = false,
    JumpValue = 150,
    -- 4ut0 S4f3
    AutoSafe = false,
    SafeHP = 30,
    SafeDistance = 50,
}

-- ============================================
-- DR4W1NG M4N4G3R
-- ============================================
local ESPObjects = {}

local function CreateDrawing(t, p)
    local d = Drawing.new(t)
    for k, v in pairs(p) do pcall(function() d[k] = v end) end
    return d
end

local function RemoveESP(p)
    if ESPObjects[p] then
        for _, o in pairs(ESPObjects[p]) do pcall(function() o:Remove() end) end
        ESPObjects[p] = nil
    end
end

local function CreateESPObjects(p)
    RemoveESP(p)
    ESPObjects[p] = {
        Line = CreateDrawing("Line", {Thickness = Settings.LineThickness, Color = Settings.LineColor, Transparency = 1, Visible = false, ZIndex = 1}),
        Box = CreateDrawing("Square", {Thickness = Settings.BoxThickness, Color = Settings.BoxColor, Transparency = 1, Filled = false, Visible = false, ZIndex = 2}),
        BoxFill = CreateDrawing("Square", {Thickness = 1, Color = Settings.BoxColor, Transparency = 0.1, Filled = true, Visible = false, ZIndex = 1}),
        Name = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.NameColor, Visible = false, ZIndex = 3}),
        Dist = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.DistanceColor, Visible = false, ZIndex = 3}),
        HP = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.HealthColor, Visible = false, ZIndex = 3}),
        HPBar = CreateDrawing("Line", {Thickness = 2, Color = Settings.HealthColor, Visible = false, ZIndex = 4}),
        HPBarBG = CreateDrawing("Line", {Thickness = 4, Color = Color3.fromRGB(30, 30, 30), Visible = false, ZIndex = 3}),
        RoleTag = CreateDrawing("Text", {Text = "", Size = Settings.TextSize + 1, Center = true, Outline = true, Visible = false, ZIndex = 5}),
    }
end

-- ============================================
-- PL4Y3R CH3CK5 - F1X3D R0L3 D3T3CT10N
-- ============================================
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetHRP(p)
    local c = p.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
end

-- F1X: R0l3 d3t3ct10n y4ng b3n4r
local function GetRole(p)
    local c = p.Character
    if not c then return "Unknown" end
    
    -- F1X: Ch3ck 4ttribut3s dulu
    if c:FindFirstChild("Seeker") or c:FindFirstChild("IsSeeker") then return "Seeker" end
    if c:FindFirstChild("Hider") or c:FindFirstChild("IsHider") then return "Hider" end
    
    -- Ch3ck f0ld3r5
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Folder") then
            local n = o.Name:lower()
            if (n:match("seeker") or n:match("hunter")) and o:FindFirstChild(p.Name) then return "Seeker" end
            if (n:match("hider") or n:match("hidden")) and o:FindFirstChild(p.Name) then return "Hider" end
        end
    end
    
    -- Ch3ck t34m
    if p.Team then
        local tn = p.Team.Name:lower()
        if tn:match("seeker") or tn:match("hunter") or tn:match("tagger") then return "Seeker" end
        if tn:match("hider") or tn:match("hidden") then return "Hider" end
    end
    
    -- Ch3ck l34d3rst4ts
    if p:FindFirstChild("leaderstats") then
        for _, s in ipairs(p.leaderstats:GetChildren()) do
            local sn = s.Name:lower()
            if sn:match("seeker") or sn:match("hunter") then
                if tonumber(s.Value) and tonumber(s.Value) > 0 then return "Seeker" end
            end
        end
    end
    
    -- Ch3ck t00l5/w34p0n (s33k3r h4v3 w34p0n)
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local tn = t.Name:lower()
                if tn:match("sword") or tn:match("bat") or tn:match("tag") or tn:match("seek") then return "Seeker" end
            end
        end
    end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local tn = t.Name:lower()
            if tn:match("sword") or tn:match("bat") or tn:match("tag") or tn:match("seek") then return "Seeker" end
        end
    end
    
    -- F1X: Ch3ck g4m3 t3xt l4b3l5 (s33k3r t4g)
    for _, g in ipairs(c:GetDescendants()) do
        if g:IsA("BillboardGui") or g:IsA("TextLabel") then
            local txt = ""
            pcall(function() txt = g.Text:lower() end)
            if txt:match("seeker") or txt:match("hunter") then return "Seeker" end
            if txt:match("hider") or txt:match("hidden") then return "Hider" end
        end
    end
    
    -- F1X: B4s3d 0n g4m3 st4t3 (ch3ck 1f pl4y3r c4n t4g 0th3r5)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        -- S33k3r5 0ft3n h4v3 h1gh3r w4lksp33d
        if hum.WalkSpeed > 30 then return "Seeker" end
    end
    
    -- D3f4ult: 1f l0c4l pl4y3r 1s s33k3r, 0th3r5 = h1d3r
    if p == LocalPlayer then
        -- Ch3ck 1f w3 h4v3 4 w34p0n
        local hasWeapon = false
        local bp2 = p:FindFirstChild("Backpack")
        if bp2 then
            for _, t in ipairs(bp2:GetChildren()) do
                if t:IsA("Tool") then hasWeapon = true break end
            end
        end
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then hasWeapon = true break end
        end
        if hasWeapon then return "Seeker" end
        return "Hider"
    end
    
    -- F0r 0th3r pl4y3r5: 1f l0c4l 1s s33k3r, th3y'r3 h1d3r
    local myRole = GetRole(LocalPlayer)
    if myRole == "Seeker" then return "Hider" end
    if myRole == "Hider" then return "Seeker" end
    
    return "Hider"
end

local function IsHider(p)
    return p ~= LocalPlayer and IsAlive(p) and GetRole(p) == "Hider"
end

local function IsSeeker(p)
    return p ~= LocalPlayer and IsAlive(p) and GetRole(p) == "Seeker"
end

local function AmISeeker()
    return GetRole(LocalPlayer) == "Seeker"
end

-- ============================================
-- 3SP UPD4T3
-- ============================================
local BoxOffset = {X = 0, Y = 0}

local function UpdateESP()
    if not Settings.ESP_Enabled then
        for _, o in pairs(ESPObjects) do
            for _, obj in pairs(o) do pcall(function() obj.Visible = false end) end
        end
        return
    end
    
    local lChar = LocalPlayer.Character
    local lHRP = lChar and GetHRP(LocalPlayer)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(p) then
            if ESPObjects[p] then
                for _, o in pairs(ESPObjects[p]) do pcall(function() o.Visible = false end) end
            end
            continue
        end
        
        local c = p.Character
        if not c then continue end
        local hrp = GetHRP(p)
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then continue end
        
        if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
        
        if lHRP then
            local d = (hrp.Position - lHRP.Position).Magnitude
            if d > Settings.MaxDistance then
                if ESPObjects[p] then
                    for _, o in pairs(ESPObjects[p]) do pcall(function() o.Visible = false end) end
                end
                continue
            end
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            if ESPObjects[p] then
                for _, o in pairs(ESPObjects[p]) do pcall(function() o.Visible = false end) end
            end
            continue
        end
        
        if not ESPObjects[p] then CreateESPObjects(p) end
        local o = ESPObjects[p]
        
        local role = GetRole(p)
        local hp = hum.Health
        local maxHp = hum.MaxHealth
        local hpPct = hp / maxHp
        
        local color = Settings.BoxColor
        if role == "Seeker" then color = Settings.SeekerColor
        elseif role == "Hider" then color = Settings.HiderColor end
        
        local cf, size = c:GetBoundingBox()
        if not cf then continue end
        
        local topY = cf.Position.Y + size.Y / 2
        local botY = cf.Position.Y - size.Y / 2
        local top = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, topY, cf.Position.Z))
        local bot = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, botY, cf.Position.Z))
        
        local h = math.abs(top.Y - bot.Y)
        local w = h * 0.55
        local bx = pos.X - w / 2 + BoxOffset.X
        local by = top.Y + BoxOffset.Y
        
        -- Line
        if Settings.Line_ESP and o.Line then
            local origin
            if Settings.LineOrigin == "Bottom" then origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Settings.LineOrigin == "Top" then origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
            else origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end
            o.Line.From = origin
            o.Line.To = Vector2.new(pos.X, pos.Y)
            o.Line.Color = Settings.LineColor
            o.Line.Visible = true
        else pcall(function() o.Line.Visible = false end) end
        
        -- Box
        if Settings.Box_ESP and o.Box and o.BoxFill then
            o.Box.Size = Vector2.new(w, h)
            o.Box.Position = Vector2.new(bx, by)
            o.Box.Color = color
            o.Box.Visible = true
            o.BoxFill.Size = Vector2.new(w, h)
            o.BoxFill.Position = Vector2.new(bx, by)
            o.BoxFill.Color = color
            o.BoxFill.Visible = true
        else
            pcall(function() o.Box.Visible = false end)
            pcall(function() o.BoxFill.Visible = false end)
        end
        
        -- Name
        if Settings.Name_ESP and o.Name then
            o.Name.Text = p.Name .. " [" .. role .. "]"
            o.Name.Position = Vector2.new(pos.X, top.Y - 18)
            o.Name.Color = role == "Seeker" and Settings.SeekerColor or Settings.NameColor
            o.Name.Visible = true
        else pcall(function() o.Name.Visible = false end) end
        
        -- Role
        if o.RoleTag then
            o.RoleTag.Text = role
            o.RoleTag.Position = Vector2.new(pos.X, top.Y - 32)
            o.RoleTag.Color = role == "Seeker" and Settings.SeekerColor or Settings.HiderColor
            o.RoleTag.Visible = true
        end
        
        -- Distance
        if Settings.Distance_ESP and o.Dist and lHRP then
            local d = math.floor((hrp.Position - lHRP.Position).Magnitude)
            o.Dist.Text = d .. "m"
            o.Dist.Position = Vector2.new(pos.X, bot.Y + 5)
            o.Dist.Visible = true
        else pcall(function() o.Dist.Visible = false end) end
        
        -- Health
        if Settings.Health_ESP and o.HP and o.HPBar and o.HPBarBG then
            o.HP.Text = math.floor(hp) .. "/" .. math.floor(maxHp)
            o.HP.Position = Vector2.new(pos.X, bot.Y + 18)
            o.HP.Visible = true
            local barX = bx - 5
            o.HPBarBG.From = Vector2.new(barX, by)
            o.HPBarBG.To = Vector2.new(barX, by + h)
            o.HPBarBG.Visible = true
            local hh = h * hpPct
            o.HPBar.From = Vector2.new(barX, by + h - hh)
            o.HPBar.To = Vector2.new(barX, by + h)
            if hpPct > 0.6 then o.HPBar.Color = Color3.fromRGB(200, 200, 200)
            elseif hpPct > 0.3 then o.HPBar.Color = Color3.fromRGB(150, 150, 150)
            else o.HPBar.Color = Color3.fromRGB(100, 100, 100) end
            o.HPBar.Visible = true
        else
            pcall(function() o.HP.Visible = false end)
            pcall(function() o.HPBar.Visible = false end)
            pcall(function() o.HPBarBG.Visible = false end)
        end
    end
end

-- ============================================
-- K1LL 4UR4 - F4ST R35P0N5
-- ============================================
local KillConn = nil

local function StartKillAura()
    if KillConn then return end
    KillConn = RunService.Heartbeat:Connect(function()
        if not Settings.KillAura_Enabled then return end
        if not AmISeeker() then return end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        if not lHRP then return end
        
        local tool = nil
        for _, c in ipairs(lChar:GetChildren()) do
            if c:IsA("Tool") then tool = c break end
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsHider(p) then continue end
            
            local c = p.Character
            local hrp = c and GetHRP(p)
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then continue end
            
            local dist = (hrp.Position - lHRP.Position).Magnitude
            if dist <= Settings.KillAura_Radius then
                -- F4st k1ll m3th0d5
                pcall(function() hum:TakeDamage(100) end)
                pcall(function() hum.Health = 0 end)
                
                pcall(function()
                    for _, part in ipairs(lChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            firetouchinterest(part, hrp, 0)
                            firetouchinterest(part, hrp, 1)
                        end
                    end
                end)
                
                if tool then
                    pcall(function()
                        local h = tool:FindFirstChild("Handle")
                        if h then
                            firetouchinterest(h, hrp, 0)
                            firetouchinterest(h, hrp, 1)
                            -- F4st r3sp0n53: t3l3p0rt h4ndl3 t0 t4rg3t
                            if Settings.FastKill then
                                local old = h.CFrame
                                h.CFrame = hrp.CFrame
                                task.wait(0.03)
                                h.CFrame = old
                            end
                        end
                    end)
                end
            end
            task.wait(Settings.KillAura_Delay)
        end
    end)
end

-- ============================================
-- 4UT0 S4F3 - K4BUR K4L0 HP R3ND4H
-- ============================================
local SafeConn = nil

local function StartAutoSafe()
    if SafeConn then return end
    SafeConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoSafe then return end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        local lHum = lChar and lChar:FindFirstChildOfClass("Humanoid")
        if not lHRP or not lHum then return end
        
        -- Ch3ck 1f HP r3nd4h
        if lHum.Health / lHum.MaxHealth * 100 <= Settings.SafeHP then
            -- F1nd n34r3st s33k3r
            local nearestSeeker = nil
            local nearestDist = math.huge
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                if not IsSeeker(p) then continue end
                
                local c = p.Character
                local hrp = c and GetHRP(p)
                if hrp then
                    local d = (hrp.Position - lHRP.Position).Magnitude
                    if d < nearestDist then
                        nearestDist = d
                        nearestSeeker = hrp
                    end
                end
            end
            
            -- K4bur d4r1 s33k3r
            if nearestSeeker and nearestDist < Settings.SafeDistance then
                local awayDir = (lHRP.Position - nearestSeeker.Position).Unit
                local safePos = lHRP.Position + awayDir * 30
                lHRP.CFrame = CFrame.new(safePos)
            end
        end
    end)
end

-- ============================================
-- SP33D & JUMP H4CK
-- ============================================
local SpeedConn = nil
local JumpConn = nil

local function StartSpeedHack()
    if SpeedConn then return end
    SpeedConn = RunService.Heartbeat:Connect(function()
        if not Settings.SpeedHack then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = math.clamp(Settings.SpeedValue, 16, 1000)
        end
    end)
end

local function StartJumpHack()
    if JumpConn then return end
    JumpConn = RunService.Heartbeat:Connect(function()
        if not Settings.JumpHack then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            h.JumpPower = math.clamp(Settings.JumpValue, 50, 300)
        end
    end)
end

-- ============================================
-- T3L3P0RT H1D3R
-- ============================================
local TPConn = nil
local HiderList = {}
local HiderIdx = 1

local function UpdateHiders()
    HiderList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsHider(p) then
            table.insert(HiderList, p)
        end
    end
end

local function StartTP()
    if TPConn then return end
    TPConn = task.spawn(function()
        while true do
            if not Settings.TeleportHider_Enabled then
                task.wait(1)
                continue
            end
            if not AmISeeker() then
                task.wait(1)
                continue
            end
            
            UpdateHiders()
            if #HiderList > 0 then
                HiderIdx = (HiderIdx % #HiderList) + 1
                local target = HiderList[HiderIdx]
                
                if target and target.Character and IsHider(target) then
                    local tHRP = GetHRP(target)
                    local lChar = LocalPlayer.Character
                    local lHRP = lChar and GetHRP(LocalPlayer)
                    
                    if tHRP and lHRP then
                        local ty = tHRP.Position.Y
                        if ty > -100 and ty < 500 then
                            lHRP.CFrame = tHRP.CFrame * CFrame.new(math.random(-2, 2), 0, 4)
                        end
                    end
                end
            end
            task.wait(Settings.TeleportHider_Delay)
        end
    end)
end

-- ============================================
-- 4UT0 C01N - BYP4SS T3L3P0RT
-- ============================================
local CoinConn = nil
local AllCoins = {}

local function ScanCoins()
    AllCoins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local n = obj.Name:lower()
            if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash") or 
               n:match("gem") or n:match("token") or n:match("collect") or n:match("point") or
               n:match("star") or n:match("reward") or n:match("drop") or n:match("pickup") then
                local y = obj.Position.Y
                if y > -100 and y < 500 then
                    table.insert(AllCoins, obj)
                end
            end
        end
    end
    return AllCoins
end

-- R34l-t1m3 c01n d3t3ct10n
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        local n = obj.Name:lower()
        if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash") or 
           n:match("gem") or n:match("token") or n:match("collect") then
            table.insert(AllCoins, obj)
        end
    end
end)

local function StartCoin()
    if CoinConn then return end
    CoinConn = task.spawn(function()
        while true do
            if not Settings.AutoCoin_Enabled then
                task.wait(1)
                continue
            end
            
            local coins = ScanCoins()
            local lChar = LocalPlayer.Character
            local lHRP = lChar and GetHRP(LocalPlayer)
            
            if lHRP then
                for _, coin in ipairs(coins) do
                    if not Settings.AutoCoin_Enabled then break end
                    if coin and coin.Parent then
                        local dist = (coin.Position - lHRP.Position).Magnitude
                        local cy = coin.Position.Y
                        if dist < 500 and cy > -100 and cy < 500 then
                            if Settings.CoinBypass then
                                -- BYP4SS: 1nst4nt c0ll3ct w1th0ut t3l3p0rt
                                pcall(function()
                                    -- F1r3 t0uch fr0m d1st4nc3
                                    firetouchinterest(lHRP, coin, 0)
                                    firetouchinterest(lHRP, coin, 1)
                                    
                                    -- F1r3 w1th 4ll b0dy p4rt5
                                    for _, part in ipairs(lChar:GetDescendants()) do
                                        if part:IsA("BasePart") then
                                            firetouchinterest(part, coin, 0)
                                            firetouchinterest(part, coin, 1)
                                        end
                                    end
                                    
                                    -- 4lt3rn4t3: m0v3 c01n t0 pl4y3r
                                    if coin:FindFirstChildWhichIsA("TouchInterest") then
                                        coin.CFrame = lHRP.CFrame
                                        task.wait(0.05)
                                    end
                                end)
                            else
                                -- N0rm4l t3l3p0rt m3th0d
                                pcall(function()
                                    lHRP.CFrame = coin.CFrame
                                    task.wait(0.1)
                                    firetouchinterest(lHRP, coin, 0)
                                    firetouchinterest(lHRP, coin, 1)
                                end)
                            end
                        end
                    end
                    task.wait(Settings.AutoCoin_Delay)
                end
            end
            task.wait(0.3)
        end
    end)
end

-- ============================================
-- PL4Y3R 3V3NT5
-- ============================================
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESPObjects(p)
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESPObjects(p) end
end

-- ============================================
-- 1N1T14L1Z3 4LL SYST3M5
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
StartKillAura()
StartAutoSafe()
StartSpeedHack()
StartJumpHack()
StartTP()
StartCoin()

-- ============================================
-- UI - B&W M0D3RN
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "XyinESP_" .. tostring(math.random(10000, 99999))
SG.Parent = CoreGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- L04D1NG SCR33N - B&W
-- ============================================
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG

local LG = Instance.new("UIGradient")
LG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
LG.Rotation = 45
LG.Parent = Loading

-- Particles B&W
for i = 1, 20 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    p.BackgroundTransparency = math.random(5, 9) / 10
    p.BorderSizePixel = 0
    p.ZIndex = 10000
    p.Parent = Loading
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        while p.Parent do
            TweenService:Create(p, TweenInfo.new(math.random(3, 6)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(5, 9) / 10
            }):Play()
            task.wait(math.random(3, 6))
        end
    end)
end

-- Logo B&W
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 500, 0, 60 * UIScale)
Logo.Position = UDim2.new(0.5, -250, 0.32, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "N4n0Xy1n"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 48 * UIScale
Logo.Font = Enum.Font.GothamBlack
Logo.ZIndex = 10001
Logo.Parent = Loading

local Glow = Instance.new("TextLabel")
Glow.Size = Logo.Size
Glow.Position = UDim2.new(0.5, -248, 0.32, 2)
Glow.BackgroundTransparency = 1
Glow.Text = "N4n0Xy1n"
Glow.TextColor3 = Color3.fromRGB(255, 255, 255)
Glow.TextSize = 48 * UIScale
Glow.Font = Enum.Font.GothamBlack
Glow.TextTransparency = 0.8
Glow.ZIndex = 10000
Glow.Parent = Loading

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 500, 0, 25 * UIScale)
Sub.Position = UDim2.new(0.5, -250, 0.4, 0)
Sub.BackgroundTransparency = 1
Sub.Text = "Xy1nESP v5.0 B&W // プレイヤーESP // Игрок ESP"
Sub.TextColor3 = Color3.fromRGB(150, 150, 150)
Sub.TextSize = 13 * UIScale
Sub.Font = Enum.Font.Gotham
Sub.ZIndex = 10001
Sub.Parent = Loading

local Auth = Instance.new("TextLabel")
Auth.Size = UDim2.new(0, 300, 0, 20 * UIScale)
Auth.Position = UDim2.new(0.5, -150, 0.44, 0)
Auth.BackgroundTransparency = 1
Auth.Text = "by @RukanooXD_YT"
Auth.TextColor3 = Color3.fromRGB(200, 200, 200)
Auth.TextSize = 11 * UIScale
Auth.Font = Enum.Font.GothamBold
Auth.ZIndex = 10001
Auth.Parent = Loading

-- Bar B&W
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 320 * UIScale, 0, 6)
BarBG.Position = UDim2.new(0.5, -160 * UIScale, 0.52, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 10001
BarBG.Parent = Loading
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 3)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10002
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 3)

local Pct = Instance.new("TextLabel")
Pct.Size = UDim2.new(0, 100, 0, 25 * UIScale)
Pct.Position = UDim2.new(0.5, -50, 0.55, 5)
Pct.BackgroundTransparency = 1
Pct.Text = "0%"
Pct.TextColor3 = Color3.fromRGB(255, 255, 255)
Pct.TextSize = 16 * UIScale
Pct.Font = Enum.Font.GothamBlack
Pct.ZIndex = 10001
Pct.Parent = Loading

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 400, 0, 20 * UIScale)
Status.Position = UDim2.new(0.5, -200, 0.6, 0)
Status.BackgroundTransparency = 1
Status.Text = "Initializing..."
Status.TextColor3 = Color3.fromRGB(100, 100, 100)
Status.TextSize = 11 * UIScale
Status.Font = Enum.Font.Gotham
Status.ZIndex = 10001
Status.Parent = Loading

-- Animate
task.spawn(function()
    local stages = {
        {pct = 10, txt = "Initializing Core..."},
        {pct = 25, txt = "Loading ESP Engine..."},
        {pct = 40, txt = "Loading Combat Systems..."},
        {pct = 55, txt = "Loading Speed & Jump..."},
        {pct = 70, txt = "Loading Auto Safe..."},
        {pct = 82, txt = "Building B&W UI..."},
        {pct = 92, txt = "Finalizing..."},
        {pct = 100, txt = "Ready!"},
    }
    
    local cur = 0
    for _, s in ipairs(stages) do
        while cur < s.pct do
            cur = cur + math.random(1, 4)
            if cur > s.pct then cur = s.pct end
            BarFill.Size = UDim2.new(cur / 100, 0, 1, 0)
            Pct.Text = cur .. "%"
            Status.Text = s.txt
            task.wait(0.04)
        end
        task.wait(0.15)
    end
    
    task.wait(0.6)
    
    for _, child in ipairs(Loading:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") and child ~= Loading then
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        end
    end
    
    TweenService:Create(Loading, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    task.wait(1)
    Loading:Destroy()
end)

-- ============================================
-- M41N M3NU - B&W GL4SSM0RPH15M
-- ============================================
local MenuSize = IsMobile and UDim2.new(0, 300, 0, 420) or UDim2.new(0, 380, 0, 520)
local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Glass = Instance.new("UIGradient")
Glass.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 12))
})
Glass.Rotation = 135
Glass.Parent = Main

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.Position = UDim2.new(0, -30, 0, -30)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

-- Title Bar
local Title = Instance.new("Frame")
Title.Size = UDim2.new(1, 0, 0, 52 * UIScale)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 16)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -110, 0, 26 * UIScale)
TitleText.Position = UDim2.new(0, 16, 0, 6)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Xy1nESP v5.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 17 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = Title

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(1, -110, 0, 16 * UIScale)
TitleSub.Position = UDim2.new(0, 16, 0, 30)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "プレイヤーESP // Игрок ESP"
TitleSub.TextColor3 = Color3.fromRGB(100, 100, 100)
TitleSub.TextSize = 9 * UIScale
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = Title

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -74, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Title
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -16, 0, 38 * UIScale)
TabFrame.Position = UDim2.new(0, 8, 0, 54)
TabFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main
Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 10)

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Padding = UDim.new(0, 6)
TabList.Parent = TabFrame

local Tabs = {}
local Contents = {}

local function MakeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90 * UIScale, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(120, 120, 120)
    btn.TextSize = 10 * UIScale
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name
    content.Size = UDim2.new(1, -16, 1, -108 * UIScale)
    content.Position = UDim2.new(0, 8, 0, 96 * UIScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 900)
    content.Visible = false
    content.Parent = Main
    
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)
    
    table.insert(Tabs, btn)
    Contents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.TextColor3 = Color3.fromRGB(120, 120, 120)
        end
        for _, c in pairs(Contents) do c.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        content.Visible = true
    end)
    
    return content
end

local ESPContent = MakeTab("ESP", "👁️")
local CombatContent = MakeTab("Combat", "⚔️")
local MiscContent = MakeTab("Misc", "🛠️")
local PlayerContent = MakeTab("Player", "🏃")

Tabs[1].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tabs[1].TextColor3 = Color3.fromRGB(0, 0, 0)
ESPContent.Visible = true

-- ============================================
-- T0GGL3 CR34T0R B&W
-- ============================================
local function MakeToggle(parent, text, key, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 58 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -10, 0, 24 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(235, 235, 235)
    lbl.TextSize = 13 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.6, -10, 0, 16 * UIScale)
        d.Position = UDim2.new(0, 14, 0, 30)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(80, 80, 80)
        d.TextSize = 9 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 50, 0, 26)
    bg.Position = UDim2.new(1, -62, 0.5, -13)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    circle.BorderSizePixel = 0
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = f
    
    local function Update()
        if Settings[key] then
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 26, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            }):Play()
        end
    end
    
    click.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        Update()
    end)
    
    Update()
    return f
end

-- ============================================
-- SL1D3R CR34T0R B&W
-- ============================================
local function MakeSlider(parent, text, key, min, max, suffix)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 62 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, -10, 0, 22 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(235, 235, 235)
    lbl.TextSize = 12 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.3, 0, 0, 22 * UIScale)
    val.Position = UDim2.new(0.7, 0, 0, 6)
    val.BackgroundTransparency = 1
    val.Text = tostring(Settings[key]) .. (suffix or "")
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.TextSize = 12 * UIScale
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = f
    
    local sbg = Instance.new("Frame")
    sbg.Size = UDim2.new(1, -28, 0, 6)
    sbg.Position = UDim2.new(0, 14, 0, 40 * UIScale)
    sbg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sbg.BorderSizePixel = 0
    sbg.Parent = f
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sbg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((Settings[key] - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sbg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 25)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = f
    
    local drag = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X - sbg.AbsolutePosition.X
            local scale = math.clamp(pos / sbg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + scale * (max - min))
            Settings[key] = value
            fill.Size = UDim2.new(scale, 0, 1, 0)
            knob.Position = UDim2.new(scale, -8, 0.5, -8)
            val.Text = tostring(value) .. (suffix or "")
        end
    end)
    
    return f
end

-- ============================================
-- 3SP T4B
-- ============================================
MakeToggle(ESPContent, "ESP Master", "ESP_Enabled", "Aktifkan semua ESP")
MakeToggle(ESPContent, "Line ESP", "Line_ESP", "Garis ke player")
MakeToggle(ESPContent, "Box ESP", "Box_ESP", "Kotak di sekitar player")
MakeToggle(ESPContent, "Name ESP", "Name_ESP", "Nama player")
MakeToggle(ESPContent, "Distance ESP", "Distance_ESP", "Jarak ke player")
MakeToggle(ESPContent, "Health ESP", "Health_ESP", "Health bar")
MakeToggle(ESPContent, "Team Check", "TeamCheck", "Sembunyikan tim")
MakeSlider(ESPContent, "Max Distance", "MaxDistance", 50, 2000, "m")

-- ============================================
-- C0MB4T T4B
-- ============================================
MakeToggle(CombatContent, "Kill Aura", "KillAura_Enabled", "Auto attack hider // キルオーラ // Килл Аура")
MakeToggle(CombatContent, "Fast Kill", "FastKill", "Kill instant with tool teleport")
MakeSlider(CombatContent, "Kill Aura Radius", "KillAura_Radius", 5, 50, " studs")
MakeSlider(CombatContent, "Kill Aura Delay", "KillAura_Delay", 0.01, 1, "s")
MakeToggle(CombatContent, "Teleport Hider", "TeleportHider_Enabled", "Teleport ke hider // テレポート // Телепорт")
MakeSlider(CombatContent, "Teleport Delay", "TeleportHider_Delay", 0.5, 5, "s")
MakeToggle(CombatContent, "Auto Safe", "AutoSafe", "Kabur kalau HP rendah")
MakeSlider(CombatContent, "Safe HP %", "SafeHP", 10, 80, "%")
MakeSlider(CombatContent, "Safe Distance", "SafeDistance", 20, 100, " studs")

-- ============================================
-- M1SC T4B
-- ============================================
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin_Enabled", "Auto ambil coin")
MakeToggle(MiscContent, "Coin Bypass TP", "CoinBypass", "Collect tanpa teleport")
MakeSlider(MiscContent, "Coin Delay", "AutoCoin_Delay", 0.05, 2, "s")

-- ============================================
-- PL4Y3R T4B - SP33D & JUMP
-- ============================================
MakeToggle(PlayerContent, "Speed Hack", "SpeedHack", "Lari cepat // スピード // Скорость")
MakeSlider(PlayerContent, "Speed Value", "SpeedValue", 16, 1000, "")
MakeToggle(PlayerContent, "Jump Hack", "JumpHack", "Lompat tinggi // ジャンプ // Прыжок")
MakeSlider(PlayerContent, "Jump Power", "JumpValue", 50, 300, "")

-- ============================================
-- DR4G M3NU
-- ============================================
local dragM = false
local dragSP = nil
local dragMP = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragM = true
        dragSP = input.Position
        dragMP = Main.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragM = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragM and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragSP
        Main.Position = UDim2.new(dragMP.X.Scale, dragMP.X.Offset + delta.X, dragMP.Y.Scale, dragMP.Y.Offset + delta.Y)
    end
end)

-- ============================================
-- T0GGL3 M3NU BUTT0N B&W
-- ============================================
local ToggleBtnSize = IsMobile and UDim2.new(0, 55, 0, 55) or UDim2.new(0, 50, 0, 50)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 18, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MenuBtn.Text = "👁️"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.TextSize = 26 * UIScale
MenuBtn.Font = Enum.Font.GothamBlack
MenuBtn.Parent = SG

Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 14)

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(255, 255, 255)
BtnStroke.Thickness = 2
BtnStroke.Parent = MenuBtn

local BtnGlow = Instance.new("ImageLabel")
BtnGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
BtnGlow.Position = UDim2.new(-0.3, 0, -0.3, 0)
BtnGlow.BackgroundTransparency = 1
BtnGlow.Image = "rbxassetid://10822646370"
BtnGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
BtnGlow.ImageTransparency =  0.7
BtnGlow.Parent = MenuBtn

task.spawn(function()
    while MenuBtn.Parent do
        TweenService:Create(BtnGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.4}):Play()
        task.wait(1.5)
        TweenService:Create(BtnGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.8}):Play()
        task.wait(1.5)
    end
end)

MenuBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        BtnStroke.Color = Color3.fromRGB(255, 255, 255)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = MenuSize}):Play()
    else
        MenuBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- ============================================
-- K3YB04RD SH0RTCUT5
-- ============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Main.Visible = not Main.Visible
        if Main.Visible then
            MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            MenuBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    if input.KeyCode == Enum.KeyCode.Insert then Settings.ESP_Enabled = not Settings.ESP_Enabled end
    if input.KeyCode == Enum.KeyCode.Home then Settings.KillAura_Enabled = not Settings.KillAura_Enabled end
    if input.KeyCode == Enum.KeyCode.PageUp then Settings.TeleportHider_Enabled = not Settings.TeleportHider_Enabled end
    if input.KeyCode == Enum.KeyCode.End then Settings.AutoCoin_Enabled = not Settings.AutoCoin_Enabled end
    if input.KeyCode == Enum.KeyCode.Delete then Settings.SpeedHack = not Settings.SpeedHack end
end)

-- ============================================
-- 4NT1-D3T3CT10N
-- ============================================
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "FindFirstChild" or m == "WaitForChild" then
                local a = {...}
                if a[1] and (a[1]:match("ESP") or a[1]:match("Xyin") or a[1]:match("Nano")) then
                    return nil
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

-- ============================================
-- N0T1F1C4T10N
-- ============================================
task.delay(5, function()
    local N = Instance.new("Frame")
    N.Size = UDim2.new(0, 380 * UIScale, 0, 75 * UIScale)
    N.Position = UDim2.new(0.5, -190 * UIScale, 0, -90)
    N.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    N.BorderSizePixel = 0
    N.Parent = SG
    
    Instance.new("UICorner", N).CornerRadius = UDim.new(0, 14)
    
    local NS = Instance.new("UIStroke")
    NS.Color = Color3.fromRGB(255, 255, 255)
    NS.Thickness = 1
    NS.Parent = N
    
    local NT = Instance.new("TextLabel")
    NT.Size = UDim2.new(1, -20, 0.35, 0)
    NT.Position = UDim2.new(0, 10, 0, 8)
    NT.BackgroundTransparency = 1
    NT.Text = "Xy1nESP v5.0 B&W G4C0R!"
    NT.TextColor3 = Color3.fromRGB(255, 255, 255)
    NT.TextSize = 14 * UIScale
    NT.Font = Enum.Font.GothamBlack
    NT.Parent = N
    
    local NA = Instance.new("TextLabel")
    NA.Size = UDim2.new(1, -20, 0.3, 0)
    NA.Position = UDim2.new(0, 10, 0.35, 2)
    NA.BackgroundTransparency = 1
    NA.Text = "by @RukanooXD_YT | 完了 | Готово"
    NA.TextColor3 = Color3.fromRGB(200, 200, 200)
    NA.TextSize = 11 * UIScale
    NA.Font = Enum.Font.GothamBold
    NA.Parent = N
    
    local NK = Instance.new("TextLabel")
    NK.Size = UDim2.new(1, -20, 0.35, 0)
    NK.Position = UDim2.new(0, 10, 0.65, 0)
    NK.BackgroundTransparency = 1
    NK.Text = "R1ghtAlt:M3nu | 1ns3rt:ESP | H0m3:K1ll | PgUp:TP | 3nd:C01n | D3l:Sp33d"
    NK.TextColor3 = Color3.fromRGB(120, 120, 120)
    NK.TextSize = 9 * UIScale
    NK.Font = Enum.Font.Gotham
    NK.Parent = N
    
    N:TweenPosition(UDim2.new(0.5, -190 * UIScale, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6)
    
    task.delay(6, function()
        N:TweenPosition(UDim2.new(0.5, -190 * UIScale, 0, -90), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5)
        task.wait(0.6)
        N:Destroy()
    end)
end)

-- ============================================
-- F1N4L PR1NT
-- ============================================
print("[N4n0Xy1n] Xy1nESP v5.0 B&W L04D3D")
print("[N4n0Xy1n] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")
print("[N4n0Xy1n] プレイヤーESP v5.0 B&W ロード完了")
print("[N4n0Xy1n] Игрок ESP v5.0 B&W загружен")
print("[N4n0Xy1n] @RukanooXD_YT")
print("[N4n0Xy1n] R0l3: " .. GetRole(LocalPlayer))
print("[N4n0Xy1n] D3v1c3: " .. (IsMobile and "M0b1l3" or "L4pt0p"))
