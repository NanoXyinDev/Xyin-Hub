-- ============================================
-- XYINHUB v7.1 - PAINT OR SEEK EDITION
-- @RukanooXD_YT
-- Game: Paint or Seek
-- Features: ESP, Auto Kill (Fast Touch), Auto Coin,
-- Auto Safe, Seeker Detector, Speed, Jump, Noclip
-- FIX: Auto Kill only in round, distance check,
-- Fast Kill tool touch simulation, Noclip added
-- NO DELAY, INSTANT EXECUTE
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- ============================================
-- DEVICE DETECTION
-- ============================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScale = IsMobile and 0.85 or 1

-- ============================================
-- SETTINGS
-- ============================================
local Settings = {
    ESP_Enabled = false,
    MaxDistance = 1000,
    AutoKill_Enabled = false,
    AutoKill_Radius = 30,
    AutoKill_Delay = 0.05,
    TeleportHider_Enabled = false,
    TeleportHider_Delay = 1.5,
    AutoCoin_Enabled = false,
    AutoCoin_Delay = 0.05,
    CoinBypass = true,
    SpeedHack = false,
    SpeedValue = 100,
    JumpHack = false,
    JumpValue = 150,
    AutoSafe = false,
    SafeDistance = 25,
    SeekerDetector = false,
    DetectorRange = 100,
    Noclip = false,
}

-- ============================================
-- GAME STATE DETECTION
-- ============================================
local GameState = {
    InRound = false,
    MyRole = "Unknown",
    RoundTimer = nil,
    HidersLeft = 0,
}

local function UpdateGameState()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") then
            local text = gui.Text:lower()
            if text:match("round ends") or text:match("hiders left") or text:match("seekers left") then
                GameState.InRound = true
                local timer = text:match("(%d+:%d+)")
                if timer then GameState.RoundTimer = timer end
                return
            end
            if text:match("you:%s*seeker") or text:match("you%s*seeker") then
                GameState.MyRole = "Seeker"
            elseif text:match("you:%s*hider") or text:match("you%s*hider") then
                GameState.MyRole = "Hider"
            end
        end
    end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("BillboardGui") then
            local txt = ""
            pcall(function() txt = obj.Text:lower() end)
            if txt:match("hiders left") or txt:match("round ends") then
                GameState.InRound = true
                return
            end
        end
    end
    
    GameState.InRound = false
end

task.spawn(function()
    while true do
        UpdateGameState()
        task.wait(0.5)
    end
end)

-- ============================================
-- DRAWING MANAGER
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
        Line = CreateDrawing("Line", {Thickness = 1.5, Color = Color3.fromRGB(255,255,255), Transparency = 1, Visible = false, ZIndex = 1}),
        Box = CreateDrawing("Square", {Thickness = 1.5, Color = Color3.fromRGB(255,255,255), Transparency = 1, Filled = false, Visible = false, ZIndex = 2}),
        BoxFill = CreateDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(255,255,255), Transparency = 0.08, Filled = true, Visible = false, ZIndex = 1}),
        Name = CreateDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255), Visible = false, ZIndex = 3}),
        Dist = CreateDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(180,180,180), Visible = false, ZIndex = 3}),
        HP = CreateDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(200,200,200), Visible = false, ZIndex = 3}),
        RoleTag = CreateDrawing("Text", {Text = "", Size = 14, Center = true, Outline = true, Visible = false, ZIndex = 5}),
    }
end

-- ============================================
-- PLAYER CHECKS - PAINT OR SEEK ROLE DETECTION
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

local function GetPlayerRole(p)
    local playerGui = p:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") then
                local text = gui.Text:lower()
                if text:match("you:%s*seeker") or text:match("role:%s*seeker") or text:match("team:%s*seeker") then
                    return "Seeker"
                end
                if text:match("you:%s*hider") or text:match("role:%s*hider") or text:match("team:%s*hider") then
                    return "Hider"
                end
            end
        end
    end
    
    local c = p.Character
    if c then
        if c:FindFirstChild("Seeker") or c:FindFirstChild("IsSeeker") then return "Seeker" end
        if c:FindFirstChild("Hider") or c:FindFirstChild("IsHider") then return "Hider" end
        
        for _, tool in ipairs(c:GetChildren()) do
            if tool:IsA("Tool") then
                local tn = tool.Name:lower()
                if tn:match("paint") or tn:match("brush") or tn:match("bucket") or tn:match("seek") then
                    return "Seeker"
                end
            end
        end
        
        local bp = p:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    local tn = tool.Name:lower()
                    if tn:match("paint") or tn:match("brush") or tn:match("bucket") or tn:match("seek") then
                        return "Seeker"
                    end
                end
            end
        end
        
        for _, g in ipairs(c:GetDescendants()) do
            if g:IsA("BillboardGui") or g:IsA("TextLabel") then
                local txt = ""
                pcall(function() txt = g.Text:lower() end)
                if txt:match("seeker") then return "Seeker" end
                if txt:match("hider") then return "Hider" end
            end
        end
    end
    
    if p == LocalPlayer then
        if GameState.MyRole ~= "Unknown" then
            return GameState.MyRole
        end
    end
    
    if p ~= LocalPlayer then
        local myRole = GetPlayerRole(LocalPlayer)
        if myRole == "Seeker" then return "Hider" end
        if myRole == "Hider" then return "Seeker" end
    end
    
    return "Unknown"
