-- ============================================================
-- RACE CLICKER - ULTIMATE CHEAT v3.0
-- Developer: @XyrooXellz
-- Game: Race Clicker (by 48h Games) | ID: 9285238704
-- Executor: Synapse X / KRNL / Fluxus / Script-Ware / Delta / Hydrogen
-- ============================================================
-- FITUR:
-- 1. Auto Clicker (Auto Stop saat race mulai)
-- 2. Speed Hack (Max 999B)
-- 3. Auto Race (Auto masuk race + auto finish)
-- 4. Auto Farm Wins
-- 5. Auto Rebirth
-- 6. Auto Hatch Eggs
-- 7. Auto Equip Best Pets
-- 8. Auto Redeem Codes
-- 9. Anti-Fall / Auto Steer
-- 10. Teleport to Best World
-- 11. WalkSpeed & JumpPower
-- 12. Modern UI @XyrooXellz Style
-- 13. Progress Loading Animation
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

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- KONFIGURASI
-- ============================================================
local Config = {
    AutoClick = false,
    ClickSpeed = 0.001,
    AutoRace = false,
    SpeedHack = false,
    SpeedValue = 999000000000, -- 999B
    AutoFarm = false,
    AutoRebirth = false,
    AutoHatch = false,
    AutoEquipBestPets = false,
    AutoRedeemCodes = false,
    AntiFall = false,
    WalkSpeed = 100,
    JumpPower = 150,
    AutoSteer = false,
    TeleportToBestWorld = false,
}

-- ============================================================
-- DETEKSI GAME STATE (Race Phase vs Click Phase)
-- ============================================================
local GameState = {
    IsRaceActive = false,
    IsClickPhase = false,
    Countdown = 0,
    CurrentWorld = 1,
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

-- Backup: Cari di workspace juga
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

-- Deteksi Game State dari UI
local function UpdateGameState()
    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            local text = v.Text:lower()
            if text:find("race starting") or text:find("get ready") or text:find("click!") then
                GameState.IsClickPhase = true
                GameState.IsRaceActive = false
            elseif text:find("race in progress") or text:find("racing") then
                GameState.IsClickPhase = false
                GameState.IsRaceActive = true
            elseif text:find("finished") or text:find("results") then
                GameState.IsClickPhase = false
                GameState.IsRaceActive = false
            end

            -- Deteksi countdown
            local num = text:match("(%d+)")
            if num then
                GameState.Countdown = tonumber(num)
            end
        end
    end
end

-- ============================================================
-- UTILITY FUNCTIONS
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
-- SPEED HACK (999B)
-- ============================================================
-- Cara 1: Modify Humanoid WalkSpeed
-- Cara 2: Modify Velocity langsung
-- Cara 3: Fire Remote dengan speed value tinggi
-- Cara 4: Modify BodyVelocity
-- Cara 5: CFrame teleport forward
-- Cara 6: Modify game values (Wins/Speed stats)

local SpeedConnections = {}

local function ApplySpeedHack()
    if not Config.SpeedHack then return end

    local hrp = GetHRP()
    local humanoid = GetHumanoid()

    -- Cara 1: WalkSpeed
    humanoid.WalkSpeed = 999

    -- Cara 2: Velocity manipulation
    pcall(function()
        hrp.Velocity = hrp.CFrame.LookVector * Config.SpeedValue
    end)

    -- Cara 3: Fire remote dengan speed tinggi
    if Remotes.Click then
        pcall(function()
            Remotes.Click:FireServer(Config.SpeedValue)
        end)
    end

    -- Cara 4: BodyVelocity
    pcall(function()
        local bv = hrp:FindFirstChild("SpeedHackBV") or Instance.new("BodyVelocity")
        bv.Name = "SpeedHackBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = hrp.CFrame.LookVector * Config.SpeedValue
        bv.Parent = hrp
    end)

    -- Cara 5: CFrame teleport forward (instant movement)
    pcall(function()
        if GameState.IsRaceActive then
            hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 50)
        end
    end)

    -- Cara 6: Modify player stats
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

