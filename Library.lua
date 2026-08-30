local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or toclipboard or set_clipboard or (syn and syn.write_clipboard) or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/saiops-cc/Obsidian-main/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },

    AppIcon = {
        RobloxId = 95816097006870,
        Path = "Obsidian/assets/icon.png",
        URL = BaseURL .. "assets/icon.png",

        Id = nil,
    },

    ["icon.png"] = {
        RobloxId = 95816097006870,
        Path = "Obsidian/assets/icon.png",
        URL = BaseURL .. "assets/icon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotificationHistory = {},
    NotificationListeners = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},
    GroupboxHolders = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

function Library:GetActiveFeatures()
    local Active = {}
    for Idx, Toggle in pairs(Library.Toggles) do
        if Toggle and Toggle.Value == true and not Toggle.Destroyed then
            table.insert(Active, {
                Idx = Idx,
                Toggle = Toggle,
                Text = Toggle.Text or tostring(Idx),
                Default = Toggle.Default,
            })
        end
    end
    table.sort(Active, function(a, b)
        return (a.Text or "") < (b.Text or "")
    end)
    return Active
end

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        Minimizable = true,
        AlwaysOnTop = false,
        FooterLinks = {},

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 4,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Font = Enum.Font.Code,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom"
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = false
    },
    SliderInput = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextLen, SearchLen = Text:len(), Search:len()
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
            local PrevChar = TextIdx > 1 and Text:sub(TextIdx - 1, TextIdx - 1) or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): boolean
    if typeof(Text) ~= "string" or Text == "" then
        return false
    end

    return (FuzzyScore(Text:lower(), Search))
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a
    --// specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    local VisibleElements = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        VisibleElements += CheckDepbox(Depbox, Search, ForceVisible)
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function DimPopOutClone(Root: GuiObject)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)

    return math.max(0, Available / Library.DPIScale - Reserved)
end

--// Search
local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return
    end

    local HasVisible = false

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        local VisibleElements = 0

        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            VisibleElements += CheckDepbox(Depbox, Search, GroupboxMatches)
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                VisibleElements[SubTab] += CheckDepbox(Depbox, Search, SubTabMatches)
            end
        end

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                if Tabbox.ActiveTab == SubTab then
                    SubTab:Resize()
                elseif Tabbox.ActiveTab and VisibleElements[Tabbox.ActiveTab] == 0 then
                    SubTab:Show()
                end
            end
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible
end
local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToReset = {}

    if Library.GlobalSearch then
        for _, Tab in Library.Tabs do
            if typeof(Tab) == "table" and not Tab.IsKeyTab then
                table.insert(TabsToReset, Tab)
            end
        end
    elseif Library.LastSearchTab and typeof(Library.LastSearchTab) == "table" then
        table.insert(TabsToReset, Library.LastSearchTab)
    end

    for _, Tab in ipairs(TabsToReset) do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(SearchText:lower())
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local TabsToSearch = {}

    if Library.GlobalSearch then
        TabsToSearch = TabsToReset
        if #TabsToSearch == 0 then
            for _, Tab in Library.Tabs do
                if typeof(Tab) == "table" and not Tab.IsKeyTab then
                    table.insert(TabsToSearch, Tab)
                end
            end
        end
    elseif Library.ActiveTab then
        table.insert(TabsToSearch, Library.ActiveTab)
    end

    local FirstVisibleTab = nil
    local ActiveHasVisible = false

    for _, Tab in ipairs(TabsToSearch) do
        local HasVisible = ApplySearchToTab(Tab, Search)
        if HasVisible then
            if not FirstVisibleTab then
                FirstVisibleTab = Tab
            end
            if Tab == Library.ActiveTab then
                ActiveHasVisible = true
            end
        end
    end

    if Library.GlobalSearch then
        if ActiveHasVisible and Library.ActiveTab then
            Library.ActiveTab:RefreshSides()
        elseif FirstVisibleTab then
            local SearchMarker = SearchText
            task.defer(function()
                if Library.SearchText ~= SearchMarker then
                    return
                end

                if Library.ActiveTab ~= FirstVisibleTab then
                    FirstVisibleTab:Show()
                end
            end)
        end
        Library.LastSearchTab = nil
    else
        Library.LastSearchTab = Library.ActiveTab
    end
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end

    (Library :: any):UpdateNotificationPositions(true)
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string)
    if not FetchIcons or not Icons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end

    return Icon
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IconName == "icon" or IconName == "icon.png" or IconName == "AppIcon" or IconName == "sai" or IconName == "sai.png" or (CustomImageManagerAssets and CustomImageManagerAssets[IconName]) then
        local Lookup = (IconName == "icon" or IconName == "icon.png" or IconName == "sai" or IconName == "sai.png") and "AppIcon" or IconName
        local AssetId = CustomImageManager.GetAsset(Lookup)
        if AssetId then
            return {
                Url = AssetId,
                ImageRectOffset = Vector2.zero,
                ImageRectSize = Vector2.zero,
                Custom = true,
            }
        end
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:ApplyLucideIcon(ImageGui: any, Icon: any, Rotation: number?)
    if not ImageGui or not Icon then
        return
    end

    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then
        return
    end

    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset 
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
    ImageGui.Rotation = Rotation or ImageGui.Rotation
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    if not Gui then
        return
    end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor, CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(9, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 2, 1, 2),
        ZIndex = 1,
        Parent = Cursor,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(3, 11),
        ZIndex = 1,
        Parent = Cursor,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1, 9),
        ZIndex = 2,
        Parent = Cursor,
    })

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    pcall(function() 
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
    end)

    UserInputService.MouseIconEnabled = (Library.OriginalMouseIconEnabled ~= false)
    if Cursor then Cursor.Visible = false end
end

local function EnableMouseIcon()
    if Library.IsMobile or Library.Unloaded then
        return
    end

    local ShowCursorBinding = Library.ShowCursorBinding
    pcall(function() RunService:UnbindFromRenderStep(ShowCursorBinding) end)
    RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
        if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
            RestoreMouseIcon()
            return
        end

        UserInputService.MouseIconEnabled = not Library.ShowCustomCursor
        if Cursor then
            Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
            Cursor.Visible = Library.ShowCustomCursor
        end
    end)
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Icons \\--
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon
function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
if OnlineFetchIcons and OnlineIcons then
    Library:SetIconModule(OnlineIcons)
end

--// Lib Functions \\--
function Library:ResetCursorIcon()
    CursorCustomImage.Visible = false
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library:ChangeCursorIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library:ResetCursorIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCustomImage.Visible = true
    Library:ApplyLucideIcon(CursorCustomImage, Icon)
end

