--[[
    Rivals Advanced Exploit Loader & Wrapper (Luraph Emulator / Xeno Compatible)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().RivalsConfig = {
    Aimbot = {
        Enabled = false,
        Smoothness = 5,
        FOV = 180,
        Part = "Head"
    },
    SilentAim = {
        Enabled = false,
        Chance = 100
    },
    ESP = {
        Boxes = false,
        TeamCheck = true
    }
}

local CFG = getgenv().RivalsConfig

-- Silent Aim & Metatable Hook for Xeno execution bypass
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if CFG.SilentAim.Enabled and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(CFG.Aimbot.Part) then
                if CFG.ESP.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local targetPart = p.Character[CFG.Aimbot.Part]
                if method == "Raycast" and args[1] then
                    args[2] = (targetPart.Position - args[1]).Unit * 1000
                end
                break
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- ESP Boxes Storage
local ESPList = {}
local function ClearESP(p)
    if ESPList[p] then
        pcall(function() ESPList[p]:Remove() end)
        ESPList[p] = nil
    end
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        -- ESP Logic
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if CFG.ESP.Boxes and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if CFG.ESP.TeamCheck and p.Team == LocalPlayer.Team then
                        ClearESP(p)
                    else
                        if not ESPList[p] then
                            local sq = Drawing.new("Square")
                            sq.Visible = false
                            sq.Color = Color3.fromRGB(255, 0, 255)
                            sq.Thickness = 1.5
                            sq.Filled = false
                            ESPList[p] = sq
                        end
                        local hrp = p.Character.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local size = Vector2.new(2000 / pos.Z, 3500 / pos.Z)
                            local sq = ESPList[p]
                            sq.Size = size
                            sq.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                            sq.Visible = true
                        else
                            if ESPList[p] then ESPList[p].Visible = false end
                        end
                    end
                else
                    ClearESP(p)
                end
            end
        end

        -- Aimbot Logic
        if CFG.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closest, shortest = nil, CFG.Aimbot.FOV
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(CFG.Aimbot.Part) and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if CFG.ESP.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local part = p.Character[CFG.Aimbot.Part]
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = part
                        end
                    end
                end
            end
            if closest then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 1 / CFG.Aimbot.Smoothness)
            end
        end
    end)
end)

-- UI on K
pcall(function()
    if CoreGui:FindFirstChild("RivalsUltimateHub") then CoreGui.RivalsUltimateHub:Destroy() end
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "RivalsUltimateHub"
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 360, 0, 280)
    frame.Position = UDim2.new(0.5, -180, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.Text = "Rivals Luraph/Xeno Hub [K]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    
    local tCorner = Instance.new("UICorner", title)
    tCorner.CornerRadius = UDim.new(0, 8)
    
    local function AddBtn(text, y, callback)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 320, 0, 35)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = text .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Medium
        btn.TextSize = 14
        
        local bCorner = Instance.new("UICorner", btn)
        bCorner.CornerRadius = UDim.new(0, 6)
        
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            btn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 200, 200)
            callback(state)
        end)
    end
    
    AddBtn("Aimbot", 55, function(v) CFG.Aimbot.Enabled = v end)
    AddBtn("Silent Aim", 100, function(v) CFG.SilentAim.Enabled = v end)
    AddBtn("ESP Boxes", 145, function(v) CFG.ESP.Boxes = v end)
    AddBtn("Team Check", 190, function(v) CFG.ESP.TeamCheck = v end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.K then
            frame.Visible = not frame.Visible
        end
    end)
end)
