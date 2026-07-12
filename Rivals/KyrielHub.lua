local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local KyrielHub = {
    Active = {},
    Connections = {},
    ESPObjects = {},
    AimbotEnabled = false,
    ESPEnabled = false,
    FullBright = false,
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InstantReload = false,
    InfiniteAmmo = false,
    NoFlash = false,
    NoScope = false,
    BunnyHop = false,
    AutoStrafe = false,
    TriggerBot = false,
    AutoHeal = false,
    AutoMedkit = false,
    WallCheck = true,
    TeamCheck = true,
    Smoothness = 0.15,
    FOV = 150,
    AimPart = "Head",
    DrawFOV = true,
    NotificationCount = 0,
    MaxPlayers = 16
}

local function Notify(text, dur)
    dur = dur or 2.5
    KyrielHub.NotificationCount = KyrielHub.NotificationCount + 1
    local notif = Instance.new("Frame")
    notif.Name = "KyrielNotif_" .. KyrielHub.NotificationCount
    notif.Size = UDim2.new(0, 260, 0, 50)
    notif.Position = UDim2.new(1, 20, 0, -60 + (KyrielHub.NotificationCount * 60))
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    notif.BorderSizePixel = 0
    notif.Parent = CoreGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notif
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(170, 0, 255)
    stroke.Thickness = 1.5
    stroke.Parent = notif
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -270, 0, 20 + ((KyrielHub.NotificationCount - 1) * 60))
    }):Play()
    
    task.delay(dur, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, notif.Position.Y.Offset)
        }):Play()
        task.wait(0.3)
        notif:Destroy()
        KyrielHub.NotificationCount = KyrielHub.NotificationCount - 1
    end)
end

local function CreateDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyrielHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("Frame")
ToggleBtn.Name = "ToggleBox"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(170, 0, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

local ToggleImage = Instance.new("TextLabel")
ToggleImage.Size = UDim2.new(1, 0, 1, 0)
ToggleImage.BackgroundTransparency = 1
ToggleImage.Text = "K"
ToggleImage.TextColor3 = Color3.fromRGB(170, 0, 255)
ToggleImage.Font = Enum.Font.GothamBlack
ToggleImage.TextSize = 24
ToggleImage.Parent = ToggleBtn

CreateDraggable(ToggleBtn)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(170, 0, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "Title"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "KYRIEL HUB  v2.0"
TitleText.TextColor3 = Color3.fromRGB(170, 0, 255)
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar

CreateDraggable(TitleBar)
CreateDraggable(MainFrame)

local TabHolder = Instance.new("Frame")
TabHolder.Name = "Tabs"
TabHolder.Size = UDim2.new(0, 140, 1, -35)
TabHolder.Position = UDim2.new(0, 0, 0, 35)
TabHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TabHolder.BorderSizePixel = 0
TabHolder.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 6)
TabCorner.Parent = TabHolder

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -140, 1, -35)
ContentFrame.Position = UDim2.new(0, 140, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Tabs = {"MAIN MENU", "PLAYER", "MISC"}
local TabContents = {}
local TabButtons = {}
local ActiveTab = "MAIN MENU"

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tabName
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 10 + ((i - 1) * 38))
    btn.BackgroundColor3 = tabName == "MAIN MENU" and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = TabHolder
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    TabButtons[tabName] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Name = tabName .. "_Content"
    content.Size = UDim2.new(1, -10, 1, -10)
    content.Position = UDim2.new(0, 5, 0, 5)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
    content.Visible = tabName == "MAIN MENU"
    content.Parent = ContentFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = content
    
    TabContents[tabName] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
        btn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
        for _, c in pairs(TabContents) do
            c.Visible = false
        end
        content.Visible = true
        ActiveTab = tabName
    end)
end

