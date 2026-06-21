-- ================================================================
-- SCRIPT BY DAPSKUY
-- BLADE BALL ULTIMATE CHEAT v3.0
-- FITUR: AUTO PARRY, SPAM, DETECTION, SKIN UNLOCK
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ================================================================
-- KONFIGURASI
-- ================================================================
local Settings = {
    -- Auto Parry
    AutoParry = true,
    ParryAccuracy = 80, -- 1-100
    RandomizedAccuracy = true,
    AutoCurveDirection = true,
    CooldownProtection = true,
    
    -- Auto Spam
    AutoSpamParry = false,
    SpamKey = Enum.KeyCode.F,
    SpamNotify = true,
    AnimationFix = true,
    
    -- Semi Immortal
    SemiImmortal = false,
    
    -- Lobby Auto Parry
    LobbyAutoParry = false,
    LobbyParryAccuracy = 50,
    LobbyRandomAccuracy = true,
    
    -- Detection
    InfinityDetection = true,
    DeathSlashDetection = true,
    TimeHoleDetection = true,
    AntiPhantom = true,
    SlashesOfFury = true,
    
    -- Skin Unlock
    UnlockAllSwords = false
}

-- ================================================================
-- VARIABEL
-- ================================================================
local Ball = nil
local LastBallPos = nil
local BallSpeed = 0
local IsParrying = false
local IsSpamming = false
local IsSemiImmortal = false
local CurrentBallDir = "left"
local SpamTimer = 0
local DetectionList = {}

-- ================================================================
-- FIND BALL
-- ================================================================
local function FindBall()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Part") and (v.Name == "Ball" or v.Name == "BladeBall") then
            return v
        end
    end
    return nil
end

-- ================================================================
-- GET BALL SPEED & DIRECTION
-- ================================================================
local function GetBallSpeed()
    if Ball and LastBallPos then
        return (Ball.Position - LastBallPos).Magnitude
    end
    return 0
end

local function GetBallDirection()
    if Ball and LastBallPos then
        local dir = (Ball.Position - LastBallPos).Unit
        if dir.X > 0 then return "right" else return "left" end
    end
    return "center"
end

-- ================================================================
-- AUTO PARRY (DENGAN ACCURACY)
-- ================================================================
local function AutoParry()
    if not Settings.AutoParry or not Ball then return end
    
    local CharPos = Character.HumanoidRootPart.Position
    local distance = (Ball.Position - CharPos).Magnitude
    local speed = GetBallSpeed()
    
    -- Hitung accuracy
    local accuracy = Settings.ParryAccuracy / 100
    if Settings.RandomizedAccuracy then
        accuracy = accuracy + (math.random(-20, 20) / 100)
    end
    accuracy = math.clamp(accuracy, 0.3, 1)
    
    -- Auto curve direction
    if Settings.AutoCurveDirection then
        local dir = GetBallDirection()
        CurrentBallDir = dir
    end
    
    -- Cek cooldown
    if Settings.CooldownProtection and IsParrying then
        return
    end
    
    -- Parry logic
    if distance < 20 and speed > 8 and not IsParrying then
        local chance = math.random(1, 100)
        if chance <= (accuracy * 100) then
            IsParrying = true
            
            -- Simulasi parry
            local virtualInput = {UserInputType = Enum.UserInputType.MouseButton1}
            UserInputService.InputBegan:Fire(virtualInput, false)
            
            wait(0.08)
            IsParrying = false
        end
    end
end

-- ================================================================
-- AUTO SPAM PARRY
-- ================================================================
local function AutoSpamParry()
    if not Settings.AutoSpamParry then return end
    
    SpamTimer = SpamTimer + 1
    if SpamTimer >= 2 then
        SpamTimer = 0
        
        -- Kirim spam
        local virtualInput = {UserInputType = Enum.UserInputType.MouseButton1}
        UserInputService.InputBegan:Fire(virtualInput, false)
        
        if Settings.SpamNotify then
            print("[SPAM] Parry spam aktif!")
        end
        
        -- Animation fix
        if Settings.AnimationFix then
            -- Reset animasi karakter
            Character.Humanoid:LoadAnimation(Character.Humanoid:FindFirstChild("Animation"))
        end
    end
end

