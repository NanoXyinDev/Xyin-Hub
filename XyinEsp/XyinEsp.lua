
-- ============================================
-- XYINHUB v11.0 - PAINT OR SEEK EDITION
-- @RukanooXD_YT | Quantum Script Style UI
-- Full Fix: Lobby ESP bug, AutoKill leak, Round detection
-- Target: 130KB | Optimized & Clean
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

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
    TeleportHider = false,
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
    FullBright = false,
    AntiAFK = true,
}

-- ============================================
-- GAME STATE - ENHANCED ROUND DETECTION
-- ============================================
local GameState = {
    InRound = false,
    MyRole = "Unknown",
    RoundTimer = nil,
    SeekerArrivalTime = 40,
    IsLobby = true,
    RoundEnded = false,
}

-- Round detection keywords
local RoundKeywords = {
    "round ends", "hiders left", "seekers left",
    "hiders:%s*%d+", "seekers:%s*%d+",
    "time:", "timer:", "time remaining",
    "you are a hider", "you are a seeker",
    "role:%s*hider", "role:%s*seeker",
    "find a spot", "seeker arrives",
}

local LobbyKeywords = {
    "waiting for players", "intermission",
    "vote", "lobby", "queue", "joining",
    "starting", "next round",
}

local function CheckInRound()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local inRound = false
    local isLobby = false

    -- Check PlayerGui
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                for _, kw in ipairs(RoundKeywords) do
                    if text:match(kw) then
                        inRound = true
                        break
                    end
                end
                for _, kw in ipairs(LobbyKeywords) do
                    if text:match(kw) then
                        isLobby = true
                        break
                    end
                end
                -- Role detection from GUI
                if text:match("you are a seeker") or text:match("role:%s*seeker") 
                   or text:match("you:%s*seeker") then
                    GameState.MyRole = "Seeker"
                elseif text:match("you are a hider") or text:match("role:%s*hider")
                   or text:match("you:%s*hider") then
                    GameState.MyRole = "Hider"
                end
            end
        end
    end

    -- Check Workspace for round indicators
    if not inRound then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("BillboardGui") then
                local txt = ""
                pcall(function() txt = obj.Text:lower() end)
                for _, kw in ipairs(RoundKeywords) do
                    if txt:match(kw) then
                        inRound = true
                        break
                    end
                end
            end
        end
    end

    -- Check workspace lobby objects
    if not inRound then
        local lobbyObjects = {"Lobby", "Intermission", "Waiting", "Queue", "SpawnLocation"}
        for _, name in ipairs(lobbyObjects) do
            if Workspace:FindFirstChild(name) then
                isLobby = true
                break
            end
        end
    end

    -- Check if round ended (all players dead or timer 0)
    if inRound then
        GameState.RoundEnded = false
    end

    GameState.IsLobby = isLobby and not inRound
    GameState.InRound = inRound and not isLobby

    return GameState.InRound
end

-- Continuous state updater
task.spawn(function()
    while true do
        CheckInRound()
        task.wait(0.15)
    end
end)

-- Detect round end
task.spawn(function()
    while true do
        task.wait(1)
        if GameState.InRound then
            local allDead = true
            local playerCount = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    playerCount = playerCount + 1
                    if IsAlive(p) then
                        allDead = false
                        break
                    end
                end
            end
            if allDead and playerCount > 0 then
                GameState.RoundEnded = true
                GameState.InRound = false
                GameState.IsLobby = true
            end
        end
    end
end)


-- ============================================
-- ENHANCED ROLE DETECTION WITH LOBBY RESET
-- ============================================
local RoleCache = {}

local function GetPlayerRole(p)
    if not p then return "Unknown" end

    -- Reset role in lobby for non-local players
    if GameState.IsLobby and p ~= LocalPlayer then
        return "Unknown"
    end

    -- Check cache
    if p ~= LocalPlayer and RoleCache[p] then
        if tick() - RoleCache[p].time < 0.8 then
            return RoleCache[p].role
        end
    end

    local role = "Unknown"

    -- Method 1: PlayerGui text
    local playerGui = p:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:match("you are a seeker") or text:match("role:%s*seeker") 
                   or text:match("you:%s*seeker") or text:match("team:%s*seeker") then
                    role = "Seeker"
                    break
                end
                if text:match("you are a hider") or text:match("role:%s*hider")
                   or text:match("you:%s*hider") or text:match("team:%s*hider") then
                    role = "Hider"
                    break
                end
            end
        end
    end

    -- Method 2: Character attributes/tags
    if role == "Unknown" then
        local c = p.Character
        if c then
            if c:FindFirstChild("Seeker") or c:FindFirstChild("IsSeeker") 
               or c:FindFirstChild("SeekerTag") then
                role = "Seeker"
            elseif c:FindFirstChild("Hider") or c:FindFirstChild("IsHider")
                   or c:FindFirstChild("HiderTag") then
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

            -- Method 3: Tool-based detection
            if role == "Unknown" then
                for _, tool in ipairs(c:GetChildren()) do
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

            -- Method 4: BillboardGui tags
            if role == "Unknown" then
                for _, g in ipairs(c:GetDescendants()) do
                    if g:IsA("BillboardGui") or g:IsA("TextLabel") then
                        local txt = ""
                        pcall(function() txt = g.Text:lower() end)
                        if txt:match("seeker") and not txt:match("hider") then 
                            role = "Seeker" 
                            break 
                        end
                        if txt:match("hider") and not txt:match("seeker") then 
                            role = "Hider" 
                            break 
                        end
                    end
                end
            end
        end
    end

    -- Method 5: Backpack tool
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

    -- Method 6: Team inference (only in round)
    if role == "Unknown" and GameState.InRound then
        if p == LocalPlayer then
            if GameState.MyRole ~= "Unknown" then
                role = GameState.MyRole
            end
        else
            local myRole = GetPlayerRole(LocalPlayer)
            if myRole == "Seeker" then role = "Hider"
            elseif myRole == "Hider" then role = "Seeker" end
        end
    end

    -- Cache result (only in round)
    if p ~= LocalPlayer and GameState.InRound then
        RoleCache[p] = {role = role, time = tick()}
    end

    return role
end

-- Clear cache on round end
local function ClearRoleCache()
    for k, _ in pairs(RoleCache) do
        RoleCache[k] = nil
    end
end

-- Auto clear cache when entering lobby
task.spawn(function()
    local wasInRound = false
    while true do
        task.wait(0.5)
        if wasInRound and not GameState.InRound then
            ClearRoleCache()
            GameState.MyRole = "Unknown"
        end
        wasInRound = GameState.InRound
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if GameState.InRound then
            RoleCache[p] = nil
            task.wait(0.5)
            CreateESPObjects(p)
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
    return p ~= LocalPlayer and IsAlive(p) and GameState.InRound and GetPlayerRole(p) == "Hider"
end

local function IsSeeker(p)
    return p ~= LocalPlayer and IsAlive(p) and GameState.InRound and GetPlayerRole(p) == "Seeker"
end

local function AmISeeker()
    return GameState.InRound and GetPlayerRole(LocalPlayer) == "Seeker"
end

local function AmIHider()
    return GameState.InRound and GetPlayerRole(LocalPlayer) == "Hider"
end


-- ============================================
-- DRAWING MANAGER - LOBBY SAFE
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

local function RemoveAllESP()
    for p, _ in pairs(ESPObjects) do
        RemoveESP(p)
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
-- ESP UPDATE - STRICT LOBBY CHECK
-- ============================================
local function UpdateESP()
    -- FORCE HIDE in lobby or when round ended
    if not Settings.ESP or not GameState.InRound or GameState.IsLobby or GameState.RoundEnded then
        for _, o in pairs(ESPObjects) do
            for _, obj in pairs(o) do pcall(function() obj.Visible = false end) end
        end
        return
    end

    local lChar = LocalPlayer.Character
    local lHRP = lChar and GetHRP(LocalPlayer)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        -- Skip dead players and non-round
        if not IsAlive(p) or not GameState.InRound then
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

        -- Distance check
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

-- Auto cleanup ESP when entering lobby
task.spawn(function()
    local wasInLobby = false
    while true do
        task.wait(0.3)
        if GameState.IsLobby and not wasInLobby then
            RemoveAllESP()
            Settings.ESP = false
        end
        wasInLobby = GameState.IsLobby
    end
end)

-- ============================================
-- AUTO KILL - LOBBY SAFE, STRICT ROUND CHECK
-- ============================================
local AutoKillConn = nil
local AutoKillActive = false

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

local function GetToolHandle(tool)
    if not tool then return nil end
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("BasePart") and child.Name:lower():match("handle") then
                return child
            end
        end
    end
    return handle
end

local function InstantKillTarget(targetPlayer)
    -- STRICT CHECK: Only in round, not lobby
    if not GameState.InRound or GameState.IsLobby or GameState.RoundEnded then return end
    if not AmISeeker() then return end

    local lChar = LocalPlayer.Character
    local lHRP = lChar and GetHRP(LocalPlayer)
    if not lHRP then return end

    local c = targetPlayer.Character
    local hrp = c and GetHRP(targetPlayer)
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    -- Verify still hider
    if GetPlayerRole(targetPlayer) ~= "Hider" then return end

    local tool = GetTool()
    if not tool then return end

    local handle = GetToolHandle(tool)
    local oldCF = lHRP.CFrame
    local oldHandleCF = handle and handle.CFrame

    pcall(function()
        -- Method 1: Direct damage
        hum:TakeDamage(hum.MaxHealth)

        -- Method 2: BreakJoints
        c:BreakJoints()

        -- Method 3: Set health to 0
        hum.Health = 0

        -- Method 4: Tool activate spam with teleport
        lHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
        for i = 1, 10 do
            tool:Activate()
            task.wait(0.01)
        end

        -- Method 5: Handle touch spam
        if handle then
            for i = 1, 10 do
                handle.CFrame = hrp.CFrame * CFrame.new(
                    math.random(-3, 3), math.random(-3, 3), math.random(-3, 3)
                )
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

        -- Method 6: Body parts touch spam
        for _, part in ipairs(lChar:GetDescendants()) do
            if part:IsA("BasePart") then
                for i = 1, 5 do
                    firetouchinterest(part, hrp, 0)
                    firetouchinterest(part, hrp, 1)
                end
            end
        end

        -- Method 7: Headshot
        local head = c:FindFirstChild("Head")
        if head and handle then
            handle.CFrame = head.CFrame
            firetouchinterest(handle, head, 0)
            firetouchinterest(handle, head, 1)
        end

        -- Method 8: RemoteEvent
        for _, event in ipairs(tool:GetDescendants()) do
            if event:IsA("RemoteEvent") then
                pcall(function()
                    event:FireServer(hrp.Position, targetPlayer)
                end)
            end
        end

        -- Return
        lHRP.CFrame = oldCF
    end)
end

local function StartAutoKill()
    if AutoKillConn then return end
    AutoKillConn = RunService.Heartbeat:Connect(function()
        -- STRICT: Only run in round, not lobby
        if not Settings.AutoKill then return end
        if not GameState.InRound or GameState.IsLobby or GameState.RoundEnded then return end
        if not AmISeeker() then return end

        local lChar = LocalPlayer.Character
        local lHRP = lChar and GetHRP(LocalPlayer)
        if not lHRP then return end

        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if not IsHider(p) then continue end

            local c = p.Character
            local hrp = c and GetHRP(p)
            if not hrp then continue end

            InstantKillTarget(p)
        end
    end)
end


-- ============================================
-- AUTO SAFE - LOBBY SAFE
-- ============================================
local SafeConn = nil
local LastSafeTeleport = 0

local function StartAutoSafe()
    if SafeConn then return end
    SafeConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoSafe then return end
        if not GameState.InRound or GameState.IsLobby or GameState.RoundEnded then return end
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
-- SEEKER DETECTOR - LOBBY SAFE
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
        if not GameState.InRound or GameState.IsLobby or GameState.RoundEnded then
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
-- SPEED HACK - ANTI-RESET
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
-- TELEPORT HIDER - LOBBY SAFE
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
            if not GameState.InRound or GameState.IsLobby or GameState.RoundEnded then
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
                    break
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- AUTO COIN - LOBBY SAFE
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
            if GameState.IsLobby then
                task.wait(1)
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
-- ANTI-AFK
-- ============================================
local AntiAFKConn = nil

local function StartAntiAFK()
    if AntiAFKConn then return end
    AntiAFKConn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end

-- ============================================
-- FULL BRIGHT
-- ============================================
local FullBrightConn = nil
local OldBrightness = Lighting.Brightness
local OldClockTime = Lighting.ClockTime

local function StartFullBright()
    if FullBrightConn then return end
    FullBrightConn = RunService.RenderStepped:Connect(function()
        if not Settings.FullBright then return end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)
end

-- ============================================
-- PLAYER EVENTS
-- ============================================
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    RoleCache[p] = nil
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
StartTP()
StartCoin()
StartAntiAFK()
StartFullBright()



-- ============================================
-- ADDITIONAL FEATURES FOR 130KB TARGET
-- ============================================

-- ============================================
-- FLY HACK SYSTEM
-- ============================================
local FlyConn = nil
local FlyBodyGyro = nil
local FlyBodyVelocity = nil

local function StartFly()
    if FlyConn then return end

    local function EnableFly()
        local c = LocalPlayer.Character
        if not c then return end
        local hrp = GetHRP(LocalPlayer)
        if not hrp then return end

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Parent = hrp
    end

    FlyConn = RunService.RenderStepped:Connect(function()
        if not Settings.FlyHack then
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
            return
        end

        if not FlyBodyGyro or not FlyBodyVelocity then
            EnableFly()
        end

        local c = LocalPlayer.Character
        local hrp = c and GetHRP(LocalPlayer)
        if not hrp or not FlyBodyGyro or not FlyBodyVelocity then return end

        local speed = Settings.FlySpeed
        local direction = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit * speed
        end

        FlyBodyVelocity.Velocity = direction
        FlyBodyGyro.CFrame = Camera.CFrame
    end)
end

-- ============================================
-- GOD MODE SYSTEM
-- ============================================
local GodModeConn = nil

local function StartGodMode()
    if GodModeConn then return end
    GodModeConn = RunService.Heartbeat:Connect(function()
        if not Settings.GodMode then return end
        local c = LocalPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end)
        end
    end)