end

local function IsHider(p)
    return p ~= LocalPlayer and IsAlive(p) and GetPlayerRole(p) == "Hider"
end

local function IsSeeker(p)
    return p ~= LocalPlayer and IsAlive(p) and GetPlayerRole(p) == "Seeker"
end

local function AmISeeker()
    return GetPlayerRole(LocalPlayer) == "Seeker"
end

-- ============================================
-- ESP UPDATE
-- ============================================
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
        
        local role = GetPlayerRole(p)
        local hp = hum.Health
        local maxHp = hum.MaxHealth
        
        local color = Color3.fromRGB(255,255,255)
        if role == "Seeker" then color = Color3.fromRGB(255,80,80)
        elseif role == "Hider" then color = Color3.fromRGB(80,255,80) end
        
        local cf, size = c:GetBoundingBox()
        if not cf then continue end
        
        local topY = cf.Position.Y + size.Y / 2
        local botY = cf.Position.Y - size.Y / 2
        local top = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, topY, cf.Position.Z))
        local bot = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, botY, cf.Position.Z))
        
        local h = math.abs(top.Y - bot.Y)
        local w = h * 0.55
        local bx = pos.X - w / 2
        local by = top.Y
        
        if o.Box and o.BoxFill then
            o.Box.Size = Vector2.new(w, h)
            o.Box.Position = Vector2.new(bx, by)
            o.Box.Color = color
            o.Box.Visible = true
            o.BoxFill.Size = Vector2.new(w, h)
            o.BoxFill.Position = Vector2.new(bx, by)
            o.BoxFill.Color = color
            o.BoxFill.Visible = true
        end
        
        if o.Name then
            o.Name.Text = p.Name .. " [" .. role .. "]"
            o.Name.Position = Vector2.new(pos.X, top.Y - 18)
            o.Name.Color = color
            o.Name.Visible = true
        end
        
        if o.RoleTag then
            o.RoleTag.Text = role
            o.RoleTag.Position = Vector2.new(pos.X, top.Y - 32)
            o.RoleTag.Color = color
            o.RoleTag.Visible = true
        end
        
        if o.Dist and lHRP then
            local d = math.floor((hrp.Position - lHRP.Position).Magnitude)
            o.Dist.Text = d .. "m"
            o.Dist.Position = Vector2.new(pos.X, bot.Y + 5)
            o.Dist.Visible = true
        end
        
        if o.HP then
            o.HP.Text = math.floor(hp) .. "/" .. math.floor(maxHp)
            o.HP.Position = Vector2.new(pos.X, bot.Y + 18)
            o.HP.Visible = true
        end
        
        if o.Line then
            o.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            o.Line.To = Vector2.new(pos.X, pos.Y)
            o.Line.Color = color
            o.Line.Visible = true
        end
    end
end

-- ============================================
-- AUTO KILL - FAST TOOL TOUCH SIMULATION
-- FIX: Only in round, strict distance check
-- ============================================
local AutoKillConn = nil

local function GetTool()
    local c = LocalPlayer.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then return t end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                c:FindFirstChildOfClass("Humanoid"):EquipTool(t)
                task.wait(0.1)
                return t
            end
        end
    end
    return nil
end