function Library:ChangeCursorIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return Bounds.X, Bounds.Y
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function Library:CopyToClipboard(Text: string, Title: string?, Silent: boolean?)
    local Copied = false
    if typeof(setclipboard) == "function" then
        Copied = pcall(setclipboard, tostring(Text))
    elseif typeof(toclipboard) == "function" then
        Copied = pcall(toclipboard, tostring(Text))
    elseif typeof(set_clipboard) == "function" then
        Copied = pcall(set_clipboard, tostring(Text))
    elseif typeof(syn) == "table" and typeof(syn.write_clipboard) == "function" then
        Copied = pcall(syn.write_clipboard, tostring(Text))
    end

    if not Silent and Library.Notify then
        Library:Notify({
            Title = Title or "Clipboard",
            Description = Copied and (Title and string.format("Copied %s to clipboard!", Title) or "Copied to clipboard!") or tostring(Text),
            Time = 2,
            Icon = Copied and "check" or "copy",
            SkipHistory = true,
        })
    end
    return Copied
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(TabCanvas: CanvasGroup, Showing: boolean, OnComplete: (() -> ())?)
    if not TabCanvas then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local Existing = ActiveTabTweens[TabCanvas]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabCanvas] = nil
    end

    local BaseZIndex = TabCanvas.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabCanvas.Visible = Showing
        TabCanvas.GroupTransparency = Showing and 0 or 1
        TabCanvas.Position = UDim2.fromScale(0, 0)
        TabCanvas.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition

        if SwipeFrom == "left" then
            StartPosition = UDim2.fromOffset(-Offset, 0)
        elseif SwipeFrom == "top" then
            StartPosition = UDim2.fromOffset(0, -Offset)
        elseif SwipeFrom == "right" then
            StartPosition = UDim2.fromOffset(Offset, 0)
        else -- bottom (Default)
            StartPosition = UDim2.fromOffset(0, Offset)
        end

        TabCanvas.ZIndex = BaseZIndex + 1
        TabCanvas.GroupTransparency = 1
        TabCanvas.Position = StartPosition
        TabCanvas.Visible = true

        local Tween = TweenService:Create(TabCanvas, TweenInfo, {
            GroupTransparency = 0,
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabCanvas] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabCanvas] == Tween then
                ActiveTabTweens[TabCanvas] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabCanvas.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabCanvas.GroupTransparency = 1
        TabCanvas.Visible = false
        TabCanvas.Position = UDim2.fromScale(0, 0)
        TabCanvas.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
})
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2) end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function RaiseFloat()
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = New("ImageButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            })
            Library:ApplyLucideIcon(PlaceholderDockIcon, PopOutIcon)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local Width = Holder.AbsoluteSize.X / Library.DPIScale
            if Width < 50 then
                Width = 200
            end

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        
        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PoppedOut = false
        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    --// Drag Handler
    local function StopDrag()
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })

            Library:ApplyLucideIcon(IconImage, CustomIcon)
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:OpenDropdownModal(Dropdown)
    if not ScreenGui or not ScreenGui.Parent or not Dropdown then return end

    if Library.DropdownModalInstance then
        Library.DropdownModalInstance:Destroy()
        Library.DropdownModalInstance = nil
    end

    local Modal = New("Frame", {
        Name = "DropdownExpandModal",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(460, 360),
        ZIndex = 40,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = Modal,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Modal,
        })
    )
    Library:AddOutline(Modal)
    Library:MakeDraggable(Modal, Modal, false, true, { Enabled = true, Distance = 28, Margin = 8 })

    Library.DropdownModalInstance = Modal

    -- 1. Top Header Frame
    local HeaderFrame = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 41,
        Parent = Modal,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = HeaderFrame,
    })

    local HeaderLeft = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, -36, 1, 0),
        ZIndex = 42,
        Parent = HeaderFrame,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = HeaderLeft,
    })

    local TitleLabel = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Text = Dropdown.Text or "Select Options",
        TextColor3 = "FontColor",
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 42,
        Parent = HeaderLeft,
    })

    if Dropdown.Multi then
        local MultiBadge = New("Frame", {
            BackgroundColor3 = "AccentColor",
            BackgroundTransparency = 0.85,
            Size = UDim2.fromOffset(72, 18),
            ZIndex = 42,
            Parent = HeaderLeft,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = MultiBadge,
            })
        )
        New("UIStroke", {
            Color = "AccentColor",
            Thickness = 1,
            Parent = MultiBadge,
        })
        local MultiText = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "Multi-Select",
            TextColor3 = "AccentColor",
            TextSize = 9.5,
            Font = Enum.Font.GothamBold,
            ZIndex = 43,
            Parent = MultiBadge,
        })
    end

    local CloseBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        Text = "",
        ZIndex = 42,
        Parent = HeaderFrame,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = CloseBtn,
        })
    )

    local CloseIcon = Library:GetCustomIcon("x")
    local CloseIconImg
    if CloseIcon then
        CloseIconImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(13, 13),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 43,
            Parent = CloseBtn,
        })
        Library:ApplyLucideIcon(CloseIconImg, CloseIcon)
    end

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, Library.TweenInfo, { BackgroundTransparency = 0.8 }):Play()
        if CloseIconImg then
            TweenService:Create(CloseIconImg, Library.TweenInfo, { ImageTransparency = 0, ImageColor3 = Library.Scheme.RedColor }):Play()
        end
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
        if CloseIconImg then
            TweenService:Create(CloseIconImg, Library.TweenInfo, { ImageTransparency = 0.4, ImageColor3 = Library.Scheme.FontColor }):Play()
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Modal:Destroy()
        Library.DropdownModalInstance = nil
    end)

    Library:MakeLine(Modal, {
        Position = UDim2.fromOffset(0, 38),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 41,
    })

    -- 2. Search Bar
    local SearchContainer = New("Frame", {
        BackgroundColor3 = "MainColor",
        Position = UDim2.fromOffset(12, 44),
        Size = UDim2.new(1, -24, 0, 28),
        ZIndex = 41,
        Parent = Modal,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = SearchContainer,
        })
    )
    local SearchStroke = New("UIStroke", {
        Color = "OutlineColor",
        Parent = SearchContainer,
    })

    local SearchIcon = Library:GetCustomIcon("search")
    if SearchIcon then
        local SearchIconImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            ZIndex = 42,
            Parent = SearchContainer,
        })
        Library:ApplyLucideIcon(SearchIconImg, SearchIcon)
    end

    local SearchTextBox = New("TextBox", {
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        PlaceholderText = "Search options...",
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -34, 1, 0),
        Text = "",
        TextColor3 = "FontColor",
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 42,
        Parent = SearchContainer,
    })

    SearchTextBox.Focused:Connect(function()
        TweenService:Create(SearchStroke, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
    end)
    SearchTextBox.FocusLost:Connect(function()
        TweenService:Create(SearchStroke, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
    end)

    -- 3. Grid Options ScrollingFrame
    local GridScroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = "OutlineColor",
        Position = UDim2.fromOffset(12, 78),
        Size = UDim2.new(1, -24, 1, -86),
        ZIndex = 41,
        Parent = Modal,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 2),
        Parent = GridScroll,
    })

    New("UIGridLayout", {
        CellPadding = UDim2.fromOffset(6, 6),
        CellSize = UDim2.new(0.5, -7, 0, 26),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = GridScroll,
    })

    local Cards = {}

    local function IsOptionSelected(Value)
        if Dropdown.Multi then
            return Dropdown.Value and Dropdown.Value[Value] == true
        else
            return Dropdown.Value == Value
        end
    end

    local function UpdateCardsVisual()
        for _, Item in ipairs(Cards) do
            local Selected = IsOptionSelected(Item.Value)
            TweenService:Create(Item.Card, Library.TweenInfo, {
                BackgroundColor3 = Selected and Library.Scheme.AccentColor or Library.Scheme.MainColor,
                BackgroundTransparency = Selected and 0.82 or 0,
            }):Play()
            TweenService:Create(Item.Stroke, Library.TweenInfo, {
                Color = Selected and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
            }):Play()
            if Item.CheckIcon then
                Item.CheckIcon.Visible = Selected
                if Selected then
                    Item.CheckIcon.ImageColor3 = Library.Scheme.AccentColor
                end
            end
            TweenService:Create(Item.Label, Library.TweenInfo, {
                Position = Selected and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 8, 0.5, 0),
            }):Play()
            Item.Label.TextColor3 = Selected and Library.Scheme.AccentColor or Library.Scheme.FontColor
        end
    end

    local Values = Dropdown.Values
    local IsDictionary = not IsSequentialArray(Values)
    local CheckCustomIcon = Library:GetCustomIcon("check")

    for Key, RawValue in pairs(Values) do
        local Value = IsDictionary and Key or RawValue
        local DisplayText = tostring(RawValue)
        local Selected = IsOptionSelected(Value)

        local Card = New("TextButton", {
            BackgroundColor3 = Selected and "AccentColor" or "MainColor",
            BackgroundTransparency = Selected and 0.82 or 0,
            Size = UDim2.fromOffset(0, 0),
            Text = "",
            ZIndex = 42,
            Parent = GridScroll,
        })
        local CardCorner = New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = Card,
        })
        table.insert(Library.SpecificCorners, CardCorner)

        local CardStroke = New("UIStroke", {
            Color = Selected and "AccentColor" or "OutlineColor",
            Thickness = 1,
            LineJoinMode = Enum.LineJoinMode.Round,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Card,
        })

        local CheckIconImg
        if CheckCustomIcon then
            CheckIconImg = New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),
                ImageColor3 = "AccentColor",
                ImageTransparency = 0,
                Visible = Selected,
                ZIndex = 43,
                Parent = Card,
            })
            Library:ApplyLucideIcon(CheckIconImg, CheckCustomIcon)
        end

        local CardLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = Selected and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = DisplayText,
            TextColor3 = Selected and "AccentColor" or "FontColor",
            TextSize = 12,
            Font = Enum.Font.Code,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 43,
            Parent = Card,
        })

        Card.MouseEnter:Connect(function()
            if not IsOptionSelected(Value) then
                TweenService:Create(CardStroke, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
            end
        end)
        Card.MouseLeave:Connect(function()
            if not IsOptionSelected(Value) then
                TweenService:Create(CardStroke, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
            end
        end)

        Card.MouseButton1Click:Connect(function()
            if Dropdown.Multi then
                local CurrVal = Dropdown.Value or {}
                CurrVal[Value] = not CurrVal[Value]
                Dropdown:SetValue(CurrVal)
            else
                Dropdown:SetValue(Value)
            end
            UpdateCardsVisual()
        end)

        table.insert(Cards, {
            Card = Card,
            Stroke = CardStroke,
            Label = CardLabel,
            CheckIcon = CheckIconImg,
            Value = Value,
            Text = DisplayText:lower(),
        })
    end

    SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Query = SearchTextBox.Text:lower():match("^%s*(.-)%s*$")
        for _, Item in ipairs(Cards) do
            if Query == "" or Item.Text:find(Query, 1, true) then
                Item.Card.Visible = true
            else
                Item.Card.Visible = false
            end
        end
    end)
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local DragThreshold = if ExcludeDragging then 0.25 else math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local Start = tick()

        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            local IsLikelyDragging = tick() - Start > DragThreshold
            if IsLikelyDragging then
                return
            end

            Library:SafeCallback(Func, DraggableButton)

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local DragThreshold = if ExcludeDragging then 0.25 else math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local Start = tick()

        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            local IsLikelyDragging = tick() - Start > DragThreshold
            if IsLikelyDragging then
                return
            end

            Library:SafeCallback(Func, DraggableImageButton)

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        Table.Active = false
        CurrentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if CurrentMenu == Table then
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    if Library.Unloaded then
        return
    end

    local X, _ = Library:GetTextBounds(
        TooltipLabel.Text,
        TooltipLabel.FontFace,
        TooltipLabel.TextSize,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    TooltipLabel.Size = UDim2.fromOffset(X + 8, 0)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Visible = true

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:SetText(NewInfoStr: string?, NewDisabledInfoStr: string?)
        if typeof(NewInfoStr) == "string" then
            InfoStr = NewInfoStr
        end
        if typeof(NewDisabledInfoStr) == "string" then
            DisabledInfoStr = NewDisabledInfoStr
        end
        if CurrentHoverInstance == HoverInstance and TooltipLabel.Visible then
            TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        end
    end

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local CancelSlidingTweens = function()
            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                FontFace = Picker.FontFace,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })

            Library:AddToRegistry(SlidingLabel, {
                TextColor3 = "FontColor",
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        Picker.MouseEnter:Connect(function()
            TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
        end)

        Picker.MouseLeave:Connect(function()
            TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = 0.4,
            }):Play()
        end)

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })
            if CheckIcon then
                Library:ApplyLucideIcon(CheckImage, CheckIcon)
            end

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
            end)

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end)

            Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end)

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            KeyPicker:Display()

            if Info.NoUI then
                return
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        local SetPickingState = function(State)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            KeyPicker:Update()
        end

        Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end)
        Picker.MouseButton2Click:Connect(MenuTable.Toggle)

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if KeyPicker.Mode == "Toggle" then
                if HoldingKey then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            elseif KeyPicker.Mode == "Press" then
                if HoldingKey then
                    KeyPicker:DoClick()
                end
            end

            KeyPicker:Update()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputEnded:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            KeyPicker:Update()
        end))

        KeyPicker:Update()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(Info.Transparency and 256 or 234, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(200, 200),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(16, 200),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(16, 200),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = 16
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = BaseMapSize
            ColorPicker.MapHeight = BaseMapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                local BarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + BarWidth + BasePadding
                if Info.Transparency then
                    Width += (BarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local BarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, BarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, BarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            local ResizeGrabberIcon = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })
            if ResizeIcon then
                Library:ApplyLucideIcon(ResizeGrabberIcon, ResizeIcon)
            end

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end)

                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end)

                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end)
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            Holder.BackgroundColor3 = ColorPicker.Value
            HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
            HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        function ColorPicker:RunChanged()
            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()
            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(ColorMenu.Toggle))
        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(ContextMenu.Toggle))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Display()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, ColorPicker)
        end

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = Params.Visible or true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end)
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = Params.Visible or true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Tween = nil,
            Type = "Button",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = 0.4,
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            return Base, Stroke
        end

        local function InitEvents(Button)
            Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()
            end)
            Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()
            end)

            Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    Button.Base.Text = "Are you sure?"
                    Button.Base.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Base].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Base.Text = Button.Text
                    Button.Base.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Base].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait() --// Mouse Button fires without waiting (i hate roblox)
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end)
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor
                    or Library.Scheme.MainColor
                SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Base.Text = Text
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            if SubButton.Risky then
                SubButton.Base.TextColor3 = Library.Scheme.RedColor
                Library.Registry[SubButton.Base].TextColor3 = "RedColor"
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor
                or Library.Scheme.MainColor
            Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Base.Text = Text
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        if Button.Risky then
            Button.Base.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Button.Base].TextColor3 = "RedColor"
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker

        function Button:Destroy()
            Button.Destroyed = true

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })
        if CheckIcon then
            Library:ApplyLucideIcon(CheckImage, CheckIcon)
        end

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            if Toggle.Disabled then
                return
            end

            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            if Toggle.Disabled then
                return
            end

            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()
            if Library.UpdateActiveFeaturesCount then
                Library:UpdateActiveFeaturesCount()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
            if Library.UpdateActiveFeaturesCount then
                Library:UpdateActiveFeaturesCount()
            end
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            if not Input.Disabled then
                Input:RunChanged()
            end
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (Info.Input == true or Info.WithInput == true or Info.ShowInput == true) then
            return self:AddSliderInput(Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local InputTextBox
        local InputTextBoxStroke
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = Bar,
            })
            InputTextBoxStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 20),
            Parent = Bar,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 20),
            Parent = Fill,
        })

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            if Slider.Disabled then
                return
            end

            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text

                    if AsNum then
                        if AsNum > Slider.Max then
                            InputTextBox.Text = tostring(Slider.Max)
                        elseif AsNum < Slider.Min then
                            InputTextBox.Text = tostring(Slider.Min)
                        end
                    end
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))

            table.insert(Slider.Connections, InputTextBox.Focused:Connect(function()
                Library.Registry[InputTextBoxStroke].Color = "AccentColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                Library.Registry[InputTextBoxStroke].Color = "DarkColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.DarkColor,
                }):Play()
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddSliderInput(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.SliderInput or Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local InputWidth = 48
        local Gap = 6

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, -(InputWidth + Gap), 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 20),
            Parent = Bar,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 20),
            Parent = Fill,
        })

        local InputBox = New("TextBox", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Position = UDim2.fromScale(1, 1),
            Size = UDim2.new(0, InputWidth, 0, 15),
            Text = tostring(Slider.Value),
            TextColor3 = "FontColor",
            TextEditable = not Slider.Disabled,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = Holder,
        })

        local InputBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = InputBox,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = InputBox,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 0),
            Parent = InputBox,
        })

        Slider.InputBox = InputBox

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            InputBox.TextTransparency = Slider.Disabled and 0.8 or 0
            InputBox.TextEditable = not Slider.Disabled

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(math.clamp(X, 0, 1), 1)

            if not InputBox:IsFocused() then
                InputBox.Text = tostring(Slider.Value)
            end
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            if Slider.Disabled then
                return
            end

            local Num = tonumber(Str)
            if not Num then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)
            Num = Round(Num, Slider.Rounding)

            if Num == Slider.Value then
                Slider:Display()
                return
            end

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            InputBox.TextEditable = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        local LastValidText = tostring(Slider.Value)
        table.insert(Slider.Connections, InputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local Text = InputBox.Text
            local AsNum = tonumber(Text)

            if #tostring(Text) > 0 and not AsNum and Text ~= "-" and Text ~= "." and Text ~= "-." then
                InputBox.Text = LastValidText
            else
                if Slider.Rounding == 0 and Text:find("%.") then
                    InputBox.Text = LastValidText
                    return
                end

                local DecimalPos = Text:find("%.")
                if DecimalPos and Slider.Rounding > 0 then
                    local Decimals = #Text - DecimalPos
                    if Decimals > Slider.Rounding then
                        InputBox.Text = LastValidText
                        return
                    end
                end

                LastValidText = Text
            end
        end))

        table.insert(Slider.Connections, InputBox.FocusLost:Connect(function()
            Library.Registry[InputBoxStroke].Color = "OutlineColor"
            TweenService:Create(InputBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()

            local Num = tonumber(InputBox.Text)
            if not Num then
                InputBox.Text = tostring(Slider.Value)
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)
            Num = Round(Num, Slider.Rounding)
            Slider:SetValue(Num)
            InputBox.Text = tostring(Slider.Value)
        end))

        table.insert(Slider.Connections, InputBox.Focused:Connect(function()
            Library.Registry[InputBoxStroke].Color = "AccentColor"
            TweenService:Create(InputBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input)
            if not ValidInput or Slider.Disabled then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    Funcs.AddInputSlider = Funcs.AddSliderInput
    Funcs.AddSliderWithInput = Funcs.AddSliderInput

    function Funcs:AddDropdown(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = 3,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = New("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -22, 0.5, 0),
            Size = UDim2.fromOffset(15, 15),
            Parent = DisplayContainer,
        })
        if ArrowIcon then
            Library:ApplyLucideIcon(ArrowImage, ArrowIcon)
        end

        local ExpandButton = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -2, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            ZIndex = 4,
            Parent = DisplayContainer,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ExpandButton,
            })
        )

        local ExpandIcon = Library:GetCustomIcon("maximize-2") or Library:GetCustomIcon("expand")
        local ExpandIconImg
        if ExpandIcon then
            ExpandIconImg = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(12, 12),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                ZIndex = 5,
                Parent = ExpandButton,
            })
            Library:ApplyLucideIcon(ExpandIconImg, ExpandIcon)
        end
        Library:AddTooltip("Expand searchable options grid", "", ExpandButton)

        ExpandButton.MouseEnter:Connect(function()
            TweenService:Create(ExpandButton, Library.TweenInfo, { BackgroundTransparency = 0.85 }):Play()
            if ExpandIconImg then
                TweenService:Create(ExpandIconImg, Library.TweenInfo, { ImageTransparency = 0, ImageColor3 = Library.Scheme.AccentColor }):Play()
            end
        end)
        ExpandButton.MouseLeave:Connect(function()
            TweenService:Create(ExpandButton, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            if ExpandIconImg then
                TweenService:Create(ExpandIconImg, Library.TweenInfo, { ImageTransparency = 0.5, ImageColor3 = Library.Scheme.FontColor }):Play()
            end
        end)
        ExpandButton.MouseButton1Click:Connect(function()
            if Dropdown.Disabled then return end
            Library:OpenDropdownModal(Dropdown)
        end)

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), 0)
            end,
            function()
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                ArrowImage.ImageTransparency = Active and 0 or 0.5
                ArrowImage.Rotation = Active and 180 or 0

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = Active and Zero or Half
                DropdownCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Zero
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = 21
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or #FilteredEntries
            local Y = math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayImage.ImageTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            if #Str > 25 then
                Str = Str:sub(1, 22) .. "..."
            end

            DisplayButton.Text = (Str == "" and "---" or Str)

            if ValueImage then
                Library:ApplyLucideIcon(DisplayImage, ValueImage)
                DisplayImage.ImageTransparency = 0
            else
                DisplayImage.Image = ""
                DisplayImage.ImageTransparency = 1
            end

            DisplayButton.Size = ValueImage and UDim2.new(1, -8, 0, 21) or UDim2.new(1, 0, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            local Table = {}

            if Info.Multi then
                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function RecomputeFilteredEntries()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(SearchBox.Text:lower()) or ""
            local IsSearching = SearchQuery ~= ""

            local EnabledList, DisabledList = {}, {}
            local Pending = {}

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(FormattedValue:lower(), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    SortKey = Key,
                    MatchScore = MatchScore,
                    Order = #Pending + 1,
                }

                table.insert(Pending, Entry)
            end

            if IsSearching then
                --// Best matches first; ties fall back to original order \\--
                table.sort(Pending, function(A, B)
                    if A.MatchScore ~= B.MatchScore then
                        return A.MatchScore > B.MatchScore
                    end
                    return A.Order < B.Order
                end)
            elseif not IsDictionary then
                table.sort(Pending, function(A, B)
                    return A.SortKey < B.SortKey
                end)
            end

            for _, Entry in Pending do
                if Entry.IsDisabled then
                    table.insert(DisabledList, Entry)
                else
                    table.insert(EnabledList, Entry)
                end
            end

            table.clear(FilteredEntries)
            for _, Entry in EnabledList do
                table.insert(FilteredEntries, Entry)
            end
            for _, Entry in DisabledList do
                table.insert(FilteredEntries, Entry)
            end
        end

        local function GetFirstVisibleIndex()
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = MenuTable.Menu.CanvasPosition.Y / Library.DPIScale
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    continue
                end

                Row.Container.Visible = true
                Row.Container.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue

                if Entry.ValueImage then
                    Row.Image.Visible = true
                    Library:ApplyLucideIcon(Row.Image, Entry.ValueImage)
                    Row.Button.Size = UDim2.new(1, -18, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(0, 0)
                end

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        local function StopDragSelect()
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button

            function Row:UpdateButton()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    Image.ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5
                end
            end

            Button.MouseButton1Click:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end)

            Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.25,
                    }):Play()
                end
            end)

            Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.5,
                    }):Play()
                end
            end)

            Button.InputBegan:Connect(function(StartInput)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end)

            return Row
        end

        function Dropdown:BuildDropdownList()
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                local Table = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        function Dropdown:SetDragSelect(Value: boolean)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, DisplayContainer.MouseButton1Click:Connect(ToggleDropdown))
        table.insert(Dropdown.Connections, DisplayButton.MouseButton1Click:Connect(ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            Dropdown.Destroyed = true

            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = (Viewport.Object :: PVInstance):GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            Library:ApplyLucideIcon(ImageLabel, Icon)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end)

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end)

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:SetTransparency(Transparency: number)
    assert(typeof(Transparency) == "number", "Expected number for transparency")
    Library.Transparency = math.clamp(Transparency, 0, 0.85)
    if Library.Window and Library.Window.SetTransparency then
        Library.Window:SetTransparency(Transparency)
    end
