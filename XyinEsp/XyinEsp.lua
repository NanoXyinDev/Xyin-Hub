
-- ============================================
-- XYINHUB v10.0 - PAINT OR SEEK EDITION
-- @RukanooXD_YT | ReziHub Style UI
-- Full rewrite: Modern UI, improved AutoKill, Seeker Timer fix
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
}

-- ============================================
-- GAME STATE
-- ============================================
local GameState = {
    InRound = false,
    MyRole = "Unknown",
    RoundTimer = nil,
    SeekerArrivalTime = 40,
}

local function UpdateGameState()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local inRound = false

    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:match("round ends") or text:match("hiders left") or text:match("seekers left") 
                   or text:match("hiders:%s*%d+") or text:match("seekers:%s*%d+")
                   or text:match("time:") or text:match("timer:") or text:match("time remaining") then
                    inRound = true
                end
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

    local isLobby = false
    if not inRound then
        if Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("Intermission")
           or Workspace:FindFirstChild("Waiting") or Workspace:FindFirstChild("Queue") then
            isLobby = true
        end
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
-- ENHANCED ROLE DETECTION
-- ============================================
local RoleCache = {}

local function GetPlayerRole(p)
    if not p then return "Unknown" end

    if p ~= LocalPlayer and RoleCache[p] then
        if tick() - RoleCache[p].time < 1 then
            return RoleCache[p].role
        end
    end

    local role = "Unknown"

    local playerGui = p:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:match("you:%s*seeker") or text:match("you%s*seeker") 
                   or text:match("role:%s*seeker") or text:match("team:%s*seeker")
                   or text:match("you are a seeker") then
                    role = "Seeker"
                    break
                end
                if text:match("you:%s*hider") or text:match("you%s*hider")
                   or text:match("role:%s*hider") or text:match("team:%s*hider")
                   or text:match("you are a hider") then
                    role = "Hider"
                    break
                end
            end
        end
    end

    if role == "Unknown" then
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
    end

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

    if role == "Unknown" then
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

    if p ~= LocalPlayer then
        RoleCache[p] = {role = role, time = tick()}
    end

    return role
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        RoleCache[p] = nil
        task.wait(0.5)
        CreateESPObjects(p)
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
    return GetPlayerRole(LocalPlayer) == "Seeker"
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
-- ESP UPDATE
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
-- AUTO KILL - ENHANCED INSTANT KILL SYSTEM
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
    local lChar = LocalPlayer.Character
    local lHRP = lChar and GetHRP(LocalPlayer)
    if not lHRP then return end

    local c = targetPlayer.Character
    local hrp = c and GetHRP(targetPlayer)
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local tool = GetTool()
    if not tool then return end

    local handle = GetToolHandle(tool)
    local oldCF = lHRP.CFrame
    local oldHandleCF = handle and handle.CFrame

    pcall(function()
        -- Method 1: Direct damage via Humanoid
        hum:TakeDamage(hum.MaxHealth)

        -- Method 2: BreakJoints on target
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

        -- Method 7: Headshot instant kill
        local head = c:FindFirstChild("Head")
        if head and handle then
            handle.CFrame = head.CFrame
            firetouchinterest(handle, head, 0)
            firetouchinterest(handle, head, 1)
        end

        -- Method 8: RemoteEvent fire if exists
        for _, event in ipairs(tool:GetDescendants()) do
            if event:IsA("RemoteEvent") then
                pcall(function()
                    event:FireServer(hrp.Position, targetPlayer)
                end)
            end
        end

        -- Return to original position
        lHRP.CFrame = oldCF
    end)
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
-- AUTO SAFE - ZERO DELAY, HEARTBEAT
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
-- SEEKER DETECTOR - FLASHING RED
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
-- TELEPORT HIDER - ZERO DELAY
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
            if not GameState.InRound then
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
-- AUTO COIN - ZERO DELAY, DIRECT COLLECT
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


