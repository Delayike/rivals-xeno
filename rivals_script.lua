--[[
    Rivals Simple Working Universal Hub (Xeno Safe)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().Rivals = {
    Aimbot = false,
    ESP = false,
    TeamCheck = true
}

local Config = getgenv().Rivals

-- Simple ESP Drawing
local ESPPool = {}

local function RemoveESP(p)
    if ESPPool[p] then
        pcall(function() ESPPool[p]:Remove() end)
        ESPPool[p] = nil
    end
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        -- ESP Boxes
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if Config.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if Config.TeamCheck and p.Team == LocalPlayer.Team then
                        RemoveESP(p)
                    else
                        if not ESPPool[p] then
                            local sq = Drawing.new("Square")
                            sq.Visible = false
                            sq.Color = Color3.fromRGB(0, 255, 0)
                            sq.Thickness = 1
                            sq.Filled = false
                            ESPPool[p] = sq
                        end
                        local hrp = p.Character.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local size = Vector2.new(2000 / pos.Z, 3500 / pos.Z)
                            local sq = ESPPool[p]
                            sq.Size = size
                            sq.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                            sq.Visible = true
                        else
                            if ESPPool[p] then ESPPool[p].Visible = false end
                        end
                    end
                else
                    RemoveESP(p)
                end
            end
        end

        -- Aimbot
        if Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closest, shortest = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local head = p.Character.Head
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = head
                        end
                    end
                end
            end
            if closest then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
            end
        end
    end)
end)

-- UI on K
pcall(function()
    if CoreGui:FindFirstChild("RivalsSimpleUI") then CoreGui.RivalsSimpleUI:Destroy() end
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "RivalsSimpleUI"
    
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 300, 0, 220)
    f.Position = UDim2.new(0.5, -150, 0.5, -110)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    f.Active = true
    f.Draggable = true
    
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.Text = "Rivals Menu [K]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)
    
    local function mkBtn(text, y, var)
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0, 260, 0, 35)
        b.Position = UDim2.new(0, 20, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        b.Text = text .. ": OFF"
        b.TextColor3 = Color3.fromRGB(200, 200, 200)
        b.Font = Enum.Font.Gotham
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        
        b.MouseButton1Click:Connect(function()
            Config[var] = not Config[var]
            b.Text = text .. ": " .. (Config[var] and "ON" or "OFF")
            b.TextColor3 = Config[var] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
        end)
    end
    
    mkBtn("Aimbot", 50, "Aimbot")
    mkBtn("ESP Boxes", 95, "ESP")
    mkBtn("Team Check", 140, "TeamCheck")
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.K then
            f.Visible = not f.Visible
        end
    end)
end)
