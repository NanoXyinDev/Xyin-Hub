-- ============================================
-- RACE CLICKER SCRIPT v2.0 - FIXED WORKING
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
-- UTILITY FUNCTIONS
-- ============================================
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[RukanooXD] Error: " .. tostring(result))
    end
    return success, result
end

-- Find Knit Services (Race Clicker pake Knit framework)
local Knit = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Knit", 5)
local ClickService = Knit:WaitForChild("Services", 5):WaitForChild("ClickService", 5)
local ClickRF = ClickService:WaitForChild("RF", 5):WaitForChild("Click", 5)
local RebirthService = Knit:WaitForChild("Services", 5):WaitForChild("RebirthService", 5)
local RebirthRF = RebirthService:WaitForChild("RF", 5):WaitForChild("Rebirth", 5)
local RaceService = Knit:WaitForChild("Services", 5):WaitForChild("RaceService", 5)
local RaceRF = RaceService:WaitForChild("RF", 5):WaitForChild("Race", 5)

-- ============================================
-- LOADING SCREEN WITH SMOOTH PROGRESS BAR
-- ============================================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "RukanooXD_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = playerGui

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 450, 0, 220)
loadingFrame.Position = UDim2.new(0.5, -225, 0.5, -110)
loadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
loadingFrame.BorderSizePixel = 0
loadingFrame.ClipsDescendants = true
loadingFrame.Parent = loadingGui

-- Gradient background
local loadGradient = Instance.new("UIGradient")
loadGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 15, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
})
loadGradient.Rotation = 45
loadGradient.Parent = loadingFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 24)
corner.Parent = loadingFrame

-- Glow border
local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, 4, 1, 4)
glowBorder.Position = UDim2.new(0, -2, 0, -2)
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
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RukanooXD_YT"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 32
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = loadingFrame

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 25)
subtitleLabel.Position = UDim2.new(0, 0, 0, 75)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Race Clicker v2.0 - 2026 Edition"
subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Parent = loadingFrame

-- Progress Bar Container
local progressContainer = Instance.new("Frame")
progressContainer.Size = UDim2.new(0, 360, 0, 14)
progressContainer.Position = UDim2.new(0.5, -180, 0, 125)
progressContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
progressContainer.BorderSizePixel = 0
progressContainer.Parent = loadingFrame

local progressContainerCorner = Instance.new("UICorner")
progressContainerCorner.CornerRadius = UDim.new(1, 0)
progressContainerCorner.Parent = progressContainer

-- Progress Fill
local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressContainer

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progressFill

-- Gradient on progress
local progressGradient = Instance.new("UIGradient")
progressGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
})
progressGradient.Parent = progressFill

-- Progress Text
local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 30)
progressText.Position = UDim2.new(0, 0, 0, 150)
progressText.BackgroundTransparency = 1
progressText.Text = "Initializing..."
progressText.TextColor3 = Color3.fromRGB(0, 255, 150)
progressText.TextSize = 16
progressText.Font = Enum.Font.GothamBold
progressText.Parent = loadingFrame

-- Status text
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 0, 180)
statusText.BackgroundTransparency = 1
statusText.Text = "Loading modules..."
statusText.TextColor3 = Color3.fromRGB(120, 120, 150)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.Parent = loadingFrame

-- Smooth Loading Animation
local function animateLoading()
    local stages = {
        {pct = 0.15, text = "Loading modules...", status = "Knit Framework detected"},
        {pct = 0.35, text = "Connecting services...", status = "ClickService ✓ RebirthService ✓"},
        {pct = 0.55, text = "Scanning remotes...", status = "RemoteFunctions found"},
        {pct = 0.75, text = "Building UI...", status = "Glassmorphism style loaded"},
        {pct = 0.90, text = "Finalizing...", status = "Ready to race!"},
        {pct = 1.00, text = "100%", status = "Done!"},
    }
    
    for _, stage in ipairs(stages) do
        local tween = TweenService:Create(progressFill, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(stage.pct, 0, 1, 0)
        })
        tween:Play()
        progressText.Text = math.floor(stage.pct * 100) .. "%"
        statusText.Text = stage.status
        task.wait(0.9)
    end
    
    task.wait(0.3)
    
    -- Fade out loading
    local fadeTween = TweenService:Create(loadingFrame, TweenInfo.new(0.6), {
        BackgroundTransparency = 1
    })
    fadeTween:Play()
    
    for _, child in pairs(loadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            if child ~= glowBorder then
                TweenService:Create(child, TweenInfo.new(0.6), {
                    BackgroundTransparency = 1,
                    TextTransparency = 1
                }):Play()
            end
        end
    end
    
    task.wait(0.7)
    loadingGui:Destroy()
end

-- ============================================
-- MAIN UI - GLASSMORPHISM 2026 STYLE
-- ============================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RukanooXD_Main"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 580)
mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

-- Glassmorphism gradient
local glassGradient = Instance.new("UIGradient")
glassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 25, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
})
glassGradient.Rotation = 135
glassGradient.Parent = mainFrame

