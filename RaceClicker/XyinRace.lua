-- ============================================
-- RACE CLICKER SCRIPT - BY RukanooXD_YT
-- Youtube.com/RukanooXD_YT
-- DEVELOPER TAG
-- ============================================

-- Loading Screen & Notification
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Anti-Detection (Basic)
local function antiKick()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then
                return warn("[NanoXyin] Kick blocked!")
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end
pcall(antiKick)

-- ============================================
-- LOADING SCREEN WITH PROGRESS BAR
-- ============================================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "RukanooXD_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = playerGui

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 400, 0, 200)
loadingFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = loadingGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = loadingFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RukanooXD_YT SCRIPT"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 28
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = loadingFrame

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 30)
subtitleLabel.Position = UDim2.new(0, 0, 0, 70)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Race Clicker - 2026 Edition"
subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitleLabel.TextSize = 16
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Parent = loadingFrame

-- Progress Bar Background
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 320, 0, 12)
progressBg.Position = UDim2.new(0.5, -160, 0, 120)
progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
progressBg.BorderSizePixel = 0
progressBg.Parent = loadingFrame

local progressBgCorner = Instance.new("UICorner")
progressBgCorner.CornerRadius = UDim.new(1, 0)
progressBgCorner.Parent = progressBg

-- Progress Bar Fill
local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progressFill

-- Progress Text
local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 25)
progressText.Position = UDim2.new(0, 0, 0, 145)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(0, 255, 150)
progressText.TextSize = 18
progressText.Font = Enum.Font.GothamBold
progressText.Parent = loadingFrame

-- Loading Animation
local function animateLoading()
    for i = 0, 100, 2 do
        progressFill.Size = UDim2.new(i/100, 0, 1, 0)
        progressText.Text = tostring(i) .. "%"
        task.wait(0.03)
    end
    task.wait(0.5)
    TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    for _, child in pairs(loadingFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        end
    end
    task.wait(0.6)
    loadingGui:Destroy()
end

-- ============================================
-- MAIN UI - NEW STYLE 2026
-- ============================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RukanooXD_Main"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Gradient Background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 28))
})
gradient.Rotation = 90
gradient.Parent = mainFrame

-- Glow Effect
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 40, 1, 40)
glow.Position = UDim2.new(0, -20, 0, -20)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891979"
glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
glow.ImageTransparency = 0.85
glow.ZIndex = 0
glow.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 16)
titleBarCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.15, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "RACE CLICKER 2026"
titleText.TextColor3 = Color3.fromRGB(0, 255, 150)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- Developer Tag
local devTag = Instance.new("TextLabel")
devTag.Size = UDim2.new(1, 0, 0, 20)
devTag.Position = UDim2.new(0, 0, 0, 45)
devTag.BackgroundTransparency = 1
devTag.Text = "Youtube.com/RukanooXD_YT"
devTag.TextColor3 = Color3.fromRGB(100, 100, 150)
devTag.TextSize = 11
devTag.Font = Enum.Font.Gotham
devTag.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainGui:Destroy()
    -- Stop all loops
    if _G.speedLoop then _G.speedLoop:Disconnect() end
    if _G.clickLoop then _G.clickLoop:Disconnect() end
    if _G.rebirthLoop then _G.rebirthLoop:Disconnect() end
end)

-- Drag Function
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
-- SECTION: MAIN MENU
-- ============================================
local mainSection = Instance.new("Frame")
mainSection.Size = UDim2.new(1, -20, 0, 180)
mainSection.Position = UDim2.new(0, 10, 0, 70)
mainSection.BackgroundTransparency = 1
mainSection.Parent = mainFrame

local sectionTitle1 = Instance.new("TextLabel")
sectionTitle1.Size = UDim2.new(1, 0, 0, 25)
sectionTitle1.BackgroundTransparency = 1
sectionTitle1.Text = "MAIN MENU"
sectionTitle1.TextColor3 = Color3.fromRGB(0, 255, 150)
sectionTitle1.TextSize = 16
sectionTitle1.Font = Enum.Font.GothamBold
sectionTitle1.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle1.Parent = mainSection

