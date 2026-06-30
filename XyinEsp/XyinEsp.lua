-- ============================================
-- N4n0Xy1n Xy1nESP v4.0 - ULTRA F1X
-- @RukanooXD_YT // Pembuat Script
-- F34tur3s: ESP, K1ll 4ur4, T3l3p0rt, C01n, M0d3rn UI
-- R3sp0ns1v3: L4pt0p + M0b1l3/HP
-- L4ngu4g3: 1nd0 + 3ngl15h + J4p4n353 + Ru5514n
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- D3V1C3 D3T3CT10N
-- ============================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScale = IsMobile and 0.85 or 1
local MenuSize = IsMobile and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 360, 0, 500)
local ToggleBtnSize = IsMobile and UDim2.new(0, 55, 0, 55) or UDim2.new(0, 50, 0, 50)

-- ============================================
-- S3TT1NGS
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
    LineThickness = 1.5,
    BoxThickness = 1.5,
    KillAura_Enabled = false,
    KillAura_Radius = 20,
    KillAura_Delay = 0.1,
    TeleportHider_Enabled = false,
    TeleportHider_Delay = 2,
    AutoCoin_Enabled = false,
    AutoCoin_Delay = 0.5,
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
-- DR4W1NG M4N4G3R
-- ============================================
local ESPObjects = {}

local function CreateDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    return d
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function CreateESPObjects(player)
    RemoveESP(player)
    ESPObjects[player] = {
        Line = CreateDrawing("Line", {Thickness = Settings.LineThickness, Color = Settings.LineColor, Transparency = 1, Visible = false, ZIndex = 1}),
        Box = CreateDrawing("Square", {Thickness = Settings.BoxThickness, Color = Settings.BoxColor, Transparency = 1, Filled = false, Visible = false, ZIndex = 2}),
        BoxFill = CreateDrawing("Square", {Thickness = 1, Color = Settings.BoxColor, Transparency = 0.12, Filled = true, Visible = false, ZIndex = 1}),
        Name = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.NameColor, Visible = false, ZIndex = 3}),
        Dist = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.DistanceColor, Visible = false, ZIndex = 3}),
        HP = CreateDrawing("Text", {Text = "", Size = Settings.TextSize, Center = true, Outline = true, Color = Settings.HealthColor, Visible = false, ZIndex = 3}),
        HPBar = CreateDrawing("Line", {Thickness = 2, Color = Settings.HealthColor, Visible = false, ZIndex = 4}),
        HPBarBG = CreateDrawing("Line", {Thickness = 4, Color = Color3.fromRGB(40, 40, 40), Visible = false, ZIndex = 3}),
        RoleTag = CreateDrawing("Text", {Text = "", Size = Settings.TextSize + 1, Center = true, Outline = true, Visible = false, ZIndex = 5}),
    }
end

-- ============================================
-- PL4Y3R CH3CK5
-- ============================================
local function IsAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetHRP(player)
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function GetRole(player)
    local char = player.Character
    if not char then return "Unknown" end
    
    -- Check attributes
    if char:FindFirstChild("Seeker") or char:FindFirstChild("IsSeeker") then return "Seeker" end
    if char:FindFirstChild("Hider") or char:FindFirstChild("IsHider") then return "Hider" end
    
    -- Check folders
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Folder") then
            local n = obj.Name:lower()
            if (n:match("seeker") or n:match("hunter")) and obj:FindFirstChild(player.Name) then return "Seeker" end
            if (n:match("hider") or n:match("hidden")) and obj:FindFirstChild(player.Name) then return "Hider" end
        end
    end
    
    -- Check team
    if player.Team then
        local tn = player.Team.Name:lower()
        if tn:match("seeker") or tn:match("hunter") or tn:match("tagger") then return "Seeker" end
        if tn:match("hider") or tn:match("hidden") then return "Hider" end
    end
    
    -- Check tools
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local tname = tool.Name:lower()
                if tname:match("sword") or tname:match("bat") or tname:match("tag") then return "Seeker" end
            end
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local tname = tool.Name:lower()
            if tname:match("sword") or tname:match("bat") or tname:match("tag") then return "Seeker" end
        end
    end
    
    -- Check leaderstats
    if player:FindFirstChild("leaderstats") then
        for _, stat in ipairs(player.leaderstats:GetChildren()) do
            local sn = stat.Name:lower()
            if (sn:match("seeker") or sn:match("hunter")) and tonumber(stat.Value) > 0 then return "Seeker" end
        end
    end
    
    -- Default based on local player
    local myChar = LocalPlayer.Character
    if myChar then
        if myChar:FindFirstChild("Seeker") or myChar:FindFirstChild("IsSeeker") then return "Hider" end
        if myChar:FindFirstChild("Hider") or myChar:FindFirstChild("IsHider") then return "Seeker" end
    end
    
    return "Hider"
