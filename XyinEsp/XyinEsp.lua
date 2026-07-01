-- ============================================
-- XYINHUB v9.1 - PAINT OR SEEK EDITION
-- @RukanooXD_YT
-- Fixes: Lobby ESP leak, role detection, 
-- throwable knife auto-kill, merged TP+Kill,
-- round timer awareness, fresh UI
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
local UIScale = IsMobile and 0.78 or 1

-- ============================================
-- SETTINGS
-- ============================================
local Settings = {
    ESP = false,
    MaxDistance = 1500,
    AutoKill = false,
    AutoKillRadius = 9999,
    AutoCoin = false,
    SpeedHack = false,
    SpeedValue = 120,
    JumpHack = false,
    JumpValue = 150,
    AutoSafe = false,
    SafeDistance = 40,
    SeekerDetector = false,
    DetectorRange = 300,
    Noclip = false,
}

-- ============================================
-- GAME STATE — ENHANCED WITH TIMER AWARENESS
-- ============================================
local GameState = {
    InRound = false,
    MyRole = "Unknown",
    RoundPhase = "Unknown", -- "Lobby", "Warmup", "Hiding", "Seeking", "Round"
    RoundStartTime = 0,
    SeekerReleaseTime = 50, -- 50 detik warmup
    RoundDuration = 180, -- 3 menit
}

local function UpdateGameState()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local inRound = false
    local phase = "Unknown"
    local myRole = "Unknown"
    
    -- Scan PlayerGui for role & phase
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                
                -- Role detection from UI
                if text:match("you are a seeker") or text:match("you are seeker") 
                   or text:match("role:%s*seeker") or text:match("team:%s*seeker")
                   or text:match("you:%s*seeker") then
                    myRole = "Seeker"
                elseif text:match("you are a hider") or text:match("you are hider")
                   or text:match("role:%s*hider") or text:match("team:%s*hider")
                   or text:match("you:%s*hider") then
                    myRole = "Hider"
                end
                
                -- Phase detection
                if text:match("round ends") or text:match("hiders left") 
                   or text:match("seekers left") or text:match("time remaining") then
                    inRound = true
                    phase = "Round"
                end
                if text:match("time until seeker arrives") or text:match("quickly find a spot") then
                    inRound = true
                    phase = "Hiding"
                end
                if text:match("round starts in") or text:match("game starts in") then
                    inRound = true
                    phase = "Warmup"
                end
                if text:match("waiting for players") or text:match("intermission")
                   or text:match("vote") or text:match("lobby") then
                    phase = "Lobby"
                end
            end
        end
    end
    
    -- Workspace scan
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("BillboardGui") then
            local txt = ""
            pcall(function() txt = obj.Text:lower() end)
            if txt:match("hiders left") or txt:match("round ends") 
               or txt:match("seekers left") or txt:match("time remaining") then
                inRound = true
                if phase == "Unknown" then phase = "Round" end
            end
            if txt:match("time until seeker") then
                inRound = true
                phase = "Hiding"
            end
        end
    end
    
    -- Lobby detection via workspace children
    if Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("Intermission")
       or Workspace:FindFirstChild("Waiting") or Workspace:FindFirstChild("Queue") then
        if not inRound then
            phase = "Lobby"
        end
    end
    
    -- Force lobby if no round indicators AND lobby UI present
    if not inRound and phase == "Unknown" then
        if playerGui then
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("TextLabel") then
                    local text = gui.Text:lower()
                    if text:match("waiting") or text:match("intermission")
                       or text:match("vote") or text:match("lobby")
                       or text:match("shop") or text:match("inventory") then
                        phase = "Lobby"
                        break
                    end
                end
            end
        end
    end
    
    -- If we detected round phase but no explicit lobby, assume in round
    if inRound and phase ~= "Lobby" then
        GameState.InRound = true
    elseif phase == "Lobby" then
        GameState.InRound = false
    else
        -- Default: if role is known but no phase, check if we're in game
        GameState.InRound = (myRole ~= "Unknown") and (phase ~= "Lobby")
    end
    
    GameState.MyRole = myRole
    GameState.RoundPhase = phase
    
    -- Timer tracking
    if GameState.InRound and GameState.RoundStartTime == 0 then
        GameState.RoundStartTime = tick()
    elseif not GameState.InRound then
        GameState.RoundStartTime = 0
    end
end

task.spawn(function()
    while true do
        UpdateGameState()
        task.wait(0.2)
    end
end)

-- ============================================
-- ENHANCED ROLE DETECTION — PLAYERGUI PRIORITY
-- ============================================
local RoleCache = {}

