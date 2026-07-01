-- ============================================
-- XYINHUB v8.0 - PAINT OR SEEK EDITION
-- @RukanooXD_YT
-- Full Rebuild: Modern UI, Fixed Role Detection,
-- Instant AutoKill, Instant AutoCoin, No Delays
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")

-- ============================================
-- DEVICE DETECTION
-- ============================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScale = IsMobile and 0.78 or 1

-- ============================================
-- SETTINGS - NO DELAYS, INSTANT
-- ============================================
local Settings = {
    ESP = false,
    MaxDistance = 1500,
    AutoKill = false,
    AutoKillRadius = 50,
    TeleportHider = false,
    AutoCoin = false,
    SpeedHack = false,
    SpeedValue = 120,
    JumpHack = false,
    JumpValue = 150,
    AutoSafe = false,
    SafeDistance = 30,
    SeekerDetector = false,
    DetectorRange = 150,
    Noclip = false,
    Fly = false,
    FlySpeed = 80,
}

-- ============================================
-- GAME STATE - ENHANCED DETECTION
-- ============================================
local GameState = {
    InRound = false,
    MyRole = "Unknown",
    RoundTimer = nil,
}

local function UpdateGameState()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local inRound = false
    
    -- Check PlayerGui for round indicators
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                -- Round active indicators
                if text:match("round ends") or text:match("hiders left") or text:match("seekers left") 
                   or text:match("hiders:%s*%d+") or text:match("seekers:%s*%d+")
                   or text:match("time:") or text:match("timer:") then
                    inRound = true
                end
                -- Role detection from UI
                if text:match("you:%s*seeker") or text:match("you%s*seeker") 
                   or text:match("role:%s*seeker") or text:match("team:%s*seeker")
                   or text:match("you are a seeker") or text:match("you are seeker") then
                    GameState.MyRole = "Seeker"
                elseif text:match("you:%s*hider") or text:match("you%s*hider")
                   or text:match("role:%s*hider") or text:match("team:%s*hider")
                   or text:match("you are a hider") or text:match("you are hider") then
                    GameState.MyRole = "Hider"
                end
            end
        end
    end
    
    -- Check workspace for round indicators
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("BillboardGui") then
            local txt = ""
            pcall(function() txt = obj.Text:lower() end)
            if txt:match("hiders left") or txt:match("round ends") 
               or txt:match("seekers left") or txt:match("time remaining") then
                inRound = true
                break
            end
        end
    end
    
    -- Check if in lobby (no round + lobby elements exist)
    local isLobby = false
    if not inRound then
        if Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("Intermission")
           or Workspace:FindFirstChild("Waiting") or Workspace:FindFirstChild("Queue") then
            isLobby = true
        end
        -- Check for spawn/lobby specific UI
        if playerGui then
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("TextLabel") then
                    local text = gui.Text:lower()
                    if text:match("waiting for players") or text:match("intermission")
                       or text:match("vote") or text:match("lobby") then
                        isLobby = true
                        break
                    end
                end
            end
        end
    end
    
    GameState.InRound = inRound and not isLobby
end

task.spawn(function()
    while true do
        UpdateGameState()
        task.wait(0.2)
    end
end)