-- ============================================
-- REZIHUB STYLE UI v10.0 - MODERN DARK THEME
-- ============================================
local SG_UI = Instance.new("ScreenGui")
SG_UI.Name = "XyinHub_" .. tostring(math.random(10000, 99999))
SG_UI.Parent = CoreGui
SG_UI.ResetOnSpawn = false
SG_UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- COLORS & STYLES (ReziHub Style)
-- ============================================
local Colors = {
    Background = Color3.fromRGB(18, 18, 28),
    BackgroundLight = Color3.fromRGB(25, 25, 40),
    BackgroundDark = Color3.fromRGB(12, 12, 20),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentGlow = Color3.fromRGB(0, 150, 200),
    Text = Color3.fromRGB(230, 230, 255),
    TextDim = Color3.fromRGB(120, 120, 150),
    Red = Color3.fromRGB(255, 60, 60),
    Green = Color3.fromRGB(60, 255, 120),
    Yellow = Color3.fromRGB(255, 200, 60),
    Purple = Color3.fromRGB(180, 100, 255),
}

-- ============================================
-- LOADING SCREEN
-- ============================================
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Colors.BackgroundDark
Loading.BorderSizePixel = 0
Loading.ZIndex = 9999
Loading.Parent = SG_UI

local LoadGradient = Instance.new("UIGradient")
LoadGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 18))
})
LoadGradient.Rotation = 45
LoadGradient.Parent = Loading

-- Particles
for i = 1, 30 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Colors.Accent
    p.BackgroundTransparency = math.random(5, 9) / 10
    p.BorderSizePixel = 0
    p.ZIndex = 10000
    p.Parent = Loading
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        while p.Parent do
            TweenService:Create(p, TweenInfo.new(math.random(2, 5)), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(5, 9) / 10
            }):Play()
            task.wait(math.random(2, 5))
        end
    end)
end

-- Logo
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 200 * UIScale, 0, 200 * UIScale)
LogoContainer.Position = UDim2.new(0.5, -100 * UIScale, 0.25, 0)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 10001
LogoContainer.Parent = Loading

local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(0, 120 * UIScale, 0, 120 * UIScale)
LogoImage.Position = UDim2.new(0.5, -60 * UIScale, 0, 0)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "https://files.catbox.moe/vg9txy.jpg"
LogoImage.ZIndex = 10001
LogoImage.Parent = LogoContainer
Instance.new("UICorner", LogoImage).CornerRadius = UDim.new(0, 20)

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Colors.Accent
LogoStroke.Thickness = 2
LogoStroke.Transparency = 0.3
LogoStroke.Parent = LogoImage

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 0, 40 * UIScale)
LogoText.Position = UDim2.new(0, 0, 0, 130 * UIScale)
LogoText.BackgroundTransparency = 1
LogoText.Text = "XYINHUB"
LogoText.TextColor3 = Colors.Accent
LogoText.TextSize = 36 * UIScale
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 10001
LogoText.Parent = LogoContainer

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(1, 0, 0, 22 * UIScale)
SubText.Position = UDim2.new(0, 0, 0, 170 * UIScale)
SubText.BackgroundTransparency = 1
SubText.Text = "Paint or Seek Edition | v10.0"
SubText.TextColor3 = Colors.TextDim
SubText.TextSize = 12 * UIScale
SubText.Font = Enum.Font.GothamBold
SubText.ZIndex = 10001
SubText.Parent = LogoContainer

-- Role Display
local RoleText = Instance.new("TextLabel")
RoleText.Size = UDim2.new(0, 300, 0, 20 * UIScale)
RoleText.Position = UDim2.new(0.5, -150, 0.55, 0)
RoleText.BackgroundTransparency = 1
RoleText.Text = "Detecting Role..."
RoleText.TextColor3 = Colors.TextDim
RoleText.TextSize = 11 * UIScale
RoleText.Font = Enum.Font.Gotham
RoleText.ZIndex = 10001
RoleText.Parent = Loading

task.spawn(function()
    while RoleText.Parent do
        local role = GetPlayerRole(LocalPlayer)
        RoleText.Text = "You: " .. role .. " | " .. (GameState.InRound and "In Round" or "In Lobby")
        if role == "Seeker" then
            RoleText.TextColor3 = Colors.Red
        elseif role == "Hider" then
            RoleText.TextColor3 = Colors.Green
        else
            RoleText.TextColor3 = Colors.TextDim
        end
        task.wait(0.5)
    end
end)

-- Progress Bar
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 320 * UIScale, 0, 6)
BarBG.Position = UDim2.new(0.5, -160 * UIScale, 0.62, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 10001
BarBG.Parent = Loading
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 3)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Colors.Accent
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10002
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 3)