local function StartSpeedHack()
    if SpeedConnections.Hack then return end

    Notify("Race Clicker", "Speed Hack 999B ACTIVATED! 🔥")

    SpeedConnections.Hack = RunService.Heartbeat:Connect(function()
        ApplySpeedHack()
    end)
end

local function StopSpeedHack()
    if SpeedConnections.Hack then
        SpeedConnections.Hack:Disconnect()
        SpeedConnections.Hack = nil
    end

    -- Cleanup BodyVelocity
    pcall(function()
        local hrp = GetHRP()
        local bv = hrp:FindFirstChild("SpeedHackBV")
        if bv then bv:Destroy() end
    end)

    -- Reset WalkSpeed
    pcall(function()
        GetHumanoid().WalkSpeed = 16
    end)
end

-- ============================================================
-- AUTO CLICKER (Auto Stop saat race mulai)
-- ============================================================
local ClickConnection
local function StartAutoClick()
    if ClickConnection then return end

    Notify("Race Clicker", "Auto Clicker ACTIVATED! (Auto-stop saat race)")

    ClickConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoClick then return end

        -- Update game state
        UpdateGameState()

        -- AUTO STOP saat race mulai
        if GameState.IsRaceActive then
            return -- Stop clicking, race udah mulai
        end

        -- Hanya click saat click phase
        if GameState.IsClickPhase or GameState.Countdown > 0 then
            -- Method 1: Fire Remote
            if Remotes.Click then
                pcall(function()
                    Remotes.Click:FireServer()
                end)
            end

            -- Method 2: Simulate Mouse Click
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(Config.ClickSpeed)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)

            -- Method 3: Fire ClickDetector
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    pcall(function()
                        fireclickdetector(v)
                    end)
                end
            end

            -- Method 4: Fire ProximityPrompt
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(v)
                    end)
                end
            end
        end
    end)
end

local function StopAutoClick()
    if ClickConnection then
        ClickConnection:Disconnect()
        ClickConnection = nil
    end
end

-- ============================================================
-- AUTO RACE (Auto masuk race + auto finish)
-- ============================================================
local RaceConnection
local function StartAutoRace()
    if RaceConnection then return end

    Notify("Race Clicker", "Auto Race ACTIVATED! 🏁")

    RaceConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoRace then return end

        UpdateGameState()
        local hrp = GetHRP()
        local humanoid = GetHumanoid()

        -- Phase 1: Click Phase - Auto click maksimal
        if GameState.IsClickPhase then
            -- Click secepat mungkin
            for i = 1, 10 do
                if Remotes.Click then
                    pcall(function()
                        Remotes.Click:FireServer()
                    end)
                end
            end
        end

        -- Phase 2: Race Phase - Auto run + speed hack
        if GameState.IsRaceActive then
            -- Speed hack aktif
            ApplySpeedHack()

            -- Auto run forward
            humanoid:Move(Vector3.new(0, 0, -1))

            -- Teleport ke finish line
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("finish") or v.Name:lower():find("end") or v.Name:lower():find("goal") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        pcall(function()
                            hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                        end)
                        break
                    end
                end
            end

            -- Cari checkpoint dan teleport
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("checkpoint") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        pcall(function()
                            hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        end)
                    end
                end
            end
        end

        -- Phase 3: Results Phase - Auto restart
        if not GameState.IsRaceActive and not GameState.IsClickPhase then
            -- Cari tombol restart/next race
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local name = v.Name:lower()
                    if name:find("race") or name:find("start") or name:find("next") or name:find("play") then
                        pcall(function()
                            v.MouseButton1Click:Fire()
                        end)
                    end
                end
            end

            -- Fire race remote
            if Remotes.Race then
                pcall(function()
                    Remotes.Race:FireServer("Start")
                end)
            end
        end
    end)
end