local function AddToggle(parent, name, flag, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -54, 0.5, -11)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = toggle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    KyrielHub.Active[flag] = false
    
    toggle.MouseButton1Click:Connect(function()
        KyrielHub.Active[flag] = not KyrielHub.Active[flag]
        local isOn = KyrielHub.Active[flag]
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = isOn and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(60, 60, 65)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = isOn and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        if callback then callback(isOn) end
        if isOn then
            Notify(name .. " Active", 2)
        else
            Notify(name .. " Off", 2)
        end
    end)
    
    return frame
end

local function AddSlider(parent, name, flag, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    KyrielHub.Active[flag] = default
    
    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (pos * (max - min)))
            KyrielHub.Active[flag] = val
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -7, 0.5, -7)
            label.Text = name .. ": " .. val
            if callback then callback(val) end
        end
    end)
    
    return frame
end

local function AddButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = true
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(130, 0, 200)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
        if callback then callback() end
    end)
    
    return btn
end

local function AddLabel(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function AddDivider(parent)
    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -10, 0, 1)
    div.Position = UDim2.new(0, 5, 0, 0)
    div.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    div.BorderSizePixel = 0
    div.Parent = parent
    return div
end

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 600, 0, 400)}):Play()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local mainContent = TabContents["MAIN MENU"]

AddLabel(mainContent, "STATUS CHECK", Color3.fromRGB(170, 0, 255))
AddDivider(mainContent)

local statusLabel = AddLabel(mainContent, "Scanning...", Color3.fromRGB(0, 255, 100))

AddDivider(mainContent)
AddLabel(mainContent, "GAME DETAILS", Color3.fromRGB(170, 0, 255))
AddDivider(mainContent)