-- ============================================
-- ENHANCED ROLE DETECTION SYSTEM
-- ============================================
local function GetPlayerRole(p)
    if not p then return "Unknown" end
    
    -- Method 1: PlayerGui text (most reliable)
    local playerGui = p:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:match("you:%s*seeker") or text:match("you%s*seeker") 
                   or text:match("role:%s*seeker") or text:match("team:%s*seeker")
                   or text:match("you are a seeker") then
                    return "Seeker"
                end
                if text:match("you:%s*hider") or text:match("you%s*hider")
                   or text:match("role:%s*hider") or text:match("team:%s*hider")
                   or text:match("you are a hider") then
                    return "Hider"
                end
            end
        end
    end
    
    -- Method 2: Character attributes/values/tags
    local c = p.Character
    if c then
        -- Check for role indicator objects
        if c:FindFirstChild("Seeker") or c:FindFirstChild("IsSeeker") 
           or c:FindFirstChild("SeekerTag") or c:FindFirstChild("SeekerRole") then
            return "Seeker"
        end
        if c:FindFirstChild("Hider") or c:FindFirstChild("IsHider")
           or c:FindFirstChild("HiderTag") or c:FindFirstChild("HiderRole") then
            return "Hider"
        end
        
        -- Check for attributes
        local attrs = {"Role", "Team", "GameRole", "PlayerRole"}
        for _, attr in ipairs(attrs) do
            local val = c:GetAttribute(attr)
            if val then
                local v = tostring(val):lower()
                if v:match("seeker") then return "Seeker" end
                if v:match("hider") then return "Hider" end
            end
        end
        
        -- Method 3: Tool-based detection (Seekers have weapons)
        for _, tool in ipairs(c:GetChildren()) do
            if tool:IsA("Tool") then
                local tn = tool.Name:lower()
                if tn:match("paint") or tn:match("brush") or tn:match("bucket") 
                   or tn:match("seek") or tn:match("throw") or tn:match("knife")
                   or tn:match("sword") or tn:match("weapon") or tn:match("gun")
                   or tn:match("balloon") or tn:match("dart") then
                    return "Seeker"
                end
            end
        end
        
        -- Method 4: BillboardGui/NameTag tags
        for _, g in ipairs(c:GetDescendants()) do
            if g:IsA("BillboardGui") or g:IsA("TextLabel") then
                local txt = ""
                pcall(function() txt = g.Text:lower() end)
                if txt:match("seeker") and not txt:match("hider") then return "Seeker" end
                if txt:match("hider") and not txt:match("seeker") then return "Hider" end
            end
        end
    end
    
    -- Method 5: Backpack tool check
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local tn = tool.Name:lower()
                if tn:match("paint") or tn:match("brush") or tn:match("bucket")
                   or tn:match("seek") or tn:match("throw") or tn:match("knife")
                   or tn:match("sword") or tn:match("weapon") or tn:match("gun") then
                    return "Seeker"
                end
            end
        end
    end
    
    -- Method 6: Team-based inference
    if p == LocalPlayer then
        if GameState.MyRole ~= "Unknown" then
            return GameState.MyRole
        end
    else
        -- Infer from local player's role (opposite)
        local myRole = GetPlayerRole(LocalPlayer)
        if myRole == "Seeker" then return "Hider" end
        if myRole == "Hider" then return "Seeker" end
    end
    
    return "Unknown"
end

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
    return GetPlayerRole(LocalPlayer) == "Seeker"
end

-- ============================================
-- DRAWING MANAGER - ESP
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
-- ESP UPDATE - FIXED: NO LOBBY, REAL-TIME ROLE
-- ============================================
local function UpdateESP()
    if not Settings.ESP or not GameState.InRound then
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
        
        -- REAL-TIME ROLE DETECTION (not cached)
        local role = GetPlayerRole(p)
        local hp = hum.Health
        local maxHp = hum.MaxHealth
        
        local color = Color3.fromRGB(0,255,255) -- cyan default
        if role == "Seeker" then 
            color = Color3.fromRGB(255,50,50) -- red
        elseif role == "Hider" then 
            color = Color3.fromRGB(50,255,100) -- green
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
-- AUTO KILL - INSTANT THROW KILL, NO DELAY, BIG RADIUS
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
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(t)
                    task.wait(0.03)
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
        if not Settings.AutoKill then return end
        if not GameState.InRound then return end
        if not AmISeeker() then return end
        
        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        if not lHRP then return end
        
        local tool = GetTool()
        if not tool then return end
        
        local handle = tool:FindFirstChild("Handle")
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsHider(p) then continue end
            
            local c = p.Character
            local hrp = c and GetHRP(p)
            if not hrp then continue end
            
            local dist = (hrp.Position - lHRP.Position).Magnitude
            if dist > Settings.AutoKillRadius then continue end
            
            -- INSTANT THROW KILL
            pcall(function()
                local oldCFrame = lHRP.CFrame
                
                -- Face target
                lHRP.CFrame = CFrame.new(lHRP.Position, hrp.Position)
                
                -- Activate tool (throw)
                tool:Activate()
                
                -- Move handle through target for guaranteed hit
                if handle then
                    local oldHandleCF = handle.CFrame
                    
                    -- Teleport handle to target multiple times for hit registration
                    for i = 1, 3 do
                        handle.CFrame = hrp.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
                        firetouchinterest(handle, hrp, 0)
                        firetouchinterest(handle, hrp, 1)
                        
                        for _, part in ipairs(c:GetDescendants()) do
                            if part:IsA("BasePart") then
                                firetouchinterest(handle, part, 0)
                                firetouchinterest(handle, part, 1)
                            end
                        end
                    end
                    
                    handle.CFrame = oldHandleCF
                end
                
                -- Body touch fallback
                for _, part in ipairs(lChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        firetouchinterest(part, hrp, 0)
                        firetouchinterest(part, hrp, 1)
                    end
                end
                
                -- Return immediately
                lHRP.CFrame = oldCFrame
            end)
        end
        -- NO DELAY - instant loop
    end)
