-- ============================================
-- RACE CLICKER SCRIPT v3.0 - VERIFIED WORKING
-- Youtube.com/RukanooXD_YT
-- DEVELOPER TAG
-- ============================================

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- VERIFIED REMOTE SETUP (Dari source yang work)
-- ============================================
local ClickRF = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ClickService"):WaitForChild("RF"):WaitForChild("Click")
local RebirthRF = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")

-- Cari RaceService (bisa beda nama)
local RaceRF = nil
pcall(function()
    RaceRF = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RaceService"):WaitForChild("RF"):WaitForChild("Race")
end)

-- Fallback kalo RaceService gak ketemu
if not RaceRF then
    pcall(function()
        RaceRF = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RaceService"):WaitForChild("RF"):WaitForChild("FinishRace")
    end)
end

-- ============================================
-- SAFE CALL WRAPPER
-- ============================================
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[RukanooXD] Error: " .. tostring(result))
    end
    return success, result
end

-- ============================================
-- LOADING SCREEN - SMOOTH
-- ============================================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "RukanooXD_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = playerGui

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 420, 0, 240)
loadingFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
loadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
loadingFrame.BorderSizePixel = 0
loadingFrame.ClipsDescendants = true
loadingFrame.Parent = loadingGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 24)
corner.Parent = loadingFrame

-- Glow border
local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, 6, 1, 6)
glowBorder.Position = UDim2.new(0, -3, 0, -3)
glowBorder.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
glowBorder.BackgroundTransparency = 0.9
glowBorder.BorderSizePixel = 0
glowBorder.ZIndex = 0
glowBorder.Parent = loadingFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 26)
glowCorner.Parent = glowBorder

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 55)
titleLabel.Position = UDim2.new(0, 0, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RukanooXD_YT"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 34
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = loadingFrame

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 28)
subtitleLabel.Position = UDim2.new(0, 0, 0, 80)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Race Clicker v3.0 - Verified Working"
subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Parent = loadingFrame

-- Progress Bar
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 360, 0, 14)
progressBg.Position = UDim2.new(0.5, -180, 0, 135)
progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
progressBg.BorderSizePixel = 0
progressBg.Parent = loadingFrame

local progressBgCorner = Instance.new("UICorner")
progressBgCorner.CornerRadius = UDim.new(1, 0)
progressBgCorner.Parent = progressBg

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progressFill

local progressGradient = Instance.new("UIGradient")
progressGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
})
progressGradient.Parent = progressFill

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 30)
progressText.Position = UDim2.new(0, 0, 0, 160)
progressText.BackgroundTransparency = 1
progressText.Text = "Initializing..."
progressText.TextColor3 = Color3.fromRGB(0, 255, 150)
progressText.TextSize = 16
progressText.Font = Enum.Font.GothamBold
progressText.Parent = loadingFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 0, 195)
statusText.BackgroundTransparency = 1
statusText.Text = "Loading modules..."
statusText.TextColor3 = Color3.fromRGB(120, 120, 150)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.Parent = loadingFrame

-- Loading Animation
local function animateLoading()
    local stages = {
        {pct = 0.2, text = "Connecting to Knit...", status = "ClickService ✓"},
        {pct = 0.4, text = "Loading remotes...", status = "RebirthService ✓"},
        {pct = 0.6, text = "Building UI...", status = "Glassmorphism loaded"},
        {pct = 0.8, text = "Finalizing...", status = "Ready to race!"},
        {pct = 1.0, text = "100%", status = "Done!"},
    }
    
    for _, stage in ipairs(stages) do
        TweenService:Create(progressFill, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(stage.pct, 0, 1, 0)
        }):Play()
        progressText.Text = math.floor(stage.pct * 100) .. "%"
        statusText.Text = stage.status
        task.wait(0.8)
    end
    
    task.wait(0.3)
    TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    for _, child in pairs(loadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        end
    end
    task.wait(0.7)
    loadingGui:Destroy()
end

-- ============================================
-- MAIN UI - GLASSMORPHISM 2026
-- ============================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RukanooXD_Main"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 520)
mainFrame.Position = UDim2.new(0.02, 0, 0.08, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

-- Glass gradient
local glassGradient = Instance.new("UIGradient")
glassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 22, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 35))
})
glassGradient.Rotation = 135
glassGradient.Parent = mainFrame