local function StartAutoKill()
    if AutoKillConn then return end
    AutoKillConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoKill_Enabled then return end
        if not GameState.InRound then return end
        if not AmISeeker() then return end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        if not lHRP then return end
        
        local tool = GetTool()
        if not tool then return end
        
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsHider(p) then continue end
            
            local c = p.Character
            local hrp = c and GetHRP(p)
            if not hrp then continue end
            
            local dist = (hrp.Position - lHRP.Position).Magnitude
            if dist > Settings.AutoKill_Radius then continue end
            
            -- FAST KILL: Move tool Handle to target HRP, fire touch, return
            pcall(function()
                local oldCFrame = handle.CFrame
                local oldParent = handle.Parent
                
                -- Teleport tool handle to target
                handle.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                
                -- Activate tool
                tool:Activate()
                
                -- Fire touch with handle to target body parts
                firetouchinterest(handle, hrp, 0)
                firetouchinterest(handle, hrp, 1)
                
                -- Fire touch with all target parts
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        firetouchinterest(handle, part, 0)
                        firetouchinterest(handle, part, 1)
                    end
                end
                
                -- Fire touch with local body parts to target
                for _, part in ipairs(lChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        firetouchinterest(part, hrp, 0)
                        firetouchinterest(part, hrp, 1)
                    end
                end
                
                task.wait(0.03)
                
                -- Return handle
                handle.CFrame = oldCFrame
            end)
            
            task.wait(Settings.AutoKill_Delay)
        end
    end)
end

-- ============================================
-- AUTO SAFE - ONLY DURING ROUND, FROM REAL SEEKERS
-- ============================================
local SafeConn = nil
local LastSafeTeleport = 0

local function StartAutoSafe()
    if SafeConn then return end
    SafeConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoSafe then return end
        if not GameState.InRound then return end
        if AmISeeker() then return end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        local lHum = lChar and lChar:FindFirstChildOfClass("Humanoid")
        if not lHRP or not lHum then return end
        
        if tick() - LastSafeTeleport < 0.5 then return end
        
        local nearestSeeker = nil
        local nearestDist = math.huge
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsSeeker(p) then continue end
            
            local c = p.Character
            local hasTool = false
            if c then
                for _, t in ipairs(c:GetChildren()) do
                    if t:IsA("Tool") then hasTool = true break end
                end
            end
            local bp = p:FindFirstChild("Backpack")
            if bp and not hasTool then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") then hasTool = true break end
                end
            end
            
            if not hasTool then continue end
            
            local hrp = c and GetHRP(p)
            if hrp then
                local d = (hrp.Position - lHRP.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearestSeeker = hrp
                end
            end
        end
        
        if nearestSeeker and nearestDist < Settings.SafeDistance then
            local awayDir = (lHRP.Position - nearestSeeker.Position).Unit
            local safePos = lHRP.Position + awayDir * 20
            safePos = Vector3.new(
                math.clamp(safePos.X, -500, 500),
                math.max(safePos.Y, 5),
                math.clamp(safePos.Z, -500, 500)
            )
            
            pcall(function() lHum.Sit = false end)
            pcall(function() lHum.PlatformStand = false end)
            
            lHRP.CFrame = CFrame.new(safePos)
            lHRP.Velocity = Vector3.new(0, 0, 0)
            
            pcall(function()
                lHum:MoveTo(safePos + awayDir * 5)
            end)
            
            LastSafeTeleport = tick()
        end
    end)
end

-- ============================================
-- SEEKER DETECTOR - ONLY DURING ROUND
-- ============================================
local DetectorText = CreateDrawing("Text", {
    Text = "",
    Size = 28,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Visible = false,
    ZIndex = 100
})

local DetectorLine = CreateDrawing("Line", {
    Thickness = 3,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Visible = false,
    ZIndex = 99
})

local LastDetectorReset = 0

local function ResetDetector()
    DetectorText.Visible = false
    DetectorLine.Visible = false
    LastDetectorReset = tick()
end

local function StartSeekerDetector()
    RunService.RenderStepped:Connect(function()
        if not GameState.InRound then
            ResetDetector()
            return
        end
        
        if not Settings.SeekerDetector then
            DetectorText.Visible = false
            DetectorLine.Visible = false
            return
        end
        if AmISeeker() then
            DetectorText.Visible = false
            DetectorLine.Visible = false
            return
        end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        if not lHRP then return end
        
        local nearestSeeker = nil
        local nearestDist = math.huge
        local seekerPos = nil
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsSeeker(p) then continue end
            
            local c = p.Character
            local hrp = c and GetHRP(p)
            if hrp then
                local d = (hrp.Position - lHRP.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearestSeeker = p
                    seekerPos = hrp.Position
                end
            end
        end
        
        if nearestSeeker and nearestDist < Settings.DetectorRange then
            local screenPos = Camera:WorldToViewportPoint(seekerPos)
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            local flash = math.abs(math.sin(tick() * 8))
            DetectorText.Color = Color3.fromRGB(255, 255 * (1 - flash), 255 * (1 - flash))
            DetectorText.Text = "SEEKER " .. nearestSeeker.Name .. " " .. math.floor(nearestDist) .. "m"
            DetectorText.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 120)
            DetectorText.Visible = true
            
            DetectorLine.From = center
            DetectorLine.To = Vector2.new(screenPos.X, screenPos.Y)
            DetectorLine.Color = Color3.fromRGB(255, 255 * (1 - flash), 255 * (1 - flash))
            DetectorLine.Visible = true
        else
            DetectorText.Visible = false
            DetectorLine.Visible = false
        end
    end)
