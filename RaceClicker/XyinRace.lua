-- ============================================================
-- RACE CLICKER - ULTIMATE CHEAT v4.0
-- Developer: @XyrooXellz
-- Style: Micro Black & White Root Terminal
-- Game: Race Clicker (by 48h Games) | ID: 9285238704
-- Executor: Synapse X / KRNL / Fluxus / Script-Ware / Delta / Hydrogen
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- KONFIGURASI
-- ============================================================
local Config = {
    -- Race Menu
    AutoRace = false,
    SpeedHack = false,
    SpeedValue = 999000000000,
    AutoClick = false,
    ClickSpeed = 0.001,

    -- Misc Menu
    AutoFarm = false,
    AutoRebirth = false,
    AutoHatch = false,
    AutoEquipBestPets = false,
    AutoRedeemCodes = false,
    AntiFall = false,
    AutoSteer = false,
    WalkSpeed = 100,
    JumpPower = 150,
    TeleportToBestWorld = false,

    -- Profile Menu
    ShowStats = false,
}

-- ============================================================
-- GAME STATE DETECTION
-- ============================================================
local GameState = {
    IsRaceActive = false,
    IsClickPhase = false,
    Countdown = 0,
    CurrentWorld = 1,
    Wins = 0,
    Rebirths = 0,
    Speed = 0,
}

-- Cari Remote Events
local Remotes = {}
local function FindRemotes()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("click") or name:find("tap") or name:find("speed") then
                Remotes.Click = v
            elseif name:find("rebirth") then
                Remotes.Rebirth = v
            elseif name:find("hatch") or name:find("egg") then
                Remotes.Hatch = v
            elseif name:find("equip") or name:find("pet") then
                Remotes.EquipPet = v
            elseif name:find("code") or name:find("redeem") then
                Remotes.RedeemCode = v
            elseif name:find("race") or name:find("start") then
                Remotes.Race = v
            elseif name:find("world") or name:find("teleport") then
                Remotes.Teleport = v
            end
        end
    end
end
FindRemotes()

-- Backup workspace
if not Remotes.Click then
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("click") or name:find("tap") or name:find("speed") then
                Remotes.Click = v
            end
        end
    end
end

