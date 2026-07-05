-- ============================================
-- RACE CLICKER v4.0 - STEP BY STEP DEBUG
-- Youtube.com/RukanooXD_YT
-- ============================================

print("[Step 1] Script starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[Step 2] Services loaded")

-- ============================================
-- STEP 3: FIND REMOTES (with fallback)
-- ============================================
print("[Step 3] Finding remotes...")

local ClickRF = nil
local RebirthRF = nil
local RaceRF = nil

-- Try to find ClickService
local success, err = pcall(function()
    ClickRF = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Knit", 5):WaitForChild("Services", 5):WaitForChild("ClickService", 5):WaitForChild("RF", 5):WaitForChild("Click", 5)
end)
if success and ClickRF then
    print("[Step 3a] ClickRF found: " .. ClickRF:GetFullName())
else
    print("[Step 3a] ClickRF NOT found, error: " .. tostring(err))
    -- Fallback: search all remotes
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Click" then
            ClickRF = obj
            print("[Step 3a] ClickRF found via search: " .. obj:GetFullName())
            break
        end
    end
end

-- Try to find RebirthService
success, err = pcall(function()
    RebirthRF = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Knit", 5):WaitForChild("Services", 5):WaitForChild("RebirthService", 5):WaitForChild("RF", 5):WaitForChild("Rebirth", 5)
end)
if success and RebirthRF then
    print("[Step 3b] RebirthRF found: " .. RebirthRF:GetFullName())
else
    print("[Step 3b] RebirthRF NOT found, error: " .. tostring(err))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Rebirth" then
            RebirthRF = obj
            print("[Step 3b] RebirthRF found via search: " .. obj:GetFullName())
            break
        end
    end
end

-- Try to find RaceService
success, err = pcall(function()
    RaceRF = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Knit", 5):WaitForChild("Services", 5):WaitForChild("RaceService", 5):WaitForChild("RF", 5):WaitForChild("Race", 5)
end)
if success and RaceRF then
    print("[Step 3c] RaceRF found: " .. RaceRF:GetFullName())
else
    print("[Step 3c] RaceRF NOT found, error: " .. tostring(err))
    -- Try alternative names
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") and (obj.Name == "Race" or obj.Name == "FinishRace" or obj.Name == "CompleteRace") then
            RaceRF = obj
            print("[Step 3c] RaceRF found via search: " .. obj:GetFullName())
            break
        end
    end
end

-- Check if we have at least ClickRF
if not ClickRF then
    print("[ERROR] ClickRF not found! Script cannot continue.")
    print("[INFO] Available children in ReplicatedStorage:")
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    return -- Stop script
end

print("[Step 4] Remotes setup complete")

-- ============================================
-- STEP 5: CREATE MINIMAL UI
-- ============================================
print("[Step 5] Creating UI...")

