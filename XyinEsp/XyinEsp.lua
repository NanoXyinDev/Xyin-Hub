-- ============================================
-- N4n0Xy1n ESP Pl4y3r - Pr1nt F0r S33k Styl3
-- F34tur3s: L1n3 ESP, B0x ESP, T0ggl3 M3nu
-- L4ngu4g3: L4u + 3ngl15h + J4p4n353 + Ru5514n
-- ============================================

-- S3rv1c3s
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- S3TT1NGS (4LL F4L53 BY D3F4ULT)
-- ============================================
local Settings = {
    ESP_Enabled = false,           -- M4in t0ggl3
    Line_ESP = false,              -- L1n3 t0ggl3
    Box_ESP = false,               -- B0x t0ggl3
    Name_ESP = false,              -- N4m3 t0ggl3
    Distance_ESP = false,          -- D15t4nc3 t0ggl3
    Health_ESP = false,            -- H34lth t0ggl3
    TeamCheck = false,             -- T34m ch3ck t0ggl3
    MaxDistance = 1000,            -- M4x d15t4nc3 3SP
    BoxType = "2D",                -- "2D" 0r "3D" b0x
    LineOrigin = "Bottom",         -- "Bottom", "Center", "Top"
    TextSize = 13,
    LineThickness = 1,
    BoxThickness = 1,
    -- C0l0r5
    LineColor = Color3.fromRGB(0, 255, 255),      -- Cy4n
    BoxColor = Color3.fromRGB(255, 0, 255),       -- M4g3nt4
    NameColor = Color3.fromRGB(255, 255, 255),    -- Wh1t3
    HealthColor = Color3.fromRGB(0, 255, 0),      -- Gr33n
    DistanceColor = Color3.fromRGB(255, 255, 0),    -- Y3ll0w
}

-- ============================================
-- DR4W1NG 0BJ3CT5 M4N4G3R
-- ============================================
local ESPObjects = {}

local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        pcall(function()
            drawing[property] = value
        end)
    end
    return drawing
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj then
                pcall(function() obj:Remove() end)
            end
        end
        ESPObjects[player] = nil
    end
end

local function CreateESPObjects(player)
    if ESPObjects[player] then
        RemoveESP(player)
    end
    
    ESPObjects[player] = {
        Line = CreateDrawing("Line", {
            Thickness = Settings.LineThickness,
            Color = Settings.LineColor,
            Transparency = 1,
            Visible = false,
            ZIndex = 1
        }),
        Box = CreateDrawing("Square", {
            Thickness = Settings.BoxThickness,
            Color = Settings.BoxColor,
            Transparency = 1,
            Filled = false,
            Visible = false,
            ZIndex = 2
        }),
        BoxFilled = CreateDrawing("Square", {
            Thickness = 1,
            Color = Settings.BoxColor,
            Transparency = 0.2,
            Filled = true,
            Visible = false,
            ZIndex = 1
        }),
        Name = CreateDrawing("Text", {
            Text = "",
            Size = Settings.TextSize,
            Center = true,
            Outline = true,
            Color = Settings.NameColor,
            Transparency = 1,
            Visible = false,
            ZIndex = 3
        }),
        Distance = CreateDrawing("Text", {
            Text = "",
            Size = Settings.TextSize,
            Center = true,
            Outline = true,
            Color = Settings.DistanceColor,
            Transparency = 1,
            Visible = false,
            ZIndex = 3
        }),
        Health = CreateDrawing("Text", {
            Text = "",
            Size = Settings.TextSize,
            Center = true,
            Outline = true,
            Color = Settings.HealthColor,
            Transparency = 1,
            Visible = false,
            ZIndex = 3
        }),
        HealthBar = CreateDrawing("Line", {
            Thickness = 2,
            Color = Settings.HealthColor,
            Transparency = 1,
            Visible = false,
            ZIndex = 4
        }),
        HealthBarBG = CreateDrawing("Line", {
            Thickness = 4,
            Color = Color3.fromRGB(50, 50, 50),
            Transparency = 1,
            Visible = false,
            ZIndex = 3
        })
    }
end

