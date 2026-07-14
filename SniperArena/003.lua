local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local flags = {
    aim = false,
    silent = false,
    esp = false,
    xray = false,
    aura = false,
    vis = false,
    inf = false,
    rpl = false,
    rec = false,
    spr = false,
    rld = false,
    antiafk = false,
    hidename = false,
    fullbright = false,
    nofog = false,
    freecam = false,
    fov = 150,
    auraRange = 50
}

local ESP = {}
local botESP = {}
local fovCircle = nil
local lockedTarget = nil
local xrayData = {}
local uiMap = {}
local lastShot = 0
local freecamPos = nil
local freecamCF = nil

local function newDraw(t, p)
    local d = Drawing.new(t)
    for k, v in pairs(p) do
        d[k] = v
    end
    return d
end

local function isEnemy(plr)
    if plr == lp then return false end
    if plr.Team and lp.Team and plr.Team == lp.Team then return false end
    return true
end

local function getTeamColor(plr)
    if plr == lp then return Color3.fromRGB(0, 212, 255) end
    if plr.Team and lp.Team and plr.Team == lp.Team then return Color3.fromRGB(0, 120, 255) end
    return Color3.fromRGB(255, 50, 50)
end

local function mkEsp(plr)
    if plr == lp then return end
    local col = getTeamColor(plr)
    ESP[plr] = {
        box = newDraw("Square", {Thickness = 1.2, Color = col, Filled = false, Visible = false}),
        fill = newDraw("Square", {Thickness = 0, Color = col, Filled = true, Transparency = 0.05, Visible = false}),
        name = newDraw("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        hp = newDraw("Text", {Size = 11, Center = true, Outline = true, Color = Color3.fromRGB(0, 255, 130), Visible = false}),
        dist = newDraw("Text", {Size = 11, Center = true, Outline = true, Color = Color3.fromRGB(180, 180, 180), Visible = false}),
        line = newDraw("Line", {Thickness = 1, Color = col, Transparency = 0.5, Visible = false})
    }
end

local function rmEsp(plr)
    local e = ESP[plr]
    if e then
        for _, v in pairs(e) do
            v:Remove()
        end
        ESP[plr] = nil
    end
end

local function mkBotEsp(bot)
    botESP[bot] = {
        box = newDraw("Square", {Thickness = 1.2, Color = Color3.fromRGB(255, 180, 0), Filled = false, Visible = false}),
        fill = newDraw("Square", {Thickness = 0, Color = Color3.fromRGB(255, 180, 0), Filled = true, Transparency = 0.05, Visible = false}),
        name = newDraw("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        hp = newDraw("Text", {Size = 11, Center = true, Outline = true, Color = Color3.fromRGB(0, 255, 130), Visible = false}),
        dist = newDraw("Text", {Size = 11, Center = true, Outline = true, Color = Color3.fromRGB(180, 180, 180), Visible = false}),
        line = newDraw("Line", {Thickness = 1, Color = Color3.fromRGB(255, 180, 0), Transparency = 0.5, Visible = false})
    }
end

local function rmBotEsp(bot)
    local e = botESP[bot]
    if e then
        for _, v in pairs(e) do
            v:Remove()
        end
        botESP[bot] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    mkEsp(p)
end

Players.PlayerAdded:Connect(function(p)
    mkEsp(p)
end)

Players.PlayerRemoving:Connect(function(p)
    rmEsp(p)
end)

lp:GetPropertyChangedSignal("Team"):Connect(function()
    for plr, _ in pairs(ESP) do
        rmEsp(plr)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        mkEsp(p)
    end
end)

local function checkBot(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") and not Players:FindFirstChild(obj.Name) and obj ~= lp.Character then
        if not botESP[obj] then
            mkBotEsp(obj)
        end
    end
end

Workspace.DescendantAdded:Connect(checkBot)

task.spawn(function()
    while task.wait(2) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            checkBot(obj)
        end
        for bot, _ in pairs(botESP) do
            if not bot.Parent then
                rmBotEsp(bot)
            end
        end
    end
end)

local function getAimTarget()
    local near = flags.fov
    local target = nil
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local pos, vis = cam:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < near then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            near = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    for bot, _ in pairs(botESP) do
        if bot.Parent then
            local head = bot:FindFirstChild("Head")
            if head then
                local pos, vis = cam:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < near then
                        local hum = bot:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            near = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

local function getAuraTarget()
    local closest = nil
    local minDist = flags.auraRange
    local myPos = cam.CFrame.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local dist = (head.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = head
                end
            end
        end
    end
    for bot, _ in pairs(botESP) do
        if bot.Parent then
            local head = bot:FindFirstChild("Head")
            local hum = bot:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local dist = (head.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

local function validTarget(head)
    if not head or not head.Parent then return false end
    local hum = head.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local pos, vis = cam:WorldToViewportPoint(head.Position)
    if not vis then return false end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    if (Vector2.new(pos.X, pos.Y) - center).Magnitude > flags.fov then return false end
    return true
end

local function isVisible(target)
    if not target or not target.Parent then return false end
    local origin = cam.CFrame.Position
    local dest = target.Position
    local dir = dest - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {lp.Character, cam}
    local result = Workspace:Raycast(origin, dir, rayParams)
    if not result then return true end
    local model = result.Instance:FindFirstAncestorOfClass("Model")
    if model and model == target.Parent then
        return true
    end
    return false
end

local function setXray(on)
    if on then
        task.spawn(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(lp.Character) then
                    if obj.LocalTransparencyModifier < 0.1 and obj.Transparency < 0.9 then
                        xrayData[obj] = obj.LocalTransparencyModifier
                        obj.LocalTransparencyModifier = 0.6
                    end
                end
            end
        end)
    else
        for obj, orig in pairs(xrayData) do
            if obj then
                obj.LocalTransparencyModifier = orig
            end
        end
        xrayData = {}
    end
end

local function notify(txt)
    local sg = CoreGui:FindFirstChild("KyrielHub")
    if not sg then return end
    local nh = sg:FindFirstChild("NH")
    if not nh then
        nh = Instance.new("Frame")
        nh.Name = "NH"
        nh.Size = UDim2.new(0, 270, 1, 0)
        nh.Position = UDim2.new(1, -280, 0, 10)
        nh.BackgroundTransparency = 1
        nh.Parent = sg
    end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 260, 0, 52)
    f.Position = UDim2.new(1, 20, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    f.BorderSizePixel = 0
    f.Parent = nh
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(0, 212, 255)
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 0, 10 + (#nh:GetChildren() - 1) * 60)}):Play()
    task.delay(3.5, function()
        TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, f.Position.Y.Offset)}):Play()
        task.delay(0.35, function() f:Destroy() end)
    end)
end

local sg = Instance.new("ScreenGui")
sg.Name = "KyrielHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = CoreGui

local ob = Instance.new("TextButton")
ob.Size = UDim2.new(0, 52, 0, 52)
ob.Position = UDim2.new(0, 20, 0.85, -26)
ob.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ob.Text = "KH"
ob.TextColor3 = Color3.fromRGB(0, 212, 255)
ob.TextSize = 18
ob.Font = Enum.Font.GothamBold
ob.Parent = sg
Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 16)
local obStroke = Instance.new("UIStroke")
obStroke.Color = Color3.fromRGB(0, 212, 255)
obStroke.Thickness = 2
obStroke.Parent = ob
local obGlow = Instance.new("ImageLabel")
obGlow.Size = UDim2.new(1, 16, 1, 16)
obGlow.Position = UDim2.new(0, -8, 0, -8)
obGlow.BackgroundTransparency = 1
obGlow.Image = "rbxassetid://5028857084"
obGlow.ImageColor3 = Color3.fromRGB(0, 212, 255)
obGlow.ImageTransparency = 0.85
obGlow.Parent = ob

local mf = Instance.new("Frame")
mf.Size = UDim2.new(0, 640, 0, 480)
mf.Position = UDim2.new(0.5, -320, 0.5, -240)
mf.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
mf.BorderSizePixel = 0
mf.Active = true
mf.Visible = false
mf.ClipsDescendants = true
mf.Parent = sg
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 20)
local mfStroke = Instance.new("UIStroke")
mfStroke.Color = Color3.fromRGB(0, 212, 255)
mfStroke.Thickness = 1.5
mfStroke.Parent = mf
local mfGlow = Instance.new("ImageLabel")
mfGlow.Size = UDim2.new(1, 24, 1, 24)
mfGlow.Position = UDim2.new(0, -12, 0, -12)
mfGlow.BackgroundTransparency = 1
mfGlow.Image = "rbxassetid://5028857084"
mfGlow.ImageColor3 = Color3.fromRGB(0, 212, 255)
mfGlow.ImageTransparency = 0.92
mfGlow.Parent = mf

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 60)
top.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
top.BorderSizePixel = 0
top.Parent = mf
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 20)