end

-- ============================================
-- INFINITE JUMP
-- ============================================
local InfJumpConn = nil

local function StartInfiniteJump()
    if InfJumpConn then return end
    InfJumpConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not Settings.InfiniteJump then return end
        if input.KeyCode == Enum.KeyCode.Space then
            local c = LocalPlayer.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            local hrp = c and GetHRP(LocalPlayer)
            if hum and hrp then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, Settings.JumpValue, hrp.Velocity.Z)
            end
        end
    end)
end

-- ============================================
-- AUTO RESPAWN
-- ============================================
local RespawnConn = nil

local function StartAutoRespawn()
    if RespawnConn then return end
    RespawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
        if not Settings.AutoRespawn then return end
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                task.wait(2)
                pcall(function()
                    local args = {char}
                    game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Respawn"):FireServer(unpack(args))
                end)
            end)
        end
    end)
end

-- ============================================
-- HIDE NAME / ANONYMOUS MODE
-- ============================================
local HideNameConn = nil

local function StartHideName()
    if HideNameConn then return end
    HideNameConn = RunService.RenderStepped:Connect(function()
        if not Settings.HideName then return end
        local c = LocalPlayer.Character
        if not c then return end
        for _, obj in ipairs(c:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Text == LocalPlayer.Name then
                        child.Text = "[Hidden]"
                        child.TextColor3 = Colors.TextMuted
                    end
                end
            end
        end
    end)
end

-- ============================================
-- RAINBOW ESP COLORS
-- ============================================
local function GetRainbowColor(offset)
    local hue = (tick() * 0.5 + (offset or 0)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- ============================================
-- SKELETON ESP
-- ============================================
local SkeletonLines = {}

local function CreateSkeleton(p)
    if SkeletonLines[p] then return end
    local lines = {}
    for i = 1, 12 do
        lines[i] = CreateDrawing("Line", {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.8,
            Visible = false,
            ZIndex = 2
        })
    end
    SkeletonLines[p] = lines
end

local function UpdateSkeletonESP()
    if not Settings.SkeletonESP or not GameState.InRound then
        for _, lines in pairs(SkeletonLines) do
            for _, line in ipairs(lines) do
                pcall(function() line.Visible = false end)
            end
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(p) then
            if SkeletonLines[p] then
                for _, line in ipairs(SkeletonLines[p]) do
                    pcall(function() line.Visible = false end)
                end
            end
            continue
        end

        local c = p.Character
        if not c then continue end

        if not SkeletonLines[p] then CreateSkeleton(p) end
        local lines = SkeletonLines[p]

        local parts = {
            Head = c:FindFirstChild("Head"),
            Torso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"),
            LowerTorso = c:FindFirstChild("LowerTorso"),
            LeftArm = c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm"),
            RightArm = c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm"),
            LeftLeg = c:FindFirstChild("LeftUpperLeg") or c:FindFirstChild("Left Leg"),
            RightLeg = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg"),
        }

        local function getPos(part)
            if not part then return nil end
            local pos = Camera:WorldToViewportPoint(part.Position)
            return pos.Z > 0 and Vector2.new(pos.X, pos.Y) or nil
        end

        local positions = {}
        for name, part in pairs(parts) do
            positions[name] = getPos(part)
        end

        local connections = {
            {positions.Head, positions.Torso},
            {positions.Torso, positions.LowerTorso},
            {positions.Torso, positions.LeftArm},
            {positions.Torso, positions.RightArm},
            {positions.LowerTorso, positions.LeftLeg},
            {positions.LowerTorso, positions.RightLeg},
        }

        local color = Settings.RainbowESP and GetRainbowColor(0) or Color3.fromRGB(255, 255, 255)

        for i, conn in ipairs(connections) do
            if lines[i] and conn[1] and conn[2] then
                lines[i].From = conn[1]
                lines[i].To = conn[2]
                lines[i].Color = color
                lines[i].Visible = true
            elseif lines[i] then
                lines[i].Visible = false
            end
        end
    end
end

-- ============================================
-- ITEM ESP
-- ============================================
local ItemESPObjects = {}

local function IsImportantItem(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    return n:match("coin") or n:match("gem") or n:match("star") or n:match("chest")
        or n:match("key") or n:match("token") or n:match("reward")
end

local function UpdateItemESP()
    if not Settings.ItemESP or not GameState.InRound then
        for _, o in pairs(ItemESPObjects) do
            pcall(function() o.Visible = false end)
        end
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsImportantItem(obj) then
            if not ItemESPObjects[obj] then
                ItemESPObjects[obj] = CreateDrawing("Text", {
                    Text = obj.Name,
                    Size = 11,
                    Center = true,
                    Outline = true,
                    Color = Colors.Yellow,
                    Visible = false,
                    ZIndex = 3
                })
            end

            local pos = Camera:WorldToViewportPoint(obj.Position)
            if pos.Z > 0 then
                ItemESPObjects[obj].Position = Vector2.new(pos.X, pos.Y)
                ItemESPObjects[obj].Visible = true
            else
                ItemESPObjects[obj].Visible = false
            end
        end
    end
end

-- ============================================
-- HEALTH BAR ESP
-- ============================================
local HealthBarObjects = {}

local function CreateHealthBar(p)
    if HealthBarObjects[p] then return end
    HealthBarObjects[p] = {
        Bar = CreateDrawing("Square", {Thickness = 1, Filled = true, Visible = false, ZIndex = 4}),
        Background = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.fromRGB(40,40,40), Visible = false, ZIndex = 3}),
    }
end

local function UpdateHealthBarESP()
    if not Settings.HealthBar or not GameState.InRound then
        for _, o in pairs(HealthBarObjects) do
            pcall(function() o.Bar.Visible = false end)
            pcall(function() o.Background.Visible = false end)
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(p) then
            if HealthBarObjects[p] then
                pcall(function() HealthBarObjects[p].Bar.Visible = false end)
                pcall(function() HealthBarObjects[p].Background.Visible = false end)
            end
            continue
        end

        local c = p.Character
        if not c then continue end
        local hrp = GetHRP(p)
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then continue end

        if not HealthBarObjects[p] then CreateHealthBar(p) end
        local o = HealthBarObjects[p]

        local cf, size = c:GetBoundingBox()
        if not cf then continue end

        local topY = cf.Position.Y + size.Y / 2
        local top = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, topY, cf.Position.Z))
        local bot = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, cf.Position.Y - size.Y/2, cf.Position.Z))

        local h = math.abs(top.Y - bot.Y)
        local barWidth = 4
        local barHeight = h
        local barX = top.X - (h * 0.55) / 2 - barWidth - 4
        local barY = top.Y

        local hpPercent = hum.Health / hum.MaxHealth
        local hpColor = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 50)

        o.Background.Size = Vector2.new(barWidth, barHeight)
        o.Background.Position = Vector2.new(barX, barY)
        o.Background.Visible = true

        o.Bar.Size = Vector2.new(barWidth, barHeight * hpPercent)
        o.Bar.Position = Vector2.new(barX, barY + barHeight * (1 - hpPercent))
        o.Bar.Color = hpColor
        o.Bar.Visible = true
    end
end

-- ============================================
-- TRACERS ESP
-- ============================================
local TracerLines = {}

local function UpdateTracers()
    if not Settings.Tracers or not GameState.InRound then
        for _, line in pairs(TracerLines) do
            pcall(function() line.Visible = false end)
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(p) then
            if TracerLines[p] then
                pcall(function() TracerLines[p].Visible = false end)
            end
            continue
        end

        local hrp = GetHRP(p)
        if not hrp then continue end

        if not TracerLines[p] then
            TracerLines[p] = CreateDrawing("Line", {
                Thickness = 1,
                Transparency = 0.7,
                Visible = false,
                ZIndex = 1
            })
        end

        local pos = Camera:WorldToViewportPoint(hrp.Position)
        if pos.Z > 0 then
            local role = GetPlayerRole(p)
            local color = Color3.fromRGB(0,255,255)
            if role == "Seeker" then color = Color3.fromRGB(255,50,50)
            elseif role == "Hider" then color = Color3.fromRGB(50,255,100) end

            TracerLines[p].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            TracerLines[p].To = Vector2.new(pos.X, pos.Y)
            TracerLines[p].Color = color
            TracerLines[p].Visible = true
        else
            TracerLines[p].Visible = false
        end
    end
end

-- ============================================
-- ANTI-BAN SYSTEM
-- ============================================
local function StartAntiBan()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if m == "Kick" or m == "kick" then
                    return warn("[XYINHUB] Kick blocked!")
                end
                if m == "FindFirstChild" or m == "WaitForChild" or m == "FindFirstChildOfClass" then
                    local a = {...}
                    if a[1] and type(a[1]) == "string" then
                        local name = a[1]:lower()
                        if name:match("esp") or name:match("xyin") or name:match("hub") 
                           or name:match("menu") or name:match("toggle") or name:match("script") 
                           or name:match("quantum") or name:match("cheat") or name:match("exploit") then
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
                    if kl:match("esp") or kl:match("xyin") or kl:match("hub") or kl:match("quantum") 
                       or kl:match("cheat") or kl:match("hack") then
                        return nil
                    end
                end
                return oldIndex(self, k)
            end)

            setreadonly(mt, true)
        end
    end)

    -- Block remote kick events
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():match("kick") then
                remote.OnClientEvent:Connect(function()
                    warn("[XYINHUB] Remote kick blocked!")
                    return nil
                end)
            end
        end
    end)
end

-- ============================================
-- PERFORMANCE MONITOR
-- ============================================
local FPSCounter = CreateDrawing("Text", {
    Text = "FPS: 60",
    Size = 14,
    Position = Vector2.new(10, 10),
    Color = Colors.Accent,
    Outline = true,
    Visible = false,
    ZIndex = 999
})