-- ============================================
-- 3SP L0G1C - W0RLD T0 V13WPORT
-- ============================================
local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function GetBoundingBox(character)
    local hrp = GetRootPart(character)
    if not hrp then return nil end
    
    local cf, size = character:GetBoundingBox()
    return cf, size
end

local function UpdateESP()
    if not Settings.ESP_Enabled then
        for player, objects in pairs(ESPObjects) do
            for _, obj in pairs(objects) do
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = GetCharacter(player)
        if not character then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    pcall(function() obj.Visible = false end)
                end
            end
            continue
        end
        
        local humanoid = GetHumanoid(character)
        local rootPart = GetRootPart(character)
        
        if not humanoid or not rootPart then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    pcall(function() obj.Visible = false end)
                end
            end
            continue
        end
        
        -- T34m ch3ck
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    pcall(function() obj.Visible = false end)
                end
            end
            continue
        end
        
        -- D15t4nc3 ch3ck
        local localHRP = GetRootPart(GetCharacter(LocalPlayer))
        if localHRP then
            local distance = (rootPart.Position - localHRP.Position).Magnitude
            if distance > Settings.MaxDistance then
                if ESPObjects[player] then
                    for _, obj in pairs(ESPObjects[player]) do
                        pcall(function() obj.Visible = false end)
                    end
                end
                continue
            end
        end
        
        -- W0rld t0 V13wP0rt
        local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
        if not rootVisible then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    pcall(function() obj.Visible = false end)
                end
            end
            continue
        end
        
        -- Cr34t3 0bj3ct5 1f n0t 3x15t
        if not ESPObjects[player] then
            CreateESPObjects(player)
        end
        
        local objects = ESPObjects[player]
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthPercent = health / maxHealth
        
        -- G3t b0und1ng b0x
        local cf, size = GetBoundingBox(character)
        if not cf then
            for _, obj in pairs(objects) do
                pcall(function() obj.Visible = false end)
            end
            continue
        end
        
        -- C4lcul4t3 2D b0x c0rn3r5
        local topY = cf.Position.Y + (size.Y / 2)
        local bottomY = cf.Position.Y - (size.Y / 2)
        local leftX = cf.Position.X - (size.X / 2)
        local rightX = cf.Position.X + (size.X / 2)
        
        local topPos = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, topY, cf.Position.Z))
        local bottomPos = Camera:WorldToViewportPoint(Vector3.new(cf.Position.X, bottomY, cf.Position.Z))
        local leftPos = Camera:WorldToViewportPoint(Vector3.new(leftX, cf.Position.Y, cf.Position.Z))
        local rightPos = Camera:WorldToViewportPoint(Vector3.new(rightX, cf.Position.Y, cf.Position.Z))
        
        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
        local boxWidth = math.abs(rightPos.X - leftPos.X)
        
        -- ========== L1N3 3SP ==========
        if Settings.Line_ESP and objects.Line then
            local lineOrigin
            if Settings.LineOrigin == "Bottom" then
                lineOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Settings.LineOrigin == "Top" then
                lineOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
            else -- Center
                lineOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end
            
            objects.Line.From = lineOrigin
            objects.Line.To = Vector2.new(rootPos.X, rootPos.Y)
            objects.Line.Color = Settings.LineColor
            objects.Line.Thickness = Settings.LineThickness
            objects.Line.Visible = true
        elseif objects.Line then
            objects.Line.Visible = false
        end
        
        -- ========== B0X 3SP ==========
        if Settings.Box_ESP and objects.Box and objects.BoxFilled then
            local boxX = rootPos.X - (boxWidth / 2)
            local boxY = topPos.Y
            
            objects.Box.Size = Vector2.new(boxWidth, boxHeight)
            objects.Box.Position = Vector2.new(boxX, boxY)
            objects.Box.Color = Settings.BoxColor
            objects.Box.Thickness = Settings.BoxThickness
            objects.Box.Visible = true
            
            objects.BoxFilled.Size = Vector2.new(boxWidth, boxHeight)
            objects.BoxFilled.Position = Vector2.new(boxX, boxY)
            objects.BoxFilled.Color = Settings.BoxColor
            objects.BoxFilled.Visible = true
        else
            if objects.Box then objects.Box.Visible = false end
            if objects.BoxFilled then objects.BoxFilled.Visible = false end
        end
        
        -- ========== N4M3 3SP ==========
        if Settings.Name_ESP and objects.Name then
            objects.Name.Text = player.Name
            objects.Name.Position = Vector2.new(rootPos.X, topPos.Y - 15)
            objects.Name.Color = Settings.NameColor
            objects.Name.Size = Settings.TextSize
            objects.Name.Visible = true
        elseif objects.Name then
            objects.Name.Visible = false
        end
        
        -- ========== D15T4NC3 3SP ==========
        if Settings.Distance_ESP and objects.Distance and localHRP then
            local dist = math.floor((rootPart.Position - localHRP.Position).Magnitude)
            objects.Distance.Text = tostring(dist) .. "m"
            objects.Distance.Position = Vector2.new(rootPos.X, bottomPos.Y + 5)
            objects.Distance.Color = Settings.DistanceColor
            objects.Distance.Size = Settings.TextSize
            objects.Distance.Visible = true
        elseif objects.Distance then
            objects.Distance.Visible = false
        end
        
        -- ========== H34LTH 3SP ==========
        if Settings.Health_ESP and objects.Health and objects.HealthBar and objects.HealthBarBG then
            -- H34lth t3xt
            objects.Health.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
            objects.Health.Position = Vector2.new(rootPos.X, bottomPos.Y + 20)
            objects.Health.Color = Settings.HealthColor
            objects.Health.Size = Settings.TextSize
            objects.Health.Visible = true
            
            -- H34lth b4r
            local barX = rootPos.X - (boxWidth / 2) - 6
            local barTop = topPos.Y
            local barBottom = bottomPos.Y
            
            objects.HealthBarBG.From = Vector2.new(barX, barTop)
            objects.HealthBarBG.To = Vector2.new(barX, barBottom)
            objects.HealthBarBG.Visible = true
            
            local healthHeight = boxHeight * healthPercent
            objects.HealthBar.From = Vector2.new(barX, barBottom - healthHeight)
            objects.HealthBar.To = Vector2.new(barX, barBottom)
            
            -- C0l0r b4s3d 0n h34lth
            if healthPercent > 0.6 then
                objects.HealthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then
                objects.HealthBar.Color = Color3.fromRGB(255, 255, 0)
            else
                objects.HealthBar.Color = Color3.fromRGB(255, 0, 0)
            end
            objects.HealthBar.Visible = true
        else
            if objects.Health then objects.Health.Visible = false end
            if objects.HealthBar then objects.HealthBar.Visible = false end
            if objects.HealthBarBG then objects.HealthBarBG.Visible = false end
        end
    end
