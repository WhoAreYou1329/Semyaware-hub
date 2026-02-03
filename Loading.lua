local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MaintenanceScreen"
screenGui.IgnoreGuiInset = true 
screenGui.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BorderSizePixel = 0
background.Parent = screenGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Hello. Currently we testing new features.\nPlease, wait about 30 minutes - 1 hour"
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true 
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextStrokeTransparency = 0 
textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
textLabel.Parent = screenGui