local gameNameLabel = AddLabel(mainContent, "Game: RIVALS")
local gameCreatorLabel = AddLabel(mainContent, "Creator: Nosniy Games")
local gameModeLabel = AddLabel(mainContent, "Mode: Detecting...")
local playerCountLabel = AddLabel(mainContent, "Players: " .. #Players:GetPlayers() .. "/16")
local mapLabel = AddLabel(mainContent, "Map: Detecting...")
local teamLabel = AddLabel(mainContent, "Team: Detecting...")
local versionLabel = AddLabel(mainContent, "Version: Summer Update 2026")
local visitLabel = AddLabel(mainContent, "Visits: 16.3B+")

AddDivider(mainContent)
AddLabel(mainContent, "COMBAT", Color3.fromRGB(170, 0, 255))
AddDivider(mainContent)

AddToggle(mainContent, "Aimbot", "Aimbot", function(state)
    KyrielHub.AimbotEnabled = state
end)

AddToggle(mainContent, "ESP", "ESP", function(state)
    KyrielHub.ESPEnabled = state
    if not state then
        for _, obj in pairs(KyrielHub.ESPObjects) do
            if obj.Box then obj.Box:Remove() end
            if obj.Name then obj.Name:Remove() end
            if obj.HealthBar then obj.HealthBar:Remove() end
            if obj.Tracer then obj.Tracer:Remove() end
            if obj.Distance then obj.Distance:Remove() end
            if obj.Weapon then obj.Weapon:Remove() end
        end
        KyrielHub.ESPObjects = {}
    end
end)

AddToggle(mainContent, "Trigger Bot", "TriggerBot", function(state)
    KyrielHub.TriggerBot = state
end)

AddToggle(mainContent, "Wall Check", "WallCheck", function(state)
    KyrielHub.WallCheck = state
end)

AddToggle(mainContent, "Team Check", "TeamCheck", function(state)
    KyrielHub.TeamCheck = state
end)

AddDivider(mainContent)
AddLabel(mainContent, "VISUAL", Color3.fromRGB(170, 0, 255))
AddDivider(mainContent)

AddToggle(mainContent, "Full Bright", "FullBright", function(state)
    KyrielHub.FullBright = state
    if state then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end)

AddToggle(mainContent, "No Flash", "NoFlash", function(state)
    KyrielHub.NoFlash = state
end)

AddToggle(mainContent, "No Scope Overlay", "NoScope", function(state)
    KyrielHub.NoScope = state
end)

AddDivider(mainContent)
AddLabel(mainContent, "CONFIG", Color3.fromRGB(170, 0, 255))
AddDivider(mainContent)

AddSlider(mainContent, "FOV", "FOV", 30, 500, 150, function(val)
    KyrielHub.FOV = val
end)

AddSlider(mainContent, "Smooth", "Smooth", 0, 100, 15, function(val)
    KyrielHub.Smoothness = val / 100
end)

AddButton(mainContent, "Unload Script", function()
    for _, conn in pairs(KyrielHub.Connections) do
        if conn then conn:Disconnect() end
    end
    for _, obj in pairs(KyrielHub.ESPObjects) do
        if obj.Box then obj.Box:Remove() end
        if obj.Name then obj.Name:Remove() end
        if obj.HealthBar then obj.HealthBar:Remove() end
        if obj.Tracer then obj.Tracer:Remove() end
        if obj.Distance then obj.Distance:Remove() end
        if obj.Weapon then obj.Weapon:Remove() end
    end
    ScreenGui:Destroy()
    Notify("Kyriel Hub Unloaded", 3)
end)

local playerContent = TabContents["PLAYER"]

AddLabel(playerContent, "WEAPON MODS", Color3.fromRGB(170, 0, 255))
AddDivider(playerContent)

AddToggle(playerContent, "No Recoil", "NoRecoil", function(state)
    KyrielHub.NoRecoil = state
end)

AddToggle(playerContent, "No Spread", "NoSpread", function(state)
    KyrielHub.NoSpread = state
end)

AddToggle(playerContent, "Rapid Fire", "RapidFire", function(state)
    KyrielHub.RapidFire = state
end)

AddToggle(playerContent, "Instant Reload", "InstantReload", function(state)
    KyrielHub.InstantReload = state
end)

AddToggle(playerContent, "Infinite Ammo", "InfiniteAmmo", function(state)
    KyrielHub.InfiniteAmmo = state
end)

AddDivider(playerContent)
AddLabel(playerContent, "MOVEMENT", Color3.fromRGB(170, 0, 255))
AddDivider(playerContent)

AddToggle(playerContent, "Bunny Hop", "BunnyHop", function(state)
    KyrielHub.BunnyHop = state
end)

AddToggle(playerContent, "Auto Strafe", "AutoStrafe", function(state)
    KyrielHub.AutoStrafe = state
end)

AddDivider(playerContent)
AddLabel(playerContent, "MISC PLAYER", Color3.fromRGB(170, 0, 255))
AddDivider(playerContent)

AddToggle(playerContent, "Anti-AFK", "AntiAFK", function(state)
    if state then
        local afkConn = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2(Vector2.new())
        end)
        KyrielHub.Connections["AntiAFK"] = afkConn
    else
        if KyrielHub.Connections["AntiAFK"] then
            KyrielHub.Connections["AntiAFK"]:Disconnect()
            KyrielHub.Connections["AntiAFK"] = nil
        end
    end
end)

AddToggle(playerContent, "Auto Heal", "AutoHeal", function(state)
    KyrielHub.AutoHeal = state
end)

AddToggle(playerContent, "Auto Medkit", "AutoMedkit", function(state)
    KyrielHub.AutoMedkit = state
end)

local miscContent = TabContents["MISC"]

AddLabel(miscContent, "SERVER", Color3.fromRGB(170, 0, 255))
AddDivider(miscContent)