-- Update Game State
local function UpdateGameState()
    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            local text = v.Text:lower()
            if text:find("race starting") or text:find("get ready") or text:find("click!") or text:find("countdown") then
                GameState.IsClickPhase = true
                GameState.IsRaceActive = false
            elseif text:find("race in progress") or text:find("racing") or text:find("go!") then
                GameState.IsClickPhase = false
                GameState.IsRaceActive = true
            elseif text:find("finished") or text:find("results") or text:find("winner") then
                GameState.IsClickPhase = false
                GameState.IsRaceActive = false
            end

            local num = text:match("(%d+)")
            if num then
                GameState.Countdown = tonumber(num)
            end
        end
    end

    -- Update stats
    for _, v in pairs(LocalPlayer:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local name = v.Name:lower()
            if name:find("win") then
                GameState.Wins = v.Value
            elseif name:find("rebirth") then
                GameState.Rebirths = v.Value
            elseif name:find("speed") or name:find("strength") then
                GameState.Speed = v.Value
            end
        end
    end
end

-- ============================================================
-- UTILITY
-- ============================================================
local function Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:WaitForChild("Humanoid")
end

local function GetHRP()
    local char = GetCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

-- ============================================================
-- RACE ENGINE (Merged: Auto Win + Auto Race + Speed Hack)
-- ============================================================
local RaceEngine = {
    Connection = nil,
    SpeedBodyVelocity = nil,
}

local function ApplySpeedHack()
    if not Config.SpeedHack then return end

    local hrp = GetHRP()
    local humanoid = GetHumanoid()

    -- Method 1: WalkSpeed
    humanoid.WalkSpeed = 999

    -- Method 2: Velocity
    pcall(function()
        hrp.Velocity = hrp.CFrame.LookVector * Config.SpeedValue
    end)

    -- Method 3: Remote
    if Remotes.Click then
        pcall(function()
            Remotes.Click:FireServer(Config.SpeedValue)
        end)
    end

    -- Method 4: BodyVelocity
    pcall(function()
        if not RaceEngine.SpeedBodyVelocity or not RaceEngine.SpeedBodyVelocity.Parent then
            RaceEngine.SpeedBodyVelocity = Instance.new("BodyVelocity")
            RaceEngine.SpeedBodyVelocity.Name = "XyrooXellz_Speed"
            RaceEngine.SpeedBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            RaceEngine.SpeedBodyVelocity.Parent = hrp
        end
        RaceEngine.SpeedBodyVelocity.Velocity = hrp.CFrame.LookVector * Config.SpeedValue
    end)

    -- Method 5: CFrame teleport
    pcall(function()
        if GameState.IsRaceActive then
            hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 50)
        end
    end)

    -- Method 6: Stats modify
    pcall(function()
        for _, v in pairs(LocalPlayer:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("speed") or name:find("strength") or name:find("power") then
                    v.Value = Config.SpeedValue
                end
            end
        end
    end)
end

local function CleanupSpeedHack()
    pcall(function()
        local hrp = GetHRP()
        local bv = hrp:FindFirstChild("XyrooXellz_Speed")
        if bv then bv:Destroy() end
        RaceEngine.SpeedBodyVelocity = nil
    end)
    pcall(function()
        GetHumanoid().WalkSpeed = 16
    end)
end

local function StartRaceEngine()
    if RaceEngine.Connection then return end

    Notify("🏁 Race Engine", "Activated! Auto Win + Speed Hack + Auto Click")

    RaceEngine.Connection = RunService.Heartbeat:Connect(function()
        UpdateGameState()

        -- PHASE 1: CLICK PHASE (0-30 detik)
        if GameState.IsClickPhase or GameState.Countdown > 0 then
            -- Auto Clicker
            if Config.AutoClick then
                for i = 1, 10 do
                    if Remotes.Click then
                        pcall(function()
                            Remotes.Click:FireServer()
                        end)
                    end
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ClickDetector") then
                            pcall(function() fireclickdetector(v) end)
                        end
                        if v:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(v) end)
                        end
                    end
                end
            end
        end

        -- PHASE 2: RACE PHASE (Auto Win)
        if GameState.IsRaceActive then
            local hrp = GetHRP()
            local humanoid = GetHumanoid()

            -- Speed Hack
            ApplySpeedHack()

            -- Auto run
            humanoid:Move(Vector3.new(0, 0, -1))

            -- Teleport ke finish (instant win)
            for _, v in pairs(workspace:GetDescendants()) do
                local name = v.Name:lower()
                if name:find("finish") or name:find("end") or name:find("goal") or name:find("win") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        pcall(function()
                            hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                        end)
                        break
                    end
                end
            end

            -- Teleport ke checkpoint
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("checkpoint") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        pcall(function()
                            hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        end)
                    end
                end
            end

            -- CFrame rush forward
            pcall(function()
                hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 100)
            end)
        end

        -- PHASE 3: RESULTS (Auto restart)
        if not GameState.IsRaceActive and not GameState.IsClickPhase then
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local name = v.Name:lower()
                    if name:find("race") or name:find("start") or name:find("next") or name:find("play") or name:find("restart") then
                        pcall(function()
                            v.MouseButton1Click:Fire()
                        end)
                    end
                end
            end

            if Remotes.Race then
                pcall(function()
                    Remotes.Race:FireServer("Start")
                end)
            end
        end

        -- Anti Fall
        if Config.AntiFall then
            local hrp = GetHRP()
            if hrp.Position.Y < -50 then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("spawn") or v.Name:lower():find("start") then
                        if v:IsA("BasePart") or v:IsA("MeshPart") then
                            hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                            break
                        end
                    end
                end
            end
        end

        -- Auto Steer
        if Config.AutoSteer then
            local hrp = GetHRP()
            local humanoid = GetHumanoid()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("track") or v.Name:lower():find("path") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        local trackCenter = v.Position
                        local direction = (trackCenter - hrp.Position).Unit
                        direction = Vector3.new(direction.X, 0, direction.Z)
                        humanoid:Move(direction)
                        break
                    end
                end
            end
        end
    end)
end

local function StopRaceEngine()
    if RaceEngine.Connection then
        RaceEngine.Connection:Disconnect()
        RaceEngine.Connection = nil
    end
    CleanupSpeedHack()
end