local function StopAutoRace()
    if RaceConnection then
        RaceConnection:Disconnect()
        RaceConnection = nil
    end
end

-- ============================================================
-- AUTO FARM WINS
-- ============================================================
local FarmConnection
local function StartAutoFarm()
    if FarmConnection then return end

    Notify("Race Clicker", "Auto Farm ACTIVATED!")

    FarmConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end

        local hrp = GetHRP()
        local humanoid = GetHumanoid()

        UpdateGameState()

        -- Click phase: click maksimal
        if GameState.IsClickPhase then
            for i = 1, 5 do
                if Remotes.Click then
                    pcall(function()
                        Remotes.Click:FireServer()
                    end)
                end
            end
        end

        -- Race phase: auto run + teleport
        if GameState.IsRaceActive then
            ApplySpeedHack()
            humanoid:Move(Vector3.new(0, 0, -1))

            -- Teleport ke finish
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("finish") or v.Name:lower():find("end") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        pcall(function()
                            hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                        end)
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

-- ============================================================
-- AUTO REBIRTH
-- ============================================================
local RebirthConnection
local function StartAutoRebirth()
    if RebirthConnection then return end

    Notify("Race Clicker", "Auto Rebirth ACTIVATED!")

    RebirthConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoRebirth then return end

        if Remotes.Rebirth then
            pcall(function()
                Remotes.Rebirth:FireServer()
            end)
        else
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local name = v.Name:lower()
                    if name:find("rebirth") then
                        pcall(function()
                            v.MouseButton1Click:Fire()
                        end)
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

-- ============================================================
-- AUTO HATCH EGGS
-- ============================================================
local HatchConnection
local function StartAutoHatch()
    if HatchConnection then return end

    Notify("Race Clicker", "Auto Hatch ACTIVATED!")

    HatchConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoHatch then return end

        if Remotes.Hatch then
            pcall(function()
                Remotes.Hatch:FireServer("BestEgg")
            end)
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

-- ============================================================
-- AUTO EQUIP BEST PETS
-- ============================================================
local EquipConnection
local function StartAutoEquip()
    if EquipConnection then return end

    Notify("Race Clicker", "Auto Equip Best Pets ACTIVATED!")

    EquipConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoEquipBestPets then return end

        if Remotes.EquipPet then
            pcall(function()
                Remotes.EquipPet:FireServer("BestPets")
            end)
        else
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local name = v.Name:lower()
                    if name:find("equip") and name:find("pet") then
                        pcall(function()
                            v.MouseButton1Click:Fire()
                        end)
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

-- ============================================================
-- AUTO REDEEM CODES
-- ============================================================
local Codes = {
    "Easter!", "Fantasy", "Season14", "NewPotion", "Ninja",
    "RaceTrack", "67", "Christmas", "XMAS", "Winter",
    "REVERT", "800m", "Halloween", "Toy", "Fall",
}

local function RedeemAllCodes()
    Notify("Race Clicker", "Redeeming all codes...")

    for _, code in pairs(Codes) do
        if Remotes.RedeemCode then
            pcall(function()
                Remotes.RedeemCode:FireServer(code)
            end)
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

    Notify("Race Clicker", "All codes redeemed! ✅")
end