AddButton(miscContent, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

AddButton(miscContent, "Server Hop", function()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
end)

AddDivider(miscContent)
AddLabel(miscContent, "INFO", Color3.fromRGB(170, 0, 255))
AddDivider(miscContent)

AddLabel(miscContent, "Kyriel Hub v2.0")
AddLabel(miscContent, "Made by Kyriel")
AddLabel(miscContent, "Game: RIVALS")
AddLabel(miscContent, "Modes: 1v1 to 5v5, FFA, TDM")
AddLabel(miscContent, "Total Gamemodes: 21")
AddLabel(miscContent, "Active Players: 260K+")
AddLabel(miscContent, "Total Visits: 16.3B+")

local function GetTeamColor(player)
    if player.Team then
        return player.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function IsEnemy(player)
    if not KyrielHub.TeamCheck then return true end
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true
end

local function CanSee(target)
    if not KyrielHub.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dest = target.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, (dest - origin).Unit * 1000, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(target.Parent)
    end
    return true
end

local function GetClosestPlayer()
    local closest = nil
    local shortest = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild(KyrielHub.AimPart)
            if humanoid and head and humanoid.Health > 0 then
                if not IsEnemy(player) then continue end
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < KyrielHub.FOV and dist < shortest then
                        if CanSee(head) then
                            shortest = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetPlayerWeapon(player)
    local char = player.Character
    if not char then return "None" end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        return tool.Name
    end
    return "None"
end

local function DrawESP()
    if not KyrielHub.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        
        if not humanoid or not hrp or not head then continue end
        if humanoid.Health <= 0 then continue end
        
        local id = tostring(player.UserId)
        if not KyrielHub.ESPObjects[id] then
            KyrielHub.ESPObjects[id] = {}
        end
        
        local obj = KyrielHub.ESPObjects[id]
        local isEnemy = IsEnemy(player)
        local color = isEnemy and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        
        if not obj.Box then
            obj.Box = Drawing.new("Square")
            obj.Box.Thickness = 1.5
            obj.Box.Filled = false
            obj.Box.Visible = false
        end
        
        if not obj.Name then
            obj.Name = Drawing.new("Text")
            obj.Name.Size = 14
            obj.Name.Center = true
            obj.Name.Outline = true
            obj.Name.Visible = false
        end
        
        if not obj.HealthBar then
            obj.HealthBar = Drawing.new("Line")
            obj.HealthBar.Thickness = 2
            obj.HealthBar.Visible = false
        end
        
        if not obj.Tracer then
            obj.Tracer = Drawing.new("Line")
            obj.Tracer.Thickness = 1
            obj.Tracer.Visible = false
        end
        
        if not obj.Distance then
            obj.Distance = Drawing.new("Text")
            obj.Distance.Size = 12
            obj.Distance.Center = true
            obj.Distance.Outline = true
            obj.Distance.Visible = false
        end
        
        if not obj.Weapon then
            obj.Weapon = Drawing.new("Text")
            obj.Weapon.Size = 11
            obj.Weapon.Center = true
            obj.Weapon.Outline = true
            obj.Weapon.Visible = false
        end
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        if headPos.Z > 0 and footPos.Z > 0 then
            local height = math.abs(headPos.Y - footPos.Y)
            local width = height * 0.6
            
            obj.Box.Size = Vector2.new(width, height)
            obj.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
            obj.Box.Color = color
            obj.Box.Visible = true
            
            obj.Name.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "HP]"
            obj.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
            obj.Name.Color = color
            obj.Name.Visible = true
            
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            obj.HealthBar.From = Vector2.new(headPos.X - width / 2 - 5, footPos.Y)
            obj.HealthBar.To = Vector2.new(headPos.X - width / 2 - 5, headPos.Y)
            obj.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            obj.HealthBar.Visible = true
            
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(headPos.X, footPos.Y)
            obj.Tracer.Color = color
            obj.Tracer.Visible = true
            
            local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
            obj.Distance.Text = dist .. "m"
            obj.Distance.Position = Vector2.new(headPos.X, footPos.Y + 5)
            obj.Distance.Color = Color3.fromRGB(200, 200, 200)
            obj.Distance.Visible = true
            
            local weapon = GetPlayerWeapon(player)
            obj.Weapon.Text = weapon
            obj.Weapon.Position = Vector2.new(headPos.X, headPos.Y - 32)
            obj.Weapon.Color = Color3.fromRGB(255, 200, 100)
            obj.Weapon.Visible = true
        else
            obj.Box.Visible = false
            obj.Name.Visible = false
            obj.HealthBar.Visible = false
            obj.Tracer.Visible = false
            obj.Distance.Visible = false
            obj.Weapon.Visible = false
        end
    end
    
    for id, obj in pairs(KyrielHub.ESPObjects) do
        local stillThere = false
        for _, p in pairs(Players:GetPlayers()) do
            if tostring(p.UserId) == id then stillThere = true break end
        end
        if not stillThere then
            if obj.Box then obj.Box:Remove() end
            if obj.Name then obj.Name:Remove() end
            if obj.HealthBar then obj.HealthBar:Remove() end
            if obj.Tracer then obj.Tracer:Remove() end
            if obj.Distance then obj.Distance:Remove() end
            if obj.Weapon then obj.Weapon:Remove() end
            KyrielHub.ESPObjects[id] = nil
        end
    end
end

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 64
FOV_Circle.Radius = KyrielHub.FOV
FOV_Circle.Filled = false
FOV_Circle.Visible = false
FOV_Circle.Color = Color3.fromRGB(170, 0, 255)

local renderConn = RunService.RenderStepped:Connect(function()
    FOV_Circle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOV_Circle.Radius = KyrielHub.FOV
    FOV_Circle.Visible = KyrielHub.DrawFOV and KyrielHub.AimbotEnabled
    
    if KyrielHub.AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(KyrielHub.AimPart) then
            local targetPos = target.Character[KyrielHub.AimPart].Position
            local cameraCF = Camera.CFrame
            local targetCF = CFrame.new(cameraCF.Position, targetPos)
            if KyrielHub.Smoothness > 0 then
                Camera.CFrame = cameraCF:Lerp(targetCF, KyrielHub.Smoothness)
            else
                Camera.CFrame = targetCF
            end
        end
    end
    
    DrawESP()
    
    if KyrielHub.TriggerBot then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model then
                local player = Players:FindFirstChild(model.Name)
                if player and player ~= LocalPlayer and IsEnemy(player) then
                    mouse1click()
                end
            end
        end
    end
    
    if KyrielHub.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Jump = true
            end
        end
    end
end)

table.insert(KyrielHub.Connections, renderConn)

local function UpdateGameInfo()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and info then
        gameNameLabel.Text = "Game: " .. info.Name
    end
    
    playerCountLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. KyrielHub.MaxPlayers
    
    local mode = "Lobby"
    local map = "Lobby"
    local team = "None"
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("StringValue") or obj:IsA("TextButton") then
            local txt = obj.Text or obj.Value
            if typeof(txt) == "string" then
                txt = txt:lower()
                if txt:find("1v1") then mode = "1v1" end
                if txt:find("2v2") then mode = "2v2" end
                if txt:find("3v3") then mode = "3v3" end
                if txt:find("4v4") then mode = "4v4" end
                if txt:find("5v5") then mode = "5v5" end
                if txt:find("ffa") or txt:find("free for all") then mode = "FFA" end
                if txt:find("team deathmatch") or txt:find("tdm") then mode = "TDM" end
                if txt:find("gun game") then mode = "Gun Game" end
                if txt:find("juggernaut") then mode = "Juggernaut" end
                if txt:find("ranked") then mode = "Ranked" end
            end
        end
    end
    
    if LocalPlayer.Team then
        team = LocalPlayer.Team.Name
    end
    
    gameModeLabel.Text = "Mode: " .. mode
    mapLabel.Text = "Map: " .. map
    teamLabel.Text = "Team: " .. team
    
    local activeFuncs = {}
    if KyrielHub.AimbotEnabled then table.insert(activeFuncs, "Aimbot") end
    if KyrielHub.ESPEnabled then table.insert(activeFuncs, "ESP") end
    if KyrielHub.TriggerBot then table.insert(activeFuncs, "TriggerBot") end
    if KyrielHub.FullBright then table.insert(activeFuncs, "FullBright") end
    if KyrielHub.NoRecoil then table.insert(activeFuncs, "NoRecoil") end
    if KyrielHub.NoSpread then table.insert(activeFuncs, "NoSpread") end
    if KyrielHub.RapidFire then table.insert(activeFuncs, "RapidFire") end
    if KyrielHub.InstantReload then table.insert(activeFuncs, "InstantReload") end
    if KyrielHub.InfiniteAmmo then table.insert(activeFuncs, "InfiniteAmmo") end
    if KyrielHub.BunnyHop then table.insert(activeFuncs, "BunnyHop") end
    if KyrielHub.AutoStrafe then table.insert(activeFuncs, "AutoStrafe") end
    if KyrielHub.NoFlash then table.insert(activeFuncs, "NoFlash") end
    if KyrielHub.NoScope then table.insert(activeFuncs, "NoScope") end
    if KyrielHub.AutoHeal then table.insert(activeFuncs, "AutoHeal") end
    if KyrielHub.AutoMedkit then table.insert(activeFuncs, "AutoMedkit") end
    
    if #activeFuncs > 0 then
        statusLabel.Text = "Active: " .. table.concat(activeFuncs, ", ")
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        statusLabel.Text = "No functions active"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        UpdateGameInfo()
        task.wait(1)
    end
end)

