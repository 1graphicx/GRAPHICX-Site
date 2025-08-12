--[[
    Speed Hack Script for Roblox
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
local SpeedEnabled = false
local SpeedMultiplier = 2
local JumpPower = 50
local JumpEnabled = false

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHackGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
Title.Text = "Speed Hack"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Name = "SpeedToggle"
SpeedToggle.Size = UDim2.new(1, -20, 0, 30)
SpeedToggle.Position = UDim2.new(0, 10, 0, 40)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SpeedToggle.Text = "Speed: OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.TextSize = 14
SpeedToggle.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 80)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed Multiplier: " .. SpeedMultiplier
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = MainFrame

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Size = UDim2.new(1, -20, 0, 20)
SpeedSlider.Position = UDim2.new(0, 10, 0, 100)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedSlider.Text = "Adjust Speed"
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.Font = Enum.Font.SourceSans
SpeedSlider.TextSize = 12
SpeedSlider.Parent = MainFrame

local JumpToggle = Instance.new("TextButton")
JumpToggle.Name = "JumpToggle"
JumpToggle.Size = UDim2.new(1, -20, 0, 30)
JumpToggle.Position = UDim2.new(0, 10, 0, 130)
JumpToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
JumpToggle.Text = "High Jump: OFF"
JumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpToggle.Font = Enum.Font.SourceSansBold
JumpToggle.TextSize = 14
JumpToggle.Parent = MainFrame

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Name = "JumpLabel"
JumpLabel.Size = UDim2.new(1, -20, 0, 20)
JumpLabel.Position = UDim2.new(0, 10, 0, 170)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power: " .. JumpPower
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.SourceSans
JumpLabel.Parent = MainFrame

local JumpSlider = Instance.new("TextButton")
JumpSlider.Name = "JumpSlider"
JumpSlider.Size = UDim2.new(1, -20, 0, 20)
JumpSlider.Position = UDim2.new(0, 10, 0, 190)
JumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
JumpSlider.Text = "Adjust Jump"
JumpSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpSlider.Font = Enum.Font.SourceSans
JumpSlider.TextSize = 12
JumpSlider.Parent = MainFrame

local ResetButton = Instance.new("TextButton")
ResetButton.Name = "ResetButton"
ResetButton.Size = UDim2.new(1, -20, 0, 30)
ResetButton.Position = UDim2.new(0, 10, 0, 220)
ResetButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ResetButton.Text = "Reset to Default"
ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetButton.Font = Enum.Font.SourceSansBold
ResetButton.TextSize = 14
ResetButton.Parent = MainFrame

-- Functions
function UpdateSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local Humanoid = LocalPlayer.Character.Humanoid
        if SpeedEnabled then
            Humanoid.WalkSpeed = 16 * SpeedMultiplier
        else
            Humanoid.WalkSpeed = 16
        end
    end
end

function UpdateJump()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local Humanoid = LocalPlayer.Character.Humanoid
        if JumpEnabled then
            Humanoid.JumpPower = JumpPower
        else
            Humanoid.JumpPower = 50
        end
    end
end

-- Event handlers
SpeedToggle.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        SpeedToggle.Text = "Speed: ON"
    else
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        SpeedToggle.Text = "Speed: OFF"
    end
    UpdateSpeed()
end)

SpeedSlider.MouseButton1Click:Connect(function()
    SpeedMultiplier = SpeedMultiplier + 0.5
    if SpeedMultiplier > 10 then
        SpeedMultiplier = 1
    end
    SpeedLabel.Text = "Speed Multiplier: " .. SpeedMultiplier
    UpdateSpeed()
end)

JumpToggle.MouseButton1Click:Connect(function()
    JumpEnabled = not JumpEnabled
    if JumpEnabled then
        JumpToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        JumpToggle.Text = "High Jump: ON"
    else
        JumpToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        JumpToggle.Text = "High Jump: OFF"
    end
    UpdateJump()
end)

JumpSlider.MouseButton1Click:Connect(function()
    JumpPower = JumpPower + 25
    if JumpPower > 500 then
        JumpPower = 50
    end
    JumpLabel.Text = "Jump Power: " .. JumpPower
    UpdateJump()
end)

ResetButton.MouseButton1Click:Connect(function()
    SpeedEnabled = false
    SpeedMultiplier = 2
    JumpEnabled = false
    JumpPower = 50
    
    SpeedToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SpeedToggle.Text = "Speed: OFF"
    SpeedLabel.Text = "Speed Multiplier: " .. SpeedMultiplier
    
    JumpToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    JumpToggle.Text = "High Jump: OFF"
    JumpLabel.Text = "Jump Power: " .. JumpPower
    
    UpdateSpeed()
    UpdateJump()
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

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    UpdateSpeed()
    UpdateJump()
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        SpeedEnabled = not SpeedEnabled
        if SpeedEnabled then
            SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            SpeedToggle.Text = "Speed: ON"
        else
            SpeedToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            SpeedToggle.Text = "Speed: OFF"
        end
        UpdateSpeed()
    elseif input.KeyCode == Enum.KeyCode.Z then
        JumpEnabled = not JumpEnabled
        if JumpEnabled then
            JumpToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            JumpToggle.Text = "High Jump: ON"
        else
            JumpToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            JumpToggle.Text = "High Jump: OFF"
        end
        UpdateJump()
    end
end)

print("Speed Hack Script loaded successfully!")
print("Press X to toggle speed")
print("Press Z to toggle high jump")
print("Use the GUI to adjust settings") 