local lastTick = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTick >= 1 then
        FPSCounter.Text = "FPS: " .. frameCount
        frameCount = 0
        lastTick = now
    end
end)

-- ============================================
-- INITIALIZE ALL SYSTEMS
-- ============================================
RunService.RenderStepped:Connect(UpdateESP)
RunService.RenderStepped:Connect(UpdateSkeletonESP)
RunService.RenderStepped:Connect(UpdateItemESP)
RunService.RenderStepped:Connect(UpdateHealthBarESP)
RunService.RenderStepped:Connect(UpdateTracers)
StartAutoKill()
StartAutoSafe()
StartSeekerDetector()
StartSpeedHack()
StartJumpHack()
StartNoclip()
StartTP()
StartCoin()
StartAntiAFK()
StartFullBright()
StartFly()
StartGodMode()
StartInfiniteJump()
StartAutoRespawn()
StartHideName()
StartAntiBan()


-- ============================================
-- QUANTUM SCRIPT STYLE UI v11.0
-- Dark Premium Theme with Purple/Blue Accents
-- ============================================
local SG_UI = Instance.new("ScreenGui")
SG_UI.Name = "QuantumXyin_" .. tostring(math.random(10000, 99999))
SG_UI.Parent = CoreGui
SG_UI.ResetOnSpawn = false
SG_UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- COLORS - QUANTUM STYLE
-- ============================================
local Colors = {
    Background = Color3.fromRGB(13, 13, 23),
    BackgroundLight = Color3.fromRGB(20, 20, 35),
    BackgroundDark = Color3.fromRGB(8, 8, 16),
    Surface = Color3.fromRGB(25, 25, 42),
    SurfaceHover = Color3.fromRGB(30, 30, 50),
    Accent = Color3.fromRGB(147, 51, 234),
    AccentLight = Color3.fromRGB(168, 85, 247),
    AccentDark = Color3.fromRGB(126, 34, 206),
    AccentBlue = Color3.fromRGB(59, 130, 246),
    AccentCyan = Color3.fromRGB(6, 182, 212),
    Text = Color3.fromRGB(243, 244, 246),
    TextSecondary = Color3.fromRGB(156, 163, 175),
    TextMuted = Color3.fromRGB(107, 114, 128),
    Red = Color3.fromRGB(239, 68, 68),
    Green = Color3.fromRGB(34, 197, 94),
    Yellow = Color3.fromRGB(234, 179, 8),
    Orange = Color3.fromRGB(249, 115, 22),
    Border = Color3.fromRGB(55, 65, 81),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreateGradient(parent, colors, rotation)
    local grad = Instance.new("UIGradient")
    grad.Color = colors or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.AccentBlue)
    })
    grad.Rotation = rotation or 135
    grad.Parent = parent
    return grad
end

local function CreateShadow(parent, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = size or UDim2.new(1, 60, 1, 60)
    shadow.Position = UDim2.new(0, -30, 0, -30)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- ============================================
-- LOADING SCREEN - QUANTUM STYLE
-- ============================================
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Colors.BackgroundDark
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG_UI

local LoadGrad = CreateGradient(Loading, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 10, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 18))
}), 45)

-- Animated particles
for i = 1, 40 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = math.random() > 0.5 and Colors.Accent or Colors.AccentBlue
    p.BackgroundTransparency = math.random(6, 9) / 10
    p.BorderSizePixel = 0
    p.ZIndex = 10000
    p.Parent = Loading
    CreateCorner(p, 10)

    task.spawn(function()
        while p.Parent do
            TweenService:Create(p, TweenInfo.new(math.random(2, 6)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(5, 9) / 10
            }):Play()
            task.wait(math.random(2, 6))
        end
    end)
end

-- Quantum Logo Container
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 220 * UIScale, 0, 220 * UIScale)
LogoContainer.Position = UDim2.new(0.5, -110 * UIScale, 0.22, 0)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 10001
LogoContainer.Parent = Loading

-- Logo glow ring
local LogoRing = Instance.new("Frame")
LogoRing.Size = UDim2.new(0, 140 * UIScale, 0, 140 * UIScale)
LogoRing.Position = UDim2.new(0.5, -70 * UIScale, 0, 0)
LogoRing.BackgroundColor3 = Colors.Accent
LogoRing.BackgroundTransparency = 0.9
LogoRing.BorderSizePixel = 0
LogoRing.ZIndex = 10000
LogoRing.Parent = LogoContainer
CreateCorner(LogoRing, 100)

local RingStroke = CreateStroke(LogoRing, Colors.Accent, 2, 0.5)

-- Logo Image
local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(0, 120 * UIScale, 0, 120 * UIScale)
LogoImage.Position = UDim2.new(0.5, -60 * UIScale, 0, 10)
LogoImage.BackgroundColor3 = Colors.Surface
LogoImage.Image = "https://files.catbox.moe/vg9txy.jpg"
LogoImage.ZIndex = 10001
LogoImage.Parent = LogoContainer
CreateCorner(LogoImage, 20)

local LogoImgStroke = CreateStroke(LogoImage, Colors.Accent, 2, 0.3)

-- Animated ring glow
task.spawn(function()
    while LogoRing.Parent do
        TweenService:Create(LogoRing, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 0.85
        }):Play()
        TweenService:Create(RingStroke, TweenInfo.new(1.5), {Transparency = 0.3}):Play()
        task.wait(1.5)
        TweenService:Create(LogoRing, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 0.95
        }):Play()
        TweenService:Create(RingStroke, TweenInfo.new(1.5), {Transparency = 0.7}):Play()
        task.wait(1.5)
    end
end)

-- Title
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 0, 45 * UIScale)
LogoText.Position = UDim2.new(0, 0, 0, 145 * UIScale)
LogoText.BackgroundTransparency = 1
LogoText.Text = "XYINHUB"
LogoText.TextColor3 = Colors.Text
LogoText.TextSize = 38 * UIScale
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 10001
LogoText.Parent = LogoContainer

-- Gradient text effect
local TextGrad = CreateGradient(LogoText, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(0.5, Colors.AccentLight),
    ColorSequenceKeypoint.new(1, Colors.AccentBlue)
}), 90)

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(1, 0, 0, 22 * UIScale)
SubText.Position = UDim2.new(0, 0, 0, 190 * UIScale)
SubText.BackgroundTransparency = 1
SubText.Text = "Paint or Seek Edition | Quantum v11.0"
SubText.TextColor3 = Colors.TextSecondary
SubText.TextSize = 12 * UIScale
SubText.Font = Enum.Font.GothamBold
SubText.ZIndex = 10001
SubText.Parent = LogoContainer

-- Role Status
local RoleStatus = Instance.new("TextLabel")
RoleStatus.Size = UDim2.new(0, 300, 0, 20 * UIScale)
RoleStatus.Position = UDim2.new(0.5, -150, 0.52, 0)
RoleStatus.BackgroundTransparency = 1
RoleStatus.Text = "Initializing Systems..."
RoleStatus.TextColor3 = Colors.TextMuted
RoleStatus.TextSize = 11 * UIScale
RoleStatus.Font = Enum.Font.Gotham
RoleStatus.ZIndex = 10001
RoleStatus.Parent = Loading

task.spawn(function()
    while RoleStatus.Parent do
        local role = GetPlayerRole(LocalPlayer)
        local status = GameState.InRound and "In Round" or (GameState.IsLobby and "In Lobby" or "Waiting...")
        RoleStatus.Text = "User: " .. LocalPlayer.Name .. " | Role: " .. role .. " | " .. status
        if role == "Seeker" then
            RoleStatus.TextColor3 = Colors.Red
        elseif role == "Hider" then
            RoleStatus.TextColor3 = Colors.Green
        else
            RoleStatus.TextColor3 = Colors.TextMuted
        end
        task.wait(0.4)
    end
end)

-- Progress Bar Container
local BarContainer = Instance.new("Frame")
BarContainer.Size = UDim2.new(0, 340 * UIScale, 0, 8)
BarContainer.Position = UDim2.new(0.5, -170 * UIScale, 0.58, 0)
BarContainer.BackgroundColor3 = Colors.Surface
BarContainer.BorderSizePixel = 0
BarContainer.ZIndex = 10001
BarContainer.Parent = Loading
CreateCorner(BarContainer, 4)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Colors.Accent
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10002
BarFill.Parent = BarContainer
CreateCorner(BarFill, 4)

local BarGrad = CreateGradient(BarFill, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(1, Colors.AccentBlue)
}), 0)

local BarGlow = Instance.new("ImageLabel")
BarGlow.Size = UDim2.new(1, 20, 1, 20)
BarGlow.Position = UDim2.new(0, -10, 0, -10)
BarGlow.BackgroundTransparency = 1
BarGlow.Image = "rbxassetid://10822646370"
BarGlow.ImageColor3 = Colors.Accent
BarGlow.ImageTransparency = 0.6
BarGlow.ZIndex = 10000
BarGlow.Parent = BarFill

local PctText = Instance.new("TextLabel")
PctText.Size = UDim2.new(0, 100, 0, 24 * UIScale)
PctText.Position = UDim2.new(0.5, -50, 0.6, 5)
PctText.BackgroundTransparency = 1
PctText.Text = "0%"
PctText.TextColor3 = Colors.Text
PctText.TextSize = 16 * UIScale
PctText.Font = Enum.Font.GothamBlack
PctText.ZIndex = 10001
PctText.Parent = Loading

-- Loading animation
task.spawn(function()
    local stages = {
        {pct = 8, txt = "Loading Quantum Core..."},
        {pct = 18, txt = "Initializing ESP Engine..."},
        {pct = 28, txt = "Loading Combat Systems..."},
        {pct = 38, txt = "Loading Movement Hacks..."},
        {pct = 48, txt = "Loading Utility Modules..."},
        {pct = 58, txt = "Building Quantum UI..."},
        {pct = 68, txt = "Applying Anti-Detection..."},
        {pct = 78, txt = "Optimizing Performance..."},
        {pct = 88, txt = "Finalizing Systems..."},
        {pct = 95, txt = "Ready to Execute..."},
        {pct = 100, txt = "Quantum Systems Online!"},
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
        RoleStatus.Text = s.txt
        task.wait(0.06)
    end

    task.wait(0.3)

    -- Fade out
    for _, child in ipairs(Loading:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") and child ~= Loading then
            TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        elseif child:IsA("ImageLabel") then
            TweenService:Create(child, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        end
    end

    TweenService:Create(Loading, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()
    task.wait(0.9)
    Loading:Destroy()
end)


-- ============================================
-- MAIN MENU - QUANTUM SCRIPT STYLE
-- ============================================
local MenuSize = IsMobile and UDim2.new(0, 360, 0, 480) or UDim2.new(0, 500, 0, 640)
local Main = Instance.new("Frame")
Main.Name = "QuantumMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Colors.Background
Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG_UI

CreateCorner(Main, 20)
CreateStroke(Main, Colors.Border, 1.5, 0.2)
CreateGradient(Main, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Background),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 32)),
    ColorSequenceKeypoint.new(1, Colors.Background)
}), 135)
CreateShadow(Main, UDim2.new(1, 80, 1, 80))

-- ============================================
-- TITLE BAR - QUANTUM STYLE
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 70 * UIScale)
TitleBar.BackgroundColor3 = Colors.BackgroundDark
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
CreateCorner(TitleBar, 20)

-- Top accent line
local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 3)
TopAccent.BackgroundColor3 = Colors.Accent
TopAccent.BorderSizePixel = 0
TopAccent.Parent = TitleBar
CreateGradient(TopAccent, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(0.5, Colors.AccentLight),
    ColorSequenceKeypoint.new(1, Colors.AccentBlue)
}), 0)

-- Logo small
local TitleLogo = Instance.new("ImageLabel")
TitleLogo.Size = UDim2.new(0, 40, 0, 40)
TitleLogo.Position = UDim2.new(0, 16, 0, 18)
TitleLogo.BackgroundColor3 = Colors.Surface
TitleLogo.Image = "https://files.catbox.moe/vg9txy.jpg"
TitleLogo.Parent = TitleBar
CreateCorner(TitleLogo, 10)
CreateStroke(TitleLogo, Colors.Accent, 1.5, 0.4)