local function GetPlayerRole(p)
    if not p then return "Unknown" end
    
    -- For local player: ALWAYS use PlayerGui directly, no cache, no inference
    if p == LocalPlayer then
        return GameState.MyRole
    end
    
    -- Check cache for others (1 second)
    if RoleCache[p] then
        if tick() - RoleCache[p].time < 1 then
            return RoleCache[p].role
        end
    end
    
    local role = "Unknown"
    
    -- Method 1: Character attributes/tags
    local c = p.Character
    if c then
        if c:FindFirstChild("Seeker") or c:FindFirstChild("IsSeeker") 
           or c:FindFirstChild("SeekerTag") or c:FindFirstChild("SeekerRole") then
            role = "Seeker"
        elseif c:FindFirstChild("Hider") or c:FindFirstChild("IsHider")
           or c:FindFirstChild("HiderTag") or c:FindFirstChild("HiderRole") then
            role = "Hider"
        end
        
        if role == "Unknown" then
            local attrs = {"Role", "Team", "GameRole", "PlayerRole"}
            for _, attr in ipairs(attrs) do
                local val = c:GetAttribute(attr)
                if val then
                    local v = tostring(val):lower()
                    if v:match("seeker") then role = "Seeker" break end
                    if v:match("hider") then role = "Hider" break end
                end
            end
        end
        
        -- Method 2: Tool-based (Seeker has knife/paint/weapon)
        if role == "Unknown" then
            for _, tool in ipairs(c:GetChildren()) do
                if tool:IsA("Tool") then
                    local tn = tool.Name:lower()
                    if tn:match("paint") or tn:match("brush") or tn:match("bucket") 
                       or tn:match("seek") or tn:match("throw") or tn:match("knife")
                       or tn:match("sword") or tn:match("weapon") or tn:match("gun")
                       or tn:match("balloon") or tn:match("dart") then
                        role = "Seeker"
                        break
                    end
                end
            end
        end
        
        -- Method 3: BillboardGui tags
        if role == "Unknown" then
            for _, g in ipairs(c:GetDescendants()) do
                if g:IsA("BillboardGui") or g:IsA("TextLabel") then
                    local txt = ""
                    pcall(function() txt = g.Text:lower() end)
                    if txt:match("seeker") and not txt:match("hider") then role = "Seeker" break end
                    if txt:match("hider") and not txt:match("seeker") then role = "Hider" break end
                end
            end
        end
    end
    
    -- Method 4: Backpack tool check
    if role == "Unknown" then
        local bp = p:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    local tn = tool.Name:lower()
                    if tn:match("paint") or tn:match("brush") or tn:match("bucket")
                       or tn:match("seek") or tn:match("throw") or tn:match("knife")
                       or tn:match("sword") or tn:match("weapon") or tn:match("gun") then
                        role = "Seeker"
                        break
                    end
                end
            end
        end
    end
    
    -- Method 5: Team inference (LAST RESORT only)
    if role == "Unknown" then
        local myRole = GameState.MyRole
        if myRole == "Seeker" then role = "Hider"
        elseif myRole == "Hider" then role = "Seeker" end
    end
    
    -- Cache result
    RoleCache[p] = {role = role, time = tick()}
    return role
end

-- Clear cache on character added
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        RoleCache[p] = nil
        task.wait(0.5)
        if p ~= LocalPlayer then
            pcall(function() CreateESPObjects(p) end)
        end
    end)
end)

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

local function IsHider(p)
    return p ~= LocalPlayer and IsAlive(p) and GetPlayerRole(p) == "Hider"
end

local function IsSeeker(p)
    return p ~= LocalPlayer and IsAlive(p) and GetPlayerRole(p) == "Seeker"
end

local function AmISeeker()
    return GameState.MyRole == "Seeker"
end

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
        Line = CreateDrawing("Line", {Thickness = 1.5, Color = Color3.fromRGB(0,255,255), Transparency = 1, Visible = false, ZIndex = 1}),
        Box = CreateDrawing("Square", {Thickness = 1.5, Color = Color3.fromRGB(0,255,255), Transparency = 1, Filled = false, Visible = false, ZIndex = 2}),
        BoxFill = CreateDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(0,255,255), Transparency = 0.06, Filled = true, Visible = false, ZIndex = 1}),
        Name = CreateDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255), Visible = false, ZIndex = 3}),
        Dist = CreateDrawing("Text", {Text = "", Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(180,180,180), Visible = false, ZIndex = 3}),
        HP = CreateDrawing("Text", {Text = "", Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(200,200,200), Visible = false, ZIndex = 3}),
        RoleTag = CreateDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, Visible = false, ZIndex = 5}),
    }
end