end

-- ============================================
-- PL4Y3R 3V3NT H4NDL3R5
-- ============================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        -- W41t f0r ch4r4ct3r t0 l04d
        task.wait(1)
        CreateESPObjects(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- 1n1t14l1z3 3x15t1ng pl4y3r5
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESPObjects(player)
        if player.Character then
            task.wait(0.1)
        end
    end
end

-- ============================================
-- R3ND3R L00P
-- ============================================
local ESPConnection = RunService.RenderStepped:Connect(UpdateESP)

-- ============================================
-- M3NU UI - T0GGL3 M3NU SYST3M
-- ============================================

-- Pr0t3ct fr0m 1nsp3ct 4nd d3t3ct10n
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NX_" .. tostring(math.random(100000, 999999))
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- M41n fr4m3 (h1dd3n by d3f4ult)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 280, 0, 400)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- C0rn3r r0und1ng
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Sh4d0w
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- T1tl3 b4r
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 5, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "N4n0Xy1n ESP // プレイヤーESP // Игрок ESP"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Cl0s3 butt0n
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Scr0ll1ng fr4m3
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "Scroll"
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- ============================================
-- T0GGL3 BUTT0N CR34T0R
-- ============================================
local function CreateToggle(parent, text, settingKey, color)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "_Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "Toggle"
    ToggleBtn.Size = UDim2.new(0, 50, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleBtn.TextSize = 11
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 11)
    ToggleBtnCorner.Parent = ToggleBtn
    
    local function UpdateToggle()
        if Settings[settingKey] then
            ToggleBtn.BackgroundColor3 = color or Color3.fromRGB(0, 255, 150)
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        UpdateToggle()
    end)
    
    UpdateToggle()
    ToggleFrame.Parent = parent
    return ToggleFrame