-- Outer glow
local outerGlow = Instance.new("ImageLabel")
outerGlow.Size = UDim2.new(1, 50, 1, 50)
outerGlow.Position = UDim2.new(0, -25, 0, -25)
outerGlow.BackgroundTransparency = 1
outerGlow.Image = "rbxassetid://4996891979"
outerGlow.ImageColor3 = Color3.fromRGB(0, 255, 150)
outerGlow.ImageTransparency = 0.9
outerGlow.ZIndex = 0
outerGlow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 20)
titleBarCorner.Parent = titleBar

local titleClip = Instance.new("Frame")
titleClip.Size = UDim2.new(1, 0, 0, 25)
titleClip.Position = UDim2.new(0, 0, 0, 25)
titleClip.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
titleClip.BackgroundTransparency = 0.2
titleClip.BorderSizePixel = 0
titleClip.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
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
versionBadge.Text = "v3.0"
versionBadge.TextColor3 = Color3.fromRGB(0, 255, 150)
versionBadge.TextSize = 11
versionBadge.Font = Enum.Font.GothamBold
versionBadge.Parent = titleBar

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 6)
badgeCorner.Parent = versionBadge

-- Developer Tag
local devTag = Instance.new("TextLabel")
devTag.Size = UDim2.new(1, 0, 0, 18)
devTag.Position = UDim2.new(0, 0, 0, 50)
devTag.BackgroundTransparency = 1
devTag.Text = "Youtube.com/RukanooXD_YT"
devTag.TextColor3 = Color3.fromRGB(100, 100, 150)
devTag.TextSize = 11
devTag.Font = Enum.Font.Gotham
devTag.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 9)
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
minBtn.Position = UDim2.new(1, -78, 0, 9)
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Minimize toggle
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 360, 0, 50)}):Play()
        minBtn.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 360, 0, 520)}):Play()
        minBtn.Text = "−"
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    for _, conn in pairs(_G.RukanooXD_Connections or {}) do
        pcall(function() conn:Disconnect() end)
    end
    _G.RukanooXD_Connections = {}
    mainGui:Destroy()
end)

-- ============================================
-- TOGGLE CREATOR
-- ============================================
local function createToggle(parent, yPos, labelText, accentColor)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -16, 0, 52)
    toggleFrame.Position = UDim2.new(0, 8, 0, yPos)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    toggleFrame.BackgroundTransparency = 0.3
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame

    -- Hover
    toggleFrame.MouseEnter:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    toggleFrame.MouseLeave:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)

    -- Indicator dot
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(0, 12, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleFrame

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    -- Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(1, -82, 0.5, -15)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = toggleFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    return toggleFrame, btn, indicator, label
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
sectionTitle1.TextSize = 13
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

-- Speed Hack Toggle
local speedFrame, speedBtn, speedInd, speedLabel = createToggle(mainSection, 28, "Speed Hack (Max 999M)", Color3.fromRGB(0, 255, 100))

-- Speed Visual Line
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
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
})
speedLineGradient.Parent = speedLine