end

-- ============================================
-- AUTO SAFE
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
            local safePos = lHRP.Position + awayDir * 30
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
-- SEEKER DETECTOR
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
-- FLY
-- ============================================
local FlyConn = nil
local FlyBodyGyro = nil
local FlyBodyVelo = nil

local function StartFly()
    if FlyConn then return end
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelo then FlyBodyVelo:Destroy() end
        FlyBodyGyro = nil
        FlyBodyVelo = nil
    end)
    
    FlyConn = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyBodyVelo then FlyBodyVelo:Destroy() FlyBodyVelo = nil end
            return
        end
        
        local c = LocalPlayer.Character
        local hrp = c and GetHRP(LocalPlayer)
        if not hrp then return end
        
        if not FlyBodyGyro then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.P = 9e4
            FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            FlyBodyGyro.CFrame = hrp.CFrame
            FlyBodyGyro.Parent = hrp
        end
        
        if not FlyBodyVelo then
            FlyBodyVelo = Instance.new("BodyVelocity")
            FlyBodyVelo.Velocity = Vector3.new(0, 0, 0)
            FlyBodyVelo.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            FlyBodyVelo.Parent = hrp
        end
        
        local camCF = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * Settings.FlySpeed
        end
        
        FlyBodyGyro.CFrame = camCF
        FlyBodyVelo.Velocity = moveDir
    end)
end

-- ============================================
-- TELEPORT HIDER
-- ============================================
local TPConn = nil

local function StartTP()
    if TPConn then return end
    TPConn = task.spawn(function()
        while true do
            if not Settings.TeleportHider then
                task.wait(0.5)
                continue
            end
            if not AmISeeker() then
                task.wait(0.5)
                continue
            end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                if not IsHider(p) then continue end
                
                local c = p.Character
                local hrp = c and GetHRP(p)
                local lChar = LocalPlayer.Character
                local lHRP = lChar and GetHRP(LocalPlayer)
                
                if hrp and lHRP then
                    lHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
                    break -- teleport to first hider found
                end
            end
            task.wait(Settings.TeleportHider and 0.1 or 0.5)
        end
    end)
end

-- ============================================
-- AUTO COIN - INSTANT, DIRECT, NO BYPASS, ACCURATE
-- ============================================
local CoinConn = nil

local function IsCoin(obj)
    if not obj or not obj.Parent then return false end
    if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part")) then return false end
    
    local n = obj.Name:lower()
    local isCoinName = false
    
    -- Positive matches
    if n:match("coin") or n:match("money") or n:match("gold") or n:match("cash")
       or n:match("gem") or n:match("token") or n:match("collectible") or n:match("point")
       or n:match("star") or n:match("reward") or n:match("drop") or n:match("pickup")
       or n:match("loot") or n:match("bonus") or n:match("candy") or n:match("xp")
       or n:match("exp") or n:match("orb") or n:match("sphere") or n:match("bill") then
        isCoinName = true
    end
    
    if not isCoinName then return false end
    
    -- Negative matches (blacklist)
    local blacklist = {"invite", "friend", "gui", "button", "frame", "label", "menu", "shop",
        "settings", "inventory", "taunt", "pose", "lock", "paint", "troll", "become",
        "tiny", "giant", "portal", "spawn", "lobby", "home", "base", "checkpoint",
        "chest", "crate", "box", "camo", "sample", "fill", "brush", "bucket",
        "throw", "knife", "sword", "tool", "weapon", "handle", "hitbox"}
    
    for _, bl in ipairs(blacklist) do
        if n:match(bl) then return false end
    end
    
    -- Must have interaction capability
    local hasTouch = obj:FindFirstChildWhichIsA("TouchInterest") ~= nil
    local hasPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt") ~= nil
    local hasClick = obj:FindFirstChildWhichIsA("ClickDetector") ~= nil
    
    -- Also check parent for prompt
    if not hasPrompt then
        hasPrompt = obj.Parent and obj.Parent:FindFirstChildWhichIsA("ProximityPrompt") ~= nil
    end
    
    return hasTouch or hasPrompt or hasClick