-- ============================================================
-- MISC FUNCTIONS
-- ============================================================
-- Auto Farm
local FarmConnection
local function StartAutoFarm()
    if FarmConnection then return end
    Notify("💰 Auto Farm", "Activated!")

    FarmConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end
        UpdateGameState()

        if GameState.IsClickPhase then
            for i = 1, 5 do
                if Remotes.Click then
                    pcall(function() Remotes.Click:FireServer() end)
                end
            end
        end

        if GameState.IsRaceActive then
            ApplySpeedHack()
            GetHumanoid():Move(Vector3.new(0, 0, -1))
            local hrp = GetHRP()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("finish") or v.Name:lower():find("end") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        pcall(function() hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0) end)
                        break
                    end
                end
            end
        end

        task.wait(0.05)
    end)
end

local function StopAutoFarm()
    if FarmConnection then
        FarmConnection:Disconnect()
        FarmConnection = nil
    end
end

-- Auto Rebirth
local RebirthConnection
local function StartAutoRebirth()
    if RebirthConnection then return end
    Notify("🔄 Auto Rebirth", "Activated!")

    RebirthConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoRebirth then return end

        if Remotes.Rebirth then
            pcall(function() Remotes.Rebirth:FireServer() end)
        else
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    if v.Name:lower():find("rebirth") then
                        pcall(function() v.MouseButton1Click:Fire() end)
                    end
                end
            end
        end

        task.wait(1)
    end)
end

local function StopAutoRebirth()
    if RebirthConnection then
        RebirthConnection:Disconnect()
        RebirthConnection = nil
    end
end

-- Auto Hatch
local HatchConnection
local function StartAutoHatch()
    if HatchConnection then return end
    Notify("🥚 Auto Hatch", "Activated!")

    HatchConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoHatch then return end

        if Remotes.Hatch then
            pcall(function() Remotes.Hatch:FireServer("BestEgg") end)
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("egg") and (v:IsA("BasePart") or v:IsA("MeshPart")) then
                    pcall(function()
                        local hrp = GetHRP()
                        hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        for _, child in pairs(v:GetDescendants()) do
                            if child:IsA("ProximityPrompt") then
                                fireproximityprompt(child)
                            elseif child:IsA("ClickDetector") then
                                fireclickdetector(child)
                            end
                        end
                    end)
                end
            end
        end

        task.wait(0.5)
    end)
end

local function StopAutoHatch()
    if HatchConnection then
        HatchConnection:Disconnect()
        HatchConnection = nil
    end
end

-- Auto Equip Best Pets
local EquipConnection
local function StartAutoEquip()
    if EquipConnection then return end
    Notify("🐾 Auto Equip", "Activated!")

    EquipConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoEquipBestPets then return end

        if Remotes.EquipPet then
            pcall(function() Remotes.EquipPet:FireServer("BestPets") end)
        else
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local name = v.Name:lower()
                    if name:find("equip") and name:find("pet") then
                        pcall(function() v.MouseButton1Click:Fire() end)
                    end
                end
            end
        end

        task.wait(2)
    end)
end

local function StopAutoEquip()
    if EquipConnection then
        EquipConnection:Disconnect()
        EquipConnection = nil
    end
end

-- Redeem Codes
local Codes = {
    "Easter!", "Fantasy", "Season14", "NewPotion", "Ninja",
    "RaceTrack", "67", "Christmas", "XMAS", "Winter",
    "REVERT", "800m", "Halloween", "Toy", "Fall",
}

local function RedeemAllCodes()
    Notify("🎫 Codes", "Redeeming...")
    for _, code in pairs(Codes) do
        if Remotes.RedeemCode then
            pcall(function() Remotes.RedeemCode:FireServer(code) end)
        else
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextBox") and v.Name:lower():find("code") then
                    pcall(function()
                        v.Text = code
                        for _, btn in pairs(v.Parent:GetDescendants()) do
                            if btn:IsA("TextButton") and btn.Name:lower():find("redeem") then
                                btn.MouseButton1Click:Fire()
                            end
                        end
                    end)
                end
            end
        end
        task.wait(0.5)
    end
    Notify("🎫 Codes", "All redeemed!")
end