end

local function IsHider(player)
    return player ~= LocalPlayer and IsAlive(player) and GetRole(player) == "Hider"
end

local function IsSeeker(player)
    return player ~= LocalPlayer and IsAlive(player) and GetRole(player) == "Seeker"
end

local function AmISeeker()
    return GetRole(LocalPlayer) == "Seeker"
end

-- ============================================
-- 3SP UPD4T3 - F1X3D
-- ============================================
local BoxOffset = {X = 0, Y = 0}

local function UpdateESP()
    if not Settings.ESP_Enabled then
        for _, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    local localChar = LocalPlayer.Character
    local localHRP = localChar and GetHRP(LocalPlayer)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Skip dead
        if not IsAlive(player) then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    pcall(function() obj.Visible = false end)
                end
            end
            continue
        end
        
        local char = player.Character
        if not char then continue end
        
        local hrp = GetHRP(player)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then continue end
        
        -- Team check
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        -- Distance check
        if localHRP then
            local dist = (hrp.Position - localHRP.Position).Magnitude
            if dist > Settings.MaxDistance then
                if ESPObjects[player] then
                    for _, obj in pairs(ESPObjects[player]) do
                        pcall(function() obj.Visible = false end)
                    end
                end
                continue
            end
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    pcall(function() obj.Visible = false end)
                end
            end
            continue
        end
        
        if not ESPObjects[player] then CreateESPObjects(player) end
        local objs = ESPObjects[player]
        
        local role = GetRole(player)
        local hp = hum.Health
        local maxHp = hum.MaxHealth
        local hpPct = hp / maxHp
        
        -- Color
        local color = Settings.BoxColor
        if role == "Seeker" then color = Settings.SeekerColor
        elseif role == "Hider" then color = Settings.HiderColor end
        
        -- Bounding box
        local cf, size = char:GetBoundingBox()
        if not cf then continue end
        
        local topY = cf.Position.Y + size.Y / 2
        local botY = cf.Position.Y - size.Y / 2
        
        local top = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, topY, cf.Position.Z))
        local bot = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, botY, cf.Position.Z))
        
        local h = math.abs(top.Y - bot.Y)
        local w = h * 0.55
        
        local bx = pos.X - w / 2 + BoxOffset.X
        local by = top.Y + BoxOffset.Y
        
        -- Line ESP
        if Settings.Line_ESP and objs.Line then
            local origin
            if Settings.LineOrigin == "Bottom" then origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Settings.LineOrigin == "Top" then origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
            else origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end
            
            objs.Line.From = origin
            objs.Line.To = Vector2.new(pos.X, pos.Y)
            objs.Line.Color = Settings.LineColor
            objs.Line.Visible = true
        else
            pcall(function() objs.Line.Visible = false end)
        end
        
        -- Box ESP
        if Settings.Box_ESP and objs.Box and objs.BoxFill then
            objs.Box.Size = Vector2.new(w, h)
            objs.Box.Position = Vector2.new(bx, by)
            objs.Box.Color = color
            objs.Box.Visible = true
            
            objs.BoxFill.Size = Vector2.new(w, h)
            objs.BoxFill.Position = Vector2.new(bx, by)
            objs.BoxFill.Color = color
            objs.BoxFill.Visible = true
        else
            pcall(function() objs.Box.Visible = false end)
            pcall(function() objs.BoxFill.Visible = false end)
        end
        
        -- Name
        if Settings.Name_ESP and objs.Name then
            objs.Name.Text = player.Name .. " [" .. role .. "]"
            objs.Name.Position = Vector2.new(pos.X, top.Y - 18)
            objs.Name.Color = role == "Seeker" and Settings.SeekerColor or Settings.NameColor
            objs.Name.Visible = true
        else
            pcall(function() objs.Name.Visible = false end)
        end
        
        -- Role tag
        if objs.RoleTag then
            objs.RoleTag.Text = role
            objs.RoleTag.Position = Vector2.new(pos.X, top.Y - 32)
            objs.RoleTag.Color = role == "Seeker" and Settings.SeekerColor or Settings.HiderColor
            objs.RoleTag.Visible = true
        end
        
        -- Distance
        if Settings.Distance_ESP and objs.Dist and localHRP then
            local d = math.floor((hrp.Position - localHRP.Position).Magnitude)
            objs.Dist.Text = d .. "m"
            objs.Dist.Position = Vector2.new(pos.X, bot.Y + 5)
            objs.Dist.Visible = true
        else
            pcall(function() objs.Dist.Visible = false end)
        end
        
        -- Health
        if Settings.Health_ESP and objs.HP and objs.HPBar and objs.HPBarBG then
            objs.HP.Text = math.floor(hp) .. "/" .. math.floor(maxHp)
            objs.HP.Position = Vector2.new(pos.X, bot.Y + 18)
            objs.HP.Visible = true
            
            local barX = bx - 5
            objs.HPBarBG.From = Vector2.new(barX, by)
            objs.HPBarBG.To = Vector2.new(barX, by + h)
            objs.HPBarBG.Visible = true
            
            local hh = h * hpPct
            objs.HPBar.From = Vector2.new(barX, by + h - hh)
            objs.HPBar.To = Vector2.new(barX, by + h)
            
            if hpPct > 0.6 then objs.HPBar.Color = Color3.fromRGB(0, 255, 0)
            elseif hpPct > 0.3 then objs.HPBar.Color = Color3.fromRGB(255, 255, 0)
            else objs.HPBar.Color = Color3.fromRGB(255, 0, 0) end
            objs.HPBar.Visible = true
        else
            pcall(function() objs.HP.Visible = false end)
            pcall(function() objs.HPBar.Visible = false end)
            pcall(function() objs.HPBarBG.Visible = false end)
        end
    end