end

-- ============================================
-- SPEED HACK
-- ============================================
local SpeedConn = nil
local SpeedPropConn = nil

local function StartSpeedHack()
    if SpeedConn then return end
    
    SpeedConn = RunService.RenderStepped:Connect(function()
        if not Settings.SpeedHack then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed ~= Settings.SpeedValue then
            h.WalkSpeed = Settings.SpeedValue
        end
    end)
    
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        SpeedPropConn = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if not Settings.SpeedHack then return end
            if h.WalkSpeed ~= Settings.SpeedValue then
                h.WalkSpeed = Settings.SpeedValue
            end
        end)
    end
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        local newHum = newChar:FindFirstChildOfClass("Humanoid")
        if newHum then
            if SpeedPropConn then SpeedPropConn:Disconnect() end
            SpeedPropConn = newHum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if not Settings.SpeedHack then return end
                if newHum.WalkSpeed ~= Settings.SpeedValue then
                    newHum.WalkSpeed = Settings.SpeedValue
                end
            end)
        end
    end)
end

-- ============================================
-- JUMP HACK
-- ============================================
local JumpConn = nil

local function StartJumpHack()
    if JumpConn then return end
    
    JumpConn = RunService.RenderStepped:Connect(function()
        if not Settings.JumpHack then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h.JumpHeight = Settings.JumpValue / 10
                h.UseJumpHeight = true
            end)
            pcall(function()
                if h:FindFirstChild("JumpPower") then
                    h.JumpPower = Settings.JumpValue
                end
            end)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not Settings.JumpHack then return end
        if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h:GetState() ~= Enum.HumanoidStateType.Jumping then
                pcall(function()
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    end)
end

-- ============================================
-- NOCLIP - NEW FEATURE
-- ============================================
local NoclipConn = nil