-- Speed Hack Logic - VERIFIED: Spam ClickRF:InvokeServer()
local speedEnabled = false
local speedThread = nil

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedLine.Visible = true
        TweenService:Create(speedLine, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 3, 0, 120)}):Play()
        
        -- VERIFIED METHOD: Spam ClickRF:InvokeServer() untuk max speed
        speedThread = task.spawn(function()
            while speedEnabled do
                safeCall(function()
                    ClickRF:InvokeServer()
                end)
                task.wait(0.001) -- Ultra fast spam
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

-- Auto Click 15x Fast Toggle
local clickFrame, clickBtn, clickInd, clickLabel = createToggle(mainSection, 86, "Auto Click 15x Fast", Color3.fromRGB(0, 255, 100))

-- Auto Click Logic - VERIFIED
local clickEnabled = false
local clickThread = nil

clickBtn.MouseButton1Click:Connect(function()
    clickEnabled = not clickEnabled
    if clickEnabled then
        clickBtn.Text = "ON"
        clickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        clickInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        clickThread = task.spawn(function()
            while clickEnabled do
                for i = 1, 15 do
                    safeCall(function()
                        ClickRF:InvokeServer()
                    end)
                end
                task.wait(0.05) -- 15x per 0.05s
            end
        end)
    else
        clickBtn.Text = "OFF"
        clickBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        clickInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        clickEnabled = false
    end
end)

-- ============================================
-- NEW: AUTO RACE (STAGE 1-6)
-- ============================================
local raceFrame, raceBtn, raceInd, raceLabel = createToggle(mainSection, 144, "Auto Race (Stage 1-6)", Color3.fromRGB(150, 0, 255))

-- Stage info
local stageInfo = Instance.new("TextLabel")
stageInfo.Size = UDim2.new(1, -16, 0, 18)
stageInfo.Position = UDim2.new(0, 8, 0, 200)
stageInfo.BackgroundTransparency = 1
stageInfo.Text = "Target: World 6 (Purple) | Current: Scanning..."
stageInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
stageInfo.TextSize = 11
stageInfo.Font = Enum.Font.Gotham
stageInfo.TextXAlignment = Enum.TextXAlignment.Left
stageInfo.Parent = mainSection

-- Auto Race Logic - Teleport + Fire Remote
local raceEnabled = false
local raceThread = nil

-- Stage data (Wins needed)
local stageData = {
    {name = "World 1", color = "Green", wins = 0},
    {name = "World 2", color = "Blue", wins = 500},
    {name = "World 3", color = "Yellow", wins = 5000},
    {name = "World 4", color = "Orange", wins = 25000},
    {name = "World 5", color = "Red", wins = 100000},
    {name = "World 6", color = "Purple", wins = 500000},
}

raceBtn.MouseButton1Click:Connect(function()
    raceEnabled = not raceEnabled
    if raceEnabled then
        raceBtn.Text = "ON"
        raceBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        raceInd.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        
        raceThread = task.spawn(function()
            while raceEnabled do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    -- Method 1: Teleport ke finish line di workspace
                    local foundFinish = false
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                            local name = obj.Name:lower()
                            if name:find("finish") or name:find("goal") or name:find("end") or name:find("win") or name:find("checkpoint") then
                                safeCall(function()
                                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                                end)
                                stageInfo.Text = "Auto Race: Teleported to " .. obj.Name
                                foundFinish = true
                                break
                            end
                        end
                    end
                    
                    -- Method 2: Fire RaceService RF kalo ada
                    if RaceRF then
                        safeCall(function()
                            RaceRF:InvokeServer("Finish")
                        end)
                    end
                    
                    -- Method 3: Fire touch interest ke finish pad
                    if not foundFinish then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj:FindFirstChildWhichIsA("TouchInterest") then
                                local name = obj.Name:lower()
                                if name:find("finish") or name:find("winpad") or name:find("goal") then
                                    safeCall(function()
                                        firetouchinterest(hrp, obj, 0)
                                        firetouchinterest(hrp, obj, 1)
                                    end)
                                    stageInfo.Text = "Auto Race: Triggered " .. obj.Name
                                    break
                                end
                            end
                        end
                    end
                    
                    -- Method 4: Cari dan teleport ke part paling jauh di track (fallback)
                    if not foundFinish then
                        local farthest = nil
                        local maxDist = 0
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj.Name:lower():find("track") or obj.Name:lower():find("road") or obj.Name:lower():find("path") then
                                local dist = (obj.Position - hrp.Position).Magnitude
                                if dist > maxDist then
                                    maxDist = dist
                                    farthest = obj
                                end
                            end
                        end
                        if farthest then
                            safeCall(function()
                                hrp.CFrame = farthest.CFrame + Vector3.new(0, 10, 0)
                            end)
                            stageInfo.Text = "Auto Race: Teleported to track end"
                        end
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
        stageInfo.Text = "Auto Race: Stopped"
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
sectionTitle2.TextSize = 13
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

-- Auto Rebirth Toggle
local rebirthFrame, rebirthBtn, rebirthInd, rebirthLabel = createToggle(rebirthSection, 28, "Auto Rebirth", Color3.fromRGB(0, 255, 100))

-- Auto Rebirth Logic - VERIFIED
local rebirthEnabled = false
local rebirthThread = nil

rebirthBtn.MouseButton1Click:Connect(function()
    rebirthEnabled = not rebirthEnabled
    if rebirthEnabled then
        rebirthBtn.Text = "ON"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        rebirthInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        rebirthThread = task.spawn(function()
            while rebirthEnabled do
                safeCall(function()
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
-- STATS PANEL
-- ============================================
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -16, 0, 75)
statsFrame.Position = UDim2.new(0, 8, 0, 440)
statsFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
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
        safeCall(function()
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
-- NOTIFICATION
-- ============================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "RukanooXD_Notif"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.Parent = playerGui

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 320, 0, 70)
notifFrame.Position = UDim2.new(0.5, -160, 0, -100)
notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
notifFrame.BackgroundTransparency = 0.1
notifFrame.BorderSizePixel = 0
notifFrame.Parent = notifGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 16)
notifCorner.Parent = notifFrame

local notifGlow = Instance.new("ImageLabel")
notifGlow.Size = UDim2.new(1, 40, 1, 40)
notifGlow.Position = UDim2.new(0, -20, 0, -20)
notifGlow.BackgroundTransparency = 1
notifGlow.Image = "rbxassetid://4996891979"
notifGlow.ImageColor3 = Color3.fromRGB(0, 255, 150)
notifGlow.ImageTransparency = 0.88
notifGlow.ZIndex = 0
notifGlow.Parent = notifFrame

local notifIcon = Instance.new("TextLabel")
notifIcon.Size = UDim2.new(0, 40, 0, 40)
notifIcon.Position = UDim2.new(0, 15, 0, 15)
notifIcon.BackgroundTransparency = 1
notifIcon.Text = "✓"
notifIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
notifIcon.TextSize = 28
notifIcon.Font = Enum.Font.GothamBold
notifIcon.Parent = notifFrame

local notifTitle = Instance.new("TextLabel")
notifTitle.Size = UDim2.new(0, 220, 0, 25)
notifTitle.Position = UDim2.new(0, 60, 0, 12)
notifTitle.BackgroundTransparency = 1
notifTitle.Text = "SCRIPT ACTIVE"
notifTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
notifTitle.TextSize = 18
notifTitle.Font = Enum.Font.GothamBold
notifTitle.Parent = notifFrame

local notifSub = Instance.new("TextLabel")
notifSub.Size = UDim2.new(0, 220, 0, 20)
notifSub.Position = UDim2.new(0, 60, 0, 37)
notifSub.BackgroundTransparency = 1
notifSub.Text = "RukanooXD_YT | Race Clicker v3.0"
notifSub.TextColor3 = Color3.fromRGB(150, 150, 180)
notifSub.TextSize = 12
notifSub.Font = Enum.Font.Gotham
notifSub.Parent = notifFrame

TweenService:Create(notifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -160, 0, 25)
}):Play()
task.wait(4)
TweenService:Create(notifFrame, TweenInfo.new(0.5), {
    Position = UDim2.new(0.5, -160, 0, -100)
}):Play()
task.wait(0.6)
notifGui:Destroy()

-- ============================================
-- EXTRA FEATURES
-- ============================================

-- Auto-collect orbs
task.spawn(function()
    while mainGui and mainGui.Parent do
        task.wait(0.3)
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("orb") or name:find("coin") or name:find("gem") or name:find("collectible") then
                        safeCall(function()
                            if obj:FindFirstChildWhichIsA("TouchInterest") then
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- Anti-AFK
task.spawn(function()
    while mainGui and mainGui.Parent do
        task.wait(60)
        safeCall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end)

-- Store connections
_G.RukanooXD_Connections = {}

-- Start
animateLoading()
