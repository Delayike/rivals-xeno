--[[
    Rivals Universal Script - Working Hook & Aimbot for Xeno
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
        Key = Enum.UserInputType.MouseButton2,
        Smoothness = 3,
        FOV = 200,
        ShowFOV = true,
        TargetPart = "Head"
    },
    SilentAim = {
        Enabled = false,
        Chance = 100,
        Hitbox = "Head"
    },
    ESP = {
        TeamCheck = true
    }
}

local Config = getgenv().RivalsConfig

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.ShowFOV
FOVCircle.Filled = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.8

RunService.RenderStepped:Connect(function()
    pcall(function()
        FOVCircle.Radius = Config.Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
    end)
end)

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if targetPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Camera Aimbot
RunService.RenderStepped:Connect(function()
    pcall(function()
        if Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Config.Aimbot.Key) then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
                local targetPos = target.Character[Config.Aimbot.TargetPart].Position
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 1 / Config.Aimbot.Smoothness)
            end
        end
    end)
end)

-- Silent Aim Hook using Xeno supported methods
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Config.SilentAim.Enabled and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Config.SilentAim.Hitbox) then
            local targetPart = target.Character[Config.SilentAim.Hitbox]
            if method == "Raycast" and args[1] then
                args[2] = (targetPart.Position - args[1]).Unit * 1000
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- GUI
pcall(function()
    if CoreGui:FindFirstChild("RivalsHub") then
        CoreGui.RivalsHub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsHub"
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
    MainFrame.Size = UDim2.new(0, 400, 0, 240)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Rivals Working Hub (Xeno)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

    local function CreateToggle(name, yPos, callback)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Parent = MainFrame
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ToggleBtn.Position = UDim2.new(0, 20, 0, yPos)
        ToggleBtn.Size = UDim2.new(0, 360, 0, 35)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = name .. ": OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ToggleBtn.TextSize = 14
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = ToggleBtn
        
        local state = false
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            ToggleBtn.Text = name .. ": " .. (state and "ON" or "OFF")
            ToggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 200, 200)
            callback(state)
        end)
    end

    CreateToggle("Aimbot (Hold RMB)", 55, function(state) Config.Aimbot.Enabled = state end)
    CreateToggle("Silent Aim", 100, function(state) Config.SilentAim.Enabled = state end)
    CreateToggle("Team Check", 145, function(state) Config.ESP.TeamCheck = state end)
end)

print("Rivals Script Fully Loaded and Active!")
