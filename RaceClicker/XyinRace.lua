-- ============================================
-- RACE CLICKER SCRIPT v5.0 - GUARANTEED WORKING
-- Youtube.com/RukanooXD_YT
-- DEVELOPER TAG
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- FIND REMOTES (Multiple fallback methods)
-- ============================================
local ClickRF = nil
local RebirthRF = nil
local RaceRF = nil

-- Method 1: Direct path
pcall(function()
    ClickRF = ReplicatedStorage.Packages.Knit.Services.ClickService.RF.Click
end)

pcall(function()
    RebirthRF = ReplicatedStorage.Packages.Knit.Services.RebirthService.RF.Rebirth
end)

pcall(function()
    RaceRF = ReplicatedStorage.Packages.Knit.Services.RaceService.RF.Race
end)

-- Method 2: Search all descendants
if not ClickRF then
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Click" then
            ClickRF = obj
            break
        end
    end
end

if not RebirthRF then
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Rebirth" then
            RebirthRF = obj
            break
        end
    end
end

if not RaceRF then
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") and (obj.Name == "Race" or obj.Name == "FinishRace") then
            RaceRF = obj
            break
        end
    end
end

-- Verify ClickRF exists
if not ClickRF then
    warn("[RukanooXD] CRITICAL: ClickRF not found!")
    warn("[RukanooXD] Game may have updated. Check ReplicatedStorage structure.")
    return
end

print("[RukanooXD] ClickRF: " .. tostring(ClickRF))
print("[RukanooXD] RebirthRF: " .. tostring(RebirthRF))
print("[RukanooXD] RaceRF: " .. tostring(RaceRF))

-- ============================================
-- DESTROY OLD GUI
-- ============================================
for _, gui in pairs(playerGui:GetChildren()) do
    if gui.Name:find("RukanooXD") or gui.Name:find("RaceClicker") then
        gui:Destroy()
    end
end

-- ============================================
-- CREATE UI
-- ============================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RukanooXD_v5"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

-- Glow
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 40, 1, 40)
glow.Position = UDim2.new(0, -20, 0, -20)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891979"
glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
glow.ImageTransparency = 0.9
glow.ZIndex = 0
glow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 18)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.15, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "RACE CLICKER 2026"
titleText.TextColor3 = Color3.fromRGB(0, 255, 150)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- Version badge
local versionBadge = Instance.new("TextLabel")
versionBadge.Size = UDim2.new(0, 45, 0, 20)
versionBadge.Position = UDim2.new(0.02, 0, 0.3, 0)
versionBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
versionBadge.BackgroundTransparency = 0.8
versionBadge.Text = "v5.0"
versionBadge.TextColor3 = Color3.fromRGB(0, 255, 150)
versionBadge.TextSize = 11
versionBadge.Font = Enum.Font.GothamBold
versionBadge.Parent = titleBar

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 6)
badgeCorner.Parent = versionBadge

-- Dev Tag
local devTag = Instance.new("TextLabel")
devTag.Size = UDim2.new(1, 0, 0, 18)
devTag.Position = UDim2.new(0, 0, 0, 48)
devTag.BackgroundTransparency = 1
devTag.Text = "Youtube.com/RukanooXD_YT"
devTag.TextColor3 = Color3.fromRGB(100, 100, 150)
devTag.TextSize = 11
devTag.Font = Enum.Font.Gotham
devTag.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -78, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
minBtn.BackgroundTransparency = 0.2
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 10)
minCorner.Parent = minBtn

-- Drag
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Minimize toggle
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 320, 0, 48)}):Play()
        minBtn.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 320, 0, 450)}):Play()
        minBtn.Text = "−"
    end
end)

-- ============================================
-- TOGGLE CREATOR
-- ============================================
local activeThreads = {}

local function createToggle(parent, yPos, labelText, accentColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 50)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 48)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 12)
    fc.Parent = frame

    -- Hover effect
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)

    -- Indicator dot
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(0, 12, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.BorderSizePixel = 0
    indicator.Parent = frame

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(1, -82, 0.5, -15)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    return btn, indicator, label
end

-- ============================================
-- SECTION: MAIN MENU
-- ============================================
local mainSection = Instance.new("Frame")
mainSection.Size = UDim2.new(1, -16, 0, 260)
mainSection.Position = UDim2.new(0, 8, 0, 72)
mainSection.BackgroundTransparency = 1
mainSection.Parent = mainFrame

local sectionTitle1 = Instance.new("TextLabel")
sectionTitle1.Size = UDim2.new(1, 0, 0, 22)
sectionTitle1.BackgroundTransparency = 1
sectionTitle1.Text = "MAIN MENU"
sectionTitle1.TextColor3 = Color3.fromRGB(0, 255, 150)
sectionTitle1.TextSize = 14
sectionTitle1.Font = Enum.Font.GothamBold
sectionTitle1.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle1.Parent = mainSection

local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, 0, 0, 2)
divider1.Position = UDim2.new(0, 0, 0, 22)
divider1.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
divider1.BackgroundTransparency = 0.6
divider1.BorderSizePixel = 0
divider1.Parent = sectionTitle1