local noFlashConn = Lighting.Changed:Connect(function()
    if KyrielHub.NoFlash then
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
                obj.Enabled = false
            end
        end
    end
end)

table.insert(KyrielHub.Connections, noFlashConn)

local function SetupWeaponMods()
    local mt = getrawmetatable(game)
    if not mt then return end
    local oldIndex = mt.__index
    setreadonly(mt, false)
    
    mt.__index = newcclosure(function(self, key)
        if KyrielHub.NoRecoil and key == "Recoil" then
            return 0
        end
        if KyrielHub.NoSpread and key == "Spread" then
            return 0
        end
        if KyrielHub.RapidFire and key == "FireRate" then
            local val = oldIndex(self, key)
            if typeof(val) == "number" then
                return val * 3
            end
        end
        if KyrielHub.InstantReload and key == "ReloadTime" then
            return 0.1
        end
        if KyrielHub.InfiniteAmmo and key == "Ammo" then
            return 999
        end
        if KyrielHub.InfiniteAmmo and key == "MaxAmmo" then
            return 999
        end
        return oldIndex(self, key)
    end)
    
    setreadonly(mt, true)
end

pcall(SetupWeaponMods)

local function AutoHealLoop()
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if KyrielHub.AutoHeal then
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health < humanoid.MaxHealth * 0.7 then
                        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("medkit") or tool.Name:lower():find("heal")) then
                                humanoid.Health = humanoid.Health + 30
                                break
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