-- Teleport Best World
local function TeleportToBestWorld()
    Notify("🌍 Teleport", "Finding best world...")

    if Remotes.Teleport then
        pcall(function()
            for i = 6, 1, -1 do
                Remotes.Teleport:FireServer("World" .. tostring(i))
                task.wait(0.5)
            end
        end)
    else
        local bestWorld = nil
        local highestWorldNum = 0

        for _, v in pairs(workspace:GetDescendants()) do
            local name = v.Name:lower()
            if name:find("world") or name:find("portal") or name:find("teleport") then
                local num = tonumber(name:match("%d+"))
                if num and num > highestWorldNum then
                    highestWorldNum = num
                    bestWorld = v
                end
            end
        end

        if bestWorld and (bestWorld:IsA("BasePart") or bestWorld:IsA("MeshPart")) then
            GetHRP().CFrame = bestWorld.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

-- Speed Mods
local SpeedModConnection
local function ApplySpeedMods()
    local humanoid = GetHumanoid()
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
end

local function StartSpeedMods()
    SpeedModConnection = RunService.Heartbeat:Connect(function()
        ApplySpeedMods()
    end)
end

-- ============================================================
-- UI: MICRO BLACK & WHITE ROOT TERMINAL STYLE
-- ============================================================

-- Destroy existing
if game.CoreGui:FindFirstChild("XyrooXellzTerminal") then
    game.CoreGui:FindFirstChild("XyrooXellzTerminal"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyrooXellzTerminal"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Terminal Colors
local Colors = {
    BG = Color3.fromRGB(8, 8, 12),
    Panel = Color3.fromRGB(15, 15, 20),
    PanelHover = Color3.fromRGB(25, 25, 30),
    Text = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentGlow = Color3.fromRGB(200, 200, 200),
    Green = Color3.fromRGB(100, 255, 100),
    Red = Color3.fromRGB(255, 80, 80),
    Border = Color3.fromRGB(40, 40, 45),
}

-- Blur Effect
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

-- ============================================================
-- LOADING SCREEN
-- ============================================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Colors.BG
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(0, 500, 0, 40)
LoadingTitle.Position = UDim2.new(0.5, -250, 0.38, 0)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "XYROOXELLZ // RACE CLICKER"
LoadingTitle.TextColor3 = Colors.Text
LoadingTitle.TextSize = 28
LoadingTitle.Font = Enum.Font.Code
LoadingTitle.ZIndex = 101
LoadingTitle.Parent = LoadingFrame

local LoadingSub = Instance.new("TextLabel")
LoadingSub.Size = UDim2.new(0, 500, 0, 20)
LoadingSub.Position = UDim2.new(0.5, -250, 0.43, 0)
LoadingSub.BackgroundTransparency = 1
LoadingSub.Text = "INITIALIZING ROOT TERMINAL v4.0"
LoadingSub.TextColor3 = Colors.TextDim
LoadingSub.TextSize = 12
LoadingSub.Font = Enum.Font.Code
LoadingSub.ZIndex = 101
LoadingSub.Parent = LoadingFrame

-- Terminal-style progress
local ProgressContainer = Instance.new("Frame")
ProgressContainer.Size = UDim2.new(0, 400, 0, 20)
ProgressContainer.Position = UDim2.new(0.5, -200, 0.48, 0)
ProgressContainer.BackgroundColor3 = Colors.Panel
ProgressContainer.BorderSizePixel = 0
ProgressContainer.ZIndex = 101
ProgressContainer.Parent = LoadingFrame

local ProgressBorder = Instance.new("UIStroke")
ProgressBorder.Color = Colors.Border
ProgressBorder.Thickness = 1
ProgressBorder.Parent = ProgressContainer

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Colors.Text
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 102
ProgressFill.Parent = ProgressContainer

local ProgressText = Instance.new("TextLabel")
ProgressText.Size = UDim2.new(0, 400, 0, 20)
ProgressText.Position = UDim2.new(0.5, -200, 0.52, 0)
ProgressText.BackgroundTransparency = 1
ProgressText.Text = "> BOOTING..."
ProgressText.TextColor3 = Colors.Green
ProgressText.TextSize = 11
ProgressText.Font = Enum.Font.Code
ProgressText.ZIndex = 101
ProgressText.Parent = LoadingFrame

-- Log lines
local LogLines = {}
for i = 1, 5 do
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(0, 500, 0, 16)
    line.Position = UDim2.new(0.5, -250, 0.56 + (i * 0.02), 0)
    line.BackgroundTransparency = 1
    line.Text = ""
    line.TextColor3 = Colors.TextDim
    line.TextSize = 10
    line.Font = Enum.Font.Code
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.ZIndex = 101
    line.Parent = LoadingFrame
    LogLines[i] = line
end

local bootLogs = {
    "> [OK] Connected to game server",
    "> [OK] Remote events detected",
    "> [OK] Player data loaded",
    "> [OK] Modules initialized",
    "> [OK] UI rendering...",
}

local function PlayBootSequence()
    for i, log in ipairs(bootLogs) do
        LogLines[i].Text = log
        task.wait(0.3)
    end

    for i = 1, 100 do
        local progress = i / 100
        ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        ProgressText.Text = "> LOADING " .. i .. "%"
        task.wait(0.02)
    end

    ProgressText.Text = "> SYSTEM READY"
    ProgressText.TextColor3 = Colors.Green
    task.wait(0.5)

    TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    for _, child in pairs(LoadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        end
    end

    task.wait(0.6)
    LoadingFrame:Destroy()
end

-- ============================================================
-- MAIN TERMINAL FRAME
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainTerminal"
MainFrame.Size = UDim2.new(0, 420, 0, 540)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -270)
MainFrame.BackgroundColor3 = Colors.BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Colors.Panel
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = MainFrame

local TitleBarStroke = Instance.new("UIStroke")
TitleBarStroke.Color = Colors.Border
TitleBarStroke.Thickness = 1
TitleBarStroke.Parent = TitleBar

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 250, 0, 36)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XYROOXELLZ // RACE_CLICKER"
TitleText.TextColor3 = Colors.Text
TitleText.TextSize = 13
TitleText.Font = Enum.Font.Code
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 12
TitleText.Parent = TitleBar

