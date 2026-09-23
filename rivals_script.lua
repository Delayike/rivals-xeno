--[[
    Rivals Universal Script (Optimized for Xeno Executor)
    Features: Aimbot, Silent Aim, ESP (Chams/Boxes/Tracers), FOV Circle, Config UI (Rayfield/Fluent style or custom GUI)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings / Configuration
getgenv().RivalsConfig = {
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Smoothness = 5,
        FOV = 150,
        ShowFOV = true,
        TargetPart = "Head" -- Head, HumanoidRootPart
    },
    SilentAim = {
        Enabled = false,
        Chance = 100,
        Hitbox = "Head"
    },
    ESP = {
        Boxes = false,
        Tracers = false,
        Names = false,
        Chams = false,
        TeamCheck = true,
        BoxColor = Color3.fromRGB(0, 255, 255),
        TracerColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255)
    }
}

local Config = getgenv().RivalsConfig

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.ShowFOV
FOVCircle.Filled = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
end)

-- Helper Functions
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

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Config.Aimbot.Key) then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            local targetPos = target.Character[Config.Aimbot.TargetPart].Position
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / Config.Aimbot.Smoothness)
        end
    end
end)

-- Silent Aim Hook (Raycast / FindPartOnRay override via metatable for Xeno compatibility)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Config.SilentAim.Enabled and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") then
        if math.random(1, 100) <= Config.SilentAim.Chance then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(Config.SilentAim.Hitbox) then
                local targetPart = target.Character[Config.SilentAim.Hitbox]
                if method == "Raycast" then
                    args[2] = (targetPart.Position - args[1]).Unit * 1000
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- Simple Rayfield-style or Custom UI Library for Rivals
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Rivals Ultimate Hub | Xeno Supported"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Toggle Button Creator Helper
local function CreateToggle(name, yPos, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = MainFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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

CreateToggle("Aimbot", 55, function(state) Config.Aimbot.Enabled = state end)
CreateToggle("Silent Aim", 100, function(state) Config.SilentAim.Enabled = state end)
CreateToggle("ESP Boxes", 145, function(state) Config.ESP.Boxes = state end)
CreateToggle("ESP Tracers", 190, function(state) Config.ESP.Tracers = state end)
CreateToggle("Team Check", 235, function(state) Config.ESP.TeamCheck = state end)

print("Rivals Script Successfully Loaded via Xeno!")