-- ============================================
-- ESP UPDATE — STRICT LOBBY BLOCK
-- ============================================
local function UpdateESP()
    -- STRICT: Force invisible when NOT in active round
    if not Settings.ESP or not GameState.InRound or GameState.RoundPhase == "Lobby" 
       or GameState.RoundPhase == "Unknown" or GameState.MyRole == "Unknown" then
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
                for _, o in pairs(ESPObjects[p]) do pcall(function() obj.Visible = false end) end
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
                    for _, o in pairs(ESPObjects[p]) do pcall(function() obj.Visible = false end) end
                end
                continue
            end
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            if ESPObjects[p] then
                for _, o in pairs(ESPObjects[p]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        if not ESPObjects[p] then CreateESPObjects(p) end
        local o = ESPObjects[p]
        
        local role = GetPlayerRole(p)
        local hp = hum.Health
        local maxHp = hum.MaxHealth
        
        local color = Color3.fromRGB(0,255,255)
        if role == "Seeker" then 
            color = Color3.fromRGB(255,50,50)
        elseif role == "Hider" then 
            color = Color3.fromRGB(50,255,100)
        end
        
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
-- AUTO KILL v2 — THROWABLE KNIFE MECHANIC
-- Merged with Teleport Hider
-- Fokus 1 target sampai mati, baru next
-- ============================================
local AutoKillConn = nil
local CurrentTarget = nil

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
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(t)
                    task.wait(0.05)
                    return t
                end
            end
        end
    end
    return nil
end

local function StartAutoKill()
    if AutoKillConn then return end
    
    AutoKillConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoKill then 
            CurrentTarget = nil
            return 
        end
        if not GameState.InRound then 
            CurrentTarget = nil
            return 
        end
        if not AmISeeker() then 
            CurrentTarget = nil
            return 
        end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        if not lHRP then return end
        
        local tool = GetTool()
        if not tool then return end
        
        -- If we have a current target, check if still alive
        if CurrentTarget then
            if not IsHider(CurrentTarget) then
                CurrentTarget = nil -- Target dead or left, find new
            end
        end
        
        -- Find target if none
        if not CurrentTarget then
            local nearestDist = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                if not IsHider(p) then continue end
                
                local c = p.Character
                local hrp = c and GetHRP(p)
                if hrp then
                    local d = (hrp.Position - lHRP.Position).Magnitude
                    if d < nearestDist then
                        nearestDist = d
                        CurrentTarget = p
                    end
                end
            end
        end
        
        -- Execute kill on current target
        if CurrentTarget then
            local c = CurrentTarget.Character
            local hrp = c and GetHRP(CurrentTarget)
            if not hrp then 
                CurrentTarget = nil
                return 
            end
            
            pcall(function()
                -- TP to target (close but not inside)
                local targetPos = hrp.Position
                local offset = CFrame.new(targetPos) * CFrame.new(0, 0, 5)
                lHRP.CFrame = offset
                lHRP.CFrame = CFrame.new(lHRP.Position, targetPos)
                
                -- Face target precisely
                lHRP.CFrame = CFrame.new(lHRP.Position, targetPos)
                
                -- Activate tool (throw/shoot)
                for i = 1, 3 do
                    tool:Activate()
                end
                
                -- For click-based tools: simulate click on target
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    -- Touch the target with tool handle
                    firetouchinterest(handle, hrp, 0)
                    firetouchinterest(handle, hrp, 1)
                    
                    -- Touch all body parts
                    for _, part in ipairs(c:GetDescendants()) do
                        if part:IsA("BasePart") then
                            firetouchinterest(handle, part, 0)
                            firetouchinterest(handle, part, 1)
                        end
                    end
                end
                
                -- Body touch spam for extra damage
                for _, part in ipairs(lChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        firetouchinterest(part, hrp, 0)
                        firetouchinterest(part, hrp, 1)
                    end
                end
                
                -- Check if target died after this hit
                task.wait(0.1)
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    CurrentTarget = nil -- Target dead, find next
                end
            end)
        end
    end)
end

-- ============================================
-- AUTO SAFE — ZERO DELAY, HEARTBEAT
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
        
        if tick() - LastSafeTeleport < 0.2 then return end
        
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
        
        if nearestSeeker and nearestDist < Settings.SafeDistance then
            local awayDir = (lHRP.Position - nearestSeeker.Position).Unit
            local safePos = lHRP.Position + awayDir * 40
            safePos = Vector3.new(
                math.clamp(safePos.X, -500, 500),
                math.max(safePos.Y, 5),
                math.clamp(safePos.Z, -500, 500)
            )
            
            pcall(function() lHum.Sit = false end)
            pcall(function() lHum.PlatformStand = false end)
            
            lHRP.CFrame = CFrame.new(safePos)
            lHRP.Velocity = Vector3.new(0, 0, 0)
            LastSafeTeleport = tick()
        end
    end)
end

-- ============================================
-- SEEKER DETECTOR — FLASHING RED
-- ============================================
local DetectorText = CreateDrawing("Text", {
    Text = "",
    Size = 28,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(255, 50, 50),
    Transparency = 1,
    Visible = false,
    ZIndex = 100
})

local DetectorLine = CreateDrawing("Line", {
    Thickness = 3,
    Color = Color3.fromRGB(255, 50, 50),
    Transparency = 1,
    Visible = false,
    ZIndex = 99
})

local function StartSeekerDetector()
    RunService.RenderStepped:Connect(function()
        if not GameState.InRound then
            DetectorText.Visible = false
            DetectorLine.Visible = false
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
            
            local flash = math.abs(math.sin(tick() * 10))
            DetectorText.Color = Color3.fromRGB(255, 50 + 205 * (1-flash), 50 + 205 * (1-flash))
            DetectorText.Text = "SEEKER " .. nearestSeeker.Name .. " " .. math.floor(nearestDist) .. "m"
            DetectorText.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 120)
            DetectorText.Visible = true
            
            DetectorLine.From = center
            DetectorLine.To = Vector2.new(screenPos.X, screenPos.Y)
            DetectorLine.Color = Color3.fromRGB(255, 50 + 205 * (1-flash), 50 + 205 * (1-flash))
            DetectorLine.Visible = true
        else
            DetectorText.Visible = false
            DetectorLine.Visible = false
        end
    end)