end

-- ============================================
-- K1LL 4UR4
-- ============================================
local KillAuraConn = nil

local function StartKillAura()
    if KillAuraConn then return end
    KillAuraConn = RunService.Heartbeat:Connect(function()
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
            
            local char = p.Character
            local hrp = char and GetHRP(p)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then continue end
            
            local dist = (hrp.Position - lHRP.Position).Magnitude
            if dist <= Settings.KillAura_Radius then
                pcall(function() hum:TakeDamage(100) end)
                pcall(function()
                    for _, part in ipairs(lChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            firetouchinterest(part, hrp, 0)
                            task.wait(0.02)
                            firetouchinterest(part, hrp, 1)
                        end
                    end
                end)
                if tool then
                    pcall(function()
                        local h = tool:FindFirstChild("Handle")
                        if h then
                            firetouchinterest(h, hrp, 0)
                            task.wait(0.02)
                            firetouchinterest(h, hrp, 1)
                        end
                    end)
                end
            end
            task.wait(Settings.KillAura_Delay)
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
-- 4UT0 C01N
-- ============================================
local CoinConn = nil

local function FindCoins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local n = obj.Name:lower()
            if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash") or n:match("gem") or n:match("token") or n:match("collect") then
                local y = obj.Position.Y
                if y > -100 and y < 500 then
                    if obj:FindFirstChildWhichIsA("TouchInterest") then
                        table.insert(coins, obj)
                    end
                end
            end
        end
    end
    return coins
end

local function StartCoin()
    if CoinConn then return end
    CoinConn = task.spawn(function()
        while true do
            if not Settings.AutoCoin_Enabled then
                task.wait(1)
                continue
            end
            
            local coins = FindCoins()
            local lChar = LocalPlayer.Character
            local lHRP = lChar and GetHRP(LocalPlayer)
            
            if lHRP then
                for _, coin in ipairs(coins) do
                    if not Settings.AutoCoin_Enabled then break end
                    if coin and coin.Parent then
                        local dist = (coin.Position - lHRP.Position).Magnitude
                        local cy = coin.Position.Y
                        if dist < 400 and cy > -100 and cy < 500 then
                            pcall(function()
                                lHRP.CFrame = coin.CFrame
                                task.wait(0.1)
                                firetouchinterest(lHRP, coin, 0)
                                task.wait(0.03)
                                firetouchinterest(lHRP, coin, 1)
                                for _, part in ipairs(lChar:GetDescendants()) do
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
-- 3SP R3ND3R L00P - F1X3D
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
StartKillAura()
StartTP()
StartCoin()

-- ============================================
-- UI - 1 SCR33NGU1 S4J4
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "XyinESP_" .. tostring(math.random(10000, 99999))
SG.Parent = CoreGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- L04D1NG SCR33N - F1X3D
-- ============================================
local Loading = Instance.new("Frame")
Loading.Name = "LoadingScreen"
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG

-- Gradient
local LG = Instance.new("UIGradient")
LG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 5, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))
})
LG.Rotation = 45
LG.Parent = Loading