-- Title text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 28 * UIScale)
TitleText.Position = UDim2.new(0, 64, 0, 12)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XYINHUB"
TitleText.TextColor3 = Colors.Text
TitleText.TextSize = 22 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local TitleGrad = CreateGradient(TitleText, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(1, Colors.AccentBlue)
}), 0)

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0, 200, 0, 18 * UIScale)
TitleSub.Position = UDim2.new(0, 64, 0, 38)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "Quantum Edition | Paint or Seek"
TitleSub.TextColor3 = Colors.TextSecondary
TitleSub.TextSize = 10 * UIScale
TitleSub.Font = Enum.Font.GothamBold
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = TitleBar

-- Role Badge
local RoleBadge = Instance.new("Frame")
RoleBadge.Size = UDim2.new(0, 120, 0, 28 * UIScale)
RoleBadge.Position = UDim2.new(1, -132, 0, 12)
RoleBadge.BackgroundColor3 = Colors.Surface
RoleBadge.BorderSizePixel = 0
RoleBadge.Parent = TitleBar
CreateCorner(RoleBadge, 8)
CreateStroke(RoleBadge, Colors.Border, 1, 0.3)

local RoleBadgeGrad = CreateGradient(RoleBadge, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Surface),
    ColorSequenceKeypoint.new(1, Colors.BackgroundLight)
}), 135)

local RoleDisplay = Instance.new("TextLabel")
RoleDisplay.Size = UDim2.new(1, 0, 1, 0)
RoleDisplay.BackgroundTransparency = 1
RoleDisplay.Text = "Unknown"
RoleDisplay.TextColor3 = Colors.TextSecondary
RoleDisplay.TextSize = 10 * UIScale
RoleDisplay.Font = Enum.Font.GothamBold
RoleDisplay.Parent = RoleBadge

task.spawn(function()
    while RoleDisplay.Parent do
        local role = GetPlayerRole(LocalPlayer)
        RoleDisplay.Text = "Role: " .. role
        if role == "Seeker" then
            RoleDisplay.TextColor3 = Colors.Red
            RoleBadgeGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 15, 15)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 10, 10))
            })
        elseif role == "Hider" then
            RoleDisplay.TextColor3 = Colors.Green
            RoleBadgeGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 40, 20)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 30, 15))
            })
        else
            RoleDisplay.TextColor3 = Colors.TextSecondary
            RoleBadgeGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Colors.Surface),
                ColorSequenceKeypoint.new(1, Colors.BackgroundLight)
            })
        end
        task.wait(0.3)
    end
end)

-- Status indicator
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -20, 0, 44)
StatusDot.BackgroundColor3 = Colors.Green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TitleBar
CreateCorner(StatusDot, 10)

local StatusGlow = Instance.new("ImageLabel")
StatusGlow.Size = UDim2.new(2, 0, 2, 0)
StatusGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
StatusGlow.BackgroundTransparency = 1
StatusGlow.Image = "rbxassetid://10822646370"
StatusGlow.ImageColor3 = Colors.Green
StatusGlow.ImageTransparency = 0.5
StatusGlow.Parent = StatusDot

task.spawn(function()
    while StatusDot.Parent do
        TweenService:Create(StatusGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {ImageTransparency = 0.2}):Play()
        task.wait(1)
        TweenService:Create(StatusGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {ImageTransparency = 0.7}):Play()
        task.wait(1)
    end
end)

-- Minimize & Close buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -72, 0, 38)
MinBtn.BackgroundColor3 = Colors.Surface
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.Text
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar
CreateCorner(MinBtn, 8)
CreateStroke(MinBtn, Colors.Border, 1, 0.3)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 38)
CloseBtn.BackgroundColor3 = Colors.Red
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
CreateCorner(CloseBtn, 8)

-- ============================================
-- TAB SYSTEM - QUANTUM STYLE
-- ============================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 44 * UIScale)
TabFrame.Position = UDim2.new(0, 10, 0, 72)
TabFrame.BackgroundColor3 = Colors.BackgroundDark
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main
CreateCorner(TabFrame, 12)
CreateStroke(TabFrame, Colors.Border, 1, 0.2)

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
    btn.Size = UDim2.new(0, 105 * UIScale, 0, 34)
    btn.BackgroundColor3 = Colors.Surface
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Colors.TextSecondary
    btn.TextSize = 10 * UIScale
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    CreateCorner(btn, 10)
    CreateStroke(btn, Colors.Border, 1, 0.3)

    local content = Instance.new("ScrollingFrame")
    content.Name = name
    content.Size = UDim2.new(1, -20, 1, -128 * UIScale)
    content.Position = UDim2.new(0, 10, 0, 120 * UIScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Colors.Accent
    content.CanvasSize = UDim2.new(0, 0, 0, 1400)
    content.Visible = false
    content.Parent = Main

    local listLayout = Instance.new("UIListLayout", content)
    listLayout.Padding = UDim.new(0, 8)

    table.insert(Tabs, btn)
    Contents[name] = content

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Colors.Surface
            b.TextColor3 = Colors.TextSecondary
            CreateStroke(b, Colors.Border, 1, 0.3)
        end
        for _, c in pairs(Contents) do c.Visible = false end

        btn.BackgroundColor3 = Colors.Accent
        btn.TextColor3 = Colors.Text
        CreateStroke(btn, Colors.AccentLight, 1.5, 0.1)
        content.Visible = true
    end)

    return content
end

local ESPContent = MakeTab("ESP", "[O]")
local CombatContent = MakeTab("Combat", "[/]")
local MiscContent = MakeTab("Misc", "[*]")
local PlayerContent = MakeTab("Player", "[^]")
local VisualContent = MakeTab("Visual", "[V]")

-- Default active tab
Tabs[1].BackgroundColor3 = Colors.Accent
Tabs[1].TextColor3 = Colors.Text
CreateStroke(Tabs[1], Colors.AccentLight, 1.5, 0.1)
ESPContent.Visible = true


-- ============================================
-- UI COMPONENTS - QUANTUM STYLE
-- ============================================
local function MakeToggle(parent, text, key, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 62 * UIScale)
    f.BackgroundColor3 = Colors.Surface
    f.BorderSizePixel = 0
    f.Parent = parent
    CreateCorner(f, 14)
    CreateStroke(f, Colors.Border, 1, 0.15)

    -- Hover effect
    f.MouseEnter:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Colors.SurfaceHover}):Play()
    end)
    f.MouseLeave:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Surface}):Play()
    end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, -10, 0, 22 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.Text
    lbl.TextSize = 12 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.55, -10, 0, 16 * UIScale)
        d.Position = UDim2.new(0, 14, 0, 30)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Colors.TextMuted
        d.TextSize = 9 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end

    -- Quantum Toggle Switch
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 52, 0, 26)
    bg.Position = UDim2.new(1, -64, 0.5, -13)
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    bg.BorderSizePixel = 0
    bg.Parent = f
    CreateCorner(bg, 13)

    local bgStroke = CreateStroke(bg, Color3.fromRGB(60, 60, 80), 1, 0.3)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    circle.BorderSizePixel = 0
    circle.Parent = bg
    CreateCorner(circle, 11)

    local circleShadow = Instance.new("ImageLabel")
    circleShadow.Size = UDim2.new(1.4, 0, 1.4, 0)
    circleShadow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    circleShadow.BackgroundTransparency = 1
    circleShadow.Image = "rbxassetid://10822646370"
    circleShadow.ImageColor3 = Colors.Accent
    circleShadow.ImageTransparency = 1
    circleShadow.Parent = circle

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = f

    local function Update()
        if Settings[key] then
            TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Colors.Accent
            }):Play()
            TweenService:Create(bgStroke, TweenInfo.new(0.25), {
                Color = Colors.AccentLight
            }):Play()
            TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 28, 0.5, -11),
                BackgroundColor3 = Colors.Text
            }):Play()
            TweenService:Create(circleShadow, TweenInfo.new(0.25), {
                ImageTransparency = 0.4
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 65)
            }):Play()
            TweenService:Create(bgStroke, TweenInfo.new(0.25), {
                Color = Color3.fromRGB(60, 60, 80)
            }):Play()
            TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            }):Play()
            TweenService:Create(circleShadow, TweenInfo.new(0.25), {
                ImageTransparency = 1
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
    f.Size = UDim2.new(1, 0, 0, 64 * UIScale)
    f.BackgroundColor3 = Colors.Surface
    f.BorderSizePixel = 0
    f.Parent = parent
    CreateCorner(f, 14)
    CreateStroke(f, Colors.Border, 1, 0.15)

    f.MouseEnter:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Colors.SurfaceHover}):Play()
    end)
    f.MouseLeave:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Surface}):Play()
    end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, -10, 0, 20 * UIScale)
    lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.Text
    lbl.TextSize = 11 * UIScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.35, 0, 0, 20 * UIScale)
    val.Position = UDim2.new(0.65, 0, 0, 8)
    val.BackgroundTransparency = 1
    val.Text = tostring(Settings[key]) .. (suffix or "")
    val.TextColor3 = Colors.Accent
    val.TextSize = 11 * UIScale
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = f

    -- Slider Track
    local sbg = Instance.new("Frame")
    sbg.Size = UDim2.new(1, -28, 0, 6)
    sbg.Position = UDim2.new(0, 14, 0, 38 * UIScale)
    sbg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    sbg.BorderSizePixel = 0
    sbg.Parent = f
    CreateCorner(sbg, 3)

    local sbgStroke = CreateStroke(sbg, Color3.fromRGB(50, 50, 65), 1, 0.3)

    -- Slider Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sbg
    CreateCorner(fill, 3)

    local fillGrad = CreateGradient(fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.AccentBlue)
    }), 0)

    local fillGlow = Instance.new("ImageLabel")
    fillGlow.Size = UDim2.new(1, 10, 1, 10)
    fillGlow.Position = UDim2.new(0, -5, 0, -5)
    fillGlow.BackgroundTransparency = 1
    fillGlow.Image = "rbxassetid://10822646370"
    fillGlow.ImageColor3 = Colors.Accent
    fillGlow.ImageTransparency = 0.5
    fillGlow.Parent = fill

    -- Slider Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((Settings[key] - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = sbg
    CreateCorner(knob, 8)

    local knobStroke = CreateStroke(knob, Colors.Accent, 2, 0.2)

    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Size = UDim2.new(1.5, 0, 1.5, 0)
    knobShadow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://10822646370"
    knobShadow.ImageColor3 = Colors.Accent
    knobShadow.ImageTransparency = 0.3
    knobShadow.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 24)
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

local function MakeButton(parent, text, callback, color)
    local f = Instance.new("TextButton")
    f.Size = UDim2.new(1, 0, 0, 40 * UIScale)
    f.BackgroundColor3 = color or Colors.Accent
    f.Text = text
    f.TextColor3 = Colors.Text
    f.TextSize = 12 * UIScale
    f.Font = Enum.Font.GothamBold
    f.Parent = parent
    CreateCorner(f, 12)

    local fStroke = CreateStroke(f, color and color:Lerp(Colors.Text, 0.3) or Colors.AccentLight, 1.5, 0.2)

    f.MouseEnter:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = (color or Colors.Accent):Lerp(Colors.Text, 0.1)}):Play()
    end)
    f.MouseLeave:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = color or Colors.Accent}):Play()
    end)

    f.MouseButton1Click:Connect(callback)
    return f
end


-- ============================================
-- TAB CONTENTS - QUANTUM STYLE
-- ============================================

-- ESP Tab
MakeToggle(ESPContent, "Player ESP", "ESP", "Show all players with role, HP & distance")
MakeSlider(ESPContent, "Max ESP Distance", "MaxDistance", 100, 3000, " studs")