-- Status
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 6, 0, 6)
StatusIndicator.Position = UDim2.new(1, -50, 0, 15)
StatusIndicator.BackgroundColor3 = Colors.Green
StatusIndicator.BorderSizePixel = 0
StatusIndicator.ZIndex = 12
StatusIndicator.Parent = TitleBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusIndicator

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 40, 0, 36)
StatusText.Position = UDim2.new(1, -42, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "ONLINE"
StatusText.TextColor3 = Colors.Green
StatusText.TextSize = 9
StatusText.Font = Enum.Font.Code
StatusText.ZIndex = 12
StatusText.Parent = TitleBar

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Colors.Panel
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.Code
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 12
CloseBtn.Parent = TitleBar

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -64, 0, 3)
MinBtn.BackgroundColor3 = Colors.Panel
MinBtn.Text = "−"
MinBtn.TextColor3 = Colors.Text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.Code
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 12
MinBtn.Parent = TitleBar

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local CurrentTab = "RACE"
local Tabs = {}
local TabContents = {}

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 36)
TabBar.BackgroundColor3 = Colors.BG
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = MainFrame

local TabBarStroke = Instance.new("UIStroke")
TabBarStroke.Color = Colors.Border
TabBarStroke.Thickness = 1
TabBarStroke.Parent = TabBar

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.BackgroundColor3 = Colors.BG
    TabBtn.Text = "[" .. name .. "]"
    TabBtn.TextColor3 = Colors.TextDim
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.Code
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 12
    TabBtn.Parent = TabBar

    local TabIndicator = Instance.new("Frame")
    TabIndicator.Size = UDim2.new(1, 0, 0, 2)
    TabIndicator.Position = UDim2.new(0, 0, 1, -2)
    TabIndicator.BackgroundColor3 = Colors.Text
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = false
    TabIndicator.ZIndex = 13
    TabIndicator.Parent = TabBtn

    Tabs[name] = {Button = TabBtn, Indicator = TabIndicator}

    -- Content Frame
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "Content"
    Content.Size = UDim2.new(1, -16, 1, -100)
    Content.Position = UDim2.new(0, 8, 0, 72)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Colors.TextDim
    Content.CanvasSize = UDim2.new(0, 0, 0, 500)
    Content.ZIndex = 11
    Content.Visible = false
    Content.Parent = MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.Parent = Content

    TabContents[name] = Content

    TabBtn.MouseButton1Click:Connect(function()
        for tabName, tabData in pairs(Tabs) do
            tabData.Button.TextColor3 = Colors.TextDim
            tabData.Indicator.Visible = false
            TabContents[tabName].Visible = false
        end

        TabBtn.TextColor3 = Colors.Text
        TabIndicator.Visible = true
        Content.Visible = true
        CurrentTab = name
    end)

    -- Hover
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.PanelHover}):Play()
        end
    end)

    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.BG}):Play()
        end
    end)

    return Content
end