end

-- ============================================
-- SPEED HACK — ANTI-RESET
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
        task.wait(0.3)
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
                h.JumpPower = Settings.JumpValue
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
-- NOCLIP
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
-- AUTO COIN — ZERO DELAY, DIRECT COLLECT
-- ============================================
local CoinConn = nil

local function IsCoin(obj)
    if not obj or not obj.Parent then return false end
    if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part")) then return false end
    
    local n = obj.Name:lower()
    local isCoinName = false
    
    if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash")
       or n:match("gem") or n:match("token") or n:match("collectible") or n:match("point")
       or n:match("star") or n:match("reward") or n:match("drop") or n:match("pickup")
       or n:match("loot") or n:match("bonus") or n:match("candy") or n:match("xp")
       or n:match("exp") or n:match("orb") or n:match("sphere") or n:match("bill") then
        isCoinName = true
    end
    
    if not isCoinName then return false end
    
    local blacklist = {"invite", "friend", "gui", "button", "frame", "label", "menu", "shop",
        "settings", "inventory", "taunt", "pose", "lock", "paint", "troll", "become",
        "tiny", "giant", "portal", "spawn", "lobby", "home", "base", "checkpoint",
        "chest", "crate", "box", "camo", "sample", "fill", "brush", "bucket",
        "throw", "knife", "sword", "tool", "weapon", "handle", "hitbox"}
    
    for _, bl in ipairs(blacklist) do
        if n:match(bl) then return false end
    end
    
    return true
end

local function StartCoin()
    if CoinConn then return end
    CoinConn = task.spawn(function()
        while true do
            if not Settings.AutoCoin then
                task.wait(0.3)
                continue
            end
            
            local lChar = LocalPlayer.Character
            local lHRP = lChar and GetHRP(LocalPlayer)
            
            if lHRP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Settings.AutoCoin then break end
                    if not IsCoin(obj) then continue end
                    
                    pcall(function()
                        local oldPos = lHRP.CFrame
                        lHRP.CFrame = obj.CFrame * CFrame.new(0, 2, 0)
                        
                        firetouchinterest(lHRP, obj, 0)
                        firetouchinterest(lHRP, obj, 1)
                        
                        for _, part in ipairs(lChar:GetDescendants()) do
                            if part:IsA("BasePart") then
                                firetouchinterest(part, obj, 0)
                                firetouchinterest(part, obj, 1)
                            end
                        end
                        
                        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
                        if not prompt and obj.Parent then
                            prompt = obj.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                        end
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                        
                        local clicker = obj:FindFirstChildWhichIsA("ClickDetector")
                        if clicker then
                            fireclickdetector(clicker)
                        end
                        
                        lHRP.CFrame = oldPos
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- PLAYER EVENTS
-- ============================================
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    RoleCache[p] = nil
    if CurrentTarget == p then CurrentTarget = nil end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then pcall(function() CreateESPObjects(p) end) end
end

-- ============================================
-- INITIALIZE SYSTEMS
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
StartAutoKill()
StartAutoSafe()
StartSeekerDetector()
StartSpeedHack()
StartJumpHack()
StartNoclip()
StartCoin()

-- ============================================
-- FRESH UI v9.1 — CLEAN, MODERN, COOL
-- ============================================
local SG_UI = Instance.new("ScreenGui")
SG_UI.Name = "XyinHub_" .. tostring(math.random(10000, 99999))
SG_UI.Parent = CoreGui
SG_UI.ResetOnSpawn = false
SG_UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 280, 0, 20)
Watermark.Position = UDim2.new(1, -290, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "@RukanooXD_YT | XYINHUB v9.1"
Watermark.TextColor3 = Color3.fromRGB(0, 255, 255)
Watermark.TextSize = 11
Watermark.Font = Enum.Font.GothamBold
Watermark.TextTransparency = 0.4
Watermark.Parent = SG_UI

-- ============================================
-- LOADING SCREEN — SLEEK DARK
-- ============================================
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG_UI

local LoadGradient = Instance.new("UIGradient")
LoadGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 15)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 15))
})
LoadGradient.Rotation = 90
LoadGradient.Parent = Loading

-- Animated grid lines
for i = 1, 8 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 1, 0)
    line.Position = UDim2.new(i / 9, 0, 0, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    line.BackgroundTransparency = 0.95
    line.BorderSizePixel = 0
    line.ZIndex = 10000
    line.Parent = Loading
end

for i = 1, 6 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, i / 7, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    line.BackgroundTransparency = 0.95
    line.BorderSizePixel = 0
    line.ZIndex = 10000
    line.Parent = Loading
end

-- Particles
for i = 1, 30 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    p.BackgroundTransparency = math.random(7, 9) / 10
    p.BorderSizePixel = 0
    p.ZIndex = 10001
    p.Parent = Loading
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        while p.Parent do
            TweenService:Create(p, TweenInfo.new(math.random(3, 6)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(7, 9) / 10
            }):Play()
            task.wait(math.random(3, 6))
        end
    end)