local tit = Instance.new("TextLabel")
tit.Size = UDim2.new(0, 220, 0, 30)
tit.Position = UDim2.new(0, 24, 0, 6)
tit.BackgroundTransparency = 1
tit.Text = "Kyriel Hub"
tit.TextColor3 = Color3.fromRGB(255, 255, 255)
tit.TextSize = 22
tit.Font = Enum.Font.GothamBold
tit.TextXAlignment = Enum.TextXAlignment.Left
tit.Parent = top

local subtit = Instance.new("TextLabel")
subtit.Size = UDim2.new(0, 220, 0, 20)
subtit.Position = UDim2.new(0, 24, 0, 34)
subtit.BackgroundTransparency = 1
subtit.Text = "Sniper Arena | Ultimate"
subtit.TextColor3 = Color3.fromRGB(0, 212, 255)
subtit.TextSize = 12
subtit.Font = Enum.Font.Gotham
subtit.TextXAlignment = Enum.TextXAlignment.Left
subtit.Parent = top

local xb = Instance.new("TextButton")
xb.Size = UDim2.new(0, 36, 0, 36)
xb.Position = UDim2.new(1, -50, 0, 12)
xb.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
xb.Text = ""
xb.Parent = top
Instance.new("UICorner", xb).CornerRadius = UDim.new(0, 10)
local xIcon = Instance.new("TextLabel")
xIcon.Size = UDim2.new(1, 0, 1, 0)
xIcon.BackgroundTransparency = 1
xIcon.Text = "X"
xIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
xIcon.TextSize = 16
xIcon.Font = Enum.Font.GothamBold
xIcon.Parent = xb