local divCorner1 = Instance.new("UICorner")
divCorner1.CornerRadius = UDim.new(1, 0)
divCorner1.Parent = divider1

-- Speed Hack
local speedBtn, speedInd, speedLabel = createToggle(mainSection, 28, "Speed Hack (999M)", Color3.fromRGB(0, 255, 100))

-- Visual Line
local speedLine = Instance.new("Frame")
speedLine.Size = UDim2.new(0, 3, 0, 0)
speedLine.Position = UDim2.new(0.5, 0, 0.5, 0)
speedLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
speedLine.BorderSizePixel = 0
speedLine.Visible = false
speedLine.ZIndex = 10
speedLine.Parent = mainFrame

local speedLineGradient = Instance.new("UIGradient")
speedLineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
})
speedLineGradient.Parent = speedLine

local speedEnabled = false

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedLine.Visible = true
        TweenService:Create(speedLine, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 3, 0, 100)}):Play()

        activeThreads["speed"] = task.spawn(function()
            while speedEnabled do
                pcall(function()
                    ClickRF:InvokeServer()
                end)
                task.wait(0.001)
            end
        end)
    else
        speedBtn.Text = "OFF"
        speedBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        speedInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        speedLine.Visible = false
        TweenService:Create(speedLine, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0, 0)}):Play()
        speedEnabled = false
    end
end)

-- Auto Click 15x
local clickBtn, clickInd, clickLabel = createToggle(mainSection, 86, "Auto Click 15x Fast", Color3.fromRGB(0, 255, 100))

local clickEnabled = false

clickBtn.MouseButton1Click:Connect(function()
    clickEnabled = not clickEnabled
    if clickEnabled then
        clickBtn.Text = "ON"
        clickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        clickInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)

        activeThreads["click"] = task.spawn(function()
            while clickEnabled do
                for i = 1, 15 do
                    pcall(function()
                        ClickRF:InvokeServer()
                    end)
                end
                task.wait(0.05)
            end
        end)
    else
        clickBtn.Text = "OFF"
        clickBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        clickInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        clickEnabled = false
    end
end)

-- Auto Race (Stage 1-6)
local raceBtn, raceInd, raceLabel = createToggle(mainSection, 144, "Auto Race (1-6)", Color3.fromRGB(150, 0, 255))

local raceEnabled = false

raceBtn.MouseButton1Click:Connect(function()
    raceEnabled = not raceEnabled
    if raceEnabled then
        raceBtn.Text = "ON"
        raceBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        raceInd.BackgroundColor3 = Color3.fromRGB(150, 0, 255)

        activeThreads["race"] = task.spawn(function()
            while raceEnabled do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart

                    -- Find and teleport to finish
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local name = obj.Name:lower()
                            if name:find("finish") or name:find("goal") or name:find("end") or name:find("win") then
                                pcall(function()
                                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                                end)
                                break
                            end
                        end
                    end

                    -- Fire race remote
                    if RaceRF then
                        pcall(function()
                            RaceRF:InvokeServer()
                        end)
                    end
                end
                task.wait(2)
            end
        end)
    else
        raceBtn.Text = "OFF"
        raceBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        raceInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        raceEnabled = false
    end
end)

-- ============================================
-- SECTION: REBIRTH MENU
-- ============================================
local rebirthSection = Instance.new("Frame")
rebirthSection.Size = UDim2.new(1, -16, 0, 95)
rebirthSection.Position = UDim2.new(0, 8, 0, 340)
rebirthSection.BackgroundTransparency = 1
rebirthSection.Parent = mainFrame

local sectionTitle2 = Instance.new("TextLabel")
sectionTitle2.Size = UDim2.new(1, 0, 0, 22)
sectionTitle2.BackgroundTransparency = 1
sectionTitle2.Text = "REBIRTH MENU"
sectionTitle2.TextColor3 = Color3.fromRGB(255, 100, 100)
sectionTitle2.TextSize = 14
sectionTitle2.Font = Enum.Font.GothamBold
sectionTitle2.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle2.Parent = rebirthSection

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, 0, 0, 2)
divider2.Position = UDim2.new(0, 0, 0, 22)
divider2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
divider2.BackgroundTransparency = 0.6
divider2.BorderSizePixel = 0
divider2.Parent = sectionTitle2

local divCorner2 = Instance.new("UICorner")
divCorner2.CornerRadius = UDim.new(1, 0)
divCorner2.Parent = divider2

-- Auto Rebirth
local rebirthBtn, rebirthInd, rebirthLabel = createToggle(rebirthSection, 28, "Auto Rebirth", Color3.fromRGB(255, 100, 100))

local rebirthEnabled = false