local BarGlow = Instance.new("ImageLabel")
BarGlow.Size = UDim2.new(1, 20, 1, 20)
BarGlow.Position = UDim2.new(0, -10, 0, -10)
BarGlow.BackgroundTransparency = 1
BarGlow.Image = "rbxassetid://10822646370"
BarGlow.ImageColor3 = Colors.Accent
BarGlow.ImageTransparency = 0.7
BarGlow.ZIndex = 10000
BarGlow.Parent = BarFill

local PctText = Instance.new("TextLabel")
PctText.Size = UDim2.new(0, 100, 0, 22 * UIScale)
PctText.Position = UDim2.new(0.5, -50, 0.64, 10)
PctText.BackgroundTransparency = 1
PctText.Text = "0%"
PctText.TextColor3 = Colors.Accent
PctText.TextSize = 14 * UIScale
PctText.Font = Enum.Font.GothamBlack
PctText.ZIndex = 10001
PctText.Parent = Loading

task.spawn(function()
    local stages = {
        {pct = 10, txt = "Loading Core Modules..."},
        {pct = 22, txt = "Initializing ESP Engine..."},
        {pct = 35, txt = "Loading Combat Systems..."},
        {pct = 48, txt = "Loading Movement Hacks..."},
        {pct = 60, txt = "Loading Utility Modules..."},
        {pct = 72, txt = "Building Modern UI..."},
        {pct = 85, txt = "Applying Anti-Detection..."},
        {pct = 95, txt = "Finalizing Systems..."},
        {pct = 100, txt = "Ready to Dominate!"},
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
        elseif child:IsA("ImageLabel") then
            TweenService:Create(child, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        end
    end

    TweenService:Create(Loading, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    task.wait(0.8)
    Loading:Destroy()
end)


-- ============================================
-- MAIN MENU - REZIHUB STYLE
-- ============================================
local MenuSize = IsMobile and UDim2.new(0, 340, 0, 460) or UDim2.new(0, 460, 0, 600)
local Main = Instance.new("Frame")
Main.Name = "MainMenu"
Main.Size = MenuSize
Main.Position = UDim2.new(0.5, -MenuSize.X.Offset / 2, 0.5, -MenuSize.Y.Offset / 2)
Main.BackgroundColor3 = Colors.Background
Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG_UI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.25
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 22, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
})
MainGradient.Rotation = 135
MainGradient.Parent = Main

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 100, 1, 100)
Shadow.Position = UDim2.new(0, -50, 0, -50)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.35
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

-- ============================================
-- TITLE BAR
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 64 * UIScale)
TitleBar.BackgroundColor3 = Colors.BackgroundDark
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 20)

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Colors.Accent
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TitleBar

-- Logo in title
local TitleLogo = Instance.new("ImageLabel")
TitleLogo.Size = UDim2.new(0, 36, 0, 36)
TitleLogo.Position = UDim2.new(0, 14, 0, 14)
TitleLogo.BackgroundTransparency = 1
TitleLogo.Image = "https://files.catbox.moe/vg9txy.jpg"
TitleLogo.Parent = TitleBar
Instance.new("UICorner", TitleLogo).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 26 * UIScale)
TitleText.Position = UDim2.new(0, 56, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XYINHUB"
TitleText.TextColor3 = Colors.Text
TitleText.TextSize = 20 * UIScale
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0, 200, 0, 16 * UIScale)
TitleSub.Position = UDim2.new(0, 56, 0, 34)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "Paint or Seek | v10.0"
TitleSub.TextColor3 = Colors.TextDim
TitleSub.TextSize = 10 * UIScale
TitleSub.Font = Enum.Font.GothamBold
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = TitleBar

-- Role Display Badge
local RoleBadge = Instance.new("Frame")
RoleBadge.Size = UDim2.new(0, 110, 0, 26 * UIScale)
RoleBadge.Position = UDim2.new(1, -120, 0, 10)
RoleBadge.BackgroundColor3 = Colors.BackgroundLight
RoleBadge.BorderSizePixel = 0
RoleBadge.Parent = TitleBar
Instance.new("UICorner", RoleBadge).CornerRadius = UDim.new(0, 8)

local RoleBadgeStroke = Instance.new("UIStroke")
RoleBadgeStroke.Color = Colors.Accent
RoleBadgeStroke.Thickness = 1
RoleBadgeStroke.Transparency = 0.5
RoleBadgeStroke.Parent = RoleBadge