end

local function FindCoins()
    local coins = {}
    local lChar = LocalPlayer.Character
    local lHRP = lChar and GetHRP(LocalPlayer)
    if not lHRP then return coins end
    
    -- Method 1: Scan workspace descendants
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsCoin(obj) then
            table.insert(coins, obj)
        end
    end
    
    -- Method 2: Check common coin containers
    local coinContainers = {"Coins", "CoinSpawns", "Drops", "Loot", "Collectibles", 
        "Rewards", "Items", "Pickups", "Spawns", "Map", "Game"}
    for _, name in ipairs(coinContainers) do
        local container = Workspace:FindFirstChild(name)
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if IsCoin(obj) then
                    local found = false
                    for _, c in ipairs(coins) do
                        if c == obj then found = true break end
                    end
                    if not found then
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
            if not Settings.AutoCoin then
                task.wait(0.3)
                continue
            end
            
            local coins = FindCoins()
            local lChar = LocalPlayer.Character
            local lHRP = lChar and GetHRP(LocalPlayer)
            
            if lHRP then
                for _, coin in ipairs(coins) do
                    if not Settings.AutoCoin then break end
                    if not coin or not coin.Parent then continue end
                    
                    local dist = (coin.Position - lHRP.Position).Magnitude
                    if dist < 400 then
                        pcall(function()
                            local oldPos = lHRP.CFrame
                            
                            -- INSTANT teleport to coin
                            lHRP.CFrame = coin.CFrame * CFrame.new(0, 2, 0)
                            
                            -- Touch with all parts
                            firetouchinterest(lHRP, coin, 0)
                            firetouchinterest(lHRP, coin, 1)
                            
                            for _, part in ipairs(lChar:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    firetouchinterest(part, coin, 0)
                                    firetouchinterest(part, coin, 1)
                                end
                            end
                            
                            -- Prompt
                            local prompt = coin:FindFirstChildWhichIsA("ProximityPrompt")
                            if not prompt and coin.Parent then
                                prompt = coin.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                            end
                            if prompt then
                                fireproximityprompt(prompt)
                            end
                            
                            -- Click detector
                            local clicker = coin:FindFirstChildWhichIsA("ClickDetector")
                            if clicker then
                                fireclickdetector(clicker)
                            end
                            
                            -- INSTANT return
                            lHRP.CFrame = oldPos
                        end)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- PLAYER EVENTS
-- ============================================
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
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
-- INITIALIZE SYSTEMS
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
StartAutoKill()
StartAutoSafe()
StartSeekerDetector()
StartSpeedHack()
StartJumpHack()
StartNoclip()
StartFly()
StartTP()
StartCoin()

-- ============================================
-- MODERN UI - FLUXUS/ARCEUS X STYLE
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "XyinHub_" .. tostring(math.random(10000, 99999))
SG.Parent = CoreGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 250, 0, 20)
Watermark.Position = UDim2.new(1, -260, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "@RukanooXD_YT | XYINHUB v8.0"
Watermark.TextColor3 = Color3.fromRGB(0, 255, 255)
Watermark.TextSize = 11
Watermark.Font = Enum.Font.GothamBold
Watermark.TextTransparency = 0.4
Watermark.Parent = SG

-- Loading Screen
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG

local LoadGradient = Instance.new("UIGradient")
LoadGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 16)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 12, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 16))
})
LoadGradient.Rotation = 45
LoadGradient.Parent = Loading

-- Animated particles
for i = 1, 20 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    p.BackgroundTransparency = math.random(6, 9) / 10
    p.BorderSizePixel = 0
    p.ZIndex = 10000
    p.Parent = Loading
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        while p.Parent do
            TweenService:Create(p, TweenInfo.new(math.random(2, 5)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(6, 9) / 10
            }):Play()
            task.wait(math.random(2, 5))
        end
    end)