-- Speed Hack Toggle
local speedToggle = Instance.new("Frame")
speedToggle.Size = UDim2.new(1, 0, 0, 50)
speedToggle.Position = UDim2.new(0, 0, 0, 30)
speedToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
speedToggle.BorderSizePixel = 0
speedToggle.Parent = mainSection

local speedToggleCorner = Instance.new("UICorner")
speedToggleCorner.CornerRadius = UDim.new(0, 10)
speedToggleCorner.Parent = speedToggle

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.6, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 15, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed Hack (Max 999M)"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedToggle

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, 70, 0, 30)
speedBtn.Position = UDim2.new(1, -85, 0.5, -15)
speedBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
speedBtn.Text = "OFF"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextSize = 14
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Parent = speedToggle

local speedBtnCorner = Instance.new("UICorner")
speedBtnCorner.CornerRadius = UDim.new(0, 8)
speedBtnCorner.Parent = speedBtn

-- Speed Visual Line
local speedLine = Instance.new("Frame")
speedLine.Size = UDim2.new(0, 2, 0, 0)
speedLine.Position = UDim2.new(0.5, 0, 0.5, 0)
speedLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
speedLine.BorderSizePixel = 0
speedLine.Visible = false
speedLine.Parent = mainFrame

local speedLineGlow = Instance.new("UIGradient")
speedLineGlow.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150), Color3.fromRGB(0, 200, 100))
speedLineGlow.Parent = speedLine

-- Speed Hack Logic
local speedEnabled = false
_G.speedLoop = nil

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        speedBtn.Text = "ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        speedLine.Visible = true
        
        -- Visual Line Animation
        TweenService:Create(speedLine, TweenInfo.new(0.5), {Size = UDim2.new(0, 2, 0, 100)}):Play()
        
        -- Speed Hack Loop
        _G.speedLoop = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                -- Set max speed to 999M (999,000,000)
                char.Humanoid.WalkSpeed = 999000000
                -- Visual line follows player
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    speedLine.Position = UDim2.new(0, 0, 0, root.Position.Y)
                end
            end
        end)
    else
        speedBtn.Text = "OFF"
        speedBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        speedLine.Visible = false
        TweenService:Create(speedLine, TweenInfo.new(0.3), {Size = UDim2.new(0, 2, 0, 0)}):Play()
        if _G.speedLoop then
            _G.speedLoop:Disconnect()
            _G.speedLoop = nil
        end
        -- Reset speed
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end
end)

-- Auto Click 15x Fast
local clickToggle = Instance.new("Frame")
clickToggle.Size = UDim2.new(1, 0, 0, 50)
clickToggle.Position = UDim2.new(0, 0, 0, 90)
clickToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
clickToggle.BorderSizePixel = 0
clickToggle.Parent = mainSection

local clickToggleCorner = Instance.new("UICorner")
clickToggleCorner.CornerRadius = UDim.new(0, 10)
clickToggleCorner.Parent = clickToggle

local clickLabel = Instance.new("TextLabel")
clickLabel.Size = UDim2.new(0.6, 0, 1, 0)
clickLabel.Position = UDim2.new(0, 15, 0, 0)
clickLabel.BackgroundTransparency = 1
clickLabel.Text = "Auto Click 15x Fast"
clickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
clickLabel.TextSize = 14
clickLabel.Font = Enum.Font.Gotham
clickLabel.TextXAlignment = Enum.TextXAlignment.Left
clickLabel.Parent = clickToggle

local clickBtn = Instance.new("TextButton")
clickBtn.Size = UDim2.new(0, 70, 0, 30)
clickBtn.Position = UDim2.new(1, -85, 0.5, -15)
clickBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
clickBtn.Text = "OFF"
clickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickBtn.TextSize = 14
clickBtn.Font = Enum.Font.GothamBold
clickBtn.Parent = clickToggle

local clickBtnCorner = Instance.new("UICorner")
clickBtnCorner.CornerRadius = UDim.new(0, 8)
clickBtnCorner.Parent = clickBtn