-- ============================================================
-- ANTI FALL / AUTO STEER
-- ============================================================
local AntiFallConnection
local function StartAntiFall()
    if AntiFallConnection then return end

    Notify("Race Clicker", "Anti-Fall ACTIVATED!")

    AntiFallConnection = RunService.Heartbeat:Connect(function()
        if not Config.AntiFall then return end

        local hrp = GetHRP()
        local humanoid = GetHumanoid()

        -- Anti fall
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

        -- Auto steer
        if Config.AutoSteer then
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

local function StopAntiFall()
    if AntiFallConnection then
        AntiFallConnection:Disconnect()
        AntiFallConnection = nil
    end
end

-- ============================================================
-- WALKSPEED & JUMPPOWER
-- ============================================================
local function ApplySpeedMods()
    local humanoid = GetHumanoid()
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
end

local SpeedModConnection
local function StartSpeedMods()
    SpeedModConnection = RunService.Heartbeat:Connect(function()
        ApplySpeedMods()
    end)
end

-- ============================================================
-- TELEPORT TO BEST WORLD
-- ============================================================
local function TeleportToBestWorld()
    Notify("Race Clicker", "Teleporting...")

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
            local hrp = GetHRP()
            hrp.CFrame = bestWorld.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

-- ============================================================
-- MODERN UI @XYROOXELLZ STYLE
-- ============================================================

-- Destroy existing GUI
if game.CoreGui:FindFirstChild("XyrooXellzRaceClicker") then
    game.CoreGui:FindFirstChild("XyrooXellzRaceClicker"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyrooXellzRaceClicker"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Blur Background
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

-- Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LoadingFrame.BackgroundTransparency = 0
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 0)
LoadingCorner.Parent = LoadingFrame

-- Loading Title
local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(0, 400, 0, 50)
LoadingTitle.Position = UDim2.new(0.5, -200, 0.4, 0)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "🏁 RACE CLICKER"
LoadingTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
LoadingTitle.TextSize = 36
LoadingTitle.Font = Enum.Font.GothamBlack
LoadingTitle.ZIndex = 101
LoadingTitle.Parent = LoadingFrame

-- Developer Credit
local DevCredit = Instance.new("TextLabel")
DevCredit.Size = UDim2.new(0, 400, 0, 30)
DevCredit.Position = UDim2.new(0.5, -200, 0.45, 0)
DevCredit.BackgroundTransparency = 1
DevCredit.Text = "@XyrooXellz | Ultimate Cheat v3.0"
DevCredit.TextColor3 = Color3.fromRGB(150, 150, 150)
DevCredit.TextSize = 14
DevCredit.Font = Enum.Font.GothamSemibold
DevCredit.ZIndex = 101
DevCredit.Parent = LoadingFrame

-- Progress Bar Background
local ProgressBg = Instance.new("Frame")
ProgressBg.Name = "ProgressBg"
ProgressBg.Size = UDim2.new(0, 300, 0, 8)
ProgressBg.Position = UDim2.new(0.5, -150, 0.52, 0)
ProgressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProgressBg.BorderSizePixel = 0
ProgressBg.ZIndex = 101
ProgressBg.Parent = LoadingFrame

local ProgressBgCorner = Instance.new("UICorner")
ProgressBgCorner.CornerRadius = UDim.new(0, 4)
ProgressBgCorner.Parent = ProgressBg

-- Progress Bar Fill
local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "ProgressFill"
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 102
ProgressFill.Parent = ProgressBg

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(0, 4)
ProgressFillCorner.Parent = ProgressFill

-- Progress Text
local ProgressText = Instance.new("TextLabel")
ProgressText.Size = UDim2.new(0, 300, 0, 25)
ProgressText.Position = UDim2.new(0.5, -150, 0.55, 0)
ProgressText.BackgroundTransparency = 1
ProgressText.Text = "0%"
ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
ProgressText.TextSize = 14
ProgressText.Font = Enum.Font.GothamBold
ProgressText.ZIndex = 101
ProgressText.Parent = LoadingFrame

-- Loading Animation
local loadingSteps = {
    "Detecting game...",
    "Finding remotes...",
    "Loading modules...",
    "Building UI...",
    "Initializing hacks...",
    "Ready!"
}

local function PlayLoadingAnimation()
    for i, step in ipairs(loadingSteps) do
        local progress = (i / #loadingSteps)

        -- Animate progress bar
        TweenService:Create(ProgressFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(progress, 0, 1, 0)
        }):Play()

        ProgressText.Text = math.floor(progress * 100) .. "% - " .. step

        task.wait(0.6)
    end

    -- Fade out loading
    TweenService:Create(LoadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(LoadingTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(DevCredit, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()

    task.wait(1)
    LoadingFrame:Destroy()
end

-- ============================================================
-- MAIN UI FRAME
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

-- Main Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Glow Effect
local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.Position = UDim2.new(0, -20, 0, -20)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://4996891970"
Glow.ImageColor3 = Color3.fromRGB(255, 215, 0)
Glow.ImageTransparency = 0.9
Glow.ZIndex = 9
Glow.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 11
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 16)
TopBarCorner.Parent = TopBar

-- Bottom fix for top bar
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 20)
TopBarFix.Position = UDim2.new(0, 0, 0, 30)
TopBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TopBarFix.BorderSizePixel = 0
TopBarFix.ZIndex = 11
TopBarFix.Parent = TopBar

-- Title Icon
local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 40, 0, 40)
TitleIcon.Position = UDim2.new(0, 10, 0, 5)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🏁"
TitleIcon.TextSize = 24
TitleIcon.ZIndex = 12
TitleIcon.Parent = TopBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 25)
TitleText.Position = UDim2.new(0, 50, 0, 5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "RACE CLICKER"
TitleText.TextColor3 = Color3.fromRGB(255, 215, 0)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 12
TitleText.Parent = TopBar

-- Subtitle
local SubtitleText = Instance.new("TextLabel")
SubtitleText.Size = UDim2.new(0, 200, 0, 18)
SubtitleText.Position = UDim2.new(0, 50, 0, 28)
SubtitleText.BackgroundTransparency = 1
SubtitleText.Text = "@XyrooXellz | v3.0"
SubtitleText.TextColor3 = Color3.fromRGB(120, 120, 140)
SubtitleText.TextSize = 11
SubtitleText.Font = Enum.Font.GothamSemibold
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.ZIndex = 12
SubtitleText.Parent = TopBar

-- Status Indicator
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -60, 0, 21)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 12
StatusDot.Parent = TopBar

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 50, 0, 20)
StatusLabel.Position = UDim2.new(1, -50, 0, 15)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ONLINE"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.ZIndex = 12
StatusLabel.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 12
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

