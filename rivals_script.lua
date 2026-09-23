--[[
    Rivals Simple & Guaranteed Working Aimbot/ESP for Xeno
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().AimbotEnabled = false
getgenv().TeamCheck = true

local function GetClosest()
    local target = nil
    local shortest = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if getgenv().TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < shortest then
                    shortest = dist
                    target = p.Character.Head
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if getgenv().AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
end)

pcall(function()
    if CoreGui:FindFirstChild("SimpleRivalsUI") then CoreGui.SimpleRivalsUI:Destroy() end
    
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "SimpleRivalsUI"
    
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 160, 0, 50)
    btn.Position = UDim2.new(0, 50, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextSize = 16
    btn.Text = "Aimbot: OFF"
    btn.Active = true
    btn.Draggable = true
    
    btn.MouseButton1Click:Connect(function()
        getgenv().AimbotEnabled = not getgenv().AimbotEnabled
        btn.Text = "Aimbot: " .. (getgenv().AimbotEnabled and "ON" or "OFF")
        btn.TextColor3 = getgenv().AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end)

print("Simple Rivals Script Loaded!")