end

-- ============================================
-- CR34T3 T0GGL3S
-- ============================================
CreateToggle(ScrollFrame, "🎯 ESP Master", "ESP_Enabled", Color3.fromRGB(0, 255, 255))
CreateToggle(ScrollFrame, "📏 Line ESP", "Line_ESP", Color3.fromRGB(0, 200, 255))
CreateToggle(ScrollFrame, "📦 Box ESP", "Box_ESP", Color3.fromRGB(255, 0, 255))
CreateToggle(ScrollFrame, "👤 Name ESP", "Name_ESP", Color3.fromRGB(255, 255, 255))
CreateToggle(ScrollFrame, "📍 Distance ESP", "Distance_ESP", Color3.fromRGB(255, 255, 0))
CreateToggle(ScrollFrame, "❤️ Health ESP", "Health_ESP", Color3.fromRGB(0, 255, 100))
CreateToggle(ScrollFrame, "🛡️ Team Check", "TeamCheck", Color3.fromRGB(255, 100, 100))

-- S3p4r4t0r
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, 0, 0, 2)
Separator.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Separator.BorderSizePixel = 0
Separator.Parent = ScrollFrame

-- L1n3 0r1g1n s3l3ct0r
local LineOriginLabel = Instance.new("TextLabel")
LineOriginLabel.Size = UDim2.new(1, 0, 0, 25)
LineOriginLabel.BackgroundTransparency = 1
LineOriginLabel.Text = "Line Origin: Bottom"
LineOriginLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
LineOriginLabel.TextSize = 12
LineOriginLabel.Font = Enum.Font.Gotham
LineOriginLabel.Parent = ScrollFrame

local LineOriginBtn = Instance.new("TextButton")
LineOriginBtn.Size = UDim2.new(1, 0, 0, 30)
LineOriginBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
LineOriginBtn.Text = "Switch Origin"
LineOriginBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
LineOriginBtn.TextSize = 12
LineOriginBtn.Font = Enum.Font.GothamBold
LineOriginBtn.Parent = ScrollFrame

local LineOriginCorner = Instance.new("UICorner")
LineOriginCorner.CornerRadius = UDim.new(0, 6)
LineOriginCorner.Parent = LineOriginBtn

LineOriginBtn.MouseButton1Click:Connect(function()
    if Settings.LineOrigin == "Bottom" then
        Settings.LineOrigin = "Center"
        LineOriginLabel.Text = "Line Origin: Center"
    elseif Settings.LineOrigin == "Center" then
        Settings.LineOrigin = "Top"
        LineOriginLabel.Text = "Line Origin: Top"
    else
        Settings.LineOrigin = "Bottom"
        LineOriginLabel.Text = "Line Origin: Bottom"
    end
end)

-- M4x D15t4nc3
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(1, 0, 0, 25)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Max Distance: 1000m"
DistLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
DistLabel.TextSize = 12
DistLabel.Font = Enum.Font.Gotham
DistLabel.Parent = ScrollFrame

local DistSlider = Instance.new("TextBox")
DistSlider.Size = UDim2.new(1, 0, 0, 30)
DistSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
DistSlider.Text = "1000"
DistSlider.TextColor3 = Color3.fromRGB(200, 200, 200)
DistSlider.TextSize = 12
DistSlider.Font = Enum.Font.GothamBold
DistSlider.ClearTextOnFocus = true
DistSlider.Parent = ScrollFrame

local DistSliderCorner = Instance.new("UICorner")
DistSliderCorner.CornerRadius = UDim.new(0, 6)
DistSliderCorner.Parent = DistSlider

DistSlider.FocusLost:Connect(function()
    local num = tonumber(DistSlider.Text)
    if num then
        Settings.MaxDistance = math.clamp(num, 50, 5000)
        DistLabel.Text = "Max Distance: " .. Settings.MaxDistance .. "m"
    end
    DistSlider.Text = tostring(Settings.MaxDistance)
end)

