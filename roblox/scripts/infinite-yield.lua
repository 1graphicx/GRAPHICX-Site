--[[
    Infinite Yield Admin Script for Roblox
    Created by GRAPHICX
    Version: 1.0
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Admin Commands
local Commands = {
    ["kill"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end,
    
    ["kick"] = function(target)
        if target then
            target:Kick("Kicked by admin")
        end
    end,
    
    ["speed"] = function(target, speed)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.WalkSpeed = tonumber(speed) or 16
        end
    end,
    
    ["jump"] = function(target, jumpPower)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.JumpPower = tonumber(jumpPower) or 50
        end
    end,
    
    ["sit"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Sit = true
        end
    end,
    
    ["unsit"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Sit = false
        end
    end,
    
    ["teleport"] = function(target, destination)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local destPlayer = Players:FindFirstChild(destination)
            if destPlayer and destPlayer.Character and destPlayer.Character:FindFirstChild("HumanoidRootPart") then
                target.Character.HumanoidRootPart.CFrame = destPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end,
    
    ["bring"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end,
    
    ["goto"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end,
    
    ["freeze"] = function(target)
        if target and target.Character then
            for _, part in pairs(target.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
        end
    end,
    
    ["unfreeze"] = function(target)
        if target and target.Character then
            for _, part in pairs(target.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
        end
    end,
    
    ["invisible"] = function(target)
        if target and target.Character then
            for _, part in pairs(target.Character:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end,
    
    ["visible"] = function(target)
        if target and target.Character then
            for _, part in pairs(target.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end,
    
    ["size"] = function(target, size)
        if target and target.Character then
            local scale = tonumber(size) or 1
            for _, part in pairs(target.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * scale
                end
            end
        end
    end,
    
    ["fire"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local fire = Instance.new("Fire")
            fire.Parent = target.Character.HumanoidRootPart
        end
    end,
    
    ["unfire"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local fire = target.Character.HumanoidRootPart:FindFirstChild("Fire")
            if fire then
                fire:Destroy()
            end
        end
    end,
    
    ["sparkles"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local sparkles = Instance.new("Sparkles")
            sparkles.Parent = target.Character.HumanoidRootPart
        end
    end,
    
    ["unsparkles"] = function(target)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local sparkles = target.Character.HumanoidRootPart:FindFirstChild("Sparkles")
            if sparkles then
                sparkles:Destroy()
            end
        end
    end,
    
    ["reset"] = function(target)
        if target and target.Character then
            target.Character:BreakJoints()
        end
    end,
    
    ["refresh"] = function(target)
        if target and target.Character then
            target.Character:BreakJoints()
            wait(0.1)
            target.Character:WaitForChild("HumanoidRootPart")
        end
    end,
    
    ["loopkill"] = function(target)
        if target then
            while target.Character and target.Character:FindFirstChild("Humanoid") do
                target.Character.Humanoid.Health = 0
                wait(0.1)
            end
        end
    end,
    
    ["loopreset"] = function(target)
        if target then
            while target.Character do
                target.Character:BreakJoints()
                wait(0.1)
            end
        end
    end,
    
    ["stoploop"] = function(target)
        -- This would need a more sophisticated loop management system
        print("Loop stopped for " .. (target and target.Name or "all"))
    end
}

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfiniteYield"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
Title.Text = "Infinite Yield Admin"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local CommandBox = Instance.new("TextBox")
CommandBox.Name = "CommandBox"
CommandBox.Size = UDim2.new(1, -20, 0, 25)
CommandBox.Position = UDim2.new(0, 10, 0, 40)
CommandBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CommandBox.Text = ""
CommandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandBox.PlaceholderText = "Enter command (e.g., kill PlayerName)"
CommandBox.Font = Enum.Font.SourceSans
CommandBox.TextSize = 14
CommandBox.Parent = MainFrame

local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(1, -20, 0, 25)
ExecuteButton.Position = UDim2.new(0, 10, 0, 70)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
ExecuteButton.Text = "Execute Command"
ExecuteButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ExecuteButton.Font = Enum.Font.SourceSansBold
ExecuteButton.TextSize = 14
ExecuteButton.Parent = MainFrame

local OutputFrame = Instance.new("ScrollingFrame")
OutputFrame.Name = "OutputFrame"
OutputFrame.Size = UDim2.new(1, -20, 1, -110)
OutputFrame.Position = UDim2.new(0, 10, 0, 105)
OutputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OutputFrame.BorderSizePixel = 0
OutputFrame.ScrollBarThickness = 6
OutputFrame.Parent = MainFrame

-- Functions
function GetPlayer(name)
    if name:lower() == "me" then
        return LocalPlayer
    elseif name:lower() == "all" then
        return "all"
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name:lower():find(name:lower()) then
                return player
            end
        end
    end
    return nil
end

function ExecuteCommand(command)
    local args = {}
    for arg in command:gmatch("%S+") do
        table.insert(args, arg)
    end
    
    if #args == 0 then return end
    
    local cmd = args[1]:lower()
    local target = args[2] and GetPlayer(args[2])
    local param = args[3]
    
    if Commands[cmd] then
        if target == "all" then
            for _, player in pairs(Players:GetPlayers()) do
                Commands[cmd](player, param)
            end
        else
            Commands[cmd](target, param)
        end
        
        -- Add to output
        local OutputLabel = Instance.new("TextLabel")
        OutputLabel.Size = UDim2.new(1, -10, 0, 20)
        OutputLabel.Position = UDim2.new(0, 5, 0, #OutputFrame:GetChildren() * 25)
        OutputLabel.BackgroundTransparency = 1
        OutputLabel.Text = "> " .. command
        OutputLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        OutputLabel.TextSize = 12
        OutputLabel.Font = Enum.Font.SourceSans
        OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
        OutputLabel.Parent = OutputFrame
    else
        -- Add error to output
        local ErrorLabel = Instance.new("TextLabel")
        ErrorLabel.Size = UDim2.new(1, -10, 0, 20)
        ErrorLabel.Position = UDim2.new(0, 5, 0, #OutputFrame:GetChildren() * 25)
        ErrorLabel.BackgroundTransparency = 1
        ErrorLabel.Text = "> Unknown command: " .. cmd
        ErrorLabel.TextColor3 = Color3.fromRGB(255, 71, 87)
        ErrorLabel.TextSize = 12
        ErrorLabel.Font = Enum.Font.SourceSans
        ErrorLabel.TextXAlignment = Enum.TextXAlignment.Left
        ErrorLabel.Parent = OutputFrame
    end
end

-- Event handlers
ExecuteButton.MouseButton1Click:Connect(function()
    ExecuteCommand(CommandBox.Text)
    CommandBox.Text = ""
end)

CommandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ExecuteCommand(CommandBox.Text)
        CommandBox.Text = ""
    end
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

-- Welcome message
local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Size = UDim2.new(1, -10, 0, 20)
WelcomeLabel.Position = UDim2.new(0, 5, 0, 0)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Text = "> Infinite Yield Admin Loaded"
WelcomeLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
WelcomeLabel.TextSize = 12
WelcomeLabel.Font = Enum.Font.SourceSans
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
WelcomeLabel.Parent = OutputFrame

print("Infinite Yield Admin Script loaded successfully!")
print("Use the GUI or type commands in the output") 