local RoleDisplay = Instance.new("TextLabel")
RoleDisplay.Size = UDim2.new(1, 0, 1, 0)
RoleDisplay.BackgroundTransparency = 1
RoleDisplay.Text = "You: Unknown"
RoleDisplay.TextColor3 = Colors.Accent
RoleDisplay.TextSize = 10 * UIScale
RoleDisplay.Font = Enum.Font.GothamBold
RoleDisplay.Parent = RoleBadge

task.spawn(function()
    while RoleDisplay.Parent do
        local role = GetPlayerRole(LocalPlayer)
        RoleDisplay.Text = "You: " .. role
        if role == "Seeker" then
            RoleDisplay.TextColor3 = Colors.Red
            RoleBadgeStroke.Color = Colors.Red
        elseif role == "Hider" then
            RoleDisplay.TextColor3 = Colors.Green
            RoleBadgeStroke.Color = Colors.Green
        else
            RoleDisplay.TextColor3 = Colors.Accent
            RoleBadgeStroke.Color = Colors.Accent
        end
        task.wait(0.3)
    end
end)

-- Minimize & Close
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0, 34)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.Text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 34)
CloseBtn.BackgroundColor3 = Colors.Red
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ============================================
-- TAB SYSTEM
-- ============================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 40 * UIScale)
TabFrame.Position = UDim2.new(0, 10, 0, 66)
TabFrame.BackgroundColor3 = Colors.BackgroundDark
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main
Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 12)

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
    btn.Size = UDim2.new(0, 100 * UIScale, 0, 32)
    btn.BackgroundColor3 = Colors.BackgroundLight
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Colors.TextDim
    btn.TextSize = 10 * UIScale
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local content = Instance.new("ScrollingFrame")
    content.Name = name
    content.Size = UDim2.new(1, -20, 1, -118 * UIScale)
    content.Position = UDim2.new(0, 10, 0, 110 * UIScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Colors.Accent
    content.CanvasSize = UDim2.new(0, 0, 0, 1200)
    content.Visible = false
    content.Parent = Main

    Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)

    table.insert(Tabs, btn)
    Contents[name] = content

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(Tabs) do
            b.BackgroundColor3 = Colors.BackgroundLight
            b.TextColor3 = Colors.TextDim
        end
        for _, c in pairs(Contents) do c.Visible = false end
        btn.BackgroundColor3 = Colors.Accent
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        content.Visible = true
    end)

    return content
end

local ESPContent = MakeTab("ESP", "[O]")
local CombatContent = MakeTab("Combat", "[/]")
local MiscContent = MakeTab("Misc", "[*]")
local PlayerContent = MakeTab("Player", "[^]")

Tabs[1].BackgroundColor3 = Colors.Accent
Tabs[1].TextColor3 = Color3.fromRGB(0, 0, 0)
ESPContent.Visible = true