-- Create tabs
local RaceContent = CreateTab("RACE", "🏁")
local MiscContent = CreateTab("MISC", "⚙️")
local ProfileContent = CreateTab("PROFILE", "👤")

-- Position tabs
local tabNames = {"RACE", "MISC", "PROFILE"}
for i, name in ipairs(tabNames) do
    Tabs[name].Button.Position = UDim2.new(0, (i - 1) * 100, 0, 0)
end

-- Default active
Tabs["RACE"].Button.TextColor3 = Colors.Text
Tabs["RACE"].Indicator.Visible = true
TabContents["RACE"].Visible = true

-- ============================================================
-- UI COMPONENTS
-- ============================================================
local function CreateSection(parent, text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, -10, 0, 22)
    Section.BackgroundTransparency = 1
    Section.Text = "// " .. text:upper()
    Section.TextColor3 = Colors.TextDim
    Section.TextSize = 10
    Section.Font = Enum.Font.Code
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.ZIndex = 12
    Section.Parent = parent
    return Section
end

local function CreateToggle(parent, name, configKey, startFunc, stopFunc)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Colors.Panel
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 12
    Frame.Parent = parent

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Colors.Border
    FrameStroke.Thickness = 1
    FrameStroke.Parent = Frame

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 200, 0, 38)
    NameLabel.Position = UDim2.new(0, 12, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = "> " .. name
    NameLabel.TextColor3 = Colors.Text
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.Code
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.ZIndex = 13
    NameLabel.Parent = Frame

    -- Status
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0, 50, 0, 38)
    StatusLabel.Position = UDim2.new(1, -90, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "[OFF]"
    StatusLabel.TextColor3 = Colors.Red
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.ZIndex = 13
    StatusLabel.Parent = Frame

    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -62, 0, 7)
    ToggleBtn.BackgroundColor3 = Colors.PanelHover
    ToggleBtn.Text = "EXEC"
    ToggleBtn.TextColor3 = Colors.TextDim
    ToggleBtn.TextSize = 10
    ToggleBtn.Font = Enum.Font.Code
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 13
    ToggleBtn.Parent = Frame

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Colors.Border
    ToggleStroke.Thickness = 1
    ToggleStroke.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]

        if Config[configKey] then
            StatusLabel.Text = "[ON]"
            StatusLabel.TextColor3 = Colors.Green
            ToggleBtn.TextColor3 = Colors.Green
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
            ToggleStroke.Color = Colors.Green
            if startFunc then startFunc() end
        else
            StatusLabel.Text = "[OFF]"
            StatusLabel.TextColor3 = Colors.Red
            ToggleBtn.TextColor3 = Colors.TextDim
            ToggleBtn.BackgroundColor3 = Colors.PanelHover
            ToggleStroke.Color = Colors.Border
            if stopFunc then stopFunc() end
        end
    end)

    ToggleBtn.MouseEnter:Connect(function()
        if not Config[configKey] then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
        end
    end)

    ToggleBtn.MouseLeave:Connect(function()
        if not Config[configKey] then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.PanelHover}):Play()
        end
    end)

    return Frame
end

local function CreateActionButton(parent, name, callback, color)
    color = color or Colors.Text

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Colors.Panel
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 12
    Frame.Parent = parent

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Colors.Border
    FrameStroke.Thickness = 1
    FrameStroke.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ">>> " .. name:upper()
    Btn.TextColor3 = color
    Btn.TextSize = 12
    Btn.Font = Enum.Font.Code
    Btn.AutoButtonColor = false
    Btn.ZIndex = 13
    Btn.Parent = Frame

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
        task.wait(0.1)
        TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Panel}):Play()
        callback()
    end)

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Frame, TweenInfo.new(0.15), {BackgroundColor3 = Colors.PanelHover}):Play()
        TweenService:Create(FrameStroke, TweenInfo.new(0.15), {Color = color}):Play()
    end)

    Btn.MouseLeave:Connect(function()
        TweenService:Create(Frame, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Panel}):Play()
        TweenService:Create(FrameStroke, TweenInfo.new(0.15), {Color = Colors.Border}):Play()
    end)

    return Frame
end