-- Auto Click Logic - NO SCREEN DISTURBANCE
local clickEnabled = false
_G.clickLoop = nil

clickBtn.MouseButton1Click:Connect(function()
    clickEnabled = not clickEnabled
    if clickEnabled then
        clickBtn.Text = "ON"
        clickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Auto Click 15x Fast - Background Click (No Screen Disturbance)
        _G.clickLoop = task.spawn(function()
            while clickEnabled do
                -- Find click remote or simulate clicks
                local remotes = ReplicatedStorage:GetDescendants()
                for _, remote in pairs(remotes) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():find("click") or remote.Name:lower():find("speed") or remote.Name:lower():find("tap")) then
                        for i = 1, 15 do
                            pcall(function()
                                remote:FireServer()
                            end)
                        end
                    end
                end
                
                -- Alternative: Simulate mouse clicks without disturbing screen
                -- Using virtual input that doesn't show on screen
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    for i = 1, 15 do
                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end)
                
                task.wait(0.05) -- 15x per 0.05s = very fast
            end
        end)
    else
        clickBtn.Text = "OFF"
        clickBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        clickEnabled = false
    end
end)

-- ============================================
-- SECTION: REBIRTH MENU
-- ============================================
local rebirthSection = Instance.new("Frame")
rebirthSection.Size = UDim2.new(1, -20, 0, 100)
rebirthSection.Position = UDim2.new(0, 10, 0, 260)
rebirthSection.BackgroundTransparency = 1
rebirthSection.Parent = mainFrame

local sectionTitle2 = Instance.new("TextLabel")
sectionTitle2.Size = UDim2.new(1, 0, 0, 25)
sectionTitle2.BackgroundTransparency = 1
sectionTitle2.Text = "REBIRTH MENU"
sectionTitle2.TextColor3 = Color3.fromRGB(255, 100, 100)
sectionTitle2.TextSize = 16
sectionTitle2.Font = Enum.Font.GothamBold
sectionTitle2.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle2.Parent = rebirthSection

-- Auto Rebirth Toggle
local rebirthToggle = Instance.new("Frame")
rebirthToggle.Size = UDim2.new(1, 0, 0, 50)
rebirthToggle.Position = UDim2.new(0, 0, 0, 30)
rebirthToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
rebirthToggle.BorderSizePixel = 0
rebirthToggle.Parent = rebirthSection

local rebirthToggleCorner = Instance.new("UICorner")
rebirthToggleCorner.CornerRadius = UDim.new(0, 10)
rebirthToggleCorner.Parent = rebirthToggle

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Size = UDim2.new(0.6, 0, 1, 0)
rebirthLabel.Position = UDim2.new(0, 15, 0, 0)
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.Text = "Auto Rebirth"
rebirthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthLabel.TextSize = 14
rebirthLabel.Font = Enum.Font.Gotham
rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
rebirthLabel.Parent = rebirthToggle

local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Size = UDim2.new(0, 70, 0, 30)
rebirthBtn.Position = UDim2.new(1, -85, 0.5, -15)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
rebirthBtn.Text = "OFF"
rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthBtn.TextSize = 14
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.Parent = rebirthToggle

local rebirthBtnCorner = Instance.new("UICorner")
rebirthBtnCorner.CornerRadius = UDim.new(0, 8)
rebirthBtnCorner.Parent = rebirthBtn

-- Visual Indicator for Rebirth
local rebirthIndicator = Instance.new("Frame")
rebirthIndicator.Size = UDim2.new(0, 10, 0, 10)
rebirthIndicator.Position = UDim2.new(0, 5, 0.5, -5)
rebirthIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red = OFF
rebirthIndicator.BorderSizePixel = 0
rebirthIndicator.Parent = rebirthToggle

local rebirthIndicatorCorner = Instance.new("UICorner")
rebirthIndicatorCorner.CornerRadius = UDim.new(1, 0)
rebirthIndicatorCorner.Parent = rebirthIndicator

-- Auto Rebirth Logic
local rebirthEnabled = false
_G.rebirthLoop = nil