-- Particles
for i = 1, 15 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
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

-- Logo
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 500, 0, 60 * UIScale)
Logo.Position = UDim2.new(0.5, -250, 0.32, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "N4n0Xy1n"
Logo.TextColor3 = Color3.fromRGB(0, 255, 255)
Logo.TextSize = 48 * UIScale
Logo.Font = Enum.Font.GothamBlack
Logo.ZIndex = 10001
Logo.Parent = Loading

-- Glow
local Glow = Instance.new("TextLabel")
Glow.Size = Logo.Size
Glow.Position = UDim2.new(0.5, -248, 0.32, 2)
Glow.BackgroundTransparency = 1
Glow.Text = "N4n0Xy1n"
Glow.TextColor3 = Color3.fromRGB(0, 255, 255)
Glow.TextSize = 48 * UIScale
Glow.Font = Enum.Font.GothamBlack
Glow.TextTransparency = 0.7
Glow.ZIndex = 10000
Glow.Parent = Loading

-- Subtitle
local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 500, 0, 25 * UIScale)
Sub.Position = UDim2.new(0.5, -250, 0.4, 0)
Sub.BackgroundTransparency = 1
Sub.Text = "Xy1nESP v4.0 // プレイヤーESP // Игрок ESP"
Sub.TextColor3 = Color3.fromRGB(150, 150, 170)
Sub.TextSize = 13 * UIScale
Sub.Font = Enum.Font.Gotham
Sub.ZIndex = 10001
Sub.Parent = Loading

-- Author
local Auth = Instance.new("TextLabel")
Auth.Size = UDim2.new(0, 300, 0, 20 * UIScale)
Auth.Position = UDim2.new(0.5, -150, 0.44, 0)
Auth.BackgroundTransparency = 1
Auth.Text = "by @RukanooXD_YT"
Auth.TextColor3 = Color3.fromRGB(0, 200, 255)
Auth.TextSize = 11 * UIScale
Auth.Font = Enum.Font.GothamBold
Auth.ZIndex = 10001
Auth.Parent = Loading

-- Bar BG
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 320 * UIScale, 0, 8)
BarBG.Position = UDim2.new(0.5, -160 * UIScale, 0.52, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 10001
BarBG.Parent = Loading
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 4)

-- Bar Fill
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10002
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 4)