local function StartNoclip()
    if NoclipConn then return end
    NoclipConn = RunService.Stepped:Connect(function()
        if not Settings.Noclip then return end
        local c = LocalPlayer.Character
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- ============================================
-- TELEPORT HIDER
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
-- AUTO COIN - FIX TOTAL
-- ============================================
local CoinConn = nil
local CoinBlacklist = {
    "invite", "friend", "gui", "button", "frame", "label", "menu", "shop", "settings",
    "inventory", "taunt", "pose", "lock", "paint", "troll", "become", "tiny", "giant",
    "portal", "spawn", "lobby", "home", "base", "checkpoint", "chest", "crate", "box",
    "camo", "sample", "fill", "brush", "bucket"
}

local CachedCoins = {}
local LastCoinScan = 0

local function IsRealCoin(obj)
    if not obj or not obj.Parent then return false end
    local n = obj.Name:lower()
    for _, bl in ipairs(CoinBlacklist) do
        if n:match(bl) then return false end
    end
    if obj:FindFirstChild("Collected") then return false end
    local hasTouch = obj:FindFirstChildWhichIsA("TouchInterest") ~= nil
    local hasPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt") ~= nil
    return hasTouch or hasPrompt
end

local function ScanCoins()
    if tick() - LastCoinScan < 1 then return CachedCoins end
    
    CachedCoins = {}
    local lChar = LocalPlayer.Character
    local lHRP = lChar and GetHRP(LocalPlayer)
    if not lHRP then return CachedCoins end
    
    local success, parts = pcall(function()
        return Workspace:GetPartBoundsInRadius(lHRP.Position, 300)
    end)
    
    if success and parts then
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                local n = part.Name:lower()
                if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash") or 
                   n:match("gem") or n:match("token") or n:match("collect") or n:match("point") or
                   n:match("star") or n:match("reward") or n:match("drop") or n:match("pickup") or
                   n:match("loot") or n:match("bonus") or n:match("candy") then
                    if IsRealCoin(part) then
                        table.insert(CachedCoins, part)
                    end
                end
            end
        end
    end
    
    LastCoinScan = tick()
    return CachedCoins
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        local n = obj.Name:lower()
        if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash") then
            if IsRealCoin(obj) then
                table.insert(CachedCoins, obj)
            end
        end
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    for i, coin in ipairs(CachedCoins) do
        if coin == obj then
            table.remove(CachedCoins, i)
            break
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
                for i = #coins, 1, -1 do
                    local coin = coins[i]
                    if not Settings.AutoCoin_Enabled then break end
                    if not coin or not coin.Parent then
                        table.remove(coins, i)
                        continue
                    end
                    
                    local dist = (coin.Position - lHRP.Position).Magnitude
                    if dist < 200 then
                        if Settings.CoinBypass then
                            pcall(function()
                                local oldCFrame = coin.CFrame
                                coin.CFrame = lHRP.CFrame
                                task.wait(0.05)
                                
                                for _, part in ipairs(lChar:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        firetouchinterest(part, coin, 0)
                                        firetouchinterest(part, coin, 1)
                                    end
                                end
                                
                                firetouchinterest(lHRP, coin, 0)
                                firetouchinterest(lHRP, coin, 1)
                                
                                local prompt = coin:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                                
                                task.wait(0.05)
                                
                                if coin and coin.Parent then
                                    coin.CFrame = oldCFrame
                                end
                            end)
                        else
                            pcall(function()
                                local oldPos = lHRP.CFrame
                                lHRP.CFrame = coin.CFrame * CFrame.new(0, 2, 0)
                                task.wait(0.05)
                                firetouchinterest(lHRP, coin, 0)
                                firetouchinterest(lHRP, coin, 1)
                                
                                local prompt = coin:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                                
                                task.wait(0.05)
                                lHRP.CFrame = oldPos
                            end)
                        end
                    end
                    task.wait(Settings.AutoCoin_Delay)
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================
-- PLAYER EVENTS
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
-- INITIALIZE ALL SYSTEMS
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
StartAutoKill()
StartAutoSafe()
StartSeekerDetector()
StartSpeedHack()
StartJumpHack()
StartNoclip()
StartTP()
StartCoin()

-- ============================================
-- UI - CINEMATIC B&W PROFESSIONAL
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "XyinESP_" .. tostring(math.random(10000, 99999))
SG.Parent = CoreGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 200, 0, 20)
Watermark.Position = UDim2.new(1, -210, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "@RukanooXD_YT"
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.TextSize = 12
Watermark.Font = Enum.Font.GothamBold
Watermark.TextTransparency = 0.3
Watermark.Parent = SG

-- ============================================
-- LOADING SCREEN - CINEMATIC GLITCH
-- ============================================
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG

for i = 0, 1, 0.02 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, i, 0)
    line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.ZIndex = 9998
    line.Parent = Loading
end

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(10, 10, 10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
Gradient.Rotation = 90
Gradient.Parent = Loading

for i = 1, 30 do
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
            TweenService:Create(p, TweenInfo.new(math.random(3, 7)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(5, 9) / 10
            }):Play()
            task.wait(math.random(3, 7))
        end
    end)
end

local GlitchTexts = {"XYINHUB", "X_Y_I_N_H_U_B", "X#Y#I#N#H#U#B", "XY1NHUB", "X¥INHUB"}
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 600, 0, 80 * UIScale)
Logo.Position = UDim2.new(0.5, -300, 0.28, 0)
Logo.BackgroundTransparency = 1
Logo.Text = ""
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 56 * UIScale
Logo.Font = Enum.Font.GothamBlack
Logo.ZIndex = 10001
Logo.Parent = Loading