local function CreateInfoLine(parent, label, value)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 28)
    Frame.BackgroundColor3 = Colors.Panel
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 12
    Frame.Parent = parent

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Colors.Border
    FrameStroke.Thickness = 1
    FrameStroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 28)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "> " .. label
    Label.TextColor3 = Colors.TextDim
    Label.TextSize = 11
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 13
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 200, 0, 28)
    ValueLabel.Position = UDim2.new(1, -210, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = Colors.Text
    ValueLabel.TextSize = 11
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = 13
    ValueLabel.Parent = Frame

    return Frame, ValueLabel
end

-- ============================================================
-- RACE TAB CONTENT
-- ============================================================
CreateSection(RaceContent, "Race Engine")
CreateToggle(RaceContent, "Auto Race (Win + Speed)", "AutoRace", StartRaceEngine, StopRaceEngine)
CreateToggle(RaceContent, "Auto Clicker", "AutoClick", function() end, function() end)
CreateToggle(RaceContent, "Speed Hack 999B", "SpeedHack", function() end, CleanupSpeedHack)

CreateSection(RaceContent, "Race Settings")
CreateToggle(RaceContent, "Anti-Fall", "AntiFall", function() end, function() end)
CreateToggle(RaceContent, "Auto Steer", "AutoSteer", function() end, function() end)

-- Speed Presets
local SpeedPresets = {"1M", "1B", "999B"}
local SpeedValues = {1000000, 1000000000, 999000000000}

local PresetFrame = Instance.new("Frame")
PresetFrame.Size = UDim2.new(1, -10, 0, 38)
PresetFrame.BackgroundColor3 = Colors.Panel
PresetFrame.BorderSizePixel = 0
PresetFrame.ZIndex = 12
PresetFrame.Parent = RaceContent

local PresetStroke = Instance.new("UIStroke")
PresetStroke.Color = Colors.Border
PresetStroke.Thickness = 1
PresetStroke.Parent = PresetFrame

local PresetLabel = Instance.new("TextLabel")
PresetLabel.Size = UDim2.new(0, 100, 0, 38)
PresetLabel.Position = UDim2.new(0, 12, 0, 0)
PresetLabel.BackgroundTransparency = 1
PresetLabel.Text = "> SPEED:"
PresetLabel.TextColor3 = Colors.Text
PresetLabel.TextSize = 12
PresetLabel.Font = Enum.Font.Code
PresetLabel.TextXAlignment = Enum.TextXAlignment.Left
PresetLabel.ZIndex = 13
PresetLabel.Parent = PresetFrame

for i, preset in ipairs(SpeedPresets) do
    local PresetBtn = Instance.new("TextButton")
    PresetBtn.Size = UDim2.new(0, 50, 0, 24)
    PresetBtn.Position = UDim2.new(0, 80 + (i * 55), 0, 7)
    PresetBtn.BackgroundColor3 = Colors.PanelHover
    PresetBtn.Text = preset
    PresetBtn.TextColor3 = Colors.TextDim
    PresetBtn.TextSize = 10
    PresetBtn.Font = Enum.Font.Code
    PresetBtn.AutoButtonColor = false
    PresetBtn.ZIndex = 13
    PresetBtn.Parent = PresetFrame

    local PresetBtnStroke = Instance.new("UIStroke")
    PresetBtnStroke.Color = Colors.Border
    PresetBtnStroke.Thickness = 1
    PresetBtnStroke.Parent = PresetBtn

    PresetBtn.MouseButton1Click:Connect(function()
        Config.SpeedValue = SpeedValues[i]
        Notify("SPEED", "Set to " .. preset)
    end)

    PresetBtn.MouseEnter:Connect(function()
        TweenService:Create(PresetBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    end)

    PresetBtn.MouseLeave:Connect(function()
        TweenService:Create(PresetBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.PanelHover}):Play()
    end)
end

-- ============================================================
-- MISC TAB CONTENT
-- ============================================================
CreateSection(MiscContent, "Farming")
CreateToggle(MiscContent, "Auto Farm Wins", "AutoFarm", StartAutoFarm, StopAutoFarm)
CreateToggle(MiscContent, "Auto Rebirth", "AutoRebirth", StartAutoRebirth, StopAutoRebirth)

CreateSection(MiscContent, "Pets")
CreateToggle(MiscContent, "Auto Hatch Eggs", "AutoHatch", StartAutoHatch, StopAutoHatch)
CreateToggle(MiscContent, "Auto Equip Best", "AutoEquipBestPets", StartAutoEquip, StopAutoEquip)

CreateSection(MiscContent, "Actions")
CreateActionButton(MiscContent, "Redeem All Codes", RedeemAllCodes, Colors.Text)
CreateActionButton(MiscContent, "Teleport Best World", TeleportToBestWorld, Colors.Text)

CreateSection(MiscContent, "Movement")
CreateToggle(MiscContent, "Speed Mods (Walk/Jump)", "AntiFall", StartSpeedMods, function()
    if SpeedModConnection then SpeedModConnection:Disconnect() end
end)

-- ============================================================
-- PROFILE TAB CONTENT
-- ============================================================
CreateSection(ProfileContent, "Player Stats")

local WinsLine, WinsValue = CreateInfoLine(ProfileContent, "WINS", "0")
local RebirthLine, RebirthValue = CreateInfoLine(ProfileContent, "REBIRTHS", "0")
local SpeedLine, SpeedValue = CreateInfoLine(ProfileContent, "SPEED", "0")
local WorldLine, WorldValue = CreateInfoLine(ProfileContent, "WORLD", "1")

CreateSection(ProfileContent, "System Info")
CreateInfoLine(ProfileContent, "EXECUTOR", identifyexecutor and identifyexecutor() or "UNKNOWN")
CreateInfoLine(ProfileContent, "VERSION", "v4.0")
CreateInfoLine(ProfileContent, "DEVELOPER", "@XyrooXellz")

-- Update stats loop
spawn(function()
    while task.wait(1) do
        UpdateGameState()
        pcall(function()
            WinsValue.Text = tostring(GameState.Wins)
            RebirthValue.Text = tostring(GameState.Rebirths)
            SpeedValue.Text = tostring(GameState.Speed)
            WorldValue.Text = tostring(GameState.CurrentWorld)
        end)
    end
end)

-- ============================================================
-- BOTTOM BAR
-- ============================================================
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 24)
BottomBar.Position = UDim2.new(0, 0, 1, -24)
BottomBar.BackgroundColor3 = Colors.Panel
BottomBar.BorderSizePixel = 0
BottomBar.ZIndex = 11
BottomBar.Parent = MainFrame