local side = Instance.new("Frame")
side.Size = UDim2.new(0, 160, 1, -60)
side.Position = UDim2.new(0, 0, 0, 60)
side.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
side.BorderSizePixel = 0
side.Parent = mf
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 20)

local tabs = {"Main", "Combat", "Visuals", "Misc"}
local btns = {}
local frms = {}

for i, v in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -18, 0, 42)
    b.Position = UDim2.new(0, 9, 0, 16 + (i - 1) * 50)
    b.BackgroundColor3 = v == "Main" and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(20, 20, 26)
    b.Text = v:upper()
    b.TextColor3 = v == "Main" and Color3.fromRGB(8, 8, 12) or Color3.fromRGB(160, 160, 160)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    btns[v] = b
    
    local f = Instance.new("ScrollingFrame")
    f.Size = UDim2.new(1, -160, 1, -60)
    f.Position = UDim2.new(0, 160, 0, 60)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Color3.fromRGB(35, 35, 50)
    f.Visible = v == "Main"
    f.Parent = mf
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 12)
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.Parent = f
    frms[v] = f
end

local function sw(t)
    for k, v in pairs(frms) do
        v.Visible = k == t
        btns[k].BackgroundColor3 = k == t and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(20, 20, 26)
        btns[k].TextColor3 = k == t and Color3.fromRGB(8, 8, 12) or Color3.fromRGB(160, 160, 160)
    end