task.spawn(function()
    local finalText = "XYINHUB"
    for i = 1, #finalText do
        local char = string.sub(finalText, 1, i)
        Logo.Text = char
        task.wait(0.1)
    end
    
    for i = 1, 8 do
        Logo.Text = GlitchTexts[math.random(1, #GlitchTexts)]
        Logo.TextColor3 = Color3.fromRGB(math.random(200, 255), math.random(200, 255), math.random(200, 255))
        task.wait(0.05)
    end
    Logo.Text = finalText
    Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

local Glow = Instance.new("TextLabel")
Glow.Size = Logo.Size
Glow.Position = UDim2.new(0.5, -298, 0.28, 2)
Glow.BackgroundTransparency = 1
Glow.Text = "XYINHUB"
Glow.TextColor3 = Color3.fromRGB(255, 255, 255)
Glow.TextSize = 56 * UIScale
Glow.Font = Enum.Font.GothamBlack
Glow.TextTransparency = 0.85
Glow.ZIndex = 10000
Glow.Parent = Loading

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 600, 0, 25 * UIScale)
Sub.Position = UDim2.new(0.5, -300, 0.37, 0)
Sub.BackgroundTransparency = 1
Sub.Text = "Paint or Seek Edition | v7.1 | Premium Script"
Sub.TextColor3 = Color3.fromRGB(120, 120, 120)
Sub.TextSize = 13 * UIScale
Sub.Font = Enum.Font.Gotham
Sub.ZIndex = 10001
Sub.Parent = Loading

local Auth = Instance.new("TextLabel")
Auth.Size = UDim2.new(0, 300, 0, 20 * UIScale)
Auth.Position = UDim2.new(0.5, -150, 0.41, 0)
Auth.BackgroundTransparency = 1
Auth.Text = "by @RukanooXD_YT"
Auth.TextColor3 = Color3.fromRGB(180, 180, 180)
Auth.TextSize = 11 * UIScale
Auth.Font = Enum.Font.GothamBold
Auth.ZIndex = 10001
Auth.Parent = Loading

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 320 * UIScale, 0, 4)
BarBG.Position = UDim2.new(0.5, -160 * UIScale, 0.5, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 10001
BarBG.Parent = Loading
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 2)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10002
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 2)

local Pct = Instance.new("TextLabel")
Pct.Size = UDim2.new(0, 100, 0, 22 * UIScale)
Pct.Position = UDim2.new(0.5, -50, 0.52, 5)
Pct.BackgroundTransparency = 1
Pct.Text = "0%"
Pct.TextColor3 = Color3.fromRGB(255, 255, 255)
Pct.TextSize = 14 * UIScale
Pct.Font = Enum.Font.GothamBlack
Pct.ZIndex = 10001
Pct.Parent = Loading

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 400, 0, 18 * UIScale)
Status.Position = UDim2.new(0.5, -200, 0.57, 0)
Status.BackgroundTransparency = 1
Status.Text = "Initializing..."
Status.TextColor3 = Color3.fromRGB(80, 80, 80)
Status.TextSize = 10 * UIScale
Status.Font = Enum.Font.Gotham
Status.ZIndex = 10001
Status.Parent = Loading

task.spawn(function()
    local stages = {
        {pct = 10, txt = "Initializing Core..."},
        {pct = 22, txt = "Loading ESP Engine..."},
        {pct = 35, txt = "Loading Combat Systems..."},
        {pct = 48, txt = "Loading Speed & Jump..."},
        {pct = 58, txt = "Loading Auto Safe..."},
        {pct = 68, txt = "Loading Seeker Detector..."},
        {pct = 78, txt = "Loading Coin Collector..."},
        {pct = 88, txt = "Building Cinematic UI..."},
        {pct = 95, txt = "Finalizing..."},
        {pct = 100, txt = "Ready!"},
    }
    
    local cur = 0
    for _, s in ipairs(stages) do
        while cur < s.pct do
            cur = cur + math.random(1, 3)
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
            TweenService:Create(child, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") and child ~= Loading then
            TweenService:Create(child, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        end
    end
    
    TweenService:Create(Loading, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    task.wait(1.2)
    Loading:Destroy()
end)

-- ============================================
-- MAIN MENU - PROFESSIONAL B&W
-- ============================================
local MenuSize = IsMobile and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 400, 0, 540)
local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

local Glass = Instance.new("UIGradient")
Glass.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 8)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
})
Glass.Rotation = 135
Glass.Parent = Main

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.Position = UDim2.new(0, -30, 0, -30)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.35
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

local Title = Instance.new("Frame")
Title.Size = UDim2.new(1, 0, 0, 54 * UIScale)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 18)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -120, 0, 28 * UIScale)
TitleText.Position = UDim2.new(0, 18, 0, 6)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XYINHUB v7.1"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = Title

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(1, -120, 0, 16 * UIScale)
TitleSub.Position = UDim2.new(0, 18, 0, 32)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "Paint or Seek | Premium"
TitleSub.TextColor3 = Color3.fromRGB(80, 80, 80)
TitleSub.TextSize = 9 * UIScale
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = Title

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -74, 0, 11)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Title
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -16, 0, 38 * UIScale)
TabFrame.Position = UDim2.new(0, 8, 0, 56)
TabFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
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
    btn.Size = UDim2.new(0, 88 * UIScale, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(100, 100, 100)
    btn.TextSize = 10 * UIScale
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name
    content.Size = UDim2.new(1, -16, 1, -110 * UIScale)
    content.Position = UDim2.new(0, 8, 0, 98 * UIScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 1000)
    content.Visible = false
    content.Parent = Main
    
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)
    
    table.insert(Tabs, btn)
    Contents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            b.TextColor3 = Color3.fromRGB(100, 100, 100)
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