AutoHealLoop()

local function AutoMedkitLoop()
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if KyrielHub.AutoMedkit then
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health < humanoid.MaxHealth * 0.5 then
                        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:lower():find("medkit") then
                                tool.Parent = char
                                task.wait(0.1)
                                if tool:FindFirstChild("Activate") then
                                    tool.Activate:FireServer()
                                end
                                task.wait(0.1)
                                tool.Parent = LocalPlayer.Backpack
                                break
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

AutoMedkitLoop()

local function AntiCheatBypass()
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "table" then
            for k, v in pairs(obj) do
                local kStr = tostring(k):lower()
                if kStr:find("kick") or kStr:find("ban") or kStr:find("cheat") or kStr:find("detect") or kStr:find("report") or kStr:find("flag") then
                    if typeof(v) == "function" then
                        hookfunction(v, function() end)
                    end
                end
            end
        end
    end
end

pcall(AntiCheatBypass)

local function NoScopeLoop()
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if KyrielHub.NoScope then
                for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                        local name = gui.Name:lower()
                        if name:find("scope") or name:find("sniper") or name:find("overlay") or name:find("zoom") then
                            gui.Visible = false
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

NoScopeLoop()

Notify("Kyriel Hub Loaded!", 3)
Notify("Game: RIVALS | 21 Modes | 260K Active", 3)
Notify("Press K Box to Toggle Menu", 3)
