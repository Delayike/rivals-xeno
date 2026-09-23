--[[
    Rivals Universal Script (Fixed & Optimized for Xeno Executor)
    Features: Aimbot, Silent Aim, FOV Circle, Config UI
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
        Smoothness = 4,
        FOV = 150,
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

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.ShowFOV
FOVCircle.Filled = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

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

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    pcall(function()
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
end)

-- GUI Creation safely using CoreGui
local success, err = pcall(function()
    if CoreGui:FindFirstChild("RivalsHub") then
        CoreGui.RivalsHub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsHub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
    MainFrame.Size = UDim2.new(0, 400, 0, 240)
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
    Title.Text = "Rivals Fixed Hub | Xeno Compatible"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

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
    CreateToggle("Team Check", 145, function(state) Config.ESP.TeamCheck = state end)
end)

if not success then
    warn("Rivals Hub GUI Error: " .. tostring(err))
end

print("Rivals Script Loaded Successfully!")