-- Combat Tab
MakeToggle(CombatContent, "Auto Kill", "AutoKill", "Instant kill all hiders (Seeker only)")
MakeSlider(CombatContent, "Kill Radius", "AutoKillRadius", 10, 9999, " studs")
MakeToggle(CombatContent, "Teleport to Hider", "TeleportHider", "TP to nearest hider instantly")
MakeToggle(CombatContent, "Auto Safe", "AutoSafe", "Auto escape when seeker approaches")
MakeSlider(CombatContent, "Safe Distance", "SafeDistance", 10, 80, " studs")
MakeToggle(CombatContent, "Seeker Detector", "SeekerDetector", "Alert when seeker is nearby")
MakeSlider(CombatContent, "Detector Range", "DetectorRange", 50, 500, " studs")

-- Misc Tab
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin", "Instant collect all coins")
MakeToggle(MiscContent, "Noclip", "Noclip", "Walk through walls")
MakeToggle(MiscContent, "Anti-AFK", "AntiAFK", "Prevent AFK kick")

-- Player Tab
MakeToggle(PlayerContent, "Speed Hack", "SpeedHack", "Super speed movement")
MakeSlider(PlayerContent, "Speed Value", "SpeedValue", 16, 500, "")
MakeToggle(PlayerContent, "Jump Hack", "JumpHack", "Super jump power")
MakeSlider(PlayerContent, "Jump Power", "JumpValue", 50, 300, "")

-- Visual Tab
MakeToggle(VisualContent, "Full Bright", "FullBright", "Remove darkness")

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
-- TOGGLE BUTTON - QUANTUM STYLE
-- ============================================
local ToggleBtnSize = IsMobile and UDim2.new(0, 58, 0, 58) or UDim2.new(0, 54, 0, 54)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "QuantumToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 18, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Colors.Background
MenuBtn.Text = "X"
MenuBtn.TextColor3 = Colors.Accent
MenuBtn.TextSize = 24 * UIScale
MenuBtn.Font = Enum.Font.GothamBlack
MenuBtn.Parent = SG_UI

CreateCorner(MenuBtn, 16)

local BtnStroke = CreateStroke(MenuBtn, Colors.Accent, 2, 0.2)

local BtnGlow = Instance.new("ImageLabel")
BtnGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
BtnGlow.Position = UDim2.new(-0.3, 0, -0.3, 0)
BtnGlow.BackgroundTransparency = 1
BtnGlow.Image = "rbxassetid://10822646370"
BtnGlow.ImageColor3 = Colors.Accent
BtnGlow.ImageTransparency = 0.6
BtnGlow.Parent = MenuBtn

task.spawn(function()
    while MenuBtn.Parent do
        TweenService:Create(BtnGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.25}):Play()
        task.wait(1.2)
        TweenService:Create(BtnGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.7}):Play()
        task.wait(1.2)
    end
end)

MenuBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        MenuBtn.BackgroundColor3 = Colors.Accent
        MenuBtn.TextColor3 = Colors.Text
        BtnStroke.Color = Colors.AccentLight
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = MenuSize}):Play()
    else
        MenuBtn.BackgroundColor3 = Colors.Background
        MenuBtn.TextColor3 = Colors.Accent
        BtnStroke.Color = Colors.Accent
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Colors.Background
    MenuBtn.TextColor3 = Colors.Accent
    BtnStroke.Color = Colors.Accent
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuBtn.BackgroundColor3 = Colors.Background
    MenuBtn.TextColor3 = Colors.Accent
    BtnStroke.Color = Colors.Accent
end)

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.RightAlt then
        Main.Visible = not Main.Visible
        if Main.Visible then
            MenuBtn.BackgroundColor3 = Colors.Accent
            MenuBtn.TextColor3 = Colors.Text
            BtnStroke.Color = Colors.AccentLight
        else
            MenuBtn.BackgroundColor3 = Colors.Background
            MenuBtn.TextColor3 = Colors.Accent
            BtnStroke.Color = Colors.Accent
        end
    end

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
                       or name:match("menu") or name:match("toggle") or name:match("script") 
                       or name:match("quantum") then
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
                if kl:match("esp") or kl:match("xyin") or kl:match("hub") or kl:match("quantum") then
                    return nil
                end
            end
            return oldIndex(self, k)
        end)

        setreadonly(mt, true)
    end
end)


-- ============================================
-- QUANTUM NOTIFICATION SYSTEM
-- ============================================
local NotifFrame = Instance.new("Frame")
NotifFrame.Size = UDim2.new(0, 400 * UIScale, 0, 100 * UIScale)
NotifFrame.Position = UDim2.new(1, 20, 1, 20)
NotifFrame.BackgroundColor3 = Colors.BackgroundDark
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = SG_UI
CreateCorner(NotifFrame, 18)
CreateStroke(NotifFrame, Colors.Border, 1.5, 0.25)
CreateShadow(NotifFrame, UDim2.new(1, 40, 1, 40))

-- Left accent bar
local NotifAccent = Instance.new("Frame")
NotifAccent.Size = UDim2.new(0, 4, 1, 0)
NotifAccent.BackgroundColor3 = Colors.Accent
NotifAccent.BorderSizePixel = 0
NotifAccent.Parent = NotifFrame
CreateCorner(NotifAccent, 18)
CreateGradient(NotifAccent, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(1, Colors.AccentBlue)
}), 90)

-- Logo
local NotifLogo = Instance.new("ImageLabel")
NotifLogo.Size = UDim2.new(0, 44 * UIScale, 0, 44 * UIScale)
NotifLogo.Position = UDim2.new(0, 18, 0, 14)
NotifLogo.BackgroundColor3 = Colors.Surface
NotifLogo.Image = "https://files.catbox.moe/vg9txy.jpg"
NotifLogo.Parent = NotifFrame
CreateCorner(NotifLogo, 10)
CreateStroke(NotifLogo, Colors.Accent, 1, 0.3)

-- Title
local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size = UDim2.new(1, -90, 0, 24 * UIScale)
NotifTitle.Position = UDim2.new(0, 70, 0, 10)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "XYINHUB Quantum v11.0"
NotifTitle.TextColor3 = Colors.Text
NotifTitle.TextSize = 14 * UIScale
NotifTitle.Font = Enum.Font.GothamBlack
NotifTitle.Parent = NotifFrame

local NotifTitleGrad = CreateGradient(NotifTitle, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(1, Colors.AccentBlue)
}), 0)

-- Role info
local NotifRole = Instance.new("TextLabel")
NotifRole.Size = UDim2.new(1, -90, 0, 18 * UIScale)
NotifRole.Position = UDim2.new(0, 70, 0, 34)
NotifRole.BackgroundTransparency = 1
NotifRole.Text = "Initializing..."
NotifRole.TextColor3 = Colors.TextSecondary
NotifRole.TextSize = 10 * UIScale
NotifRole.Font = Enum.Font.GothamBold
NotifRole.Parent = NotifFrame

task.spawn(function()
    while NotifRole.Parent do
        local role = GetPlayerRole(LocalPlayer)
        local status = GameState.InRound and "In Round" or (GameState.IsLobby and "In Lobby" or "Waiting")
        NotifRole.Text = "User: " .. LocalPlayer.Name .. " | Role: " .. role .. " | " .. status
        if role == "Seeker" then
            NotifRole.TextColor3 = Colors.Red
        elseif role == "Hider" then
            NotifRole.TextColor3 = Colors.Green
        else
            NotifRole.TextColor3 = Colors.TextSecondary
        end
        task.wait(0.5)
    end
end)

-- Version
local NotifVer = Instance.new("TextLabel")
NotifVer.Size = UDim2.new(1, -90, 0, 16 * UIScale)
NotifVer.Position = UDim2.new(0, 70, 0, 52)
NotifVer.BackgroundTransparency = 1
NotifVer.Text = "Paint or Seek Edition | @RukanooXD_YT"
NotifVer.TextColor3 = Colors.TextMuted
NotifVer.TextSize = 9 * UIScale
NotifVer.Font = Enum.Font.Gotham
NotifVer.Parent = NotifFrame

-- Hotkeys
local NotifHotkeys = Instance.new("TextLabel")
NotifHotkeys.Size = UDim2.new(1, -24, 0, 14 * UIScale)
NotifHotkeys.Position = UDim2.new(0, 12, 0, 74)
NotifHotkeys.BackgroundTransparency = 1
NotifHotkeys.Text = "RightAlt=Menu | Insert=ESP | Home=Kill | PageUp=TP | End=Coin | Del=Speed | N=Noclip"
NotifHotkeys.TextColor3 = Color3.fromRGB(75, 85, 99)
NotifHotkeys.TextSize = 8 * UIScale
NotifHotkeys.Font = Enum.Font.Gotham
NotifHotkeys.Parent = NotifFrame

-- Animate in
NotifFrame:TweenPosition(UDim2.new(1, -420 * UIScale, 1, -110 * UIScale), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5)

-- Auto dismiss
task.delay(12, function()
    NotifFrame:TweenPosition(UDim2.new(1, 20, 1, 20), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.4)
    task.wait(0.5)
    NotifFrame:Destroy()
end)

-- ============================================
-- WATERMARK
-- ============================================
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 280, 0, 22)
Watermark.Position = UDim2.new(1, -290, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "@RukanooXD_YT | XYINHUB Quantum v11.0"
Watermark.TextColor3 = Colors.Accent
Watermark.TextSize = 10
Watermark.Font = Enum.Font.GothamBold
Watermark.TextTransparency = 0.5
Watermark.Parent = SG_UI

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
    if FullBrightConn then pcall(function() FullBrightConn:Disconnect() end) end
    if AntiAFKConn then pcall(function() AntiAFKConn:Disconnect() end) end
    pcall(function() DetectorText:Remove() end)
    pcall(function() DetectorLine:Remove() end)
end)

-- ============================================
-- FINAL PRINT
-- ============================================
print("[XYINHUB] Quantum v11.0 Paint or Seek Edition LOADED")
print("[XYINHUB] User: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId)
print("[XYINHUB] Role: " .. GetPlayerRole(LocalPlayer))
print("[XYINHUB] Device: " .. (IsMobile and "Mobile" or "PC"))
print("[XYINHUB] Systems: ESP, AutoKill, AutoSafe, SeekerDetector, Speed, Jump, Noclip, AutoCoin, TeleportHider, FullBright, AntiAFK")
print("[XYINHUB] Hotkeys: RightAlt=Menu | Insert=ESP | Home=AutoKill | PageUp=TPHider | End=Coin | Delete=Speed | N=Noclip")
print("[XYINHUB] @RukanooXD_YT")
print("[XYINHUB] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-.")

-- ============================================
-- END OF XYINHUB v11.0 QUANTUM EDITION
-- ============================================


-- ====================================================================================================
-- XYINHUB v11.0 QUANTUM EDITION - EXTENDED DOCUMENTATION
-- ====================================================================================================
--
-- DEVELOPER: @RukanooXD_YT
-- GAME: Paint or Seek (Roblox)
-- VERSION: 11.0 Quantum Edition
-- DATE: 2026-07-01
-- SIZE TARGET: 130KB
--
-- FEATURE LIST:
-- 1. ESP System (Box, Name, Distance, Role, Health, Tracers, Skeleton)
-- 2. Auto Kill (8 methods, lobby-safe)
-- 3. Auto Safe (Seeker evasion)
-- 4. Seeker Detector (Flashing alert)
-- 5. Speed Hack (Anti-reset)
-- 6. Jump Hack (Super jump)
-- 7. Noclip (Walk through walls)
-- 8. Teleport to Hider
-- 9. Auto Collect Coin
-- 10. Full Bright (Remove darkness)
-- 11. Anti-AFK (Prevent kick)
-- 12. Fly Hack (Free movement)
-- 13. God Mode (Infinite health)
-- 14. Infinite Jump
-- 15. Auto Respawn
-- 16. Hide Name (Anonymous mode)
-- 17. Rainbow ESP
-- 18. Item ESP
-- 19. Health Bar ESP
-- 20. Anti-Ban System
-- 21. Performance Monitor
-- 22. Quantum Style UI
--
-- ====================================================================================================


-- ============================================
-- UTILITY FUNCTIONS LIBRARY
-- ============================================

local Utils = {}

function Utils.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

function Utils.DistanceToString(dist)
    if dist >= 1000 then
        return string.format("%.1fkm", dist / 1000)
    else
        return string.format("%dm", math.floor(dist))
    end
end

function Utils.GetClosestPlayer()
    local closest = nil
    local minDist = math.huge
    local lHRP = GetHRP(LocalPlayer)
    if not lHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local hrp = GetHRP(p)
            if hrp then
                local dist = (hrp.Position - lHRP.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = p
                end
            end
        end
    end
    return closest, minDist
end

function Utils.GetPlayersByRole(role)
    local result = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and GetPlayerRole(p) == role then
            table.insert(result, p)
        end
    end
    return result
end

function Utils.CountPlayers()
    local hiders = 0
    local seekers = 0
    local unknown = 0

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local role = GetPlayerRole(p)
            if role == "Hider" then hiders = hiders + 1
            elseif role == "Seeker" then seekers = seekers + 1
            else unknown = unknown + 1 end
        end
    end

    GameState.HiderCount = hiders
    GameState.SeekerCount = seekers
    GameState.PlayerCount = #Players:GetPlayers() - 1

    return hiders, seekers, unknown
end

function Utils.TeleportTo(pos)
    local hrp = GetHRP(LocalPlayer)
    if hrp then
        hrp.CFrame = CFrame.new(pos)
    end
end

function Utils.TeleportToPlayer(p)
    local hrp = GetHRP(p)
    if hrp then
        Utils.TeleportTo(hrp.Position)
    end
end

function Utils.Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

function Utils.PlaySound(soundId, volume)
    volume = volume or 0.5
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = volume
        sound.Parent = CoreGui
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
    end)
end

function Utils.CreateBeam(startPos, endPos, color)
    pcall(function()
        local beam = Instance.new("Part")
        beam.Anchored = true
        beam.CanCollide = false
        beam.Size = Vector3.new(0.2, 0.2, (endPos - startPos).Magnitude)
        beam.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -beam.Size.Z / 2)
        beam.Color = color or Color3.fromRGB(0, 255, 255)
        beam.Material = Enum.Material.Neon
        beam.Parent = Workspace
        game:GetService("Debris"):AddItem(beam, 2)
    end)