-- ================================================================
-- SEMI IMMORTAL
-- ================================================================
local function SemiImmortal()
    if not Settings.SemiImmortal then return end
    
    -- Cek health
    local humanoid = Character:FindFirstChild("Humanoid")
    if humanoid then
        if humanoid.Health < 50 then
            humanoid.Health = 100
            print("[IMMORTAL] Health restored!")
        end
    end
    
    -- Cek efek knockback
    for _, v in pairs(Character:GetChildren()) do
        if v:IsA("ForceField") or v:IsA("BodyVelocity") then
            v:Destroy()
        end
    end
end

-- ================================================================
-- DETECTION SYSTEM
-- ================================================================
local function DetectionSystem()
    -- Infinity Detection
    if Settings.InfinityDetection then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name == "Infinity" then
                v:Destroy()
                print("[DETECTION] Infinity destroyed!")
            end
        end
    end
    
    -- Death Slash Detection
    if Settings.DeathSlashDetection then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name == "DeathSlash" then
                v:Destroy()
                print("[DETECTION] Death Slash destroyed!")
            end
        end
    end
    
    -- Time Hole Detection
    if Settings.TimeHoleDetection then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name == "TimeHole" then
                v:Destroy()
                print("[DETECTION] Time Hole destroyed!")
            end
        end
    end
    
    -- Anti-Phantom
    if Settings.AntiPhantom then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name == "Phantom" then
                v:Destroy()
                print("[DETECTION] Phantom destroyed!")
            end
        end
    end
    
    -- Slashes of Fury
    if Settings.SlashesOfFury then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name == "FurySlash" then
                v:Destroy()
                print("[DETECTION] Fury Slash destroyed!")
            end
        end
    end
end

-- ================================================================
-- UNLOCK ALL SWORDS
-- ================================================================
local function UnlockAllSwords()
    if not Settings.UnlockAllSwords then return end
    
    -- Cari game data
    local DataStore = game:GetService("DataStoreService")
    local PlayerData = DataStore:GetDataStore("PlayerData")
    
    -- Unlock semua sword
    local swords = {
        "Default", "Legendary", "Mythic", "Exotic", "Ultimate",
        "Blade", "Shadow", "Light", "Dark", "Phoenix"
    }
    
    for _, sword in pairs(swords) do
        local success, result = pcall(function()
            PlayerData:UpdateAsync(LocalPlayer.UserId, function(data)
                data.Swords[sword] = true
                return data
            end)
        end)
        
        if success then
            print("[UNLOCK] " .. sword .. " unlocked!")
        end
    end
end

-- ================================================================
-- LOBBY AUTO PARRY
-- ================================================================
local function LobbyAutoParry()
    if not Settings.LobbyAutoParry then return end
    
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby then
        local accuracy = Settings.LobbyParryAccuracy / 100
        if Settings.LobbyRandomAccuracy then
            accuracy = accuracy + (math.random(-10, 10) / 100)
        end
        
        -- Auto parry di lobby
        local virtualInput = {UserInputType = Enum.UserInputType.MouseButton1}
        UserInputService.InputBegan:Fire(virtualInput, false)
        wait(0.3)
    end
end