-- ============================================
-- UI COMPONENTS - REZIHUB STYLE
-- ============================================
local function MakeToggle(parent, text, key, desc)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 58 * UIScale)
    f.BackgroundColor3 = Colors.BackgroundLight
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 14)

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(35, 35, 55)
    fStroke.Thickness = 1
    fStroke.Parent = f

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
        d.TextColor3 = Colors.TextDim
        d.TextSize = 9 * UIScale
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
    end

    -- Modern Toggle Switch
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 52, 0, 26)
    bg.Position = UDim2.new(1, -64, 0.5, -13)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = Color3.fromRGB(50, 50, 70)
    bgStroke.Thickness = 1
    bgStroke.Parent = bg

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    circle.BorderSizePixel = 0
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local circleShadow = Instance.new("ImageLabel")
    circleShadow.Size = UDim2.new(1.3, 0, 1.3, 0)
    circleShadow.Position = UDim2.new(-0.15, 0, -0.15, 0)
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
            TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Colors.Accent}):Play()
            TweenService:Create(bgStroke, TweenInfo.new(0.25), {Color = Colors.AccentGlow}):Play()
            TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 28, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(circleShadow, TweenInfo.new(0.25), {ImageTransparency = 0.5}):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
            TweenService:Create(bgStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(50, 50, 70)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            }):Play()
            TweenService:Create(circleShadow, TweenInfo.new(0.25), {ImageTransparency = 1}):Play()
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
    f.BackgroundColor3 = Colors.BackgroundLight
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 14)

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(35, 35, 55)
    fStroke.Thickness = 1
    fStroke.Parent = f

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
    sbg.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    sbg.BorderSizePixel = 0
    sbg.Parent = f
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(0, 3)

    local sbgStroke = Instance.new("UIStroke")
    sbgStroke.Color = Color3.fromRGB(40, 40, 60)
    sbgStroke.Thickness = 1
    sbgStroke.Parent = sbg

    -- Slider Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sbg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local fillGlow = Instance.new("ImageLabel")
    fillGlow.Size = UDim2.new(1, 10, 1, 10)
    fillGlow.Position = UDim2.new(0, -5, 0, -5)
    fillGlow.BackgroundTransparency = 1
    fillGlow.Image = "rbxassetid://10822646370"
    fillGlow.ImageColor3 = Colors.Accent
    fillGlow.ImageTransparency = 0.6
    fillGlow.Parent = fill

    -- Slider Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((Settings[key] - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Colors.Accent
    knob.BorderSizePixel = 0
    knob.Parent = sbg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Color3.fromRGB(255, 255, 255)
    knobStroke.Thickness = 2
    knobStroke.Transparency = 0.3
    knobStroke.Parent = knob

    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Size = UDim2.new(1.5, 0, 1.5, 0)
    knobShadow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://10822646370"
    knobShadow.ImageColor3 = Colors.Accent
    knobShadow.ImageTransparency = 0.4
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


-- ============================================
-- TAB CONTENTS
-- ============================================

-- ESP Tab
MakeToggle(ESPContent, "ESP", "ESP", "Show all players with role & distance")

-- Combat Tab
MakeToggle(CombatContent, "Auto Kill", "AutoKill", "Instant kill all hiders with weapon")
MakeSlider(CombatContent, "Kill Radius", "AutoKillRadius", 10, 9999, " studs")
MakeToggle(CombatContent, "Teleport to Hider", "TeleportHider", "TP to nearest hider instantly")
MakeToggle(CombatContent, "Auto Safe", "AutoSafe", "Auto escape when seeker approaches")
MakeSlider(CombatContent, "Safe Distance", "SafeDistance", 10, 80, " studs")
MakeToggle(CombatContent, "Seeker Detector", "SeekerDetector", "Alert when seeker is nearby")
MakeSlider(CombatContent, "Detector Range", "DetectorRange", 50, 500, " studs")

-- Misc Tab
MakeToggle(MiscContent, "Auto Collect Coin", "AutoCoin", "Instant collect all coins on map")
MakeToggle(MiscContent, "Noclip", "Noclip", "Walk through walls and obstacles")

-- Player Tab
MakeToggle(PlayerContent, "Speed Hack", "SpeedHack", "Super speed movement")
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
-- TOGGLE BUTTON - MODERN STYLE
-- ============================================
local ToggleBtnSize = IsMobile and UDim2.new(0, 56, 0, 56) or UDim2.new(0, 52, 0, 52)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuToggle"
MenuBtn.Size = ToggleBtnSize
MenuBtn.Position = UDim2.new(0, 18, 0.5, -ToggleBtnSize.Y.Offset / 2)
MenuBtn.BackgroundColor3 = Colors.Background
MenuBtn.Text = "X"
MenuBtn.TextColor3 = Colors.Accent
MenuBtn.TextSize = 22 * UIScale
MenuBtn.Font = Enum.Font.GothamBlack
MenuBtn.Parent = SG_UI

Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 16)

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Colors.Accent
BtnStroke.Thickness = 2
BtnStroke.Parent = MenuBtn

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
        TweenService:Create(BtnGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.3}):Play()
        task.wait(1.2)
        TweenService:Create(BtnGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.7}):Play()
        task.wait(1.2)
    end
end)

MenuBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        MenuBtn.BackgroundColor3 = Colors.Accent
        MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        BtnStroke.Color = Colors.AccentGlow
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
            MenuBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            BtnStroke.Color = Colors.AccentGlow
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
NotifFrame.Size = UDim2.new(0, 380 * UIScale, 0, 90 * UIScale)
NotifFrame.Position = UDim2.new(1, 20, 1, 20)
NotifFrame.BackgroundColor3 = Colors.BackgroundDark
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = SG_UI
Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 16)

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Colors.Accent
NotifStroke.Thickness = 1.5
NotifStroke.Transparency = 0.35
NotifStroke.Parent = NotifFrame

local NotifAccent = Instance.new("Frame")
NotifAccent.Size = UDim2.new(0, 4, 1, 0)
NotifAccent.BackgroundColor3 = Colors.Accent
NotifAccent.BorderSizePixel = 0
NotifAccent.Parent = NotifFrame
Instance.new("UICorner", NotifAccent).CornerRadius = UDim.new(0, 16)