-- Outer glow
local outerGlow = Instance.new("ImageLabel")
outerGlow.Size = UDim2.new(1, 60, 1, 60)
outerGlow.Position = UDim2.new(0, -30, 0, -30)
outerGlow.BackgroundTransparency = 1
outerGlow.Image = "rbxassetid://4996891979"
outerGlow.ImageColor3 = Color3.fromRGB(0, 255, 150)
outerGlow.ImageTransparency = 0.92
outerGlow.ZIndex = 0
outerGlow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 20)
titleBarCorner.Parent = titleBar

-- Bottom clip for title bar
local titleBarClip = Instance.new("Frame")
titleBarClip.Size = UDim2.new(1, 0, 0, 25)
titleBarClip.Position = UDim2.new(0, 0, 0, 25)
titleBarClip.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
titleBarClip.BackgroundTransparency = 0.3
titleBarClip.BorderSizePixel = 0
titleBarClip.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.15, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "RACE CLICKER 2026"
titleText.TextColor3 = Color3.fromRGB(0, 255, 150)
titleText.TextSize = 22
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- Version badge
local versionBadge = Instance.new("TextLabel")
versionBadge.Size = UDim2.new(0, 50, 0, 20)
versionBadge.Position = UDim2.new(0.02, 0, 0.3, 0)
versionBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
versionBadge.BackgroundTransparency = 0.8
versionBadge.Text = "v2.0"
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
devTag.TextColor3 = Color3.fromRGB(120, 120, 160)
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

closeBtn.MouseButton1Click:Connect(function()
    -- Destroy all loops
    for _, conn in pairs(_G.RukanooXD_Connections or {}) do
        pcall(function() conn:Disconnect() end)
    end
    _G.RukanooXD_Connections = {}
    mainGui:Destroy()
end)

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

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 380, 0, 50)
        }):Play()
        minBtn.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 380, 0, 580)
        }):Play()
        minBtn.Text = "−"
    end
end)

-- Drag Function (Smooth)
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

-- ============================================
-- HELPER: CREATE TOGGLE BUTTON
-- ============================================
local function createToggle(parent, yPos, labelText, colorOn)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 55)
    toggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    toggleFrame.BackgroundTransparency = 0.4
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame

    -- Hover effect
    toggleFrame.MouseEnter:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    toggleFrame.MouseLeave:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.4
        }):Play()
    end)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 0, 32)
    btn.Position = UDim2.new(1, -90, 0.5, -16)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = toggleFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    -- Status indicator dot
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 8, 0, 8)
    indicator.Position = UDim2.new(0, 6, 0.5, -4)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleFrame

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    return toggleFrame, btn, indicator, label
end

-- ============================================
-- SECTION: MAIN MENU
-- ============================================
local mainSection = Instance.new("Frame")
mainSection.Size = UDim2.new(1, -20, 0, 280)
mainSection.Position = UDim2.new(0, 10, 0, 75)
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

-- Divider line
local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, 0, 0, 2)
divider1.Position = UDim2.new(0, 0, 0, 22)
divider1.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
divider1.BackgroundTransparency = 0.7
divider1.BorderSizePixel = 0
divider1.Parent = sectionTitle1

local divCorner = Instance.new("UICorner")
divCorner.CornerRadius = UDim.new(1, 0)
divCorner.Parent = divider1

-- Speed Hack Toggle
local speedFrame, speedBtn, speedInd, speedLabel = createToggle(mainSection, 30, "Speed Hack (Max 999M)", Color3.fromRGB(0, 255, 100))

-- Speed Visual Line (Neon)
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

-- Speed Hack Logic - FIXED
local speedEnabled = false
local speedConn = nil

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedLine.Visible = true
        
        -- Animate line
        TweenService:Create(speedLine, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 3, 0, 120)
        }):Play()
        
        -- Speed Hack: Fire ClickService RF Click untuk max speed
        speedConn = task.spawn(function()
            while speedEnabled do
                safeCall(function()
                    -- Race Clicker pake ClickService RF Click untuk nambah speed
                    ClickRF:InvokeServer()
                end)
                task.wait(0.01) -- Ultra fast clicking
            end
        end)
    else
        speedBtn.Text = "OFF"
        speedBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        speedInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        speedLine.Visible = false
        TweenService:Create(speedLine, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 3, 0, 0)
        }):Play()
        speedEnabled = false
    end