rebirthBtn.MouseButton1Click:Connect(function()
    rebirthEnabled = not rebirthEnabled
    if rebirthEnabled then
        rebirthBtn.Text = "ON"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        rebirthIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 100) -- Green = ON
        
        -- Auto Rebirth Loop
        _G.rebirthLoop = task.spawn(function()
            while rebirthEnabled do
                -- Find rebirth remote
                local remotes = ReplicatedStorage:GetDescendants()
                for _, remote in pairs(remotes) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():find("rebirth") or remote.Name:lower():find("reset")) then
                        pcall(function()
                            remote:FireServer()
                        end)
                    end
                    if remote:IsA("RemoteFunction") and (remote.Name:lower():find("rebirth") or remote.Name:lower():find("reset")) then
                        pcall(function()
                            remote:InvokeServer()
                        end)
                    end
                end
                
                -- Alternative: Check for rebirth button in UI
                pcall(function()
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if gui:IsA("TextButton") and (gui.Text:lower():find("rebirth") or gui.Text:lower():find("prestige")) then
                            -- Simulate click without visual disturbance
                            local vim = game:GetService("VirtualInputManager")
                            local pos = gui.AbsolutePosition
                            vim:SendMouseButtonEvent(pos.X + gui.AbsoluteSize.X/2, pos.Y + gui.AbsoluteSize.Y/2, 0, true, game, 0)
                            vim:SendMouseButtonEvent(pos.X + gui.AbsoluteSize.X/2, pos.Y + gui.AbsoluteSize.Y/2, 0, false, game, 0)
                        end
                    end
                end)
                
                task.wait(1) -- Check every 1 second
            end
        end)
    else
        rebirthBtn.Text = "OFF"
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        rebirthIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red = OFF
        rebirthEnabled = false
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
notifFrame.Size = UDim2.new(0, 300, 0, 60)
notifFrame.Position = UDim2.new(0.5, -150, 0, -80)
notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
notifFrame.BorderSizePixel = 0
notifFrame.Parent = notifGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 12)
notifCorner.Parent = notifFrame

local notifGlow = Instance.new("ImageLabel")
notifGlow.Size = UDim2.new(1, 30, 1, 30)
notifGlow.Position = UDim2.new(0, -15, 0, -15)
notifGlow.BackgroundTransparency = 1
notifGlow.Image = "rbxassetid://4996891979"
notifGlow.ImageColor3 = Color3.fromRGB(0, 255, 150)
notifGlow.ImageTransparency = 0.9
notifGlow.ZIndex = 0
notifGlow.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "SCRIPT ACTIVE - RukanooXD_YT"
notifText.TextColor3 = Color3.fromRGB(0, 255, 150)
notifText.TextSize = 18
notifText.Font = Enum.Font.GothamBold
notifText.Parent = notifFrame

-- Animate Notification
TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
task.wait(3)
TweenService:Create(notifFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, -80)}):Play()
task.wait(0.6)
notifGui:Destroy()

-- Start Loading Animation
animateLoading()

-- ============================================
-- ADDITIONAL FEATURES
-- ============================================

-- Auto-collect orbs/items if any
task.spawn(function()
    while true do
        task.wait(0.5)
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("orb") or obj.Name:lower():find("coin") or obj.Name:lower():find("gem")) then
                    pcall(function()
                        -- Check if collectible
                        if obj:FindFirstChildWhichIsA("TouchInterest") then
                            firetouchinterest(char.HumanoidRootPart, obj, 0)
                            firetouchinterest(char.HumanoidRootPart, obj, 1)
                        end
                    end)
                end
            end
        end
    end
end)

-- Anti-AFK
local antiAfk = Instance.new("Frame")
antiAfk.Size = UDim2.new(0, 0, 0, 0)
antiAfk.Position = UDim2.new(0, 0, 0, 0)
antiAfk.Parent = playerGui

local connection
connection = player.Idled:Connect(function()
    -- Prevent kick for being idle
    local vim = game:GetService("VirtualInputManager")
    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end)

print("[NanoXyin] Race Clicker Script Loaded Successfully!")
print("[NanoXyin] Developer: Youtube.com/RukanooXD_YT")
print("[NanoXyin] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")