-- ============================================
-- T0GGL3 M3NU BUTT0N (Sm4ll b0x 0uts1d3)
-- ============================================
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Name = "MenuToggle"
ToggleMenuBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleMenuBtn.Position = UDim2.new(0, 20, 0.5, -22)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
ToggleMenuBtn.Text = "📦"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleMenuBtn.TextSize = 20
ToggleMenuBtn.Font = Enum.Font.GothamBold
ToggleMenuBtn.Parent = ScreenGui

local MenuBtnCorner = Instance.new("UICorner")
MenuBtnCorner.CornerRadius = UDim.new(0, 10)
MenuBtnCorner.Parent = ToggleMenuBtn

local MenuBtnStroke = Instance.new("UIStroke")
MenuBtnStroke.Color = Color3.fromRGB(0, 255, 255)
MenuBtnStroke.Thickness = 2
MenuBtnStroke.Parent = ToggleMenuBtn

-- T0ggl3 m3nu v151b1l1ty
ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    else
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    end
end)

-- Cl0s3 butt0n
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
end)

-- K3yb04rd sh0rtcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- R1ght 4lt t0 t0ggl3 m3nu
    if input.KeyCode == Enum.KeyCode.RightAlt then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        else
            ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        end
    end
    
    -- 1ns3rt t0 t0ggl3 3SP qu1ck
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.ESP_Enabled = not Settings.ESP_Enabled
        -- Upd4t3 t0ggl3 v15u4l5
        for _, child in pairs(ScrollFrame:GetChildren()) do
            if child.Name == "🎯 ESP Master_Toggle" then
                local btn = child:FindFirstChild("Toggle")
                if btn then
                    if Settings.ESP_Enabled then
                        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                        btn.Text = "ON"
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                        btn.Text = "OFF"
                        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 4NT1-1N5P3CT & 4NT1-D3T3CT10N
-- ============================================

-- H1d3 fr0m g4m3 d3t3ct10n
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FindFirstChild" or method == "WaitForChild" then
                local args = {...}
                if args[1] and (args[1]:match("ESP") or args[1]:match("NanoXyin")) then
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

-- H1d3 fr0m 1nsp3ct 3l3m3nt sp1ff3r
pcall(function()
    for _, v in pairs(ScreenGui:GetDescendants()) do
        v.Archivable = false
    end
end)

-- ============================================
-- N0T1F1C4T10N 0N L04D
-- ============================================
local NotifFrame = Instance.new("Frame")
NotifFrame.Size = UDim2.new(0, 300, 0, 50)
NotifFrame.Position = UDim2.new(0.5, -150, 0, -60)
NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
NotifFrame.BorderSizePixel = 0
NotifFrame.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 8)
NotifCorner.Parent = NotifFrame

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Color3.fromRGB(0, 255, 255)
NotifStroke.Thickness = 1
NotifStroke.Parent = NotifFrame

local NotifText = Instance.new("TextLabel")
NotifText.Size = UDim2.new(1, -20, 1, 0)
NotifText.Position = UDim2.new(0, 10, 0, 0)
NotifText.BackgroundTransparency = 1
NotifText.Text = "N4n0Xy1n ESP L04D3D // ロード完了 // Загружено\nR1ghtAlt: M3nu | 1ns3rt: Qu1ck T0ggl3"
NotifText.TextColor3 = Color3.fromRGB(0, 255, 255)
NotifText.TextSize = 12
NotifText.Font = Enum.Font.Gotham
NotifText.Parent = NotifFrame

-- Sl1d3 1n
NotifFrame:TweenPosition(UDim2.new(0.5, -150, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5)

-- Sl1d3 0ut 4ft3r 3 s3c
task.delay(3, function()
    NotifFrame:TweenPosition(UDim2.new(0.5, -150, 0, -60), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5)
    task.wait(0.6)
    NotifFrame:Destroy()
end)

-- ============================================
-- CL34NUP 0N D34TH
-- ============================================
LocalPlayer.CharacterRemoving:Connect(function()
    -- 3SP 0bj3ct5 p3r515t, UI p3r515t
end)

-- ============================================
-- M0R53 C0D3: - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
-- ============================================
print("[N4n0Xy1n] ESP M0dul3 1n1t14l1z3d")
print("[N4n0Xy1n] - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")
print("[N4n0Xy1n] プレイヤーESPアクティブ")
print("[N4n0Xy1n] Игрок ESP активирован")