local BottomStroke = Instance.new("UIStroke")
BottomStroke.Color = Colors.Border
BottomStroke.Thickness = 1
BottomStroke.Parent = BottomBar

local BottomText = Instance.new("TextLabel")
BottomText.Size = UDim2.new(1, 0, 1, 0)
BottomText.BackgroundTransparency = 1
BottomText.Text = "[RIGHT_CTRL] TOGGLE | [X] CLOSE | [−] MINIMIZE | v4.0"
BottomText.TextColor3 = Colors.TextDim
BottomText.TextSize = 9
BottomText.Font = Enum.Font.Code
BottomText.ZIndex = 12
BottomText.Parent = BottomBar

-- ============================================================
-- ANIMATIONS & CONTROLS
-- ============================================================
-- Entry
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Visible = false

spawn(function()
    PlayBootSequence()

    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 420, 0, 540),
        Position = UDim2.new(0.5, -210, 0.5, -270)
    }):Play()

    TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 8}):Play()
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()

    task.wait(0.3)
    ScreenGui:Destroy()
    Blur:Destroy()

    StopRaceEngine()
    StopAutoFarm()
    StopAutoRebirth()
    StopAutoHatch()
    StopAutoEquip()
    CleanupSpeedHack()
    if SpeedModConnection then SpeedModConnection:Disconnect() end
end)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _, content in pairs(TabContents) do
            content.Visible = false
        end
        TabBar.Visible = false
        BottomBar.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 420, 0, 36)}):Play()
    else
        TabBar.Visible = true
        BottomBar.Visible = true
        TabContents[CurrentTab].Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 420, 0, 540)}):Play()
    end
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 8}):Play()
        else
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
        end
    end
end)

-- Hover effects for title bar buttons
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 30, 30)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Panel}):Play()
end)

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.PanelHover}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Panel}):Play()
end)

-- ============================================================
-- INIT
-- ============================================================
StartSpeedMods()

Notify("XYROOXELLZ", "Race Clicker v4.0 loaded | Press RightCtrl")

print("[XYROOXELLZ] Race Clicker Cheat v4.0")
print("[XYROOXELLZ] Terminal Style: Micro Black & White")
print("[XYROOXELLZ] Developer: @XyrooXellz")
print("[XYROOXELLZ] Press Right Ctrl to toggle")