end

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 500, 0, 70 * UIScale)
LogoText.Position = UDim2.new(0.5, -250, 0.3, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "XYINHUB"
LogoText.TextColor3 = Color3.fromRGB(0, 255, 255)
LogoText.TextSize = 52 * UIScale
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 10001
LogoText.Parent = Loading

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(0, 500, 0, 24 * UIScale)
SubText.Position = UDim2.new(0.5, -250, 0.38, 0)
SubText.BackgroundTransparency = 1
SubText.Text = "Paint or Seek Edition | v8.0"
SubText.TextColor3 = Color3.fromRGB(100, 200, 255)
SubText.TextSize = 14 * UIScale
SubText.Font = Enum.Font.GothamBold
SubText.ZIndex = 10001
SubText.Parent = Loading

local RoleText = Instance.new("TextLabel")
RoleText.Size = UDim2.new(0, 300, 0, 20 * UIScale)
RoleText.Position = UDim2.new(0.5, -150, 0.43, 0)
RoleText.BackgroundTransparency = 1
RoleText.Text = "Detecting Role..."
RoleText.TextColor3 = Color3.fromRGB(150, 150, 150)
RoleText.TextSize = 11 * UIScale
RoleText.Font = Enum.Font.Gotham
RoleText.ZIndex = 10001
RoleText.Parent = Loading

-- Update role text
task.spawn(function()
    while Loading.Parent do
        local role = GetPlayerRole(LocalPlayer)
        RoleText.Text = "You: " .. role .. " | " .. (GameState.InRound and "In Round" or "In Lobby")
        task.wait(0.5)
    end
end)

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 300 * UIScale, 0, 4)
BarBG.Position = UDim2.new(0.5, -150 * UIScale, 0.5, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 10001
BarBG.Parent = Loading
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 2)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10002
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 2)

local PctText = Instance.new("TextLabel")
PctText.Size = UDim2.new(0, 100, 0, 20 * UIScale)
PctText.Position = UDim2.new(0.5, -50, 0.52, 5)
PctText.BackgroundTransparency = 1
PctText.Text = "0%"
PctText.TextColor3 = Color3.fromRGB(0, 255, 255)
PctText.TextSize = 13 * UIScale
PctText.Font = Enum.Font.GothamBlack
PctText.ZIndex = 10001
PctText.Parent = Loading

task.spawn(function()
    local stages = {
        {pct = 12, txt = "Loading Core..."},
        {pct = 25, txt = "Initializing ESP..."},
        {pct = 38, txt = "Loading Combat..."},
        {pct = 50, txt = "Loading Movement..."},
        {pct = 62, txt = "Loading Utilities..."},
        {pct = 75, txt = "Building UI..."},
        {pct = 88, txt = "Finalizing..."},
        {pct = 100, txt = "Ready!"},
    }
    
    local cur = 0
    for _, s in ipairs(stages) do
        while cur < s.pct do
            cur = cur + math.random(1, 4)
            if cur > s.pct then cur = s.pct end
            BarFill.Size = UDim2.new(cur / 100, 0, 1, 0)
            PctText.Text = cur .. "%"
            task.wait(0.03)
        end
        task.wait(0.1)
    end
    
    task.wait(0.5)
    
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
-- MAIN MENU - MODERN DARK GLASS
-- ============================================
local MenuSize = IsMobile and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 420, 0, 560)
local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 200, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
MainGradient.Rotation = 135
MainGradient.Parent = Main

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 80, 1, 80)
Shadow.Position = UDim2.new(0, -40, 0, -40)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 56 * UIScale)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TitleBar

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 30, 0, 30)
TitleIcon.Position = UDim2.new(0, 14, 0, 13)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "◈"
TitleIcon.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleIcon.TextSize = 22
TitleIcon.Font = Enum.Font.GothamBlack
TitleIcon.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 26 * UIScale)
TitleText.Position = UDim2.new(0, 48, 0, 6)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XYINHUB"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0, 200, 0, 16 * UIScale)
TitleSub.Position = UDim2.new(0, 48, 0, 30)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "Paint or Seek | v8.0"
TitleSub.TextColor3 = Color3.fromRGB(100, 150, 200)
TitleSub.TextSize = 9 * UIScale
TitleSub.Font = Enum.Font.GothamBold
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = TitleBar