end

-- Logo
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 500, 0, 80 * UIScale)
LogoText.Position = UDim2.new(0.5, -250, 0.28, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "XYINHUB"
LogoText.TextColor3 = Color3.fromRGB(0, 255, 255)
LogoText.TextSize = 56 * UIScale
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 10002
LogoText.Parent = Loading

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(0, 500, 0, 22 * UIScale)
SubText.Position = UDim2.new(0.5, -250, 0.38, 0)
SubText.BackgroundTransparency = 1
SubText.Text = "Paint or Seek Edition | v9.1"
SubText.TextColor3 = Color3.fromRGB(100, 200, 255)
SubText.TextSize = 13 * UIScale
SubText.Font = Enum.Font.GothamBold
SubText.ZIndex = 10002
SubText.Parent = Loading

-- Role detection status
local RoleText = Instance.new("TextLabel")
RoleText.Size = UDim2.new(0, 400, 0, 20 * UIScale)
RoleText.Position = UDim2.new(0.5, -200, 0.44, 0)
RoleText.BackgroundTransparency = 1
RoleText.Text = "Scanning Game State..."
RoleText.TextColor3 = Color3.fromRGB(150, 150, 150)
RoleText.TextSize = 11 * UIScale
RoleText.Font = Enum.Font.Gotham
RoleText.ZIndex = 10002
RoleText.Parent = Loading

task.spawn(function()
    while Loading.Parent do
        local role = GameState.MyRole
        local phase = GameState.RoundPhase
        RoleText.Text = "Role: " .. role .. " | Phase: " .. phase .. " | " .. (GameState.InRound and "ACTIVE" or "LOBBY")
        if role == "Seeker" then
            RoleText.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif role == "Hider" then
            RoleText.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            RoleText.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        task.wait(0.3)
    end
end)

-- Progress bar
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 320 * UIScale, 0, 4)
BarBG.Position = UDim2.new(0.5, -160 * UIScale, 0.52, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 10002
BarBG.Parent = Loading
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 2)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10003
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 2)

local PctText = Instance.new("TextLabel")
PctText.Size = UDim2.new(0, 100, 0, 20 * UIScale)
PctText.Position = UDim2.new(0.5, -50, 0.54, 5)
PctText.BackgroundTransparency = 1
PctText.Text = "0%"
PctText.TextColor3 = Color3.fromRGB(0, 255, 255)
PctText.TextSize = 13 * UIScale
PctText.Font = Enum.Font.GothamBlack
PctText.ZIndex = 10002
PctText.Parent = Loading

-- Loading animation
task.spawn(function()
    local stages = {
        {pct = 10, txt = "Initializing Core..."},
        {pct = 22, txt = "Loading ESP Engine..."},
        {pct = 35, txt = "Loading Combat System..."},
        {pct = 48, txt = "Loading Movement..."},
        {pct = 60, txt = "Loading Utilities..."},
        {pct = 72, txt = "Building Interface..."},
        {pct = 85, txt = "Finalizing Setup..."},
        {pct = 100, txt = "Ready!"},
    }
    
    local cur = 0
    for _, s in ipairs(stages) do
        while cur < s.pct do
            cur = cur + math.random(1, 3)
            if cur > s.pct then cur = s.pct end
            BarFill.Size = UDim2.new(cur / 100, 0, 1, 0)
            PctText.Text = cur .. "%"
            task.wait(0.02)
        end
        task.wait(0.08)
    end
    
    task.wait(0.4)
    
    for _, child in ipairs(Loading:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") and child ~= Loading then
            TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        end
    end
    
    TweenService:Create(Loading, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    task.wait(0.8)
    Loading:Destroy()
end)

-- ============================================
-- MAIN MENU — CLEAN MODERN GLASS
-- ============================================
local MenuSize = IsMobile and UDim2.new(0, 330, 0, 440) or UDim2.new(0, 440, 0, 580)
local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG_UI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.25
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 22)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 22))
})
MainGradient.Rotation = 135
MainGradient.Parent = Main

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
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 52 * UIScale)
TitleBar.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 18)

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TitleBar

-- Hexagon icon
local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 28, 0, 28)
IconFrame.Position = UDim2.new(0, 14, 0, 12)
IconFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
IconFrame.BorderSizePixel = 0
IconFrame.Parent = TitleBar
Instance.new("UICorner", IconFrame).CornerRadius = UDim.new(0, 6)