local CloseIcon = Instance.new("TextLabel")
CloseIcon.Size = UDim2.new(1, 0, 1, 0)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "✕"
CloseIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseIcon.TextSize = 16
CloseIcon.Font = Enum.Font.GothamBold
CloseIcon.ZIndex = 13
CloseIcon.Parent = CloseBtn

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -75, 0, 9)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.Text = ""
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 12
MinBtn.Parent = TopBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinBtn

local MinIcon = Instance.new("TextLabel")
MinIcon.Size = UDim2.new(1, 0, 1, 0)
MinIcon.BackgroundTransparency = 1
MinIcon.Text = "−"
MinIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
MinIcon.TextSize = 20
MinIcon.Font = Enum.Font.GothamBold
MinIcon.ZIndex = 13
MinIcon.Parent = MinBtn

-- ============================================================
-- CONTENT AREA
-- ============================================================
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -110)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ContentFrame.ZIndex = 11
ContentFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentFrame

-- ============================================================
-- CATEGORY HEADERS
-- ============================================================
local function CreateCategory(text)
    local Category = Instance.new("TextLabel")
    Category.Size = UDim2.new(1, -10, 0, 25)
    Category.BackgroundTransparency = 1
    Category.Text = "▸ " .. text
    Category.TextColor3 = Color3.fromRGB(255, 215, 0)
    Category.TextSize = 13
    Category.Font = Enum.Font.GothamBold
    Category.TextXAlignment = Enum.TextXAlignment.Left
    Category.ZIndex = 12
    Category.Parent = ContentFrame
    return Category
end