-- Role Display
local RoleDisplay = Instance.new("TextLabel")
RoleDisplay.Size = UDim2.new(0, 120, 0, 20 * UIScale)
RoleDisplay.Position = UDim2.new(1, -130, 0, 8)
RoleDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
RoleDisplay.Text = "You: Unknown"
RoleDisplay.TextColor3 = Color3.fromRGB(0, 255, 255)
RoleDisplay.TextSize = 10 * UIScale
RoleDisplay.Font = Enum.Font.GothamBold
RoleDisplay.Parent = TitleBar
Instance.new("UICorner", RoleDisplay).CornerRadius = UDim.new(0, 6)

-- Update role display
task.spawn(function()
    while RoleDisplay.Parent do
        local role = GetPlayerRole(LocalPlayer)
        RoleDisplay.Text = "You: " .. role
        if role == "Seeker" then
            RoleDisplay.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif role == "Hider" then
            RoleDisplay.TextColor3 = Color3.fromRGB(80, 255, 100)
        else
            RoleDisplay.TextColor3 = Color3.fromRGB(0, 255, 255)
        end
        task.wait(0.5)
    end
end)

-- Minimize & Close
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0, 14)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Tab Frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 36 * UIScale)
TabFrame.Position = UDim2.new(0, 10, 0, 58)
TabFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
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
    btn.Size = UDim2.new(0, 95 * UIScale, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(120, 120, 150)
    btn.TextSize = 10 * UIScale
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name
    content.Size = UDim2.new(1, -20, 1, -108 * UIScale)
    content.Position = UDim2.new(0, 10, 0, 98 * UIScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    content.CanvasSize = UDim2.new(0, 0, 0, 1200)
    content.Visible = false
    content.Parent = Main
    
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)
    
    table.insert(Tabs, btn)
    Contents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
            b.TextColor3 = Color3.fromRGB(120, 120, 150)
        end
        for _, c in pairs(Contents) do c.Visible = false end
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        content.Visible = true
    end)
    
    return content
end

local ESPContent = MakeTab("ESP", "◉")
local CombatContent = MakeTab("Combat", "⚔")
local MiscContent = MakeTab("Misc", "◆")
local PlayerContent = MakeTab("Player", "▲")

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Tabs[1].TextColor3 = Color3.fromRGB(0, 0, 0)
ESPContent.Visible = true

-- ============================================
-- UI COMPONENTS
-- ============================================
local function MakeToggle(parent, text, key, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 56 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, -10, 0, 22 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 255)
    lbl.TextSize = 12 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.55, -10, 0, 16 * UIScale)
        d.Position = UDim2.new(0, 14, 0, 28)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(80, 80, 100)
        d.TextSize = 9 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end
    
    -- Modern toggle
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 48, 0, 24)
    bg.Position = UDim2.new(1, -60, 0.5, -12)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0, 2, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
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
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 26, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 45)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(80, 80, 100)
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
    f.Size = UDim2.new(1, 0, 0, 58 * UIScale)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, -10, 0, 20 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 255)
    lbl.TextSize = 11 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.35, 0, 0, 20 * UIScale)
    val.Position = UDim2.new(0.65, 0, 0, 6)
    val.BackgroundTransparency = 1
    val.Text = tostring(Settings[key]) .. (suffix or "")
    val.TextColor3 = Color3.fromRGB(0, 255, 255)
    val.TextSize = 11 * UIScale
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = f
    
    local sbg = Instance.new("Frame")
    sbg.Size = UDim2.new(1, -28, 0, 5)
    sbg.Position = UDim2.new(0, 14, 0, 36 * UIScale)
    sbg.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    sbg.BorderSizePixel = 0
    sbg.Parent = f
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sbg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((Settings[key] - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sbg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, 22)
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
            knob.Position = UDim2.new(scale, -7, 0.5, -7)
            val.Text = tostring(value) .. (suffix or "")
        end
    end)
    
    return f
end

-- ============================================
-- TAB CONTENTS
-- ============================================

-- ESP Tab
MakeToggle(ESPContent, "ESP", "ESP", "Show all players with role")

