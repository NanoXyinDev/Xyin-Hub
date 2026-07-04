-- ============================================================
-- RACE CLICKER - ULTIMATE CHEAT SCRIPT
-- Game: Race Clicker (by 48h Games)
-- Game ID: 9285238704
-- Executor: Synapse X / KRNL / Fluxus / Script-Ware / etc
-- ============================================================
-- Fitur:
-- 1. Auto Click (Speed Hack)
-- 2. Auto Farm Wins
-- 3. Auto Rebirth
-- 4. Auto Hatch Eggs
-- 5. Auto Equip Best Pets
-- 6. Auto Redeem Codes
-- 7. Teleport to Best World
-- 8. Anti-Fall / Auto Steer
-- 9. GUI Interface
-- 10. WalkSpeed & JumpPower
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- KONFIGURASI
-- ============================================================
local Config = {
    AutoClick = false,
    ClickSpeed = 0.001, -- Semakin kecil semakin cepat
    AutoFarm = false,
    AutoRebirth = false,
    AutoHatch = false,
    AutoEquipBestPets = false,
    AutoRedeemCodes = false,
    AntiFall = false,
    WalkSpeed = 50,
    JumpPower = 100,
    AutoSteer = false,
    TeleportToBestWorld = false,
    InfiniteWins = false,
    GodMode = false,
}

-- ============================================================
-- REMOTE EVENTS & FUNCTIONS (Dari Analisis Game)
-- ============================================================
-- Berdasarkan analisis game Race Clicker:
-- - Game pakai sistem click untuk build speed
-- - Ada countdown 30 detik sebelum race
-- - Speed ditentukan dari total click + multiplier pet + rebirth
-- - Wins didapat dari jarak tempuh di track
-- - Rebirth reset strength tapi kasih permanent multiplier
-- - Pets dari eggs, ada rarity system
-- - 6 Worlds total
-- - Codes bisa redeem untuk boost

-- Cari Remote Events
local Remotes = {}
local function FindRemotes()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("click") or name:find("tap") then
                Remotes.Click = v
            elseif name:find("rebirth") then
                Remotes.Rebirth = v
            elseif name:find("hatch") or name:find("egg") then
                Remotes.Hatch = v
            elseif name:find("equip") or name:find("pet") then
                Remotes.EquipPet = v
            elseif name:find("code") or name:find("redeem") then
                Remotes.RedeemCode = v
            elseif name:find("win") or name:find("race") then
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

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function Notify(title, text, duration)
    duration = duration or 3
    if syn and syn.toast_notification then
        syn.toast_notification({
            Title = title,
            Content = text,
            Duration = duration
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end
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
-- AUTO CLICKER (SPEED HACK)
-- ============================================================
local ClickConnection
local function StartAutoClick()
    if ClickConnection then return end

    Notify("Race Clicker", "Auto Clicker ACTIVATED!")

    ClickConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoClick then return end

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

        -- Method 3: Fire ClickDetector jika ada
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ClickDetector") then
                pcall(function()
                    fireclickdetector(v)
                end)
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

        -- Auto walk forward di track
        if Config.AutoSteer then
            humanoid:Move(Vector3.new(0, 0, -1))
        end

        -- Auto Click selama farming
        if Remotes.Click then
            pcall(function()
                Remotes.Click:FireServer()
            end)
        end

        -- Cari finish line atau checkpoint
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find("finish") or v.Name:lower():find("checkpoint") or v.Name:lower():find("win") then
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    pcall(function()
                        hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                    end)
                end
            end
        end

        task.wait(0.1)
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
            -- Cari tombol rebirth di UI
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
                -- Hatch egg terbaik yang available
                Remotes.Hatch:FireServer("BestEgg") -- Adjust nama egg
            end)
        else
            -- Cari egg di workspace
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("egg") and (v:IsA("BasePart") or v:IsA("MeshPart")) then
                    pcall(function()
                        local hrp = GetHRP()
                        hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        -- Trigger proximity prompt atau click detector
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
                -- Equip pets dengan multiplier tertinggi
                Remotes.EquipPet:FireServer("BestPets")
            end)
        else
            -- Cari UI pets
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
    "Easter!",
    "Fantasy",
    "Season14",
    "NewPotion",
    "Ninja",
    "RaceTrack",
    "67",
    "Christmas",
    "XMAS",
    "Winter",
    "REVERT",
    "800m",
    "Halloween",
    "Toy",
    "Fall",
}