-- ============================================================
-- MODERN TOGGLE BUTTON
-- ============================================================
local function CreateToggle(name, configKey, startFunc, stopFunc, icon)
    icon = icon or "⚡"

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 12
    ToggleFrame.Parent = ContentFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame

    -- Icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 30, 0, 30)
    IconLabel.Position = UDim2.new(0, 10, 0, 7)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextSize = 18
    IconLabel.ZIndex = 13
    IconLabel.Parent = ToggleFrame

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 200, 0, 20)
    NameLabel.Position = UDim2.new(0, 45, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 13
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.ZIndex = 13
    NameLabel.Parent = ToggleFrame

    -- Status
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0, 200, 0, 15)
    StatusText.Position = UDim2.new(0, 45, 0, 24)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "OFF"
    StatusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusText.TextSize = 10
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.ZIndex = 13
    StatusText.Parent = ToggleFrame

    -- Toggle Switch
    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 44, 0, 24)
    SwitchBg.Position = UDim2.new(1, -54, 0, 10)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    SwitchBg.BorderSizePixel = 0
    SwitchBg.ZIndex = 13
    SwitchBg.Parent = ToggleFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg

    local SwitchKnob = Instance.new("Frame")
    SwitchKnob.Size = UDim2.new(0, 20, 0, 20)
    SwitchKnob.Position = UDim2.new(0, 2, 0, 2)
    SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchKnob.BorderSizePixel = 0
    SwitchKnob.ZIndex = 14
    SwitchKnob.Parent = SwitchBg

    local SwitchKnobCorner = Instance.new("UICorner")
    SwitchKnobCorner.CornerRadius = UDim.new(1, 0)
    SwitchKnobCorner.Parent = SwitchKnob

    -- Click Area
    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.ZIndex = 15
    ClickArea.Parent = ToggleFrame

    ClickArea.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]

        if Config[configKey] then
            -- ON Animation
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            }):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 22, 0, 2)
            }):Play()
            StatusText.Text = "ON"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 100)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)

            if startFunc then startFunc() end
        else
            -- OFF Animation
            TweenService:Create(SwitchBg, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            }):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
            StatusText.Text = "OFF"
            StatusText.TextColor3 = Color3.fromRGB(150, 150, 150)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)

            if stopFunc then stopFunc() end
        end
    end)

    -- Hover effect
    ToggleFrame.MouseEnter:Connect(function()
        if not Config[configKey] then
            TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            }):Play()
        end
    end)

    ToggleFrame.MouseLeave:Connect(function()
        if not Config[configKey] then
            TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            }):Play()
        end
    end)

    return ToggleFrame
end

-- ============================================================
-- MODERN ACTION BUTTON
-- ============================================================
local function CreateActionButton(name, callback, icon, color)
    icon = icon or "🚀"
    color = color or Color3.fromRGB(100, 50, 200)

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -10, 0, 45)
    ButtonFrame.BackgroundColor3 = color
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.ZIndex = 12
    ButtonFrame.Parent = ContentFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = ButtonFrame

    -- Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.min(color.R * 255 + 30, 255),
            math.min(color.G * 255 + 30, 255),
            math.min(color.B * 255 + 30, 255)
        ))
    })
    Gradient.Parent = ButtonFrame

    -- Icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 30, 0, 30)
    IconLabel.Position = UDim2.new(0, 10, 0, 7)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextSize = 18
    IconLabel.ZIndex = 13
    IconLabel.Parent = ButtonFrame

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 200, 0, 20)
    NameLabel.Position = UDim2.new(0, 45, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 13
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.ZIndex = 13
    NameLabel.Parent = ButtonFrame

    -- Subtitle
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 0, 15)
    SubLabel.Position = UDim2.new(0, 45, 0, 24)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Click to execute"
    SubLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    SubLabel.TextSize = 10
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.ZIndex = 13
    SubLabel.Parent = ButtonFrame

    -- Click Area
    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.ZIndex = 15
    ClickArea.Parent = ButtonFrame

    ClickArea.MouseButton1Click:Connect(function()
        -- Click animation
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
            Size = UDim2.new(0.98, -10, 0, 43)
        }):Play()
        task.wait(0.1)
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -10, 0, 45)
        }):Play()

        callback()
    end)

    -- Hover effect
    ButtonFrame.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 20, 255),
                math.min(color.G * 255 + 20, 255),
                math.min(color.B * 255 + 20, 255)
            )
        }):Play()
    end)

    ButtonFrame.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = color
        }):Play()
    end)

    return ButtonFrame