-- Percent
local Pct = Instance.new("TextLabel")
Pct.Size = UDim2.new(0, 100, 0, 25 * UIScale)
Pct.Position = UDim2.new(0.5, -50, 0.55, 5)
Pct.BackgroundTransparency = 1
Pct.Text = "0%"
Pct.TextColor3 = Color3.fromRGB(0, 255, 255)
Pct.TextSize = 16 * UIScale
Pct.Font = Enum.Font.GothamBlack
Pct.ZIndex = 10001
Pct.Parent = Loading

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 400, 0, 20 * UIScale)
Status.Position = UDim2.new(0.5, -200, 0.6, 0)
Status.BackgroundTransparency = 1
Status.Text = "Initializing..."
Status.TextColor3 = Color3.fromRGB(100, 100, 120)
Status.TextSize = 11 * UIScale
Status.Font = Enum.Font.Gotham
Status.ZIndex = 10001
Status.Parent = Loading

-- Animate loading
task.spawn(function()
    local stages = {
        {pct = 10, txt = "Initializing Core..."},
        {pct = 25, txt = "Loading ESP Engine..."},
        {pct = 40, txt = "Loading Combat Systems..."},
        {pct = 55, txt = "Loading Teleport Module..."},
        {pct = 70, txt = "Loading Auto Collect..."},
        {pct = 82, txt = "Building Modern UI..."},
        {pct = 92, txt = "Finalizing..."},
        {pct = 100, txt = "Ready to Dominate!"},
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
    
    -- PROPER CLEANUP - Destroy everything
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
-- M41N M3NU - M0D3RN GL4SSM0RPH15M
-- ============================================
local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

-- Glass effect
local Glass = Instance.new("UIGradient")
Glass.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 32)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 15, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 32))
})
Glass.Rotation = 135
Glass.Parent = Main

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.Position = UDim2.new(0, -30, 0, -30)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

-- Title Bar
local Title = Instance.new("Frame")
Title.Size = UDim2.new(1, 0, 0, 52 * UIScale)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 16)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -110, 0, 26 * UIScale)
TitleText.Position = UDim2.new(0, 16, 0, 6)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Xy1nESP v4.0"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleText.TextSize = 17 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = Title

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(1, -110, 0, 16 * UIScale)
TitleSub.Position = UDim2.new(0, 16, 0, 30)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "プレイヤーESP // Игрок ESP"
TitleSub.TextColor3 = Color3.fromRGB(100, 100, 120)
TitleSub.TextSize = 9 * UIScale
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = Title

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -74, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Title
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
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
TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
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
    btn.Size = UDim2.new(0, 95 * UIScale, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(130, 130, 150)
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
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 800)
    content.Visible = false
    content.Parent = Main
    
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)
    
    table.insert(Tabs, btn)
    Contents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            b.TextColor3 = Color3.fromRGB(130, 130, 150)
        end
        for _, c in pairs(Contents) do c.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
    end)
    
    return content
end

local ESPContent = MakeTab("ESP", "👁️")
local CombatContent = MakeTab("Combat", "⚔️")
local MiscContent = MakeTab("Misc", "🛠️")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Tabs[1].TextColor3 = Color3.fromRGB(255, 255, 255)
ESPContent.Visible = true