end

function Library:SetParticles(Enabled: boolean)
    if Library.Window and Library.Window.SetParticles then
        Library.Window:SetParticles(Enabled)
    end
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft = Library.NotifySide:lower() == "left"
    local XScale = IsLeft and 0 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, 0, RunningY)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y + 8
    end
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local IsLeft = Side:lower() == "left"
    if IsLeft then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = if IsLeft then Vector2.new(0, 0) else Vector2.new(1, 0)
    end

    if Library.UpdateNotificationPositions then
        Library:UpdateNotificationPositions(true)
end

function Library:SetTransparency(Transparency: number)
    Library.Transparency = Transparency
    if Library.Window and Library.Window.SetTransparency then
        Library.Window:SetTransparency(Transparency)
    end
end

function Library:SetParticles(Enabled: boolean)
    if Library.Window and Library.Window.SetParticles then
        Library.Window:SetParticles(Enabled)
    end
end

function Library:SetParticleType(Type: "Dot" | "Image" | "Emoji" | string)
    if Library.Window and Library.Window.SetParticleType then
        Library.Window:SetParticleType(Type)
    end
end

function Library:SetParticleImage(Image: string)
    if Library.Window and Library.Window.SetParticleImage then
        Library.Window:SetParticleImage(Image)
    end
end

function Library:SetParticleEmoji(Emoji: string | { string })
    if Library.Window and Library.Window.SetParticleEmoji then
        Library.Window:SetParticleEmoji(Emoji)
    end
end

function Library:SetParticleCount(Count: number)
    if Library.Window and Library.Window.SetParticleCount then
        Library.Window:SetParticleCount(Count)
    end
end

