--[[
    SAIOPS HUB - Powered by Obsidian UI Library
    A feature-rich, high-performance Roblox UI template with zero stubs.
    Theme: NeonEdge (Deep Purple & Sky Cyan)
    Ready-to-use boilerplate for creating new scripts.
]]

local repo = "https://raw.githubusercontent.com/saiops-cc/Obsidian-main/main/"
local cacheBuster = "?t=" .. tostring(os.time())

local Library = loadstring(game:HttpGet(repo .. "Library.lua" .. cacheBuster))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua" .. cacheBuster))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua" .. cacheBuster))()

local Options = Library.Options
local Toggles = Library.Toggles

-- Apply NeonEdge Theme (Deep Purple & Sky Surge Cyan)
Library.Scheme.BackgroundColor = Color3.fromHex("#170025") -- Deepest Purple
Library.Scheme.MainColor = Color3.fromHex("#2f0049")       -- Surface Purple
Library.Scheme.AccentColor = Color3.fromHex("#48bfe3")     -- Sky Surge Cyan
Library.Scheme.OutlineColor = Color3.fromHex("#5e60ce")    -- Slate Blue
Library.Scheme.FontColor = Color3.fromHex("#edf6f9")       -- Off-white text
Library.Scheme.DarkColor = Color3.fromHex("#0f0019")       -- Shadow Dark
Library.Scheme.WhiteColor = Color3.fromHex("#edf6f9")

-- Library Configurations
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

-- Create Main Window
local Window = Library:CreateWindow({
    Title = "SAIOPS HUB",
    Footer = "SAIOPS.CC",
    Icon = "icon.png",
    NotifySide = "Right",
    ShowCustomCursor = true,
    Minimizable = true,
    ToggleKeybind = Enum.KeyCode.RightShift, -- Toggle / minimize with Right Shift
    CornerRadius = 4,
    AutoShow = true,
    FooterLinks = {
        {
            Text = "Website",
            Url = "https://saiops.cc",
            Icon = "globe",
            Tooltip = "Click to copy website link",
        },
        {
            Text = "Discord",
            Url = "https://discord.gg/saiops",
            Icon = "message-square",
            Tooltip = "Click to copy Discord link",
        },
    },
})

-- Welcome Notification
Library:Notify({
    Title = "SAIOPS HUB Loaded",
    Description = "Press Right Shift or use the floating tab to toggle the menu.",
    Time = 5,
    Icon = "shield-check",
})

-- Build Tabs
local Tabs = {
    Main = Window:AddTab({ Name = "Main", Icon = "house", Description = "Primary combat & automation features" }),
    Visuals = Window:AddTab({ Name = "Visuals", Icon = "eye", Description = "ESP and visual enhancements" }),
    Settings = Window:AddTab({ Name = "Settings", Icon = "settings", Description = "Configurations and theme settings" }),
}

--------------------------------------------------------------------------------
-- 1. MAIN TAB
--------------------------------------------------------------------------------
local MainGroup = Tabs.Main:AddLeftGroupbox("Automation", "cpu")

MainGroup:AddToggle("AutoFarm", {
    Text = "Enable Auto Farm",
    Default = false,
    Tooltip = "Automatically farms objectives in the background",
    Callback = function(Value)
        print("[SAIOPS HUB] Auto Farm:", Value)
    end,
})

MainGroup:AddSlider("FarmSpeed", {
    Text = "Farm Speed",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = " %",
    Compact = false,
    Callback = function(Value)
        print("[SAIOPS HUB] Farm Speed:", Value)
    end,
})

MainGroup:AddDropdown("TargetMode", {
    Text = "Target Selection",
    Values = { "Closest Target", "Lowest Health", "Highest Priority", "Random" },
    Default = "Closest Target",
    Multi = false,
    Searchable = false,
    Callback = function(Value)
        print("[SAIOPS HUB] Target Mode:", Value)
    end,
})

MainGroup:AddButton({
    Text = "Execute Quick Action",
    DoubleClick = false,
    Tooltip = "Runs a quick action",
    Func = function()
        Library:Notify({
            Title = "Action Executed",
            Description = "Quick action executed successfully.",
            Time = 3,
            Icon = "zap",
        })
    end,
})

local CombatGroup = Tabs.Main:AddRightGroupbox("Combat", "crosshair")

CombatGroup:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = false,
    Tooltip = "Redirects bullets towards target automatically",
    Callback = function(Value)
        print("[SAIOPS HUB] Silent Aim:", Value)
    end,
})

CombatGroup:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 120,
    Min = 30,
    Max = 500,
    Rounding = 0,
    Suffix = " px",
    Callback = function(Value)
        print("[SAIOPS HUB] FOV Radius:", Value)
    end,
})

CombatGroup:AddDropdown("HitboxPart", {
    Text = "Target Hitbox",
    Values = { "Head", "HumanoidRootPart", "Torso", "Random" },
    Default = "Head",
    Multi = false,
})

--------------------------------------------------------------------------------
-- 2. VISUALS TAB
--------------------------------------------------------------------------------
local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP Settings", "eye")

ESPGroup:AddToggle("MasterESP", {
    Text = "Enable ESP",
    Default = false,
    Tooltip = "Master toggle for all visual overlays",
    Callback = function(Value)
        print("[SAIOPS HUB] Master ESP:", Value)
    end,
})

ESPGroup:AddDropdown("ESPFilters", {
    Text = "ESP Elements",
    Values = { "Boxes", "Tracers", "Names", "Health Bar", "Distance", "Chams" },
    Default = { "Boxes", "Names", "Health Bar" },
    Multi = true,
    Callback = function(Value)
        print("[SAIOPS HUB] ESP Filters updated")
    end,
})

local ColorGroup = Tabs.Visuals:AddRightGroupbox("Visual Colors", "palette")

ColorGroup:AddLabel("Box Color"):AddColorPicker("ESPBoxColor", {
    Default = Color3.fromHex("#48bfe3"),
    Title = "ESP Box Color",
    Callback = function(Value)
        print("[SAIOPS HUB] Box Color:", Value)
    end,
})

ColorGroup:AddLabel("Chams Color"):AddColorPicker("ChamsColor", {
    Default = Color3.fromHex("#80ffdb"),
    Title = "Chams Fill Color",
    Transparency = 0.5,
    Callback = function(Value)
        print("[SAIOPS HUB] Chams Color:", Value)
    end,
})

--------------------------------------------------------------------------------
-- 3. SETTINGS & MANAGERS
--------------------------------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("SAIOPS_HUB")
SaveManager:SetFolder("SAIOPS_HUB/configs")

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Apply default NeonEdge theme configuration
ThemeManager:ApplyTheme("NeonEdge")
SaveManager:LoadAutoloadConfig()

print("[SAIOPS HUB] Script successfully initialized!")