-- ============================================
-- T0GGL3 CR34T0R
-- ============================================
local function MakeToggle(parent, text, key, color, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 58 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
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
        d.TextColor3 = Color3.fromRGB(90, 90, 110)
        d.TextSize = 9 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 50, 0, 26)
    bg.Position = UDim2.new(1, -62, 0.5, -13)
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
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
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 26, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(180, 180, 180)
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
-- SL1D3R CR34T0R
-- ============================================
local function MakeSlider(parent, text, key, min, max, suffix)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 62 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
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
    val.TextColor3 = Color3.fromRGB(0, 255, 255)
    val.TextSize = 12 * UIScale
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = f
    
    local sbg = Instance.new("Frame")
    sbg.Size = UDim2.new(1, -28, 0, 6)
    sbg.Position = UDim2.new(0, 14, 0, 40 * UIScale)
    sbg.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    sbg.BorderSizePixel = 0
    sbg.Parent = f
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
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
MakeToggle(ESPContent, "ESP Master", "ESP_Enabled", Color3.fromRGB(0, 255, 255), "Aktifkan semua ESP")
MakeToggle(ESPContent, "Line ESP", "Line_ESP", Color3.fromRGB(0, 200, 255), "Garis ke player")
MakeToggle(ESPContent, "Box ESP", "Box_ESP", Color3.fromRGB(255, 0, 255), "Kotak di sekitar player")
MakeToggle(ESPContent, "Name ESP", "Name_ESP", Color3.fromRGB(255, 255, 255), "Nama player")
MakeToggle(ESPContent, "Distance ESP", "Distance_ESP", Color3.fromRGB(255, 255, 0), "Jarak ke player")
MakeToggle(ESPContent, "Health ESP", "Health_ESP", Color3.fromRGB(0, 255, 100), "Health bar")
MakeToggle(ESPContent, "Team Check", "TeamCheck", Color3.fromRGB(255, 100, 100), "Sembunyikan tim")
MakeSlider(ESPContent, "Max Distance", "MaxDistance", 50, 2000, "m")

-- ============================================
-- C0MB4T T4B
-- ============================================
MakeToggle(CombatContent, "Kill Aura", "KillAura_Enabled", Color3.fromRGB(255, 50, 50), "Auto attack hider // キルオーラ // Килл Аура")
MakeSlider(CombatContent, "Kill Aura Radius", "KillAura_Radius", 5, 50, " studs")
MakeSlider(CombatContent, "Kill Aura Delay", "KillAura_Delay", 0.05, 1, "s")
MakeToggle(CombatContent, "Teleport Hider", "TeleportHider_Enabled", Color3.fromRGB(255, 150, 0), "Teleport ke hider // テレポート // Телепорт")
MakeSlider(CombatContent, "Teleport Delay", "TeleportHider_Delay", 0.5, 5, "s")

-- ============================================
-- M1SC T4B
-- ============================================
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin_Enabled", Color3.fromRGB(255, 215, 0), "Auto ambil coin // コイン収集 // Сбор монет")
MakeSlider(MiscContent, "Coin Delay", "AutoCoin_Delay", 0.1, 2, "s")

local DragToggle = Instance.new("TextButton")
DragToggle.Size = UDim2.new(1, 0, 0, 48 * UIScale)
DragToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
DragToggle.Text = "🖱️ Drag Box Mode: OFF"
DragToggle.TextColor3 = Color3.fromRGB(130, 130, 150)
DragToggle.TextSize = 11 * UIScale
DragToggle.Font = Enum.Font.GothamBold
DragToggle.Parent = MiscContent
Instance.new("UICorner", DragToggle).CornerRadius = UDim.new(0, 12)

local DragBoxOn = false
DragToggle.MouseButton1Click:Connect(function()
    DragBoxOn = not DragBoxOn
    if DragBoxOn then
        DragToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        DragToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DragToggle.Text = "🖱️ Drag Box Mode: ON"
    else
        DragToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        DragToggle.TextColor3 = Color3.fromRGB(130, 130, 150)
        DragToggle.Text = "🖱️ Drag Box Mode: OFF"
    end
end)

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
-- DR4G B0X
-- ============================================
UserInputService.InputBegan:Connect(function(input)
    if not DragBoxOn then return end
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
    if IsDraggingBox and DragBoxOn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStartPos
        BoxOffset.X = BoxStartOffset.X + delta.X
        BoxOffset.Y = BoxStartOffset.Y + delta.Y
    end
end)

-- ============================================
-- T0GGL3 M3NU BUTT0N
-- ============================================
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 18, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
MenuBtn.Text = "👁️"
MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
MenuBtn.TextSize = 26 * UIScale
MenuBtn.Font = Enum.Font.GothamBlack
MenuBtn.Parent = SG

Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 14)

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(0, 255, 255)
BtnStroke.Thickness = 2
BtnStroke.Parent = MenuBtn