local NotifLogo = Instance.new("ImageLabel")
NotifLogo.Size = UDim2.new(0, 40 * UIScale, 0, 40 * UIScale)
NotifLogo.Position = UDim2.new(0, 16, 0, 12)
NotifLogo.BackgroundTransparency = 1
NotifLogo.Image = "https://files.catbox.moe/vg9txy.jpg"
NotifLogo.Parent = NotifFrame
Instance.new("UICorner", NotifLogo).CornerRadius = UDim.new(0, 8)

local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size = UDim2.new(1, -80, 0, 24 * UIScale)
NotifTitle.Position = UDim2.new(0, 64, 0, 10)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "XYINHUB v10.0 LOADED"
NotifTitle.TextColor3 = Colors.Accent
NotifTitle.TextSize = 14 * UIScale
NotifTitle.Font = Enum.Font.GothamBlack
NotifTitle.Parent = NotifFrame

local NotifRole = Instance.new("TextLabel")
NotifRole.Size = UDim2.new(1, -80, 0, 18 * UIScale)
NotifRole.Position = UDim2.new(0, 64, 0, 34)
NotifRole.BackgroundTransparency = 1
NotifRole.Text = "Role: Detecting..."
NotifRole.TextColor3 = Colors.TextDim
NotifRole.TextSize = 10 * UIScale
NotifRole.Font = Enum.Font.GothamBold
NotifRole.Parent = NotifFrame

task.spawn(function()
    while NotifRole.Parent do
        local role = GetPlayerRole(LocalPlayer)
        NotifRole.Text = "User: " .. LocalPlayer.Name .. " | Role: " .. role .. " | " .. (GameState.InRound and "In Round" or "Lobby")
        if role == "Seeker" then
            NotifRole.TextColor3 = Colors.Red
        elseif role == "Hider" then
            NotifRole.TextColor3 = Colors.Green
        else
            NotifRole.TextColor3 = Colors.TextDim
        end
        task.wait(0.5)
    end
end)

local NotifVer = Instance.new("TextLabel")
NotifVer.Size = UDim2.new(1, -80, 0, 16 * UIScale)
NotifVer.Position = UDim2.new(0, 64, 0, 54)
NotifVer.BackgroundTransparency = 1
NotifVer.Text = "Paint or Seek | @RukanooXD_YT"
NotifVer.TextColor3 = Colors.TextDim
NotifVer.TextSize = 9 * UIScale
NotifVer.Font = Enum.Font.Gotham
NotifVer.Parent = NotifFrame

local NotifHotkeys = Instance.new("TextLabel")
NotifHotkeys.Size = UDim2.new(1, -24, 0, 14 * UIScale)
NotifHotkeys.Position = UDim2.new(0, 12, 0, 72)
NotifHotkeys.BackgroundTransparency = 1
NotifHotkeys.Text = "RightAlt=Menu | Insert=ESP | Home=Kill | PageUp=TP | End=Coin | Del=Speed | N=Noclip"
NotifHotkeys.TextColor3 = Color3.fromRGB(80, 80, 100)
NotifHotkeys.TextSize = 8 * UIScale
NotifHotkeys.Font = Enum.Font.Gotham
NotifHotkeys.Parent = NotifFrame

NotifFrame:TweenPosition(UDim2.new(1, -400 * UIScale, 1, -100 * UIScale), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5)

task.delay(12, function()
    NotifFrame:TweenPosition(UDim2.new(1, 20, 1, 20), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.4)
    task.wait(0.5)
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
print("[XYINHUB] v10.0 Paint or Seek Edition LOADED")
print("[XYINHUB] User: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId)
print("[XYINHUB] Role: " .. GetPlayerRole(LocalPlayer))
print("[XYINHUB] Device: " .. (IsMobile and "Mobile" or "PC"))
print("[XYINHUB] Systems: ESP, AutoKill, AutoSafe, SeekerDetector, Speed, Jump, Noclip, AutoCoin, TeleportHider")
print("[XYINHUB] Hotkeys: RightAlt=Menu | Insert=ESP | Home=AutoKill | PageUp=TPHider | End=Coin | Delete=Speed | N=Noclip")
print("[XYINHUB] @RukanooXD_YT")
print("[XYINHUB] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-.")

-- ============================================
-- END OF XYINHUB v10.0
-- ============================================