-- Combat Tab
MakeToggle(CombatContent, "Auto Kill", "AutoKill", "Instant throw kill all hiders")
MakeSlider(CombatContent, "Kill Radius", "AutoKillRadius", 10, 100, " studs")
MakeToggle(CombatContent, "Teleport to Hider", "TeleportHider", "TP to hiders instantly")
MakeToggle(CombatContent, "Auto Safe", "AutoSafe", "Auto escape from seekers")
MakeSlider(CombatContent, "Safe Distance", "SafeDistance", 10, 80, " studs")
MakeToggle(CombatContent, "Seeker Detector", "SeekerDetector", "Alert when seeker nearby")
MakeSlider(CombatContent, "Detector Range", "DetectorRange", 50, 300, " studs")

-- Misc Tab
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin", "Instant collect all coins")
MakeToggle(MiscContent, "Noclip", "Noclip", "Walk through walls")
MakeToggle(MiscContent, "Fly", "Fly", "Fly mode (WASD + Space/Shift)")

-- Player Tab
MakeToggle(PlayerContent, "Speed Hack", "SpeedHack", "Super speed")
MakeSlider(PlayerContent, "Speed Value", "SpeedValue", 16, 500, "")
MakeToggle(PlayerContent, "Jump Hack", "JumpHack", "Super jump")
MakeSlider(PlayerContent, "Jump Power", "JumpValue", 50, 300, "")
MakeSlider(PlayerContent, "Fly Speed", "FlySpeed", 20, 200, "")

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
-- TOGGLE BUTTON
-- ============================================
local ToggleBtnSize = IsMobile and UDim2.new(0, 52, 0, 52) or UDim2.new(0, 48, 0, 48)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 16, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MenuBtn.Text = "X"
MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
MenuBtn.TextSize = 20 * UIScale
MenuBtn.Font = Enum.Font.GothamBlack
MenuBtn.Parent = SG

Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 14)

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(0, 200, 255)
BtnStroke.Thickness = 2
BtnStroke.Parent = MenuBtn

local -- ============================================
-- PART 2 CONTINUED - UI MODERN (LANJUTAN)
-- ============================================

-- BtnGlow animation (lanjutan dari terputus)
local BtnGlow = Instance.new("ImageLabel")
BtnGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
BtnGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
BtnGlow.BackgroundTransparency = 1
BtnGlow.Image = "rbxassetid://10822646370"
BtnGlow.ImageColor3 = Color3.fromRGB(0, 200, 255)
BtnGlow.ImageTransparency = 0.6
BtnGlow.Parent = MenuBtn

task.spawn(function()
    while MenuBtn.Parent do
        TweenService:Create(BtnGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.3}):Play()
        task.wait(1.2)
        TweenService:Create(BtnGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.7}):Play()
        task.wait(1.2)
    end
end)

-- MenuBtn click handler
MenuBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = MenuSize}):Play()
    else
        MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
    end
end)

-- Minimize button
MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
end)

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Toggle menu: RightAlt
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Main.Visible = not Main.Visible
        if Main.Visible then
            MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
            MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
            MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        end
    end
    
    -- Hotkeys
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.ESP = not Settings.ESP
    end
    if input.KeyCode == Enum.KeyCode.Home then
        Settings.AutoKill = not Settings.AutoKill
    end
    if input.KeyCode == Enum.KeyCode.PageUp then
        Settings.TeleportHider = not Settings.TeleportHider
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
    if input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
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
NotifFrame.Size = UDim2.new(0, 360 * UIScale, 0, 80 * UIScale)
NotifFrame.Position = UDim2.new(1, 20, 1, 20)
NotifFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = SG
Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 14)

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Color3.fromRGB(0, 200, 255)
NotifStroke.Thickness = 1.5
NotifStroke.Transparency = 0.4
NotifStroke.Parent = NotifFrame

local NotifAccent = Instance.new("Frame")
NotifAccent.Size = UDim2.new(0, 4, 1, 0)
NotifAccent.Position = UDim2.new(0, 0, 0, 0)
NotifAccent.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
NotifAccent.BorderSizePixel = 0
NotifAccent.Parent = NotifFrame
Instance.new("UICorner", NotifAccent).CornerRadius = UDim.new(0, 14)

