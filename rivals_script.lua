--[[
    Rivals Universal Script (Optimized for Xeno)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().RivalsSettings = {
    Aimbot = false,
    ESP = false,
    TeamCheck = true,
    Smoothness = 6,
    Keybind = Enum.KeyCode.K
}

local Settings = getgenv().RivalsSettings
local pcall = pcall
local Drawing = Drawing
local ESPBoxes = {}

local function RemoveESP(player)
    if ESPBoxes[player] then
        for _, box in pairs(ESPBoxes[player]) do
            pcall(function() box:Remove() end)
        end
        ESPBoxes[player] = nil
    end
end

local function CreateESP(player)
    if ESPBoxes[player] then return end
    local success, box = pcall(function()
        local sq = Drawing.new("Square")
        sq.Visible = false
        sq.Color = Color3.fromRGB(0, 255, 255)
        sq.Thickness = 1.5
        sq.Filled = false
        sq.Transparency = 1
        return sq
    end)
    if success and box then
        ESPBoxes[player] = {Box = box}
    end
end

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if Settings.ESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                        RemoveESP(player)
                    else
                        if not ESPBoxes[player] then CreateESP(player) end
                        local hrp = player.Character.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen and ESPBoxes[player] and ESPBoxes[player].Box then
                            local size = Vector2.new(2000 / pos.Z, 3500 / pos.Z)
                            local box = ESPBoxes[player].Box
                            box.Size = size
                            box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                            box.Visible = true
                        else
                            if ESPBoxes[player] and ESPBoxes[player].Box then ESPBoxes[player].Box.Visible = false end
                        end
                    end
                else
                    RemoveESP(player)
                end
            end
        end

        if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closest = nil
            local shortestDist = math.huge

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                    
                    local head = player.Character.Head
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = head
                        end
                    end
                end
            end

            if closest then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Settings.Smoothness)
            end
        end
    end)
end)

pcall(function()
    if CoreGui:FindFirstChild("RivalsModernHub") then
        CoreGui.RivalsModernHub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsModernHub"
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
    MainFrame.Size = UDim2.new(0, 350, 0, 260)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    local Header = Instance.new("TextLabel")
    Header.Parent = MainFrame
    Header.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.Font = Enum.Font.GothamBold
    Header.Text = "Rivals Menu [K]"
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextSize = 16

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local function MakeToggle(name, yPos, stateVar)
        local btn = Instance.new("TextButton")
        btn.Parent = MainFrame
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.Position = UDim2.new(0, 20, 0, yPos)
        btn.Size = UDim2.new(0, 310, 0, 40)
        btn.Font = Enum.Font.GothamMedium
        btn.Text = name .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 14

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            Settings[stateVar] = not Settings[stateVar]
            local active = Settings[stateVar]
            btn.Text = name .. ": " .. (active and "ON" or "OFF")
            btn.TextColor3 = active and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
        end)
    end

    MakeToggle("Smooth Aimbot", 60, "Aimbot")
    MakeToggle("ESP Boxes", 115, "ESP")
    MakeToggle("Team Check", 170, "TeamCheck")

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Settings.Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end)
