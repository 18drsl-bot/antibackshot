
--// ANTI-BACKSHOT GUI
--// Save Settings Edition | Client Side

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local env = (getgenv and getgenv()) or _G

if env.AntiBackshotUnload then
    pcall(env.AntiBackshotUnload)
end

local FILE = "AntiBackshot_Settings.json"

local Config = {
    Enabled = false,
    ShowBox = true,
    BoxSize = 12,
    BoxHeight = 7,
    PushSpeed = 65,
    Cooldown = 0.4,
    ToggleKey = Enum.KeyCode.K
}

--// Load saved settings
local function LoadSettings()
    local data

    if type(isfile) == "function"
        and type(readfile) == "function"
        and isfile(FILE) then

        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(FILE))
        end)

        if success and type(result) == "table" then
            data = result
        end
    elseif type(env.AntiBackshotSettings) == "table" then
        data = env.AntiBackshotSettings
    end

    if not data then return end

    for key, default in pairs(Config) do
        if type(data[key]) == type(default) then
            if key == "BoxSize" then
                Config[key] = math.clamp(data[key], 4, 30)
            elseif key == "PushSpeed" then
                Config[key] = math.clamp(data[key], 10, 150)
            elseif key ~= "ToggleKey" then
                Config[key] = data[key]
            end
        end
    end
end

LoadSettings()

local function SaveSettings()
    local data = {
        Enabled = Config.Enabled,
        ShowBox = Config.ShowBox,
        BoxSize = Config.BoxSize,
        BoxHeight = Config.BoxHeight,
        PushSpeed = Config.PushSpeed,
        Cooldown = Config.Cooldown
    }

    env.AntiBackshotSettings = data

    if type(writefile) == "function" then
        local success = pcall(function()
            writefile(FILE, HttpService:JSONEncode(data))
        end)

        return success
    end

    return false
end

local Running = true
local Root
local Connections = {}
local LastPush = 0
local LastScan = 0

local function Connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function New(className, properties, parent)
    local object = Instance.new(className)

    for key, value in pairs(properties) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    New("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, parent)
end

local BG = Color3.fromRGB(17, 18, 24)
local PANEL = Color3.fromRGB(28, 30, 39)
local RED = Color3.fromRGB(255, 55, 75)
local WHITE = Color3.fromRGB(245, 245, 250)
local MUTED = Color3.fromRGB(155, 158, 171)

--// Red protection box
local Box = New("Part", {
    Name = "AntiBackshotProtectionBox",
    Size = Vector3.new(
        Config.BoxSize,
        Config.BoxHeight,
        Config.BoxSize
    ),
    Anchored = true,
    CanCollide = false,
    CanTouch = false,
    CanQuery = false,
    CastShadow = false,
    Transparency = Config.ShowBox and 0.85 or 1,
    Color = RED,
    Material = Enum.Material.Neon
}, workspace)

local Outline = New("SelectionBox", {
    Adornee = Box,
    Color3 = RED,
    SurfaceTransparency = 1,
    LineThickness = 0.055,
    Visible = Config.ShowBox
}, Box)

local function UpdateBox()
    Box.Size = Vector3.new(
        Config.BoxSize,
        Config.BoxHeight,
        Config.BoxSize
    )

    Box.Transparency = Config.ShowBox and 0.85 or 1
    Outline.Visible = Config.ShowBox
end

--// GUI
local GUI = New("ScreenGui", {
    Name = "AntiBackshotGUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(320, 420),
    Position = UDim2.new(0.5, -160, 0.5, -210),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, GUI)
Corner(Main, 14)

New("UIStroke", {
    Color = Color3.fromRGB(90, 92, 105),
    Transparency = 0.35
}, Main)

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundTransparency = 1
}, Main)