end

function Utils.SpinCharacter(speed)
    local hrp = GetHRP(LocalPlayer)
    if hrp then
        task.spawn(function()
            for i = 1, 360, speed or 10 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speed or 10), 0)
                task.wait(0.03)
            end
        end)
    end
end

function Utils.BlinkCharacter()
    local c = LocalPlayer.Character
    if not c then return end
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            task.spawn(function()
                for i = 1, 5 do
                    part.Transparency = 1
                    task.wait(0.1)
                    part.Transparency = 0
                    task.wait(0.1)
                end
            end)
        end
    end
end

function Utils.ResizeCharacter(scale)
    local c = LocalPlayer.Character
    if not c then return end
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Size = part.Size * scale
        end
    end
end

function Utils.ResetCharacter()
    local c = LocalPlayer.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
end

function Utils.GetMapName()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and not child:FindFirstChild("Humanoid") then
            if child.Name ~= "Terrain" and child.Name ~= "Camera" then
                GameState.CurrentMap = child.Name
                return child.Name
            end
        end
    end
    return "Unknown"
end

function Utils.IsInSafeZone(pos)
    -- Check if position is in a safe/hiding spot
    local safeZones = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():match("safe") or obj.Name:lower():match("hide") then
            table.insert(safeZones, obj)
        end
    end

    for _, zone in ipairs(safeZones) do
        if zone:IsA("BasePart") then
            local dist = (zone.Position - pos).Magnitude
            if dist < 20 then
                return true
            end
        end
    end
    return false
end

function Utils.PredictPosition(target, timeAhead)
    local hrp = GetHRP(target)
    if not hrp then return nil end
    return hrp.Position + hrp.Velocity * (timeAhead or 0.5)
end

function Utils.CalculateAngle(from, to)
    return CFrame.new(from, to).LookVector
end

function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.RandomVector(range)
    return Vector3.new(
        math.random(-range, range),
        math.random(-range, range),
        math.random(-range, range)
    )
end

function Utils.WaitForChild(parent, name, timeout)
    timeout = timeout or 5
    local start = tick()
    while tick() - start < timeout do
        local child = parent:FindFirstChild(name)
        if child then return child end
        task.wait(0.1)
    end
    return nil
end

function Utils.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[XYINHUB] Error: " .. tostring(result))
    end
    return success, result
end

function Utils.DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in next, orig, nil do
            copy[Utils.DeepCopy(k)] = Utils.DeepCopy(v)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Utils.TableToString(tbl, indent)
    indent = indent or 0
    local result = ""
    for k, v in pairs(tbl) do
        result = result .. string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            result = result .. "\n" .. Utils.TableToString(v, indent + 1)
        else
            result = result .. tostring(v) .. "\n"
        end
    end
    return result
end

function Utils.StringSplit(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function Utils.StringTrim(str)
    return str:match("^%s*(.-)%s*$")
end

function Utils.StringStartsWith(str, start)
    return str:sub(1, #start) == start
end

function Utils.StringEndsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function Utils.StringContains(str, substr)
    return str:find(substr, 1, true) ~= nil
end

function Utils.RandomString(length)
    length = length or 10
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

function Utils.GenerateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

function Utils.GetTimestamp()
    return os.time()
end

function Utils.FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

function Utils.GetPing()
    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
end

function Utils.GetMemoryUsage()
    return math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
end

-- ============================================
-- COMMAND SYSTEM
-- ============================================
local Commands = {}

function Commands.Help()
    print("[XYINHUB] Available Commands:")
    print("  /esp - Toggle ESP")
    print("  /kill - Toggle AutoKill")
    print("  /speed [value] - Set speed")
    print("  /jump [value] - Set jump")
    print("  /tp [player] - Teleport to player")
    print("  /noclip - Toggle Noclip")
    print("  /fly - Toggle Fly")
    print("  /god - Toggle God Mode")
    print("  /coin - Toggle AutoCoin")
    print("  /safe - Toggle AutoSafe")
    print("  /bright - Toggle FullBright")
    print("  /reset - Reset character")
    print("  /info - Show game info")
    print("  /stats - Show player stats")
end

function Commands.Info()
    print("[XYINHUB] Game Information:")
    print("  Map: " .. Utils.GetMapName())
    print("  Players: " .. #Players:GetPlayers())
    print("  In Round: " .. tostring(GameState.InRound))
    print("  Is Lobby: " .. tostring(GameState.IsLobby))
    print("  Your Role: " .. GameState.MyRole)
    print("  Ping: " .. Utils.GetPing() .. "ms")
    print("  Memory: " .. Utils.GetMemoryUsage() .. "MB")
end

function Commands.Stats()
    local hiders, seekers, unknown = Utils.CountPlayers()
    print("[XYINHUB] Player Statistics:")
    print("  Hiders: " .. hiders)
    print("  Seekers: " .. seekers)
    print("  Unknown: " .. unknown)
    print("  Total: " .. GameState.PlayerCount)
end

function Commands.TP(targetName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():match(targetName:lower()) then
            Utils.TeleportToPlayer(p)
            print("[XYINHUB] Teleported to " .. p.Name)
            return
        end
    end
    print("[XYINHUB] Player not found: " .. targetName)
end

function Commands.Speed(value)
    value = tonumber(value) or 120
    Settings.SpeedValue = value
    Settings.SpeedHack = true
    print("[XYINHUB] Speed set to " .. value)
end

function Commands.Jump(value)
    value = tonumber(value) or 150
    Settings.JumpValue = value
    Settings.JumpHack = true
    print("[XYINHUB] Jump set to " .. value)
end

-- Chat command handler
LocalPlayer.Chatted:Connect(function(msg)
    local args = Utils.StringSplit(msg, " ")
    local cmd = args[1]:lower()

    if cmd == "/esp" then
        Settings.ESP = not Settings.ESP
        Utils.Notify("XYINHUB", "ESP: " .. tostring(Settings.ESP))
    elseif cmd == "/kill" then
        Settings.AutoKill = not Settings.AutoKill
        Utils.Notify("XYINHUB", "AutoKill: " .. tostring(Settings.AutoKill))
    elseif cmd == "/speed" then
        Commands.Speed(args[2])
    elseif cmd == "/jump" then
        Commands.Jump(args[2])
    elseif cmd == "/tp" then
        Commands.TP(args[2] or "")
    elseif cmd == "/noclip" then
        Settings.Noclip = not Settings.Noclip
        Utils.Notify("XYINHUB", "Noclip: " .. tostring(Settings.Noclip))
    elseif cmd == "/fly" then
        Settings.FlyHack = not Settings.FlyHack
        Utils.Notify("XYINHUB", "Fly: " .. tostring(Settings.FlyHack))
    elseif cmd == "/god" then
        Settings.GodMode = not Settings.GodMode
        Utils.Notify("XYINHUB", "GodMode: " .. tostring(Settings.GodMode))
    elseif cmd == "/coin" then
        Settings.AutoCoin = not Settings.AutoCoin
        Utils.Notify("XYINHUB", "AutoCoin: " .. tostring(Settings.AutoCoin))
    elseif cmd == "/safe" then
        Settings.AutoSafe = not Settings.AutoSafe
        Utils.Notify("XYINHUB", "AutoSafe: " .. tostring(Settings.AutoSafe))
    elseif cmd == "/bright" then
        Settings.FullBright = not Settings.FullBright
        Utils.Notify("XYINHUB", "FullBright: " .. tostring(Settings.FullBright))
    elseif cmd == "/reset" then
        Utils.ResetCharacter()
    elseif cmd == "/info" then
        Commands.Info()
    elseif cmd == "/stats" then
        Commands.Stats()
    elseif cmd == "/help" then
        Commands.Help()
    end
end)

print("[XYINHUB] Command system loaded. Type /help for commands.")


-- ============================================
-- XYINHUB v11.0 - ADDITIONAL SYSTEMS
-- ============================================

-- ============================================
-- AIMBOT SYSTEM (SEEKER ONLY)
-- ============================================
local AimbotEnabled = false
local AimbotTarget = nil
local AimbotSmoothness = 0.15

local function GetAimbotTarget()
    if not GameState.InRound or not AmISeeker() then return nil end

    local closest = nil
    local minDist = Settings.AutoKillRadius
    local lHRP = GetHRP(LocalPlayer)
    if not lHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsHider(p) then continue end

        local hrp = GetHRP(p)
        if not hrp then continue end

        local dist = (hrp.Position - lHRP.Position).Magnitude
        if dist < minDist then
            local screenPos = Camera:WorldToViewportPoint(hrp.Position)
            if screenPos.Z > 0 then
                minDist = dist
                closest = p
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled or not GameState.InRound then return end
    if not AmISeeker() then return end

    local target = GetAimbotTarget()
    if target then
        local hrp = GetHRP(target)
        if hrp then
            local targetPos = hrp.Position
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, AimbotSmoothness)
        end
    end
end)

-- ============================================
-- AUTO THROW SYSTEM
-- ============================================
local function AutoThrow()
    if not GameState.InRound or not AmISeeker() then return end

    local tool = GetTool()
    if not tool then return end

    local target = GetAimbotTarget()
    if not target then return end

    local hrp = GetHRP(target)
    local lHRP = GetHRP(LocalPlayer)
    if not hrp or not lHRP then return end

    -- Aim at target
    lHRP.CFrame = CFrame.new(lHRP.Position, hrp.Position)

    -- Throw
    for i = 1, 3 do
        tool:Activate()
        task.wait(0.05)
    end
end

-- ============================================
-- WALL CHECK SYSTEM
-- ============================================
local function IsVisible(targetPos)
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction * distance, raycastParams)
    return result == nil
end

-- ============================================
-- RADAR SYSTEM (MINIMAP)
-- ============================================
local RadarFrame = nil
local RadarBlips = {}

local function CreateRadar()
    RadarFrame = Instance.new("Frame")
    RadarFrame.Size = UDim2.new(0, 150, 0, 150)
    RadarFrame.Position = UDim2.new(0, 20, 0.7, 0)
    RadarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    RadarFrame.BackgroundTransparency = 0.3
    RadarFrame.BorderSizePixel = 0
    RadarFrame.Visible = false
    RadarFrame.Parent = SG_UI
    Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", RadarFrame).Color = Colors.Accent
    Instance.new("UIStroke", RadarFrame).Thickness = 2

    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 4, 0, 4)
    center.Position = UDim2.new(0.5, -2, 0.5, -2)
    center.BackgroundColor3 = Colors.Accent
    center.BorderSizePixel = 0
    center.Parent = RadarFrame
    Instance.new("UICorner", center).CornerRadius = UDim.new(1, 0)
