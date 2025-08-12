--[[
    Dex Explorer Script for Roblox
    Created by GRAPHICX
    Version: 1.0
]]

local Dex = {}
Dex.__index = Dex

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DexExplorer"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
Title.Text = "Dex Explorer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = Title

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -20, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 50)
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.Text = "Search objects..."
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Search objects..."
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 14
SearchBox.Parent = MainFrame

local ObjectList = Instance.new("ScrollingFrame")
ObjectList.Name = "ObjectList"
ObjectList.Size = UDim2.new(0.5, -15, 1, -100)
ObjectList.Position = UDim2.new(0, 10, 0, 90)
ObjectList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ObjectList.BorderSizePixel = 0
ObjectList.ScrollBarThickness = 6
ObjectList.Parent = MainFrame

local PropertiesFrame = Instance.new("ScrollingFrame")
PropertiesFrame.Name = "PropertiesFrame"
PropertiesFrame.Size = UDim2.new(0.5, -15, 1, -100)
PropertiesFrame.Position = UDim2.new(0.5, 5, 0, 90)
PropertiesFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PropertiesFrame.BorderSizePixel = 0
PropertiesFrame.ScrollBarThickness = 6
PropertiesFrame.Parent = MainFrame

-- Functions
function Dex:CreatePropertyLabel(name, value)
    local PropertyFrame = Instance.new("Frame")
    PropertyFrame.Size = UDim2.new(1, -10, 0, 25)
    PropertyFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    PropertyFrame.BorderSizePixel = 0
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.SourceSans
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = PropertyFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.6, -5, 1, 0)
    ValueLabel.Position = UDim2.new(0.4, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.SourceSans
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.Parent = PropertyFrame
    
    return PropertyFrame
end

function Dex:UpdateObjectList()
    -- Clear existing list
    for _, child in pairs(ObjectList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local objects = {}
    local function addObjects(parent, prefix)
        for _, child in pairs(parent:GetChildren()) do
            table.insert(objects, {object = child, name = prefix .. child.Name})
            addObjects(child, prefix .. child.Name .. ".")
        end
    end
    
    addObjects(game, "")
    
    -- Filter by search
    local searchText = SearchBox.Text:lower()
    local filteredObjects = {}
    for _, obj in pairs(objects) do
        if searchText == "" or obj.name:lower():find(searchText) then
            table.insert(filteredObjects, obj)
        end
    end
    
    -- Create buttons
    for i, obj in pairs(filteredObjects) do
        if i <= 50 then -- Limit to 50 objects for performance
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 25)
            Button.Position = UDim2.new(0, 5, 0, (i-1) * 30)
            Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Button.BorderSizePixel = 0
            Button.Text = obj.name
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 12
            Button.Font = Enum.Font.SourceSans
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = ObjectList
            
            Button.MouseButton1Click:Connect(function()
                Dex:ShowProperties(obj.object)
            end)
        end
    end
end

function Dex:ShowProperties(object)
    -- Clear existing properties
    for _, child in pairs(PropertiesFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Add object name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -10, 0, 30)
    NameLabel.Position = UDim2.new(0, 5, 0, 5)
    NameLabel.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
    NameLabel.Text = object.Name .. " (" .. object.ClassName .. ")"
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 14
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.Parent = PropertiesFrame
    
    local yOffset = 40
    
    -- Show properties
    local properties = {
        "Name", "ClassName", "Parent", "Position", "Size", "Color", "Transparency",
        "Anchored", "CanCollide", "Material", "BrickColor", "CFrame"
    }
    
    for _, propName in pairs(properties) do
        local success, value = pcall(function() return object[propName] end)
        if success then
            local PropertyLabel = Dex:CreatePropertyLabel(propName, value)
            PropertyLabel.Position = UDim2.new(0, 5, 0, yOffset)
            PropertyLabel.Parent = PropertiesFrame
            yOffset = yOffset + 30
        end
    end
end

-- Event handlers
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

SearchBox.Changed:Connect(function(property)
    if property == "Text" then
        Dex:UpdateObjectList()
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

-- Initialize
Dex:UpdateObjectList()

-- Return the Dex object
return Dex 