local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size = UDim2.new(1, -24, 0, 24 * UIScale)
NotifTitle.Position = UDim2.new(0, 14, 0, 8)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "XYINHUB v8.0 LOADED"
NotifTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
NotifTitle.TextSize = 14 * UIScale
NotifTitle.Font = Enum.Font.GothamBlack
NotifTitle.Parent = NotifFrame

local NotifRole = Instance.new("TextLabel")
NotifRole.Size = UDim2.new(1, -24, 0, 18 * UIScale)
NotifRole.Position = UDim2.new(0, 14, 0, 32)
NotifRole.BackgroundTransparency = 1
NotifRole.Text = "Role: Detecting..."
NotifRole.TextColor3 = Color3.fromRGB(180, 180, 200)
NotifRole.TextSize = 10 * UIScale
NotifRole.Font = Enum.Font.GothamBold
NotifRole.Parent = NotifFrame

-- Update role in notification
task.spawn(function()
    while NotifRole.Parent do
        local role = GetPlayerRole(LocalPlayer)
        NotifRole.Text = "User: " .. LocalPlayer.Name .. " | Role: " .. role .. " | " .. (GameState.InRound and "In Round" or "Lobby")
        if role == "Seeker" then
            NotifRole.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif role == "Hider" then
            NotifRole.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            NotifRole.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        task.wait(0.5)
    end
end)

local NotifVer = Instance.new("TextLabel")
NotifVer.Size = UDim2.new(1, -24, 0, 16 * UIScale)
NotifVer.Position = UDim2.new(0, 14, 0, 52)
NotifVer.BackgroundTransparency = 1
NotifVer.Text = "Paint or Seek | @RukanooXD_YT"
NotifVer.TextColor3 = Color3.fromRGB(100, 100, 120)
NotifVer.TextSize = 9 * UIScale
NotifVer.Font = Enum.Font.Gotham
NotifVer.Parent = NotifFrame

-- Animate notification in
NotifFrame:TweenPosition(UDim2.new(1, -380 * UIScale, 1, -90 * UIScale), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5)

-- Auto dismiss
task.delay(10, function()
    NotifFrame:TweenPosition(UDim2.new(1, 20, 1, 20), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.4)
    task.wait(0.5)
    NotifFrame:Destroy()
end)

-- ============================================
-- REAL-TIME ROLE DISPLAY IN MENU
-- ============================================
task.spawn(function()
    while TitleBar and TitleBar.Parent do
        local role = GetPlayerRole(LocalPlayer)
        if RoleDisplay and RoleDisplay.Parent then
            RoleDisplay.Text = "You: " .. role
            if role == "Seeker" then
                RoleDisplay.TextColor3 = Color3.fromRGB(255, 80, 80)
                RoleDisplay.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
            elseif role == "Hider" then
                RoleDisplay.TextColor3 = Color3.fromRGB(80, 255, 100)
                RoleDisplay.BackgroundColor3 = Color3.fromRGB(15, 40, 20)
            else
                RoleDisplay.TextColor3 = Color3.fromRGB(0, 255, 255)
                RoleDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
            end
        end
        task.wait(0.3)
    end
end)

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
    if FlyConn then pcall(function() FlyConn:Disconnect() end) end
    if FlyBodyGyro then pcall(function() FlyBodyGyro:Destroy() end) end
    if FlyBodyVelo then pcall(function() FlyBodyVelo:Destroy() end) end
    pcall(function() DetectorText:Remove() end)
    pcall(function() DetectorLine:Remove() end)
end)

-- ============================================
-- FINAL PRINT
-- ============================================
print("[XYINHUB] v8.0 Paint or Seek Edition LOADED")
print("[XYINHUB] User: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId)
print("[XYINHUB] Role: " .. GetPlayerRole(LocalPlayer))
print("[XYINHUB] Device: " .. (IsMobile and "Mobile" or "PC"))
print("[XYINHUB] Systems: ESP, AutoKill, AutoSafe, SeekerDetector, Speed, Jump, Noclip, Fly, AutoCoin, TeleportHider")
print("[XYINHUB] Hotkeys: RightAlt=Menu | Insert=ESP | Home=AutoKill | PageUp=TPHider | End=Coin | Delete=Speed | N=Noclip | F=Fly")
print("[XYINHUB] @RukanooXD_YT")
print("[XYINHUB] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")

-- ============================================
-- END OF XYINHUB v8.0
-- ============================================