local BtnGlow = Instance.new("ImageLabel")
BtnGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
BtnGlow.Position = UDim2.new(-0.3, 0, -0.3, 0)
BtnGlow.BackgroundTransparency = 1
BtnGlow.Image = "rbxassetid://10822646370"
BtnGlow.ImageColor3 = Color3.fromRGB(0, 255, 255)
BtnGlow.ImageTransparency = 0.7
BtnGlow.Parent = MenuBtn

-- Pulse
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
        MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        BtnStroke.Color = Color3.fromRGB(0, 255, 150)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = MenuSize}):Play()
    else
        MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
        BtnStroke.Color = Color3.fromRGB(0, 255, 255)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    BtnStroke.Color = Color3.fromRGB(0, 255, 255)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    BtnStroke.Color = Color3.fromRGB(0, 255, 255)
end)

-- ============================================
-- K3YB04RD SH0RTCUT5
-- ============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Main.Visible = not Main.Visible
        MenuBtn.BackgroundColor3 = Main.Visible and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(15, 15, 28)
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
-- N0T1F1C4T10N 4FT3R L04D
-- ============================================
task.delay(5, function()
    local N = Instance.new("Frame")
    N.Size = UDim2.new(0, 380 * UIScale, 0, 75 * UIScale)
    N.Position = UDim2.new(0.5, -190 * UIScale, 0, -90)
    N.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    N.BorderSizePixel = 0
    N.Parent = SG
    
    Instance.new("UICorner", N).CornerRadius = UDim.new(0, 14)
    
    local NS = Instance.new("UIStroke")
    NS.Color = Color3.fromRGB(0, 255, 255)
    NS.Thickness = 1
    NS.Parent = N
    
    local NT = Instance.new("TextLabel")
    NT.Size = UDim2.new(1, -20, 0.35, 0)
    NT.Position = UDim2.new(0, 10, 0, 8)
    NT.BackgroundTransparency = 1
    NT.Text = "Xy1nESP v4.0 G4C0R K1NG Aktif!"
    NT.TextColor3 = Color3.fromRGB(0, 255, 255)
    NT.TextSize = 14 * UIScale
    NT.Font = Enum.Font.GothamBlack
    NT.Parent = N
    
    local NA = Instance.new("TextLabel")
    NA.Size = UDim2.new(1, -20, 0.3, 0)
    NA.Position = UDim2.new(0, 10, 0.35, 2)
    NA.BackgroundTransparency = 1
    NA.Text = "by @RukanooXD_YT | 完了 | Готово"
    NA.TextColor3 = Color3.fromRGB(0, 200, 255)
    NA.TextSize = 11 * UIScale
    NA.Font = Enum.Font.GothamBold
    NA.Parent = N
    
    local NK = Instance.new("TextLabel")
    NK.Size = UDim2.new(1, -20, 0.35, 0)
    NK.Position = UDim2.new(0, 10, 0.65, 0)
    NK.BackgroundTransparency = 1
    NK.Text = "R1ghtAlt: M3nu | 1ns3rt: ESP | H0m3: K1ll | PgUp: TP | 3nd: C01n"
    NK.TextColor3 = Color3.fromRGB(150, 150, 150)
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
-- M0R53 & F1N4L
-- ============================================
print("[N4n0Xy1n] Xy1nESP v4.0 ULTRA F1X L04D3D")
print("[N4n0Xy1n] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")
print("[N4n0Xy1n] プレイヤーESP v4.0 ロード完了")
print("[N4n0Xy1n] Игрок ESP v4.0 загружен")
print("[N4n0Xy1n] @RukanooXD_YT")
print("[N4n0Xy1n] D3v1c3: " .. (IsMobile and "M0b1l3" or "L4pt0p"))
print("[N4n0Xy1n] U1Sc4l3: " .. UIScale)
