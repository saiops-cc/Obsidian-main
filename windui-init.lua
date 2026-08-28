--[[
    SAIOPS HUB - Powered by WindUI Library
    A feature-rich, high-performance Roblox UI script with zero stubs.
    Custom Theme: NeonEdge (Royal Purple & Sky Cyan, Sharp Corners)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Define NeonEdge Theme according to design.md specs (Zero border-radius, Deep purple background, sky surge cyan accents)
WindUI:AddTheme({
    Name = "NeonEdge",
    Accent = Color3.fromHex("#48bfe3"),       -- Sky Surge Cyan
    Background = Color3.fromHex("#170025"),   -- Deepest Purple
    Outline = Color3.fromHex("#5e60ce"),      -- Slate Blue Border
    Dialog = Color3.fromHex("#2f0049"),       -- Surface Purple
    Text = Color3.fromHex("#edf6f9"),         -- Off-white text
    Placeholder = Color3.fromHex("#b8dcf2"),  -- Cloudy Sky secondary text
    Button = Color3.fromHex("#48bfe3"),       -- Accent buttons
    Icon = Color3.fromHex("#80ffdb")          -- Aquamarine highlights
})

-- Create Window with NeonEdge Custom Theme & Floating Open Button
local Window = WindUI:CreateWindow({
    Title = "SAIOPS HUB",
    Icon = "rbxassetid://85515149149740",
    Author = "SAIOPS.CC",
    Folder = "SAIOPS_HUB_CONFIG",
    Size = UDim2.fromOffset(580, 460),
    Theme = "NeonEdge",
    Transparent = false,
    ToggleKey = Enum.KeyCode.RightShift, -- Toggle with Right Shift key
    OpenButton = {
        Title = "Open SAIOPS HUB",
        Icon = "rbxassetid://85515149149740", -- User logo/icon
        Enabled = true,
        Draggable = true,
        CornerRadius = UDim.new(0, 0), -- Sharp 0px corners matching design.md
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("#48bfe3"), Color3.fromHex("#80ffdb")),
    }
})

-- Welcome Notification
WindUI:Notify({
    Title = "SAIOPS HUB Loaded",
    Content = "Press Right Shift or use the floating button to toggle the menu.",
    Icon = "rbxassetid://85515149149740",
    Duration = 5
})

-- Helper to find the WindUI ScreenGui
local function getWindScreenGui()
    local parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ScreenGui") and (child.Name == "WindUI" or child:FindFirstChild("Main") or child:FindFirstChild("WindUI")) then
            return child
        end
    end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, child in ipairs(playerGui:GetChildren()) do
            if child:IsA("ScreenGui") and (child.Name == "WindUI" or child:FindFirstChild("Main") or child:FindFirstChild("WindUI")) then
                return child
            end
        end
    end
    return nil
end

-- Create Custom Launcher ScreenGui (Independent UI that stays visible on minimize)
local LauncherGui = Instance.new("ScreenGui")
LauncherGui.Name = "SAIOPS_Launcher"
LauncherGui.ResetOnSpawn = false
LauncherGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LauncherGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "MainFrame"
ButtonFrame.Size = UDim2.fromOffset(50, 50)
ButtonFrame.Position = UDim2.new(1, -70, 1, -70) -- Bottom-right corner
ButtonFrame.BackgroundColor3 = Color3.fromHex("#170025") -- Deepest Purple
ButtonFrame.BorderSizePixel = 1
ButtonFrame.BorderColor3 = Color3.fromHex("#5e60ce") -- Slate Blue
ButtonFrame.Active = true
ButtonFrame.Parent = LauncherGui

local ImageButton = Instance.new("ImageButton")
ImageButton.Name = "LogoButton"
ImageButton.Size = UDim2.fromScale(1, 1)
ImageButton.BackgroundTransparency = 1
ImageButton.Image = "rbxassetid://85515149149740" -- Logo
ImageButton.Parent = ButtonFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromHex("#5e60ce")
UIStroke.Thickness = 1.5
UIStroke.Parent = ButtonFrame

-- Smooth custom drag scripting for the Launcher button
local dragging = false
local dragInput, dragStart, startPos

ButtonFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ButtonFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ButtonFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ButtonFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Unified window toggle logic that handles both ScreenGui status and MainFrame visibility state
local function toggleWindowVisibility()
    if Window and Window.Toggle then
        pcall(function()
            Window:Toggle()
        end)
    else
        local windGui = getWindScreenGui()
        if windGui then
            local mainFrame = windGui:FindFirstChild("Main") or windGui:FindFirstChildOfClass("Frame") or windGui:FindFirstChildOfClass("CanvasGroup")
            if mainFrame then
                local isCurrentlyVisible = windGui.Enabled and mainFrame.Visible
                if isCurrentlyVisible then
                    windGui.Enabled = false
                    mainFrame.Visible = false
                else
                    windGui.Enabled = true
                    mainFrame.Visible = true
                end
            else
                windGui.Enabled = not windGui.Enabled
            end
        end
    end
end

-- Render loop to automatically sync the Launcher border color with the actual UI visibility
local syncConnection
syncConnection = RunService.RenderStepped:Connect(function()
    if LauncherGui and LauncherGui.Parent then
        local windGui = getWindScreenGui()
        local mainFrame = windGui and (windGui:FindFirstChild("Main") or windGui:FindFirstChildOfClass("Frame") or windGui:FindFirstChildOfClass("CanvasGroup"))
        local isActive = windGui and windGui.Enabled and (mainFrame and mainFrame.Visible or false)
        local targetColor = isActive and Color3.fromHex("#48bfe3") or Color3.fromHex("#5e60ce")
        UIStroke.Color = UIStroke.Color:Lerp(targetColor, 0.15)
    end
end)

-- Hover Effects
ImageButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(UIStroke, TweenInfo.new(0.2), {Color = Color3.fromHex("#48bfe3")}):Play()
end)

ImageButton.MouseLeave:Connect(function()
    local windGui = getWindScreenGui()
    local mainFrame = windGui and (windGui:FindFirstChild("Main") or windGui:FindFirstChildOfClass("Frame") or windGui:FindFirstChildOfClass("CanvasGroup"))
    local isActive = windGui and windGui.Enabled and (mainFrame and mainFrame.Visible or false)
    local targetColor = isActive and Color3.fromHex("#48bfe3") or Color3.fromHex("#5e60ce")
    game:GetService("TweenService"):Create(UIStroke, TweenInfo.new(0.2), {Color = targetColor}):Play()
end)

-- Toggle click handler
ImageButton.MouseButton1Click:Connect(toggleWindowVisibility)