end

for k, v in pairs(btns) do
    v.MouseButton1Click:Connect(function() sw(k) end)
end

local function mkSwitch(parent, txt, key)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 430, 0, 48)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 280, 1, 0)
    l.Position = UDim2.new(0, 18, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 52, 0, 26)
    bg.Position = UDim2.new(1, -68, 0.5, -13)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    f.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            flags[key] = not flags[key]
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = flags[key] and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(40, 40, 50)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = flags[key] and UDim2.new(0, 28, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)}):Play()
            if uiMap[key] then
                uiMap[key].dot.BackgroundColor3 = flags[key] and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(255, 60, 60)
                uiMap[key].st.Text = flags[key] and "ON" or "OFF"
                uiMap[key].st.TextColor3 = flags[key] and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(255, 60, 60)
            end
            if key == "xray" then
                setXray(flags.xray)
            end
            if key == "fullbright" then
                if flags.fullbright then
                    Lighting.Brightness = 10
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                else
                    Lighting.Brightness = 2
                    Lighting.GlobalShadows = true
                    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
                end
            end
            if key == "nofog" then
                if flags.nofog then
                    Lighting.FogEnd = 100000
                else
                    Lighting.FogEnd = 500
                end
            end
            if key == "hidename" then
                if lp.Character and lp.Character:FindFirstChild("Head") then
                    local head = lp.Character.Head
                    local nameTag = head:FindFirstChild("NameTag") or head:FindFirstChild("name")
                    if nameTag then
                        nameTag.Enabled = not flags.hidename
                    end
                    for _, v in ipairs(head:GetDescendants()) do
                        if v:IsA("BillboardGui") and v.Name:lower():find("name") then
                            v.Enabled = not flags.hidename
                        end
                    end
                end
            end
        end
    end)
    return f
end

local function mkBtn(parent, txt, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 430, 0, 48)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 280, 1, 0)
    l.Position = UDim2.new(0, 18, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 80, 0, 30)
    b.Position = UDim2.new(1, -94, 0.5, -15)
    b.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    b.Text = "EXEC"
    b.TextColor3 = Color3.fromRGB(8, 8, 12)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return f
end

local function mkLbl(parent, txt, col, sz)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 430, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = col or Color3.fromRGB(160, 160, 160)
    l.TextSize = sz or 13
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function mkStatus(parent, txt, key)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 430, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 16, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    dot.BorderSizePixel = 0
    dot.Parent = f
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 320, 1, 0)
    l.Position = UDim2.new(0, 34, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 60, 1, 0)
    st.Position = UDim2.new(1, -70, 0, 0)
    st.BackgroundTransparency = 1
    st.Text = "OFF"
    st.TextColor3 = Color3.fromRGB(255, 60, 60)
    st.TextSize = 12
    st.Font = Enum.Font.GothamBold
    st.TextXAlignment = Enum.TextXAlignment.Right
    st.Parent = f
    uiMap[key] = {dot = dot, st = st}
    return f
end

mkLbl(frms.Main, "Sniper Arena | 9D GAME CLUB", Color3.fromRGB(255, 255, 255), 17)
mkLbl(frms.Main, "Active: 10.9K Players | 91% Rating", Color3.fromRGB(140, 140, 140), 12)
mkLbl(frms.Main, " ")

