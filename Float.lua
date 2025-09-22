local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,150,0,50)
frame.Position = UDim2.new(0.4,0,0.1,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local button = Instance.new("TextButton")
button.Size = UDim2.new(1,0,1,0)
button.Text = "Flutuar OFF"
button.Parent = frame

local ativo = false
button.MouseButton1Click:Connect(function()
    ativo = not ativo
    button.Text = ativo and "Flutuar ON" or "Flutuar OFF"
end)

RunService.Heartbeat:Connect(function()
    if ativo and hrp then
        hrp.Velocity = cam.CFrame.LookVector * 25
    end
end)
