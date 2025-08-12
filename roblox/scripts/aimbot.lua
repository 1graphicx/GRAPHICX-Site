--[[
    Aimbot Script for Roblox
    Created by GRAPHICX
    Version: 1.0
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Settings
local AimbotEnabled = false
local Smoothness = 0.1
local FOV = 100
local TeamCheck = true
local VisibilityCheck = true
local TargetPart = "Head"

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
Title.Text = "Aimbot Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(1, -20, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Text = "Aimbot: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

local SmoothnessLabel = Instance.new("TextLabel")
SmoothnessLabel.Name = "SmoothnessLabel"
SmoothnessLabel.Size = UDim2.new(1, -20, 0, 20)
SmoothnessLabel.Position = UDim2.new(0, 10, 0, 80)
SmoothnessLabel.BackgroundTransparency = 1
SmoothnessLabel.Text = "Smoothness: " .. Smoothness
SmoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessLabel.TextSize = 12
SmoothnessLabel.Font = Enum.Font.SourceSans
SmoothnessLabel.Parent = MainFrame

local SmoothnessSlider = Instance.new("TextButton")
SmoothnessSlider.Name = "SmoothnessSlider"
SmoothnessSlider.Size = UDim2.new(1, -20, 0, 20)
SmoothnessSlider.Position = UDim2.new(0, 10, 0, 100)
SmoothnessSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SmoothnessSlider.Text = "Adjust Smoothness"
SmoothnessSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessSlider.Font = Enum.Font.SourceSans
SmoothnessSlider.TextSize = 12
SmoothnessSlider.Parent = MainFrame

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Name = "FOVLabel"
FOVLabel.Size = UDim2.new(1, -20, 0, 20)
FOVLabel.Position = UDim2.new(0, 10, 0, 130)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. FOV
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 12
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.Parent = MainFrame

local FOVSlider = Instance.new("TextButton")
FOVSlider.Name = "FOVSlider"
FOVSlider.Size = UDim2.new(1, -20, 0, 20)
FOVSlider.Position = UDim2.new(0, 10, 0, 150)
FOVSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOVSlider.Text = "Adjust FOV"
FOVSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVSlider.Font = Enum.Font.SourceSans
FOVSlider.TextSize = 12
FOVSlider.Parent = MainFrame

-- FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, FOV * 2, 0, FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -FOV, 0.5, -FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 1
FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.Parent = ScreenGui

-- Functions
function GetClosestPlayer()
    local MaxDistance = FOV
    local Target = nil
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild(TargetPart) then
            local Humanoid = Player.Character.Humanoid
            local RootPart = Player.Character.HumanoidRootPart
            local TargetPart = Player.Character:FindFirstChild(TargetPart)
            
            if Humanoid.Health > 0 then
                -- Team Check
                if TeamCheck and LocalPlayer.Team == Player.Team then
                    continue
                end
                
                -- Visibility Check
                if VisibilityCheck then
                    local Ray = Ray.new(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000)
                    local Hit, _ = workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character, Player.Character})
                    if Hit then
                        continue
                    end
                end
                
                local Distance = (TargetPart.Position - Camera.CFrame.Position).Magnitude
                if Distance <= MaxDistance then
                    MaxDistance = Distance
                    Target = Player
                end
            end
        end
    end
    
    return Target
end

function AimAtPlayer(Player)
    if Player and Player.Character and Player.Character:FindFirstChild(TargetPart) then
        local TargetPart = Player.Character:FindFirstChild(TargetPart)
        local TargetPosition = TargetPart.Position
        
        local CurrentCFrame = Camera.CFrame
        local TargetCFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)
        
        Camera.CFrame = CurrentCFrame:Lerp(TargetCFrame, Smoothness)
    end
end

-- Event handlers
ToggleButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "Aimbot: ON"
        FOVCircle.Visible = true
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "Aimbot: OFF"
        FOVCircle.Visible = false
    end
end)

SmoothnessSlider.MouseButton1Click:Connect(function()
    local newSmoothness = Smoothness + 0.1
    if newSmoothness > 1 then
        newSmoothness = 0.1
    end
    Smoothness = newSmoothness
    SmoothnessLabel.Text = "Smoothness: " .. string.format("%.1f", Smoothness)
end)

FOVSlider.MouseButton1Click:Connect(function()
    local newFOV = FOV + 25
    if newFOV > 500 then
        newFOV = 50
    end
    FOV = newFOV
    FOVLabel.Text = "FOV: " .. FOV
    FOVCircle.Size = UDim2.new(0, FOV * 2, 0, FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -FOV, 0.5, -FOV)
end)

-- Make window draggable
local dragging = false
local dragStart = nil
local startPos = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target then
            AimAtPlayer(Target)
        end
    end
end)

-- Keybind (Right Click)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = true
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "Aimbot: ON"
        FOVCircle.Visible = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = false
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "Aimbot: OFF"
        FOVCircle.Visible = false
    end
end)

print("Aimbot Script loaded successfully!")
print("Right-click to activate aimbot")
print("Use the GUI to adjust settings") 