mkLbl(frms.Main, "Active Functions", Color3.fromRGB(255, 255, 255), 14)
mkStatus(frms.Main, "Aimbot Lock Head", "aim")
mkStatus(frms.Main, "Silent Aim", "silent")
mkStatus(frms.Main, "Aura Kill", "aura")
mkStatus(frms.Main, "ESP Box", "esp")
mkStatus(frms.Main, "X-Ray Wallhack", "xray")
mkStatus(frms.Main, "Rapid Fire", "rpl")
mkStatus(frms.Main, "Infinite Ammo", "inf")
mkStatus(frms.Main, "Anti-AFK", "antiafk")
mkStatus(frms.Main, "Hide Name", "hidename")
mkStatus(frms.Main, "Fullbright", "fullbright")
mkStatus(frms.Main, "No Fog", "nofog")

mkLbl(frms.Main, " ")
mkLbl(frms.Main, "Live Stats", Color3.fromRGB(255, 255, 255), 14)
local fpsLbl = mkLbl(frms.Main, "FPS: --", Color3.fromRGB(200, 200, 200), 13)
local pingLbl = mkLbl(frms.Main, "Ping: --", Color3.fromRGB(200, 200, 200), 13)
local hpLbl = mkLbl(frms.Main, "Health: --", Color3.fromRGB(200, 200, 200), 13)
local wsLbl = mkLbl(frms.Main, "WalkSpeed: --", Color3.fromRGB(200, 200, 200), 13)
mkLbl(frms.Main, " ")

mkLbl(frms.Main, "Server Info", Color3.fromRGB(255, 255, 255), 14)
local plrLbl = mkLbl(frms.Main, "Players: loading...", Color3.fromRGB(200, 200, 200), 13)

mkSwitch(frms.Combat, "Aimbot Lock Head", "aim")
mkSwitch(frms.Combat, "Silent Aim", "silent")
mkSwitch(frms.Combat, "Aura Kill", "aura")
mkSwitch(frms.Combat, "Rapid Fire", "rpl")
mkSwitch(frms.Combat, "Infinite Ammo", "inf")
mkSwitch(frms.Combat, "No Recoil", "rec")
mkSwitch(frms.Combat, "No Spread", "spr")
mkSwitch(frms.Combat, "Instant Reload", "rld")

mkSwitch(frms.Visuals, "ESP Box", "esp")
mkSwitch(frms.Visuals, "X-Ray Wallhack", "xray")
mkSwitch(frms.Visuals, "Fullbright", "fullbright")
mkSwitch(frms.Visuals, "No Fog", "nofog")
mkSwitch(frms.Visuals, "Hide Name", "hidename")

local visSw = mkSwitch(frms.Visuals, "Visual UI", "vis")
visSw.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if not flags.vis then
            TweenService:Create(mf, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.delay(0.25, function()
                mf.Visible = false
                ob.Visible = true
            end)
        else
            mf.Visible = true
            ob.Visible = false
            TweenService:Create(mf, TweenInfo.new(0.25), {Size = UDim2.new(0, 640, 0, 480)}):Play()
        end
    end
end)

mkLbl(frms.Misc, "Server Tools", Color3.fromRGB(255, 255, 255), 14)
mkBtn(frms.Misc, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, lp)
end)
mkBtn(frms.Misc, "Server Hop", function()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    local data = game:GetService("HttpService"):JSONDecode(req)
    for _, s in ipairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            table.insert(servers, s.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], lp)
    end
end)
mkBtn(frms.Misc, "Copy JobId", function()
    setclipboard(game.JobId)
    notify("JobId copied to clipboard")
end)

mkLbl(frms.Misc, " ")
mkLbl(frms.Misc, "Utility", Color3.fromRGB(255, 255, 255), 14)
mkSwitch(frms.Misc, "Anti-AFK", "antiafk")
mkSwitch(frms.Misc, "Freecam", "freecam")

ob.MouseButton1Click:Connect(function()
    mf.Visible = true
    ob.Visible = false
    TweenService:Create(mf, TweenInfo.new(0.25), {Size = UDim2.new(0, 640, 0, 480)}):Play()
end)