local IconText = Instance.new("TextLabel")
IconText.Size = UDim2.new(1, 0, 1, 0)
IconText.BackgroundTransparency = 1
IconText.Text = "X"
IconText.TextColor3 = Color3.fromRGB(0, 0, 0)
IconText.TextSize = 18
IconText.Font = Enum.Font.GothamBlack
IconText.Parent = IconFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 24 * UIScale)
TitleText.Position = UDim2.new(0, 50, 0, 5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XYINHUB"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 17 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0, 200, 0, 14 * UIScale)
TitleSub.Position = UDim2.new(0, 50, 0, 28)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "Paint or Seek | v9.1"
TitleSub.TextColor3 = Color3.fromRGB(100, 140, 200)
TitleSub.TextSize = 8 * UIScale
TitleSub.Font = Enum.Font.GothamBold
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = TitleBar

-- Role Badge
local RoleBadge = Instance.new("Frame")
RoleBadge.Size = UDim2.new(0, 110, 0, 22 * UIScale)
RoleBadge.Position = UDim2.new(1, -122, 0, 6)
RoleBadge.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
RoleBadge.BorderSizePixel = 0
RoleBadge.Parent = TitleBar
Instance.new("UICorner", RoleBadge).CornerRadius = UDim.new(0, 8)

local RoleBadgeText = Instance.new("TextLabel")
RoleBadgeText.Size = UDim2.new(1, 0, 1, 0)
RoleBadgeText.BackgroundTransparency = 1
RoleBadgeText.Text = "You: Unknown"
RoleBadgeText.TextColor3 = Color3.fromRGB(0, 255, 255)
RoleBadgeText.TextSize = 9 * UIScale
RoleBadgeText.Font = Enum.Font.GothamBold
RoleBadgeText.Parent = RoleBadge

local RoleDot = Instance.new("Frame")
RoleDot.Size = UDim2.new(0, 6, 0, 6)
RoleDot.Position = UDim2.new(0, 8, 0.5, -3)
RoleDot.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
RoleDot.BorderSizePixel = 0
RoleDot.Parent = RoleBadge
Instance.new("UICorner", RoleDot).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while RoleBadge.Parent do
        local role = GameState.MyRole
        local phase = GameState.RoundPhase
        RoleBadgeText.Text = "You: " .. role
        if role == "Seeker" then
            RoleBadgeText.TextColor3 = Color3.fromRGB(255, 80, 80)
            RoleBadge.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
            RoleDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        elseif role == "Hider" then
            RoleBadgeText.TextColor3 = Color3.fromRGB(80, 255, 100)
            RoleBadge.BackgroundColor3 = Color3.fromRGB(12, 35, 18)
            RoleDot.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
        else
            RoleBadgeText.TextColor3 = Color3.fromRGB(0, 200, 255)
            RoleBadge.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
            RoleDot.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        end
        task.wait(0.3)
    end
end)

-- Phase indicator
local PhaseText = Instance.new("TextLabel")
PhaseText.Size = UDim2.new(0, 110, 0, 14 * UIScale)
PhaseText.Position = UDim2.new(1, -122, 0, 30)
PhaseText.BackgroundTransparency = 1
PhaseText.Text = "Phase: Lobby"
PhaseText.TextColor3 = Color3.fromRGB(120, 120, 140)
PhaseText.TextSize = 7 * UIScale
PhaseText.Font = Enum.Font.Gotham
PhaseText.Parent = TitleBar

task.spawn(function()
    while PhaseText.Parent do
        PhaseText.Text = "Phase: " .. GameState.RoundPhase
        if GameState.InRound then
            PhaseText.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            PhaseText.TextColor3 = Color3.fromRGB(120, 120, 140)
        end
        task.wait(0.3)
    end
end)

-- Minimize & Close
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -62, 0, 13)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Tab Frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -16, 0, 34 * UIScale)
TabFrame.Position = UDim2.new(0, 8, 0, 54)
TabFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main
Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 10)

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Padding = UDim.new(0, 5)
TabList.Parent = TabFrame

local Tabs = {}
local Contents = {}

local function MakeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 98 * UIScale, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(110, 110, 140)
    btn.TextSize = 9 * UIScale
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name
    content.Size = UDim2.new(1, -16, 1, -102 * UIScale)
    content.Position = UDim2.new(0, 8, 0, 92)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 1000)
    content.Visible = false
    content.Parent = Main
    
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 6)
    
    table.insert(Tabs, btn)
    Contents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            b.TextColor3 = Color3.fromRGB(110, 110, 140)
        end
        for _, c in pairs(Contents) do c.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        content.Visible = true
    end)
    
    return content
end

local ESPContent = MakeTab("ESP", "◉")
local CombatContent = MakeTab("Combat", "⚔")
local MiscContent = MakeTab("Misc", "◈")
local PlayerContent = MakeTab("Player", "▲")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 180, 255)
Tabs[1].TextColor3 = Color3.fromRGB(0, 0, 0)
ESPContent.Visible = true