local function MakeToggle(parent, text, key, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 58 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -10, 0, 24 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
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
        d.TextColor3 = Color3.fromRGB(70, 70, 70)
        d.TextSize = 9 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 50, 0, 26)
    bg.Position = UDim2.new(1, -62, 0.5, -13)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
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
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(80, 80, 80)
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

local function MakeSlider(parent, text, key, min, max, suffix)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 62 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, -10, 0, 22 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
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
    sbg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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

-- ESP Tab
MakeToggle(ESPContent, "ESP Master", "ESP_Enabled", "Show all players")

-- Combat Tab
MakeToggle(CombatContent, "Auto Kill", "AutoKill_Enabled", "Auto teleport + swing at hiders")
MakeSlider(CombatContent, "Kill Radius", "AutoKill_Radius", 5, 50, " studs")
MakeSlider(CombatContent, "Kill Delay", "AutoKill_Delay", 0.05, 1, "s")
MakeToggle(CombatContent, "Teleport Hider", "TeleportHider_Enabled", "Teleport to hiders")
MakeSlider(CombatContent, "Teleport Delay", "TeleportHider_Delay", 0.5, 5, "s")
MakeToggle(CombatContent, "Auto Safe", "AutoSafe", "Auto run from seekers")
MakeSlider(CombatContent, "Safe Distance", "SafeDistance", 10, 60, " studs")
MakeToggle(CombatContent, "Seeker Detector", "SeekerDetector", "Alert when seeker near")
MakeSlider(CombatContent, "Detector Range", "DetectorRange", 50, 200, " studs")

-- Misc Tab
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin_Enabled", "Auto collect coins")
MakeToggle(MiscContent, "Coin Bypass", "CoinBypass", "Collect without teleport")
MakeSlider(MiscContent, "Coin Delay", "AutoCoin_Delay", 0.01, 1, "s")

-- Player Tab
MakeToggle(PlayerContent, "Speed Hack", "SpeedHack", "Fast run")
MakeSlider(PlayerContent, "Speed Value", "SpeedValue", 16, 500, "")
MakeToggle(PlayerContent, "Jump Hack", "JumpHack", "High jump")
MakeSlider(PlayerContent, "Jump Power", "JumpValue", 50, 300, "")
MakeToggle(PlayerContent, "Noclip", "Noclip", "Walk through walls")

-- Drag menu
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

-- Toggle menu button
local ToggleBtnSize = IsMobile and UDim2.new(0, 55, 0, 55) or UDim2.new(0, 50, 0, 50)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 18, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MenuBtn.Text = "XY"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.TextSize = 20 * UIScale
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
BtnGlow.ImageTransparency = 0.7
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
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = MenuSize}):Play()
    else
        MenuBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Main.Visible = not Main.Visible
        if Main.Visible then
            MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            MenuBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
            MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    if input.KeyCode == Enum.KeyCode.Insert then Settings.ESP_Enabled = not Settings.ESP_Enabled end
    if input.KeyCode == Enum.KeyCode.Home then Settings.AutoKill_Enabled = not Settings.AutoKill_Enabled end
    if input.KeyCode == Enum.KeyCode.PageUp then Settings.TeleportHider_Enabled = not Settings.TeleportHider_Enabled end
    if input.KeyCode == Enum.KeyCode.End then Settings.AutoCoin_Enabled = not Settings.AutoCoin_Enabled end
    if input.KeyCode == Enum.KeyCode.Delete then Settings.SpeedHack = not Settings.SpeedHack end
    if input.KeyCode == Enum.KeyCode.N then Settings.Noclip = not Settings.Noclip end
end)

-- ============================================
-- ANTI-DETECTION
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
                if a[1] and (a[1]:match("ESP") or a[1]:match("Xyin") or a[1]:match("XYIN") or a[1]:match("Hub")) then
                    return nil
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