New("TextLabel", {
    Size = UDim2.new(1, -100, 0, 26),
    Position = UDim2.fromOffset(18, 8),
    BackgroundTransparency = 1,
    Text = "ANTI-BACKSHOT",
    TextColor3 = WHITE,
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

New("TextLabel", {
    Size = UDim2.new(1, -100, 0, 16),
    Position = UDim2.fromOffset(18, 32),
    BackgroundTransparency = 1,
    Text = "Personal Space Protection",
    TextColor3 = MUTED,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local function HeaderButton(text, offset, color)
    local button = New("TextButton", {
        Size = UDim2.fromOffset(30, 28),
        Position = UDim2.new(1, offset, 0, 13),
        BackgroundColor3 = PANEL,
        Text = text,
        TextColor3 = color,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    }, Header)

    Corner(button, 7)
    return button
end

local Minimize = HeaderButton("−", -74, WHITE)
local Close = HeaderButton("×", -38, RED)

New("Frame", {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.fromOffset(16, 56),
    BackgroundColor3 = Color3.fromRGB(55, 57, 69),
    BorderSizePixel = 0
}, Main)

local Content = New("Frame", {
    Size = UDim2.new(1, -32, 1, -74),
    Position = UDim2.fromOffset(16, 65),
    BackgroundTransparency = 1
}, Main)

New("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Content)

--// Toggle creator
local function MakeToggle(name, order, initial, callback)
    local Row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = PANEL,
        LayoutOrder = order,
        BorderSizePixel = 0
    }, Content)
    Corner(Row, 9)

    New("TextLabel", {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Row)

    local Button = New("TextButton", {
        Size = UDim2.fromOffset(65, 28),
        Position = UDim2.new(1, -76, 0.5, -14),
        BackgroundColor3 = PANEL,
        Text = "",
        BorderSizePixel = 0
    }, Row)
    Corner(Button, 14)

    local Knob = New("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.fromOffset(4, 4),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0
    }, Button)
    Corner(Knob, 10)

    local enabled = initial

    local function Render()
        TweenService:Create(
            Button,
            TweenInfo.new(0.16),
            {
                BackgroundColor3 = enabled and RED
                    or Color3.fromRGB(64, 65, 77)
            }
        ):Play()

        TweenService:Create(
            Knob,
            TweenInfo.new(0.16),
            {
                Position = enabled
                    and UDim2.fromOffset(41, 4)
                    or UDim2.fromOffset(4, 4)
            }
        ):Play()
    end

    Connect(Button.MouseButton1Click, function()
        enabled = not enabled
        Render()
        callback(enabled)
    end)

    Render()

    return function(value)
        enabled = value
        Render()
        callback(enabled)
    end
end

--// Slider creator
local function MakeSlider(
    name, order, minValue, maxValue, default, callback
)
    local Row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = PANEL,
        LayoutOrder = order,
        BorderSizePixel = 0
    }, Content)
    Corner(Row, 9)

    New("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -90, 0, 18),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Row)

    local Value = New("TextLabel", {
        Position = UDim2.new(1, -73, 0, 8),
        Size = UDim2.fromOffset(60, 18),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = RED,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right
    }, Row)

    local Track = New("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.fromOffset(14, 43),
        BackgroundColor3 = Color3.fromRGB(60, 62, 75),
        BorderSizePixel = 0
    }, Row)
    Corner(Track, 3)

    local fraction = (default - minValue) / (maxValue - minValue)

    local Fill = New("Frame", {
        Size = UDim2.fromScale(fraction, 1),
        BackgroundColor3 = RED,
        BorderSizePixel = 0
    }, Track)
    Corner(Fill, 3)

    local Knob = New("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(fraction, 0.5),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0
    }, Track)
    Corner(Knob, 7)

    local dragging = false

    local function Update(x)
        local percent = math.clamp(
            (x - Track.AbsolutePosition.X)
            / math.max(Track.AbsoluteSize.X, 1),
            0, 1
        )

        local amount = math.floor(
            minValue + (maxValue - minValue) * percent + 0.5
        )

        Value.Text = tostring(amount)
        Fill.Size = UDim2.fromScale(percent, 1)
        Knob.Position = UDim2.fromScale(percent, 0.5)

        callback(amount)
    end

    local Hitbox = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0.5, -12),
        BackgroundTransparency = 1,
        Text = ""
    }, Track)

    Connect(Hitbox.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input.Position.X)
        end
    end)

    Connect(UIS.InputChanged, function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            Update(input.Position.X)
        end
    end)

    Connect(UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local SetEnabled = MakeToggle(
    "Anti-Backshot",
    1,
    Config.Enabled,
    function(value)
        Config.Enabled = value
    end
)

MakeToggle(
    "Show Red Box",
    2,
    Config.ShowBox,
    function(value)
        Config.ShowBox = value
        UpdateBox()
    end
)

MakeSlider(
    "Protection Range",
    3,
    4, 30, Config.BoxSize,
    function(value)
        Config.BoxSize = value
        UpdateBox()
    end
)

MakeSlider(
    "Push Strength",
    4,
    10, 150, Config.PushSpeed,
    function(value)
        Config.PushSpeed = value
    end
)

--// SAVE SETTINGS BUTTON
local SaveButton = New("TextButton", {
    Name = "SaveSettings",
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = RED,
    BorderSizePixel = 0,
    Text = "SAVE SETTINGS",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    LayoutOrder = 5,
    AutoButtonColor = true
}, Content)
Corner(SaveButton, 9)

local SaveVersion = 0

Connect(SaveButton.MouseButton1Click, function()
    local savedToFile = SaveSettings()

    SaveVersion = SaveVersion + 1
    local version = SaveVersion

    SaveButton.Text = savedToFile
        and "SETTINGS SAVED!"
        or "SAVED FOR THIS SESSION!"

    SaveButton.BackgroundColor3 = Color3.fromRGB(50, 185, 110)

    task.delay(1.5, function()
        if Running and version == SaveVersion then
            SaveButton.Text = "SAVE SETTINGS"
            SaveButton.BackgroundColor3 = RED
        end
    end)
end)

--// Character handling
local function SetupCharacter(character)
    Root = character:WaitForChild("HumanoidRootPart", 10)
    LastPush = 0
end

if Player.Character then
    task.spawn(SetupCharacter, Player.Character)
end

Connect(Player.CharacterAdded, SetupCharacter)

--// Player detection
local function IsInside(otherRoot)
    if not Root then return false end

    local relative = Root.CFrame:PointToObjectSpace(
        otherRoot.Position
    )

    return math.abs(relative.X) <= Config.BoxSize / 2
        and math.abs(relative.Y) <= Config.BoxHeight / 2
        and math.abs(relative.Z) <= Config.BoxSize / 2
end

--// Retreat from nearby player
local function Retreat(otherRoot)
    if not Root or not Root.Parent then return end

    local humanoid =
        Root.Parent:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local diff = Root.Position - otherRoot.Position
    local direction = Vector3.new(diff.X, 0, diff.Z)

    if direction.Magnitude < 0.01 then
        local back = -Root.CFrame.LookVector
        direction = Vector3.new(back.X, 0, back.Z)
    end

    if direction.Magnitude < 0.01 then
        direction = Vector3.new(0, 0, -1)
    end

    direction = direction.Unit

    local y = Root.AssemblyLinearVelocity.Y

    Root.AssemblyLinearVelocity = Vector3.new(
        direction.X * Config.PushSpeed,
        y,
        direction.Z * Config.PushSpeed
    )
end

--// Main protection loop
Connect(RunService.Heartbeat, function(dt)
    if not Running then return end

    if Root and Root.Parent then
        Box.CFrame = Root.CFrame
    end

    if not Config.Enabled or not Root or not Root.Parent then
        return
    end

    LastScan = LastScan + dt

    if LastScan < 0.05 then return end
    LastScan = 0

    if os.clock() - LastPush < Config.Cooldown then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local character = player.Character
            local otherRoot =
                character:FindFirstChild("HumanoidRootPart")
            local humanoid =
                character:FindFirstChildOfClass("Humanoid")

            if otherRoot and humanoid
                and humanoid.Health > 0
                and IsInside(otherRoot) then

                Retreat(otherRoot)
                LastPush = os.clock()
                break
            end
        end
    end
end)

--// Draggable GUI
local dragging = false
local dragStart
local startPosition

Connect(Header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        -- Do not drag when clicking header buttons
        local x = input.Position.X
        if x >= Main.AbsolutePosition.X + Main.AbsoluteSize.X - 85 then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

Connect(UIS.InputChanged, function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

Connect(UIS.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--// Minimize
local minimized = false

Connect(Minimize.MouseButton1Click, function()
    minimized = not minimized
    Content.Visible = not minimized

    TweenService:Create(Main, TweenInfo.new(0.2), {
        Size = minimized
            and UDim2.fromOffset(320, 58)
            or UDim2.fromOffset(320, 420)
    }):Play()

    Minimize.Text = minimized and "+" or "−"
end)

--// K keybind
Connect(UIS.InputBegan, function(input, processed)
    if processed then return end

    if input.KeyCode == Config.ToggleKey then
        SetEnabled(not Config.Enabled)
    end
end)

--// Unload
local function Unload()
    if not Running then return end

    Running = false
    Config.Enabled = false

    for _, connection in ipairs(Connections) do
        connection:Disconnect()
    end

    table.clear(Connections)

    GUI:Destroy()
    Box:Destroy()

    if env.AntiBackshotUnload == Unload then
        env.AntiBackshotUnload = nil
    end
end

env.AntiBackshotUnload = Unload

Connect(Close.MouseButton1Click, Unload)

UpdateBox()

print("[Anti-Backshot] GUI loaded!")
print("[Anti-Backshot] Saved settings loaded if available.")