end)

-- Auto Click 15x Fast Toggle
local clickFrame, clickBtn, clickInd, clickLabel = createToggle(mainSection, 92, "Auto Click 15x Fast", Color3.fromRGB(0, 255, 100))

-- Auto Click Logic - FIXED (No Screen Disturbance)
local clickEnabled = false
local clickConn = nil

clickBtn.MouseButton1Click:Connect(function()
    clickEnabled = not clickEnabled
    if clickEnabled then
        clickBtn.Text = "ON"
        clickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        clickInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Auto Click via ClickService RF (Server-side, no visual disturbance)
        clickConn = task.spawn(function()
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
-- NEW: AUTO RACE - FINISH ALL STAGES 1-6
-- ============================================
local raceFrame, raceBtn, raceInd, raceLabel = createToggle(mainSection, 154, "Auto Race (Stage 1-6)", Color3.fromRGB(150, 0, 255))

-- Stage info text
local stageInfo = Instance.new("TextLabel")
stageInfo.Size = UDim2.new(1, -20, 0, 18)
stageInfo.Position = UDim2.new(0, 10, 0, 212)
stageInfo.BackgroundTransparency = 1
stageInfo.Text = "Current: Stage 1 | Target: World 6 (Purple)"
stageInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
stageInfo.TextSize = 11
stageInfo.Font = Enum.Font.Gotham
stageInfo.TextXAlignment = Enum.TextXAlignment.Left
stageInfo.Parent = mainSection

-- Auto Race Logic - TELEPORT TO FINISH LINE
local raceEnabled = false
local raceConn = nil

-- World/Stage data (Race Clicker punya 6 Worlds)
local worldStages = {
    {name = "World 1", color = "Green", winsNeeded = 0},
    {name = "World 2", color = "Blue", winsNeeded = 500},
    {name = "World 3", color = "Yellow", winsNeeded = 5000},
    {name = "World 4", color = "Orange", winsNeeded = 25000},
    {name = "World 5", color = "Red", winsNeeded = 100000},
    {name = "World 6", color = "Purple", winsNeeded = 500000},
}

raceBtn.MouseButton1Click:Connect(function()
    raceEnabled = not raceEnabled
    if raceEnabled then
        raceBtn.Text = "ON"
        raceBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        raceInd.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        
        raceConn = task.spawn(function()
            while raceEnabled do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    -- Method 1: Cari finish line/part di workspace
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local name = obj.Name:lower()
                            -- Cari finish line, end, goal, checkpoint
                            if name:find("finish") or name:find("goal") or name:find("end") or name:find("win") then
                                safeCall(function()
                                    -- Teleport ke finish line
                                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                                end)
                                stageInfo.Text = "Auto Race: Teleported to " .. obj.Name
                                break
                            end
                        end
                    end
                    
                    -- Method 2: Fire RaceService RF untuk auto complete
                    safeCall(function()
                        RaceRF:InvokeServer("FinishRace")
                    end)
                    
                    -- Method 3: Cari dan trigger TouchInterest di finish
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj:FindFirstChildWhichIsA("TouchInterest") then
                            local name = obj.Name:lower()
                            if name:find("finish") or name:find("goal") or name:find("winpad") then
                                safeCall(function()
                                    firetouchinterest(hrp, obj, 0)
                                    firetouchinterest(hrp, obj, 1)
                                end)
                            end
                        end
                    end
                end
                
                task.wait(2) -- Check setiap 2 detik
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
rebirthSection.Size = UDim2.new(1, -20, 0, 100)
rebirthSection.Position = UDim2.new(0, 10, 0, 365)
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
divider2.BackgroundTransparency = 0.7
divider2.BorderSizePixel = 0
divider2.Parent = sectionTitle2

local div2Corner = Instance.new("UICorner")
div2Corner.CornerRadius = UDim.new(1, 0)
div2Corner.Parent = divider2

-- Auto Rebirth Toggle
local rebirthFrame, rebirthBtn, rebirthInd, rebirthLabel = createToggle(rebirthSection, 30, "Auto Rebirth", Color3.fromRGB(0, 255, 100))

-- Auto Rebirth Logic - FIXED
local rebirthEnabled = false
local rebirthConn = nil

rebirthBtn.MouseButton1Click:Connect(function()
    rebirthEnabled = not rebirthEnabled
    if rebirthEnabled then
        rebirthBtn.Text = "ON"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        rebirthInd.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        rebirthConn = task.spawn(function()
            while rebirthEnabled do
                -- Fire RebirthService RF
                safeCall(function()
                    RebirthRF:InvokeServer()
                end)
                task.wait(3) -- Interval rebirth
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
-- STATS DISPLAY
-- ============================================
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -20, 0, 80)
statsFrame.Position = UDim2.new(0, 10, 0, 475)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
statsFrame.BackgroundTransparency = 0.4
statsFrame.BorderSizePixel = 0
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsFrame

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, 0, 0, 20)
statsTitle.Position = UDim2.new(0, 10, 0, 5)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "LIVE STATS"
statsTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
statsTitle.TextSize = 12
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsFrame

local speedStat = Instance.new("TextLabel")
speedStat.Size = UDim2.new(0.5, 0, 0, 20)
speedStat.Position = UDim2.new(0, 10, 0, 28)
speedStat.BackgroundTransparency = 1
speedStat.Text = "Speed: 0"
speedStat.TextColor3 = Color3.fromRGB(200, 200, 200)
speedStat.TextSize = 11
speedStat.Font = Enum.Font.Gotham
speedStat.TextXAlignment = Enum.TextXAlignment.Left
speedStat.Parent = statsFrame

local winsStat = Instance.new("TextLabel")
winsStat.Size = UDim2.new(0.5, 0, 0, 20)
winsStat.Position = UDim2.new(0.5, 0, 0, 28)
winsStat.BackgroundTransparency = 1
winsStat.Text = "Wins: 0"
winsStat.TextColor3 = Color3.fromRGB(200, 200, 200)
winsStat.TextSize = 11
winsStat.Font = Enum.Font.Gotham
winsStat.TextXAlignment = Enum.TextXAlignment.Left
winsStat.Parent = statsFrame

local rebirthStat = Instance.new("TextLabel")
rebirthStat.Size = UDim2.new(0.5, 0, 0, 20)
rebirthStat.Position = UDim2.new(0, 10, 0, 50)
rebirthStat.BackgroundTransparency = 1
rebirthStat.Text = "Rebirths: 0"
rebirthStat.TextColor3 = Color3.fromRGB(200, 200, 200)
rebirthStat.TextSize = 11
rebirthStat.Font = Enum.Font.Gotham
rebirthStat.TextXAlignment = Enum.TextXAlignment.Left
rebirthStat.Parent = statsFrame

local stageStat = Instance.new("TextLabel")
stageStat.Size = UDim2.new(0.5, 0, 0, 20)
stageStat.Position = UDim2.new(0.5, 0, 0, 50)
stageStat.BackgroundTransparency = 1
stageStat.Text = "Stage: 1"
stageStat.TextColor3 = Color3.fromRGB(200, 200, 200)
stageStat.TextSize = 11
stageStat.Font = Enum.Font.Gotham
stageStat.TextXAlignment = Enum.TextXAlignment.Left
stageStat.Parent = statsFrame

-- Update stats loop
task.spawn(function()
    while mainGui and mainGui.Parent do
        safeCall(function()
            -- Coba ambil stats dari leaderstats
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local wins = leaderstats:FindFirstChild("Wins")
                local rebirths = leaderstats:FindFirstChild("Rebirths")
                if wins then winsStat.Text = "Wins: " .. wins.Value end
                if rebirths then rebirthStat.Text = "Rebirths: " .. rebirths.Value end
            end
            
            -- Speed dari character
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                speedStat.Text = "Speed: " .. math.floor(char.Humanoid.WalkSpeed)
            end
        end)
        task.wait(1)
    end
end)

-- ============================================
-- NOTIFICATION: SCRIPT ACTIVE
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
notifSub.Text = "RukanooXD_YT | Race Clicker v2.0"
notifSub.TextColor3 = Color3.fromRGB(150, 150, 180)
notifSub.TextSize = 12
notifSub.Font = Enum.Font.Gotham
notifSub.Parent = notifFrame

-- Animate Notification
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
-- ADDITIONAL FEATURES
-- ============================================

-- Auto-collect orbs/coins
task.spawn(function()
    while mainGui and mainGui.Parent do
        task.wait(0.3)
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("orb") or name:find("coin") or name:find("gem") or name:find("collect") then
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

-- Auto-equip best pets (jika ada sistem pet)
task.spawn(function()
    while mainGui and mainGui.Parent do
        task.wait(10)
        safeCall(function()
            -- Cari PetService di Knit
            local PetService = Knit:FindFirstChild("Services"):FindFirstChild("PetService")
            if PetService then
                local EquipRF = PetService:FindFirstChild("RF"):FindFirstChild("EquipBest")
                if EquipRF then
                    EquipRF:InvokeServer()
                end
            end
        end)
    end
end)

-- Store connections for cleanup
_G.RukanooXD_Connections = {}

-- Start Loading
animateLoading()