-- ============================================
-- NOTIFICATION - BOTTOM RIGHT
-- ============================================
local Notif = Instance.new("Frame")
Notif.Size = UDim2.new(0, 350 * UIScale, 0, 70 * UIScale)
Notif.Position = UDim2.new(1, 10, 1, 10)
Notif.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Notif.BorderSizePixel = 0
Notif.Parent = SG
Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 14)

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Color3.fromRGB(255, 255, 255)
NotifStroke.Thickness = 1
NotifStroke.Parent = Notif

local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size = UDim2.new(1, -20, 0, 22 * UIScale)
NotifTitle.Position = UDim2.new(0, 10, 0, 6)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "KAMU TELAH MEMASUKI SCRIPT XYINHUB"
NotifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifTitle.TextSize = 13 * UIScale
NotifTitle.Font = Enum.Font.GothamBlack
NotifTitle.Parent = Notif

local NotifInfo = Instance.new("TextLabel")
NotifInfo.Size = UDim2.new(1, -20, 0, 18 * UIScale)
NotifInfo.Position = UDim2.new(0, 10, 0, 28)
NotifInfo.BackgroundTransparency = 1
NotifInfo.Text = "Username Roblox : " .. LocalPlayer.Name .. " | ID : " .. LocalPlayer.UserId
NotifInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
NotifInfo.TextSize = 10 * UIScale
NotifInfo.Font = Enum.Font.GothamBold
NotifInfo.Parent = Notif

local NotifVer = Instance.new("TextLabel")
NotifVer.Size = UDim2.new(1, -20, 0, 16 * UIScale)
NotifVer.Position = UDim2.new(0, 10, 0, 46)
NotifVer.BackgroundTransparency = 1
NotifVer.Text = "XYINHUB v7.1 | Paint or Seek | @RukanooXD_YT"
NotifVer.TextColor3 = Color3.fromRGB(100, 100, 100)
NotifVer.TextSize = 9 * UIScale
NotifVer.Font = Enum.Font.Gotham
NotifVer.Parent = Notif

-- ============================================
-- NOTIFICATION - BOTTOM RIGHT (CONTINUED)
-- ============================================
Notif:TweenPosition(UDim2.new(1, -360 * UIScale, 1, -80 * UIScale), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5)

task.delay(8, function()
    Notif:TweenPosition(UDim2.new(1, 10, 1, 10), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.4)
    task.wait(0.5)
    Notif:Destroy()
end)

-- ============================================
-- ANTI-DETECTION ENHANCED
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
                if a[1] and (a[1]:match("ESP") or a[1]:match("Xyin") or a[1]:match("XYIN") or a[1]:match("Hub") or a[1]:match("MenuToggle") or a[1]:match("MainMenu")) then
                    return nil
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldIndex = mt.__index
        mt.__index = newcclosure(function(self, k)
            if type(k) == "string" then
                if k:match("ESP") or k:match("Xyin") or k:match("XYIN") or k:match("Hub") then
                    return nil
                end
            end
            return oldIndex(self, k)
        end)
        setreadonly(mt, true)
    end
end)

-- ============================================
-- FINAL PRINT & STATUS
-- ============================================
local function GetRole(p)
    return GetPlayerRole(p)
end

print("[XYINHUB] v7.1 Paint or Seek Edition LOADED")
print("[XYINHUB] User: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId)
print("[XYINHUB] Role: " .. GetRole(LocalPlayer))
print("[XYINHUB] Device: " .. (IsMobile and "Mobile" or "PC"))
print("[XYINHUB] Systems: ESP, AutoKill, AutoSafe, SeekerDetector, Speed, Jump, Noclip, AutoCoin, TeleportHider")
print("[XYINHUB] @RukanooXD_YT")
print("[XYINHUB] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")

-- ============================================
-- CLEANUP ON DESTROY
-- ============================================
SG.Destroying:Connect(function()
    for _, o in pairs(ESPObjects) do
        for _, obj in pairs(o) do pcall(function() obj:Remove() end) end
    end
    if AutoKillConn then pcall(function() AutoKillConn:Disconnect() end) end
    if SafeConn then pcall(function() SafeConn:Disconnect() end) end
    if SpeedConn then pcall(function() SpeedConn:Disconnect() end) end
    if SpeedPropConn then pcall(function() SpeedPropConn:Disconnect() end) end
    if JumpConn then pcall(function() JumpConn:Disconnect() end) end
    if NoclipConn then pcall(function() NoclipConn:Disconnect() end) end
    DetectorText:Remove()
    DetectorLine:Remove()
end)

-- ============================================
-- END OF XYINHUB v7.1
-- ============================================