local function RedeemAllCodes()
    Notify("Race Clicker", "Redeeming all active codes...")

    for _, code in pairs(Codes) do
        if Remotes.RedeemCode then
            pcall(function()
                Remotes.RedeemCode:FireServer(code)
            end)
        else
            -- Buka UI codes dan redeem
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextBox") and v.Name:lower():find("code") then
                    pcall(function()
                        v.Text = code
                        -- Cari tombol redeem
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

    Notify("Race Clicker", "All codes redeemed!")
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

        -- Cek jika jatuh (Y position turun drastis)
        if hrp.Position.Y < -50 then
            -- Teleport balik ke track
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower():find("spawn") or v.Name:lower():find("start") then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then
                        hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end

        -- Auto steer ke tengah track
        if Config.AutoSteer then
            -- Cari track path
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

local SpeedConnection
local function StartSpeedMods()
    SpeedConnection = RunService.Heartbeat:Connect(function()
        ApplySpeedMods()
    end)
end

-- ============================================================
-- TELEPORT TO BEST WORLD
-- ============================================================
local function TeleportToBestWorld()
    Notify("Race Clicker", "Teleporting to best available world...")

    if Remotes.Teleport then
        pcall(function()
            -- Coba teleport ke world tertinggi
            for i = 6, 1, -1 do
                Remotes.Teleport:FireServer("World" .. tostring(i))
                task.wait(0.5)
            end
        end)
    else
        -- Cari portal/world teleport di workspace
        local bestWorld = nil
        local highestWorldNum = 0

        for _, v in pairs(workspace:GetDescendants()) do
            local name = v.Name:lower()
            if name:find("world") or name:find("portal") or name:find("teleport") then
                -- Extract world number
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
-- INFINITE WINS (EXPLOIT)
-- ============================================================
local WinsConnection
local function StartInfiniteWins()
    if WinsConnection then return end

    Notify("Race Clicker", "Infinite Wins ACTIVATED! (Experimental)")

    WinsConnection = RunService.Heartbeat:Connect(function()
        if not Config.InfiniteWins then return end

        -- Coba manipulate wins via remote
        if Remotes.Race then
            pcall(function()
                -- Fire race complete dengan wins tinggi
                Remotes.Race:FireServer("Complete", 999999999)
            end)
        end

        -- Cari value wins di player
        for _, v in pairs(LocalPlayer:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("win") or name:find("point") or name:find("score") then
                    pcall(function()
                        v.Value = v.Value + 1000000
                    end)
                end
            end
        end

        task.wait(0.1)
    end)
end

local function StopInfiniteWins()
    if WinsConnection then
        WinsConnection:Disconnect()
        WinsConnection = nil
    end
end

-- ============================================================
-- GOD MODE
-- ============================================================
local GodModeConnection
local function StartGodMode()
    if GodModeConnection then return end

    Notify("Race Clicker", "God Mode ACTIVATED!")

    GodModeConnection = RunService.Heartbeat:Connect(function()
        if not Config.GodMode then return end

        local humanoid = GetHumanoid()
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge

        -- Anti ragdoll / anti stun
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end)
end

local function StopGodMode()
    if GodModeConnection then
        GodModeConnection:Disconnect()
        GodModeConnection = nil
    end
end

-- ============================================================
-- GUI INTERFACE
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RaceClickerCheat"
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "🏁 RACE CLICKER CHEAT"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Scrolling Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -90)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- Function buat toggle button
local function CreateToggle(name, configKey, startFunc, stopFunc)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Button.Text = "❌ " .. name
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = ScrollFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            Button.Text = "✅ " .. name
            Button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            if startFunc then startFunc() end
        else
            Button.Text = "❌ " .. name
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            if stopFunc then stopFunc() end
        end
    end)

    return Button
end

-- Function buat action button
local function CreateActionButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
    Button.Text = "🚀 " .. name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = ScrollFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        callback()
    end)

    return Button
end

-- Toggle Buttons
CreateToggle("Auto Clicker", "AutoClick", StartAutoClick, StopAutoClick)
CreateToggle("Auto Farm Wins", "AutoFarm", StartAutoFarm, StopAutoFarm)
CreateToggle("Auto Rebirth", "AutoRebirth", StartAutoRebirth, StopAutoRebirth)
CreateToggle("Auto Hatch Eggs", "AutoHatch", StartAutoHatch, StopAutoHatch)
CreateToggle("Auto Equip Best Pets", "AutoEquipBestPets", StartAutoEquip, StopAutoEquip)
CreateToggle("Anti Fall + Auto Steer", "AntiFall", StartAntiFall, StopAntiFall)
CreateToggle("Infinite Wins (Exp)", "InfiniteWins", StartInfiniteWins, StopInfiniteWins)
CreateToggle("God Mode", "GodMode", StartGodMode, StopGodMode)

-- Action Buttons
CreateActionButton("Redeem All Codes", RedeemAllCodes)
CreateActionButton("Teleport Best World", TeleportToBestWorld)
CreateActionButton("Apply Speed Mods", ApplySpeedMods)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    -- Matikan semua connection
    StopAutoClick()
    StopAutoFarm()
    StopAutoRebirth()
    StopAutoHatch()
    StopAutoEquip()
    StopAntiFall()
    StopInfiniteWins()
    StopGodMode()
    if SpeedConnection then SpeedConnection:Disconnect() end
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "Minimize"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ScrollFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MinBtn.Text = "+"
    else
        ScrollFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 350, 0, 500)
        MinBtn.Text = "-"
    end
end)

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 30)
InfoLabel.Position = UDim2.new(0, 10, 1, -35)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Race Clicker Cheat v2.0 | By Kyriel"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

-- ============================================================
-- AUTO START
-- ============================================================
StartSpeedMods()

Notify("Race Clicker Cheat", "Script loaded! Press the toggles to activate features.")

-- Keybind untuk toggle GUI (Right Ctrl)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[Race Clicker Cheat] Loaded successfully!")
print("[Race Clicker Cheat] Press Right Ctrl to toggle GUI")