function Library:SetParticleSpeed(Speed: number)
    if Library.Window and Library.Window.SetParticleSpeed then
        Library.Window:SetParticleSpeed(Speed)
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.TitleColor = Info.TitleColor

        Data.Description = tostring(Info.Description)
        Data.DescriptionColor = Info.DescriptionColor

        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist
        Data.SkipHistory = Info.SkipHistory == true

        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor

        Data.Volume = tonumber(Info.Volume) or 3
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
        Data.Volume = select(4, ...) or 3
    end
    Data.Destroyed = false

    if not Data.SkipHistory then
        local HistoryItem = {
            Title = Data.Title or "Notification",
            TitleColor = Data.TitleColor,
            Description = Data.Description or "",
            DescriptionColor = Data.DescriptionColor,
            Time = os.time(),
            FormattedTime = os.date("%X"),
            Icon = Data.Icon or Data.BigIcon or "bell",
            IconColor = Data.IconColor,
            Steps = Data.Steps,
        }
        table.insert(Library.NotificationHistory, 1, HistoryItem)
        if #Library.NotificationHistory > 150 then
            table.remove(Library.NotificationHistory)
        end
        for _, Listener in ipairs(Library.NotificationListeners) do
            task.spawn(Listener, HistoryItem)
        end
    end

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local FakeBackground = New("Frame", {
        AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = Holder,
    })
    Library:AddOutline(Holder)

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(1, 0),
        Parent = Holder,
    })

    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = Data.IconColor or "AccentColor",
                Parent = ContentContainer,
            })
            Library:ApplyLucideIcon(BigIconLabel, ParsedIcon)
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })

    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                ImageColor3 = Data.IconColor or "FontColor",
                Parent = TitleContainer,
            })
            Library:ApplyLucideIcon(IconLabel, ParsedIcon)
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (Data.Icon and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextColor3 = Data.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextColor3 = Data.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0

        if Title then
            local X, Y =
                Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y =
                Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX) + 24 + ExtraWidth, 0)

        if Library.Notifications[FakeBackground] then
            Library:UpdateNotificationPositions()
        end
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy()
        Data.Destroyed = true

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        if FakeBackground then
            local Idx = table.find(NotifyOrder, FakeBackground)
            if Idx then
                table.remove(NotifyOrder, Idx)
            end
        end

        Library:UpdateNotificationPositions()

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    Data:Resize()

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number",
        Parent = Holder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = tonumber(Data.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Data.Holder = Holder

    table.insert(NotifyOrder, FakeBackground)
    Library.Notifications[FakeBackground] = Data

    Library:UpdateNotificationPositions()

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.delay(Library.NotifyTweenInfo.Time, function()
        if Data.Persist then
            return
        elseif typeof(Data.Time) == "Instance" then
            repeat
                task.wait()
            until DeletedInstance or Data.Destroyed
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        if not Data.Destroyed then
            Data:Destroy()
        end
    end)

    return Data
end

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(48, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(48, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local Window = {}
    Library.Window = Window
    local MainFrame
    local DividerLine
    local ParticleContainer
    local ParticleType = WindowInfo.ParticleType or (WindowInfo.ParticleEmoji and "Emoji") or (WindowInfo.ParticleImage and "Image") or "Dot"
    local ParticleImage = WindowInfo.ParticleImage or "icon.png"
    local ParticleEmoji = WindowInfo.ParticleEmoji or "✨"
    local ParticlesEnabled = WindowInfo.Particles ~= false
    local ParticleSpeed = math.max(0.1, WindowInfo.ParticleSpeed or 1)
    local ParticleCount = math.clamp(WindowInfo.ParticleCount or 35, 5, 150)
    local ParticleColorOverride = WindowInfo.ParticleColor
    local ParticlePool = {}
    local PopulateParticles
    local CurrentTransparency = math.clamp(WindowInfo.Transparency or 0, 0, 0.85)
    Library.Transparency = CurrentTransparency
    local ApplyTransparency
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local BottomBar
    local FooterLabel
    local TopBar
    local ToggleSidebarButton
    local ToggleSidebarIconImage
    local ToggleSidebarTooltip
    local SidebarHidden = false
    local NotifHistoryButton
    local NotifBadge
    local MinimizeButton
    local MinimizeBar
    local MinimizeIconImage
    local FooterLinksContainer
    local FloatingTabWidget
    local FloatNotifBadge
    local ActiveFeaturesButton
    local ActiveFeaturesBadge
    local ActiveFeaturesBadgeLabel
    local ActiveFeaturesPopover
    local FloatActiveBtn
    local FloatActiveBadge
    local FloatActiveBadgeLabel
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        --// Animated Particle Background Canvas \\--
        ParticleContainer = New("Frame", {
            Active = false,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Name = "ParticleCanvas",
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ZIndex = 8,
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = ParticleContainer,
            })
        )

        local function GetParticleColor()
            if ParticleColorOverride then
                if typeof(ParticleColorOverride) == "string" then
                    return Library.Scheme[ParticleColorOverride] or Library.Scheme.AccentColor
                elseif typeof(ParticleColorOverride) == "Color3" then
                    return ParticleColorOverride
                end
            end
            return Library.Scheme.AccentColor
        end

        local function GetRandomEmoji()
            if typeof(ParticleEmoji) == "table" and #ParticleEmoji > 0 then
                return ParticleEmoji[math.random(1, #ParticleEmoji)]
            elseif typeof(ParticleEmoji) == "string" and #ParticleEmoji > 0 then
                return ParticleEmoji
            end
            return "✨"
        end

        local function CreateParticle()
            local GuiElement
            local SizePx = 4
            local RotSpeed = 0
            local Rotation = 0

            local currentType = ParticleType

            if currentType == "Emoji" then
                SizePx = math.random(14, 20)
                RotSpeed = math.random(-35, 35)
                Rotation = math.random(0, 360)
                local EmojiText = GetRandomEmoji()

                GuiElement = New("TextLabel", {
                    Active = false,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(SizePx, SizePx),
                    Position = UDim2.new(math.random(), 0, math.random(), 0),
                    Text = EmojiText,
                    TextScaled = true,
                    Rotation = Rotation,
                    TextTransparency = math.random(30, 75) / 100,
                    ZIndex = 8,
                    Parent = ParticleContainer,
                })
            elseif currentType == "Image" then
                SizePx = math.random(14, 20)
                RotSpeed = math.random(-30, 30)
                Rotation = math.random(0, 360)

                local ImgLabel = New("ImageLabel", {
                    Active = false,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(SizePx, SizePx),
                    Position = UDim2.new(math.random(), 0, math.random(), 0),
                    ImageColor3 = GetParticleColor,
                    ImageTransparency = math.random(30, 75) / 100,
                    Rotation = Rotation,
                    ZIndex = 8,
                    Parent = ParticleContainer,
                })

                local ParsedIcon = Library:GetCustomIcon(ParticleImage)
                if ParsedIcon then
                    Library:ApplyLucideIcon(ImgLabel, ParsedIcon)
                else
                    ImgLabel.Image = ParticleImage
                end

                GuiElement = ImgLabel
            else -- "Dot"
                SizePx = math.random(3, 6)
                local Dot = New("Frame", {
                    Active = false,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = GetParticleColor,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(SizePx, SizePx),
                    Position = UDim2.new(math.random(), 0, math.random(), 0),
                    BackgroundTransparency = math.random(40, 80) / 100,
                    ZIndex = 8,
                    Parent = ParticleContainer,
                })
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Dot,
                })
                GuiElement = Dot
            end

            local Particle = {
                gui = GuiElement,
                pType = currentType,
                x = math.random(),
                y = math.random(),
                vx = (math.random(-15, 15) / 1000) * 0.05,
                vy = -(math.random(10, 30) / 1000) * 0.05,
                phase = math.random() * math.pi * 2,
                pulseSpeed = math.random(15, 30) / 10,
                baseAlpha = math.random(35, 75) / 100,
                alphaRange = math.random(15, 25) / 100,
                rotation = Rotation,
                rotSpeed = RotSpeed,
                size = SizePx,
            }
            table.insert(ParticlePool, Particle)
            return Particle
        end

        PopulateParticles = function()
            for _, p in ipairs(ParticlePool) do
                if p.gui then p.gui:Destroy() end
            end
            table.clear(ParticlePool)

            if not ParticlesEnabled then
                return
            end

            for _ = 1, ParticleCount do
                CreateParticle()
            end
        end

        PopulateParticles()

        Library:GiveSignal(RunService.RenderStepped:Connect(function(dt)
            if not (MainFrame and MainFrame.Visible and Library.Toggled and not IsMinimized and ParticlesEnabled) then
                return
            end

            local clampedDt = math.min(dt, 0.05)
            local speedMult = ParticleSpeed

            for _, p in ipairs(ParticlePool) do
                p.x = p.x + (p.vx * speedMult * clampedDt * 60)
                p.y = p.y + (p.vy * speedMult * clampedDt * 60)
                p.phase = p.phase + (p.pulseSpeed * clampedDt)

                if p.rotSpeed ~= 0 then
                    p.rotation = (p.rotation + p.rotSpeed * clampedDt) % 360
                    p.gui.Rotation = p.rotation
                end

                -- Wrap boundaries smoothly
                if p.y < -0.02 then
                    p.y = 1.02
                    p.x = math.random()
                elseif p.y > 1.02 then
                    p.y = -0.02
                    p.x = math.random()
                end

                if p.x < -0.02 then
                    p.x = 1.02
                elseif p.x > 1.02 then
                    p.x = -0.02
                end

                p.gui.Position = UDim2.new(p.x, 0, p.y, 0)
                local currentAlpha = math.clamp(p.baseAlpha + math.sin(p.phase) * p.alphaRange, 0.15, 0.95)

                if p.pType == "Emoji" then
                    p.gui.TextTransparency = currentAlpha
                elseif p.pType == "Image" then
                    p.gui.ImageTransparency = currentAlpha
                else
                    p.gui.BackgroundTransparency = currentAlpha
                end
            end
        end))

        ApplyTransparency = function(Transparency: number)
            CurrentTransparency = math.clamp(Transparency, 0, 0.85)
            Library.Transparency = CurrentTransparency

            if MainFrame then
                MainFrame.BackgroundTransparency = CurrentTransparency
            end
            if Container then
                Container.BackgroundTransparency = math.clamp(CurrentTransparency + (CurrentTransparency > 0 and 0.05 or 0), 0, 1)
            end
            if Tabs then
                Tabs.BackgroundTransparency = math.clamp(CurrentTransparency + (CurrentTransparency > 0 and 0.05 or 0), 0, 1)
            end
            if DividerLine then
                DividerLine.BackgroundTransparency = math.clamp(CurrentTransparency * 0.5, 0, 1)
            end
            if BottomBackground then
                BottomBackground.BackgroundTransparency = math.clamp(CurrentTransparency, 0, 1)
            end
            for _, Holder in ipairs(Library.GroupboxHolders) do
                if Holder and Holder.Parent then
                    Holder.BackgroundTransparency = CurrentTransparency
                end
            end
        end

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        if BackgroundIcon then
            Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
        end

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (BackgroundImage and MainFrame) then
                return
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Toggle Sidebar / Tabs Button \\--
        ToggleSidebarButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 11),
            Size = UDim2.fromOffset(26, 26),
            Text = "",
            ZIndex = 11,
            Parent = TopBar,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
                Parent = ToggleSidebarButton,
            })
        )
        ToggleSidebarTooltip = Library:AddTooltip("Hide Tab Menu", "", ToggleSidebarButton)

        local SidebarIcon = Library:GetCustomIcon("panel-left-close") or Library:GetCustomIcon("panel-left") or Library:GetCustomIcon("sidebar") or Library:GetCustomIcon("menu")
        if SidebarIcon then
            ToggleSidebarIconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.4,
                Size = UDim2.fromOffset(15, 15),
                ZIndex = 12,
                Parent = ToggleSidebarButton,
            })
            Library:ApplyLucideIcon(ToggleSidebarIconImage, SidebarIcon)
        end

        Library:GiveSignal(ToggleSidebarButton.MouseEnter:Connect(function()
            TweenService:Create(ToggleSidebarButton, Library.TweenInfo, {
                BackgroundTransparency = 0.85,
            }):Play()
            if ToggleSidebarIconImage then
                TweenService:Create(ToggleSidebarIconImage, Library.TweenInfo, {
                    ImageTransparency = 0,
                    ImageColor3 = Library.Scheme.AccentColor,
                }):Play()
            end
        end))

        Library:GiveSignal(ToggleSidebarButton.MouseLeave:Connect(function()
            TweenService:Create(ToggleSidebarButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            if ToggleSidebarIconImage then
                TweenService:Create(ToggleSidebarIconImage, Library.TweenInfo, {
                    ImageTransparency = 0.4,
                    ImageColor3 = Library.Scheme.FontColor,
                }):Play()
            end
        end))

        Library:GiveSignal(ToggleSidebarButton.MouseButton1Click:Connect(function()
            Window:ToggleSidebar()
        end))

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(38, 0),
            Size = UDim2.new(0, math.max(0, InitialLeftWidth - 38), 1, 0),
            ClipsDescendants = true,
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ImageTransparency = 0,
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
            if Icon then
                Library:ApplyLucideIcon(WindowIcon, Icon)
            end
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local X = Library:GetTextBounds(
            WindowInfo.Title,
            Library.Scheme.Font,
            20,
            TitleHolder.AbsoluteSize.X - (WindowInfo.Icon and WindowInfo.IconSize.X.Offset + 6 or 0) - 12
        )
        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, X, 1, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            Parent = TitleHolder,
        })

        --// Top Right Actions \\--
        local TopBarActions = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 10,
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            Parent = TopBarActions,
        })

        --// Active Features Button \\--
        ActiveFeaturesButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(26, 26),
            Text = "",
            ZIndex = 11,
            Parent = TopBarActions,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
                Parent = ActiveFeaturesButton,
            })
        )
        Library:AddTooltip("Active Features", "", ActiveFeaturesButton)

        local ActiveIcon = Library:GetCustomIcon("sliders-horizontal") or Library:GetCustomIcon("sliders") or Library:GetCustomIcon("activity")
        local ActiveIconImage
        if ActiveIcon then
            ActiveIconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.4,
                Size = UDim2.fromOffset(15, 15),
                ZIndex = 12,
                Parent = ActiveFeaturesButton,
            })
            Library:ApplyLucideIcon(ActiveIconImage, ActiveIcon)
        end

        ActiveFeaturesBadge = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "AccentColor",
            Position = UDim2.new(1, -1, 0, 1),
            Size = UDim2.fromOffset(12, 12),
            Visible = false,
            ZIndex = 13,
            Parent = ActiveFeaturesButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ActiveFeaturesBadge,
            })
        )
        ActiveFeaturesBadgeLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "0",
            TextColor3 = "WhiteColor",
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            ZIndex = 14,
            Parent = ActiveFeaturesBadge,
        })

        ActiveFeaturesButton.MouseEnter:Connect(function()
            TweenService:Create(ActiveFeaturesButton, Library.TweenInfo, { BackgroundTransparency = 0.85 }):Play()
            if ActiveIconImage then
                TweenService:Create(ActiveIconImage, Library.TweenInfo, { ImageTransparency = 0, ImageColor3 = Library.Scheme.AccentColor }):Play()
            end
        end)
        ActiveFeaturesButton.MouseLeave:Connect(function()
            TweenService:Create(ActiveFeaturesButton, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            if ActiveIconImage then
                TweenService:Create(ActiveIconImage, Library.TweenInfo, { ImageTransparency = 0.4, ImageColor3 = Library.Scheme.FontColor }):Play()
            end
        end)
        ActiveFeaturesButton.MouseButton1Click:Connect(function()
            if NotifHistoryPopover then NotifHistoryPopover.Visible = false end
            ActiveFeaturesPopover.Visible = not ActiveFeaturesPopover.Visible
            if ActiveFeaturesPopover.Visible then
                if Library.RefreshActiveFeaturesCards then
                    Library.RefreshActiveFeaturesCards(true)
                end
                ActiveFeaturesPopover.AnchorPoint = Vector2.new(1, 0)
                ActiveFeaturesPopover.Position = UDim2.fromOffset(
                    MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X - 8,
                    MainFrame.AbsolutePosition.Y + 48
                )
            else
                if Library.OnActiveFeaturesClosed then
                    Library.OnActiveFeaturesClosed()
                end
            end
        end)

        NotifHistoryButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(26, 26),
            Text = "",
            ZIndex = 11,
            Parent = TopBarActions,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
                Parent = NotifHistoryButton,
            })
        )
        Library:AddTooltip("Notification History", "", NotifHistoryButton)

        local BellIcon = Library:GetCustomIcon("bell")
        local BellIconImage
        if BellIcon then
            BellIconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.4,
                Size = UDim2.fromOffset(15, 15),
                ZIndex = 12,
                Parent = NotifHistoryButton,
            })
            Library:ApplyLucideIcon(BellIconImage, BellIcon)
        end

        NotifBadge = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "AccentColor",
            Position = UDim2.new(1, -2, 0, 2),
            Size = UDim2.fromOffset(6, 6),
            Visible = (#Library.NotificationHistory > 0),
            ZIndex = 13,
            Parent = NotifHistoryButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = NotifBadge,
            })
        )

        Library:GiveSignal(NotifHistoryButton.MouseEnter:Connect(function()
            TweenService:Create(NotifHistoryButton, Library.TweenInfo, {
                BackgroundTransparency = 0.85,
            }):Play()
            if BellIconImage then
                TweenService:Create(BellIconImage, Library.TweenInfo, {
                    ImageTransparency = 0,
                    ImageColor3 = Library.Scheme.AccentColor,
                }):Play()
            end
        end))

        Library:GiveSignal(NotifHistoryButton.MouseLeave:Connect(function()
            TweenService:Create(NotifHistoryButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            if BellIconImage then
                TweenService:Create(BellIconImage, Library.TweenInfo, {
                    ImageTransparency = 0.4,
                    ImageColor3 = Library.Scheme.FontColor,
                }):Play()
            end
        end))

        if WindowInfo.Minimizable ~= false then
            MinimizeButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(26, 26),
                Text = "",
                ZIndex = 11,
                Parent = TopBarActions,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
                    Parent = MinimizeButton,
                })
            )
            Library:AddTooltip("Minimize / Restore Window", "", MinimizeButton)

            MinimizeBar = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "FontColor",
                BackgroundTransparency = 0.35,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(12, 2.5),
                ZIndex = 12,
                Parent = MinimizeButton,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, 2),
                    Parent = MinimizeBar,
                })
            )

            local MaxIcon = Library:GetCustomIcon("maximize-2") or Library:GetCustomIcon("chevron-down") or Library:GetCustomIcon("plus")
            if MaxIcon then
                MinimizeIconImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.4,
                    Size = UDim2.fromOffset(14, 14),
                    Visible = false,
                    ZIndex = 12,
                    Parent = MinimizeButton,
                })
                Library:ApplyLucideIcon(MinimizeIconImage, MaxIcon)
            end

            Library:GiveSignal(MinimizeButton.MouseEnter:Connect(function()
                TweenService:Create(MinimizeButton, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                if MinimizeBar and MinimizeBar.Visible then
                    TweenService:Create(MinimizeBar, Library.TweenInfo, {
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Library.Scheme.AccentColor,
                        Size = UDim2.fromOffset(14, 3),
                    }):Play()
                end
                if MinimizeIconImage and MinimizeIconImage.Visible then
                    TweenService:Create(MinimizeIconImage, Library.TweenInfo, {
                        ImageTransparency = 0,
                        ImageColor3 = Library.Scheme.AccentColor,
                    }):Play()
                end
            end))

            Library:GiveSignal(MinimizeButton.MouseLeave:Connect(function()
                TweenService:Create(MinimizeButton, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                if MinimizeBar and MinimizeBar.Visible then
                    TweenService:Create(MinimizeBar, Library.TweenInfo, {
                        BackgroundTransparency = 0.35,
                        BackgroundColor3 = Library.Scheme.FontColor,
                        Size = UDim2.fromOffset(12, 2.5),
                    }):Play()
                end
                if MinimizeIconImage and MinimizeIconImage.Visible then
                    TweenService:Create(MinimizeIconImage, Library.TweenInfo, {
                        ImageTransparency = 0.4,
                        ImageColor3 = Library.Scheme.FontColor,
                    }):Play()
                end
            end))
        end

        local CloseButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(26, 26),
            Text = "",
            ZIndex = 11,
            Parent = TopBarActions,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
                Parent = CloseButton,
            })
        )
        Library:AddTooltip("Close Script", "", CloseButton)

        local CloseIcon = Library:GetCustomIcon("x") or Library:GetCustomIcon("x-circle")
        local CloseIconImage
        if CloseIcon then
            CloseIconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.4,
                Size = UDim2.fromOffset(15, 15),
                ZIndex = 12,
                Parent = CloseButton,
            })
            Library:ApplyLucideIcon(CloseIconImage, CloseIcon)
        end

        Library:GiveSignal(CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                BackgroundTransparency = 0.85,
            }):Play()
            if CloseIconImage then
                TweenService:Create(CloseIconImage, Library.TweenInfo, {
                    ImageTransparency = 0,
                    ImageColor3 = Color3.fromRGB(248, 113, 113),
                }):Play()
            end
        end))

        Library:GiveSignal(CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            if CloseIconImage then
                TweenService:Create(CloseIconImage, Library.TweenInfo, {
                    ImageTransparency = 0.4,
                    ImageColor3 = Library.Scheme.FontColor,
                }):Play()
            end
        end))

        Library:GiveSignal(CloseButton.MouseButton1Click:Connect(function()
            if Library.Dialogues and Library.Dialogues["CloseConfirmDialog"] then
                return
            end

            Window:AddDialog("CloseConfirmDialog", {
                Title = "Close Script",
                Description = "Are you sure you want to close the script? This will unhook the script.",
                Icon = "alert-triangle",
                AutoDismiss = true,
                OutsideClickDismiss = true,
                FooterButtons = {
                    {
                        Title = "No",
                        Variant = "Secondary",
                        Callback = function() end,
                    },
                    {
                        Title = "Yes",
                        Variant = "Destructive",
                        Callback = function()
                            Library:Unload()
                        end,
                    },
                },
            })
        end))

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, (WindowInfo.Minimizable ~= false and -124 or -94), 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - (WindowInfo.Minimizable ~= false and 134 or 104) - 1, 1, -16),
            ZIndex = 2,
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            local SearchIconImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
            Library:ApplyLucideIcon(SearchIconImage, SearchIcon)
        end

        --// Bottom Bar \\--
        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20 + WindowInfo.CornerRadius),
            Parent = MainFrame
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
        })

        BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BottomBackground,
            })
        )
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = BottomBar,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, WindowInfo.Resizable and 24 or 8),
            Parent = BottomBar,
        })

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            Text = WindowInfo.Footer,
            TextSize = 13,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = BottomBar,
        })

        local FooterLinksContainer = New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            Parent = BottomBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = FooterLinksContainer,
        })

        local function CreateFooterLink(LinkInfo)
            if typeof(LinkInfo) ~= "table" then return end
            local LinkText = LinkInfo.Text or LinkInfo.Url or "Link"
            local LinkUrl = LinkInfo.Url or LinkInfo.Text or ""
            local LinkIconName = LinkInfo.Icon
            local LinkTooltip = LinkInfo.Tooltip or string.format("Click to copy: %s", LinkUrl)

            local LinkButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.4,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 0, 16),
                Text = "",
                Parent = FooterLinksContainer,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, math.max(2, math.floor(WindowInfo.CornerRadius / 2))),
                    Parent = LinkButton,
                })
            )
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 1),
                PaddingBottom = UDim.new(0, 1),
                Parent = LinkButton,
            })

            local LinkContent = New("Frame", {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 1),
                Parent = LinkButton,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4),
                Parent = LinkContent,
            })

            if LinkIconName then
                local ParsedIcon = Library:GetCustomIcon(LinkIconName)
                if ParsedIcon then
                    local IconImg = New("ImageLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(12, 12),
                        ImageColor3 = "AccentColor",
                        Parent = LinkContent,
                    })
                    Library:ApplyLucideIcon(IconImg, ParsedIcon)
                end
            end

            local Label = New("TextLabel", {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 1),
                Text = LinkText,
                TextSize = 12,
                TextColor3 = "AccentColor",
                Parent = LinkContent,
            })

            Library:AddTooltip(LinkTooltip, "", LinkButton)

            Library:GiveSignal(LinkButton.MouseEnter:Connect(function()
                TweenService:Create(LinkButton, Library.TweenInfo, {
                    BackgroundTransparency = 0.1,
                }):Play()
            end))

            Library:GiveSignal(LinkButton.MouseLeave:Connect(function()
                TweenService:Create(LinkButton, Library.TweenInfo, {
                    BackgroundTransparency = 0.4,
                }):Play()
            end))

            Library:GiveSignal(LinkButton.MouseButton1Click:Connect(function()
                Library:CopyToClipboard(LinkUrl, LinkText)
            end))

            return LinkButton
        end

        if typeof(WindowInfo.FooterLinks) == "table" then
            for _, Link in ipairs(WindowInfo.FooterLinks) do
                CreateFooterLink(Link)
            end
        end

        --// Resize Button \\--
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 1, 0),
                Size = UDim2.fromOffset(20, 20),
                Text = "",
                Parent = MainFrame,
                ZIndex = 5,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        local WindowResizeIcon = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })
        if ResizeIcon then
            Library:ApplyLucideIcon(WindowResizeIcon, ResizeIcon)
        end

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        Library.WindowContainer = Container
        ApplyTransparency(CurrentTransparency)
    end

    --// Window Table \\--
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
    end

    function Window:SetBackgroundImage(Image: string)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        BackgroundImage.Image = CustomImageManager.GetAsset(FileName)
                        BackgroundImage.ImageRectOffset = Vector2.zero
                        BackgroundImage.ImageRectSize = Vector2.zero
                    end
                end
            end
        end

        if not ValidIcon then
            BackgroundImage.Image = ""
            BackgroundImage.ImageRectOffset = Vector2.zero
            BackgroundImage.ImageRectSize = Vector2.zero
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetTransparency(Value: number)
        assert(typeof(Value) == "number", "Expected number for transparency got: " .. typeof(Value))
        ApplyTransparency(Value)
    end

    function Window:GetTransparency(): number
        return CurrentTransparency
    end

    function Window:SetParticles(Enabled: boolean)
        ParticlesEnabled = Enabled == true
        WindowInfo.Particles = ParticlesEnabled
        if ParticleContainer then
            ParticleContainer.Visible = ParticlesEnabled
        end
        if ParticlesEnabled and #ParticlePool == 0 then
            PopulateParticles()
        end
    end

    function Window:GetParticles(): boolean
        return ParticlesEnabled
    end

    function Window:SetParticleSpeed(Speed: number)
        assert(typeof(Speed) == "number", "Expected number for particle speed got: " .. typeof(Speed))
        ParticleSpeed = math.max(0.1, Speed)
        WindowInfo.ParticleSpeed = ParticleSpeed
    end

    function Window:SetParticleCount(Count: number)
        assert(typeof(Count) == "number", "Expected number for particle count got: " .. typeof(Count))
        ParticleCount = math.clamp(math.floor(Count), 5, 150)
        WindowInfo.ParticleCount = ParticleCount
        PopulateParticles()
    end

    function Window:SetParticleType(Type: "Dot" | "Image" | "Emoji" | string)
        if Type == "Emoji" or Type == "Image" or Type == "Dot" then
            ParticleType = Type
            WindowInfo.ParticleType = ParticleType
            PopulateParticles()
        end
    end

    function Window:SetParticleImage(Image: string)
        assert(typeof(Image) == "string", "Expected string for particle image")
        ParticleImage = Image
        WindowInfo.ParticleImage = Image
        ParticleType = "Image"
        WindowInfo.ParticleType = "Image"
        PopulateParticles()
    end

    function Window:SetParticleEmoji(Emoji: string | { string })
        ParticleEmoji = Emoji
        WindowInfo.ParticleEmoji = Emoji
        ParticleType = "Emoji"
        WindowInfo.ParticleType = "Emoji"
        PopulateParticles()
    end

    function Window:SetParticleColor(Color: Color3 | string)
        ParticleColorOverride = Color
        WindowInfo.ParticleColor = Color
        for _, p in ipairs(ParticlePool) do
            if p.gui then
                if typeof(Color) == "string" then
                    p.gui.BackgroundColor3 = Library.Scheme[Color] or Library.Scheme.AccentColor
                elseif typeof(Color) == "Color3" then
                    p.gui.BackgroundColor3 = Color
                end
            end
        end
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 20)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        BottomBackground.Size = UDim2.new(1, 0, 0, 20 + Radius)

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then 
                        continue
                    end
   
                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        if SidebarHidden then
            return
        end
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, math.max(0, Width - 38), 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - (WindowInfo.Minimizable ~= false and 134 or 104) - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:IsSidebarHidden()
        return SidebarHidden
    end

    function Window:SetSidebarHidden(Hidden: boolean)
        if SidebarHidden == Hidden then
            return
        end
        SidebarHidden = Hidden

        if SidebarHidden then
            if not IsCompact and Tabs.Size.X.Offset > 0 then
                LastExpandedWidth = Tabs.Size.X.Offset
            end

            Tabs.Visible = false
            DividerLine.Visible = false

            Tabs.Size = UDim2.new(0, 0, 1, -70)
            Container.Size = UDim2.new(1, 0, 1, -70)

            TitleHolder.Visible = true
            WindowTitle.Visible = true
            if WindowIcon then
                WindowIcon.Visible = true
            end

            if ToggleSidebarIconImage then
                local OpenIcon = Library:GetCustomIcon("panel-left") or Library:GetCustomIcon("menu") or Library:GetCustomIcon("sidebar")
                if OpenIcon then
                    Library:ApplyLucideIcon(ToggleSidebarIconImage, OpenIcon)
                end
            end
            if ToggleSidebarTooltip then
                ToggleSidebarTooltip:SetText("Show Tab Menu")
            end
        else
            local TargetWidth = math.max(InitialLeftWidth, LastExpandedWidth)
            Tabs.Visible = true
            DividerLine.Visible = true
            TitleHolder.Visible = true

            DividerLine.Position = UDim2.fromOffset(TargetWidth, 0)
            TitleHolder.Size = UDim2.new(0, math.max(0, TargetWidth - 38), 1, 0)
            Tabs.Size = UDim2.new(0, TargetWidth, 1, -70)
            Container.Size = UDim2.new(1, -TargetWidth - 1, 1, -70)
            RightWrapper.Size = UDim2.new(1, -TargetWidth - (WindowInfo.Minimizable ~= false and 134 or 104) - 1, 1, -16)

            if WindowInfo.EnableCompacting then
                ApplyCompact()
            end

            if ToggleSidebarIconImage then
                local CloseIcon = Library:GetCustomIcon("panel-left-close") or Library:GetCustomIcon("panel-left") or Library:GetCustomIcon("sidebar") or Library:GetCustomIcon("menu")
                if CloseIcon then
                    Library:ApplyLucideIcon(ToggleSidebarIconImage, CloseIcon)
                end
            end
            if ToggleSidebarTooltip then
                ToggleSidebarTooltip:SetText("Hide Tab Menu")
            end
        end

        for _, Tab in Library.Tabs do
            Tab:Resize(true)
        end
    end

    function Window:ToggleSidebar()
        Window:SetSidebarHidden(not SidebarHidden)
    end

    function Window:HideSidebar()
        Window:SetSidebarHidden(true)
    end

    function Window:ShowSidebar()
        Window:SetSidebarHidden(false)
    end

    Window.ToggleTabs = Window.ToggleSidebar
    Window.HideTabs = Window.HideSidebar
    Window.ShowTabs = Window.ShowSidebar
    Window.IsTabsHidden = Window.IsSidebarHidden

    --// Notification History Popover \\--
    local NotifHistoryPopover = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, -8, 0, 48),
        Size = UDim2.fromOffset(300, 360),
        Visible = false,
        ZIndex = 35,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = NotifHistoryPopover,
        })
    )
    Library:AddOutline(NotifHistoryPopover)

    local NotifPopTop = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 31,
        Parent = NotifHistoryPopover,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 8),
        Parent = NotifPopTop,
    })

    local NotifPopTitle = New("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, -64, 1, 0),
        Text = "Notification History",
        TextSize = 14,
        TextColor3 = "FontColor",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 32,
        Parent = NotifPopTop,
    })

    local NotifPopActions = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(56, 26),
        ZIndex = 32,
        Parent = NotifPopTop,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = NotifPopActions,
    })

    local PopClearBtn = New("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Text = "",
        ZIndex = 33,
        Parent = NotifPopActions,
    })
    local TrashIcon = Library:GetCustomIcon("trash-2")
    if TrashIcon then
        local TrashImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 34,
            Parent = PopClearBtn,
        })
        Library:ApplyLucideIcon(TrashImg, TrashIcon)
        PopClearBtn.MouseEnter:Connect(function()
            TweenService:Create(TrashImg, Library.TweenInfo, {
                ImageTransparency = 0,
                ImageColor3 = Color3.fromRGB(255, 75, 75),
            }):Play()
        end)
        PopClearBtn.MouseLeave:Connect(function()
            TweenService:Create(TrashImg, Library.TweenInfo, {
                ImageTransparency = 0.4,
                ImageColor3 = Library.Scheme.FontColor,
            }):Play()
        end)
    end
    Library:AddTooltip("Clear history", "", PopClearBtn)

    local PopCloseBtn = New("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Text = "",
        ZIndex = 33,
        Parent = NotifPopActions,
    })
    local CloseIcon = Library:GetCustomIcon("x")
    if CloseIcon then
        local CloseImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 34,
            Parent = PopCloseBtn,
        })
        Library:ApplyLucideIcon(CloseImg, CloseIcon)
        PopCloseBtn.MouseEnter:Connect(function()
            TweenService:Create(CloseImg, Library.TweenInfo, {
                ImageTransparency = 0,
            }):Play()
        end)
        PopCloseBtn.MouseLeave:Connect(function()
            TweenService:Create(CloseImg, Library.TweenInfo, {
                ImageTransparency = 0.4,
            }):Play()
        end)
    end
    PopCloseBtn.MouseButton1Click:Connect(function()
        NotifHistoryPopover.Visible = false
    end)

    local NotifPopLine = Library:MakeLine(NotifHistoryPopover, {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 31,
    })

    local NotifPopScroll = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        Position = UDim2.fromOffset(0, 37),
        ScrollBarThickness = 3,
        Size = UDim2.new(1, 0, 1, -37),
        ZIndex = 31,
        Parent = NotifHistoryPopover,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = NotifPopScroll,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = NotifPopScroll,
    })

    local function CreateNotificationCard(Item, ParentContainer, BaseZIndex)
        BaseZIndex = BaseZIndex or 1
        local Card = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 2)
            end,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = BaseZIndex,
            Parent = ParentContainer,
        })
        table.insert(Library.Corners, New("UICorner", {
            CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
            Parent = Card,
        }))
        Library:AddOutline(Card)
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 8),
            Parent = Card,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            Parent = Card,
        })

        local HeaderRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            ZIndex = BaseZIndex + 1,
            Parent = Card,
        })

        local TimeLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Text = string.format("[%s]", Item.FormattedTime or os.date("%X")),
            TextColor3 = "AccentColor",
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = BaseZIndex + 2,
            Parent = HeaderRow,
        })

        local CardCopyBtn = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            ZIndex = BaseZIndex + 2,
            Parent = HeaderRow,
        })
        local CopyIcon = Library:GetCustomIcon("copy")
        local CopyImg
        if CopyIcon then
            CopyImg = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(14, 14),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.4,
                ZIndex = BaseZIndex + 3,
                Parent = CardCopyBtn,
            })
            Library:ApplyLucideIcon(CopyImg, CopyIcon)
        end
        Library:AddTooltip("Copy notification", "", CardCopyBtn)

        CardCopyBtn.MouseEnter:Connect(function()
            if CopyImg then
                TweenService:Create(CopyImg, Library.TweenInfo, {
                    ImageTransparency = 0,
                    ImageColor3 = Library.Scheme.AccentColor,
                }):Play()
            end
        end)
        CardCopyBtn.MouseLeave:Connect(function()
            if CopyImg then
                TweenService:Create(CopyImg, Library.TweenInfo, {
                    ImageTransparency = 0.4,
                    ImageColor3 = Library.Scheme.FontColor,
                }):Play()
            end
        end)
        CardCopyBtn.MouseButton1Click:Connect(function()
            local CopyText = string.format("[%s] %s\n%s", Item.FormattedTime or "", Item.Title or "", Item.Description or "")
            Library:CopyToClipboard(CopyText, Item.Title or "Notification", false)
        end)

        local TitleLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Text = Item.Title or "Notification",
            TextColor3 = Item.TitleColor or "FontColor",
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = BaseZIndex + 2,
            Parent = Card,
        })

        if Item.Description and Item.Description ~= "" then
            local DescLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Item.Description,
                TextColor3 = Item.DescriptionColor or "FontColor",
                TextTransparency = 0.2,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = BaseZIndex + 2,
                Parent = Card,
            })
        end

        return Card
    end

    local function RefreshPopCards()
        for _, Child in ipairs(NotifPopScroll:GetChildren()) do
            if Child:IsA("GuiObject") and not Child:IsA("UIListLayout") and not Child:IsA("UIPadding") then
                Child:Destroy()
            end
        end

        if #Library.NotificationHistory == 0 then
            local EmptyHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 120),
                ZIndex = 32,
                Parent = NotifPopScroll,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                Parent = EmptyHolder,
            })
            local EmptyIcon = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.6,
                ZIndex = 33,
                Parent = EmptyHolder,
            })
            if BellIcon then
                Library:ApplyLucideIcon(EmptyIcon, BellIcon)
            end
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "No notification history",
                TextColor3 = "FontColor",
                TextTransparency = 0.6,
                TextSize = 13,
                ZIndex = 33,
                Parent = EmptyHolder,
            })
            return
        end

        for _, Item in ipairs(Library.NotificationHistory) do
            CreateNotificationCard(Item, NotifPopScroll, 32)
        end
    end

    if NotifHistoryButton then
        NotifHistoryButton.MouseButton1Click:Connect(function()
            if ActiveFeaturesPopover then ActiveFeaturesPopover.Visible = false end
            NotifHistoryPopover.Visible = not NotifHistoryPopover.Visible
            if NotifHistoryPopover.Visible then
                RefreshPopCards()
                NotifHistoryPopover.AnchorPoint = Vector2.new(1, 0)
                NotifHistoryPopover.Position = UDim2.fromOffset(
                    MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X - 8,
                    MainFrame.AbsolutePosition.Y + 48
                )
            end
        end)
    end

    if PopClearBtn then
        PopClearBtn.MouseButton1Click:Connect(function()
            table.clear(Library.NotificationHistory)
            RefreshPopCards()
            if NotifBadge then
                NotifBadge.Visible = false
            end
            if FloatNotifBadge then
                FloatNotifBadge.Visible = false
            end
            if Library.RefreshTabNotifs then
                Library.RefreshTabNotifs()
            end
            Library:Notify({
                Title = "History Cleared",
                Description = "Notification history has been cleared.",
                Time = 2,
                Icon = "trash-2",
                SkipHistory = true,
            })
        end)
    end

    --// Active Features Popover \\--
    ActiveFeaturesPopover = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, -8, 0, 48),
        Size = UDim2.fromOffset(320, 360),
        Visible = false,
        ZIndex = 35,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = ActiveFeaturesPopover,
        })
    )
    Library:AddOutline(ActiveFeaturesPopover)

    local ActivePopTop = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 36,
        Parent = ActiveFeaturesPopover,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 8),
        Parent = ActivePopTop,
    })

    local ActivePopTitle = New("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, -64, 1, 0),
        Text = "Active Features (0)",
        TextSize = 14,
        TextColor3 = "FontColor",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 37,
        Parent = ActivePopTop,
    })

    local ActivePopActions = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(56, 26),
        ZIndex = 37,
        Parent = ActivePopTop,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = ActivePopActions,
    })

    -- Turn Off All button
    local ActiveResetAllBtn = New("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Text = "",
        ZIndex = 38,
        Parent = ActivePopActions,
    })
    local ResetIcon = Library:GetCustomIcon("rotate-ccw") or Library:GetCustomIcon("power")
    if ResetIcon then
        local ResetImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 39,
            Parent = ActiveResetAllBtn,
        })
        Library:ApplyLucideIcon(ResetImg, ResetIcon)
    end
    Library:AddTooltip("Turn off all active features", "", ActiveResetAllBtn)

    local ActiveCloseBtn = New("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Text = "",
        ZIndex = 38,
        Parent = ActivePopActions,
    })
    local PopCloseIcon = Library:GetCustomIcon("x")
    if PopCloseIcon then
        local CloseImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 39,
            Parent = ActiveCloseBtn,
        })
        Library:ApplyLucideIcon(CloseImg, PopCloseIcon)
    end

    Library:MakeLine(ActiveFeaturesPopover, {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 36,
    })

    local ActivePopScroll = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        Position = UDim2.fromOffset(0, 37),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = "OutlineColor",
        Size = UDim2.new(1, 0, 1, -37),
        ZIndex = 36,
        Parent = ActiveFeaturesPopover,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = ActivePopScroll,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = ActivePopScroll,
    })

    local OpenActiveSnapshot = nil

    local function CountActiveInSnapshot()
        if not OpenActiveSnapshot then return 0 end
        local cnt = 0
        for _, Item in ipairs(OpenActiveSnapshot) do
            if Item.Toggle and Item.Toggle.Value == true and not Item.Toggle.Destroyed then
                cnt += 1
            end
        end
        return cnt
    end

    local function RefreshActiveFeaturesCards(ForceNewSnapshot: boolean)
        for _, Child in ipairs(ActivePopScroll:GetChildren()) do
            if Child:IsA("GuiObject") and not Child:IsA("UIListLayout") and not Child:IsA("UIPadding") then
                Child:Destroy()
            end
        end

        if ForceNewSnapshot or not OpenActiveSnapshot then
            OpenActiveSnapshot = {}
            for Idx, Toggle in pairs(Library.Toggles) do
                if Toggle and Toggle.Value == true and not Toggle.Destroyed then
                    table.insert(OpenActiveSnapshot, { Idx = Idx, Toggle = Toggle })
                end
            end
            table.sort(OpenActiveSnapshot, function(a, b)
                return (a.Toggle.Text or tostring(a.Idx)) < (b.Toggle.Text or tostring(b.Idx))
            end)
        end

        ActivePopTitle.Text = string.format("Active Features (%d)", CountActiveInSnapshot())

        if #OpenActiveSnapshot == 0 then
            local EmptyHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 120),
                ZIndex = 37,
                Parent = ActivePopScroll,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                Parent = EmptyHolder,
            })
            local EmptyText = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "No active features running",
                TextColor3 = "FontColor",
                TextTransparency = 0.6,
                TextSize = 13,
                Font = Enum.Font.Code,
                ZIndex = 38,
                Parent = EmptyHolder,
            })
            return
        end

        for _, Item in ipairs(OpenActiveSnapshot) do
            local Toggle = Item.Toggle
            local Card = New("Frame", {
                BackgroundColor3 = function()
                    return Library:GetBetterColor(Library.Scheme.BackgroundColor, 2)
                end,
                Size = UDim2.new(1, 0, 0, 36),
                ZIndex = 37,
                Parent = ActivePopScroll,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, math.max(4, math.floor(WindowInfo.CornerRadius / 2))),
                    Parent = Card,
                })
            )
            Library:AddOutline(Card)

            local NameLabel = New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(1, -84, 1, 0),
                Text = Toggle.Text or tostring(Item.Idx),
                TextColor3 = "FontColor",
                TextTransparency = Toggle.Value and 0 or 0.5,
                TextSize = 13,
                Font = Enum.Font.Code,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 38,
                Parent = Card,
            })

            local Controls = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -6, 0.5, 0),
                Size = UDim2.fromOffset(68, 24),
                ZIndex = 38,
                Parent = Card,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Controls,
            })

            local ResetBtn = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(20, 20),
                Text = "",
                ZIndex = 39,
                Parent = Controls,
            })
            local ResetSingleIcon = Library:GetCustomIcon("rotate-ccw")
            if ResetSingleIcon then
                local ResetSingleImg = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(12, 12),
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.5,
                    ZIndex = 40,
                    Parent = ResetBtn,
                })
                Library:ApplyLucideIcon(ResetSingleImg, ResetSingleIcon)
            end
            Library:AddTooltip("Reset to default", "", ResetBtn)

            local SwitchBtn = New("TextButton", {
                BackgroundColor3 = Toggle.Value and "AccentColor" or "OutlineColor",
                Size = UDim2.fromOffset(36, 18),
                Text = "",
                ZIndex = 39,
                Parent = Controls,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SwitchBtn,
                })
            )
            local SwitchThumb = New("Frame", {
                AnchorPoint = Vector2.new(Toggle.Value and 1 or 0, 0.5),
                BackgroundColor3 = Toggle.Value and Library.Scheme.WhiteColor or Library:GetBetterColor(Library.Scheme.FontColor, -30),
                Position = Toggle.Value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 40,
                Parent = SwitchBtn,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SwitchThumb,
                })
            )

            local function UpdateSwitchVisual(isOn: boolean)
                TweenService:Create(SwitchBtn, Library.TweenInfo, {
                    BackgroundColor3 = isOn and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
                }):Play()
                TweenService:Create(SwitchThumb, Library.TweenInfo, {
                    AnchorPoint = Vector2.new(isOn and 1 or 0, 0.5),
                    Position = isOn and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    BackgroundColor3 = isOn and Library.Scheme.WhiteColor or Library:GetBetterColor(Library.Scheme.FontColor, -30),
                }):Play()
                TweenService:Create(NameLabel, Library.TweenInfo, {
                    TextTransparency = isOn and 0 or 0.5,
                }):Play()
                ActivePopTitle.Text = string.format("Active Features (%d)", CountActiveInSnapshot())
            end

            Item.UpdateVisual = UpdateSwitchVisual

            ResetBtn.MouseButton1Click:Connect(function()
                Toggle:SetValue(Toggle.Default)
                UpdateSwitchVisual(Toggle.Value)
            end)

            SwitchBtn.MouseButton1Click:Connect(function()
                local NewVal = not Toggle.Value
                Toggle:SetValue(NewVal)
                UpdateSwitchVisual(NewVal)
            end)
        end
    end

    ActiveCloseBtn.MouseButton1Click:Connect(function()
        ActiveFeaturesPopover.Visible = false
        OpenActiveSnapshot = nil
    end)

    ActiveResetAllBtn.MouseButton1Click:Connect(function()
        if OpenActiveSnapshot then
            for _, Item in ipairs(OpenActiveSnapshot) do
                if Item.Toggle and not Item.Toggle.Destroyed then
                    Item.Toggle:SetValue(false)
                    if Item.UpdateVisual then
                        Item.UpdateVisual(false)
                    end
                end
            end
        else
            for _, Toggle in pairs(Library.Toggles) do
                if Toggle and Toggle.Value == true and not Toggle.Destroyed then
                    Toggle:SetValue(false)
                end
            end
        end
    end)

    Library.RefreshActiveFeaturesCards = RefreshActiveFeaturesCards
    Library.OnActiveFeaturesClosed = function()
        OpenActiveSnapshot = nil
    end

    function Library:UpdateActiveFeaturesCount()
        local Count = 0
        for _, Toggle in pairs(Library.Toggles) do
            if Toggle and Toggle.Value == true and not Toggle.Destroyed then
                Count += 1
            end
        end

        if ActiveFeaturesBadge then
            ActiveFeaturesBadge.Visible = (Count > 0)
            if ActiveFeaturesBadgeLabel then
                ActiveFeaturesBadgeLabel.Text = tostring(Count)
            end
        end
        if FloatActiveBadge then
            FloatActiveBadge.Visible = (Count > 0)
            if FloatActiveBadgeLabel then
                FloatActiveBadgeLabel.Text = tostring(Count)
            end
        end
        if ActivePopTitle and not (ActiveFeaturesPopover and ActiveFeaturesPopover.Visible) then
            ActivePopTitle.Text = string.format("Active Features (%d)", Count)
        end
    end

    --// Small Smart Floating Tab (Minimized Widget) \\--
    local CurrentFloatingOrientation = "vertical"
    local LastFloatingTabPosition = UDim2.new(0, 20, 0.5, -107)

    local FloatLayout
    local FloatBrandCard
    local FloatBrandLayout
    local FloatLine1
    local FloatLine2
    local FloatAvatarCard
    local FloatActionsHolder
    local FloatActionsLayout

    local SetMinimizedState

    FloatingTabWidget = New("TextButton", {
        Name = "ObsidianFloatingTab",
        Text = "",
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = LastFloatingTabPosition,
        Size = UDim2.fromOffset(56, 248),
        Visible = false,
        ZIndex = 25,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 16),
            Parent = FloatingTabWidget,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = FloatingTabWidget,
        })
    )
    Library:AddOutline(FloatingTabWidget)
    Library:MakeDraggable(FloatingTabWidget, FloatingTabWidget, false, true, WindowSnapConfig)

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 8),
        Parent = FloatingTabWidget,
    })

    FloatLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = FloatingTabWidget,
    })

    -- 1. Brand Card (App Icon + SAIOPS HUB text)
    FloatBrandCard = New("Frame", {
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
        end,
        Size = UDim2.new(1, 0, 0, 58),
        ZIndex = 26,
        Parent = FloatingTabWidget,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = FloatBrandCard,
        })
    )
    Library:AddOutline(FloatBrandCard)
    Library:AddTooltip("SAIOPS HUB", "", FloatBrandCard)

    FloatBrandLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 3),
        Parent = FloatBrandCard,
    })

    local FloatAppIconImg = New("ImageLabel", {
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0,
        Size = UDim2.fromOffset(26, 26),
        Image = (Library:GetCustomIcon("icon.png") and Library:GetCustomIcon("icon.png").Url) or CustomImageManager.GetAsset("AppIcon") or "rbxassetid://95816097006870",
        ZIndex = 27,
        Parent = FloatBrandCard,
    })

    local FloatBrandText = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Text = "SAIOPS\nHUB",
        TextColor3 = "AccentColor",
        TextSize = 8.5,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 27,
        Parent = FloatBrandCard,
    })

    -- 2. Separator Line 1
    FloatLine1 = Library:MakeLine(FloatingTabWidget, {
        Size = UDim2.new(0, 36, 0, 1),
        ZIndex = 26,
    })

    -- 3. Player Avatar Frame
    FloatAvatarCard = New("Frame", {
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
        end,
        Size = UDim2.fromOffset(36, 36),
        ZIndex = 26,
        Parent = FloatingTabWidget,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = FloatAvatarCard,
        })
    )
    New("UIStroke", {
        Color = Color3.fromRGB(75, 80, 95),
        Thickness = 1.5,
        Parent = FloatAvatarCard,
    })
    Library:AddTooltip(string.format("Player: %s (@%s)", LocalPlayer.DisplayName, LocalPlayer.Name), "", FloatAvatarCard)

    local FloatAvatarImg = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", LocalPlayer.UserId),
        ZIndex = 27,
        Parent = FloatAvatarCard,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = FloatAvatarImg,
        })
    )
    task.spawn(function()
        pcall(function()
            local Thumb, IsReady = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
            if Thumb and Thumb ~= "" then
                FloatAvatarImg.Image = Thumb
            end
        end)
    end)

    -- 4. Separator Line 2
    FloatLine2 = Library:MakeLine(FloatingTabWidget, {
        Size = UDim2.new(0, 36, 0, 1),
        ZIndex = 26,
    })

    -- 5. Nav Action Buttons Holder
    FloatActionsHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 102),
        ZIndex = 26,
        Parent = FloatingTabWidget,
    })
    FloatActionsLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = FloatActionsHolder,
    })

    -- 5a. Restore / Reopen Button
    local FloatReopenBtn = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(30, 30),
        Text = "",
        ZIndex = 27,
        Parent = FloatActionsHolder,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = FloatReopenBtn,
        })
    )
    Library:AddTooltip("Restore Window", "", FloatReopenBtn)

    local ReopenIcon = Library:GetCustomIcon("maximize-2") or Library:GetCustomIcon("external-link")
    local ReopenIconImg
    if ReopenIcon then
        ReopenIconImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(16, 16),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 28,
            Parent = FloatReopenBtn,
        })
        Library:ApplyLucideIcon(ReopenIconImg, ReopenIcon)
    end

    FloatReopenBtn.MouseEnter:Connect(function()
        TweenService:Create(FloatReopenBtn, Library.TweenInfo, {
            BackgroundTransparency = 0.85,
        }):Play()
        if ReopenIconImg then
            TweenService:Create(ReopenIconImg, Library.TweenInfo, {
                ImageTransparency = 0,
                ImageColor3 = Library.Scheme.AccentColor,
            }):Play()
        end
    end)
    FloatReopenBtn.MouseLeave:Connect(function()
        TweenService:Create(FloatReopenBtn, Library.TweenInfo, {
            BackgroundTransparency = 1,
        }):Play()
        if ReopenIconImg then
            TweenService:Create(ReopenIconImg, Library.TweenInfo, {
                ImageTransparency = 0.4,
                ImageColor3 = Library.Scheme.FontColor,
            }):Play()
        end
    end)
    FloatReopenBtn.MouseButton1Click:Connect(function()
        if SetMinimizedState then
            SetMinimizedState(false)
        end
    end)

    -- 5b. Active Features Button
    FloatActiveBtn = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(30, 30),
        Text = "",
        ZIndex = 27,
        Parent = FloatActionsHolder,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = FloatActiveBtn,
        })
    )
    Library:AddTooltip("Active Features", "", FloatActiveBtn)

    local FloatActiveIcon = Library:GetCustomIcon("sliders-horizontal") or Library:GetCustomIcon("sliders") or Library:GetCustomIcon("activity")
    local FloatActiveImg
    if FloatActiveIcon then
        FloatActiveImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(16, 16),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 28,
            Parent = FloatActiveBtn,
        })
        Library:ApplyLucideIcon(FloatActiveImg, FloatActiveIcon)
    end

    FloatActiveBadge = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = "AccentColor",
        Position = UDim2.new(1, -1, 0, 1),
        Size = UDim2.fromOffset(12, 12),
        Visible = false,
        ZIndex = 29,
        Parent = FloatActiveBtn,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = FloatActiveBadge,
        })
    )
    FloatActiveBadgeLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "0",
        TextColor3 = "WhiteColor",
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        ZIndex = 30,
        Parent = FloatActiveBadge,
    })

    FloatActiveBtn.MouseEnter:Connect(function()
        TweenService:Create(FloatActiveBtn, Library.TweenInfo, {
            BackgroundTransparency = 0.85,
        }):Play()
        if FloatActiveImg then
            TweenService:Create(FloatActiveImg, Library.TweenInfo, {
                ImageTransparency = 0,
                ImageColor3 = Library.Scheme.AccentColor,
            }):Play()
        end
    end)
    FloatActiveBtn.MouseLeave:Connect(function()
        TweenService:Create(FloatActiveBtn, Library.TweenInfo, {
            BackgroundTransparency = 1,
        }):Play()
        if FloatActiveImg then
            TweenService:Create(FloatActiveImg, Library.TweenInfo, {
                ImageTransparency = 0.4,
                ImageColor3 = Library.Scheme.FontColor,
            }):Play()
        end
    end)
    FloatActiveBtn.MouseButton1Click:Connect(function()
        if NotifHistoryPopover then NotifHistoryPopover.Visible = false end
        ActiveFeaturesPopover.Visible = not ActiveFeaturesPopover.Visible
        if ActiveFeaturesPopover.Visible then
            if Library.RefreshActiveFeaturesCards then
                Library.RefreshActiveFeaturesCards(true)
            end
            local Cam = workspace.CurrentCamera
            local VpX = Cam and Cam.ViewportSize.X or 1000
            local VpY = Cam and Cam.ViewportSize.Y or 800

            if CurrentFloatingOrientation == "horizontal" then
                ActiveFeaturesPopover.AnchorPoint = Vector2.new(0.5, 0)
                local TargetX = math.clamp(FloatingTabWidget.AbsolutePosition.X + (FloatingTabWidget.AbsoluteSize.X / 2), 170, VpX - 170)
                local TargetY = (FloatingTabWidget.AbsolutePosition.Y + FloatingTabWidget.AbsoluteSize.Y + 390 <= VpY)
                    and (FloatingTabWidget.AbsolutePosition.Y + FloatingTabWidget.AbsoluteSize.Y + 10)
                    or (FloatingTabWidget.AbsolutePosition.Y - 380)
                ActiveFeaturesPopover.Position = UDim2.fromOffset(TargetX, math.clamp(TargetY, 10, VpY - 380))
            else
                ActiveFeaturesPopover.AnchorPoint = Vector2.new(0, 0)
                local TargetX = (FloatingTabWidget.AbsolutePosition.X + FloatingTabWidget.AbsoluteSize.X + 330 <= VpX)
                    and (FloatingTabWidget.AbsolutePosition.X + FloatingTabWidget.AbsoluteSize.X + 10)
                    or (FloatingTabWidget.AbsolutePosition.X - 330)
                local TargetY = math.clamp(FloatingTabWidget.AbsolutePosition.Y, 10, VpY - 380)
                ActiveFeaturesPopover.Position = UDim2.fromOffset(math.clamp(TargetX, 10, VpX - 330), TargetY)
            end
        else
            if Library.OnActiveFeaturesClosed then
                Library.OnActiveFeaturesClosed()
            end
        end
    end)

    -- 5c. Notification History Button
    local FloatNotifBtn = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(30, 30),
        Text = "",
        ZIndex = 27,
        Parent = FloatActionsHolder,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = FloatNotifBtn,
        })
    )
    Library:AddTooltip("Notification History", "", FloatNotifBtn)

    local FloatBellIcon = Library:GetCustomIcon("bell")
    local FloatBellImg
    if FloatBellIcon then
        FloatBellImg = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(16, 16),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.4,
            ZIndex = 28,
            Parent = FloatNotifBtn,
        })
        Library:ApplyLucideIcon(FloatBellImg, FloatBellIcon)
    end

    FloatNotifBadge = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = "AccentColor",
        Position = UDim2.new(1, -2, 0, 2),
        Size = UDim2.fromOffset(6, 6),
        Visible = (#Library.NotificationHistory > 0),
        ZIndex = 29,
        Parent = FloatNotifBtn,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = FloatNotifBadge,
        })
    )

    FloatNotifBtn.MouseEnter:Connect(function()
        TweenService:Create(FloatNotifBtn, Library.TweenInfo, {
            BackgroundTransparency = 0.85,
        }):Play()
        if FloatBellImg then
            TweenService:Create(FloatBellImg, Library.TweenInfo, {
                ImageTransparency = 0,
                ImageColor3 = Library.Scheme.AccentColor,
            }):Play()
        end
    end)
    FloatNotifBtn.MouseLeave:Connect(function()
        TweenService:Create(FloatNotifBtn, Library.TweenInfo, {
            BackgroundTransparency = 1,
        }):Play()
        if FloatBellImg then
            TweenService:Create(FloatBellImg, Library.TweenInfo, {
                ImageTransparency = 0.4,
                ImageColor3 = Library.Scheme.FontColor,
            }):Play()
        end
    end)
    FloatNotifBtn.MouseButton1Click:Connect(function()
        if ActiveFeaturesPopover then ActiveFeaturesPopover.Visible = false end
        NotifHistoryPopover.Visible = not NotifHistoryPopover.Visible
        if NotifHistoryPopover.Visible then
            RefreshPopCards()
            local Cam = workspace.CurrentCamera
            local VpX = Cam and Cam.ViewportSize.X or 1000
            local VpY = Cam and Cam.ViewportSize.Y or 800

            if CurrentFloatingOrientation == "horizontal" then
                NotifHistoryPopover.AnchorPoint = Vector2.new(0.5, 0)
                local TargetX = math.clamp(FloatingTabWidget.AbsolutePosition.X + (FloatingTabWidget.AbsoluteSize.X / 2), 160, VpX - 160)
                local TargetY = (FloatingTabWidget.AbsolutePosition.Y + FloatingTabWidget.AbsoluteSize.Y + 380 <= VpY)
                    and (FloatingTabWidget.AbsolutePosition.Y + FloatingTabWidget.AbsoluteSize.Y + 10)
                    or (FloatingTabWidget.AbsolutePosition.Y - 370)
                NotifHistoryPopover.Position = UDim2.fromOffset(TargetX, math.clamp(TargetY, 10, VpY - 370))
            else
                NotifHistoryPopover.AnchorPoint = Vector2.new(0, 0)
                local TargetX = (FloatingTabWidget.AbsolutePosition.X + FloatingTabWidget.AbsoluteSize.X + 320 <= VpX)
                    and (FloatingTabWidget.AbsolutePosition.X + FloatingTabWidget.AbsoluteSize.X + 10)
                    or (FloatingTabWidget.AbsolutePosition.X - 310)
                local TargetY = math.clamp(FloatingTabWidget.AbsolutePosition.Y, 10, VpY - 370)
                NotifHistoryPopover.Position = UDim2.fromOffset(math.clamp(TargetX, 10, VpX - 310), TargetY)
            end
        end
    end)

    local function UpdateFloatingOrientation(ForceOrientation: string?)
        local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local Pos = FloatingTabWidget.AbsolutePosition
        local Size = FloatingTabWidget.AbsoluteSize

        local DistLeft = math.max(0, Pos.X)
        local DistRight = math.max(0, ViewportSize.X - (Pos.X + Size.X))
        local DistTop = math.max(0, Pos.Y)
        local DistBottom = math.max(0, ViewportSize.Y - (Pos.Y + Size.Y))

        local MinHoriz = math.min(DistLeft, DistRight)
        local MinVert = math.min(DistTop, DistBottom)

        local NewOrientation = ForceOrientation or (MinHoriz <= MinVert and "vertical" or "horizontal")
        if CurrentFloatingOrientation == NewOrientation and not ForceOrientation then
            return
        end
        CurrentFloatingOrientation = NewOrientation

        if NewOrientation == "horizontal" then
            FloatingTabWidget.Size = UDim2.fromOffset(280, 52)
            FloatLayout.FillDirection = Enum.FillDirection.Horizontal
            FloatBrandLayout.FillDirection = Enum.FillDirection.Horizontal
            FloatBrandCard.Size = UDim2.new(0, 96, 1, 0)
            FloatBrandText.Size = UDim2.new(0, 54, 1, 0)
            FloatLine1.Size = UDim2.new(0, 1, 0, 28)
            FloatLine2.Size = UDim2.new(0, 1, 0, 28)
            FloatActionsLayout.FillDirection = Enum.FillDirection.Horizontal
            FloatActionsHolder.Size = UDim2.new(0, 102, 1, 0)
        else
            FloatingTabWidget.Size = UDim2.fromOffset(56, 248)
            FloatLayout.FillDirection = Enum.FillDirection.Vertical
            FloatBrandLayout.FillDirection = Enum.FillDirection.Vertical
            FloatBrandCard.Size = UDim2.new(1, 0, 0, 58)
            FloatBrandText.Size = UDim2.new(1, 0, 0, 20)
            FloatLine1.Size = UDim2.new(0, 36, 0, 1)
            FloatLine2.Size = UDim2.new(0, 36, 0, 1)
            FloatActionsLayout.FillDirection = Enum.FillDirection.Vertical
            FloatActionsHolder.Size = UDim2.new(1, 0, 0, 102)
        end
    end

    FloatingTabWidget:GetPropertyChangedSignal("Position"):Connect(function()
        if FloatingTabWidget.Visible then
            LastFloatingTabPosition = FloatingTabWidget.Position
            UpdateFloatingOrientation()
        end
    end)

    SetMinimizedState = function(Minimized: boolean)
        IsMinimized = Minimized

        if IsMinimized then
            Library.Toggled = false

            if ResizeButton then ResizeButton.Visible = false end
            if NotifHistoryPopover then NotifHistoryPopover.Visible = false end
            if ActiveFeaturesPopover then ActiveFeaturesPopover.Visible = false end
            if Library.DropdownModalInstance then
                Library.DropdownModalInstance:Destroy()
                Library.DropdownModalInstance = nil
            end

            MainFrame.Visible = false

            FloatingTabWidget.Position = LastFloatingTabPosition
            UpdateFloatingOrientation()
            FloatingTabWidget.Visible = true

            if FloatNotifBadge then
                FloatNotifBadge.Visible = (#Library.NotificationHistory > 0)
            end
            if Library.UpdateActiveFeaturesCount then
                Library:UpdateActiveFeaturesCount()
            end

            if WindowInfo.UnlockMouseWhileOpen then
                ModalElement.Modal = false
            end

            RestoreMouseIcon()
            TooltipLabel.Visible = false

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        else
            Library.Toggled = true

            LastFloatingTabPosition = FloatingTabWidget.Position
            FloatingTabWidget.Visible = false
            if NotifHistoryPopover then
                NotifHistoryPopover.Visible = false
            end
            if ActiveFeaturesPopover then
                ActiveFeaturesPopover.Visible = false
            end

            -- Center MainFrame in the middle of the screen every time it reopens
            local Cam = workspace.CurrentCamera
            local VpX = Cam and Cam.ViewportSize.X or 1920
            local VpY = Cam and Cam.ViewportSize.Y or 1080
            MainFrame.Position = UDim2.fromOffset(
                math.max(10, math.floor((VpX - MainFrame.AbsoluteSize.X) / 2)),
                math.max(10, math.floor((VpY - MainFrame.AbsoluteSize.Y) / 2))
            )
            MainFrame.Visible = true

            if Tabs then Tabs.Visible = not SidebarHidden end
            if Container then Container.Visible = true end
            if DividerLine then DividerLine.Visible = not SidebarHidden end
            if TitleHolder then TitleHolder.Visible = true end
            if BottomBackground then BottomBackground.Visible = true end
            if BottomBar then BottomBar.Visible = true end
            if ResizeButton and WindowInfo.Resizable then
                ResizeButton.Visible = true
            end
            if Library.ActiveTab then
                Library.ActiveTab:Resize(true)
            end

            if WindowInfo.UnlockMouseWhileOpen then
                ModalElement.Modal = true
            end

            EnableMouseIcon()
        end
    end

    if MinimizeButton then
        MinimizeButton.MouseButton1Click:Connect(function()
            SetMinimizedState(not IsMinimized)
        end)
    end

    function Window:Minimize()
        SetMinimizedState(true)
    end

    function Window:Maximize()
        SetMinimizedState(false)
    end

    function Window:ToggleMinimize()
        SetMinimizedState(not IsMinimized)
    end

    function Window:IsMinimized()
        return IsMinimized
    end

    function Window:AddFooterLink(LinkInfo)
        return CreateFooterLink(LinkInfo)
    end

    function Window:SetFooterLinks(Links)
        for _, Child in FooterLinksContainer:GetChildren() do
            if Child:IsA("GuiObject") then
                Child:Destroy()
            end
        end
        if typeof(Links) == "table" then
            for _, Link in ipairs(Links) do
                CreateFooterLink(Link)
            end
        end
    end

    function Window:AddNotificationTab(...)
        local Name = "Notifications"
        local Icon = "bell"
        local Description = "Notification history and alerts"
        local Order = 9999

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or Name
            Icon = Info.Icon or Icon
            Description = Info.Description or Description
            Order = Info.Order or Order
        elseif select("#", ...) >= 1 then
            Name = select(1, ...) or Name
            Icon = select(2, ...) or Icon
            Description = select(3, ...) or Description
            Order = select(4, ...) or Order
        end

        local NotifTab = Window:AddTab({
            Name = Name,
            Icon = Icon,
            Description = Description,
            Order = Order,
        })

        local ControlsBox = NotifTab:AddLeftGroupbox("Controls", "sliders")
        local LogBox = NotifTab:AddRightGroupbox("History", "history")

        local CountLabel = ControlsBox:AddLabel(string.format("Total Notifications: %d", #Library.NotificationHistory))

        local HistoryListHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = LogBox.Container,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = HistoryListHolder,
        })

        local function RefreshTabCards()
            for _, Child in ipairs(HistoryListHolder:GetChildren()) do
                if Child:IsA("GuiObject") and not Child:IsA("UIListLayout") then
                    Child:Destroy()
                end
            end

            for _, Item in ipairs(Library.NotificationHistory) do
                CreateNotificationCard(Item, HistoryListHolder, 2)
            end
            CountLabel:SetText(string.format("Total Notifications: %d", #Library.NotificationHistory))
            LogBox:Resize()
        end

        Library.RefreshTabNotifs = RefreshTabCards

        ControlsBox:AddButton({
            Text = "Clear History",
            DoubleClick = false,
            Tooltip = "Clear all notification history",
            Risky = true,
            Func = function()
                table.clear(Library.NotificationHistory)
                RefreshTabCards()
                RefreshPopCards()
                if NotifBadge then
                    NotifBadge.Visible = false
                end
                if FloatNotifBadge then
                    FloatNotifBadge.Visible = false
                end
                Library:Notify({
                    Title = "History Cleared",
                    Description = "Notification history has been cleared.",
                    Time = 2,
                    Icon = "trash-2",
                    SkipHistory = true,
                })
            end,
        })

        ControlsBox:AddButton({
            Text = "Copy All Logs",
            Tooltip = "Copy all notifications as text",
            Func = function()
                if #Library.NotificationHistory == 0 then
                    Library:Notify({
                        Title = "Clipboard",
                        Description = "No notifications to copy.",
                        Time = 2,
                        Icon = "info",
                        SkipHistory = true,
                    })
                    return
                end
                local LogLines = {}
                for _, Item in ipairs(Library.NotificationHistory) do
                    table.insert(LogLines, string.format("[%s] %s: %s", Item.FormattedTime or "", Item.Title or "", Item.Description or ""))
                end
                Library:CopyToClipboard(table.concat(LogLines, "\n"), "Notification History", false)
            end,
        })

        RefreshTabCards()

        local Listener = function(NewItem)
            if NotifTab.Destroyed then return end
            if NotifBadge then
                NotifBadge.Visible = true
            end
            if FloatNotifBadge then
                FloatNotifBadge.Visible = true
            end
            RefreshTabCards()
            if NotifHistoryPopover and NotifHistoryPopover.Visible then
                RefreshPopCards()
            end
        end
        table.insert(Library.NotificationListeners, Listener)

        return NotifTab
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name or ""
        CurrentTabDescription.Text = Description or ""
        CurrentTabDescription.Visible = (Description ~= nil and Description ~= "")

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end

    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer
        local TabCanvas
        local TabLeft
        local TabRight

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Canvas \\--
            TabCanvas = New("CanvasGroup", {
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                GroupTransparency = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = true,
                Parent = TabCanvas,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Canvas = TabCanvas,
            Sides = {
                TabLeft,
                TabRight,
            },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
            SubTabs = {},
            ActiveSubTab = nil,
            SubTabHolder = nil,
        }

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            local Offset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
            if Tab.SubTabHolder then
                Tab.SubTabHolder.Position = UDim2.fromOffset(2, Offset)
                Offset = Offset + 36
            end

            for _, Side in Tab.Sides do
                Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                Side.Size = UDim2.new(0.5, -3, 1, -Offset)
            end

            for _, SubTab in pairs(Tab.SubTabs) do
                if SubTab.Sides then
                    for _, Side in ipairs(SubTab.Sides) do
                        Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                        Side.Size = UDim2.new(0.5, -3, 1, -Offset)
                    end
                end
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor(TabContainer.AbsoluteSize.Y / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        local function AddTabbox(self, Info)
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if ParentObj.Type == "Groupbox" then ParentObj.Container else (Info.Side == 1 and (ParentObj.Sides and ParentObj.Sides[1] or TabLeft) or (ParentObj.Sides and ParentObj.Sides[2] or TabRight)),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    BackgroundTransparency = Library.Transparency or 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(Library.GroupboxHolders, TabboxHolder)
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},

                ParentBox = if ParentObj.Type == "Groupbox" then ParentObj else nil,
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                    Library:ApplyLucideIcon(ButtonIcon, BoxIcon)
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    Name = Name,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0.5
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 14
                    if Tabbox.PoppedOut then
                        ContentSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, ContentSize + 35)
                    if ParentObj.Type == "Groupbox" then
                        ParentObj:Resize()
                    end
                end

                function Tab:UpdateCorners()
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,

                Header = TabboxButtons,
                Children = function()
                    return { TabboxHolder }
                end,

                After = function()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if ParentObj.Type == "Groupbox" then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        local function AddGroupbox(self, Info)
            Info = Library:Validate(Info, Templates.Groupbox)

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local ParentColumn = (Info.Side == 1) and (self.Sides and self.Sides[1] or TabLeft) or (self.Sides and self.Sides[2] or TabRight)
            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = ParentColumn,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    BackgroundTransparency = Library.Transparency or 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(Library.GroupboxHolders, GroupboxHolder)
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder)

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    local GroupboxHeaderIcon = New("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                    Library:ApplyLucideIcon(GroupboxHeaderIcon, BoxIcon)
                end

                local RightInset = if Info.DisableCollapsing ~= true then 22 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 24 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 15,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = New("ImageButton", {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                })
                if ArrowIcon then
                    Library:ApplyLucideIcon(GroupboxCollapseArrow, ArrowIcon, 180)
                end

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    LayoutOrder = 2,
                    ScrollBarThickness = 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Name = Info.Name,
                Description = Info.Description,

                Type = "Groupbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,
                PopOutEnabled = Info.PopOut ~= false,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,
                Tab = Tab,

                DependencyBoxes = {},
                Elements = {},
            }

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,

                Header = GroupboxTop,
                Children = function()
                    return { GroupboxHolder }
                end,

                Before = function(PoppingOut)
                    GroupboxLine.Visible = PoppingOut
                end,

                After = function()
                    Groupbox:Resize()
                end,
            })

            function Groupbox:Resize()
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContainerSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 14
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                end

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                end
            end

            function Groupbox:SetDescription(Description: string | nil)
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,

                Header = GroupboxTop,
                Children = function()
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                GroupboxCollapseArrow.MouseButton1Click:Connect(function()
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        Tab.AddGroupbox = AddGroupbox

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return AddGroupbox(Tab, { Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return AddGroupbox(Tab, { Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        function Tab:AddSubTab(NameOrInfo, IconName)
            local SubName = "SubTab"
            local SubIcon = IconName

            if typeof(NameOrInfo) == "table" then
                SubName = NameOrInfo.Name or SubName
                SubIcon = NameOrInfo.Icon or SubIcon
            else
                SubName = tostring(NameOrInfo or SubName)
            end

            if not Tab.SubTabHolder then
                Tab.SubTabHolder = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    Position = UDim2.fromOffset(2, 0),
                    Size = UDim2.new(1, -4, 0, 32),
                    Parent = TabContainer,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 6),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Parent = Tab.SubTabHolder,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    Parent = Tab.SubTabHolder,
                })

                TabLeft.Visible = false
                TabRight.Visible = false
            end

            local SubTabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 1, 0),
                Text = "",
                Parent = Tab.SubTabHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = SubTabButton,
                })
            )
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 6),
                Parent = SubTabButton,
            })

            local SubButtonContent = New("Frame", {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 1),
                Parent = SubTabButton,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = SubButtonContent,
            })

            local SubTabIconLabel
            local ParsedSubIcon = Library:GetCustomIcon(SubIcon)
            if ParsedSubIcon then
                SubTabIconLabel = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    ImageColor3 = ParsedSubIcon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = SubButtonContent,
                })
                Library:ApplyLucideIcon(SubTabIconLabel, ParsedSubIcon)
            end

            local SubTabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 1),
                Text = SubName,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = SubButtonContent,
            })

            local SubTabActiveIndicator = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "AccentColor",
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                Parent = SubTabButton,
            })

            local SubTabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Visible = false,
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = SubTabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = SubTabLeft,
            })

            local SubTabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Visible = false,
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = SubTabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = SubTabRight,
            })

            local SubTabObj: any = {
                Name = SubName,
                Tab = Tab,
                Sides = { SubTabLeft, SubTabRight },
                Groupboxes = {},
                Tabboxes = {},
                DependencyGroupboxes = {},
                Elements = {},
                DependencyBoxes = {},
            }

            function SubTabObj:Show()
                if Tab.ActiveSubTab == SubTabObj then return end
                if Tab.ActiveSubTab and Tab.ActiveSubTab.Hide then
                    Tab.ActiveSubTab:Hide()
                end

                SubTabLeft.Visible = true
                SubTabRight.Visible = true

                TweenService:Create(SubTabButton, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
                TweenService:Create(SubTabLabel, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
                if SubTabIconLabel then
                    TweenService:Create(SubTabIconLabel, Library.TweenInfo, {
                        ImageTransparency = 0,
                    }):Play()
                end
                SubTabActiveIndicator.Visible = true

                Tab.ActiveSubTab = SubTabObj
                Tab:RefreshSides()
            end

            function SubTabObj:Hide()
                SubTabLeft.Visible = false
                SubTabRight.Visible = false

                TweenService:Create(SubTabButton, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(SubTabLabel, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()
                if SubTabIconLabel then
                    TweenService:Create(SubTabIconLabel, Library.TweenInfo, {
                        ImageTransparency = 0.5,
                    }):Play()
                end
                SubTabActiveIndicator.Visible = false

                if Tab.ActiveSubTab == SubTabObj then
                    Tab.ActiveSubTab = nil
                end
            end

            function SubTabObj:Hover(Hovering)
                if Tab.ActiveSubTab == SubTabObj then return end
                TweenService:Create(SubTabLabel, Library.TweenInfo, {
                    TextTransparency = Hovering and 0.25 or 0.5,
                }):Play()
                if SubTabIconLabel then
                    TweenService:Create(SubTabIconLabel, Library.TweenInfo, {
                        ImageTransparency = Hovering and 0.25 or 0.5,
                    }):Play()
                end
            end

            function SubTabObj:Resize()
                for _, Groupbox in SubTabObj.Groupboxes do
                    if Groupbox.Resize then
                        Groupbox:Resize()
                    end
                end
                for _, Tabbox in SubTabObj.Tabboxes do
                    if Tabbox.Resize then
                        Tabbox:Resize()
                    end
                end
            end

            SubTabButton.MouseEnter:Connect(function()
                SubTabObj:Hover(true)
            end)
            SubTabButton.MouseLeave:Connect(function()
                SubTabObj:Hover(false)
            end)
            SubTabButton.MouseButton1Click:Connect(function()
                SubTabObj:Show()
            end)

            SubTabObj.AddGroupbox = function(selfObj, Info)
                return AddGroupbox(selfObj, Info)
            end
            SubTabObj.AddLeftGroupbox = function(selfObj, Name, Icon, Visible, Collapsed, DisableCollapsing)
                return AddGroupbox(selfObj, { Side = 1, Name = Name, IconName = Icon, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
            end
            SubTabObj.AddRightGroupbox = function(selfObj, Name, Icon, Visible, Collapsed, DisableCollapsing)
                return AddGroupbox(selfObj, { Side = 2, Name = Name, IconName = Icon, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
            end
            SubTabObj.AddTabbox = function(selfObj, Info)
                return AddTabbox(selfObj, Info)
            end
            SubTabObj.AddLeftTabbox = function(selfObj, Name)
                return AddTabbox(selfObj, { Side = 1, Name = Name })
            end
            SubTabObj.AddRightTabbox = function(selfObj, Name)
                return AddTabbox(selfObj, { Side = 2, Name = Name })
            end

            setmetatable(SubTabObj, BaseGroupbox)

            Tab.SubTabs[SubName] = SubTabObj

            if not Tab.ActiveSubTab then
                SubTabObj:Show()
            end

            Tab:RefreshSides()

            return SubTabObj
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            Window:ShowTabInfo(Name, Description or "")

            Library:PlayTabAnimation(TabCanvas, true)
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(TabCanvas, false)
            Window:HideTabInfo()

            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            if Tab.SubTabs then
                for _, SubTab in pairs(Tab.SubTabs) do
                    if SubTab.Destroy then
                        SubTab:Destroy()
                    end
                end
                table.clear(Tab.SubTabs)
            end

            if Tab.SubTabHolder then
                Tab.SubTabHolder:Destroy()
            end

            if TabCanvas then
                TabCanvas:Destroy()
            elseif TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabCanvas
        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Canvas \\--
            TabCanvas = New("CanvasGroup", {
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                GroupTransparency = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = true,
                Parent = TabCanvas,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Elements = {},

            Window = Window,
            Canvas = TabCanvas
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            if TabCanvas then
                TabCanvas:Destroy()
            elseif TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            Library:PlayTabAnimation(TabCanvas, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(TabCanvas, false)
            Window:HideTabInfo()

            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                local IconImg = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
                Library:ApplyLucideIcon(IconImg, ParsedIcon)
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            local MaxWidth = MainFrame.AbsoluteSize.X * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    local GuiProperties = { "BackgroundTransparency" }
    local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
    local TextProperties = { "BackgroundTransparency", "TextTransparency" }
    local StrokeProperties = { "Transparency" }

    local function FadeInstance(Desc, Properties)
        local Cache = TransparencyCache[Desc]
        if not Cache then
            Cache = {}
            TransparencyCache[Desc] = Cache
        end

        for _, Prop in Properties do
            if not Library.Toggled then
                Cache[Prop] = Desc[Prop]
            end

            if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                TweenService:Create(Desc, Library.WindowAnimationInfo, {
                    [Prop] = Library.Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end
    end

    function Window:Toggle(Value: boolean?)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if WindowInfo.Minimizable ~= false then
            local ShouldBeOpen
            if typeof(Value) == "boolean" then
                ShouldBeOpen = Value
            else
                ShouldBeOpen = IsMinimized or (not MainFrame.Visible)
            end

            if ShouldBeOpen then
                SetMinimizedState(false)
            else
                SetMinimizedState(true)
            end
        else
            if typeof(Value) == "boolean" then
                Library.Toggled = Value
            else
                Library.Toggled = not Library.Toggled
            end
            MainFrame.Visible = Library.Toggled

            if WindowInfo.UnlockMouseWhileOpen then
                ModalElement.Modal = Library.Toggled
            end

            if Library.Toggled then
                EnableMouseIcon()
            else
                RestoreMouseIcon()
                TooltipLabel.Visible = false

                if Library.DropdownModalInstance then
                    Library.DropdownModalInstance:Destroy()
                    Library.DropdownModalInstance = nil
                end

                for _, Option in Library.Options do
                    if Option.Type == "ColorPicker" then
                        Option.ColorMenu:Close()
                        Option.ContextMenu:Close()
                    elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                        Option.Menu:Close()
                    end
                end
            end
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end, true, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    Window.MainFrame = MainFrame
    Library.Window = Window

    if WindowInfo.AutoShow ~= false and not Library.ActiveLoading then
        Window:Toggle(true)
    end

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        task.defer(function()
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
        if Icon then
            Library:ApplyLucideIcon(_WindowIcon, Icon)
        end
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        TitleHolder.AbsoluteSize.X - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })
    if LoaderIcon then
        Library:ApplyLucideIcon(LoadingIcon, LoaderIcon)
    end

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(LoadingIcon, IconData)
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    Library.Unloaded = true
    RestoreMouseIcon()

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(TransparencyCache)
    table.clear(ActiveTabTweens)

    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil

    getgenv().Library = nil
end

getgenv().Library = Library
return Library