-- ============================================
-- UI COMPONENTS — MODERN TOGGLE & SLIDER
-- ============================================
local function MakeToggle(parent, text, key, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 52 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, -10, 0, 20 * UIScale)
    lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 240)
    lbl.TextSize = 11 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.55, -10, 0, 14 * UIScale)
        d.Position = UDim2.new(0, 12, 0, 26)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(70, 70, 90)
        d.TextSize = 8 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 44, 0, 22)
    bg.Position = UDim2.new(1, -56, 0.5, -11)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
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
            TweenService:Create(bg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 180, 255)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 24, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(70, 70, 90)
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
    f.Size = UDim2.new(1, 0, 0, 54 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, -10, 0, 18 * UIScale)
    lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 240)
    lbl.TextSize = 10 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.35, 0, 0, 18 * UIScale)
    val.Position = UDim2.new(0.65, 0, 0, 5)
    val.BackgroundTransparency = 1
    val.Text = tostring(Settings[key]) .. (suffix or "")
    val.TextColor3 = Color3.fromRGB(0, 200, 255)
    val.TextSize = 10 * UIScale
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = f
    
    local sbg = Instance.new("Frame")
    sbg.Size = UDim2.new(1, -24, 0, 4)
    sbg.Position = UDim2.new(0, 12, 0, 32 * UIScale)
    sbg.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    sbg.BorderSizePixel = 0
    sbg.Parent = f
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(0, 2)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sbg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((Settings[key] - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sbg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 20)
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
            knob.Position = UDim2.new(scale, -6, 0.5, -6)
            val.Text = tostring(value) .. (suffix or "")
        end
    end)
    
    return f
end

-- ============================================
-- TAB CONTENTS
-- ============================================

-- ESP Tab
MakeToggle(ESPContent, "Player ESP", "ESP", "Box, line, name, distance, HP, role")

-- Combat Tab
MakeToggle(CombatContent, "Auto Kill", "AutoKill", "TP + throw knife, focus 1 target")
MakeSlider(CombatContent, "Kill Radius", "AutoKillRadius", 10, 9999, " studs")
MakeToggle(CombatContent, "Auto Safe", "AutoSafe", "Auto escape from seekers")
MakeSlider(CombatContent, "Safe Distance", "SafeDistance", 10, 80, " studs")
MakeToggle(CombatContent, "Seeker Detector", "SeekerDetector", "Alert when seeker nearby")
MakeSlider(CombatContent, "Detector Range", "DetectorRange", 50, 500, " studs")

-- Misc Tab
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin", "Instant collect all coins")
MakeToggle(MiscContent, "Noclip", "Noclip", "Walk through walls")

-- Player Tab
MakeToggle(PlayerContent, "Speed Hack", "SpeedHack", "Super speed, anti-reset")
MakeSlider(PlayerContent, "Speed Value", "SpeedValue", 16, 500, "")
MakeToggle(PlayerContent, "Jump Hack", "JumpHack", "Super jump power")
MakeSlider(PlayerContent, "Jump Power", "JumpValue", 50, 300, "")

-- ============================================
-- DRAG SYSTEM
-- ============================================
local dragM = false
local dragSP = nil
local dragMP = nil

TitleBar.InputBegan:Connect(function(input)
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
-- TOGGLE BUTTON — FLOATING X
-- ============================================
local ToggleBtnSize = IsMobile and UDim2.new(0, 50, 0, 50) or UDim2.new(0, 46, 0, 46)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 14, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
MenuBtn.Text = "X"
MenuBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
MenuBtn.TextSize = 20 * UIScale
MenuBtn.Font = Enum.Font.GothamBlack
MenuBtn.Parent = SG_UI

Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 14)

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(0, 180, 255)
BtnStroke.Thickness = 2
BtnStroke.Transparency = 0.3
BtnStroke.Parent = MenuBtn

local BtnGlow = Instance.new("ImageLabel")
BtnGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
BtnGlow.Position = UDim2.new(-0.3, 0, -0.3, 0)
BtnGlow.BackgroundTransparency = 1
BtnGlow.Image = "rbxassetid://10822646370"
BtnGlow.ImageColor3 = Color3.fromRGB(0, 180, 255)
BtnGlow.ImageTransparency = 0.7
BtnGlow.Parent = MenuBtn

task.spawn(function()
    while MenuBtn .Parent do
        TweenService:Create(BtnGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.4}):Play()
        task.wait(1.5)
        TweenService:Create(BtnGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.8}):Play()
        task.wait(1.5)
    end
end)

MenuBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = MenuSize}):Play()
    else
        MenuBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
        MenuBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    MenuBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    MenuBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
end)

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Main.Visible = not Main.Visible
        if Main.Visible then
            MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            MenuBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
            MenuBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.ESP = not Settings.ESP
    end
    if input.KeyCode == Enum.KeyCode.Home then
        Settings.AutoKill = not Settings.AutoKill
    end
    if input.KeyCode == Enum.KeyCode.End then
        Settings.AutoCoin = not Settings.AutoCoin
    end
    if input.KeyCode == Enum.KeyCode.Delete then
        Settings.SpeedHack = not Settings.SpeedHack
    end
    if input.KeyCode == Enum.KeyCode.N then
        Settings.Noclip = not Settings.Noclip
    end
end)

-- ============================================
-- ANTI-DETECTION ENHANCED
-- ============================================
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "FindFirstChild" or m == "WaitForChild" or m == "FindFirstChildOfClass" then
                local a = {...}
                if a[1] and type(a[1]) == "string" then
                    local name = a[1]:lower()
                    if name:match("esp") or name:match("xyin") or name:match("hub") 
                       or name:match("menu") or name:match("toggle") or name:match("script") then
                        return nil
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        
        local oldIndex = mt.__index
        mt.__index = newcclosure(function(self, k)
            if type(k) == "string" then
                local kl = k:lower()
                if kl:match("esp") or kl:match("xyin") or kl:match("hub") then
                    return nil
                end
            end
            return oldIndex(self, k)
        end)
        
        setreadonly(mt, true)
    end