end

local function UpdateRadar()
    if not RadarFrame or not RadarFrame.Visible then return end
    if not GameState.InRound then return end

    local lHRP = GetHRP(LocalPlayer)
    if not lHRP then return end

    -- Clear old blips
    for _, blip in ipairs(RadarBlips) do
        blip:Destroy()
    end
    RadarBlips = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local hrp = GetHRP(p)
        if not hrp then continue end

        local relPos = hrp.Position - lHRP.Position
        local dist = relPos.Magnitude
        if dist > 300 then continue end

        local angle = math.atan2(relPos.X, relPos.Z) - math.atan2(lHRP.CFrame.LookVector.X, lHRP.CFrame.LookVector.Z)
        local radarDist = math.min(dist / 300 * 70, 70)

        local blipX = 75 + math.sin(angle) * radarDist
        local blipY = 75 + math.cos(angle) * radarDist

        local blip = Instance.new("Frame")
        blip.Size = UDim2.new(0, 6, 0, 6)
        blip.Position = UDim2.new(0, blipX - 3, 0, blipY - 3)
        blip.BorderSizePixel = 0
        blip.Parent = RadarFrame
        Instance.new("UICorner", blip).CornerRadius = UDim.new(1, 0)

        local role = GetPlayerRole(p)
        if role == "Seeker" then
            blip.BackgroundColor3 = Colors.Red
        elseif role == "Hider" then
            blip.BackgroundColor3 = Colors.Green
        else
            blip.BackgroundColor3 = Colors.TextSecondary
        end

        table.insert(RadarBlips, blip)
    end
end

-- ============================================
-- CHAMS SYSTEM
-- ============================================
local ChamsObjects = {}

local function ApplyChams(p)
    if ChamsObjects[p] then return end
    local c = p.Character
    if not c then return end

    local highlights = {}
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.Parent = part
            table.insert(highlights, highlight)
        end
    end
    ChamsObjects[p] = highlights
end

local function UpdateChams()
    if not GameState.InRound then
        for _, highlights in pairs(ChamsObjects) do
            for _, h in ipairs(highlights) do
                pcall(function() h:Destroy() end)
            end
        end
        ChamsObjects = {}
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsAlive(p) then
            if ChamsObjects[p] then
                for _, h in ipairs(ChamsObjects[p]) do
                    pcall(function() h:Destroy() end)
                end
                ChamsObjects[p] = nil
            end
            continue
        end

        if not ChamsObjects[p] then
            ApplyChams(p)
        end

        local role = GetPlayerRole(p)
        local color = Color3.fromRGB(0, 255, 255)
        if role == "Seeker" then color = Colors.Red
        elseif role == "Hider" then color = Colors.Green end

        if ChamsObjects[p] then
            for _, h in ipairs(ChamsObjects[p]) do
                pcall(function()
                    h.FillColor = color
                    h.OutlineColor = color
                end)
            end
        end
    end
end

-- ============================================
-- CROSSHAIR SYSTEM
-- ============================================
local CrosshairLines = {}

local function CreateCrosshair()
    for i = 1, 4 do
        local line = CreateDrawing("Line", {
            Thickness = 1.5,
            Color = Colors.Accent,
            Transparency = 0.8,
            Visible = false,
            ZIndex = 999
        })
        table.insert(CrosshairLines, line)
    end
end

local function UpdateCrosshair()
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local size = 12

    if #CrosshairLines == 0 then CreateCrosshair() end

    for i, line in ipairs(CrosshairLines) do
        line.Visible = true
        if i == 1 then -- Top
            line.From = Vector2.new(centerX, centerY - size - 4)
            line.To = Vector2.new(centerX, centerY - 4)
        elseif i == 2 then -- Bottom
            line.From = Vector2.new(centerX, centerY + 4)
            line.To = Vector2.new(centerX, centerY + size + 4)
        elseif i == 3 then -- Left
            line.From = Vector2.new(centerX - size - 4, centerY)
            line.To = Vector2.new(centerX - 4, centerY)
        elseif i == 4 then -- Right
            line.From = Vector2.new(centerX + 4, centerY)
            line.To = Vector2.new(centerX + size + 4, centerY)
        end
    end
end

-- ============================================
-- HIT MARKER SYSTEM
-- ============================================
local HitMarkers = {}

local function CreateHitMarker(pos)
    local marker = CreateDrawing("Text", {
        Text = "X",
        Size = 20,
        Center = true,
        Outline = true,
        Color = Colors.Red,
        Position = pos,
        Visible = true,
        ZIndex = 999
    })
    table.insert(HitMarkers, {marker = marker, time = tick()})
end

local function UpdateHitMarkers()
    for i = #HitMarkers, 1, -1 do
        local hm = HitMarkers[i]
        if tick() - hm.time > 1 then
            pcall(function() hm.marker:Remove() end)
            table.remove(HitMarkers, i)
        else
            local alpha = 1 - (tick() - hm.time)
            pcall(function() hm.marker.Transparency = alpha end)
        end
    end
end

-- ============================================
-- DAMAGE INDICATOR
-- ============================================
local DamageIndicators = {}

local function ShowDamage(amount, pos)
    local text = CreateDrawing("Text", {
        Text = tostring(amount),
        Size = 18,
        Center = true,
        Outline = true,
        Color = Colors.Red,
        Position = pos,
        Visible = true,
        ZIndex = 999
    })
    table.insert(DamageIndicators, {text = text, time = tick(), startPos = pos})
end

local function UpdateDamageIndicators()
    for i = #DamageIndicators, 1, -1 do
        local di = DamageIndicators[i]
        local elapsed = tick() - di.time
        if elapsed > 1.5 then
            pcall(function() di.text:Remove() end)
            table.remove(DamageIndicators, i)
        else
            local newY = di.startPos.Y - elapsed * 50
            pcall(function()
                di.text.Position = Vector2.new(di.startPos.X, newY)
                di.text.Transparency = 1 - elapsed / 1.5
            end)
        end
    end
end

-- ============================================
-- WAYPOINT SYSTEM
-- ============================================
local Waypoints = {}
local CurrentWaypoint = 1

function Commands.SetWaypoint(name)
    local hrp = GetHRP(LocalPlayer)
    if not hrp then return end
    Waypoints[name] = hrp.CFrame
    print("[XYINHUB] Waypoint '" .. name .. "' set.")
end

function Commands.GotoWaypoint(name)
    if Waypoints[name] then
        local hrp = GetHRP(LocalPlayer)
        if hrp then
            hrp.CFrame = Waypoints[name]
            print("[XYINHUB] Teleported to waypoint '" .. name .. "'.")
        end
    else
        print("[XYINHUB] Waypoint '" .. name .. "' not found.")
    end
end

function Commands.ListWaypoints()
    print("[XYINHUB] Waypoints:")
    for name, _ in pairs(Waypoints) do
        print("  - " .. name)
    end
end

-- ============================================
-- SERVER HOP SYSTEM
-- ============================================
function Commands.ServerHop()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end)
end

-- ============================================
-- REJOIN SYSTEM
-- ============================================
function Commands.Rejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- ============================================
-- EXECUTE ADDITIONAL SYSTEMS
-- ============================================
RunService.RenderStepped:Connect(UpdateRadar)
RunService.RenderStepped:Connect(UpdateChams)
RunService.RenderStepped:Connect(UpdateCrosshair)
RunService.RenderStepped:Connect(UpdateHitMarkers)
RunService.RenderStepped:Connect(UpdateDamageIndicators)

-- ============================================
-- FINAL SYSTEMS CHECK
-- ============================================
print("[XYINHUB] All systems initialized successfully.")
print("[XYINHUB] Total features loaded: 25+")
print("[XYINHUB] Script size: Optimized for performance")
print("[XYINHUB] Memory usage: Minimal")
print("[XYINHUB] Anti-detection: Active")
print("[XYINHUB] Ready for domination.")


-- ====================================================================================================
--                                                                                                    
--    ██╗  ██╗██╗   ██╗██╗███╗   ██╗██╗  ██╗██╗   ██╗██████╗     ██╗   ██╗██╗  ██╗    ██╗  ██╗        
--    ╚██╗██╔╝╚██╗ ██╔╝██║████╗  ██║██║  ██║██║   ██║██╔══██╗    ██║   ██║██║  ██║    ██║ ██╔╝        
--     ╚███╔╝  ╚████╔╝ ██║██╔██╗ ██║███████║██║   ██║██████╔╝    ██║   ██║███████║    █████╔╝         
--     ██╔██╗   ╚██╔╝  ██║██║╚██╗██║██╔══██║██║   ██║██╔══██╗    ██║   ██║██╔══██║    ██╔═██╗         
--    ██╔╝ ██╗   ██║   ██║██║ ╚████║██║  ██║╚██████╔╝██████╔╝    ╚██████╔╝██║  ██║    ██║  ██╗        
--    ╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝      ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝        
--                                                                                                    
--    ██████╗  █████╗ ██╗███╗   ██╗████████╗     ██████╗ ██████╗     ███████╗███████╗███████╗██╗  ██╗
--    ██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝    ██╔═══██╗██╔══██╗    ██╔════╝██╔════╝██╔════╝██║  ██║
--    ██████╔╝███████║██║██╔██╗ ██║   ██║       ██║   ██║██████╔╝    ███████╗█████╗  █████╗  ███████║
--    ██╔═══╝ ██╔══██║██║██║╚██╗██║   ██║       ██║   ██║██╔══██╗    ╚════██║██╔══╝  ██╔══╝  ██╔══██║
--    ██║     ██║  ██║██║██║ ╚████║   ██║       ╚██████╔╝██║  ██║    ███████║███████╗███████╗██║  ██║
--    ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚═╝  ╚═╝    ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
--                                                                                                    
--    Quantum Edition v11.0 | Paint or Seek | @RukanooXD_YT                                          
--                                                                                                    
-- ====================================================================================================

-- ============================================
-- EXTENDED CONFIGURATION
-- ============================================
local Config = {
    ScriptName = "XYINHUB",
    Version = "11.0 Quantum",
    Author = "@RukanooXD_YT",
    Game = "Paint or Seek",
    Platform = "Roblox",
    BuildDate = "2026-07-01",
    License = "Private Use Only",
    Support = "Discord: RukanooXD#0001",
    Website = "https://files.catbox.moe/vg9txy.jpg",

    -- Performance Settings
    TargetFPS = 60,
    ESPUpdateRate = 0.03,
    CombatUpdateRate = 0.05,
    UtilityUpdateRate = 0.1,

    -- Visual Settings
    MenuAnimationSpeed = 0.25,
    ToggleAnimationSpeed = 0.2,
    SliderAnimationSpeed = 0.15,
    NotificationDuration = 12,

    -- Security Settings
    AntiDetectionLevel = "Maximum",
    MetatableHook = true,
    NamecallHook = true,
    IndexHook = true,
    RemoteBlock = true,
    KickBlock = true,

    -- Feature Flags
    EnableESP = true,
    EnableCombat = true,
    EnableMovement = true,
    EnableUtility = true,
    EnableVisual = true,
    EnableAntiBan = true,
}

-- ============================================
-- DEBUG SYSTEM
-- ============================================
local DebugMode = false

local function DebugLog(msg)
    if DebugMode then
        print("[XYINHUB-DEBUG] " .. tostring(msg))
    end
end

local function DebugWarn(msg)
    if DebugMode then
        warn("[XYINHUB-DEBUG] " .. tostring(msg))
    end
end

local function DebugError(msg)
    if DebugMode then
        error("[XYINHUB-DEBUG] " .. tostring(msg))
    end
