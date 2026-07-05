-- ============================================
-- RACE CLICKER DEBUG SCRIPT - FIND REMOTES
-- Youtube.com/RukanooXD_YT
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== RACE CLICKER REMOTE SCANNER ===")
print("Game ID: " .. game.PlaceId)
print("Job ID: " .. game.JobId)

-- Scan ReplicatedStorage
print("\n--- ReplicatedStorage Structure ---")
for _, child in pairs(ReplicatedStorage:GetChildren()) do
    print("  " .. child.Name .. " (" .. child.ClassName .. ")")
end

-- Cari Knit
local knit = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit")
if knit then
    print("\n--- Knit Services ---")
    local services = knit:FindFirstChild("Services")
    if services then
        for _, svc in pairs(services:GetChildren()) do
            print("  Service: " .. svc.Name)
            local rf = svc:FindFirstChild("RF")
            local re = svc:FindFirstChild("RE")
            if rf then
                for _, r in pairs(rf:GetChildren()) do
                    print("    RF: " .. r.Name .. " (" .. r.ClassName .. ")")
                end
            end
            if re then
                for _, r in pairs(re:GetChildren()) do
                    print("    RE: " .. r.Name .. " (" .. r.ClassName .. ")")
                end
            end
        end
    else
        print("  Services folder not found!")
    end
else
    print("\nKnit not found! Scanning all remotes...")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("  " .. obj:GetFullName() .. " (" .. obj.ClassName .. ")")
        end
    end
end

-- Cari leaderstats
print("\n--- Leaderstats ---")
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
    for _, stat in pairs(leaderstats:GetChildren()) do
        print("  " .. stat.Name .. " = " .. tostring(stat.Value) .. " (" .. stat.ClassName .. ")")
    end
else
    print("  No leaderstats found")
end

-- Cari GUI elements
print("\n--- Player GUI ---")
for _, gui in pairs(player.PlayerGui:GetChildren()) do
    print("  " .. gui.Name .. " (" .. gui.ClassName .. ")")
end

print("\n=== SCAN COMPLETE ===")
print("Copy semua output di atas dan kirim ke RukanooXD_YT")