end)

-- ============================================
-- MODERN NOTIFICATION SYSTEM
-- ============================================
local NotifFrame = Instance.new("Frame")
NotifFrame.Size = UDim2.new(0, 340 * UIScale, 0, 76 * UIScale)
NotifFrame.Position = UDim2.new(1, 20, 1, 20)
NotifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = SG_UI
Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 12)

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Color3.fromRGB(0, 180, 255)
NotifStroke.Thickness = 1.2
NotifStroke.Transparency = 0.35
NotifStroke.Parent = NotifFrame

local NotifAccent = Instance.new("Frame")
NotifAccent.Size = UDim2.new(0, 3, 1, 0)
NotifAccent.Position = UDim2.new(0, 0, 0, 0)
NotifAccent.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
NotifAccent.BorderSizePixel = 0
NotifAccent.Parent = NotifFrame
Instance.new("UICorner", NotifAccent).CornerRadius = UDim.new(0, 12)

local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size = UDim2.new(1, -20, 0, 22 * UIScale)
NotifTitle.Position = UDim2.new(0, 12, 0, 6)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "XYINHUB v9.1 LOADED"
NotifTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
NotifTitle.TextSize = 13 * UIScale
NotifTitle.Font = Enum.Font.GothamBlack
NotifTitle.Parent = NotifFrame

local NotifRole = Instance.new("TextLabel")
NotifRole.Size = UDim2.new(1, -20, 0, 16 * UIScale)
NotifRole.Position = UDim2.new(0, 12, 0, 28)
NotifRole.BackgroundTransparency = 1
NotifRole.Text = "Detecting..."
NotifRole.TextColor3 = Color3.fromRGB(160, 160, 180)
NotifRole.TextSize = 9 * UIScale
NotifRole.Font = Enum.Font.GothamBold
NotifRole.Parent = NotifFrame

task.spawn(function()
    while NotifRole.Parent do
        local role = GameState.MyRole
        local phase = GameState.RoundPhase
        NotifRole.Text = "User: " .. LocalPlayer.Name .. " | Role: " .. role .. " | " .. phase
        if role == "Seeker" then
            NotifRole.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif role == "Hider" then
            NotifRole.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            NotifRole.TextColor3 = Color3.fromRGB(160, 160, 180)
        end
        task.wait(0.5)
    end
end)

local NotifVer = Instance.new("TextLabel")
NotifVer.Size = UDim2.new(1, -20, 0, 14 * UIScale)
NotifVer.Position = UDim2.new(0, 12, 0, 48)
NotifVer.BackgroundTransparency = 1
NotifVer.Text = "Paint or Seek | @RukanooXD_YT"
NotifVer.TextColor3 = Color3.fromRGB(90, 90, 110)
NotifVer.TextSize = 8 * UIScale
NotifVer.Font = Enum.Font.Gotham
NotifVer.Parent = NotifFrame

NotifFrame:TweenPosition(UDim2.new(1, -360 * UIScale, 1, -86 * UIScale), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5)

task.delay(10, function()
    NotifFrame:TweenPosition(UDim2.new(1, 20, 1, 20), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.35)
    task.wait(0.4)
    NotifFrame:Destroy()
end)

-- ============================================
-- CLEANUP ON DESTROY
-- ============================================
SG_UI.Destroying:Connect(function()
    for _, o in pairs(ESPObjects) do
        for _, obj in pairs(o) do pcall(function() obj:Remove() end) end
    end
    if AutoKillConn then pcall(function() AutoKillConn:Disconnect() end) end
    if SafeConn then pcall(function() SafeConn:Disconnect() end) end
    if SpeedConn then pcall(function() SpeedConn:Disconnect() end) end
    if SpeedPropConn then pcall(function() SpeedPropConn:Disconnect() end) end
    if JumpConn then pcall(function() JumpConn:Disconnect() end) end
    if NoclipConn then pcall(function() NoclipConn:Disconnect() end) end
    pcall(function() DetectorText:Remove() end)
    pcall(function() DetectorLine:Remove() end)
end)

-- ============================================
-- FINAL PRINT
-- ============================================
print("[XYINHUB] v9.1 Paint or Seek Edition LOADED")
print("[XYINHUB] User: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId)
print("[XYINHUB] Role: " .. GameState.MyRole .. " | Phase: " .. GameState.RoundPhase)
print("[XYINHUB] Device: " .. (IsMobile and "Mobile" or "PC"))
print("[XYINHUB] Systems: ESP, AutoKill+TP, AutoSafe, SeekerDetector, Speed, Jump, Noclip, AutoCoin")
print("[XYINHUB] Hotkeys: RightAlt=Menu | Insert=ESP | Home=AutoKill | End=Coin | Delete=Speed | N=Noclip")
print("[XYINHUB] Round Timer: 3s warmup | 50s hiding | 3min round")
print("[XYINHUB] @RukanooXD_YT")
print("[XYINHUB] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")

-- ============================================
-- END OF XYINHUB v9.1
-- ============================================