end

-- ============================================================
-- SPEED HACK SLIDER
-- ============================================================
local function CreateSpeedSlider()
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.ZIndex = 12
    SliderFrame.Parent = ContentFrame

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = SliderFrame

    -- Icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 30, 0, 30)
    IconLabel.Position = UDim2.new(0, 10, 0, 5)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "💨"
    IconLabel.TextSize = 18
    IconLabel.ZIndex = 13
    IconLabel.Parent = SliderFrame

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 150, 0, 20)
    NameLabel.Position = UDim2.new(0, 45, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = "Speed Value"
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 13
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.ZIndex = 13
    NameLabel.Parent = SliderFrame

    -- Value Display
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 100, 0, 20)
    ValueLabel.Position = UDim2.new(1, -110, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = "999B"
    ValueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = 13
    ValueLabel.Parent = SliderFrame

    -- Slider Background
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 8)
    SliderBg.Position = UDim2.new(0, 10, 0, 38)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SliderBg.BorderSizePixel = 0
    SliderBg.ZIndex = 13
    SliderBg.Parent = SliderFrame

    local SliderBgCorner = Instance.new("UICorner")
    SliderBgCorner.CornerRadius = UDim.new(0, 4)
    SliderBgCorner.Parent = SliderBg

    -- Slider Fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(1, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    SliderFill.BorderSizePixel = 0
    SliderFill.ZIndex = 14
    SliderFill.Parent = SliderBg

    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 4)
    SliderFillCorner.Parent = SliderFill

    -- Slider Knob
    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.Position = UDim2.new(1, -8, 0, -4)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnob.BorderSizePixel = 0
    SliderKnob.ZIndex = 15
    SliderKnob.Parent = SliderBg

    local SliderKnobCorner = Instance.new("UICorner")
    SliderKnobCorner.CornerRadius = UDim.new(1, 0)
    SliderKnobCorner.Parent = SliderKnob

    -- Preset Buttons
    local PresetsFrame = Instance.new("Frame")
    PresetsFrame.Size = UDim2.new(1, -20, 0, 20)
    PresetsFrame.Position = UDim2.new(0, 10, 0, 50)
    PresetsFrame.BackgroundTransparency = 1
    PresetsFrame.ZIndex = 13
    PresetsFrame.Parent = SliderFrame

    local PresetsLayout = Instance.new("UIListLayout")
    PresetsLayout.FillDirection = Enum.FillDirection.Horizontal
    PresetsLayout.Padding = UDim.new(0, 5)
    PresetsLayout.Parent = PresetsFrame

    local presets = {
        {name = "1M", value = 1000000},
        {name = "1B", value = 1000000000},
        {name = "999B", value = 999000000000},
    }

    for _, preset in pairs(presets) do
        local PresetBtn = Instance.new("TextButton")
        PresetBtn.Size = UDim2.new(0, 50, 0, 18)
        PresetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        PresetBtn.Text = preset.name
        PresetBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        PresetBtn.TextSize = 10
        PresetBtn.Font = Enum.Font.GothamBold
        PresetBtn.ZIndex = 14
        PresetBtn.Parent = PresetsFrame

        local PresetCorner = Instance.new("UICorner")
        PresetCorner.CornerRadius = UDim.new(0, 4)
        PresetCorner.Parent = PresetBtn

        PresetBtn.MouseButton1Click:Connect(function()
            Config.SpeedValue = preset.value
            ValueLabel.Text = preset.name
            TweenService:Create(SliderFill, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()
        end)
    end

    return SliderFrame
end

-- ============================================================
-- BUILD UI
-- ============================================================
CreateCategory("CORE HACKS")
CreateToggle("Auto Clicker", "AutoClick", StartAutoClick, StopAutoClick, "👆")
CreateToggle("Auto Race", "AutoRace", StartAutoRace, StopAutoRace, "🏁")
CreateToggle("Speed Hack (999B)", "SpeedHack", StartSpeedHack, StopSpeedHack, "💨")
CreateSpeedSlider()

CreateCategory("FARMING")
CreateToggle("Auto Farm Wins", "AutoFarm", StartAutoFarm, StopAutoFarm, "💰")
CreateToggle("Auto Rebirth", "AutoRebirth", StartAutoRebirth, StopAutoRebirth, "🔄")

CreateCategory("PETS")
CreateToggle("Auto Hatch Eggs", "AutoHatch", StartAutoHatch, StopAutoHatch, "🥚")
CreateToggle("Auto Equip Best Pets", "AutoEquipBestPets", StartAutoEquip, StopAutoEquip, "🐾")

CreateCategory("UTILITIES")
CreateToggle("Anti-Fall + Steer", "AntiFall", StartAntiFall, StopAntiFall, "🛡️")
CreateToggle("Speed Mods", "AntiFall", function() end, function() end, "⚡")

CreateCategory("ACTIONS")
CreateActionButton("Redeem All Codes", RedeemAllCodes, "🎫", Color3.fromRGB(100, 50, 200))
CreateActionButton("Teleport Best World", TeleportToBestWorld, "🌍", Color3.fromRGB(50, 100, 200))

-- ============================================================
-- BOTTOM INFO
-- ============================================================
local BottomFrame = Instance.new("Frame")
BottomFrame.Size = UDim2.new(1, -20, 0, 30)
BottomFrame.Position = UDim2.new(0, 10, 1, -35)
BottomFrame.BackgroundTransparency = 1
BottomFrame.ZIndex = 11
BottomFrame.Parent = MainFrame

local BottomText = Instance.new("TextLabel")
BottomText.Size = UDim2.new(1, 0, 1, 0)
BottomText.BackgroundTransparency = 1
BottomText.Text = "Race Clicker Cheat v3.0 | @XyrooXellz | Press RightCtrl to toggle"
BottomText.TextColor3 = Color3.fromRGB(100, 100, 120)
BottomText.TextSize = 10
BottomText.Font = Enum.Font.Gotham
BottomText.ZIndex = 12
BottomText.Parent = BottomFrame

-- ============================================================
-- ANIMATIONS
-- ============================================================
-- Entry animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Visible = false

-- Play loading then show main
spawn(function()
    PlayLoadingAnimation()

    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 520),
        Position = UDim2.new(0.5, -190, 0.5, -260)
    }):Play()

    TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 10}):Play()
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()

    TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()

    task.wait(0.3)
    ScreenGui:Destroy()
    Blur:Destroy()

    -- Cleanup
    StopAutoClick()
    StopAutoRace()
    StopSpeedHack()
    StopAutoFarm()
    StopAutoRebirth()
    StopAutoHatch()
    StopAutoEquip()
    StopAntiFall()
    if SpeedModConnection then SpeedModConnection:Disconnect() end
end)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(ContentFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, 0)}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 60)}):Play()
        MinIcon.Text = "+"
    else
        TweenService:Create(ContentFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 1, -110)}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 520)}):Play()
        MinIcon.Text = "−"
    end
end)

-- Keybind toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 10}):Play()
        else
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
        end
    end
end)

-- ============================================================
-- AUTO INIT
-- ============================================================
StartSpeedMods()

Notify("🏁 Race Clicker Cheat", "v3.0 by @XyrooXellz loaded! Press RightCtrl to toggle UI")

print("[Race Clicker Cheat v3.0] Loaded successfully!")
print("[Race Clicker Cheat v3.0] Developer: @XyrooXellz")
print("[Race Clicker Cheat v3.0] Press Right Ctrl to toggle GUI")