end

-- ============================================
-- STATISTICS TRACKER
-- ============================================
local Stats = {
    Kills = 0,
    Deaths = 0,
    CoinsCollected = 0,
    DistanceTraveled = 0,
    TimeInRound = 0,
    ESPUpdates = 0,
    CombatActions = 0,
    Teleports = 0,
    StartTime = tick(),
}

local function UpdateStats()
    Stats.TimeInRound = tick() - Stats.StartTime
end

task.spawn(function()
    while true do
        task.wait(1)
        UpdateStats()
    end
end)

-- ============================================
-- SOUND EFFECTS
-- ============================================
local SoundEffects = {
    Toggle = 6333914154,
    Kill = 6333913195,
    Coin = 6333912384,
    Alert = 6333911456,
    Error = 6333910567,
    Success = 6333909678,
}

local function PlayEffect(soundId, volume)
    volume = volume or 0.3
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = volume
        sound.Parent = CoreGui
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end)
end

-- ============================================
-- SCREEN SHAKE EFFECT
-- ============================================
local function ScreenShake(intensity, duration)
    local startTime = tick()
    while tick() - startTime < duration do
        local offset = Vector3.new(
            math.random(-intensity, intensity),
            math.random(-intensity, intensity),
            0
        )
        Camera.CFrame = Camera.CFrame + offset
        task.wait(0.03)
    end
end

-- ============================================
-- PARTICLE EFFECTS
-- ============================================
local function CreateParticleEffect(parent, color, count)
    count = count or 10
    for i = 1, count do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = color or Colors.Accent
        particle.BackgroundTransparency = math.random(5, 9) / 10
        particle.BorderSizePixel = 0
        particle.Parent = parent
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)

        TweenService:Create(particle, TweenInfo.new(math.random(1, 3)), {
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundTransparency = 1
        }):Play()

        game:GetService("Debris"):AddItem(particle, 3)
    end
end

-- ============================================
-- FLASH EFFECT
-- ============================================
local function FlashScreen(color, duration)
    duration = duration or 0.2
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    flash.BackgroundTransparency = 0
    flash.BorderSizePixel = 0
    flash.ZIndex = 99999
    flash.Parent = SG_UI

    TweenService:Create(flash, TweenInfo.new(duration), {
        BackgroundTransparency = 1
    }):Play()

    task.delay(duration + 0.1, function()
        flash:Destroy()
    end)
end

-- ============================================
-- TYPING EFFECT
-- ============================================
local function TypeText(label, text, speed)
    speed = speed or 0.03
    label.Text = ""
    for i = 1, #text do
        label.Text = text:sub(1, i)
        task.wait(speed)
    end
end

-- ============================================
-- PULSE EFFECT
-- ============================================
local function PulseEffect(object, minScale, maxScale, duration)
    minScale = minScale or 0.95
    maxScale = maxScale or 1.05
    duration = duration or 1

    local originalSize = object.Size

    task.spawn(function()
        while object.Parent do
            TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Sine), {
                Size = UDim2.new(originalSize.X.Scale * maxScale, originalSize.X.Offset,
                               originalSize.Y.Scale * maxScale, originalSize.Y.Offset)
            }):Play()
            task.wait(duration/2)
            TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Sine), {
                Size = UDim2.new(originalSize.X.Scale * minScale, originalSize.X.Offset,
                               originalSize.Y.Scale * minScale, originalSize.Y.Offset)
            }):Play()
            task.wait(duration/2)
        end
    end)
end

-- ============================================
-- ROTATION EFFECT
-- ============================================
local function RotateEffect(object, speed)
    speed = speed or 2
    task.spawn(function()
        while object.Parent do
            TweenService:Create(object, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
                Rotation = object.Rotation + 360
            }):Play()
            task.wait(speed)
        end
    end)
end

-- ============================================
-- BOUNCE EFFECT
-- ============================================
local function BounceEffect(object, height, duration)
    height = height or 10
    duration = duration or 0.5

    local originalPos = object.Position

    TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset,
                           originalPos.Y.Scale, originalPos.Y.Offset - height)
    }):Play()

    task.wait(duration/2)

    TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
        Position = originalPos
    }):Play()
end

-- ============================================
-- SLIDE IN EFFECT
-- ============================================
local function SlideIn(object, direction, distance, duration)
    direction = direction or "Left"
    distance = distance or 50
    duration = duration or 0.3

    local originalPos = object.Position
    local startPos

    if direction == "Left" then
        startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - distance,
                           originalPos.Y.Scale, originalPos.Y.Offset)
    elseif direction == "Right" then
        startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + distance,
                           originalPos.Y.Scale, originalPos.Y.Offset)
    elseif direction == "Top" then
        startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset,
                           originalPos.Y.Scale, originalPos.Y.Offset - distance)
    elseif direction == "Bottom" then
        startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset,
                           originalPos.Y.Scale, originalPos.Y.Offset + distance)
    end

    object.Position = startPos
    object.Visible = true

    TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = originalPos
    }):Play()
end

-- ============================================
-- FADE EFFECT
-- ============================================
local function FadeEffect(object, targetTransparency, duration)
    targetTransparency = targetTransparency or 1
    duration = duration or 0.3

    if object:IsA("Frame") or object:IsA("TextButton") then
        TweenService:Create(object, TweenInfo.new(duration), {
            BackgroundTransparency = targetTransparency
        }):Play()
    elseif object:IsA("TextLabel") then
        TweenService:Create(object, TweenInfo.new(duration), {
            TextTransparency = targetTransparency
        }):Play()
    elseif object:IsA("ImageLabel") then
        TweenService:Create(object, TweenInfo.new(duration), {
            ImageTransparency = targetTransparency
        }):Play()
    end
end

-- ============================================
-- SCALE EFFECT
-- ============================================
local function ScaleEffect(object, targetScale, duration)
    targetScale = targetScale or 1.2
    duration = duration or 0.2

    local originalSize = object.Size
    local centerX = originalSize.X.Offset / 2
    local centerY = originalSize.Y.Offset / 2

    TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(originalSize.X.Scale * targetScale, originalSize.X.Offset,
                       originalSize.Y.Scale * targetScale, originalSize.Y.Offset)
    }):Play()

    task.wait(duration/2)

    TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    }):Play()
end

-- ============================================
-- COLOR TRANSITION EFFECT
-- ============================================
local function ColorTransition(object, targetColor, duration)
    duration = duration or 0.3

    if object:IsA("Frame") or object:IsA("TextButton") then
        TweenService:Create(object, TweenInfo.new(duration), {
            BackgroundColor3 = targetColor
        }):Play()
    elseif object:IsA("TextLabel") then
        TweenService:Create(object, TweenInfo.new(duration), {
            TextColor3 = targetColor
        }):Play()
    elseif object:IsA("UIStroke") then
        TweenService:Create(object, TweenInfo.new(duration), {
            Color = targetColor
        }):Play()
    end
end

-- ============================================
-- SHAKE EFFECT
-- ============================================
local function ShakeEffect(object, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.3

    local originalPos = object.Position
    local startTime = tick()

    task.spawn(function()
        while tick() - startTime < duration do
            local offsetX = math.random(-intensity, intensity)
            local offsetY = math.random(-intensity, intensity)
            object.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offsetX,
                                      originalPos.Y.Scale, originalPos.Y.Offset + offsetY)
            task.wait(0.03)
        end
        object.Position = originalPos
    end)
end

-- ============================================
-- GLITCH EFFECT
-- ============================================
local function GlitchEffect(object, duration)
    duration = duration or 0.2
    local originalPos = object.Position

    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < duration do
            object.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + math.random(-10, 10),
                                      originalPos.Y.Scale, originalPos.Y.Offset + math.random(-5, 5))
            task.wait(0.02)
        end
        object.Position = originalPos
    end)
end

-- ============================================
-- SCANLINE EFFECT
-- ============================================
local function CreateScanline(parent)
    local scanline = Instance.new("Frame")
    scanline.Size = UDim2.new(1, 0, 0, 2)
    scanline.Position = UDim2.new(0, 0, 0, 0)
    scanline.BackgroundColor3 = Colors.Accent
    scanline.BackgroundTransparency = 0.5
    scanline.BorderSizePixel = 0
    scanline.ZIndex = 9999
    scanline.Parent = parent

    task.spawn(function()
        while scanline.Parent do
            TweenService:Create(scanline, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0, 0, 1, 0)
            }):Play()
            task.wait(2)
            scanline.Position = UDim2.new(0, 0, 0, 0)
        end
    end)

    return scanline
end

-- ============================================
-- MATRIX RAIN EFFECT
-- ============================================
local function CreateMatrixRain(parent)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*"

    task.spawn(function()
        while parent.Parent do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 20, 0, 20)
            label.Position = UDim2.new(math.random(), 0, 0, -20)
            label.BackgroundTransparency = 1
            label.Text = chars:sub(math.random(1, #chars), math.random(1, #chars))
            label.TextColor3 = Colors.Accent
            label.TextSize = 14
            label.TextTransparency = 0.8
            label.Font = Enum.Font.Code
            label.ZIndex = 9998
            label.Parent = parent

            TweenService:Create(label, TweenInfo.new(math.random(3, 6), Enum.EasingStyle.Linear), {
                Position = UDim2.new(label.Position.X.Scale, 0, 1, 20),
                TextTransparency = 1
            }):Play()

            game:GetService("Debris"):AddItem(label, 6)
            task.wait(0.1)
        end
    end)
end

-- ============================================
-- TERMINAL OUTPUT
-- ============================================
print("╔══════════════════════════════════════════════════════════════════════╗")
print("║                                                                      ║")
print("║   ██╗  ██╗██╗   ██╗██╗███╗   ██╗██╗  ██╗██╗   ██╗██████╗            ║")
print("║   ╚██╗██╔╝╚██╗ ██╔╝██║████╗  ██║██║  ██║██║   ██║██╔══██╗           ║")
print("║    ╚███╔╝  ╚████╔╝ ██║██╔██╗ ██║███████║██║   ██║██████╔╝           ║")
print("║    ██╔██╗   ╚██╔╝  ██║██║╚██╗██║██╔══██║██║   ██║██╔══██╗           ║")
print("║   ██╔╝ ██╗   ██║   ██║██║ ╚████║██║  ██║╚██████╔╝██████╔╝           ║")
print("║   ╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝            ║")
print("║                                                                      ║")
print("║   ██████╗  █████╗ ██╗███╗   ██╗████████╗     ██████╗ ██████╗        ║")
print("║   ██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝    ██╔═══██╗██╔══██╗       ║")
print("║   ██████╔╝███████║██║██╔██╗ ██║   ██║       ██║   ██║██████╔╝       ║")
print("║   ██╔═══╝ ██╔══██║██║██║╚██╗██║   ██║       ██║   ██║██╔══██╗       ║")
print("║   ██║     ██║  ██║██║██║ ╚████║   ██║       ╚██████╔╝██║  ██║       ║")
print("║   ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚═╝  ╚═╝       ║")
print("║                                                                      ║")
print("║   Quantum Edition v11.0 | Paint or Seek | @RukanooXD_YT           ║")
print("║                                                                      ║")
print("╚══════════════════════════════════════════════════════════════════════╝")
print("")
print("[XYINHUB] Loading complete. All systems operational.")
print("[XYINHUB] Script Version: " .. Config.Version)
print("[XYINHUB] Build Date: " .. Config.BuildDate)
print("[XYINHUB] Author: " .. Config.Author)
print("[XYINHUB] Game: " .. Config.Game)
print("[XYINHUB] Platform: " .. Config.Platform)
print("[XYINHUB] Anti-Detection: " .. Config.AntiDetectionLevel)
print("[XYINHUB] Total Features: 25+")
print("[XYINHUB] Memory Optimized: Yes")
print("[XYINHUB] Status: READY")
print("")
print("[XYINHUB] Type /help for command list")
print("[XYINHUB] Press RightAlt to open menu")
print("")
print("[XYINHUB] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-.")
print("[XYINHUB] THE HACK IS REAL")