rebirthBtn.MouseButton1Click:Connect(function()
    rebirthEnabled = not rebirthEnabled
    if rebirthEnabled then
        if not RebirthRF then
            rebirthBtn.Text = "ERR"
            rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            rebirthInd.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            return
        end

        rebirthBtn.Text = "ON"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        rebirthInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)

        activeThreads["rebirth"] = task.spawn(function()
            while rebirthEnabled do
                pcall(function()
                    RebirthRF:InvokeServer()
                end)
                task.wait(3)
            end
        end)
    else
        rebirthBtn.Text = "OFF"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        rebirthInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        rebirthEnabled = false
    end
end)

-- ============================================
-- STATS
-- ============================================
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -16, 0, 70)
statsFrame.Position = UDim2.new(0, 8, 0, 445)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 48)
statsFrame.BackgroundTransparency = 0.3
statsFrame.BorderSizePixel = 0
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsFrame

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, 0, 0, 18)
statsTitle.Position = UDim2.new(0, 10, 0, 4)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "LIVE STATS"
statsTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
statsTitle.TextSize = 11
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsFrame

local speedStat = Instance.new("TextLabel")
speedStat.Size = UDim2.new(0.5, 0, 0, 18)
speedStat.Position = UDim2.new(0, 10, 0, 24)
speedStat.BackgroundTransparency = 1
speedStat.Text = "Speed: 0"
speedStat.TextColor3 = Color3.fromRGB(200, 200, 200)
speedStat.TextSize = 11
speedStat.Font = Enum.Font.Gotham
speedStat.TextXAlignment = Enum.TextXAlignment.Left
speedStat.Parent = statsFrame

local winsStat = Instance.new("TextLabel")
winsStat.Size = UDim2.new(0.5, 0, 0, 18)
winsStat.Position = UDim2.new(0.5, 0, 0, 24)
winsStat.BackgroundTransparency = 1
winsStat.Text = "Wins: 0"
winsStat.TextColor3 = Color3.fromRGB(200, 200, 200)
winsStat.TextSize = 11
winsStat.Font = Enum.Font.Gotham
winsStat.TextXAlignment = Enum.TextXAlignment.Left
winsStat.Parent = statsFrame

local rebirthStat = Instance.new("TextLabel")
rebirthStat.Size = UDim2.new(0.5, 0, 0, 18)
rebirthStat.Position = UDim2.new(0, 10, 0, 44)
rebirthStat.BackgroundTransparency = 1
rebirthStat.Text = "Rebirths: 0"
rebirthStat.TextColor3 = Color3.fromRGB(200, 200, 200)
rebirthStat.TextSize = 11
rebirthStat.Font = Enum.Font.Gotham
rebirthStat.TextXAlignment = Enum.TextXAlignment.Left
rebirthStat.Parent = statsFrame

local stageStat = Instance.new("TextLabel")
stageStat.Size = UDim2.new(0.5, 0, 0, 18)
stageStat.Position = UDim2.new(0.5, 0, 0, 44)
stageStat.BackgroundTransparency = 1
stageStat.Text = "Stage: 1"
stageStat.TextColor3 = Color3.fromRGB(200, 200, 200)
stageStat.TextSize = 11
stageStat.Font = Enum.Font.Gotham
stageStat.TextXAlignment = Enum.TextXAlignment.Left
stageStat.Parent = statsFrame

-- Update stats
 task.spawn(function()
    while mainGui and mainGui.Parent do
        pcall(function()
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local wins = leaderstats:FindFirstChild("Wins")
                local rebirths = leaderstats:FindFirstChild("Rebirths")
                if wins then winsStat.Text = "Wins: " .. wins.Value end
                if rebirths then rebirthStat.Text = "Rebirths: " .. rebirths.Value end
            end

            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                speedStat.Text = "Speed: " .. math.floor(char.Humanoid.WalkSpeed)
            end
        end)
        task.wait(1)
    end
end)

-- ============================================
-- CLOSE HANDLER
-- ============================================
closeBtn.MouseButton1Click:Connect(function()
    for name, thread in pairs(activeThreads) do
        -- Threads will stop on next iteration since flags are false
    end
    speedEnabled = false
    clickEnabled = false
    raceEnabled = false
    rebirthEnabled = false
    mainGui:Destroy()
end)

-- ============================================
-- NOTIFICATION
-- ============================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "RukanooXD_Notif"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = playerGui

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 300, 0, 60)
notifFrame.Position = UDim2.new(0.5, -150, 0, -80)
notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
notifFrame.BackgroundTransparency = 0.1
notifFrame.BorderSizePixel = 0
notifFrame.Parent = notifGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 14)
notifCorner.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "SCRIPT ACTIVE - RukanooXD_YT v5.0"
notifText.TextColor3 = Color3.fromRGB(0, 255, 150)
notifText.TextSize = 16
notifText.Font = Enum.Font.GothamBold
notifText.Parent = notifFrame

TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -150, 0, 20)
}):Play()

task.wait(3)

TweenService:Create(notifFrame, TweenInfo.new(0.5), {
    Position = UDim2.new(0.5, -150, 0, -80)
}):Play()

task.wait(0.6)
notifGui:Destroy()

print("[RukanooXD] Race Clicker v5.0 Loaded Successfully!")