local successUI, errUI = pcall(function()
    -- Destroy old UI if exists
    local oldGui = playerGui:FindFirstChild("RukanooXD_v4")
    if oldGui then oldGui:Destroy() end

    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "RukanooXD_v4"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = mainGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    title.Text = "RACE CLICKER v4.0"
    title.TextColor3 = Color3.fromRGB(0, 255, 150)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = title

    -- Dev tag
    local devTag = Instance.new("TextLabel")
    devTag.Size = UDim2.new(1, 0, 0, 20)
    devTag.Position = UDim2.new(0, 0, 0, 40)
    devTag.BackgroundTransparency = 1
    devTag.Text = "Youtube.com/RukanooXD_YT"
    devTag.TextColor3 = Color3.fromRGB(100, 100, 150)
    devTag.TextSize = 10
    devTag.Font = Enum.Font.Gotham
    devTag.Parent = mainFrame

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Toggle creator
    local function createToggle(y, text, colorOn)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -16, 0, 45)
        frame.Position = UDim2.new(0, 8, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        frame.BorderSizePixel = 0
        frame.Parent = mainFrame

        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0, 10)
        fc.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 26)
        btn.Position = UDim2.new(1, -72, 0.5, -13)
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        btn.Text = "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = frame

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = btn

        return btn
    end

    -- ============================================
    -- SPEED HACK
    -- ============================================
    local speedBtn = createToggle(70, "Speed Hack", Color3.fromRGB(0, 255, 100))
    local speedEnabled = false
    local speedThread = nil

    speedBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        if speedEnabled then
            speedBtn.Text = "ON"
            speedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            print("[Speed] ENABLED - Spamming ClickRF")
            
            speedThread = task.spawn(function()
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
            speedEnabled = false
            print("[Speed] DISABLED")
        end
    end)

    -- ============================================
    -- AUTO CLICK 15x
    -- ============================================
    local clickBtn = createToggle(122, "Auto Click 15x", Color3.fromRGB(0, 255, 100))
    local clickEnabled = false
    local clickThread = nil

    clickBtn.MouseButton1Click:Connect(function()
        clickEnabled = not clickEnabled
        if clickEnabled then
            clickBtn.Text = "ON"
            clickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            print("[Click] ENABLED")

            clickThread = task.spawn(function()
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
            clickEnabled = false
            print("[Click] DISABLED")
        end
    end)

    -- ============================================
    -- AUTO RACE
    -- ============================================
    local raceBtn = createToggle(174, "Auto Race", Color3.fromRGB(150, 0, 255))
    local raceEnabled = false
    local raceThread = nil

    raceBtn.MouseButton1Click:Connect(function()
        raceEnabled = not raceEnabled
        if raceEnabled then
            raceBtn.Text = "ON"
            raceBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            print("[Race] ENABLED")

            raceThread = task.spawn(function()
                while raceEnabled do
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        
                        -- Method 1: Find finish line
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local name = obj.Name:lower()
                                if name:find("finish") or name:find("goal") or name:find("end") or name:find("win") then
                                    pcall(function()
                                        hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                                    end)
                                    print("[Race] Teleported to: " .. obj.Name)
                                    break
                                end
                            end
                        end
                        
                        -- Method 2: Fire RaceRF
                        if RaceRF then
                            pcall(function()
                                RaceRF:InvokeServer()
                            end)
                            print("[Race] Fired RaceRF")
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            raceBtn.Text = "OFF"
            raceBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            raceEnabled = false
            print("[Race] DISABLED")
        end
    end)

    -- ============================================
    -- AUTO REBIRTH
    -- ============================================
    local rebirthBtn = createToggle(226, "Auto Rebirth", Color3.fromRGB(255, 100, 100))
    local rebirthEnabled = false
    local rebirthThread = nil

    rebirthBtn.MouseButton1Click:Connect(function()
        rebirthEnabled = not rebirthEnabled
        if rebirthEnabled then
            rebirthBtn.Text = "ON"
            rebirthBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            print("[Rebirth] ENABLED")

            if RebirthRF then
                rebirthThread = task.spawn(function()
                    while rebirthEnabled do
                        pcall(function()
                            RebirthRF:InvokeServer()
                        end)
                        task.wait(3)
                    end
                end)
            else
                print("[Rebirth] ERROR - RebirthRF not found")
                rebirthEnabled = false
                rebirthBtn.Text = "ERR"
                rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            end
        else
            rebirthBtn.Text = "OFF"
            rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            rebirthEnabled = false
            print("[Rebirth] DISABLED")
        end
    end)

    -- Status label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -16, 0, 20)
    status.Position = UDim2.new(0, 8, 0, 278)
    status.BackgroundTransparency = 1
    status.Text = "Status: Ready"
    status.TextColor3 = Color3.fromRGB(0, 255, 150)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = mainFrame

    -- Update status
    task.spawn(function()
        while mainGui and mainGui.Parent do
            local leaderstats = player:FindFirstChild("leaderstats")
            local wins = leaderstats and leaderstats:FindFirstChild("Wins")
            local rebirths = leaderstats and leaderstats:FindFirstChild("Rebirths")
            
            local winsText = wins and tostring(wins.Value) or "?"
            local rebirthText = rebirths and tostring(rebirths.Value) or "?"
            
            status.Text = "Wins: " .. winsText .. " | Rebirths: " .. rebirthText
            task.wait(1)
        end
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        speedEnabled = false
        clickEnabled = false
        raceEnabled = false
        rebirthEnabled = false
        mainGui:Destroy()
        print("[UI] Closed")
    end)

    -- Drag
    local dragging = false
    local dragStart, startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    title.InputChanged:Connect(function(input)
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

    print("[Step 6] UI created successfully")
end)

if not successUI then
    print("[ERROR] UI creation failed: " .. tostring(errUI))
    return
end

print("[Step 7] Script loaded! Check UI on screen.")