xb.MouseButton1Click:Connect(function()
    TweenService:Create(mf, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(0.25, function()
        mf.Visible = false
        ob.Visible = true
    end)
end)

local function drag(gui)
    local active = false
    local offset = nil
    gui.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            active = true
            offset = Vector2.new(gui.AbsolutePosition.X, gui.AbsolutePosition.Y) - Vector2.new(inp.Position.X, inp.Position.Y)
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    active = false
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and active then
            gui.Position = UDim2.new(0, inp.Position.X + offset.X, 0, inp.Position.Y + offset.Y)
        end
    end)
end

drag(ob)
drag(mf)

local fps = 0
local frames = 0
local lastTick = tick()

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if flags.silent and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local target = lockedTarget
        if target and target.Parent then
            local headPos = target.Position
            for i = 1, #args do
                if typeof(args[i]) == "Vector3" then
                    local screenPos, onScreen = cam:WorldToViewportPoint(args[i])
                    if onScreen then
                        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < flags.fov * 2 then
                            args[i] = headPos
                        end
                    end
                elseif typeof(args[i]) == "CFrame" then
                    local pos = args[i].Position
                    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                    if onScreen then
                        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < flags.fov * 2 then
                            args[i] = CFrame.new(headPos)
                        end
                    end
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

RunService:BindToRenderStep("KyrielAim", 999, function()
    local ok = pcall(function()
        frames += 1
        if tick() - lastTick >= 1 then
            fps = frames
            frames = 0
            lastTick = tick()
        end
        
        if flags.esp then
            for plr, obj in pairs(ESP) do
                local ok2 = pcall(function()
                    if not plr or not plr.Parent then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local char = plr.Character
                    if not char or not char.Parent then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not head or not hum or not root then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    if hum.Health <= 0 then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if not onScreen then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local topPos = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local botPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(topPos.Y - botPos.Y)
                    if h < 5 then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local w = h * 0.55
                    local col = getTeamColor(plr)
                    obj.box.Color = col
                    obj.fill.Color = col
                    obj.line.Color = col
                    obj.box.Size = Vector2.new(w, h)
                    obj.box.Position = Vector2.new(pos.X - w/2, topPos.Y)
                    obj.box.Visible = true
                    obj.fill.Size = Vector2.new(w, h)
                    obj.fill.Position = Vector2.new(pos.X - w/2, topPos.Y)
                    obj.fill.Visible = true
                    obj.name.Position = Vector2.new(pos.X, topPos.Y - 18)
                    obj.name.Text = plr.Name
                    obj.name.Visible = true
                    obj.hp.Position = Vector2.new(pos.X, botPos.Y + 6)
                    obj.hp.Text = math.floor(hum.Health).."HP"
                    obj.hp.Visible = true
                    obj.dist.Position = Vector2.new(pos.X, botPos.Y + 18)
                    local distM = math.floor((cam.CFrame.Position - root.Position).Magnitude)
                    obj.dist.Text = distM.."m"
                    obj.dist.Visible = true
                    obj.line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                    obj.line.To = Vector2.new(pos.X, botPos.Y)
                    obj.line.Visible = true
                end)
                if not ok2 then
                    obj.box.Visible = false
                    obj.fill.Visible = false
                    obj.name.Visible = false
                    obj.hp.Visible = false
                    obj.dist.Visible = false
                    obj.line.Visible = false
                end
            end
            
            for bot, obj in pairs(botESP) do
                local ok2 = pcall(function()
                    if not bot or not bot.Parent then
                        rmBotEsp(bot)
                        return
                    end
                    local head = bot:FindFirstChild("Head")
                    local hum = bot:FindFirstChildOfClass("Humanoid")
                    local root = bot:FindFirstChild("HumanoidRootPart")
                    if not head or not hum or not root or hum.Health <= 0 then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if not onScreen then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local topPos = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local botPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(topPos.Y - botPos.Y)
                    if h < 5 then
                        obj.box.Visible = false
                        obj.fill.Visible = false
                        obj.name.Visible = false
                        obj.hp.Visible = false
                        obj.dist.Visible = false
                        obj.line.Visible = false
                        return
                    end
                    local w = h * 0.55
                    obj.box.Size = Vector2.new(w, h)
                    obj.box.Position = Vector2.new(pos.X - w/2, topPos.Y)
                    obj.box.Visible = true
                    obj.fill.Size = Vector2.new(w, h)
                    obj.fill.Position = Vector2.new(pos.X - w/2, topPos.Y)
                    obj.fill.Visible = true
                    obj.name.Position = Vector2.new(pos.X, topPos.Y - 18)
                    obj.name.Text = "BOT"
                    obj.name.Visible = true
                    obj.hp.Position = Vector2.new(pos.X, botPos.Y + 6)
                    obj.hp.Text = math.floor(hum.Health).."HP"
                    obj.hp.Visible = true
                    obj.dist.Position = Vector2.new(pos.X, botPos.Y + 18)
                    obj.dist.Text = math.floor((cam.CFrame.Position - root.Position).Magnitude).."m"
                    obj.dist.Visible = true
                    obj.line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                    obj.line.To = Vector2.new(pos.X, botPos.Y)
                    obj.line.Visible = true
                end)
                if not ok2 then
                    obj.box.Visible = false
                    obj.fill.Visible = false
                    obj.name.Visible = false
                    obj.hp.Visible = false
                    obj.dist.Visible = false
                    obj.line.Visible = false
                end
            end
        else
            for _, obj in pairs(ESP) do
                obj.box.Visible = false
                obj.fill.Visible = false
                obj.name.Visible = false
                obj.hp.Visible = false
                obj.dist.Visible = false
                obj.line.Visible = false
            end
            for _, obj in pairs(botESP) do
                obj.box.Visible = false
                obj.fill.Visible = false
                obj.name.Visible = false
                obj.hp.Visible = false
                obj.dist.Visible = false
                obj.line.Visible = false
            end
        end
        
        if flags.aim then
            if not lockedTarget or not validTarget(lockedTarget) then
                lockedTarget = getAimTarget()
            end
            if lockedTarget then
                local targetCF = CFrame.new(cam.CFrame.Position, lockedTarget.Position)
                cam.CFrame = cam.CFrame:Lerp(targetCF, 0.95)
            end
            if not fovCircle then
                fovCircle = newDraw("Circle", {Radius = flags.fov, Thickness = 1.5, Color = Color3.fromRGB(0, 212, 255), Filled = false, NumSides = 64, Visible = true})
            end
            fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            fovCircle.Visible = true
        else
            lockedTarget = nil
            if fovCircle then
                fovCircle.Visible = false
            end
        end
        
        if flags.aura then
            local auraTarget = getAuraTarget()
            if auraTarget and isVisible(auraTarget) and tick() - lastShot > 0.1 then
                mouse1click()
                lastShot = tick()
            end
        end
    end)
end)

task.spawn(function()
    while task.wait(1.5) do
        local c = #Players:GetPlayers()
        local m = Players.MaxPlayers
        plrLbl.Text = "Players: "..c.."/"..m.." | You: "..lp.Name
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        fpsLbl.Text = "FPS: "..fps
        local ping = lp:GetNetworkPing()
        pingLbl.Text = "Ping: "..math.floor(ping * 1000).."ms"
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hpLbl.Text = "Health: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
            wsLbl.Text = "WalkSpeed: "..math.floor(hum.WalkSpeed)
        else
            hpLbl.Text = "Health: --"
            wsLbl.Text = "WalkSpeed: --"
        end
    end
end)

task.spawn(function()
    while task.wait(30) do
        if flags.antiafk then
            local v = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if v then
                v:Move(Vector3.new(0, 0, 0), true)
            end
        end
    end
end)

notify("Kyriel Hub | Ultimate | Loaded")