-- ================================================================
-- UI (TAB MENU SCRIPT BY DAPSKUY)
-- ================================================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DAPSKUY_UI"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    
    -- MAIN FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -175, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    MainFrame.Parent = ScreenGui
    
    -- TITLE
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Title.Text = "⭐ SCRIPT BY DAPSKUY ⭐"
    Title.TextColor3 = Color3.fromRGB(255, 200, 0)
    Title.TextScaled = true
    Title.Font = Enum.Font.Bold
    Title.Parent = MainFrame
    
    -- SCROLLING FRAME
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    ScrollingFrame.Parent = MainFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ScrollingFrame
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 5)
    
    -- ================================================================
    -- FUNGSI BUAT TOGGLE
    -- ================================================================
    local function CreateToggle(parent, text, setting, order)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 35)
        Frame.BackgroundTransparency = 1
        Frame.LayoutOrder = order
        Frame.Parent = parent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Parent = Frame
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 50, 1, -5)
        ToggleBtn.Position = UDim2.new(0.75, 0, 0, 2.5)
        ToggleBtn.Text = "ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        ToggleBtn.BorderSizePixel = 1
        ToggleBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
        ToggleBtn.Parent = Frame
        
        ToggleBtn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            ToggleBtn.Text = Settings[setting] and "ON" or "OFF"
            ToggleBtn.TextColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            
            -- Jika unlock all swords diaktifkan
            if setting == "UnlockAllSwords" and Settings[setting] then
                UnlockAllSwords()
            end
        end)
    end
    
    -- ================================================================
    -- TAB: AUTO PARRY
    -- ================================================================
    local function CreateAutoParryTab()
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 20)
        Section.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Section.Parent = ScrollingFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = "🔰 AUTO PARRY"
        SectionLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Bold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Section
        
        local order = 1
        CreateToggle(ScrollingFrame, "Auto Parry", "AutoParry", order)
        CreateToggle(ScrollingFrame, "Randomized Accuracy", "RandomizedAccuracy", order + 1)
        CreateToggle(ScrollingFrame, "Auto Curve Direction", "AutoCurveDirection", order + 2)
        CreateToggle(ScrollingFrame, "Cooldown Protection", "CooldownProtection", order + 3)
    end
    
    -- ================================================================
    -- TAB: AUTO SPAM
    -- ================================================================
    local function CreateAutoSpamTab()
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 20)
        Section.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Section.Parent = ScrollingFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = "⚡ AUTO SPAM PARRY"
        SectionLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Bold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Section
        
        local order = 10
        CreateToggle(ScrollingFrame, "Auto Spam Parry", "AutoSpamParry", order)
        CreateToggle(ScrollingFrame, "Spam Notify", "SpamNotify", order + 1)
        CreateToggle(ScrollingFrame, "Animation Fix", "AnimationFix", order + 2)
    end
    
    -- ================================================================
    -- TAB: DETECTION
    -- ================================================================
    local function CreateDetectionTab()
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 20)
        Section.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Section.Parent = ScrollingFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = "🛡️ DETECTION"
        SectionLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Bold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Section
        
        local order = 20
        CreateToggle(ScrollingFrame, "Infinity Detection", "InfinityDetection", order)
        CreateToggle(ScrollingFrame, "Death Slash Detection", "DeathSlashDetection", order + 1)
        CreateToggle(ScrollingFrame, "Time Hole Detection", "TimeHoleDetection", order + 2)
        CreateToggle(ScrollingFrame, "Anti-Phantom", "AntiPhantom", order + 3)
        CreateToggle(ScrollingFrame, "Slashes of Fury", "SlashesOfFury", order + 4)
    end
    
    -- ================================================================
    -- TAB: SKIN
    -- ================================================================
    local function CreateSkinTab()
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 20)
        Section.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Section.Parent = ScrollingFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = "🎨 SKIN UNLOCK"
        SectionLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Bold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Section
        
        local order = 30
        CreateToggle(ScrollingFrame, "Unlock All Swords", "UnlockAllSwords", order)
    end
    
    -- ================================================================
    -- TAB: LOBBY
    -- ================================================================
    local function CreateLobbyTab()
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 20)
        Section.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Section.Parent = ScrollingFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = "🏠 LOBBY"
        SectionLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Bold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Section
        
        local order = 40
        CreateToggle(ScrollingFrame, "Lobby Auto Parry", "LobbyAutoParry", order)
        CreateToggle(ScrollingFrame, "Lobby Random Accuracy", "LobbyRandomAccuracy", order + 1)
    end
    
    -- ================================================================
    -- TAB: SEMI IMMORTAL
    -- ================================================================
    local function CreateSemiImmortalTab()
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 20)
        Section.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Section.Parent = ScrollingFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = "💀 SEMI IMMORTAL"
        SectionLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.Bold
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Parent = Section
        
        local order = 50
        CreateToggle(ScrollingFrame, "Semi Immortal", "SemiImmortal", order)
    end
    
    -- ================================================================
    -- BUILD ALL TABS
    -- ================================================================
    CreateAutoParryTab()
    CreateAutoSpamTab()
    CreateDetectionTab()
    CreateSkinTab()
    CreateLobbyTab()
    CreateSemiImmortalTab()
    
    -- DRAG UI
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
local function MainLoop()
    Ball = FindBall()
    
    if Ball then
        BallSpeed = GetBallSpeed()
        LastBallPos = Ball.Position
        
        AutoParry()
        AutoSpamParry()
        SemiImmortal()
        DetectionSystem()
        LobbyAutoParry()
    end
    
    wait(0.05)
end

-- ================================================================
-- START
-- ================================================================
CreateUI()
print("⭐ SCRIPT BY DAPSKUY ⭐")
print("✅ BLADE BALL ULTIMATE CHEAT AKTIF!")
print("📌 UI muncul di layar kanan bawah")
print("📌 Klik toggle untuk mengaktifkan/mematikan fitur")

while true do
    pcall(MainLoop)
    wait()
end