-- ══════════════════ EXECUTOR COMPATIBILITY SHIM ══════════════════
-- Medium executor doesn't expose getgenv() — polyfill it so the script loads.
if not getgenv then
    local _sharedEnv = {}
    getgenv = function() return _sharedEnv end
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

_G.AIMBOT_CFG = _G.AIMBOT_CFG or {
    Enabled = false,
    DrawFov = false,
    VisibleCheck = false,
    Humanize = false,
    HoldToAim = false,
    IgnoreDead = true,
    AimKey = Enum.UserInputType.MouseButton2,
    AimMode = "Mouse Aim",
    TargetPart = "Head",
    FOV = 150,
    MaxDist = 500,
    HitChance = 80,
    Prediction = false,
    PredictionAmount = 0.165,
    RCS = false,
    RCSAmount = 1.0,
    Keybind = nil
}

_G.KILLAURA_CFG = _G.KILLAURA_CFG or {
    Enabled = false,
    MaxDist = 300,
    Delay = 100,
    Wallbang = false,
    TeleKill = false,
    Keybind = Enum.KeyCode.None
}

_G.HITBOX_CFG = _G.HITBOX_CFG or {
    Enabled = false,
    Size = 10,
    Part = "head"
}

_G.TRIGGERBOT_CFG = _G.TRIGGERBOT_CFG or {
    Enabled = false,
    Keybind = Enum.KeyCode.T,
    Mode = "Legit"
}


_G.SILENT_CFG = _G.SILENT_CFG or {
    Enabled = false,
    Wallbang = false,
    FOV = 150,
    HitChance = 100,
    TargetPart = "Head",
    Keybind = Enum.KeyCode.None
}

_G.GUN_MODS_CFG = _G.GUN_MODS_CFG or {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    Automatic = false,
    InfiniteAmmo = false
}

_G.AM_CFG = _G.AM_CFG or {
    Enabled = false,
    Mode = "3v3"
}

_G.WORLD_CFG = _G.WORLD_CFG or {}
for k, v in pairs({
    FullBright = false,
    NoFog = false,
    Exposure = 0,
    Brightness = 1,
    FPSBooster = false,
    FOV = 70,
    FOVEnabled = false,
    Skybox = "Default",
    KillSoundEnabled = false,
    KillSoundId = "8904888220",
    KillSoundVolume = 100
}) do
    if _G.WORLD_CFG[k] == nil then
        _G.WORLD_CFG[k] = v
    end
end
_G.LOCAL_PLAYER_CFG = _G.LOCAL_PLAYER_CFG or {
    SpeedEnabled = false,
    Speed = 16,
    SpeedKey = "None",
    FlyEnabled = false,
    FlySpeed = 50,
    FlyKey = "None",
    InvisEnabled = false,
    InvisKey = "None"
}

_G.FUN_CFG = _G.FUN_CFG or {
    GravityEnabled = false,
    GravityValue = 196.2,
    InfJump = false,
    Spinbot = false,
    SpinSpeed = 50
}

_G.PREFERENCES_CFG = _G.PREFERENCES_CFG or {
    IgnoredPlayers = {}
}
-- Smooth Drag setting (initially set at top)
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

getgenv()._CEN_SLD_ACTIVE = false
getgenv()._CEN_PKR_ACTIVE = false

local CoreGui = game:GetService("CoreGui")

-- ══════════════════ GAME CONFIGURATIONS ══════════════════
local GAME_IDS = {
    MurderVsSheriff = {
        Lobbies = {
            [135856908115931] = true,
            [124848751642883] = true
        },
        Arenas = {
            [92876937625630] = true,
            [101617670515690] = true,
            [74084441161738] = true
        }
    },
    Hitmark = {
        [97351810896225] = true
    },
    BronxDuels = {
        [139943061361383] = true, -- Matchmaking
        [99362936871032] = true,  -- The Bronx: Duels 🔫
        [85788627530413] = true,  -- FFA
        [9091734830] = true,      -- main
        [121567535120062] = false -- previously found ID
    },
    Duelist = {
        [122310270867133] = true
    }
}

-- Game-specific check helpers
local function IsMurderVsSheriff()
    local pid = game.PlaceId
    return GAME_IDS.MurderVsSheriff.Lobbies[pid] or GAME_IDS.MurderVsSheriff.Arenas[pid]
end

local function IsHitmark()
    local pid = game.PlaceId
    return GAME_IDS.Hitmark[pid] ~= nil
end

local function IsBronxDuels()
    local pid = game.PlaceId
    if GAME_IDS.BronxDuels and GAME_IDS.BronxDuels[pid] then
        return true
    end
    -- Fallback: Detect by checking ReplicatedStorage unique combat structures
    local rs = game:GetService("ReplicatedStorage")
    local remotes = rs:FindFirstChild("Shared") and rs.Shared:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("KnifeKill") then
        return true
    end
    return false
end

function IsDuelist()
    local pid = game.PlaceId
    if GAME_IDS.Duelist and GAME_IDS.Duelist[pid] ~= nil then
        return true
    end
    local rs = game:GetService("ReplicatedStorage")
    if rs:FindFirstChild("SmurklesLib") and rs:FindFirstChild("Events") and rs.Events:FindFirstChild("Weapons") then
        if GAME_IDS.Duelist then
            GAME_IDS.Duelist[pid] = true
        end
        return true
    end
    return false
end

local function IsMurderVsSheriffLobby()
    return GAME_IDS.MurderVsSheriff.Lobbies[game.PlaceId]
end

local function IsMurderVsSheriffArena()
    return GAME_IDS.MurderVsSheriff.Arenas[game.PlaceId]
end

local function GetGameGroup(pid)
    for groupName, places in pairs(GAME_IDS) do
        if (places.Lobbies and places.Lobbies[pid]) or (places.Arenas and places.Arenas[pid]) then
            return groupName
        end
    end
    return tostring(pid)
end

_G.FLUX_CONNS = _G.FLUX_CONNS or {}

local function NormalizeIgnoredPlayers()
    local prefs = _G.PREFERENCES_CFG
    if type(prefs) ~= "table" then
        prefs = {}
        _G.PREFERENCES_CFG = prefs
    end

    local rawIgnored = prefs.IgnoredPlayers
    local normalized = {}
    if type(rawIgnored) == "table" then
        for key, value in pairs(rawIgnored) do
            if type(key) == "number" then
                if type(value) == "string" and value ~= "" then
                    normalized[value] = true
                end
            elseif value then
                normalized[tostring(key)] = true
            end
        end
    end

    prefs.IgnoredPlayers = normalized
    return normalized
end

local function IsIgnoredPlayer(playerOrName)
    if not playerOrName then return false end

    local playerName
    if typeof(playerOrName) == "Instance" and playerOrName:IsA("Player") then
        playerName = playerOrName.Name
    elseif type(playerOrName) == "string" then
        playerName = playerOrName
    end

    if not playerName or playerName == "" then
        return false
    end

    return NormalizeIgnoredPlayers()[playerName] == true
end

local function SetIgnoredPlayer(playerName, state)
    if not playerName or playerName == "" then return end

    local ignored = NormalizeIgnoredPlayers()
    if state then
        ignored[playerName] = true
    else
        ignored[playerName] = nil
    end
end

local function IsIgnoredCharacter(char)
    local owner = char and Players:GetPlayerFromCharacter(char)
    return owner and IsIgnoredPlayer(owner) or false
end

-- Session Control (Kills old loops)
local MySession = os.clock()
getgenv().FLUX_SESSION = MySession

local function CleanOld()
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetAttribute("ForceSpeed", nil)
        end
    end)

    -- Disconnect all tracked connections
    for _, c in pairs(_G.FLUX_CONNS) do
        pcall(function() c:Disconnect() end)
    end
    _G.FLUX_CONNS = {}

    -- Clean UI
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "FluxUI" or v.Name == "MobileToggle" or v.Name == "NotifySG" or v.Name == "ESP_HOLDER" then
            pcall(function() v:Destroy() end)
        end
    end
    for _, v in pairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
        if v.Name == "FluxUI" or v.Name == "MobileToggle" or v.Name == "NotifySG" or v.Name == "ESP_HOLDER" then
            pcall(function() v:Destroy() end)
        end
    end

    -- Stop Render Loops
    pcall(function() RunService:UnbindFromRenderStep("FluxAimbot") end)
    pcall(function() RunService:UnbindFromRenderStep("FluxESP") end)

    -- Clean ESP Cache and Drawings
    if _G.ESP_CACHE then
        for target, e in pairs(_G.ESP_CACHE) do
            pcall(function() e.FRM:Destroy() end)
            pcall(function() e.BOX:Destroy() end)
            pcall(function() e.FILL:Destroy() end)
            if e.CHAM then pcall(function() e.CHAM:Destroy() end) end
            if e.TCHAM then pcall(function() e.TCHAM:Destroy() end) end
        end
    end
    _G.ESP_CACHE = {}
    pcall(function() if _G.ESP_LOOP then _G.ESP_LOOP:Disconnect() end end)
    pcall(function() if FOV_CIRCLE then FOV_CIRCLE:Destroy() end end)
end
CleanOld()

-- Input Tracking with Connection Management
local isRmbDown = false
table.insert(_G.FLUX_CONNS, UIS.InputBegan:Connect(function(input)
    if getgenv().FLUX_SESSION ~= MySession then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRmbDown = true
    end
end))
table.insert(_G.FLUX_CONNS, UIS.InputEnded:Connect(function(input)
    if getgenv().FLUX_SESSION ~= MySession then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRmbDown = false
    end
end))

-- Cleanup old ESP
if _G.ESP_LOOP then
    _G.ESP_LOOP:Disconnect(); _G.ESP_LOOP = nil
end
pcall(function() RunService:UnbindFromRenderStep("FluxESP") end)
if _G.ESP_CACHE then
    for _, e in pairs(_G.ESP_CACHE) do
        pcall(function() e.FRM:Destroy() end)
        if e.CHAM then pcall(function() e.CHAM:Destroy() end) end
        if e.TCHAM then pcall(function() e.TCHAM:Destroy() end) end
    end
    _G.ESP_CACHE = nil
end

local toggleKey = Enum.KeyCode.RightShift
local uiConfigPath = "UI_Config.json"
local useSmoothDrag = true
local useNotifications = false
local useWatermark = false
local useKbHud = false

_G.CUSTOM_BG_ENABLED = false
_G.CUSTOM_BG_ID = ""
_G.CUSTOM_BG_TRANSPARENCY = 0

local SidebarBgImage
local RightBoxBgImage
local UpdateCustomBackground
local UpdatePreview
local blurActive = false
local blurVal = 0

-- UI Root References for cross-scope access
local Watermark
local NotifySG
local KbWin
local KbSG


local uiVis = true
local FOV_CIRCLE, silentFovCircle

-- Performance Caches
_G.MY_TEAM_CACHE = nil
_G.ACTIVE_MATCH_PLAYERS = {}
task.spawn(function()
    while task.wait(1.5) do
        if getgenv().FLUX_SESSION ~= MySession then break end
        local matchPlayers = {}
        local found = false

        -- 1. Check Bronx Duels enemies folder
        local enemiesFolder = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Match") and
            LP.Data.Match:FindFirstChild("Enemies")
        if enemiesFolder and #enemiesFolder:GetChildren() > 0 then
            for _, child in pairs(enemiesFolder:GetChildren()) do
                matchPlayers[child.Name] = true
            end
            matchPlayers[LP.Name] = true
            _G.MY_TEAM_CACHE = nil
            found = true
        end

        -- 2. Check Player Attributes (MurderVsSheriff & New Updates)
        if not found then
            local myGame = LP:GetAttribute("Game")
            if myGame and myGame ~= "nothing" and myGame ~= "" and myGame ~= "Lobby" then
                for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                    if p:GetAttribute("Game") == myGame then
                        matchPlayers[p.Name] = true
                    end
                end

                -- Mock MY_TEAM_CACHE to check attributes on the fly
                local myTeam = LP:GetAttribute("Team")
                _G.MY_TEAM_CACHE = {
                    FindFirstChild = function(self, name)
                        local p = game:GetService("Players"):FindFirstChild(name)
                        if p and p:GetAttribute("Team") == myTeam then
                            return true
                        end
                        return nil
                    end
                }
                found = true
            end
        end

        -- 3. Legacy RunningGames folder check
        if not found then
            local runningGames = workspace:FindFirstChild("RunningGames")
            if runningGames then
                for _, gameFolder in pairs(runningGames:GetChildren()) do
                    local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
                    if alivePlayers then
                        local inThisGame = false
                        for _, teamFolder in pairs(alivePlayers:GetChildren()) do
                            if teamFolder:FindFirstChild(LP.Name) then
                                _G.MY_TEAM_CACHE = teamFolder
                                inThisGame = true
                            end
                        end
                        if inThisGame then
                            for _, teamFolder in pairs(alivePlayers:GetChildren()) do
                                for _, pFolder in pairs(teamFolder:GetChildren()) do
                                    matchPlayers[pFolder.Name] = true
                                end
                            end
                            found = true
                            break
                        end
                    end
                end
            end
        end
        _G.ACTIVE_MATCH_PLAYERS = matchPlayers
        if not found then
            _G.MY_TEAM_CACHE = nil
        end
    end
end)

local function SaveUI()
    local data = {
        key = toggleKey.Name,
        smooth = useSmoothDrag,
        bgEnabled = _G.CUSTOM_BG_ENABLED,
        bgId = _G.CUSTOM_BG_ID,
        bgTrans = _G.CUSTOM_BG_TRANSPARENCY,
        blurActive = blurActive,
        blurVal = blurVal,
        ignoredPlayers = NormalizeIgnoredPlayers(),
        KillSoundEnabled = _G.WORLD_CFG.KillSoundEnabled,
        KillSoundId = _G.WORLD_CFG.KillSoundId,
        KillSoundVolume = _G.WORLD_CFG.KillSoundVolume
    }
    if writefile then writefile(uiConfigPath, game:GetService("HttpService"):JSONEncode(data)) end
end

local function LoadUI()
    if isfile and isfile(uiConfigPath) then
        local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(uiConfigPath)) end)
        if ok and data then
            if data.key then toggleKey = Enum.KeyCode[data.key] or toggleKey end
            if data.smooth ~= nil then useSmoothDrag = data.smooth end
            if data.bgEnabled ~= nil then _G.CUSTOM_BG_ENABLED = data.bgEnabled end
            if data.bgId ~= nil then _G.CUSTOM_BG_ID = data.bgId end
            if data.bgTrans ~= nil then _G.CUSTOM_BG_TRANSPARENCY = data.bgTrans end
            if data.blurActive ~= nil then blurActive = data.blurActive end
            if data.blurVal ~= nil then blurVal = data.blurVal end
            if data.ignoredPlayers ~= nil then
                _G.PREFERENCES_CFG.IgnoredPlayers = data.ignoredPlayers
            end
            if data.KillSoundEnabled ~= nil then _G.WORLD_CFG.KillSoundEnabled = data.KillSoundEnabled end
            if data.KillSoundId ~= nil then _G.WORLD_CFG.KillSoundId = tostring(data.KillSoundId) end
            if data.KillSoundVolume ~= nil then _G.WORLD_CFG.KillSoundVolume = data.KillSoundVolume end
            NormalizeIgnoredPlayers()
        end
    end
end

local function ApplyUIPreferences()
    if Watermark then Watermark.Visible = useWatermark end
    if _G.FLUX_KB_HUD_SYNC then _G.FLUX_KB_HUD_SYNC() end
    if UpdatePreview then UpdatePreview() end
    if UpdateCustomBackground then UpdateCustomBackground() end
end

LoadUI()


local function Tw(obj, t, es, ed, goals)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t, Enum.EasingStyle[es or "Quad"], Enum.EasingDirection[ed or "Out"]), goals)
    tween:Play()
    return tween
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(60, 60, 72)
    s.Thickness = th or 1
    if p:IsA("TextButton") then
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end
    s.Parent = p
    return s
end

local function NewFrame(parent, size, pos, color, trans)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or Color3.fromRGB(26, 26, 32)
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function NewLabel(parent, txt, sz, col, bold, xa, ya)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.TextColor3 = col or Color3.fromRGB(210, 212, 220)
    l.TextSize = sz or 13
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.Text = txt or ""
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextYAlignment = ya or Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function NewBtn(parent, size, pos, color, trans)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3 = color or Color3.fromRGB(36, 36, 46)
    b.BackgroundTransparency = (trans == 1) and 0.99 or (trans or 0)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = ""
    b.Parent = parent
    return b
end

local function NewScroll(parent, size, pos, color, trans)
    local f = Instance.new("ScrollingFrame")
    f.Size = size or UDim2.new(1, 0, 1, 0)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or Color3.fromRGB(20, 20, 26)
    f.BackgroundTransparency = trans or 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 0
    f.ScrollBarImageColor3 = Color3.fromRGB(238, 240, 255)
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Parent = parent
    return f
end

local function MakeDraggable(area, target)
    target = target or area
    local dragStart, startPos
    local dragging = false

    area.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            task.wait() -- Small wait to let slider flags set
            if getgenv()._CEN_SLD_ACTIVE or getgenv()._CEN_PKR_ACTIVE then return end

            dragging = true
            dragStart = input.Position
            startPos = target.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if getgenv()._CEN_SLD_ACTIVE or getgenv()._CEN_PKR_ACTIVE then
                dragging = false
                return
            end
            local delta = input.Position - dragStart
            local ease = useSmoothDrag and 0.15 or 0
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
            if ease > 0 then
                Tw(target, ease, "Quad", "Out", { Position = targetPos })
            else
                target.Position = targetPos
            end
        end
    end)
end

local BG              = Color3.fromRGB(20, 20, 26)
local SIDEBAR         = Color3.fromRGB(15, 15, 20)
local PANEL           = Color3.fromRGB(26, 26, 34)
local STROKE          = Color3.fromRGB(50, 50, 62)
local STROKE2         = Color3.fromRGB(65, 65, 80)
local TEXT            = Color3.fromRGB(208, 210, 220)
local DIM             = Color3.fromRGB(110, 112, 130)
local ACCENT          = Color3.fromRGB(238, 240, 255)
local SLBG            = Color3.fromRGB(42, 42, 54)
local SLFILL          = Color3.fromRGB(200, 204, 238)

-- Global Picker State
local PICKER_OPEN     = false
local PICKER_CALLBACK = nil
local PICKER_GUI      = nil
local PICKER_MAIN     = nil

-- State Variables
-- UI state variables (initially set at top)
local IS_MOBILE       = UIS.TouchEnabled
local curW            = IS_MOBILE and 600 or 900
local curH            = IS_MOBILE and 350 or 530
local SIDE_W          = IS_MOBILE and 160 or 220
local GAP             = 8

local SG              = Instance.new("ScreenGui")
SG.Name               = "FluxUI"
SG.ResetOnSpawn       = false
SG.DisplayOrder       = 2147483647
SG.IgnoreGuiInset     = true
SG.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = PG end

function AddDropdown(parent, options, default, callback)
    local frame = NewFrame(parent, UDim2.new(1, -16, 0, 32), nil, Color3.fromRGB(32, 32, 44))
    Corner(frame, 6)
    Stroke(frame, STROKE2, 1)

    local function setAncestorsZIndex(val)
        local curr = frame
        while curr do
            if curr:IsA("GuiObject") then
                curr.ZIndex = val
            end
            if curr.Parent and (curr.Parent:IsA("ScrollingFrame") or curr.Parent.Name == "RightBox" or curr.Parent.Name == "Root" or curr.Parent.Name == "FluxUI") then
                break
            end
            curr = curr.Parent
        end
    end

    local selLbl = NewLabel(frame, default, 11, TEXT)
    selLbl.Position = UDim2.new(0, 10, 0, 0)
    selLbl.Size = UDim2.new(1, -30, 1, 0)

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.Position = UDim2.new(1, -22, 0.5, -6)
    arrow.Image = "rbxassetid://6034818372"
    arrow.ImageColor3 = DIM
    arrow.Parent = frame

    local open = false

    local popup = Instance.new("ScrollingFrame")
    popup.Name = "Popup"
    popup.Parent = frame
    popup.Size = UDim2.new(1, 0, 0, 0)
    popup.Position = UDim2.new(0, 0, 1, 4)
    popup.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    popup.BorderSizePixel = 0
    popup.ZIndex = 500
    popup.Visible = false
    popup.ClipsDescendants = true
    popup.ScrollBarThickness = 4
    popup.ScrollBarImageColor3 = ACCENT
    popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popup.CanvasSize = UDim2.new(0, 0, 0, 0)
    Corner(popup, 6)
    Stroke(popup, STROKE2, 1)

    local list = Instance.new("UIListLayout", popup)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local function close()
        open = false
        Tw(popup, 0.15, "Quad", "Out", { Size = UDim2.new(1, 0, 0, 0) })
        task.delay(0.16, function()
            popup.Visible = false
            setAncestorsZIndex(1)
        end)
        Tw(arrow, 0.15, "Quad", "Out", { Rotation = 0 })
    end

    for i, opt in ipairs(options) do
        local ob = NewBtn(popup, UDim2.new(1, 0, 0, 26), nil, Color3.fromRGB(45, 45, 60), 1)
        ob.LayoutOrder = i
        ob.ZIndex = 501
        local ol = NewLabel(ob, opt, 11, TEXT)
        ol.Position = UDim2.new(0, 10, 0, 0)
        ol.Size = UDim2.new(1, -10, 1, 0)
        ol.ZIndex = 502

        ob.MouseEnter:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 0.5 }) end)
        ob.MouseLeave:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)

        ob.MouseButton1Click:Connect(function()
            selLbl.Text = opt
            callback(opt)
            close()
        end)
    end

    local btn = NewBtn(frame, UDim2.new(1, 0, 1, 0), nil, BG, 1)
    btn.ZIndex = 10
    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            setAncestorsZIndex(50)
            popup.Visible = true
            local targetHeight = math.min(#options * 26, 150)
            Tw(popup, 0.18, "Quad", "Out", { Size = UDim2.new(1, 0, 0, targetHeight) })
            Tw(arrow, 0.18, "Quad", "Out", { Rotation = 180 })
        else
            close()
        end
    end)

    -- Close on click outside
    UIS.InputBegan:Connect(function(inp, gp)
        if not open or gp then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            task.wait()
            local mx, my = inp.Position.X, inp.Position.Y
            local function hit(f)
                return mx >= f.AbsolutePosition.X and mx <= f.AbsolutePosition.X + f.AbsoluteSize.X
                    and my >= f.AbsolutePosition.Y and my <= f.AbsolutePosition.Y + f.AbsoluteSize.Y
            end
            if not hit(frame) and not hit(popup) then close() end
        end
    end)

    return frame
end

Root                 = NewFrame(SG,
    UDim2.new(0, curW, 0, curH),
    UDim2.new(0.5, -curW / 2, 0.5, -curH / 2),
    Color3.fromRGB(0, 0, 0), 1
)
Root.BorderSizePixel = 0
Corner(Root, 10)
MakeDraggable(Root) -- Re-enabled global drag with smart filtering

local SnowHolder                  = Instance.new("Frame")
SnowHolder.Name                   = "SnowHolder"
SnowHolder.Size                   = UDim2.new(1, 0, 1, 0)
SnowHolder.BackgroundTransparency = 1
SnowHolder.ZIndex                 = 10
SnowHolder.Parent                 = Root

local Sidebar                     = NewFrame(Root,
    UDim2.new(0, SIDE_W, 1, 0),
    UDim2.new(0, 0, 0, 0),
    SIDEBAR
)
Corner(Sidebar, 10)
-- MakeDraggable(Sidebar, Root) -- Redundant now
Stroke(Sidebar, STROKE2, 1.2)
local sideGrad = Instance.new("UIGradient")
sideGrad.Rotation = 90
sideGrad.Color = ColorSequence.new(Color3.fromRGB(15, 15, 20), Color3.fromRGB(15, 15, 20))
sideGrad.Enabled = false
sideGrad.Parent = Sidebar

local RightBox = NewFrame(Root,
    UDim2.new(1, -(SIDE_W + GAP), 1, 0),
    UDim2.new(0, SIDE_W + GAP, 0, 0),
    BG
)
RightBox.Name = "RightBox"
Corner(RightBox, 10)
Stroke(RightBox, STROKE2, 1.2)
RightBox.ClipsDescendants = true

SidebarBgImage = Instance.new("ImageLabel")
SidebarBgImage.Name = "CustomBackground"
SidebarBgImage.Size = UDim2.new(1, 0, 1, 0)
SidebarBgImage.Position = UDim2.new(0, 0, 0, 0)
SidebarBgImage.BackgroundTransparency = 1
SidebarBgImage.ScaleType = Enum.ScaleType.Crop
SidebarBgImage.ZIndex = 0
SidebarBgImage.Visible = false
Corner(SidebarBgImage, 10)
SidebarBgImage.Parent = Sidebar

RightBoxBgImage = Instance.new("ImageLabel")
RightBoxBgImage.Name = "CustomBackground"
RightBoxBgImage.Size = UDim2.new(1, 0, 1, 0)
RightBoxBgImage.Position = UDim2.new(0, 0, 0, 0)
RightBoxBgImage.BackgroundTransparency = 1
RightBoxBgImage.ScaleType = Enum.ScaleType.Crop
RightBoxBgImage.ZIndex = 0
RightBoxBgImage.Visible = false
Corner(RightBoxBgImage, 10)
RightBoxBgImage.Parent = RightBox

local rightGrad = Instance.new("UIGradient")
rightGrad.Rotation = 90
rightGrad.Parent = RightBox

-- ══════════════════ MOBILE HIDE BUTTON ══════════════════
if IS_MOBILE then
    local MobileBtn = Instance.new("ScreenGui")
    MobileBtn.Name = "MobileToggle"
    MobileBtn.DisplayOrder = 2147483646
    pcall(function() MobileBtn.Parent = game:GetService("CoreGui") end)
    if not MobileBtn.Parent then MobileBtn.Parent = PG end

    local Toggle = NewBtn(MobileBtn, UDim2.new(0, 80, 0, 32), UDim2.new(0.5, -40, 0, 10), Color3.fromRGB(24, 24, 30))
    Corner(Toggle, 8)
    Stroke(Toggle, STROKE2, 1)

    local Txt = NewLabel(Toggle, "HIDE UI", 11, ACCENT, true, Enum.TextXAlignment.Center)
    Txt.Size = UDim2.new(1, 0, 1, 0)

    Toggle.MouseButton1Click:Connect(function()
        Root.Visible = not Root.Visible
        Txt.Text = Root.Visible and "HIDE UI" or "SHOW UI"
        if not Root.Visible and PICKER_MAIN then
            PICKER_MAIN.Visible = false
            PICKER_OPEN = false
        end
    end)
    MakeDraggable(Toggle) -- Allow moving the toggle button
end

-- ══════════════════ NOTIFICATION SYSTEM ══════════════════
local NotifySG = Instance.new("ScreenGui")
NotifySG.Name = "FluxNotify"
NotifySG.ResetOnSpawn = false
NotifySG.DisplayOrder = 2147483647
pcall(function() NotifySG.Parent = game:GetService("CoreGui") end)
if not NotifySG.Parent then NotifySG.Parent = PG end

local NotifyHolder = Instance.new("Frame")
NotifyHolder.Size = UDim2.new(0, 250, 1, -20)
NotifyHolder.Position = UDim2.new(1, -260, 0, 40)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Parent = NotifySG

local NotifyList = Instance.new("UIListLayout")
NotifyList.VerticalAlignment = Enum.VerticalAlignment.Top
NotifyList.Padding = UDim.new(0, 8)
NotifyList.Parent = NotifyHolder

local activeNotifs = {}

local function NOTIFY(title, msg, dur)
    if not useNotifications and title ~= "System" then return end
    dur = dur or 3

    local n = NewFrame(NotifyHolder, UDim2.new(1, 0, 0, 65), nil, Color3.fromRGB(24, 24, 30))
    n.ClipsDescendants = true
    Corner(n, 8)
    Stroke(n, STROKE2, 1)

    local tLbl = NewLabel(n, title, 13, ACCENT, true)
    tLbl.Position = UDim2.new(0, 12, 0, 8)
    tLbl.Size = UDim2.new(1, -24, 0, 18)

    local mLbl = NewLabel(n, msg, 11, TEXT)
    mLbl.Position = UDim2.new(0, 12, 0, 26)
    mLbl.Size = UDim2.new(1, -24, 0, 18)
    mLbl.TextWrapped = true

    local barBG = NewFrame(n, UDim2.new(1, -24, 0, 3), UDim2.new(0, 12, 1, -10), Color3.fromRGB(40, 40, 50))
    Corner(barBG, 2)
    local bar = NewFrame(barBG, UDim2.new(1, 0, 1, 0), nil, ACCENT)
    Corner(bar, 2)

    activeNotifs[n] = { t = tLbl, b = bar }

    -- Animation
    n.Position = UDim2.new(1.5, 0, 0, 0)
    Tw(n, 0.4, "Quart", "Out", { Position = UDim2.new(0, 0, 0, 0) })
    local barTween = Tw(bar, dur, "Linear", "Out", { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(math.max(0, dur - 0.3), function()
        Tw(n, 0.3, "Quart", "In", { Position = UDim2.new(1.5, 0, 0, 0) })
        task.delay(0.35, function()
            activeNotifs[n] = nil
            if n then n:Destroy() end
        end)
    end)
end

-- ══════════════════ WATERMARK SYSTEM ══════════════════
Watermark = NewFrame(NotifySG, UDim2.new(0, 230, 0, 30), UDim2.new(0, 50, 0, 50), Color3.fromRGB(24, 24, 30))
Watermark.Visible = useWatermark
Corner(Watermark, 6)
Stroke(Watermark, STROKE2, 1)

local wmIcon = Instance.new("ImageLabel")
wmIcon.BackgroundTransparency = 1
wmIcon.Size = UDim2.new(0, 18, 0, 18)
wmIcon.Position = UDim2.new(0, 8, 0.5, -9)
wmIcon.Image = "rbxassetid://6034287525"
wmIcon.ImageColor3 = ACCENT
wmIcon.Parent = Watermark

local wmLbl = NewLabel(Watermark, "Wh01 - 0 fps - 0 ping", 11, TEXT)
wmLbl.Position = UDim2.new(0, 32, 0, 0)
wmLbl.Size = UDim2.new(1, -75, 1, 0)
wmLbl.TextXAlignment = Enum.TextXAlignment.Left

local wmBadge = NewFrame(Watermark, UDim2.new(0, 38, 0, 18), UDim2.new(1, -44, 0.5, -9), Color3.fromRGB(45, 45, 55))
Corner(wmBadge, 4)
local wmBadgeLbl = NewLabel(wmBadge, "User", 10, TEXT, true, Enum.TextXAlignment.Center)
wmBadgeLbl.Size = UDim2.new(1, 0, 1, 0)

MakeDraggable(Watermark)

local frames = 0
local fps = 0
local lastFPS = tick()
game:GetService("RunService").RenderStepped:Connect(function()
    frames = frames + 1
    local now = tick()
    if now - lastFPS >= 1 then
        fps = frames
        frames = 0
        lastFPS = now

        -- Only update text once per second
        if useWatermark and Watermark.Visible then
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            wmLbl.Text = string.format("Wh01 - %d fps - %d ping", fps, ping)
        end
    end
end)
rightGrad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(20, 20, 26))
rightGrad.Enabled = false
rightGrad.Parent = RightBox

local Shadow = Instance.new("ImageLabel")
Shadow.BackgroundTransparency = 1
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 3)
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.35
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = Root

local LogoLbl = Instance.new("ImageLabel")
LogoLbl.Name = "Logo"
LogoLbl.BackgroundTransparency = 1
LogoLbl.Size = UDim2.new(0.2, 42, 0, 42)
LogoLbl.Position = UDim2.new(0.5, -45, 0.01, 10)
LogoLbl.Image = "rbxassetid://115851224962601"
LogoLbl.Parent = Sidebar

local LogoSep = NewFrame(Sidebar, UDim2.new(1, -24, 0, 1), UDim2.new(0, 12, 0, 66), STROKE)

local NavHolder = NewFrame(Sidebar,
    UDim2.new(1, 0, 1, -110),
    UDim2.new(0, 0, 0, 76),
    SIDEBAR, 1
)

local NavPad = Instance.new("UIPadding")
NavPad.PaddingLeft = UDim.new(0, 8)
NavPad.PaddingRight = UDim.new(0, 8)
NavPad.PaddingTop = UDim.new(0, 6)
NavPad.Parent = NavHolder

local NavList = Instance.new("UIListLayout")
NavList.SortOrder = Enum.SortOrder.LayoutOrder
NavList.Padding = UDim.new(0, 3)
NavList.Parent = NavHolder

local NAV_DATA = {
    { name = "Main",     icon = "135031929601625", active = true },
    { name = "Combat",   icon = "124577101938161", active = false },
    { name = "Visuals",  icon = "94346865873525",  active = false },
    { name = "Config",   icon = "138953556540282", active = false },
    { name = "Settings", icon = "133365821659023", active = false },
}

local currentNav = nil
local navPages = {}
local accentFills = {} -- slider fill bars and accent elements, recolored on theme change

local function MakeNav(data, idx)
    local btn = NewBtn(NavHolder,
        UDim2.new(1, 0, 0, 38),
        UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(30, 30, 38), -- Dark pill background
        data.active and 0 or 1
    )
    btn.LayoutOrder = idx
    Corner(btn, 19) -- Full pill shape

    local dot = NewFrame(btn, UDim2.new(0, 8, 0, 8), UDim2.new(1, -20, 0.5, -4),
        data.active and ACCENT or Color3.new(1, 1, 1))
    dot.Visible = data.active
    Corner(dot, 4)

    local sym = Instance.new("ImageLabel")
    sym.BackgroundTransparency = 1
    sym.Size = UDim2.new(0, 20, 0, 20)
    sym.Position = UDim2.new(0, 16, 0.5, -10)
    sym.Image = "rbxassetid://" .. data.icon
    sym.ImageColor3 = data.active and Color3.new(1, 1, 1) or DIM
    sym.Parent = btn

    local lbl = NewLabel(btn, data.name, 13, data.active and Color3.new(1, 1, 1) or DIM, data.active)
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.Position = UDim2.new(0, 48, 0, 0)

    -- Create Category Page
    local catPage = NewFrame(RightBox, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    catPage.Visible = data.active
    navPages[data.name] = catPage

    local ref = { btn = btn, sym = sym, lbl = lbl, dot = dot, name = data.name, page = catPage }
    if data.active then currentNav = ref end

    btn.MouseButton1Click:Connect(function()
        if currentNav == ref then return end
        if currentNav then
            Tw(currentNav.btn, 0.13, "Quad", "Out", { BackgroundTransparency = 1 })
            Tw(currentNav.sym, 0.13, "Quad", "Out", { ImageColor3 = DIM })
            Tw(currentNav.lbl, 0.13, "Quad", "Out", { TextColor3 = DIM })
            currentNav.lbl.Font = Enum.Font.Gotham
            currentNav.dot.Visible = false
            currentNav.page.Visible = false
        end
        Tw(btn, 0.13, "Quad", "Out", { BackgroundTransparency = 0 })
        Tw(sym, 0.13, "Quad", "Out", { ImageColor3 = ACCENT })
        Tw(lbl, 0.13, "Quad", "Out", { TextColor3 = ACCENT })
        lbl.Font = Enum.Font.GothamBold
        dot.BackgroundColor3 = ACCENT
        dot.Visible = true
        catPage.Visible = true
        currentNav = ref
    end)

    btn.MouseEnter:Connect(function()
        if not (currentNav and currentNav.btn == btn) then
            Tw(btn, 0.09, "Quad", "Out", { BackgroundTransparency = 0.8, BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
        end
    end)
    btn.MouseLeave:Connect(function()
        if not (currentNav and currentNav.btn == btn) then
            Tw(btn, 0.09, "Quad", "Out", { BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(30, 30, 38) })
        end
    end)
end

for i, v in ipairs(NAV_DATA) do MakeNav(v, i) end

local FootSep = NewFrame(Sidebar, UDim2.new(1, -24, 0, 1), UDim2.new(0, 12, 1, -58), STROKE)

local UserCard = NewBtn(Sidebar, UDim2.new(1, -16, 0, 44), UDim2.new(0, 8, 1, -52), BG, 1)
Corner(UserCard, 8)

local pfp = Instance.new("ImageLabel")
pfp.Size = UDim2.new(0, 32, 0, 32)
pfp.Position = UDim2.new(0, 8, 0.5, -16)
pfp.BackgroundTransparency = 1
pfp.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
Corner(pfp, 16)
pfp.Parent = UserCard

local uLbl = NewLabel(UserCard, "••••••••••", 13, TEXT, true)
uLbl.Size = UDim2.new(1, -52, 1, 0)
uLbl.Position = UDim2.new(0, 48, 0, 0)

local censored = true
UserCard.MouseButton1Click:Connect(function()
    censored = not censored
    uLbl.Text = censored and "••••••••••" or LP.Name:lower()
end)

local function AddCardKeybind(parent, label, default, callback)
    local row = NewBtn(parent, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), BG, 1)
    local lbl = NewLabel(row, label, 10, TEXT)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Size = UDim2.new(1, -74, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    local fit = Instance.new("UITextSizeConstraint")
    fit.MaxTextSize = 11
    fit.MinTextSize = 8
    fit.Parent = lbl

    local box = NewFrame(row, UDim2.new(0, 60, 0, 20), UDim2.new(1, -68, 0.5, -10), Color3.fromRGB(45, 45, 55))
    Corner(box, 4)
    Stroke(box, STROKE2, 1)

    local bindLbl = NewLabel(box, typeof(default) == "EnumItem" and default.Name or tostring(default), 10, TEXT, false,
        Enum.TextXAlignment.Center)
    bindLbl.Size = UDim2.new(1, 0, 1, 0)

    local waiting = false
    row.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        bindLbl.Text = "..."
        Tw(box, 0.2, "Quad", "Out", { BackgroundColor3 = ACCENT })
        bindLbl.TextColor3 = Color3.new(1, 1, 1)

        local connection
        connection = UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                waiting = false
                bindLbl.Text = inp.KeyCode.Name
                Tw(box, 0.2, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                bindLbl.TextColor3 = TEXT
                callback(inp.KeyCode)
                connection:Disconnect()
            end
        end)
    end)
    return row
end

local function AddCardSetting(parent, label, default, callback, keybindDefault, keybindCallback)
    local row = NewBtn(parent, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
    Corner(row, 5)

    local checked = default
    local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
    Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)

    local check = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
    check.Size = UDim2.new(1, 0, 1, 0); check.Visible = checked

    local rightOffset = (keybindDefault and not IS_MOBILE) and -96 or -38
    local lbl = NewLabel(row, label, 13, TEXT)
    lbl.Position = UDim2.new(0, 32, 0, 0); lbl.Size = UDim2.new(1, rightOffset, 1, 0)
    lbl.TextScaled = true
    local fit = Instance.new("UITextSizeConstraint")
    fit.MaxTextSize = 13
    fit.MinTextSize = 8
    fit.Parent = lbl

    if keybindDefault and not IS_MOBILE then
        local kbBox = NewBtn(row, UDim2.new(0, 50, 0, 20), UDim2.new(1, -58, 0.5, -10), Color3.fromRGB(45, 45, 55), 1)
        kbBox.Name = "KeybindBox"
        Corner(kbBox, 4)
        Stroke(kbBox, STROKE2, 1)

        local defName = "None"
        if keybindDefault then
            if typeof(keybindDefault) == "EnumItem" then
                if keybindDefault == Enum.KeyCode.None then
                    defName = "None"
                else
                    defName = keybindDefault.Name
                end
            else
                defName = tostring(keybindDefault)
            end
        end
        local bindLbl = NewLabel(kbBox, defName, 10, TEXT, false, Enum.TextXAlignment.Center)
        bindLbl.Name = "BindLabel"
        bindLbl.Size = UDim2.new(1, 0, 1, 0)

        local waiting = false
        kbBox.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting = true
            bindLbl.Text = "..."
            Tw(kbBox, 0.2, "Quad", "Out", { BackgroundColor3 = ACCENT })
            bindLbl.TextColor3 = Color3.new(1, 1, 1)

            local connection
            connection = UIS.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    waiting = false
                    local keyName = inp.KeyCode.Name
                    bindLbl.Text = keyName
                    Tw(kbBox, 0.2, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                    bindLbl.TextColor3 = TEXT
                    keybindCallback(inp.KeyCode)
                    connection:Disconnect()
                end
            end)
        end)
    end

    local function updateUI()
        check.Visible = checked
        Tw(cbBg, 0.1, "Quad", "Out",
            { BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48) })
    end

    row.MouseButton1Click:Connect(function()
        checked = not checked; updateUI(); callback(checked)
        NOTIFY(label, checked and "Enabled" or "Disabled", 2)
    end)
    row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
    row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)
    updateUI()
    return row
end

local function AddCardSlider(parent, label, min, max, default, callback)
    local row = NewFrame(parent, UDim2.new(1, 0, 0, 44), UDim2.new(0, 0, 0, 0), PANEL, 1)
    local top = NewFrame(row, UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 0), PANEL, 1)
    local l = NewLabel(top, label, 11, TEXT); l.Size = UDim2.new(0.6, 0, 1, 0)
    local vLbl = NewLabel(top, tostring(default), 11, TEXT, false, Enum.TextXAlignment.Right)
    vLbl.Size = UDim2.new(0.4, 0, 1, 0); vLbl.Position = UDim2.new(0.6, 0, 0, 0)

    local trackH = IS_MOBILE and 30 or 20
    local track = NewBtn(row, UDim2.new(1, 0, 0, trackH), UDim2.new(0, 0, 0, 22 - (trackH / 2 - 2)), SLBG, 1)
    local trackBG = NewFrame(track, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0.5, -2), SLBG); Corner(trackBG, 2)
    trackBG.Name = "TrackBG"
    local fill = NewFrame(trackBG, UDim2.new((default - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), SLFILL)
    fill.Name = "Fill"
    Corner(fill, 2); accentFills[#accentFills + 1] = fill

    local knobS = IS_MOBILE and 18 or 12
    local knob = NewFrame(track, UDim2.new(0, knobS, 0, knobS),
        UDim2.new((default - min) / (max - min), -knobS / 2, 0.5, -knobS / 2), Color3.new(1, 1, 1))
    knob.Name = "Knob"
    Corner(knob, knobS / 2)

    local dragging = false
    local function Update(inputX)
        local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + rel * (max - min))
        vLbl.Text = tostring(val)
        Tw(fill, 0.12, "Quad", "Out", { Size = UDim2.new(rel, 0, 1, 0) })
        Tw(knob, 0.12, "Quad", "Out", { Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2) })
        callback(val)
    end

    track.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            Update(inp.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
            dragging = false; NOTIFY(label, "Set to " .. vLbl.Text, 1.5)
        end
    end)
    return row
end

-- ══════════════════ CATEGORY CONTENT: MAIN ══════════════════
-- ══════════════════ CATEGORY CONTENT: MAIN ══════════════════
do
    local MainPage = navPages["Main"]
    local M_TAB_H = 44
    local M_TabBar = NewFrame(MainPage, UDim2.new(1, 0, 0, M_TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
    local M_TabSep = NewFrame(MainPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, M_TAB_H), STROKE)
    local M_Content = NewFrame(MainPage, UDim2.new(1, -20, 1, -(M_TAB_H + 20)), UDim2.new(0, 10, 0, M_TAB_H + 10), BG, 1)

    local M_TABS = { "Main" }
    local mPages = {}
    local activeMIdx = 1

    for i, name in ipairs(M_TABS) do
        local tw = 70
        local tb = NewBtn(M_TabBar, UDim2.new(0, tw, 1, 0), UDim2.new(0, 18, 0, 0), BG, 1)
        local tl = NewLabel(tb, name, 13, ACCENT, true)
        tl.Name = "SectionTitle"
        tl.Size = UDim2.new(1, 0, 1, 0); tl.TextXAlignment = Enum.TextXAlignment.Center

        local ul = NewFrame(MainPage, UDim2.new(0, tw, 0, 2), UDim2.new(0, 18, 0, M_TAB_H - 2), ACCENT)
        Corner(ul, 1)
        table.insert(accentFills, ul)

        local page = NewScroll(M_Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
        mPages[i] = page

        local function IsMatchActive()
            -- Bronx Duels match active check
            if IsBronxDuels() then
                local enemiesFolder = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Match") and
                    LP.Data.Match:FindFirstChild("Enemies")
                if enemiesFolder and #enemiesFolder:GetChildren() > 0 then
                    return true
                end
            end

            -- MurderVsSheriff & generic attribute active match check
            local myGame = LP:GetAttribute("Game")
            if myGame and myGame ~= "nothing" and myGame ~= "" and myGame ~= "Lobby" then
                return true
            end

            -- Legacy fallback
            local runningGames = workspace:FindFirstChild("RunningGames")
            if runningGames then
                for _, gameFolder in pairs(runningGames:GetChildren()) do
                    local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
                    if alivePlayers then
                        for _, teamFolder in pairs(alivePlayers:GetChildren()) do
                            if teamFolder:FindFirstChild(LP.Name) then return true end
                        end
                    end
                end
            end
            return false
        end

        local function BuildAutoMatchCard()
            local AMCard = NewFrame(page, UDim2.new(0.46, 0, 0, 110), UDim2.new(0, 1, 0, 3), PANEL)
            Corner(AMCard, 8); Stroke(AMCard, STROKE, 1)

            local AMTitle = NewLabel(AMCard, "Auto Matchmaking", 13, TEXT, true)
            AMTitle.Size = UDim2.new(1, 0, 0, 30); AMTitle.TextXAlignment = Enum.TextXAlignment.Center

            local AMHolder = NewFrame(AMCard, UDim2.new(1, -16, 0, 70), UDim2.new(0, 8, 0, 32), PANEL, 1)
            Instance.new("UIListLayout", AMHolder).Padding = UDim.new(0, 4)

            getgenv().AM_IGNORING = false
            local lastMatch = 0
            _G.Flux_RequestMatch = function()
                if tick() - lastMatch < 1 then return end
                lastMatch = tick()

                getgenv().AM_IGNORING = true
                local Event = game:GetService("ReplicatedStorage").Packages.Networking["RE/Matchmaking/Matchmaking"]
                if Event then
                    Event:FireServer("cancel")
                    task.wait(0.5)
                    Event:FireServer("play", { mode = _G.AM_CFG.Mode })
                end
                task.wait(1)
                getgenv().AM_IGNORING = false
            end

            local ddRow = NewFrame(AMHolder, UDim2.new(1, 0, 0, 32), nil, BG, 1)
            local dd = AddDropdown(ddRow, { "1v1", "2v2", "3v3" }, _G.AM_CFG.Mode, function(v)
                _G.AM_CFG.Mode = v
                if _G.AM_CFG.Enabled then _G.Flux_RequestMatch() end
            end)
            dd.Size = UDim2.new(1, 0, 1, 0)

            local row = NewBtn(AMHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
            Corner(row, 5)
            local checked = _G.AM_CFG.Enabled
            local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
            Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)
            local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
            cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = checked
            local rowLbl = NewLabel(row, "Enable Auto Match", 13, TEXT)
            rowLbl.Position = UDim2.new(0, 32, 0, 0); rowLbl.Size = UDim2.new(1, -40, 1, 0)


            local function ToggleState(state, silent)
                if state ~= nil then checked = state else checked = not checked end
                _G.AM_CFG.Enabled = checked; cbCheck.Visible = checked
                Tw(cbBg, 0.1, "Quad", "Out",
                    { BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48) })
                if not silent and checked then _G.Flux_RequestMatch() end
            end

            row.MouseButton1Click:Connect(function()
                if IsMatchActive() or IsMurderVsSheriffArena() then
                    NOTIFY("Matchmaking", "Already in a match!", 3)
                    return
                end
                ToggleState()
            end)
            row.MouseEnter:Connect(function()
                Tw(row, 0.1, "Quad", "Out",
                    { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
            end)
            row.MouseLeave:Connect(function()
                Tw(row, 0.1, "Quad", "Out",
                    { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
            end)

            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                local ns = _G.AM_CFG.Enabled
                if ns == nil then ns = checked end
                ToggleState(ns, true)
            end)

            -- Persistence Hook: Auto re-queue if cancelled
            if not getgenv().AM_HOOKED then
                getgenv().AM_HOOKED = true
                local oldNS
                oldNS = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
                    local args = { ... }
                    if not getgenv().AM_IGNORING and typeof(self) == "Instance" and self.Name == "Matchmaking" and args[1] == "cancel" then
                        if _G.AM_CFG and _G.AM_CFG.Enabled then
                            task.spawn(function()
                                task.wait(1)
                                if _G.AM_CFG.Enabled and _G.Flux_RequestMatch then
                                    _G.Flux_RequestMatch()
                                end
                            end)
                        end
                    end
                    return oldNS(self, ...)
                end)
            end
        end
        local function BuildEquipEmoteCard()
            local EmoteCard = NewFrame(page, UDim2.new(0.52, -4, 0, 160), UDim2.new(0.48, 1, 0, 3), PANEL)
            Corner(EmoteCard, 8); Stroke(EmoteCard, STROKE, 1)

            local EmoteTitle = NewLabel(EmoteCard, "Equip Emote", 13, TEXT, true)
            EmoteTitle.Size = UDim2.new(1, 0, 0, 30); EmoteTitle.TextXAlignment = Enum.TextXAlignment.Center

            local EmoteHolder = NewFrame(EmoteCard, UDim2.new(1, -16, 0, 110), UDim2.new(0, 8, 0, 32), PANEL, 1)
            local list = Instance.new("UIListLayout", EmoteHolder)
            list.Padding = UDim.new(0, 6)
            list.HorizontalAlignment = Enum.HorizontalAlignment.Center
            list.SortOrder = Enum.SortOrder.LayoutOrder

            local emotes = {
                "20 min", "are you glad", "bad habit", "bang", "bhop", "billy bounce", "boogie down",
                "brazilian funk", "bunny", "chinese dance", "competent", "confess", "doodle", "dougie",
                "druski", "empty out our pockets", "excuse me sir", "flawless", "griddy", "gucci flip flap",
                "hope", "jester", "jumpStyle", "just wanna rock", "legacy", "low cortisol", "lush life",
                "matrix", "meant", "metro man", "miss the rage", "money so big", "msg", "no hands",
                "no the moon", "rat dance", "rather lie", "riot", "sigma walk", "snoops walk", "so nervy",
                "stephanie", "take the l", "teeth", "tiki tiki", "unlock it", "we can go up", "wiggle", "yara aura"
            }
            local slots = { "Slot: 1", "Slot: 2", "Slot: 3", "Slot: 4", "Slot: 5", "Slot: 6", "Slot: 7", "Slot: 8" }

            local selectedEmote = emotes[1]
            local selectedSlot = "Slot: 1"

            local emoteDd = AddDropdown(EmoteHolder, emotes, selectedEmote, function(v)
                selectedEmote = v
            end)
            emoteDd.LayoutOrder = 1

            local slotDd = AddDropdown(EmoteHolder, slots, selectedSlot, function(v)
                selectedSlot = v
            end)
            slotDd.LayoutOrder = 2

            local btnContainer = NewFrame(EmoteHolder, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 0),
                Color3.fromRGB(0, 0, 0), 1)
            btnContainer.LayoutOrder = 3
            btnContainer.BackgroundTransparency = 1

            local equipBtn = NewBtn(btnContainer, UDim2.new(0.5, -4, 1, 0), UDim2.new(0, 0, 0, 0),
                Color3.fromRGB(36, 36, 48))
            Corner(equipBtn, 6)
            Stroke(equipBtn, STROKE2, 1)
            local btnLbl = NewLabel(equipBtn, "Equip", 11, TEXT, false, Enum.TextXAlignment.Center)
            btnLbl.Size = UDim2.new(1, 0, 1, 0)

            local playBtn = NewBtn(btnContainer, UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 4, 0, 0),
                Color3.fromRGB(36, 36, 48))
            Corner(playBtn, 6)
            Stroke(playBtn, STROKE2, 1)
            local playLbl = NewLabel(playBtn, "Play", 11, TEXT, false, Enum.TextXAlignment.Center)
            playLbl.Size = UDim2.new(1, 0, 1, 0)

            equipBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                    if Event and Event:FindFirstChild("Emotes") then
                        local slotNum = selectedSlot:match("%d+")
                        Event.Emotes:FireServer("EquipEmote", slotNum, selectedEmote)
                        NOTIFY("Equip Emote", "Equipped " .. selectedEmote .. " to slot " .. slotNum, 2)
                    end
                end)
            end)

            equipBtn.MouseEnter:Connect(function()
                Tw(equipBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
            end)
            equipBtn.MouseLeave:Connect(function()
                Tw(equipBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
            end)

            playBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                    if Event and Event:FindFirstChild("Emotes") then
                        Event.Emotes:FireServer("playEmote", selectedEmote)
                        NOTIFY("Play Emote", "Playing " .. selectedEmote, 2)
                    end
                end)
            end)

            playBtn.MouseEnter:Connect(function()
                Tw(playBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
            end)
            playBtn.MouseLeave:Connect(function()
                Tw(playBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
            end)
        end

        local function BuildKillSoundCard()
            local KSCard = NewFrame(page, UDim2.new(0.52, -4, 0, 220), UDim2.new(0.48, 1, 0, 170), PANEL)
            Corner(KSCard, 8); Stroke(KSCard, STROKE, 1)

            local KSTitle = NewLabel(KSCard, "Custom Kill Sound", 13, TEXT, true)
            KSTitle.Size = UDim2.new(1, 0, 0, 30); KSTitle.TextXAlignment = Enum.TextXAlignment.Center

            local KSHolder = NewFrame(KSCard, UDim2.new(1, -16, 0, 180), UDim2.new(0, 8, 0, 32), PANEL, 1)
            local list = Instance.new("UIListLayout", KSHolder)
            list.Padding = UDim.new(0, 6)
            list.HorizontalAlignment = Enum.HorizontalAlignment.Center
            list.SortOrder = Enum.SortOrder.LayoutOrder

            -- Enable Toggle
            local toggleRow = AddCardSetting(KSHolder, "Enable Custom Sound", _G.WORLD_CFG.KillSoundEnabled, function(v)
                _G.WORLD_CFG.KillSoundEnabled = v
                SaveUI()
            end)
            toggleRow.LayoutOrder = 1

            -- TextBox Wrapper
            local tbWrap = NewFrame(KSHolder, UDim2.new(1, 0, 0, 30), nil, Color3.fromRGB(15, 15, 20))
            tbWrap.LayoutOrder = 2
            Corner(tbWrap, 5)
            Stroke(tbWrap, STROKE2, 1)

            local idTextBox = Instance.new("TextBox")
            idTextBox.Size = UDim2.new(1, -16, 1, 0)
            idTextBox.Position = UDim2.new(0, 8, 0, 0)
            idTextBox.BackgroundTransparency = 1
            idTextBox.BorderSizePixel = 0
            idTextBox.TextColor3 = TEXT
            idTextBox.PlaceholderColor3 = DIM
            idTextBox.PlaceholderText = "Roblox Sound ID..."
            idTextBox.Text = tostring(_G.WORLD_CFG.KillSoundId)
            idTextBox.TextSize = 11
            idTextBox.Font = Enum.Font.Gotham
            idTextBox.ClearTextOnFocus = false
            idTextBox.Parent = tbWrap

            idTextBox.FocusLost:Connect(function()
                local txt = idTextBox.Text:gsub("%D", "")
                _G.WORLD_CFG.KillSoundId = txt
                idTextBox.Text = txt
                SaveUI()
            end)

            -- Sound Volume Slider
            local volSlider = AddCardSlider(KSHolder, "Sound Volume", 0, 200, _G.WORLD_CFG.KillSoundVolume, function(v)
                _G.WORLD_CFG.KillSoundVolume = v
                SaveUI()
            end)
            volSlider.LayoutOrder = 3

            -- Test Sound Button
            local testBtn = NewBtn(KSHolder, UDim2.new(1, 0, 0, 32), nil, Color3.fromRGB(36, 36, 48))
            testBtn.LayoutOrder = 4
            Corner(testBtn, 6)
            Stroke(testBtn, STROKE2, 1)
            local testLbl = NewLabel(testBtn, "Test Sound", 11, TEXT, false, Enum.TextXAlignment.Center)
            testLbl.Size = UDim2.new(1, 0, 1, 0)

            testBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local rawId = idTextBox.Text:gsub("%D", "")
                    if rawId ~= "" then
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://" .. rawId
                        sound.Volume = (_G.WORLD_CFG.KillSoundVolume or 100) / 100
                        sound.Parent = game:GetService("SoundService")
                        sound:Play()
                        sound.Ended:Once(function()
                            sound:Destroy()
                        end)
                        task.delay(10, function()
                            if sound and sound.Parent then sound:Destroy() end
                        end)
                    end
                end)
            end)

            testBtn.MouseEnter:Connect(function()
                Tw(testBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
            end)
            testBtn.MouseLeave:Connect(function()
                Tw(testBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
            end)

            -- Sync function
            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                if not KSCard or not KSCard.Parent then return end
                local active = _G.WORLD_CFG.KillSoundEnabled
                local cbBg = toggleRow:FindFirstChildOfClass("Frame")
                local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                if cbCheck then cbCheck.Visible = active end
                if cbBg then
                    cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                end
                idTextBox.Text = tostring(_G.WORLD_CFG.KillSoundId)

                -- Sync Volume Slider
                local volVal = _G.WORLD_CFG.KillSoundVolume or 100
                local topFrame = volSlider:FindFirstChildOfClass("Frame")
                if topFrame then
                    for _, child in ipairs(topFrame:GetChildren()) do
                        if child:IsA("TextLabel") and child.TextXAlignment == Enum.TextXAlignment.Right then
                            child.Text = tostring(volVal)
                        end
                    end
                end
                local trackBtn = volSlider:FindFirstChildOfClass("TextButton")
                local trackBG = trackBtn and trackBtn:FindFirstChild("TrackBG")
                local fillFrame = trackBG and trackBG:FindFirstChild("Fill")
                local knobFrame = trackBtn and trackBtn:FindFirstChild("Knob")
                if fillFrame and knobFrame then
                    local rel = math.clamp(volVal / 200, 0, 1)
                    fillFrame.Size = UDim2.new(rel, 0, 1, 0)
                    local knobS = IS_MOBILE and 18 or 12
                    knobFrame.Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2)
                end
            end)
        end

        local function BuildAutoCollectHatsCard()
            local ACCard = NewFrame(page, UDim2.new(0.52, -4, 0, 110), UDim2.new(0.48, 1, 0, 3), PANEL)
            Corner(ACCard, 8); Stroke(ACCard, STROKE, 1)

            local ACTitle = NewLabel(ACCard, "Auto Collect Coconut", 13, TEXT, true)
            ACTitle.Size = UDim2.new(1, 0, 0, 30); ACTitle.TextXAlignment = Enum.TextXAlignment.Center

            local ACHolder = NewFrame(ACCard, UDim2.new(1, -16, 0, 34), UDim2.new(0, 8, 0, 32), PANEL, 1)

            local row = NewBtn(ACHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
            Corner(row, 5)

            local active = false
            local usedThisMatch = false

            local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
            Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)
            local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
            cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = false

            local rowLbl = NewLabel(row, "Collect Now", 13, TEXT)
            rowLbl.Position = UDim2.new(0, 32, 0, 0); rowLbl.Size = UDim2.new(1, -40, 1, 0)

            row.MouseButton1Click:Connect(function()
                if not IsMatchActive() and IsMurderVsSheriffLobby() then
                    NOTIFY("Auto Collect", "Only available in a match!", 3)
                    return
                end

                if usedThisMatch then
                    NOTIFY("Auto Collect", "Already used this match!", 3)
                    return
                end

                active = true; usedThisMatch = true
                cbCheck.Visible = true; rowLbl.Text = "Collecting..."

                task.spawn(function()
                    local Event = game:GetService("ReplicatedStorage").Packages.Networking
                        ["RE/Events/CollectEventSpawnable"]
                    local gui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("Main")
                    local currency = gui and gui:FindFirstChild("MainButtonsGui") and
                        gui.MainButtonsGui:FindFirstChild("EventCurrency")

                    local lastVal = currency and currency.Text or ""
                    local noChangeCount = 0

                    for i = 1, 100 do
                        if not active then break end
                        Event:FireServer()
                        task.wait(0.03)

                        local currentVal = currency and currency.Text or ""
                        if currentVal ~= lastVal then
                            lastVal = currentVal; noChangeCount = 0
                        else
                            noChangeCount = noChangeCount + 1
                        end

                        if i > 20 and noChangeCount > 15 then break end
                    end

                    active = false; cbCheck.Visible = false
                    rowLbl.Text = "Collect (Locked)"; rowLbl.TextColor3 = DIM
                    row.AutoButtonColor = false
                    NOTIFY("Auto Collect", "Finished collecting!", 3)
                end)
            end)
            row.MouseEnter:Connect(function()
                Tw(row, 0.1, "Quad", "Out",
                    { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
            end)
            row.MouseLeave:Connect(function()
                Tw(row, 0.1, "Quad", "Out",
                    { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
            end)

            -- Auto-reset when entering a new match
            task.spawn(function()
                local wasInMatch = false
                while task.wait(2) do
                    if getgenv().FLUX_SESSION ~= MySession then break end
                    local nowInMatch = IsMatchActive()
                    if nowInMatch and not wasInMatch then
                        usedThisMatch = false
                        rowLbl.Text = "Collect Now"
                        rowLbl.TextColor3 = TEXT
                        row.AutoButtonColor = true
                    end
                    wasInMatch = nowInMatch
                end
            end)
        end
        local function BuildAutoCollectCoconutsCard()
            local ACCard = NewFrame(page, UDim2.new(0.52, -4, 0, 80), UDim2.new(0.48, 1, 0, 3), PANEL)
            Corner(ACCard, 8); Stroke(ACCard, STROKE, 1)

            local ACTitle = NewLabel(ACCard, "Auto Collect Eggs", 13, TEXT, true)
            ACTitle.Size = UDim2.new(1, 0, 0, 30); ACTitle.TextXAlignment = Enum.TextXAlignment.Center

            local ACHolder = NewFrame(ACCard, UDim2.new(1, -16, 0, 34), UDim2.new(0, 8, 0, 32), PANEL, 1)

            local row = NewBtn(ACHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
            Corner(row, 5)

            local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
            Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)
            local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
            cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = false

            local rowLbl = NewLabel(row, "Enable Auto Collect", 13, TEXT)
            rowLbl.Position = UDim2.new(0, 32, 0, 0); rowLbl.Size = UDim2.new(1, -40, 1, 0)

            local autoCollectEnabled = false
            local addedConn = nil
            local spawnConn = nil

            row.MouseButton1Click:Connect(function()
                autoCollectEnabled = not autoCollectEnabled
                cbCheck.Visible = autoCollectEnabled
                Tw(cbBg, 0.1, "Quad", "Out",
                    { BackgroundColor3 = autoCollectEnabled and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48) })

                if autoCollectEnabled then
                    task.spawn(function()
                        local droppables = workspace:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild(
                            "Droppables")

                        local function touchEgg(part)
                            if not autoCollectEnabled then return end
                            local lp = game:GetService("Players").LocalPlayer
                            local char = lp.Character or lp.CharacterAdded:Wait()
                            local hrp = char:WaitForChild("HumanoidRootPart")
                            if not hrp then return end
                            pcall(firetouchinterest, hrp, part, 0)
                            task.wait(0.1)
                            pcall(firetouchinterest, hrp, part, 1)
                        end

                        local function collectAll()
                            if not autoCollectEnabled then return end
                            for _, child in ipairs(droppables:GetChildren()) do
                                if child.Name:match("^Egg") then
                                    task.spawn(touchEgg, child)
                                end
                            end
                        end

                        addedConn = droppables.ChildAdded:Connect(function(child)
                            if child.Name:match("^Egg") then
                                task.spawn(touchEgg, child)
                            end
                        end)

                        local lp = game:GetService("Players").LocalPlayer
                        spawnConn = lp.CharacterAdded:Connect(function()
                            task.wait(1)
                            collectAll()
                        end)

                        collectAll()
                    end)
                else
                    if addedConn then
                        addedConn:Disconnect(); addedConn = nil
                    end
                    if spawnConn then
                        spawnConn:Disconnect(); spawnConn = nil
                    end
                end
            end)

            row.MouseEnter:Connect(function()
                Tw(row, 0.1, "Quad", "Out",
                    { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
            end)
            row.MouseLeave:Connect(function()
                Tw(row, 0.1, "Quad", "Out",
                    { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
            end)
        end

        local function BuildRollbackDupeCard()
            local RDCard = NewFrame(page, UDim2.new(0.46, 0, 0, 80), UDim2.new(0, 1, 0, 353), PANEL)
            Corner(RDCard, 8); Stroke(RDCard, STROKE, 1)

            local RDTitle = NewLabel(RDCard, "Rollback Dupe", 13, TEXT, true)
            RDTitle.Size = UDim2.new(1, 0, 0, 30); RDTitle.TextXAlignment = Enum.TextXAlignment.Center

            local RDHolder = NewFrame(RDCard, UDim2.new(1, -16, 0, 40), UDim2.new(0, 8, 0, 32), PANEL, 1)
            local executeBtn = NewBtn(RDHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(36, 36, 48))
            Corner(executeBtn, 6); Stroke(executeBtn, STROKE2, 1)

            local executeLbl = NewLabel(executeBtn, "Execute Rollback", 11, TEXT, true, Enum.TextXAlignment.Center)
            executeLbl.Size = UDim2.new(1, 0, 1, 0)

            executeBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and
                        game:GetService("ReplicatedStorage").Events:FindFirstChild("HUD") and
                        game:GetService("ReplicatedStorage").Events.HUD:FindFirstChild("Settings")
                    if Event then
                        Event:FireServer("CrosshairID", "\xED\xBE\x8C", "Crosshair")
                        NOTIFY("Rollback Dupe", "Rollback event fired!", 3)
                    else
                        NOTIFY("Rollback Dupe", "Settings event not found!", 3)
                    end
                end)
            end)

            executeBtn.MouseEnter:Connect(function()
                Tw(executeBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
            end)
            executeBtn.MouseLeave:Connect(function()
                Tw(executeBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
            end)
        end

        local function BuildLocalPlayerCard()
            local yPos = 3
            local LPCardHeight = 160
            local LPHolderHeight = 120

            if IsMurderVsSheriff() then
                yPos = 123
                LPCardHeight = 240
                LPHolderHeight = 200
            elseif IsHitmark() then
                yPos = 3
                LPCardHeight = 380
                LPHolderHeight = 340
            elseif IsDuelist() then
                yPos = 3
                LPCardHeight = 340
                LPHolderHeight = 300
            end

            local LPCard = NewFrame(page, UDim2.new(0.46, 0, 0, LPCardHeight), UDim2.new(0, 1, 0, yPos), PANEL)
            Corner(LPCard, 8); Stroke(LPCard, STROKE, 1)

            local LPTitle = NewLabel(LPCard, "Local Player", 13, TEXT, true)
            LPTitle.Size = UDim2.new(1, 0, 0, 30); LPTitle.TextXAlignment = Enum.TextXAlignment.Center

            local LPHolder = NewFrame(LPCard, UDim2.new(1, -16, 0, LPHolderHeight), UDim2.new(0, 8, 0, 32), PANEL, 1)
            local list = Instance.new("UIListLayout", LPHolder)
            list.Padding = UDim.new(0, 4)
            list.HorizontalAlignment = Enum.HorizontalAlignment.Center
            list.SortOrder = Enum.SortOrder.LayoutOrder

            local speedCheck, speedSlider
            if IsMurderVsSheriff() or IsDuelist() then
                speedCheck = AddCardSetting(LPHolder, "Speed Boost", _G.LOCAL_PLAYER_CFG.SpeedEnabled, function(v)
                    _G.LOCAL_PLAYER_CFG.SpeedEnabled = v
                    local char = LP.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and not v then
                        if IsDuelist() then
                            hum:SetAttribute("ForceSpeed", nil)
                        else
                            hum.WalkSpeed = 16
                        end
                    end
                end, _G.LOCAL_PLAYER_CFG.SpeedKey, function(k)
                    _G.LOCAL_PLAYER_CFG.SpeedKey = k.Name
                end)
                speedCheck.LayoutOrder = 1

                speedSlider = AddCardSlider(LPHolder, "Walk Speed", 16, 40, _G.LOCAL_PLAYER_CFG.Speed, function(v)
                    _G.LOCAL_PLAYER_CFG.Speed = v
                end)
                speedSlider.LayoutOrder = 2
            end

            local flyCheck = AddCardSetting(LPHolder, "Player Fly", _G.LOCAL_PLAYER_CFG.FlyEnabled, function(v)
                _G.LOCAL_PLAYER_CFG.FlyEnabled = v
            end, _G.LOCAL_PLAYER_CFG.FlyKey, function(k)
                _G.LOCAL_PLAYER_CFG.FlyKey = k.Name
            end)
            flyCheck.LayoutOrder = 3

            local flySlider = AddCardSlider(LPHolder, "Fly Speed", 0, 1000, _G.LOCAL_PLAYER_CFG.FlySpeed, function(v)
                _G.LOCAL_PLAYER_CFG.FlySpeed = v
            end)
            flySlider.LayoutOrder = 4

            local invisCheck
            if not IsBronxDuels() and not IsDuelist() then
                invisCheck = AddCardSetting(LPHolder, "Invisibility", _G.LOCAL_PLAYER_CFG.InvisEnabled, function(v)
                    _G.LOCAL_PLAYER_CFG.InvisEnabled = v
                end, _G.LOCAL_PLAYER_CFG.InvisKey, function(k)
                    _G.LOCAL_PLAYER_CFG.InvisKey = k.Name
                    if _G.FLUX_UPDATE_KB_HUD then pcall(_G.FLUX_UPDATE_KB_HUD) end
                end)
                invisCheck.LayoutOrder = 5
            end

            local infCheck, spinCheck, spinSlider, gravCheck, gravSlider
            if IsHitmark() or IsDuelist() then
                infCheck = AddCardSetting(LPHolder, "Infinite Jump", _G.FUN_CFG.InfJump, function(v)
                    _G.FUN_CFG.InfJump = v
                end)
                infCheck.LayoutOrder = 10

                spinCheck = AddCardSetting(LPHolder, "Spinbot", _G.FUN_CFG.Spinbot, function(v)
                    _G.FUN_CFG.Spinbot = v
                end)
                spinCheck.LayoutOrder = 11

                spinSlider = AddCardSlider(LPHolder, "Spin Speed", 10, 100, _G.FUN_CFG.SpinSpeed, function(v)
                    _G.FUN_CFG.SpinSpeed = v
                end)
                spinSlider.LayoutOrder = 12
            end

            if IsHitmark() then
                gravCheck = AddCardSetting(LPHolder, "Custom Gravity", _G.FUN_CFG.GravityEnabled, function(v)
                    _G.FUN_CFG.GravityEnabled = v
                end)
                gravCheck.LayoutOrder = 13

                gravSlider = AddCardSlider(LPHolder, "Gravity Value", 0, 500, _G.FUN_CFG.GravityValue, function(v)
                    _G.FUN_CFG.GravityValue = v
                end)
                gravSlider.LayoutOrder = 14
            end

            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                if (IsMurderVsSheriff() or IsDuelist()) and speedCheck and speedSlider then
                    local active = _G.LOCAL_PLAYER_CFG.SpeedEnabled
                    local cbBg = speedCheck:FindFirstChildOfClass("Frame")
                    local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                    if cbCheck then cbCheck.Visible = active end
                    if cbBg then
                        cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                    end

                    local kbBox = speedCheck:FindFirstChild("KeybindBox")
                    local bindLbl = kbBox and kbBox:FindFirstChild("BindLabel")
                    if bindLbl then
                        bindLbl.Text = tostring(_G.LOCAL_PLAYER_CFG.SpeedKey)
                    end

                    local speedVal = _G.LOCAL_PLAYER_CFG.Speed
                    local topFrame = speedSlider:FindFirstChildOfClass("Frame")
                    if topFrame then
                        for _, child in ipairs(topFrame:GetChildren()) do
                            if child:IsA("TextLabel") and child.TextXAlignment == Enum.TextXAlignment.Right then
                                child.Text = tostring(speedVal)
                            end
                        end
                    end
                    local trackBtn = speedSlider:FindFirstChildOfClass("TextButton")
                    local trackBG = trackBtn and trackBtn:FindFirstChild("TrackBG")
                    local fillFrame = trackBG and trackBG:FindFirstChild("Fill")
                    local knobFrame = trackBtn and trackBtn:FindFirstChild("Knob")
                    if fillFrame and knobFrame then
                        local rel = math.clamp((speedVal - 16) / (40 - 16), 0, 1)
                        fillFrame.Size = UDim2.new(rel, 0, 1, 0)
                        local knobS = IS_MOBILE and 18 or 12
                        knobFrame.Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2)
                    end
                end

                -- Fly sync
                local fActive = _G.LOCAL_PLAYER_CFG.FlyEnabled
                local fCbBg = flyCheck:FindFirstChildOfClass("Frame")
                local fCbCheck = fCbBg and fCbBg:FindFirstChildOfClass("TextLabel")
                if fCbCheck then fCbCheck.Visible = fActive end
                if fCbBg then
                    fCbBg.BackgroundColor3 = fActive and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                end

                local fKbBox = flyCheck:FindFirstChild("KeybindBox")
                local fBindLbl = fKbBox and fKbBox:FindFirstChild("BindLabel")
                if fBindLbl then
                    fBindLbl.Text = tostring(_G.LOCAL_PLAYER_CFG.FlyKey)
                end

                local flyVal = _G.LOCAL_PLAYER_CFG.FlySpeed
                local fTopFrame = flySlider:FindFirstChildOfClass("Frame")
                if fTopFrame then
                    for _, child in ipairs(fTopFrame:GetChildren()) do
                        if child:IsA("TextLabel") and child.TextXAlignment == Enum.TextXAlignment.Right then
                            child.Text = tostring(flyVal)
                        end
                    end
                end
                local fTrackBtn = flySlider:FindFirstChildOfClass("TextButton")
                local fTrackBG = fTrackBtn and fTrackBtn:FindFirstChild("TrackBG")
                local fFillFrame = fTrackBG and fTrackBG:FindFirstChild("Fill")
                local fKnobFrame = fTrackBtn and fTrackBtn:FindFirstChild("Knob")
                if fFillFrame and fKnobFrame then
                    local rel = math.clamp(flyVal / 1000, 0, 1)
                    fFillFrame.Size = UDim2.new(rel, 0, 1, 0)
                    local knobS = IS_MOBILE and 18 or 12
                    fKnobFrame.Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2)
                end

                -- Invisibility sync
                if invisCheck then
                    local iActive = _G.LOCAL_PLAYER_CFG.InvisEnabled
                    local iCbBg = invisCheck:FindFirstChildOfClass("Frame")
                    local iCbCheck = iCbBg and iCbBg:FindFirstChildOfClass("TextLabel")
                    if iCbCheck then iCbCheck.Visible = iActive end
                    if iCbBg then
                        iCbBg.BackgroundColor3 = iActive and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                    end

                    local iKbBox = invisCheck:FindFirstChild("KeybindBox")
                    local iBindLbl = iKbBox and iKbBox:FindFirstChild("BindLabel")
                    if iBindLbl then
                        iBindLbl.Text = tostring(_G.LOCAL_PLAYER_CFG.InvisKey)
                    end
                end

                -- Fun Options sync
                if IsHitmark() or IsDuelist() then
                    if infCheck then
                        local active = _G.FUN_CFG.InfJump
                        local cbBg = infCheck:FindFirstChildOfClass("Frame")
                        local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                        if cbCheck then cbCheck.Visible = active end
                        if cbBg then
                            cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                        end
                    end
                    if spinCheck then
                        local active = _G.FUN_CFG.Spinbot
                        local cbBg = spinCheck:FindFirstChildOfClass("Frame")
                        local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                        if cbCheck then cbCheck.Visible = active end
                        if cbBg then
                            cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                        end
                    end
                    if spinSlider then
                        local val = _G.FUN_CFG.SpinSpeed
                        local topFrame = spinSlider:FindFirstChildOfClass("Frame")
                        if topFrame then
                            for _, child in ipairs(topFrame:GetChildren()) do
                                if child:IsA("TextLabel") and child.TextXAlignment == Enum.TextXAlignment.Right then
                                    child.Text = tostring(val)
                                end
                            end
                        end
                        local trackBtn = spinSlider:FindFirstChildOfClass("TextButton")
                        local trackBG = trackBtn and trackBtn:FindFirstChild("TrackBG")
                        local fillFrame = trackBG and trackBG:FindFirstChild("Fill")
                        local knobFrame = trackBtn and trackBtn:FindFirstChild("Knob")
                        if fillFrame and knobFrame then
                            local rel = math.clamp((val - 10) / 90, 0, 1)
                            fillFrame.Size = UDim2.new(rel, 0, 1, 0)
                            local knobS = IS_MOBILE and 18 or 12
                            knobFrame.Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2)
                        end
                    end
                    if gravCheck then
                        local active = _G.FUN_CFG.GravityEnabled
                        local cbBg = gravCheck:FindFirstChildOfClass("Frame")
                        local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                        if cbCheck then cbCheck.Visible = active end
                        if cbBg then
                            cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                        end
                    end
                    if gravSlider then
                        local val = _G.FUN_CFG.GravityValue
                        local topFrame = gravSlider:FindFirstChildOfClass("Frame")
                        if topFrame then
                            for _, child in ipairs(topFrame:GetChildren()) do
                                if child:IsA("TextLabel") and child.TextXAlignment == Enum.TextXAlignment.Right then
                                    child.Text = tostring(val)
                                end
                            end
                        end
                        local trackBtn = gravSlider:FindFirstChildOfClass("TextButton")
                        local trackBG = trackBtn and trackBtn:FindFirstChild("TrackBG")
                        local fillFrame = trackBG and trackBG:FindFirstChild("Fill")
                        local knobFrame = trackBtn and trackBtn:FindFirstChild("Knob")
                        if fillFrame and knobFrame then
                            local rel = math.clamp(val / 500, 0, 1)
                            fillFrame.Size = UDim2.new(rel, 0, 1, 0)
                            local knobS = IS_MOBILE and 18 or 12
                            knobFrame.Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2)
                        end
                    end
                end
            end)
        end

        if IsMurderVsSheriff() then
            BuildAutoMatchCard()
            BuildAutoCollectHatsCard()
        elseif IsHitmark() then
            BuildAutoCollectCoconutsCard()
        elseif IsDuelist() then
            BuildEquipEmoteCard()
            BuildKillSoundCard()
            BuildRollbackDupeCard()
        end
        BuildLocalPlayerCard()
    end
end

-- ══════════════════ CATEGORY CONTENT: COMBAT ══════════════════
local CombatPage = navPages["Combat"]
local TAB_H = 44
local TabBar = NewFrame(CombatPage, UDim2.new(1, 0, 0, TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
-- MakeDraggable(TabBar, Root)



local TabSep = NewFrame(CombatPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, TAB_H), STROKE)

local ContentRow = NewFrame(CombatPage,
    UDim2.new(1, -20, 1, -(TAB_H + 3 + 20)),
    UDim2.new(0, 10, 0, TAB_H + 3 + 10),
    BG, 1
)

local TABS = { "Aimbot", "Silent Aim", "Kill Aura" }
local tabPages = {}
local activeTabIdx = 1
local tabBtns = {}
local tabLines = {}

local tx = 18
for i, name in ipairs(TABS) do
    local tw2 = 82
    local tb = NewBtn(TabBar, UDim2.new(0, tw2, 1, 0), UDim2.new(0, tx, 0, 0), BG, 1)
    local tl = NewLabel(tb, name, 13, i == 1 and ACCENT or DIM, i == 1)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Center

    local ul = NewFrame(CombatPage, UDim2.new(0, tw2, 0, 2), UDim2.new(0, tx, 0, TAB_H - 2), ACCENT)
    ul.Visible = i == 1
    Corner(ul, 1)

    -- Create Page Container
    local page = NewFrame(ContentRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    page.Visible = (i == 1)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.FillDirection = Enum.FillDirection.Horizontal
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page

    tabPages[i] = page
    tabBtns[i] = { btn = tb, lbl = tl }
    tabLines[i] = ul
    tx = tx + tw2 + 14

    tb.MouseButton1Click:Connect(function()
        if activeTabIdx == i then return end

        -- Hide Old
        tabBtns[activeTabIdx].lbl.TextColor3 = DIM
        tabBtns[activeTabIdx].lbl.Font = Enum.Font.Gotham
        tabLines[activeTabIdx].Visible = false
        tabPages[activeTabIdx].Visible = false

        -- Show New
        activeTabIdx = i
        tl.TextColor3 = ACCENT
        tl.Font = Enum.Font.GothamBold
        ul.Visible = true
        page.Visible = true
    end)
end


-- Content for Aimbot Tab (Page 1)
local AimbotPage = tabPages[1]

local LeftPanel = NewFrame(AimbotPage, UDim2.new(0.54, -5, 0, 310), UDim2.new(0, 0, 0, 0), PANEL)
LeftPanel.LayoutOrder = 1
Corner(LeftPanel, 8)
Stroke(LeftPanel, STROKE, 1)

local LPTitle = NewLabel(LeftPanel, "Aimbot", 13, TEXT, true)
LPTitle.Name = "SectionTitle"
LPTitle.Size = UDim2.new(1, 0, 0, 30)
LPTitle.Position = UDim2.new(0, 0, 0, 0)
LPTitle.TextXAlignment = Enum.TextXAlignment.Center

local CheckHolder = NewFrame(LeftPanel, UDim2.new(1, -16, 0, 210), UDim2.new(0, 8, 0, 36), PANEL, 1)
local CheckList = Instance.new("UIListLayout")
CheckList.SortOrder = Enum.SortOrder.LayoutOrder
CheckList.Padding = UDim.new(0, 2)
CheckList.Parent = CheckHolder

local CHECKS = {
    { label = "Aimbot",              badge = "None" },
    { label = "Draw Fov",            badge = nil },
    { label = "Visible Check",       badge = nil },
    { label = "Ignore Dead Players", badge = nil },
    { label = "Humanize Aimbot",     badge = nil },
}

for i, data in ipairs(CHECKS) do
    local row = NewBtn(CheckHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
    row.LayoutOrder = i
    Corner(row, 5)

    local bLbl = nil

    -- Checkbox
    local checked = false
    if data.label == "Ignore Dead Players" then checked = true end
    local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
    Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)
    local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
    cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = checked

    -- Label
    local rowLbl = NewLabel(row, data.label, 13, TEXT)
    rowLbl.Position = UDim2.new(0, 32, 0, 0)
    local rightOffset = (data.badge and not IS_MOBILE) and -96 or -38
    rowLbl.Size = UDim2.new(1, rightOffset, 1, 0)
    rowLbl.TextScaled = true
    local fit = Instance.new("UITextSizeConstraint")
    fit.MaxTextSize = 13
    fit.MinTextSize = 8
    fit.Parent = rowLbl

    local function ToggleState(state, silent)
        if state ~= nil then checked = state else checked = not checked end
        cbCheck.Visible = checked
        Tw(cbBg, 0.1, "Quad", "Out", {
            BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
        })

        -- Sync with Aimbot Config
        if data.label == "Aimbot" then
            _G.AIMBOT_CFG.Enabled = checked
        elseif data.label == "Draw Fov" then
            _G.AIMBOT_CFG.DrawFov = checked
        elseif data.label == "Visible Check" then
            _G.AIMBOT_CFG.VisibleCheck = checked
        elseif data.label == "Humanize Aimbot" then
            _G.AIMBOT_CFG.Humanize = checked
        elseif data.label == "Ignore Dead Players" then
            _G.AIMBOT_CFG.IgnoreDead = checked
        end
        if not silent then NOTIFY(data.label, checked and "Enabled" or "Disabled", 2) end
    end

    _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
    table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
        local ns = checked
        if data.label == "Aimbot" then
            ns = _G.AIMBOT_CFG.Enabled
            -- Sync loaded Keybind badge label
            if data.badge and _G.AIMBOT_CFG.Keybind and bLbl then
                local k = _G.AIMBOT_CFG.Keybind
                local name = (typeof(k) == "EnumItem" and k.Name or tostring(k):gsub("Enum.UserInputType.", ""))
                if name ~= "None" and name ~= "" then
                    bLbl.Text = name:sub(1, 6)
                else
                    bLbl.Text = "None"
                end
            end
        elseif data.label == "Draw Fov" then
            ns = _G.AIMBOT_CFG.DrawFov
        elseif data.label == "Visible Check" then
            ns = _G.AIMBOT_CFG.VisibleCheck
        elseif data.label == "Humanize Aimbot" then
            ns = _G.AIMBOT_CFG.Humanize
        elseif data.label == "Ignore Dead Players" then
            ns = _G.AIMBOT_CFG.IgnoreDead
        end
        if ns == nil then ns = checked end
        ToggleState(ns, true)
    end)


    if data.badge and not IS_MOBILE then
        local kbBox = NewBtn(row, UDim2.new(0, 50, 0, 20), UDim2.new(1, -58, 0.5, -10), Color3.fromRGB(45, 45, 55), 1)
        kbBox.Name = "KeybindBox"
        Corner(kbBox, 4)
        Stroke(kbBox, STROKE2, 1)

        bLbl = NewLabel(kbBox, data.badge, 10, TEXT, false, Enum.TextXAlignment.Center)
        bLbl.Size = UDim2.new(1, 0, 1, 0)

        local waiting = false
        kbBox.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting = true
            bLbl.Text = "..."
            bLbl.TextColor3 = Color3.new(1, 1, 1)
            Tw(kbBox, 0.2, "Quad", "Out", { BackgroundColor3 = ACCENT })

            local conn; conn = UIS.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard or inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 then
                    waiting = false
                    local boundKey = inp.KeyCode ~= Enum.KeyCode.Unknown and inp.KeyCode or inp.UserInputType
                    local name = (typeof(boundKey) == "EnumItem" and boundKey.Name or tostring(boundKey):gsub("Enum.UserInputType.", ""))
                    bLbl.Text = name:sub(1, 6)
                    bLbl.TextColor3 = TEXT
                    Tw(kbBox, 0.2, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                    if data.label == "Aimbot" then
                        _G.AIMBOT_CFG.Keybind = boundKey
                        if _G.FLUX_UPDATE_KB_HUD then pcall(_G.FLUX_UPDATE_KB_HUD) end
                    end
                    conn:Disconnect()
                end
            end)
        end)

        -- Add InputBegan listener to toggle Aimbot
        table.insert(_G.FLUX_CONNS, UIS.InputBegan:Connect(function(inp, gp)
            if gp or waiting then return end
            local currentBind = (data.label == "Aimbot") and _G.AIMBOT_CFG.Keybind or nil
            if not currentBind then return end

            local match = false
            if typeof(currentBind) == "EnumItem" then
                if currentBind.EnumType == Enum.KeyCode then
                    match = (inp.KeyCode == currentBind)
                elseif currentBind.EnumType == Enum.UserInputType then
                    match = (inp.UserInputType == currentBind)
                end
            end

            if match then
                ToggleState()
                if _G.FLUX_UI_UPDATE_FUNCS then
                    for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                end
            end
        end))
    end

    row.MouseButton1Click:Connect(function() ToggleState() end)
    row.MouseEnter:Connect(function()
        Tw(row, 0.1, "Quad", "Out", { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
    end)
    row.MouseLeave:Connect(function()
        Tw(row, 0.1, "Quad", "Out", { BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
    end)
end

local targetPartDd = AddDropdown(LeftPanel, { "Head", "UpperTorso", "HumanoidRootPart" }, "Head", function(v)
    _G.AIMBOT_CFG.TargetPart = v
end)
targetPartDd.Position = UDim2.new(0, 8, 0, 260)
targetPartDd.Size = UDim2.new(0.48, -12, 0, 32)

local aimModeDd = AddDropdown(LeftPanel, { "Mouse Aim", "Camera Aim" }, "Mouse Aim", function(v)
    _G.AIMBOT_CFG.AimMode = v
end)
aimModeDd.Position = UDim2.new(0.52, 4, 0, 260)
aimModeDd.Size = UDim2.new(0.48, -12, 0, 32)

local RightPanel = NewFrame(AimbotPage, UDim2.new(0.46, -5, 0, 310), UDim2.new(0, 0, 0, 0), PANEL)
RightPanel.LayoutOrder = 2
Corner(RightPanel, 8)
Stroke(RightPanel, STROKE, 1)

local RPTitle = NewLabel(RightPanel, "Options", 13, TEXT, true)
RPTitle.Name = "SectionTitle"
RPTitle.Size = UDim2.new(1, 0, 0, 30)
RPTitle.Position = UDim2.new(0, 0, 0, 0)
RPTitle.TextXAlignment = Enum.TextXAlignment.Center

local SliderHolder = NewFrame(RightPanel, UDim2.new(1, -20, 0, 260), UDim2.new(0, 10, 0, 36), PANEL, 1)
local SliderListLayout = Instance.new("UIListLayout")
SliderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SliderListLayout.Padding = UDim.new(0, 6)
SliderListLayout.Parent = SliderHolder

local SLIDERS = {
    { label = "FOV",           min = 0, max = 500,  val = 150.0, key = "FOV" },
    { label = "Distance",      min = 0, max = 1000, val = 500.0, key = "MaxDist" },
    { label = "Hit Chance",    min = 0, max = 100,  val = 80.0,  key = "HitChance" },
    { label = "Prediction",    min = 0, max = 2,    val = 0.165, key = "PredictionAmount" },
    { label = "RCS Intensity", min = 0, max = 5,    val = 1.0,   key = "RCSAmount" },
}


local activeSliders = {}

-- accentFills declared near top (line ~605)
for i, data in ipairs(SLIDERS) do
    local row = NewFrame(SliderHolder, UDim2.new(1, 0, 0, 52), UDim2.new(0, 0, 0, 0), PANEL, 1)
    row.LayoutOrder = i

    local topRow = NewFrame(row, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), PANEL, 1)
    local sLbl = NewLabel(topRow, data.label, 12, TEXT)
    sLbl.Size = UDim2.new(0.6, 0, 1, 0)

    local valLbl = NewLabel(topRow, string.format("%.1f", data.val), 12, TEXT, false, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.4, 0, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)

    local trackH = IS_MOBILE and 30 or 5
    local track = NewBtn(row, UDim2.new(1, 0, 0, trackH), UDim2.new(0, 0, 0, 26 - (trackH / 2 - 2)), PANEL, 1)

    local trackBG = NewFrame(track, UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 0.5, -2), SLBG)
    Corner(trackBG, 3)

    local pct = (data.val - data.min) / (data.max - data.min)
    local fill = NewFrame(trackBG, UDim2.new(pct, 0, 1, 0), UDim2.new(0, 0, 0, 0), SLFILL)
    Corner(fill, 3)
    accentFills[#accentFills + 1] = fill

    local knobS = IS_MOBILE and 20 or 15
    local knob = NewFrame(track, UDim2.new(0, knobS, 0, knobS), UDim2.new(pct, -knobS / 2, 0.5, -knobS / 2),
        Color3.fromRGB(228, 230, 255))
    Corner(knob, knobS / 2)
    Stroke(knob, Color3.fromRGB(170, 174, 210), 1.5)

    local dragging = false

    local function DoUpdate(inputX)
        local ap = track.AbsolutePosition.X
        local as = track.AbsoluteSize.X
        local rel = math.clamp((inputX - ap) / as, 0, 1)
        local nv = math.floor((data.min + rel * (data.max - data.min)) * 10 + 0.5) / 10
        valLbl.Text = string.format("%.1f", nv)
        Tw(fill, 0.12, "Quad", "Out", { Size = UDim2.new(rel, 0, 1, 0) })
        Tw(knob, 0.12, "Quad", "Out", { Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2) })

        -- Sync Slider Value
        if data.key then _G.AIMBOT_CFG[data.key] = nv end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            getgenv()._CEN_SLD_ACTIVE = true
            DoUpdate(inp.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            DoUpdate(inp.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                getgenv()._CEN_SLD_ACTIVE = false
            end
        end
    end)
end



-- [ GLOBAL UI HELPERS ]
function AddESPSetting(parent, label, default, colorCount, hasKeybind, callback, defaultColors)
    local row = NewBtn(parent, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
    row.LayoutOrder = #parent:GetChildren()
    Corner(row, 5)

    local checked = default
    local curBind = nil
    local waiting = false
    local colorBtns = {}

    local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
    Corner(cbBg, 3)
    Stroke(cbBg, STROKE2, 1)

    local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
    cbCheck.Size = UDim2.new(1, 0, 1, 0)
    cbCheck.Visible = checked

    local rightOffset = -35
    local extra = 0
    if hasKeybind and not IS_MOBILE then
        extra = extra + 58
    end
    if colorCount and colorCount > 0 then
        extra = extra + (colorCount * 28)
    end
    if extra > 0 then
        rightOffset = -(extra + 38)
    end

    local lbl = NewLabel(row, label, 13, TEXT)
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.Size = UDim2.new(1, rightOffset, 1, 0)
    lbl.TextScaled = true
    lbl.TextWrapped = true
    local fit = Instance.new("UITextSizeConstraint")
    fit.MaxTextSize = 13
    fit.MinTextSize = 8
    fit.Parent = lbl

    local function updateUI()
        cbCheck.Visible = checked
        Tw(cbBg, 0.1, "Quad", "Out", {
            BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
        })
    end

    local function ToggleState(state, silent)
        if state ~= nil then checked = state else checked = not checked end
        updateUI()
        local clrs = {}
        for _, b in ipairs(colorBtns) do table.insert(clrs, b.BackgroundColor3) end
        if callback then callback(checked, clrs, curBind) end
        if not silent then NOTIFY("Settings", label .. ": " .. (checked and "Enabled" or "Disabled"), 1.2) end
    end

    if colorCount and colorCount > 0 then
        local offset = -30
        for i = 1, colorCount do
            local defClr = (defaultColors and defaultColors[i]) or Color3.new(1, 1, 1)
            local cBtn = NewBtn(row, UDim2.new(0, 24, 0, 24), UDim2.new(1, offset, 0.5, -12), defClr)
            Corner(cBtn, 4)
            Stroke(cBtn, Color3.new(1, 1, 1), 1).Transparency = 0.5
            table.insert(colorBtns, cBtn)

            cBtn.MouseButton1Click:Connect(function()
                if _G.OpenPicker then
                    _G.OpenPicker(cBtn.BackgroundColor3, cBtn.AbsolutePosition, function(c)
                        cBtn.BackgroundColor3 = c
                        local clrs = {}
                        for _, b in ipairs(colorBtns) do table.insert(clrs, b.BackgroundColor3) end
                        if callback then callback(checked, clrs) end
                    end)
                end
            end)
            offset = offset - 28
        end
    end

    if hasKeybind and not IS_MOBILE then
        local badge = NewBtn(row, UDim2.new(0, 50, 0, 20), UDim2.new(1, -58, 0.5, -10), Color3.fromRGB(45, 45, 55))
        badge.Name = "KeybindBadge"
        Corner(badge, 4)
        Stroke(badge, STROKE2, 1)
        local bLbl = NewLabel(badge, "None", 10, TEXT, false, Enum.TextXAlignment.Center)
        bLbl.Size = UDim2.new(1, 0, 1, 0)

        badge.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting = true
            bLbl.Text = "..."
            bLbl.TextColor3 = Color3.new(1, 1, 1)
            Tw(badge, 0.2, "Quad", "Out", { BackgroundColor3 = ACCENT })

            local conn
            conn = UIS.InputBegan:Connect(function(inp, gp)
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    curBind = inp.KeyCode
                    bLbl.Text = curBind.Name:sub(1, 4)
                    bLbl.TextColor3 = TEXT
                    Tw(badge, 0.2, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                    waiting = false

                    local clrs = {}
                    for _, b in ipairs(colorBtns) do table.insert(clrs, b.BackgroundColor3) end
                    if callback then callback(checked, clrs, curBind) end
                    if _G.FLUX_UPDATE_KB_HUD then pcall(_G.FLUX_UPDATE_KB_HUD) end

                    conn:Disconnect()
                end
            end)
        end)

        UIS.InputBegan:Connect(function(inp, gp)
            if gp or waiting or not curBind then return end
            if inp.KeyCode == curBind then ToggleState() end
        end)
    end

    _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
    table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
        local ns = checked
        if label == "Enabled" then
            ns = _G.ESP_CFG.Enabled
            if hasKeybind and _G.ESP_CFG.Keybind then
                curBind = _G.ESP_CFG.Keybind
                local badge = row:FindFirstChild("KeybindBadge")
                local bLbl = badge and badge:FindFirstChildOfClass("TextLabel")
                if bLbl then
                    bLbl.Text = (typeof(curBind) == "EnumItem" and curBind.Name or tostring(curBind)):sub(1, 4)
                end
            end
        elseif label == "Enable Bots" then
            ns = _G.ESP_CFG.Bots
        elseif label == "Ignore Team" then
            ns = _G.ESP_CFG.IgnoreTeam
        elseif label == "Player Names" then
            ns = _G.ESP_CFG.Names
        elseif label == "Display Names" then
            ns = _G.ESP_CFG.DisplayNames
        elseif label == "Equipped Tool" then
            ns = _G.ESP_CFG.Tools
        elseif label == "Distance" then
            ns = _G.ESP_CFG.Distance
        elseif label == "Health Bars" then
            ns = _G.ESP_CFG.HealthBar
        elseif label == "Health Text" then
            ns = _G.ESP_CFG.HealthText
        elseif label == "Skeleton" then
            ns = _G.ESP_CFG.Skeleton
        elseif label == "Chams" then
            ns = _G.ESP_CFG.Chams
        elseif label == "Tool Chams" then
            ns = _G.ESP_CFG.ToolChams
        elseif label == "Snaplines" then
            ns = _G.ESP_CFG.Snaplines
        elseif label == "Off-Screen Lines" then
            ns = _G.ESP_CFG.OffScreen
        elseif label == "Boxes" then
            ns = _G.ESP_CFG.Boxes
        elseif label == "Fill Boxes" then
            ns = _G.ESP_CFG.BoxFill
        elseif label == "Full Bright" then
            ns = _G.WORLD_CFG.FullBright
        elseif label == "No Fog" then
            ns = _G.WORLD_CFG.NoFog
        elseif label == "Atmosphere Color" then
            ns = _G.WORLD_CFG.AtmosColor ~= nil
        elseif label == "FPS Booster" then
            ns = _G.WORLD_CFG.FPSBooster
        end
        if ns == nil then ns = checked end
        ToggleState(ns, true)
    end)

    updateUI()
    row.MouseButton1Click:Connect(function() ToggleState() end)
    row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
    row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)

    return row
end

function AddVSSlider(parent, label, min, max, default, suffix, callback)
    local row = NewFrame(parent, UDim2.new(1, 0, 0, 42), nil, BG, 1)
    local top = NewFrame(row, UDim2.new(1, 0, 0, 16), nil, BG, 1)
    NewLabel(top, label, 11, TEXT).Size = UDim2.new(0.6, 0, 1, 0)
    local valL = NewLabel(top, string.format("%.1f", default) .. (suffix or ""), 11, ACCENT, false,
        Enum.TextXAlignment.Right)
    valL.Size = UDim2.new(0.4, 0, 1, 0)
    valL.Position = UDim2.new(0.6, 0, 0, 0)

    local trackH = IS_MOBILE and 32 or 24
    local track = NewBtn(row, UDim2.new(1, 0, 0, trackH), UDim2.new(0, 0, 0, 20), BG, 1)

    local trackBG = NewFrame(track, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0.5, -2), Color3.fromRGB(45, 45, 55))
    Corner(trackBG, 2)

    local fill = NewFrame(trackBG, UDim2.new((default - min) / (max - min), 0, 1, 0), nil, ACCENT)
    Corner(fill, 2)
    accentFills[#accentFills + 1] = fill

    local knobS = IS_MOBILE and 18 or 12
    local knob = NewFrame(track, UDim2.new(0, knobS, 0, knobS),
        UDim2.new((default - min) / (max - min), -knobS / 2, 0.5, -knobS / 2),
        Color3.new(1, 1, 1))
    Corner(knob, knobS / 2)

    local dragging = false
    local function update(inputX)
        local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + rel * (max - min)) * 10 + 0.5) / 10
        valL.Text = string.format("%.1f", val) .. (suffix or "")
        Tw(fill, 0.12, "Quad", "Out", { Size = UDim2.new(rel, 0, 1, 0) })
        Tw(knob, 0.12, "Quad", "Out", { Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2) })
        callback(val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            getgenv()._CEN_SLD_ACTIVE = true
            dragging = true; update(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                getgenv()._CEN_SLD_ACTIVE = false
                local val = math.floor((min + (knob.Position.X.Scale) * (max - min)) * 10 + 0.5) / 10
                NOTIFY("Settings", label .. ": " .. tostring(val) .. (suffix or ""), 1.5)
            end
        end
    end)
end

local function SETUP_COLOR_PICKER()
    if PICKER_GUI then return end
    PICKER_GUI = Instance.new("ScreenGui")
    PICKER_GUI.Name = "DrkPicker"
    PICKER_GUI.DisplayOrder = 2147483647
    PICKER_GUI.IgnoreGuiInset = true
    pcall(function() PICKER_GUI.Parent = game:GetService("CoreGui") end)
    if not PICKER_GUI.Parent then PICKER_GUI.Parent = PG end

    PICKER_MAIN = NewFrame(PICKER_GUI, UDim2.new(0, 200, 0, 220), nil, Color3.fromRGB(30, 30, 40))
    PICKER_MAIN.Visible = false
    PICKER_MAIN.Active = true
    Corner(PICKER_MAIN, 10)
    Stroke(PICKER_MAIN, STROKE, 1)

    local sv = NewFrame(PICKER_MAIN, UDim2.new(1, -20, 0, 150), UDim2.new(0, 10, 0, 10), Color3.fromHSV(0, 1, 1))
    sv.Active = true
    Corner(sv, 6)

    local white = NewFrame(sv, UDim2.new(1, 0, 1, 0), nil, Color3.new(1, 1, 1))
    Corner(white, 6)
    local wg = Instance.new("UIGradient", white)
    wg.Transparency = NumberSequence.new(0, 1)

    local black = NewFrame(sv, UDim2.new(1, 0, 1, 0), nil, Color3.new(0, 0, 0))
    Corner(black, 6)
    local bg = Instance.new("UIGradient", black)
    bg.Rotation = 90
    bg.Transparency = NumberSequence.new(1, 0)

    local cursor = NewFrame(sv, UDim2.new(0, 10, 0, 10), UDim2.new(1, -5, 0, -5), Color3.new(1, 1, 1))
    Corner(cursor, 10)
    Stroke(cursor, Color3.new(0, 0, 0), 2)

    local hue = NewFrame(PICKER_MAIN, UDim2.new(1, -20, 0, 12), UDim2.new(0, 10, 0, 170), Color3.new(1, 1, 1))
    hue.Active = true
    Corner(hue, 6)
    local hg = Instance.new("UIGradient", hue)
    hg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })

    local hcursor = NewFrame(hue, UDim2.new(0, 4, 1, 4), UDim2.new(0, 0, 0.5, -2), Color3.new(1, 1, 1))
    Corner(hcursor, 2)
    Stroke(hcursor, Color3.new(0, 0, 0), 1)

    local ch, cs, cv = 0, 1, 1
    local function Update()
        local c = Color3.fromHSV(ch, cs, cv)
        sv.BackgroundColor3 = Color3.fromHSV(ch, 1, 1)
        cursor.Position = UDim2.new(cs, -5, 1 - cv, -5)
        hcursor.Position = UDim2.new(ch, -2, 0.5, -9)
        if PICKER_CALLBACK then PICKER_CALLBACK(c) end
    end

    local function HandleInput(obj, cb)
        local d = false
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = true;
                getgenv()._CEN_PKR_ACTIVE = true
                cb(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                cb(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = false;
                getgenv()._CEN_PKR_ACTIVE = false
            end
        end)
    end

    HandleInput(sv, function(i)
        local x = math.clamp((i.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
        local y = math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        cs, cv = x, 1 - y
        Update()
    end)
    HandleInput(hue, function(i)
        ch = math.clamp((i.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
        Update()
    end)

    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and PICKER_MAIN.Visible then
            local mp = UIS:GetMouseLocation()
            local p = PICKER_MAIN.AbsolutePosition
            local s = PICKER_MAIN.AbsoluteSize
            if mp.X < p.X or mp.X > p.X + s.X or mp.Y < p.Y + 36 or mp.Y > p.Y + s.Y + 36 then
                PICKER_MAIN.Visible = false
                PICKER_OPEN = false
            end
        end
    end)

    _G.OpenPicker = function(cur, pos, cb)
        ch, cs, cv = cur:ToHSV()
        PICKER_CALLBACK = cb
        PICKER_MAIN.Position = UDim2.new(0, pos.X - 210, 0, pos.Y - 50)
        PICKER_MAIN.Visible = true
        PICKER_OPEN = true
        Update()
    end
end
SETUP_COLOR_PICKER()

local ConfigPreferencesTabPage

-- ══════════════════ CATEGORY CONTENT: OTHERS ══════════════════
-- ══════════════════ CATEGORY CONTENT: CONFIG ══════════════════
do
    local ConfigPage = navPages["Config"]
    if ConfigPage then
        local HS = game:GetService("HttpService")
        local CONFIG_FOLDER = "FluxConfigs"
        local AUTOLOAD_FILE = "FluxAutoload.json"

        -- Standard Layout Components
        local TAB_H = 44
        local TabBar = NewFrame(ConfigPage, UDim2.new(1, 0, 0, TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
        local TabSep = NewFrame(ConfigPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, TAB_H), STROKE)

        local ContentRow = NewFrame(ConfigPage,
            UDim2.new(1, -20, 1, -(TAB_H + 3 + 20)),
            UDim2.new(0, 10, 0, TAB_H + 3 + 10),
            BG, 1
        )

        local configTabDefs = {
            { name = "Configs",     width = 82 },
            { name = "Preferences", width = 96 }
        }
        local configTabBtns = {}
        local configTabLines = {}
        local configPages = {}
        local activeConfigTabIdx = 1
        local configTx = 18

        for i, tabData in ipairs(configTabDefs) do
            local tb = NewBtn(TabBar, UDim2.new(0, tabData.width, 1, 0), UDim2.new(0, configTx, 0, 0), BG, 1)
            local tl = NewLabel(tb, tabData.name, 13, i == 1 and ACCENT or DIM, i == 1)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.TextXAlignment = Enum.TextXAlignment.Center

            local ul = NewFrame(ConfigPage, UDim2.new(0, tabData.width, 0, 2), UDim2.new(0, configTx, 0, TAB_H - 2),
                ACCENT)
            ul.Visible = i == 1
            Corner(ul, 1)
            table.insert(accentFills, ul)

            local subPage = NewScroll(ContentRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
            subPage.Visible = i == 1
            subPage.ClipsDescendants = true

            configTabBtns[i] = { btn = tb, lbl = tl }
            configTabLines[i] = ul
            configPages[i] = subPage
            configTx = configTx + tabData.width + 14

            tb.MouseButton1Click:Connect(function()
                if activeConfigTabIdx == i then return end

                configTabBtns[activeConfigTabIdx].lbl.TextColor3 = DIM
                configTabBtns[activeConfigTabIdx].lbl.Font = Enum.Font.Gotham
                configTabLines[activeConfigTabIdx].Visible = false
                configPages[activeConfigTabIdx].Visible = false

                activeConfigTabIdx = i
                tl.TextColor3 = ACCENT
                tl.Font = Enum.Font.GothamBold
                ul.Visible = true
                subPage.Visible = true
            end)
        end

        _G.FLUX_CONFIG_TAB_THEME_SYNC = function()
            for i, ref in ipairs(configTabBtns) do
                if ref and ref.lbl then
                    ref.lbl.TextColor3 = (i == activeConfigTabIdx) and ACCENT or DIM
                end
            end
        end

        local page = configPages[1]
        ConfigPreferencesTabPage = configPages[2]

        -- Absolute layout used
        -- Helpers
        local function EnsureFolder()
            if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        end

        local function ListConfigs()
            EnsureFolder()
            local out = {}
            local ok, files = pcall(listfiles, CONFIG_FOLDER)
            if ok and files then
                for _, path in ipairs(files) do
                    local name = path:match("[/\\]([^/\\]+)%.json$")
                    if name then table.insert(out, name) end
                end
            end
            return out
        end

        local function GetAutoload()
            if isfile and isfile(AUTOLOAD_FILE) then
                local ok, d = pcall(function() return HS:JSONDecode(readfile(AUTOLOAD_FILE)) end)
                if ok and d and d.name then return d.name end
            end
            return nil
        end

        local function CollectSettings()
            local function copy(t)
                local r = {}
                for k, v in pairs(t) do r[k] = v end
                return r
            end
            return {
                placeId     = game.PlaceId,
                created     = os.date("%x %X"),
                AIMBOT      = copy(_G.AIMBOT_CFG),
                SILENT      = copy(_G.SILENT_CFG),
                AM          = copy(_G.AM_CFG),
                WORLD       = copy(_G.WORLD_CFG),
                LOCALPLAYER = copy(_G.LOCAL_PLAYER_CFG),
                FUN         = copy(_G.FUN_CFG),
                ESP         = _G.ESP_CFG and copy(_G.ESP_CFG) or nil,
                UI          = {
                    notifications = useNotifications,
                    watermark     = useWatermark,
                    kbhud         = useKbHud
                }
            }
        end

        local function ApplySettings(data)
            if not data then return end
            if GetGameGroup(data.placeId) ~= GetGameGroup(game.PlaceId) then
                NOTIFY("Config", "This config is for a different game!", 3)
                return
            end
            local function merge(dst, src)
                if not src then return end
                for k, v in pairs(src) do dst[k] = v end
            end
            merge(_G.AIMBOT_CFG, data.AIMBOT)
            merge(_G.SILENT_CFG, data.SILENT)
            merge(_G.AM_CFG, data.AM)
            merge(_G.WORLD_CFG, data.WORLD)
            if data.LOCALPLAYER then merge(_G.LOCAL_PLAYER_CFG, data.LOCALPLAYER) end
            if data.FUN then merge(_G.FUN_CFG, data.FUN) end
            if data.ESP and _G.ESP_CFG then merge(_G.ESP_CFG, data.ESP) end

            -- UI Preference Sync from Config
            if data.UI then
                if data.UI.notifications ~= nil then useNotifications = data.UI.notifications end
                if data.UI.watermark ~= nil then useWatermark = data.UI.watermark end
                if data.UI.kbhud ~= nil then useKbHud = data.UI.kbhud end

                -- Force apply to active instances
                if ApplyUIPreferences then ApplyUIPreferences() end
            end

            -- Sync UI Elements
            if _G.FLUX_UI_UPDATE_FUNCS then
                for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do
                    pcall(f)
                end
            end

            NOTIFY("Config", "Config loaded ✓", 2.5)
        end

        -- Auto-load on start
        task.defer(function()
            local aName = GetAutoload()
            if aName then
                local path = CONFIG_FOLDER .. "/" .. aName .. ".json"
                if isfile(path) then
                    local ok, d = pcall(function() return HS:JSONDecode(readfile(path)) end)
                    if ok and d then ApplySettings(d) end
                end
            end
        end)

        -- ─── Left Panel (Management) ───
        local LeftPanel = NewFrame(page, UDim2.new(0.46, 0, 0, 380), UDim2.new(0, 1, 0, 3), PANEL)
        LeftPanel.LayoutOrder = 1
        Corner(LeftPanel, 8); Stroke(LeftPanel, STROKE, 1)

        local LPTitle = NewLabel(LeftPanel, "Config Management", 13, TEXT, true)
        LPTitle.Name = "SectionTitle"
        LPTitle.Size = UDim2.new(1, 0, 0, 30)
        LPTitle.TextXAlignment = Enum.TextXAlignment.Center

        local scroll = NewFrame(LeftPanel, UDim2.new(1, -16, 1, -42), UDim2.new(0, 8, 0, 42), BG, 1)
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 10)

        -- Name input card
        local nameCard = NewFrame(scroll, UDim2.new(1, 0, 0, 70), nil, PANEL)
        Corner(nameCard, 8)
        NewLabel(nameCard, "Config name", 11, DIM).Position = UDim2.new(0, 10, 0, 6)

        local nameBoxWrap = NewFrame(nameCard, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 28),
            Color3.fromRGB(15, 15, 20))
        Corner(nameBoxWrap, 5); Stroke(nameBoxWrap, STROKE2, 1)

        local nameBox = Instance.new("TextBox")
        nameBox.Size = UDim2.new(1, 0, 1, 0)
        nameBox.Position = UDim2.new(0, 0, 0, 0)
        nameBox.BackgroundTransparency = 1; nameBox.BorderSizePixel = 0
        nameBox.TextColor3 = TEXT; nameBox.PlaceholderColor3 = DIM
        nameBox.PlaceholderText = "Enter name..."; nameBox.Text = ""
        nameBox.TextSize = 11; nameBox.Font = Enum.Font.Gotham
        nameBox.ClearTextOnFocus = false; nameBox.Parent = nameBoxWrap

        -- List card
        local listCard = NewFrame(scroll, UDim2.new(1, 0, 0, 260), nil, PANEL)
        Corner(listCard, 8)
        NewLabel(listCard, "Config list", 11, DIM).Position = UDim2.new(0, 10, 0, 6)

        -- Dropdown (Matching Global Style)
        local selectedConfig = nil
        local ddFrame = NewFrame(listCard, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 26), Color3.fromRGB(32, 32, 44))
        Corner(ddFrame, 6); Stroke(ddFrame, STROKE2, 1)

        local ddLbl = NewLabel(ddFrame, "---", 11, TEXT)
        ddLbl.Position = UDim2.new(0, 10, 0, 0); ddLbl.Size = UDim2.new(1, -30, 1, 0)

        local ddArrow = Instance.new("ImageLabel")
        ddArrow.BackgroundTransparency = 1; ddArrow.Size = UDim2.new(0, 12, 0, 12); ddArrow.Position = UDim2.new(1, -22,
            0.5, -6)
        ddArrow.Image = "rbxassetid://6034818372"; ddArrow.ImageColor3 = DIM; ddArrow.Parent = ddFrame

        local ddOpen = false
        local ddPopup = NewFrame(ddFrame, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 4), Color3.fromRGB(28, 28, 38))
        ddPopup.ZIndex = 500; ddPopup.Visible = false; ddPopup.ClipsDescendants = true
        Corner(ddPopup, 6); Stroke(ddPopup, STROKE2, 1)
        Instance.new("UIListLayout", ddPopup).SortOrder = Enum.SortOrder.LayoutOrder

        local totalLbl -- forward decl
        local function RefreshTotalCount()
            if totalLbl then
                local configs = ListConfigs()
                totalLbl.Text = "Total Configs: " .. #configs
            end
        end

        local configNames = {}
        local function RefreshDD()
            for _, c in ipairs(ddPopup:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            configNames = ListConfigs()
            if #configNames == 0 then
                ddLbl.Text = "---"; selectedConfig = nil
            end
            for i, n in ipairs(configNames) do
                local ob = NewBtn(ddPopup, UDim2.new(1, 0, 0, 26), nil, BG, 1)
                ob.LayoutOrder = i; ob.ZIndex = 501
                local ol = NewLabel(ob, n, 11, TEXT); ol.Position = UDim2.new(0, 10, 0, 0); ol.Size = UDim2.new(1, -10, 1,
                    0); ol.ZIndex = 502
                ob.MouseButton1Click:Connect(function()
                    selectedConfig = n; ddLbl.Text = n; ddOpen = false
                    Tw(ddPopup, 0.15, "Quad", "Out", { Size = UDim2.new(1, 0, 0, 0) })
                    task.delay(0.16, function() ddPopup.Visible = false end)
                    Tw(ddArrow, 0.15, "Quad", "Out", { Rotation = 0 })
                    if _G.UpdateConfigDetails then _G.UpdateConfigDetails(n) end
                end)
            end
            RefreshTotalCount()
        end

        local ddBtn = NewBtn(ddFrame, UDim2.new(1, 0, 1, 0), nil, BG, 1)
        ddBtn.ZIndex = 10
        ddBtn.MouseButton1Click:Connect(function()
            ddOpen = not ddOpen
            if ddOpen then
                RefreshDD()
                ddPopup.Visible = true
                local popH = #configNames * 26
                Tw(ddPopup, 0.18, "Quad", "Out", { Size = UDim2.new(1, 0, 0, math.min(popH, 150)) })
                Tw(ddArrow, 0.18, "Quad", "Out", { Rotation = 180 })
            else
                ddOpen = false; Tw(ddPopup, 0.15, "Quad", "Out", { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.16, function() ddPopup.Visible = false end)
                Tw(ddArrow, 0.15, "Quad", "Out", { Rotation = 0 })
            end
        end)

        -- Buttons grid
        local gridY = 66
        local btnDefs = {
            { "Load",    "load" }, { "Overwrite", "overwrite" }, { "Delete", "delete" },
            { "Refresh", "refresh" }, { "Autoload", "setauto" }, { "Clear Auto", "resetauto" },
        }
        local actionBtns = {}
        for i, def in ipairs(btnDefs) do
            local col = (i - 1) % 2; local row = math.floor((i - 1) / 2)
            local ab = NewBtn(listCard, UDim2.new(0.5, -13, 0, 34),
                UDim2.new(col * 0.5, col == 0 and 10 or 3, 0, gridY + row * 42), Color3.fromRGB(28, 28, 38))
            Corner(ab, 6); Stroke(ab, STROKE, 1)
            local aLbl = NewLabel(ab, def[1], 11, TEXT, false, Enum.TextXAlignment.Center); aLbl.Size = UDim2.new(1, 0, 1,
                0)
            ab.MouseEnter:Connect(function()
                Tw(ab, 0.09, "Quad", "Out",
                    { BackgroundColor3 = Color3.fromRGB(38, 38, 52) })
            end)
            ab.MouseLeave:Connect(function()
                Tw(ab, 0.09, "Quad", "Out",
                    { BackgroundColor3 = Color3.fromRGB(28, 28, 38) })
            end)
            actionBtns[def[2]] = { btn = ab, lbl = aLbl }
        end

        -- Create button (Inside listCard, at the bottom)
        local createBtn = NewBtn(listCard, UDim2.new(1, -20, 0, 38), UDim2.new(0, 10, 0, gridY + 3 * 42),
            Color3.fromRGB(32, 32, 44))
        Corner(createBtn, 8)
        Stroke(createBtn, STROKE2, 1)
        local createLbl = NewLabel(createBtn, "Create config", 13, TEXT, false, Enum.TextXAlignment.Center)
        createLbl.Size = UDim2.new(1, 0, 1, 0)
        createBtn.MouseEnter:Connect(function()
            Tw(createBtn, 0.1, "Quad", "Out",
                { BackgroundColor3 = Color3.fromRGB(40, 40, 55) })
        end)
        createBtn.MouseLeave:Connect(function()
            Tw(createBtn, 0.1, "Quad", "Out",
                { BackgroundColor3 = Color3.fromRGB(32, 32, 44) })
        end)

        listCard.Size = UDim2.new(1, 0, 0, gridY + 3 * 42 + 38 + 10)

        -- ─── Right Panel (Info) ───
        local RightPanel = NewFrame(page, UDim2.new(0.52, -4, 0, 380), UDim2.new(0.48, 1, 0, 3), PANEL)
        RightPanel.LayoutOrder = 2
        Corner(RightPanel, 8); Stroke(RightPanel, STROKE, 1)

        local RPTitle = NewLabel(RightPanel, "Settings Info", 13, TEXT, true)
        RPTitle.Name = "SectionTitle"
        RPTitle.Size = UDim2.new(1, 0, 0, 30); RPTitle.TextXAlignment = Enum.TextXAlignment.Center

        local InfoScroll = NewFrame(RightPanel, UDim2.new(1, -16, 1, -42), UDim2.new(0, 8, 0, 42), BG, 1)
        Instance.new("UIListLayout", InfoScroll).Padding = UDim.new(0, 10)

        totalLbl = NewLabel(InfoScroll, "Total Configs: 0", 11, TEXT)
        totalLbl.Size = UDim2.new(1, 0, 0, 20)

        local autoLbl = NewLabel(InfoScroll, "Autoload: none", 11, ACCENT)
        autoLbl.Size = UDim2.new(1, 0, 0, 20)

        local function RefreshAutoLbl()
            local n = GetAutoload(); autoLbl.Text = "Autoload: " .. (n or "none"); autoLbl.TextColor3 = n and ACCENT or
                DIM
        end
        RefreshAutoLbl()

        local detailTitle = NewLabel(InfoScroll, "Config Details:", 11, ACCENT)
        detailTitle.Size = UDim2.new(1, 0, 0, 20)

        local infoList = NewLabel(InfoScroll, "Select a config to see details", 11, DIM)
        infoList.Size = UDim2.new(1, 0, 0, 160); infoList.TextWrapped = true; infoList.TextYAlignment = Enum
            .TextYAlignment.Top

        _G.UpdateConfigDetails = function(name)
            if not name then
                infoList.Text = "No config selected"; return
            end
            local path = CONFIG_FOLDER .. "/" .. name .. ".json"
            if not isfile(path) then
                infoList.Text = "File not found"; return
            end
            local ok, d = pcall(function() return HS:JSONDecode(readfile(path)) end)
            if not (ok and d) then
                infoList.Text = "Could not read config"; return
            end

            local txt = "• Created: " .. (d.created or "N/A") .. "\n"
            txt = txt .. "• GameID: " .. tostring(d.placeId or "N/A") .. "\n\n"

            -- Helper: list enabled booleans in a table with name mapping
            local function listEnabled(tbl, labelMap)
                if not tbl then return "" end
                local out = ""
                for key, label in pairs(labelMap) do
                    if tbl[key] == true then
                        out = out .. "  ✓ " .. label .. "\n"
                    end
                end
                return out
            end

            -- Aimbot
            local aimbotMap = {
                Enabled = "Aimbot",
                DrawFov = "Draw FOV",
                VisibleCheck = "Visible Check",
                Humanize = "Humanize",
                IgnoreDead = "Ignore Dead"
            }
            local aimbotLines = listEnabled(d.AIMBOT, aimbotMap)
            if aimbotLines ~= "" then
                txt = txt .. "Combat:\n" .. aimbotLines
            end

            -- Silent Aim
            local silentMap = {
                Enabled = "Silent Aim",
                AutoHead = "Auto Head",
                AntiAim = "Anti-Aim",
                NoRecoil = "No Recoil",
                TargetLock = "Target Lock"
            }
            local silentLines = listEnabled(d.SILENT, silentMap)
            if silentLines ~= "" then
                txt = txt .. "Silent Aim:\n" .. silentLines
            end

            -- Auto Match
            local amMap = { Enabled = "Auto Match" }
            local amLines = listEnabled(d.AM, amMap)
            if amLines ~= "" then
                txt = txt .. "Auto Match:\n" .. amLines
            end

            -- ESP
            local espMap = {
                Enabled = "ESP",
                Names = "Player Names",
                Boxes = "Boxes",
                HealthBar = "Health Bars",
                Skeleton = "Skeleton",
                Snaplines = "Snaplines",
                Chams = "Chams",
                OffScreen = "Off-Screen Lines",
                Bots = "Enable Bots"
            }
            local espLines = listEnabled(d.ESP, espMap)
            if espLines ~= "" then
                txt = txt .. "ESP:\n" .. espLines
            end

            -- World Visuals
            local worldMap = {
                FullBright = "Full Bright", NoFog = "No Fog"
            }
            local worldLines = listEnabled(d.WORLD, worldMap)
            if d.WORLD and d.WORLD.AtmosColor then
                worldLines = worldLines .. "  ✓ Atmosphere Color\n"
            end
            if worldLines ~= "" then
                txt = txt .. "World Visuals:\n" .. worldLines
            end

            if txt:match("✓") == nil then
                txt = txt .. "(No options enabled)"
            end

            infoList.Text = txt
        end

        RefreshTotalCount()

        -- Actions
        createBtn.MouseButton1Click:Connect(function()
            local n = nameBox.Text:match("^%s*(.-)%s*$")
            if n == "" then
                NOTIFY("Config", "Enter name!", 2); return
            end
            EnsureFolder(); local path = CONFIG_FOLDER .. "/" .. n .. ".json"
            local data = CollectSettings()
            local ok = pcall(function() writefile(path, HS:JSONEncode(data)) end)
            if ok then
                NOTIFY("Config", "Saved ✓", 2.5); nameBox.Text = ""; RefreshDD()
            else
                NOTIFY("Config", "Save failed", 3)
            end
        end)

        actionBtns.load.btn.MouseButton1Click:Connect(function()
            if not selectedConfig then
                NOTIFY("Config", "Select one!", 2); return
            end
            local path = CONFIG_FOLDER .. "/" .. selectedConfig .. ".json"
            if not isfile(path) then
                NOTIFY("Config", "Not found!", 2); return
            end
            local ok, d = pcall(function() return HS:JSONDecode(readfile(path)) end)
            if ok then ApplySettings(d) else NOTIFY("Config", "Load error!", 2) end
        end)

        actionBtns.overwrite.btn.MouseButton1Click:Connect(function()
            if not selectedConfig then
                NOTIFY("Config", "Select one!", 2); return
            end
            EnsureFolder(); local path = CONFIG_FOLDER .. "/" .. selectedConfig .. ".json"
            local data = CollectSettings()
            local ok = pcall(function() writefile(path, HS:JSONEncode(data)) end)
            if ok then NOTIFY("Config", "Updated ✓", 2.5) else NOTIFY("Config", "Failed!", 2) end
        end)

        actionBtns.delete.btn.MouseButton1Click:Connect(function()
            if not selectedConfig then
                NOTIFY("Config", "Select one!", 2); return
            end
            local path = CONFIG_FOLDER .. "/" .. selectedConfig .. ".json"
            local ok = pcall(delfile, path)
            if ok then
                NOTIFY("Config", "Deleted", 2); selectedConfig = nil; ddLbl.Text = "---"; RefreshDD(); RefreshAutoLbl()
            else
                NOTIFY("Config", "Failed!", 2)
            end
        end)

        actionBtns.refresh.btn.MouseButton1Click:Connect(function()
            RefreshDD(); NOTIFY("Config", "Refreshed", 1.5)
        end)

        actionBtns.setauto.btn.MouseButton1Click:Connect(function()
            if not selectedConfig then
                NOTIFY("Config", "Select one!", 2); return
            end
            local ok = pcall(function() writefile(AUTOLOAD_FILE, HS:JSONEncode({ name = selectedConfig })) end)
            if ok then
                NOTIFY("Config", "Autoload set!", 2.5); RefreshAutoLbl()
            else
                NOTIFY("Config", "Failed!", 2)
            end
        end)

        actionBtns.resetauto.btn.MouseButton1Click:Connect(function()
            local ok = pcall(delfile, AUTOLOAD_FILE)
            if ok or not isfile(AUTOLOAD_FILE) then
                NOTIFY("Config", "Cleared", 2); RefreshAutoLbl()
            else
                NOTIFY("Config", "Failed!", 2)
            end
        end)
    end
end

do
    local PreferencesPage = ConfigPreferencesTabPage or navPages["Preferences"]
    if PreferencesPage then
        local isEmbeddedInConfig = PreferencesPage == ConfigPreferencesTabPage
        local prefScroll

        if isEmbeddedInConfig then
            prefScroll = NewScroll(PreferencesPage, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
        else
            local PREF_TAB_H = 44
            local PrefTabBar = NewFrame(PreferencesPage, UDim2.new(1, 0, 0, PREF_TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
            local PrefTabSep = NewFrame(PreferencesPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, PREF_TAB_H), STROKE)

            local PrefContentRow = NewFrame(PreferencesPage,
                UDim2.new(1, -20, 1, -(PREF_TAB_H + 3 + 20)),
                UDim2.new(0, 10, 0, PREF_TAB_H + 3 + 10),
                BG, 1
            )

            local prefTabBtn = NewBtn(PrefTabBar, UDim2.new(0, 96, 1, 0), UDim2.new(0, 18, 0, 0), BG, 1)
            local prefTabLbl = NewLabel(prefTabBtn, "Preferences", 13, ACCENT, true)
            prefTabLbl.Name = "SectionTitle"
            prefTabLbl.Size = UDim2.new(1, 0, 1, 0)
            prefTabLbl.TextXAlignment = Enum.TextXAlignment.Center

            local prefTabLine = NewFrame(PreferencesPage, UDim2.new(0, 96, 0, 2),
                UDim2.new(0, 18, 0, PREF_TAB_H - 2), ACCENT)
            Corner(prefTabLine, 1)
            table.insert(accentFills, prefTabLine)

            prefScroll = NewScroll(PrefContentRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
        end

        prefScroll.ClipsDescendants = true

        local ignoreCard = NewFrame(prefScroll, UDim2.new(0.46, 0, 0, 620), UDim2.new(0, 1, 0, 3), PANEL)
        Corner(ignoreCard, 8)
        Stroke(ignoreCard, STROKE, 1)

        local ignoreTitle = NewLabel(ignoreCard, "Ignore Players", 13, TEXT, true)
        ignoreTitle.Name = "SectionTitle"
        ignoreTitle.Size = UDim2.new(1, 0, 0, 30)
        ignoreTitle.TextXAlignment = Enum.TextXAlignment.Center

        local ignoreDesc = NewLabel(ignoreCard,
            "Los jugadores ignorados se excluyen de ESP, aimbot, silent aim, insta kill, kill aura y hitbox expander.",
            11, DIM)
        ignoreDesc.Position = UDim2.new(0, 10, 0, 36)
        ignoreDesc.Size = UDim2.new(1, -20, 0, 32)
        ignoreDesc.TextWrapped = true
        ignoreDesc.TextYAlignment = Enum.TextYAlignment.Top

        local ignoredCountLbl = NewLabel(ignoreCard, "Ignored: 0", 11, ACCENT, true, Enum.TextXAlignment.Right)
        ignoredCountLbl.Name = "SectionTitle"
        ignoredCountLbl.Position = UDim2.new(0, 10, 0, 70)
        ignoredCountLbl.Size = UDim2.new(1, -20, 0, 18)

        local searchWrap = NewFrame(ignoreCard, UDim2.new(1, -16, 0, 30), UDim2.new(0, 8, 0, 96),
            Color3.fromRGB(15, 15, 20))
        Corner(searchWrap, 5)
        Stroke(searchWrap, STROKE2, 1)

        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, -16, 1, 0)
        searchBox.Position = UDim2.new(0, 8, 0, 0)
        searchBox.BackgroundTransparency = 1
        searchBox.BorderSizePixel = 0
        searchBox.TextColor3 = TEXT
        searchBox.PlaceholderColor3 = DIM
        searchBox.PlaceholderText = "Buscar jugador por nombre o display..."
        searchBox.Text = ""
        searchBox.TextSize = 11
        searchBox.TextScaled = true
        local sFit = Instance.new("UITextSizeConstraint")
        sFit.MaxTextSize = 11
        sFit.MinTextSize = 8
        sFit.Parent = searchBox
        searchBox.Font = Enum.Font.Gotham
        searchBox.ClearTextOnFocus = false
        searchBox.Parent = searchWrap

        local buttonRow = NewFrame(ignoreCard, UDim2.new(1, -16, 0, 32), UDim2.new(0, 8, 0, 132), BG, 1)

        local refreshBtn = NewBtn(buttonRow, UDim2.new(0.5, -4, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(36, 36, 48))
        Corner(refreshBtn, 6)
        Stroke(refreshBtn, STROKE2, 1)
        local refreshLbl = NewLabel(refreshBtn, "Refresh List", 11, TEXT, false, Enum.TextXAlignment.Center)
        refreshLbl.Size = UDim2.new(1, 0, 1, 0)

        local clearBtn = NewBtn(buttonRow, UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 4, 0, 0), Color3.fromRGB(36, 36, 48))
        Corner(clearBtn, 6)
        Stroke(clearBtn, STROKE2, 1)
        local clearLbl = NewLabel(clearBtn, "Clear Ignored", 11, TEXT, false, Enum.TextXAlignment.Center)
        clearLbl.Size = UDim2.new(1, 0, 1, 0)

        local playersList = NewScroll(ignoreCard, UDim2.new(1, -16, 1, -180), UDim2.new(0, 8, 0, 172),
            Color3.fromRGB(15, 15, 20))
        playersList.ScrollBarThickness = 4
        playersList.ScrollBarImageColor3 = ACCENT
        Corner(playersList, 6)
        Stroke(playersList, STROKE2, 1)

        local playersLayout = Instance.new("UIListLayout", playersList)
        playersLayout.Padding = UDim.new(0, 4)
        playersLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function RefreshIgnoredCount()
            local total = 0
            for _ in pairs(NormalizeIgnoredPlayers()) do
                total = total + 1
            end
            ignoredCountLbl.Text = "Ignored: " .. total
        end

        local function RefreshIgnorePlayers()
            if not playersList or not playersList.Parent then return end
            playersList.ScrollBarImageColor3 = ACCENT

            for _, child in ipairs(playersList:GetChildren()) do
                if child:IsA("TextButton") or child.Name == "EmptyState" then
                    child:Destroy()
                end
            end

            local query = searchBox.Text:lower()
            local serverPlayers = Players:GetPlayers()
            table.sort(serverPlayers, function(a, b)
                return a.Name:lower() < b.Name:lower()
            end)

            local shown = 0
            for _, player in ipairs(serverPlayers) do
                if player ~= LP then
                    local haystack = (player.Name .. " " .. player.DisplayName):lower()
                    if query == "" or string.find(haystack, query, 1, true) then
                        shown = shown + 1

                        local row = NewBtn(playersList, UDim2.new(1, -8, 0, 40), nil, Color3.fromRGB(32, 32, 42), 1)
                        row.Name = "PlayerRow"
                        Corner(row, 5)

                        local ignored = IsIgnoredPlayer(player)
                        local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7),
                            Color3.fromRGB(36, 36, 48))
                        Corner(cbBg, 3)
                        Stroke(cbBg, STROKE2, 1)

                        local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
                        cbCheck.Size = UDim2.new(1, 0, 1, 0)

                        local nameLbl = NewLabel(row, player.Name, 12, TEXT, true)
                        nameLbl.Position = UDim2.new(0, 34, 0, 4)
                        nameLbl.Size = UDim2.new(1, -95, 0, 16)
                        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

                        local displayLbl = NewLabel(row, "Display: " .. player.DisplayName, 10, DIM)
                        displayLbl.Position = UDim2.new(0, 34, 0, 20)
                        displayLbl.Size = UDim2.new(1, -95, 0, 14)
                        displayLbl.TextTruncate = Enum.TextTruncate.AtEnd

                        local statusLbl = NewLabel(row, "", 10, DIM, true, Enum.TextXAlignment.Right)
                        statusLbl.Position = UDim2.new(1, -60, 0, 0)
                        statusLbl.Size = UDim2.new(0, 50, 1, 0)

                        local function ApplyRowState()
                            cbCheck.Visible = ignored
                            statusLbl.Text = ignored and "Ignored" or "Active"
                            statusLbl.TextColor3 = ignored and ACCENT or DIM
                            Tw(cbBg, 0.1, "Quad", "Out", {
                                BackgroundColor3 = ignored and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                            })
                        end

                        row.MouseButton1Click:Connect(function()
                            ignored = not ignored
                            SetIgnoredPlayer(player.Name, ignored)
                            SaveUI()
                            RefreshIgnoredCount()
                            ApplyRowState()
                        end)

                        row.MouseEnter:Connect(function()
                            Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 })
                        end)
                        row.MouseLeave:Connect(function()
                            Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 })
                        end)

                        ApplyRowState()
                    end
                end
            end

            if shown == 0 then
                local emptyLbl = NewLabel(playersList,
                    query ~= "" and "No hay jugadores que coincidan." or "No hay otros jugadores en el servidor.",
                    11, DIM, false, Enum.TextXAlignment.Center)
                emptyLbl.Name = "EmptyState"
                emptyLbl.Size = UDim2.new(1, -8, 0, 32)
            end

            RefreshIgnoredCount()
        end

        searchBox:GetPropertyChangedSignal("Text"):Connect(RefreshIgnorePlayers)

        refreshBtn.MouseButton1Click:Connect(RefreshIgnorePlayers)
        refreshBtn.MouseEnter:Connect(function()
            Tw(refreshBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
        end)
        refreshBtn.MouseLeave:Connect(function()
            Tw(refreshBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
        end)

        clearBtn.MouseButton1Click:Connect(function()
            _G.PREFERENCES_CFG.IgnoredPlayers = {}
            SaveUI()
            RefreshIgnorePlayers()
        end)
        clearBtn.MouseEnter:Connect(function()
            Tw(clearBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
        end)
        clearBtn.MouseLeave:Connect(function()
            Tw(clearBtn, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
        end)

        table.insert(_G.FLUX_CONNS, Players.PlayerAdded:Connect(RefreshIgnorePlayers))
        table.insert(_G.FLUX_CONNS, Players.PlayerRemoving:Connect(function(player)
            if IsIgnoredPlayer(player) then
                RefreshIgnoredCount()
            end
            RefreshIgnorePlayers()
        end))

        _G.FLUX_PREFERENCES_REFRESH = RefreshIgnorePlayers
        RefreshIgnorePlayers()
    end
end


-- Draggable already handled at initialization


-- Resize Logic
do
    local Handle = NewBtn(Root, UDim2.new(0, 24, 0, 24), UDim2.new(1, 0, 1, 0), Color3.new(1, 1, 1), 1)
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.ZIndex = 200

    local hIcon = Instance.new("Frame")
    hIcon.Size = UDim2.new(0, 12, 0, 12)
    hIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    hIcon.BackgroundTransparency = 1
    hIcon.ZIndex = 201
    hIcon.Parent = Handle

    local clipper = Instance.new("Frame")
    clipper.Name = "Clipper"
    clipper.Size = UDim2.new(0, 14, 0, 14)
    clipper.Position = UDim2.new(0.5, -7, 0.5, -7)
    clipper.BackgroundTransparency = 1
    clipper.ClipsDescendants = true
    clipper.ZIndex = 201
    clipper.Parent = Handle

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 24, 0, 24)
    circle.Position = UDim2.new(1, -24, 1, -24)
    circle.BackgroundTransparency = 1
    circle.ZIndex = 202
    circle.Parent = clipper

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Transparency = 0.8
    stroke.Parent = circle
    Corner(circle, 12)

    local resizing = false
    local rStart = nil
    local rW, rH = 0, 0

    Handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            rStart = inp.Position
            rW = Root.AbsoluteSize.X
            rH = Root.AbsoluteSize.Y
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - rStart
            curW = math.clamp(rW + d.X, 620, 1100)
            curH = math.clamp(rH + d.Y, 380, 700)
            Tw(Root, 0.04, "Linear", "Out", { Size = UDim2.new(0, curW, 0, curH) })
        end
    end)

    Handle.MouseEnter:Connect(function() Tw(stroke, 0.09, "Quad", "Out", { Transparency = 0 }) end)
    Handle.MouseLeave:Connect(function()
        if not resizing then
            Tw(stroke, 0.09, "Quad", "Out", { Transparency = 0.8 })
        end
    end)
end

-- ══ UI THEME SYSTEM ══
-- Forward declarations so applyUITheme can reference these (populated later in Settings section)

local stLines = {}
local stBtns = {}
local activeStIdx = 1

local vsLines = {}
local vsBtns = {}
local activeVsIdx = 1

local UI_THEMES = {
    ["Default"]     = { accent = Color3.fromRGB(238, 240, 255), side = Color3.fromRGB(15, 15, 20), bg = Color3.fromRGB(20, 20, 26), gradBot = nil },
    ["Dark Blue"]   = { accent = Color3.fromRGB(100, 190, 255), side = Color3.fromRGB(12, 12, 20), bg = Color3.fromRGB(14, 16, 26), gradBot = Color3.fromRGB(50, 140, 255) },
    ["Dark Purple"] = { accent = Color3.fromRGB(210, 130, 255), side = Color3.fromRGB(16, 10, 24), bg = Color3.fromRGB(18, 12, 30), gradBot = Color3.fromRGB(180, 50, 240) },
    ["Dark White"]  = { accent = Color3.fromRGB(230, 235, 255), side = Color3.fromRGB(18, 18, 25), bg = Color3.fromRGB(22, 22, 30), gradBot = Color3.fromRGB(255, 255, 255) },
}
local currentUITheme = "Default"

local function applyUITheme(name)
    local t = UI_THEMES[name]
    if not t then return end
    currentUITheme = name
    local oldAccent = ACCENT
    ACCENT = t.accent

    -- Smooth Blend Transition (Cinematic Fade)
    local dur = 1.2
    local ease = "Exponential"

    Tw(Sidebar, dur, ease, "Out", { BackgroundColor3 = t.side })
    Tw(RightBox, dur, ease, "Out", { BackgroundColor3 = t.bg })

    if t.gradBot then
        local sideSeq     = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.side),
            ColorSequenceKeypoint.new(0.4, t.side:Lerp(t.gradBot, 0.35)),
            ColorSequenceKeypoint.new(1, t.gradBot)
        })
        local rightSeq    = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.bg),
            ColorSequenceKeypoint.new(0.4, t.bg:Lerp(t.gradBot, 0.35)),
            ColorSequenceKeypoint.new(1, t.gradBot)
        })
        sideGrad.Color    = sideSeq
        rightGrad.Color   = rightSeq
        sideGrad.Enabled  = true
        rightGrad.Enabled = true
    else
        sideGrad.Enabled  = false
        rightGrad.Enabled = false
    end

    if currentNav then
        pcall(function()
            -- Use instant update (0s) to avoid race condition with tab-switch tweens
            currentNav.sym.ImageColor3 = t.accent
            currentNav.lbl.TextColor3 = t.accent
            currentNav.dot.BackgroundColor3 = t.accent
        end)
    end

    for _, f in ipairs(accentFills) do
        pcall(function()
            if f and f.Parent then
                if f:IsA("UIGradient") then
                    f.Color = ColorSequence.new(t.side, t.bg)
                else
                    Tw(f, dur, ease, "Out", { BackgroundColor3 = t.accent })
                end
            end
        end)
    end

    for _, v in ipairs(SG:GetDescendants()) do
        pcall(function()
            if v and v.Parent then
                if v:IsA("TextLabel") then
                    if v.Name == "SectionTitle" or v.TextColor3 == oldAccent then
                        Tw(v, dur, ease, "Out", { TextColor3 = t.accent })
                    end
                elseif v:IsA("ScrollingFrame") then
                    Tw(v, dur, ease, "Out", { ScrollBarImageColor3 = t.accent })
                elseif v:IsA("Frame") and (v.Name == "Fill" or v.BackgroundColor3 == oldAccent) then
                    Tw(v, dur, ease, "Out", { BackgroundColor3 = t.accent })
                end
            end
        end)
    end

    for _, ul in ipairs(tabLines) do pcall(function() Tw(ul, dur, ease, "Out", { BackgroundColor3 = t.accent }) end) end
    if tabBtns[activeTabIdx] then pcall(function() Tw(tabBtns[activeTabIdx].lbl, dur, ease, "Out", { TextColor3 = t.accent }) end) end
    for _, ul in ipairs(stLines) do pcall(function() Tw(ul, dur, ease, "Out", { BackgroundColor3 = t.accent }) end) end
    if stBtns[activeStIdx] then pcall(function() Tw(stBtns[activeStIdx].lbl, dur, ease, "Out", { TextColor3 = t.accent }) end) end
    for _, ul in ipairs(vsLines) do pcall(function() Tw(ul, dur, ease, "Out", { BackgroundColor3 = t.accent }) end) end
    if vsBtns[activeVsIdx] then pcall(function() Tw(vsBtns[activeVsIdx].lbl, dur, ease, "Out", { TextColor3 = t.accent }) end) end
    if _G.FLUX_CONFIG_TAB_THEME_SYNC then pcall(_G.FLUX_CONFIG_TAB_THEME_SYNC) end

    for _, v in ipairs(SG:GetDescendants()) do
        pcall(function()
            if v and v.Parent and v:IsA("TextLabel") and v.Text == "✓" then
                Tw(v, dur, ease, "Out", { TextColor3 = t.accent })
            end
        end)
    end
    -- Notifications
    for _, dat in pairs(activeNotifs) do
        pcall(function()
            Tw(dat.t, dur, ease, "Out", { TextColor3 = t.accent })
            Tw(dat.b, dur, ease, "Out", { BackgroundColor3 = t.accent })
        end)
    end
    -- Watermark
    pcall(function() Tw(wmIcon, dur, ease, "Out", { ImageColor3 = t.accent }) end)
    -- Keybind HUD (lives in separate ScreenGui, must be updated manually)
    if _G.FLUX_KB_HUD_ACCENT_UPDATE then _G.FLUX_KB_HUD_ACCENT_UPDATE() end
    if _G.FLUX_PREFERENCES_REFRESH then pcall(_G.FLUX_PREFERENCES_REFRESH) end
end

-- ══════════════════ CATEGORY CONTENT: VISUALS ══════════════════
local VisualsPage = navPages["Visuals"]
local VS_TAB_H = 44
local VS_TabBar = NewFrame(VisualsPage, UDim2.new(1, 0, 0, VS_TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
-- MakeDraggable(VS_TabBar, Root)
local VS_TabSep = NewFrame(VisualsPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, VS_TAB_H), STROKE)
local VS_Content = NewFrame(VisualsPage, UDim2.new(1, -20, 1, -(VS_TAB_H + 20)), UDim2.new(0, 10, 0, VS_TAB_H + 10), BG,
    1)

local VS_TABS = { "Player Visuals", "World Visuals" }
local vsPages = {}

local vs_x = 18
for i, name in ipairs(VS_TABS) do
    local tw = (i == 1 and 110 or 110)
    local tb = NewBtn(VS_TabBar, UDim2.new(0, tw, 1, 0), UDim2.new(0, vs_x, 0, 0), BG, 1)
    local tl = NewLabel(tb, name, 13, i == 1 and ACCENT or DIM, i == 1)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Center

    local ul = NewFrame(VisualsPage, UDim2.new(0, tw, 0, 2), UDim2.new(0, vs_x, 0, VS_TAB_H - 2), ACCENT)
    ul.Visible = i == 1
    Corner(ul, 1)

    local page = NewScroll(VS_Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    page.Visible = (i == 1)

    vsPages[i] = page
    vsBtns[i] = { btn = tb, lbl = tl }
    vsLines[i] = ul
    vs_x = vs_x + tw + 14

    tb.MouseButton1Click:Connect(function()
        if activeVsIdx == i then return end
        vsBtns[activeVsIdx].lbl.TextColor3 = DIM
        vsBtns[activeVsIdx].lbl.Font = Enum.Font.Gotham
        vsLines[activeVsIdx].Visible = false
        vsPages[activeVsIdx].Visible = false

        activeVsIdx = i
        tl.TextColor3 = ACCENT
        tl.Font = Enum.Font.GothamBold
        ul.Visible = true
        page.Visible = true
    end)
end

-- Player Visuals Content
do
    local espPage = vsPages[1]
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.Parent = NewFrame(espPage, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), BG, 1)


    local espCard = NewFrame(espPage, UDim2.new(0.46, 0, 0, 620), UDim2.new(0, 1, 0, 3), PANEL)
    Corner(espCard, 8)
    Stroke(espCard, STROKE, 1)

    local espTitle = NewLabel(espCard, "ESP Options", 12, TEXT, true)
    espTitle.Name = "SectionTitle"
    espTitle.Size = UDim2.new(1, 0, 0, 30)
    espTitle.TextXAlignment = Enum.TextXAlignment.Center

    local espContent = NewFrame(espCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
    local espList = Instance.new("UIListLayout")
    espList.Padding = UDim.new(0, 2)
    espList.Parent = espContent

    -- ESP Config Placeholder
    _G.ESP_CFG = {
        Enabled = false,
        Names = false,
        DisplayNames = false,
        Tools = false,
        Distance = false,
        HealthBar = false,
        HealthText = false,
        Skeleton = false,
        Chams = false,
        Snaplines = false,
        OffScreen = false,
        HealthColor1 = Color3.fromRGB(255, 0, 0),
        HealthColor2 = Color3.fromRGB(0, 255, 0),
        Boxes = false,
        BoxFill = false,
        BoxColor = Color3.new(1, 1, 1),
        FillColor = Color3.new(1, 1, 1),
        TracerOrigin = "Bottom",
        FontSize = 11,
        FontName = "GothamBold",
        MaxDistance = 500,
        IgnoreTeam = false,
        LocalGunCham = false,
        LocalGunChamColor1 = Color3.fromRGB(0, 255, 255)
    }

    AddESPSetting(espContent, "Enabled", false, 0, true,
        function(v, c, k)
            _G.ESP_CFG.Enabled = v; if k then _G.ESP_CFG.Keybind = k end
        end)
    AddESPSetting(espContent, "Enable Bots", false, 0, false, function(v)
        _G.ESP_CFG.Bots = v
        if not v then
            -- Force cleanup bot visuals when disabled
            if _G.ESP_CACHE then
                for target, e in pairs(_G.ESP_CACHE) do
                    if not Players:GetPlayerFromCharacter(target) then
                        e.FRM.Visible = false
                        if e.CHAM then
                            e.CHAM:Destroy(); e.CHAM = nil
                        end
                        if e.TCHAM then
                            e.TCHAM:Destroy(); e.TCHAM = nil
                        end
                    end
                end
            end
        end
    end)

    if IsMurderVsSheriff() or IsDuelist() then
        AddESPSetting(espContent, "Ignore Team", false, 0, false, function(v) _G.ESP_CFG.IgnoreTeam = v end)
    end
    AddESPSetting(espContent, "Player Names", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Names = v; if c then _G.ESP_CFG.NameColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Display Names", false, 0, false, function(v) _G.ESP_CFG.DisplayNames = v end)
    AddESPSetting(espContent, "Equipped Tool", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Tools = v; if c then _G.ESP_CFG.ToolColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Distance", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Distance = v; if c then _G.ESP_CFG.DistColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Health Bars", false, 2, false,
        function(v, c)
            _G.ESP_CFG.HealthBar = v; if c then
                _G.ESP_CFG.HealthColor1 = c[1]; _G.ESP_CFG.HealthColor2 = c[2]
            end
        end, { Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0) })
    AddESPSetting(espContent, "Health Text", false, 0, false, function(v) _G.ESP_CFG.HealthText = v end)
    AddESPSetting(espContent, "Skeleton", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Skeleton = v; if c then _G.ESP_CFG.SkelColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Chams", false, 2, false,
        function(v, c)
            _G.ESP_CFG.Chams = v; if c then
                _G.ESP_CFG.ChamColor1 = c[1]; _G.ESP_CFG.ChamColor2 = c[2]
            end
        end, { Color3.new(1, 1, 1), Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Tool Chams", false, 2, false,
        function(v, c)
            _G.ESP_CFG.ToolChams = v; if c then
                _G.ESP_CFG.ToolChamColor1 = c[1]; _G.ESP_CFG.ToolChamColor2 = c[2]
            end
        end, { Color3.new(1, 1, 1), Color3.new(1, 1, 1) })
    if IsDuelist() then
        AddESPSetting(espContent, "Local Gun Cham", false, 1, false,
            function(v, c)
                _G.ESP_CFG.LocalGunCham = v; if c then
                    _G.ESP_CFG.LocalGunChamColor1 = c[1]
                end
            end, { Color3.fromRGB(0, 255, 255) })
    end
    AddESPSetting(espContent, "Snaplines", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Snaplines = v; if c then _G.ESP_CFG.SnapColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(espContent, "Off-Screen Lines", false, 0, false, function(v) _G.ESP_CFG.OffScreen = v end)

    -- Player Boxes Card
    local pbCard = NewFrame(espPage, UDim2.new(0.52, -4, 0, 140), UDim2.new(0.48, 1, 0, 3), PANEL)
    Corner(pbCard, 8)
    Stroke(pbCard, STROKE, 1)

    local pbTitle = NewLabel(pbCard, "Player Boxes", 12, TEXT, true)
    pbTitle.Name = "SectionTitle"
    pbTitle.Size = UDim2.new(1, 0, 0, 30)
    pbTitle.TextXAlignment = Enum.TextXAlignment.Center

    local pbContent = NewFrame(pbCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
    local pbList = Instance.new("UIListLayout", pbContent)
    pbList.Padding = UDim.new(0, 2)

    AddESPSetting(pbContent, "Boxes", false, 1, false,
        function(v, c)
            _G.ESP_CFG.Boxes = v; if c then _G.ESP_CFG.BoxColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(pbContent, "Fill Boxes", false, 1, false,
        function(v, c)
            _G.ESP_CFG.BoxFill = v; if c then _G.ESP_CFG.FillColor = c[1] end
        end, { Color3.new(1, 1, 1) })
    AddESPSetting(pbContent, "Animated Boxes", false, 0, false,
        function(v)
            _G.ESP_CFG.AnimBoxFill = v
        end)

    -- New Visual Settings Card (Moved Down)
    local vsCard = NewFrame(espPage, UDim2.new(0.52, -4, 0, 260), UDim2.new(0.48, 1, 0, 153), PANEL)
    Corner(vsCard, 8)
    Stroke(vsCard, STROKE, 1)

    local vsTitle = NewLabel(vsCard, "Player Visual Settings", 12, TEXT, true)
    vsTitle.Name = "SectionTitle"
    vsTitle.Size = UDim2.new(1, 0, 0, 30)
    vsTitle.TextXAlignment = Enum.TextXAlignment.Center

    local vsContent = NewFrame(vsCard, UDim2.new(1, -20, 1, -44), UDim2.new(0, 10, 0, 36), BG, 1)
    local vsList = Instance.new("UIListLayout", vsContent)
    vsList.Padding = UDim.new(0, 8)

    -- Font Dropdown
    local fontRow = NewFrame(vsContent, UDim2.new(1, 0, 0, 32), nil, Color3.fromRGB(32, 32, 44))
    Corner(fontRow, 6)
    Stroke(fontRow, STROKE2, 1)
    local fontSel = NewLabel(fontRow, "Text Font: GothamBold", 11, TEXT)
    fontSel.Position = UDim2.new(0, 10, 0, 0)
    fontSel.Size = UDim2.new(1, -30, 1, 0)
    local fontArr = Instance.new("ImageLabel", fontRow)
    fontArr.Size = UDim2.new(0, 12, 0, 12)
    fontArr.Position = UDim2.new(1, -22, 0.5, -6)
    fontArr.BackgroundTransparency = 1
    fontArr.Image = "rbxassetid://6034818372"
    fontArr.ImageColor3 = DIM

    local FONT_OPTS = { "GothamBold", "Gotham", "Code", "Roboto", "Arcade", "SciFi" }
    local fontOpen = false
    local fontPop = NewFrame(vsCard, UDim2.new(1, -20, 0, 0), UDim2.new(0, 10, 0, 36 + 36), Color3.fromRGB(28, 28, 38))
    fontPop.ZIndex = 100
    fontPop.ClipsDescendants = true
    fontPop.Visible = false
    Corner(fontPop, 6)
    Stroke(fontPop, STROKE2, 1)
    local fontPList = Instance.new("UIListLayout", fontPop)

    for _, f in ipairs(FONT_OPTS) do
        local b = NewBtn(fontPop, UDim2.new(1, 0, 0, 26), nil, Color3.fromRGB(45, 45, 60), 1)
        b.ZIndex = 101
        local l = NewLabel(b, f, 11, TEXT)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.Size = UDim2.new(1, -10, 1, 0)
        l.ZIndex = 102
        b.MouseEnter:Connect(function() Tw(b, 0.07, "Quad", "Out", { BackgroundTransparency = 0.5 }) end)
        b.MouseLeave:Connect(function() Tw(b, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)
        b.MouseButton1Click:Connect(function()
            fontSel.Text = "Text Font: " .. f
            _G.ESP_CFG.FontName = f
            fontOpen = false
            Tw(fontPop, 0.15, "Quad", "Out", { Size = UDim2.new(1, -20, 0, 0) })
            task.delay(0.16, function() fontPop.Visible = false end)
            Tw(fontArr, 0.15, "Quad", "Out", { Rotation = 0 })
        end)
    end

    local fontBtn = NewBtn(fontRow, UDim2.new(1, 0, 1, 0), nil, BG, 1)
    fontBtn.MouseButton1Click:Connect(function()
        fontOpen = not fontOpen
        if fontOpen then
            fontPop.Size = UDim2.new(1, -20, 0, 0)
            fontPop.Visible = true
            Tw(fontPop, 0.18, "Quad", "Out", { Size = UDim2.new(1, -20, 0, #FONT_OPTS * 26) })
            Tw(fontArr, 0.18, "Quad", "Out", { Rotation = 180 })
        else
            Tw(fontPop, 0.15, "Quad", "Out", { Size = UDim2.new(1, -20, 0, 0) })
            task.delay(0.16, function() fontPop.Visible = false end)
            Tw(fontArr, 0.15, "Quad", "Out", { Rotation = 0 })
        end
    end)

    -- Size Slider
    local function AddVSSlider(parent, label, min, max, default, suffix, callback)
        local row = NewFrame(parent, UDim2.new(1, 0, 0, 42), nil, BG, 1)
        local top = NewFrame(row, UDim2.new(1, 0, 0, 16), nil, BG, 1)
        NewLabel(top, label, 11, TEXT).Size = UDim2.new(0.6, 0, 1, 0)
        local valL = NewLabel(top, tostring(default) .. (suffix or ""), 11, ACCENT, false, Enum.TextXAlignment.Right)
        valL.Size = UDim2.new(0.4, 0, 1, 0)
        valL.Position = UDim2.new(0.6, 0, 0, 0)

        local trackH = IS_MOBILE and 32 or 24
        local track = NewBtn(row, UDim2.new(1, 0, 0, trackH), UDim2.new(0, 0, 0, 20), BG, 1)

        local trackBG = NewFrame(track, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0.5, -2), Color3.fromRGB(45, 45, 55))
        Corner(trackBG, 2)

        local fill = NewFrame(trackBG, UDim2.new((default - min) / (max - min), 0, 1, 0), nil, ACCENT)
        Corner(fill, 2)
        accentFills[#accentFills + 1] = fill

        local knobS = IS_MOBILE and 18 or 12
        local knob = NewFrame(track, UDim2.new(0, knobS, 0, knobS),
            UDim2.new((default - min) / (max - min), -knobS / 2, 0.5, -knobS / 2),
            Color3.new(1, 1, 1))
        Corner(knob, knobS / 2)

        local dragging = false
        local function update(inputX)
            local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + rel * (max - min))
            valL.Text = tostring(val) .. (suffix or "")
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -knobS / 2, 0.5, -knobS / 2)
            callback(val)
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                getgenv()._CEN_SLD_ACTIVE = true
                dragging = true; update(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                getgenv()._CEN_SLD_ACTIVE = false
            end
        end)
    end

    AddVSSlider(vsContent, "Text Size", 8, 24, 11, "", function(v) _G.ESP_CFG.FontSize = v end)
    AddVSSlider(vsContent, "Max Render Distance", 50, 2000, 500, "st", function(v) _G.ESP_CFG.MaxDistance = v end)


    -- Tracer Origin Dropdown (Matching Font Style)
    local tracerRow = NewFrame(vsContent, UDim2.new(1, 0, 0, 32), nil, Color3.fromRGB(32, 32, 44))
    Corner(tracerRow, 6)
    Stroke(tracerRow, STROKE2, 1)
    local tracerSel = NewLabel(tracerRow, "Tracer Origin: " .. _G.ESP_CFG.TracerOrigin, 11, TEXT)
    tracerSel.Position = UDim2.new(0, 10, 0, 0)
    tracerSel.Size = UDim2.new(1, -30, 1, 0)
    local tracerArr = Instance.new("ImageLabel", tracerRow)
    tracerArr.Size = UDim2.new(0, 12, 0, 12)
    tracerArr.Position = UDim2.new(1, -22, 0.5, -6)
    tracerArr.BackgroundTransparency = 1
    tracerArr.Image = "rbxassetid://6034818372"
    tracerArr.ImageColor3 = DIM

    local TRACER_OPTS = { "Bottom", "Center", "Top", "Mouse" }
    local tracerOpen = false
    local tracerPop = NewFrame(vsCard, UDim2.new(1, -20, 0, 0), UDim2.new(0, 10, 0, 212), Color3.fromRGB(28, 28, 38))
    tracerPop.ZIndex = 110
    tracerPop.ClipsDescendants = true
    tracerPop.Visible = false
    Corner(tracerPop, 6)
    Stroke(tracerPop, STROKE2, 1)
    local tracerPList = Instance.new("UIListLayout", tracerPop)

    for _, t in ipairs(TRACER_OPTS) do
        local b = NewBtn(tracerPop, UDim2.new(1, 0, 0, 26), nil, Color3.fromRGB(45, 45, 60), 1)
        b.ZIndex = 111
        local l = NewLabel(b, t, 11, TEXT)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.Size = UDim2.new(1, -10, 1, 0)
        l.ZIndex = 112
        b.MouseEnter:Connect(function() Tw(b, 0.07, "Quad", "Out", { BackgroundTransparency = 0.5 }) end)
        b.MouseLeave:Connect(function() Tw(b, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)
        b.MouseButton1Click:Connect(function()
            tracerSel.Text = "Tracer Origin: " .. t
            _G.ESP_CFG.TracerOrigin = t
            tracerOpen = false
            Tw(tracerPop, 0.15, "Quad", "Out", { Size = UDim2.new(1, -20, 0, 0) })
            task.delay(0.16, function() tracerPop.Visible = false end)
            Tw(tracerArr, 0.15, "Quad", "Out", { Rotation = 0 })
            NOTIFY("Visuals", "Snapline Position: " .. t, 1.5)
        end)
    end

    local tracerBtn = NewBtn(tracerRow, UDim2.new(1, 0, 1, 0), nil, BG, 1)
    tracerBtn.MouseButton1Click:Connect(function()
        tracerOpen = not tracerOpen
        if tracerOpen then
            tracerPop.Size = UDim2.new(1, -20, 0, 0)
            tracerPop.Visible = true
            Tw(tracerPop, 0.18, "Quad", "Out", { Size = UDim2.new(1, -20, 0, #TRACER_OPTS * 26) })
            Tw(tracerArr, 0.18, "Quad", "Out", { Rotation = 180 })
        else
            Tw(tracerPop, 0.15, "Quad", "Out", { Size = UDim2.new(1, -20, 0, 0) })
            task.delay(0.16, function() tracerPop.Visible = false end)
            Tw(tracerArr, 0.15, "Quad", "Out", { Rotation = 0 })
        end
    end)
end

-- [ ESP ENGINE ]
local ESP_HOLDER = Instance.new("ScreenGui")
ESP_HOLDER.Name = "ESP_HOLDER"
ESP_HOLDER.IgnoreGuiInset = true
ESP_HOLDER.DisplayOrder = -1100
pcall(function() ESP_HOLDER.Parent = game:GetService("CoreGui") end)
if not ESP_HOLDER.Parent then ESP_HOLDER.Parent = PG end

local CACHE = {}
local R15_BONES = {
    { "Head",         "UpperTorso" }, { "UpperTorso", "LowerTorso" }, { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" }, { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" }, { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg",  "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" }, { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" }
}
local R6_BONES = {
    { "Head",  "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
    { "Torso", "Left Leg" }, { "Torso", "Right Leg" }
}
if _G.ESP_CACHE then
    for _, obj in pairs(_G.ESP_CACHE) do
        if obj.FRM then obj.FRM:Destroy() end
        if obj.CHAM then obj.CHAM:Destroy() end
        if obj.TCHAM then obj.TCHAM:Destroy() end
    end
end
local CACHE = {}
_G.ESP_CACHE = CACHE
local LOCAL_GUN_CACHE = { Mats = {}, Colors = {}, Highlights = {}, LastTool = nil }

local function MK_ESP(p)
    local E = {
        FRM = Instance.new("Frame", ESP_HOLDER),
        NAME = NewLabel(nil, "", 10, Color3.new(1, 1, 1), true, Enum.TextXAlignment.Center),
        DIST = NewLabel(nil, "", 9, Color3.new(1, 1, 1), false, Enum.TextXAlignment.Center),
        WEAP = NewLabel(nil, "", 9, Color3.new(1, 1, 1), false, Enum.TextXAlignment.Center),
        BOX = Instance.new("Frame"),
        FILL = Instance.new("Frame"),
        BAR_BG = Instance.new("Frame"),
        BAR_FL = Instance.new("Frame"),
        BAR_GRAD = Instance.new("UIGradient"),
        HEALTH_TXT = NewLabel(nil, "", 9, Color3.new(1, 1, 1), false, Enum.TextXAlignment.Center),
        SLINE = Instance.new("Frame"),
        SKEL = {}
    }
    E.SLINE.Parent = E.FRM
    E.FRM.BackgroundTransparency = 1
    E.FRM.Size = UDim2.new(1, 0, 1, 0)

    E.SLINE.BorderSizePixel = 0
    E.SLINE.ZIndex = -1
    E.SLINE.AnchorPoint = Vector2.new(0.5, 0.5)

    E.BOX.BackgroundTransparency = 1
    E.BOX.BorderSizePixel = 0
    E.BOX_LINES = {}
    for i = 1, 8 do
        local l = Instance.new("Frame", E.BOX)
        l.BorderSizePixel = 0
        l.ZIndex = 2
        local bg = Instance.new("Frame", l)
        bg.BackgroundColor3 = Color3.new(0, 0, 0)
        bg.BorderSizePixel = 0
        bg.ZIndex = 1
        E.BOX_LINES[i] = { l = l, bg = bg }
    end

    E.FILL.BorderSizePixel = 0
    E.FILL.BackgroundTransparency = 1 -- La base es invisible, las capas hacen la magia
    E.FILL.ZIndex = -1

    -- Capa 1 del campo de fuerza
    local ff1 = Instance.new("Frame", E.FILL)
    ff1.Name = "FF1"
    ff1.Size = UDim2.new(1, 0, 1, 0)
    ff1.BorderSizePixel = 0
    local grad1 = Instance.new("UIGradient", ff1)
    grad1.Name = "Gradient"
    grad1.Rotation = 45

    -- Capa 2 del campo de fuerza
    local ff2 = Instance.new("Frame", E.FILL)
    ff2.Name = "FF2"
    ff2.Size = UDim2.new(1, 0, 1, 0)
    ff2.BorderSizePixel = 0
    local grad2 = Instance.new("UIGradient", ff2)
    grad2.Name = "Gradient"
    grad2.Rotation = -45

    E.NAME.Parent = E.FRM
    E.DIST.Parent = E.FRM
    E.WEAP.Parent = E.FRM
    E.BOX.Parent = E.FRM
    E.FILL.Parent = E.FRM
    E.BAR_BG.Parent = E.FRM
    E.BAR_FL.Parent = E.BAR_BG
    E.BAR_GRAD.Parent = E.BAR_FL
    E.HEALTH_TXT.Parent = E.FRM

    E.BAR_BG.BackgroundColor3 = Color3.new(0, 0, 0)
    E.BAR_BG.BackgroundTransparency = 0.5
    E.BAR_BG.BorderSizePixel = 0
    E.BAR_FL.BorderSizePixel = 0
    E.BAR_GRAD.Rotation = 90

    for i = 1, 15 do
        local seg = Instance.new("Frame", E.FRM)
        seg.BorderSizePixel = 0
        seg.Visible = false
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        E.SKEL[i] = seg
    end

    CACHE[p] = E
    return E
end

_G.BOT_LIST = {}
task.spawn(function()
    while task.wait(1.5) do
        if getgenv().FLUX_SESSION ~= MySession then break end
        if _G.ESP_CFG and _G.ESP_CFG.Bots then
            local nb = {}
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Humanoid") then
                    local char = v.Parent
                    if char and char:IsA("Model") and char ~= LP.Character and not Players:GetPlayerFromCharacter(char) then
                        local hrp = char:FindFirstChild("HumanoidRootPart") or v.RootPart
                        if hrp then
                            table.insert(nb, char)
                        end
                    end
                end
            end
            _G.BOT_LIST = nb
        else
            _G.BOT_LIST = {}
        end
    end
end)

local function UPD_ESP()
    local cam = workspace.CurrentCamera
    local myTeamFolder = _G.MY_TEAM_CACHE

    -- Fast Target Collection
    local allPlayers = Players:GetPlayers()
    local valid_targets = {}

    local hasActiveMatch = (_G.ACTIVE_MATCH_PLAYERS and next(_G.ACTIVE_MATCH_PLAYERS) ~= nil)
    for i = 1, #allPlayers do
        local p = allPlayers[i]
        if p ~= LP and not IsIgnoredPlayer(p) then
            if not hasActiveMatch or _G.ACTIVE_MATCH_PLAYERS[p.Name] then
                if _G.ESP_CFG and _G.ESP_CFG.IgnoreTeam then
                    local isTeammate = false
                    if IsBronxDuels() or IsDuelist() then
                        local myTeam = LP:GetAttribute("DuelsTeam")
                        local theirTeam = p:GetAttribute("DuelsTeam")
                        local myMatch = LP:GetAttribute("DuelsMatchId")
                        local theirMatch = p:GetAttribute("DuelsMatchId")

                        if myMatch and theirMatch and myMatch == theirMatch then
                            if myTeam and theirTeam and myTeam == theirTeam then
                                isTeammate = true
                            end
                        end
                    else
                        isTeammate = myTeamFolder and myTeamFolder:FindFirstChild(p.Name)
                    end
                    if not isTeammate then
                        valid_targets[p] = true
                    end
                else
                    valid_targets[p] = true
                end
            end
        end
    end

    if _G.ESP_CFG.Bots then
        local bots = _G.BOT_LIST or {}
        for i = 1, #bots do
            valid_targets[bots[i]] = true
        end
    end

    -- Hide invalid entries (O(1) lookup)
    for target, E in pairs(CACHE) do
        if not valid_targets[target] then
            E.FRM.Visible = false
            if E.CHAM then E.CHAM.Enabled = false end
            if E.TCHAM then E.TCHAM.Enabled = false end
            if E.IsMaterialCham and E.CharCache and E.CharCache.Mats then
                for part, mat in pairs(E.CharCache.Mats) do
                    if part.Parent then part.Material = mat end
                end
                E.IsMaterialCham = false
            end
            if E.IsToolMatCham and E.CharCache and E.CharCache.ToolMats then
                for part, mat in pairs(E.CharCache.ToolMats) do
                    if part.Parent then part.Material = mat end
                end
                E.IsToolMatCham = false
            end
        end
    end

    local fontCache = Enum.Font[_G.ESP_CFG.FontName or "GothamBold"]
    local fontSizeCache = _G.ESP_CFG.FontSize or 11

    for p, _ in pairs(valid_targets) do
        local E = CACHE[p]
        if not E or not E.FRM or not E.FRM.Parent then
            if E and E.FRM then pcall(function() E.FRM:Destroy() end) end
            E = MK_ESP(p)
        end

        local isPlayer = p:IsA("Player")
        local C = isPlayer and p.Character or p

        -- Cache heavy lookups per-character
        if not E.CharCache or E.CharCache.C ~= C or not E.CharCache.HUM or not E.CharCache.H then
            local hum = C and C:FindFirstChildOfClass("Humanoid")
            E.CharCache = {
                C = C,
                HUM = hum,
                H = hum and hum.RootPart or
                    C and
                    (C:FindFirstChild("Torso") or C:FindFirstChild("UpperTorso") or C:FindFirstChild("HumanoidRootPart"))
            }
        end

        local HUM = E.CharCache.HUM
        local H = E.CharCache.H

        if C and H and HUM then
            local pos, vis = cam:WorldToViewportPoint(H.Position)
            local dist = (cam.CFrame.Position - H.Position).Magnitude

            local isAlive = (HUM.Health > 0.1) and
                (HUM:GetState() ~= Enum.HumanoidStateType.Dead) and
                (C:IsDescendantOf(workspace)) and
                not (C:GetAttribute("Downed") or C:GetAttribute("IsDead"))

            if _G.ESP_CFG.Enabled and isAlive then
                E.FRM.Visible = vis or (_G.ESP_CFG.OffScreen and _G.ESP_CFG.Snaplines)

                if E.FRM.Visible then
                    local fovFactor = 2 * math.tan(math.rad(cam.FieldOfView / 2))
                    local s_y = (H.Size.Y * 3.361 * cam.ViewportSize.Y) / (pos.Z * fovFactor)
                    local s_x = s_y * 0.7

                    if IsDuelist() then
                        -- Usar las medidas reales que obtuvimos del ExtentsSize para ajustar la caja
                        s_y = (5.91 * 1.05 * cam.ViewportSize.Y) / (pos.Z * fovFactor)
                        s_x = (3.00 * 1.05 * cam.ViewportSize.Y) / (pos.Z * fovFactor)
                    end

                    local x, y = pos.X - s_x / 2, pos.Y - s_y / 2

                    -- Chams
                    if _G.ESP_CFG.Chams then
                        if not E.CHAM or E.CHAM.Parent ~= C then
                            if E.CHAM then E.CHAM:Destroy() end
                            E.CHAM = Instance.new("Highlight", C)
                            E.CHAM.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        -- Aplicar Material ForceField (Efecto de la foto)
                        for _, part in ipairs(C:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                if not E.CharCache.Mats then E.CharCache.Mats = {} end
                                if not E.CharCache.Mats[part] then E.CharCache.Mats[part] = part.Material end
                                part.Material = Enum.Material.ForceField
                                part.Color = _G.ESP_CFG.ChamColor1 or Color3.new(1, 1, 1)
                            end
                        end
                        E.IsMaterialCham = true

                        -- Highlight Outline
                        E.CHAM.FillTransparency = 1 -- Transparente para que se vea el ForceField
                        E.CHAM.OutlineColor = _G.ESP_CFG.ChamColor2 or Color3.new(1, 1, 1)
                        E.CHAM.OutlineTransparency = 0
                        E.CHAM.Enabled = true
                    elseif E.CHAM or E.IsMaterialCham then
                        if E.CHAM then
                            E.CHAM:Destroy(); E.CHAM = nil
                        end
                        if E.IsMaterialCham and E.CharCache and E.CharCache.Mats then
                            for part, mat in pairs(E.CharCache.Mats) do
                                if part.Parent then part.Material = mat end
                            end
                            E.IsMaterialCham = false
                        end
                    end

                    -- Tool Chams
                    local tool = C:FindFirstChildOfClass("Tool")
                    if _G.ESP_CFG.ToolChams and tool then
                        if not E.TCHAM or E.TCHAM.Parent ~= tool then
                            if E.TCHAM then E.TCHAM:Destroy() end
                            E.TCHAM = Instance.new("Highlight", tool)
                            E.TCHAM.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        -- Aplicar Material ForceField a la herramienta
                        for _, part in ipairs(tool:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not E.CharCache.ToolMats then E.CharCache.ToolMats = {} end
                                if not E.CharCache.ToolMats[part] then E.CharCache.ToolMats[part] = part.Material end
                                part.Material = Enum.Material.ForceField
                                part.Color = _G.ESP_CFG.ToolChamColor1 or Color3.new(1, 1, 1)
                            end
                        end
                        E.IsToolMatCham = true

                        E.TCHAM.FillTransparency = 1
                        E.TCHAM.OutlineColor = _G.ESP_CFG.ToolChamColor2 or Color3.new(1, 1, 1)
                        E.TCHAM.OutlineTransparency = 0
                        E.TCHAM.Enabled = true
                    elseif E.TCHAM or E.IsToolMatCham then
                        if E.TCHAM then
                            E.TCHAM:Destroy(); E.TCHAM = nil
                        end
                        if E.IsToolMatCham and E.CharCache and E.CharCache.ToolMats then
                            for part, mat in pairs(E.CharCache.ToolMats) do
                                if part.Parent then part.Material = mat end
                            end
                            E.IsToolMatCham = false
                        end
                    end

                    if vis then
                        -- Names
                        E.NAME.Visible = _G.ESP_CFG.Names and dist <= _G.ESP_CFG.MaxDistance
                        if E.NAME.Visible then
                            E.NAME.Text = (isPlayer and _G.ESP_CFG.DisplayNames) and p.DisplayName or p.Name
                            if not isPlayer then E.NAME.Text = "[BOT] " .. p.Name end
                            E.NAME.Position = UDim2.new(0, x, 0, y - 16)
                            E.NAME.Size = UDim2.new(0, s_x, 0, 14)
                            E.NAME.TextColor3 = _G.ESP_CFG.NameColor or Color3.new(1, 1, 1)
                            if E.NAME.Font ~= fontCache then E.NAME.Font = fontCache end
                            if E.NAME.TextSize ~= fontSizeCache then E.NAME.TextSize = fontSizeCache end
                        end

                        -- Health Bar
                        local hp_per = math.clamp(HUM.Health / HUM.MaxHealth, 0, 1)
                        E.BAR_BG.Visible = _G.ESP_CFG.HealthBar and dist <= _G.ESP_CFG.MaxDistance
                        if E.BAR_BG.Visible then
                            E.BAR_BG.Position = UDim2.new(0, x - 6, 0, y)
                            E.BAR_BG.Size = UDim2.new(0, 3, 0, s_y)
                            E.BAR_FL.Size = UDim2.new(1, 0, hp_per, 0)
                            E.BAR_FL.Position = UDim2.new(0, 0, 1 - hp_per, 0)
                            E.BAR_GRAD.Color = ColorSequence.new(
                                _G.ESP_CFG.HealthColor1 or Color3.fromRGB(255, 0, 0),
                                _G.ESP_CFG.HealthColor2 or Color3.fromRGB(0, 255, 0))
                        end

                        -- Health Text
                        E.HEALTH_TXT.Visible = _G.ESP_CFG.HealthText and dist <= _G.ESP_CFG.MaxDistance
                        if E.HEALTH_TXT.Visible then
                            E.HEALTH_TXT.Text = math.floor(HUM.Health)
                            E.HEALTH_TXT.Position = UDim2.new(0, x - 40, 0, y + s_y * (1 - hp_per) - 6)
                            E.HEALTH_TXT.Size = UDim2.new(0, 30, 0, 12)
                            if E.HEALTH_TXT.Font ~= fontCache then E.HEALTH_TXT.Font = fontCache end
                            if E.HEALTH_TXT.TextSize ~= fontSizeCache then E.HEALTH_TXT.TextSize = fontSizeCache end
                        end

                        -- Distance
                        E.DIST.Visible = _G.ESP_CFG.Distance and dist <= _G.ESP_CFG.MaxDistance
                        if E.DIST.Visible then
                            E.DIST.Text = math.floor(dist) .. "m"
                            E.DIST.Position = UDim2.new(0, x, 0, y + s_y + 2)
                            E.DIST.Size = UDim2.new(0, s_x, 0, 12)
                            E.DIST.TextColor3 = _G.ESP_CFG.DistColor or Color3.new(1, 1, 1)
                            if E.DIST.Font ~= fontCache then E.DIST.Font = fontCache end
                            if E.DIST.TextSize ~= fontSizeCache then E.DIST.TextSize = fontSizeCache end
                        end

                        -- Tool Text
                        E.WEAP.Visible = _G.ESP_CFG.Tools and dist <= _G.ESP_CFG.MaxDistance
                        if E.WEAP.Visible then
                            E.WEAP.Text = tool and tool.Name or "None"
                            E.WEAP.Position = UDim2.new(0, x, 0, y + s_y + (E.DIST.Visible and 14 or 2))
                            E.WEAP.Size = UDim2.new(0, s_x, 0, 12)
                            E.WEAP.TextColor3 = _G.ESP_CFG.ToolColor or Color3.new(1, 1, 1)
                            if E.WEAP.Font ~= fontCache then E.WEAP.Font = fontCache end
                            if E.WEAP.TextSize ~= fontSizeCache then E.WEAP.TextSize = fontSizeCache end
                        end

                        -- Boxes & Fill
                        local b_vis = _G.ESP_CFG.Boxes and dist <= _G.ESP_CFG.MaxDistance
                        E.BOX.Visible = b_vis
                        if b_vis then
                            E.BOX.Position = UDim2.new(0, x, 0, y)
                            E.BOX.Size = UDim2.new(0, s_x, 0, s_y)

                            local color = _G.ESP_CFG.BoxColor or Color3.new(1, 1, 1)

                            local len = math.clamp(s_x * 0.25, 2, 60)
                            if _G.ESP_CFG.AnimBoxFill then
                                -- Animación de respiración de esquinas (Retícula de apuntado)
                                local pulse = 0.25 + math.sin(tick() * 4) * 0.1
                                len = math.clamp(s_x * pulse, 2, 60)
                            end

                            local t = 1 -- thickness

                            -- Top Left
                            E.BOX_LINES[1].l.Size = UDim2.new(0, len, 0, t); E.BOX_LINES[1].l.Position = UDim2.new(0, 0,
                                0, 0)
                            E.BOX_LINES[2].l.Size = UDim2.new(0, t, 0, len); E.BOX_LINES[2].l.Position = UDim2.new(0, 0,
                                0, 0)
                            -- Top Right
                            E.BOX_LINES[3].l.Size = UDim2.new(0, len, 0, t); E.BOX_LINES[3].l.Position = UDim2.new(1,
                                -len, 0, 0)
                            E.BOX_LINES[4].l.Size = UDim2.new(0, t, 0, len); E.BOX_LINES[4].l.Position = UDim2.new(1, -t,
                                0, 0)
                            -- Bottom Left
                            E.BOX_LINES[5].l.Size = UDim2.new(0, len, 0, t); E.BOX_LINES[5].l.Position = UDim2.new(0, 0,
                                1, -t)
                            E.BOX_LINES[6].l.Size = UDim2.new(0, t, 0, len); E.BOX_LINES[6].l.Position = UDim2.new(0, 0,
                                1, -len)
                            -- Bottom Right
                            E.BOX_LINES[7].l.Size = UDim2.new(0, len, 0, t); E.BOX_LINES[7].l.Position = UDim2.new(1,
                                -len, 1, -t)
                            E.BOX_LINES[8].l.Size = UDim2.new(0, t, 0, len); E.BOX_LINES[8].l.Position = UDim2.new(1, -t,
                                1, -len)

                            for i = 1, 8 do
                                E.BOX_LINES[i].l.BackgroundColor3 = color
                                E.BOX_LINES[i].bg.Size = UDim2.new(1, 2, 1, 2)
                                E.BOX_LINES[i].bg.Position = UDim2.new(0, -1, 0, -1)
                            end
                        end

                        local f_vis = _G.ESP_CFG.BoxFill and dist <= _G.ESP_CFG.MaxDistance
                        E.FILL.Visible = f_vis
                        if f_vis then
                            E.FILL.Position = UDim2.new(0, x, 0, y)
                            E.FILL.Size = UDim2.new(0, s_x, 0, s_y)
                            local fillC = _G.ESP_CFG.FillColor or Color3.new(1, 1, 1)

                            local ff1 = E.FILL:FindFirstChild("FF1")
                            local ff2 = E.FILL:FindFirstChild("FF2")

                            if _G.ESP_CFG.AnimBoxFill then
                                E.FILL.BackgroundTransparency = 1
                                if ff1 then ff1.Visible = true end
                                if ff2 then ff2.Visible = true end

                                -- Secuencia de ondas de energía
                                local seq = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0.95),
                                    NumberSequenceKeypoint.new(0.3, 0.4), -- Ola de energía brillante
                                    NumberSequenceKeypoint.new(0.5, 0.95),
                                    NumberSequenceKeypoint.new(0.7, 0.4), -- Ola de energía brillante
                                    NumberSequenceKeypoint.new(1, 0.95)
                                })

                                local t = tick()

                                -- Animar capa 1
                                if ff1 then
                                    ff1.BackgroundColor3 = fillC
                                    local g1 = ff1:FindFirstChild("Gradient")
                                    g1.Color = ColorSequence.new(fillC)
                                    g1.Transparency = seq
                                    g1.Offset = Vector2.new(math.sin(t * 1.5) * 0.4, math.sin(t * 1.5) * 0.4)
                                end

                                -- Animar capa 2 en dirección opuesta
                                if ff2 then
                                    ff2.BackgroundColor3 = fillC
                                    local g2 = ff2:FindFirstChild("Gradient")
                                    g2.Color = ColorSequence.new(fillC)
                                    g2.Transparency = seq
                                    g2.Offset = Vector2.new(math.cos(t * 1.1) * 0.4, math.cos(t * 1.1) * 0.4)
                                end
                            else
                                E.FILL.BackgroundTransparency = 0.6
                                E.FILL.BackgroundColor3 = fillC
                                if ff1 then ff1.Visible = false end
                                if ff2 then ff2.Visible = false end
                            end
                        end

                        -- Skeleton
                        local bones = HUM.RigType == Enum.HumanoidRigType.R15 and R15_BONES or R6_BONES
                        for i, bone in ipairs(bones) do
                            local seg = E.SKEL[i]
                            if seg then
                                seg.Visible = _G.ESP_CFG.Skeleton
                                if seg.Visible then
                                    local b1, b2 = C:FindFirstChild(bone[1]), C:FindFirstChild(bone[2])
                                    if b1 and b2 then
                                        local v1 = cam:WorldToViewportPoint(b1.Position)
                                        local v2 = cam:WorldToViewportPoint(b2.Position)
                                        local d = Vector2.new(v2.X - v1.X, v2.Y - v1.Y)
                                        seg.Size = UDim2.new(0, d.Magnitude, 0, 1)
                                        seg.Position = UDim2.new(0, (v1.X + v2.X) / 2, 0, (v1.Y + v2.Y) / 2)
                                        seg.Rotation = math.deg(math.atan2(d.Y, d.X))
                                        seg.BackgroundColor3 = _G.ESP_CFG.SkelColor or Color3.new(1, 1, 1)
                                    else
                                        seg.Visible = false
                                    end
                                end
                            end
                        end
                    else
                        -- Off-Screen: Hide everything but snaplines
                        E.NAME.Visible = false; E.BAR_BG.Visible = false; E.HEALTH_TXT.Visible = false;
                        E.DIST.Visible = false; E.WEAP.Visible = false; E.BOX.Visible = false; E.FILL.Visible = false
                        for _, s in ipairs(E.SKEL) do s.Visible = false end
                    end

                    -- Snaplines & OffScreen
                    if E.SLINE then
                        if _G.ESP_CFG.Snaplines and (vis or _G.ESP_CFG.OffScreen) and dist <= _G.ESP_CFG.MaxDistance then
                            local start_pos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                            local origin = _G.ESP_CFG.TracerOrigin or "Bottom"

                            if origin == "Center" then
                                start_pos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                            elseif origin == "Top" then
                                start_pos = Vector2.new(cam.ViewportSize.X / 2, 0)
                            elseif origin == "Mouse" then
                                start_pos = UIS:GetMouseLocation()
                            end

                            local target_2d = Vector2.new(pos.X, pos.Y)

                            if not vis then
                                local center = cam.ViewportSize / 2
                                local dir = (target_2d - center).Unit
                                if pos.Z < 0 then dir = -dir end
                                local padding = 20
                                target_2d = Vector2.new(
                                    math.clamp(center.X + (dir.X * 10000), padding, cam.ViewportSize.X - padding),
                                    math.clamp(center.Y + (dir.Y * 10000), padding, cam.ViewportSize.Y - padding)
                                )
                            end

                            local diff = target_2d - start_pos
                            local mag = diff.Magnitude
                            E.SLINE.Visible = true
                            E.SLINE.Size = UDim2.new(0, 1, 0, mag)
                            E.SLINE.Position = UDim2.new(0, start_pos.X + (diff.X / 2), 0, start_pos.Y + (diff.Y / 2))
                            E.SLINE.Rotation = math.deg(math.atan2(diff.Y, diff.X)) - 90
                            E.SLINE.BackgroundColor3 = _G.ESP_CFG.SnapColor or Color3.new(1, 1, 1)
                        else
                            E.SLINE.Visible = false
                        end
                    end
                end
            else
                E.FRM.Visible = false
                if E.CHAM then
                    E.CHAM:Destroy(); E.CHAM = nil
                end
                if E.TCHAM then
                    E.TCHAM:Destroy(); E.TCHAM = nil
                end
            end
        else
            E.FRM.Visible = false
            if E.CHAM then
                E.CHAM:Destroy(); E.CHAM = nil
            end
            if E.TCHAM then
                E.TCHAM:Destroy(); E.TCHAM = nil
            end
        end
    end
end

local function CLEAN_LOCAL_GUN()
    for part, mat in pairs(LOCAL_GUN_CACHE.Mats) do
        pcall(function()
            if part.Parent then
                part.Material = mat
                part.Color = LOCAL_GUN_CACHE.Colors[part]
            end
        end)
    end
    for hl, enabled in pairs(LOCAL_GUN_CACHE.Highlights) do
        pcall(function()
            if hl.Parent then
                hl.Enabled = enabled
            end
        end)
    end
    LOCAL_GUN_CACHE.Mats = {}
    LOCAL_GUN_CACHE.Colors = {}
    LOCAL_GUN_CACHE.Highlights = {}
    LOCAL_GUN_CACHE.LastTool = nil
end

local function UPD_LOCAL_GUN()
    local localChar = LP.Character
    local localTool = localChar and localChar:FindFirstChildOfClass("Tool")

    if _G.ESP_CFG and _G.ESP_CFG.LocalGunCham and localTool then
        -- If tool changed, restore material on the previous tool
        if LOCAL_GUN_CACHE.LastTool ~= localTool then
            CLEAN_LOCAL_GUN()
            LOCAL_GUN_CACHE.LastTool = localTool
        end

        -- Apply ForceField Material and Color
        for _, part in ipairs(localTool:GetDescendants()) do
            if part:IsA("BasePart") then
                if not LOCAL_GUN_CACHE.Mats[part] then
                    LOCAL_GUN_CACHE.Mats[part] = part.Material
                    LOCAL_GUN_CACHE.Colors[part] = part.Color
                end
                part.Material = Enum.Material.ForceField
                part.Color = _G.ESP_CFG.LocalGunChamColor1 or Color3.fromRGB(0, 255, 255)
            end
        end

        -- Disable any Highlights on the character and tool to prevent outline/stroke
        for _, v in ipairs(localChar:GetDescendants()) do
            if v:IsA("Highlight") then
                if not LOCAL_GUN_CACHE.Highlights[v] then
                    LOCAL_GUN_CACHE.Highlights[v] = v.Enabled
                end
                v.Enabled = false
            end
        end
    else
        CLEAN_LOCAL_GUN()
    end
end

-- Shake-free ESP Loop (Bound after Camera updates to ensure maximum stability and zero latency)
RunService:BindToRenderStep("FluxESP", 2001, function()
    if getgenv().FLUX_SESSION ~= MySession then
        pcall(function() RunService:UnbindFromRenderStep("FluxESP") end)
        return
    end
    if _G.ESP_CFG and _G.ESP_CFG.Enabled then
        UPD_ESP()
        UPD_LOCAL_GUN()
    else
        -- Hide all if disabled
        for _, E in pairs(CACHE) do
            if E.FRM then E.FRM.Visible = false end
            if E.CHAM then E.CHAM.Enabled = false end
            if E.TCHAM then E.TCHAM.Enabled = false end
        end
        CLEAN_LOCAL_GUN()
    end
end)

-- ══════════════════ CATEGORY CONTENT: WORLD VISUAL ══════════════════
-- ══════════════════ CATEGORY CONTENT: WORLD VISUAL ══════════════════
local worldPage = vsPages[2]

-- World Config already initialized at top

local woCard = NewFrame(worldPage, UDim2.new(0.46, 0, 0, 320), UDim2.new(0, 1, 0, 3), PANEL)
Corner(woCard, 8)
Stroke(woCard, STROKE, 1)

local woTitle = NewLabel(woCard, "Worlds Opciones", 12, TEXT, true)
woTitle.Name = "SectionTitle"
woTitle.Size = UDim2.new(1, 0, 0, 30)
woTitle.TextXAlignment = Enum.TextXAlignment.Center

local woContent = NewFrame(woCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
local woList = Instance.new("UIListLayout", woContent)
woList.Padding = UDim.new(0, 2)

-- Lighting Master
local Lighting = game:GetService("Lighting")
local ORIG_LIGHT = {
    Shadows = Lighting.GlobalShadows,
    Fog = Lighting.FogEnd,
    Exposure = Lighting.ExposureCompensation,
    Ambient = Lighting.Ambient,
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    AtmosDensities = {}
}

for _, obj in pairs(Lighting:GetDescendants()) do
    if obj:IsA("Atmosphere") then
        ORIG_LIGHT.AtmosDensities[obj] = obj.Density
    end
end

AddESPSetting(woContent, "Full Bright", false, 0, false, function(v)
    _G.WORLD_CFG.FullBright = v
    if not v then
        Lighting.Brightness = ORIG_LIGHT.Brightness
        Lighting.ClockTime = ORIG_LIGHT.ClockTime
        Lighting.GlobalShadows = ORIG_LIGHT.Shadows
        Lighting.FogEnd = ORIG_LIGHT.Fog
        Lighting.OutdoorAmbient = ORIG_LIGHT.OutdoorAmbient
    end
end)

AddESPSetting(woContent, "No Fog", false, 0, false, function(v)
    _G.WORLD_CFG.NoFog = v
    if not v then
        Lighting.FogEnd = ORIG_LIGHT.Fog
        for obj, dens in pairs(ORIG_LIGHT.AtmosDensities) do
            if obj and obj.Parent then
                obj.Density = dens
            end
        end
    end
end)

AddESPSetting(woContent, "Atmosphere Color", false, 1, false, function(v, c)
    if v and c then
        _G.WORLD_CFG.AtmosColor = c[1]
        NOTIFY("World", "Atmosphere Color Updated", 1.5)
    else
        _G.WORLD_CFG.AtmosColor = nil
        Lighting.Ambient = ORIG_LIGHT.Ambient
    end
end, { _G.WORLD_CFG.AtmosColor or Color3.fromRGB(200, 200, 200) })

AddESPSetting(woContent, "FPS Booster", _G.WORLD_CFG.FPSBooster, 0, false, function(v)
    _G.WORLD_CFG.FPSBooster = v
    if v then
        if not _G.FPS_BOOSTER_EXECUTED then
            _G.FPS_BOOSTER_EXECUTED = true
            NOTIFY("System", "Executing FPS Booster...", 2)
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Tagger83/FPS2/refs/heads/main/FPS2.lua"))()
                end)
            end)
        else
            NOTIFY("System", "FPS Booster already active", 2)
        end
    end
end)

AddVSSlider(woContent, "Exposure", 0, 5, 1, "", function(v) _G.WORLD_CFG.Exposure = v end)
AddVSSlider(woContent, "Brightness", 0, 5, 1, "", function(v) _G.WORLD_CFG.Brightness = v end)

-- Card 2: Extras
local exCard = NewFrame(worldPage, UDim2.new(0.52, -4, 0, 200), UDim2.new(0.48, 1, 0, 3), PANEL)
Corner(exCard, 8)
Stroke(exCard, STROKE, 1)

local exTitle = NewLabel(exCard, "Extras", 12, TEXT, true)
exTitle.Name = "SectionTitle"
exTitle.Size = UDim2.new(1, 0, 0, 30)
exTitle.TextXAlignment = Enum.TextXAlignment.Center

local exContent = NewFrame(exCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
local exList = Instance.new("UIListLayout", exContent)
exList.Padding = UDim.new(0, 2)

-- FOV
AddESPSetting(exContent, "Custom FOV", _G.WORLD_CFG.FOVEnabled, 0, false, function(v)
    _G.WORLD_CFG.FOVEnabled = v
    if not v then
        pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)
    else
        pcall(function() workspace.CurrentCamera.FieldOfView = _G.WORLD_CFG.FOV or 70 end)
    end
end)

AddVSSlider(exContent, "Field of View", 0, 400, 70, "", function(v)
    _G.WORLD_CFG.FOV = v
    if _G.WORLD_CFG.FOVEnabled then
        pcall(function() workspace.CurrentCamera.FieldOfView = v end)
    end
end)

-- Skybox Data
local SKY_ASSETS = {
    ["Sponge Bob"] = {
        "rbxassetid://70654252104587", "rbxassetid://85169155668096", "rbxassetid://115749804544787",
        "rbxassetid://114736069495828", "rbxassetid://96320056467829", "rbxassetid://103246856267702",
        "rbxassetid://100094276908098", "rbxassetid://85732725984731", "rbxassetid://103828381258742"
    },
    ["Purple Nebula"] = "rbxassetid://159454299",
    ["Night Stars"] = "rbxassetid://12064107",
    ["Cyberpunk"] = "rbxassetid://6073747120",
    ["Space"] = {
        Bk = "rbxassetid://16262356578",
        Dn = "rbxassetid://16262358026",
        Ft = "rbxassetid://16262360469",
        Lf = "rbxassetid://16262362003",
        Rt = "rbxassetid://16262363873",
        Up = "rbxassetid://16262366016"
    },
    ["Cartoony"] = {
        Bk = "rbxassetid://12879214960",
        Dn = "rbxassetid://12871012589",
        Ft = "rbxassetid://12879236088",
        Lf = "rbxassetid://12879246392",
        Rt = "rbxassetid://12879253901",
        Up = "rbxassetid://12871018996"
    }
}

local origSky = Lighting:FindFirstChildOfClass("Sky")
local skyCache = { Bk = "", Dn = "", Ft = "", Lf = "", Rt = "", Up = "" }
if origSky then
    skyCache = {
        Bk = origSky.SkyboxBk,
        Dn = origSky.SkyboxDn,
        Ft = origSky.SkyboxFt,
        Lf = origSky.SkyboxLf,
        Rt = origSky.SkyboxRt,
        Up = origSky.SkyboxUp
    }
end

local skyLoopIdx = 1
local function applySky(asset)
    local s = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)

    if not _G.WORLD_CFG.EnableSkybox or not asset or asset == "Default" then
        if origSky then
            s.SkyboxBk = skyCache.Bk; s.SkyboxDn = skyCache.Dn; s.SkyboxFt = skyCache.Ft
            s.SkyboxLf = skyCache.Lf; s.SkyboxRt = skyCache.Rt; s.SkyboxUp = skyCache.Up
        else
            s:Destroy()
        end
        return
    end

    if typeof(asset) == "table" then
        if asset.Bk then -- Cubemap (Static with 6 faces)
            s.SkyboxBk = asset.Bk
            s.SkyboxDn = asset.Dn
            s.SkyboxFt = asset.Ft
            s.SkyboxLf = asset.Lf
            s.SkyboxRt = asset.Rt
            s.SkyboxUp = asset.Up
        else -- Animated
            s.SkyboxBk = asset[skyLoopIdx]
            s.SkyboxDn = asset[skyLoopIdx]
            s.SkyboxFt = asset[skyLoopIdx]
            s.SkyboxLf = asset[skyLoopIdx]
            s.SkyboxRt = asset[skyLoopIdx]
            s.SkyboxUp = asset[skyLoopIdx]
        end
    else -- Static (Single face)
        s.SkyboxBk = asset; s.SkyboxDn = asset; s.SkyboxFt = asset
        s.SkyboxLf = asset; s.SkyboxRt = asset; s.SkyboxUp = asset
    end
end

do
    local skyContainer = NewFrame(exContent, UDim2.new(1, 0, 0, 50 + 34 + 4), nil, BG, 1)
    local skyList = Instance.new("UIListLayout", skyContainer)
    skyList.SortOrder = Enum.SortOrder.LayoutOrder
    skyList.Padding = UDim.new(0, 4)

    AddESPSetting(skyContainer, "Enable Custom Sky", false, 0, false, function(v)
        _G.WORLD_CFG.EnableSkybox = v
        local asset = (_G.WORLD_CFG.Skybox == "Default") and "Default" or SKY_ASSETS[_G.WORLD_CFG.Skybox]
        applySky(asset)
    end)

    local skyRow = NewFrame(skyContainer, UDim2.new(1, 0, 0, 50), nil, BG, 1)
    skyRow.LayoutOrder = 999
    NewLabel(skyRow, "Custom Skybox", 11, TEXT).Size = UDim2.new(1, 0, 0, 16)
    local skyDd = AddDropdown(skyRow,
        { "Default", "Sponge Bob", "Purple Nebula", "Night Stars", "Cyberpunk", "Space", "Cartoony" }, "Default",
        function(v)
            _G.WORLD_CFG.Skybox = v
            if v ~= "Sponge Bob" then
                applySky(v == "Default" and "Default" or SKY_ASSETS[v])
            end
        end)
    skyDd.Position = UDim2.new(0, 0, 0, 18)
    skyDd.Size = UDim2.new(1, 0, 0, 28)
end

-- [ WORLD FOV ENGINE: OMEGA BYPASS ]
local CAMERA_CACHE = {}
local function RefreshCameraCache()
    CAMERA_CACHE = { workspace.CurrentCamera }
    -- Search in common services where hidden cameras might live
    local searchIn = { workspace, game:GetService("Players"), game:GetService("StarterGui") }
    for _, service in pairs(searchIn) do
        for _, v in pairs(service:GetDescendants()) do
            if v:IsA("Camera") and not table.find(CAMERA_CACHE, v) then
                table.insert(CAMERA_CACHE, v)
            end
        end
    end
end

-- Refresh cache every 5 seconds
task.spawn(function()
    while task.wait(5) do
        if getgenv().FLUX_SESSION ~= MySession then break end
        RefreshCameraCache()
    end
end)
RefreshCameraCache()

local function ForceFOV()
    if not _G.WORLD_CFG.FOVEnabled then return end
    local targetFOV = _G.WORLD_CFG.FOV or 70
    if targetFOV <= 0 then return end

    for _, cam in pairs(CAMERA_CACHE) do
        pcall(function()
            if cam and cam.Parent then
                cam.FieldOfView = targetFOV
            end
        end)
    end
end


-- Dedicated Ultra-High Priority Loop
RunService:BindToRenderStep("ForceFOV_OMEGA", 2000, function()
    if getgenv().FLUX_SESSION ~= MySession then
        return
    end
    ForceFOV()
end)

-- Heartbeat Fallback (Ensures no escape)
table.insert(_G.FLUX_CONNS, RunService.Heartbeat:Connect(function()
    if getgenv().FLUX_SESSION ~= MySession then return end
    ForceFOV()
end))

-- Lighting Loop
task.spawn(function()
    local lastSkyTick = tick()
    while task.wait(0.3) do
        if not SG.Parent then break end

        -- Sponge Bob Animation
        if _G.WORLD_CFG.Skybox == "Sponge Bob" then
            if tick() - lastSkyTick >= 0.1 then
                skyLoopIdx = skyLoopIdx + 1
                if skyLoopIdx > #SKY_ASSETS["Sponge Bob"] then skyLoopIdx = 1 end
                applySky(SKY_ASSETS["Sponge Bob"])
                lastSkyTick = tick()
            end
        end

        if _G.WORLD_CFG.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            if _G.WORLD_CFG.Brightness ~= 1 then
                Lighting.Brightness = _G.WORLD_CFG.Brightness
            end
        end

        if _G.WORLD_CFG.NoFog then
            Lighting.FogEnd = 100000
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("Atmosphere") then v.Density = 0 end
            end
        end

        if _G.WORLD_CFG.Exposure ~= 0 then
            Lighting.ExposureCompensation = _G.WORLD_CFG.Exposure
        else
            Lighting.ExposureCompensation = ORIG_LIGHT.Exposure
        end

        if _G.WORLD_CFG.AtmosColor then
            Lighting.Ambient = _G.WORLD_CFG.AtmosColor
        else
            Lighting.Ambient = ORIG_LIGHT.Ambient
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if CACHE[p] then
        pcall(function()
            CACHE[p].FRM:Destroy()
            CACHE[p].BOX:Destroy()
            CACHE[p].FILL:Destroy()
            if CACHE[p].CHAM then CACHE[p].CHAM:Destroy() end
            if CACHE[p].TCHAM then CACHE[p].TCHAM:Destroy() end
        end)
        CACHE[p] = nil
    end
end)

-- ══════════════════ CATEGORY CONTENT: SETTINGS ══════════════════
local SettingsPage = navPages["Settings"]
local ST_TAB_H = 44
local ST_TabBar = NewFrame(SettingsPage, UDim2.new(1, 0, 0, ST_TAB_H), UDim2.new(0, 0, 0, 0), BG, 1)
-- MakeDraggable(ST_TabBar, Root)

local ST_TabSep = NewFrame(SettingsPage, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, ST_TAB_H), STROKE)

local ST_Content = NewFrame(SettingsPage,
    UDim2.new(1, -20, 1, -(ST_TAB_H + 20)),
    UDim2.new(0, 10, 0, ST_TAB_H + 10),
    BG, 1
)

local ST_TABS = { "UI Settings", "Server" }
local stPages = {}
-- stBtns, stLines, activeStIdx declared above (near theme system)


local st_x = 18
for i, name in ipairs(ST_TABS) do
    local tw = (i == 1 and 90 or 60)
    local tb = NewBtn(ST_TabBar, UDim2.new(0, tw, 1, 0), UDim2.new(0, st_x, 0, 0), BG, 1)
    local tl = NewLabel(tb, name, 13, i == 1 and ACCENT or DIM, i == 1)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Center

    local ul = NewFrame(SettingsPage, UDim2.new(0, tw, 0, 2), UDim2.new(0, st_x, 0, ST_TAB_H - 2), ACCENT)
    ul.Visible = i == 1
    Corner(ul, 1)

    local page = NewScroll(ST_Content, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BG, 1)
    page.Visible = (i == 1)

    stPages[i] = page
    stBtns[i] = { btn = tb, lbl = tl }
    stLines[i] = ul
    st_x = st_x + tw + 14

    tb.MouseButton1Click:Connect(function()
        if activeStIdx == i then return end
        stBtns[activeStIdx].lbl.TextColor3 = DIM
        stBtns[activeStIdx].lbl.Font = Enum.Font.Gotham
        stLines[activeStIdx].Visible = false
        stPages[activeStIdx].Visible = false

        activeStIdx = i
        tl.TextColor3 = ACCENT
        tl.Font = Enum.Font.GothamBold
        ul.Visible = true
        page.Visible = true
    end)
end

-- UI Settings Content
do
    local uiPage = stPages[1]



    local prefHeight = UIS.KeyboardEnabled and 295 or 265
    ; (function()
        local prefCard = NewFrame(uiPage, UDim2.new(0.46, 0, 0, prefHeight), UDim2.new(0, 1, 0, 3), PANEL)
        Corner(prefCard, 8)
        Stroke(prefCard, STROKE, 1)

        local uiTitle = NewLabel(prefCard, "UI Preferences", 13, TEXT, true)
        uiTitle.Name = "SectionTitle"
        uiTitle.Size = UDim2.new(1, 0, 0, 30)
        uiTitle.Position = UDim2.new(0, 0, 0, 0)
        uiTitle.TextXAlignment = Enum.TextXAlignment.Center

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 4)
        list.Parent = NewFrame(prefCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)

        local function AddSetting(label, default, callback)
            local row = NewBtn(list.Parent, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
            Corner(row, 5)

            local checked = default
            local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
            Corner(cbBg, 3)
            Stroke(cbBg, STROKE2, 1)

            local check = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
            check.Size = UDim2.new(1, 0, 1, 0)
            check.Visible = checked

            local lbl = NewLabel(row, label, 13, TEXT)
            lbl.Position = UDim2.new(0, 32, 0, 0)
            lbl.Size = UDim2.new(1, -32, 1, 0)

            local function updateUI()
                check.Visible = checked
                Tw(cbBg, 0.1, "Quad", "Out", {
                    BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                })
            end

            -- Register for external sync
            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                -- Find what variable this toggle is linked to and sync
                if label == "Enable Notifications" then
                    checked = useNotifications
                elseif label == "Enable Watermark" then
                    checked = useWatermark
                elseif label == "Show Active Keybinds" then
                    checked = useKbHud
                end
                updateUI()
            end)

            row.MouseButton1Click:Connect(function()
                checked = not checked
                updateUI()
                callback(checked)
            end)
            row.MouseEnter:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 0.45 }) end)
            row.MouseLeave:Connect(function() Tw(row, 0.08, "Quad", "Out", { BackgroundTransparency = 1 }) end)

            updateUI()
            return row
        end

        AddSetting("UI Shadow", true, function(v)
            if Tw then Tw(Shadow, 0.25, "Quad", "Out", { ImageTransparency = v and 0.35 or 1 }) end
        end)
        AddSetting("Smooth Drag", useSmoothDrag, function(v)
            useSmoothDrag = v
            SaveUI()
        end)
        AddSetting("Enable Notifications", useNotifications, function(v)
            useNotifications = v
            SaveUI()
        end)
        AddSetting("Enable Watermark", useWatermark, function(v)
            useWatermark = v
            Watermark.Visible = v
            SaveUI()
        end)

        -- ── Keybind Overlay ──────────────────────────────────────
        do
            KbSG = Instance.new("ScreenGui")
            KbSG.Name = "FluxKeybindHUD"
            KbSG.ResetOnSpawn = false
            KbSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            KbSG.Parent = (gethui and gethui()) or game:GetService("CoreGui")

            KbWin = NewFrame(KbSG, UDim2.new(0, 220, 0, 20), UDim2.new(0, 20, 0, 140), Color3.fromRGB(15, 15, 20))
            Corner(KbWin, 8)
            Stroke(KbWin, STROKE2, 1)
            KbWin.Visible = false

            local KbGrad = Instance.new("UIGradient")
            KbGrad.Rotation = 90
            KbGrad.Color = ColorSequence.new(Color3.fromRGB(15, 15, 20), Color3.fromRGB(22, 22, 30))
            KbGrad.Parent = KbWin

            -- Title bar (drag area)
            local KbTitleBar = NewFrame(KbWin, UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 0), Color3.fromRGB(20, 20, 28))
            Corner(KbTitleBar, 8)
            KbTitleBar.ClipsDescendants = false

            local KbTitle = NewLabel(KbTitleBar, "⌨  Active Keybinds", 11, ACCENT, true)
            KbTitle.Name = "SectionTitle"
            KbTitle.Size = UDim2.new(1, -10, 1, 0)
            KbTitle.Position = UDim2.new(0, 10, 0, 0)
            table.insert(accentFills, KbGrad) -- will recolor via theme

            -- Scrollable content area for keybind rows
            local KbContent = NewFrame(KbWin, UDim2.new(1, -16, 1, -36), UDim2.new(0, 8, 0, 34), BG, 1)
            local KbList = Instance.new("UIListLayout", KbContent)
            KbList.Padding = UDim.new(0, 4)
            KbList.SortOrder = Enum.SortOrder.LayoutOrder

            -- Make title bar draggable (moves the whole KbWin)
            MakeDraggable(KbTitleBar, KbWin)

            -- Build keybind rows dynamically (optimized for reuse)
            local rowPool = {}
            local function BuildKbRows()
                local children = KbContent:GetChildren()
                for _, c in ipairs(children) do
                    if c:IsA("Frame") then
                        c.Visible = false
                        table.insert(rowPool, c)
                    end
                end

                local binds = {}
                -- UI Toggle
                table.insert(binds, { action = "Toggle UI", key = toggleKey and toggleKey.Name or "RightShift" })
                -- Aimbot
                if _G.AIMBOT_CFG and _G.AIMBOT_CFG.Keybind then
                    local k = _G.AIMBOT_CFG.Keybind
                    local kName = (typeof(k) == "EnumItem") and k.Name or tostring(k)
                    if kName ~= "None" and kName ~= "" then
                        table.insert(binds, { action = "Aimbot", key = kName })
                    end
                end
                -- ESP
                if _G.ESP_CFG and _G.ESP_CFG.Keybind then
                    local k = _G.ESP_CFG.Keybind
                    local kName = (typeof(k) == "EnumItem") and k.Name or tostring(k)
                    if kName ~= "None" and kName ~= "" then
                        table.insert(binds, { action = "ESP Toggle", key = kName })
                    end
                end
                -- Insta Kill
                if _G.IK_CFG and _G.IK_CFG.Keybind then
                    local k = _G.IK_CFG.Keybind
                    local kName = (typeof(k) == "EnumItem") and k.Name or tostring(k)
                    if kName ~= "None" and kName ~= "" then
                        table.insert(binds, { action = "Insta Kill", key = kName })
                    end
                end
                -- Speed Boost
                if _G.LOCAL_PLAYER_CFG and _G.LOCAL_PLAYER_CFG.SpeedKey then
                    local k = _G.LOCAL_PLAYER_CFG.SpeedKey
                    local kName = (typeof(k) == "EnumItem") and k.Name or tostring(k)
                    if kName ~= "None" and kName ~= "" then
                        table.insert(binds, { action = "Speed Boost", key = kName })
                    end
                end
                -- Player Fly
                if _G.LOCAL_PLAYER_CFG and _G.LOCAL_PLAYER_CFG.FlyKey then
                    local k = _G.LOCAL_PLAYER_CFG.FlyKey
                    local kName = (typeof(k) == "EnumItem") and k.Name or tostring(k)
                    if kName ~= "None" and kName ~= "" then
                        table.insert(binds, { action = "Player Fly", key = kName })
                    end
                end
                -- Invisibility
                if _G.LOCAL_PLAYER_CFG and _G.LOCAL_PLAYER_CFG.InvisKey then
                    local k = _G.LOCAL_PLAYER_CFG.InvisKey
                    local kName = (typeof(k) == "EnumItem") and k.Name or tostring(k)
                    if kName ~= "None" and kName ~= "" then
                        table.insert(binds, { action = "Invisibility", key = kName })
                    end
                end

                for i, b in ipairs(binds) do
                    local row = table.remove(rowPool)
                    if not row then
                        row = NewFrame(KbContent, UDim2.new(1, 0, 0, 26), nil, Color3.fromRGB(28, 28, 38))
                        Corner(row, 5)
                        local aLbl = NewLabel(row, b.action, 10, TEXT, false)
                        aLbl.Name = "ActionLbl"
                        aLbl.Position = UDim2.new(0, 8, 0, 0)
                        aLbl.Size = UDim2.new(0.6, 0, 1, 0)
                        local badge = NewFrame(row, UDim2.new(0, 60, 0, 18), UDim2.new(1, -66, 0.5, -9),
                            Color3.fromRGB(40, 40, 54))
                        badge.Name = "Badge"
                        Corner(badge, 4)
                        Stroke(badge, STROKE2, 1)
                        local kLbl = NewLabel(badge, b.key, 9, ACCENT, true, Enum.TextXAlignment.Center)
                        kLbl.Name = "SectionTitle"
                        kLbl.Size = UDim2.new(1, 0, 1, 0)
                    end
                    row.LayoutOrder = i
                    row:FindFirstChild("ActionLbl").Text = b.action
                    row:FindFirstChild("Badge"):FindFirstChild("SectionTitle").Text = b.key
                    row.Visible = true
                end

                -- Cleanup unused pooled rows
                for _, r in ipairs(rowPool) do r:Destroy() end
                table.clear(rowPool)

                -- Resize window to fit content
                local rowCount = math.max(1, #binds)
                KbWin.Size = UDim2.new(0, 220, 0, 28 + rowCount * 30 + (rowCount - 1) * 4 + 12)
            end
            _G.FLUX_UPDATE_KB_HUD = BuildKbRows

            local kbAccentProxy = {
                update = function()
                    for _, lbl in ipairs(KbContent:GetDescendants()) do
                        if lbl:IsA("TextLabel") and lbl.Name == "SectionTitle" then
                            lbl.TextColor3 = ACCENT
                        end
                    end
                    KbTitle.TextColor3 = ACCENT
                end
            }
            _G.FLUX_KB_HUD_ACCENT_UPDATE = function() kbAccentProxy.update() end

            -- Poll every second to keep rows fresh
            task.spawn(function()
                while true do
                    task.wait(1)
                    if getgenv().FLUX_SESSION ~= MySession then break end
                    if KbWin.Visible then
                        BuildKbRows()
                        kbAccentProxy.update()
                    end
                end
            end)

            if not IS_MOBILE then
                AddSetting("Show Active Keybinds", useKbHud, function(v)
                    useKbHud = v
                    KbWin.Visible = v and (uiVis == true)
                    if v then BuildKbRows() end
                    SaveUI()
                end)
            end

            _G.FLUX_KB_HUD_SYNC = function()
                if KbWin then KbWin.Visible = uiVis and useKbHud and not IS_MOBILE end
            end
            _G.FLUX_KB_HUD_GUI = KbSG

            -- Initial Sync for Loaded Settings
            if useKbHud and not IS_MOBILE then
                KbWin.Visible = uiVis
                BuildKbRows()
            end
        end

        if UIS.KeyboardEnabled and not IS_MOBILE then
            AddCardKeybind(list.Parent, "Set Custom Keybind", toggleKey, function(k)
                toggleKey = k
                SaveUI()
            end)
        end

        -- UI Color Theme Dropdown
        local themeRow = NewFrame(list.Parent, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), BG, 1)
        local themeBtn = NewBtn(themeRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(36, 36, 48))
        Corner(themeBtn, 4)
        Stroke(themeBtn, STROKE2, 1)
        local themeLbl = NewLabel(themeBtn, "UI Color: Default", 11, TEXT)
        themeLbl.Position = UDim2.new(0, 8, 0, 0)
        themeLbl.Size = UDim2.new(1, -28, 1, 0)
        local themeArrow = Instance.new("ImageLabel")
        themeArrow.BackgroundTransparency = 1
        themeArrow.Size = UDim2.new(0, 12, 0, 12)
        themeArrow.Position = UDim2.new(1, -18, 0.5, -6)
        themeArrow.Image = "rbxassetid://6034818372"
        themeArrow.ImageColor3 = DIM
        themeArrow.Parent = themeBtn

        local THEME_OPTIONS = { "Default", "Dark Blue", "Dark Purple", "Dark White" }
        local themeDropOpen = false
        local themeDropH = #THEME_OPTIONS * 26

        local themeDropPanel = NewFrame(themeBtn, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 2),
            Color3.fromRGB(28, 28, 38))
        themeDropPanel.ZIndex = 200
        themeDropPanel.Visible = false
        themeDropPanel.ClipsDescendants = true
        Corner(themeDropPanel, 6)
        Stroke(themeDropPanel, STROKE2, 1)
        local themeDropList = Instance.new("UIListLayout")
        themeDropList.SortOrder = Enum.SortOrder.LayoutOrder
        themeDropList.Parent = themeDropPanel

        local function closeThemeDrop()
            themeDropOpen = false
            Tw(themeDropPanel, 0.12, "Quad", "Out", { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.13, function() themeDropPanel.Visible = false end)
            Tw(themeArrow, 0.12, "Quad", "Out", { Rotation = 0 })
        end

        for i, opt in ipairs(THEME_OPTIONS) do
            local ob = NewBtn(themeDropPanel, UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 0), Color3.fromRGB(32, 32, 44),
                1)
            ob.LayoutOrder = i
            ob.ZIndex = 201
            Corner(ob, 4)
            local ol = NewLabel(ob, opt, 11, TEXT)
            ol.Size = UDim2.new(1, -12, 1, 0)
            ol.Position = UDim2.new(0, 10, 0, 0)
            ol.ZIndex = 202
            ob.MouseEnter:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 0.35 }) end)
            ob.MouseLeave:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)
            ob.MouseButton1Click:Connect(function()
                themeLbl.Text = "UI Color: " .. opt
                closeThemeDrop()
                applyUITheme(opt)
                NOTIFY("Theme System", "Switched to " .. opt, 2.5)
            end)
        end

        themeBtn.MouseButton1Click:Connect(function()
            themeDropOpen = not themeDropOpen
            if themeDropOpen then
                themeDropPanel.Visible = true
                Tw(themeDropPanel, 0.15, "Quad", "Out", { Size = UDim2.new(1, 0, 0, themeDropH) })
                Tw(themeArrow, 0.15, "Quad", "Out", { Rotation = 180 })
            else
                closeThemeDrop()
            end
        end)

        UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if not themeDropOpen then return end
            if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
            local mx, my = inp.Position.X, inp.Position.Y
            local function hit(f)
                return mx >= f.AbsolutePosition.X and mx <= f.AbsolutePosition.X + f.AbsoluteSize.X
                    and my >= f.AbsolutePosition.Y and my <= f.AbsolutePosition.Y + f.AbsoluteSize.Y
            end
            if not hit(themeDropPanel) and not hit(themeBtn) then closeThemeDrop() end
        end)
    end)()

    -- Background Settings Card
    local bgCard = NewFrame(uiPage, UDim2.new(0.52, -4, 0, 160), UDim2.new(0.48, 1, 0, 3), PANEL)
    Corner(bgCard, 8)
    Stroke(bgCard, STROKE, 1)

    local bgTitle = NewLabel(bgCard, "Background Settings", 13, TEXT, true)
    bgTitle.Name = "SectionTitle"
    bgTitle.Size = UDim2.new(1, 0, 0, 30)
    bgTitle.Position = UDim2.new(0, 0, 0, 0)
    bgTitle.TextXAlignment = Enum.TextXAlignment.Center

    local bgList = Instance.new("UIListLayout")
    bgList.Padding = UDim.new(0, 4)
    bgList.SortOrder = Enum.SortOrder.LayoutOrder
    bgList.Parent = NewFrame(bgCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)



    -- ══════════════════ CATEGORY CONTENT: SILENT AIM ══════════════════
    ;(function()
        local SilentPage = tabPages[2]
        if IsMurderVsSheriff() or IsHitmark() or IsBronxDuels() or IsDuelist() then
            local SLift = NewFrame(SilentPage, UDim2.new(0.53, -5, 0, 310), UDim2.new(0, 0, 0, 0), PANEL)
            Corner(SLift, 8); Stroke(SLift, STROKE, 1)
            local STitle = NewLabel(SLift, "Silent Aim Configuration", 13, TEXT, true)
            STitle.Size = UDim2.new(1, 0, 0, 30); STitle.TextXAlignment = Enum.TextXAlignment.Center

            local SCheckHolder = NewFrame(SLift, UDim2.new(1, -16, 0, 110), UDim2.new(0, 8, 0, 32), PANEL, 1)
            Instance.new("UIListLayout", SCheckHolder).Padding = UDim.new(0, 2)
            local SSliderHolder = NewFrame(SLift, UDim2.new(1, -16, 0, 160), UDim2.new(0, 8, 0, 142), PANEL, 1)
            Instance.new("UIListLayout", SSliderHolder).Padding = UDim.new(0, 6)

            local function AddSilentToggle(label, cfg)
                local row = NewBtn(SCheckHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
                Corner(row, 5)
                local checked = _G.SILENT_CFG[cfg]
                local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
                Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)
                local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
                cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = checked
                local rowLbl = NewLabel(row, label, 13, TEXT)
                rowLbl.Position = UDim2.new(0, 32, 0, 0); rowLbl.Size = UDim2.new(1, -40, 1, 0)
                rowLbl.TextScaled = true
                local sFit = Instance.new("UITextSizeConstraint")
                sFit.MaxTextSize = 13
                sFit.MinTextSize = 8
                sFit.Parent = rowLbl

                local function ToggleState(state)
                    if state ~= nil then checked = state else checked = not checked end
                    _G.SILENT_CFG[cfg] = checked; cbCheck.Visible = checked
                    Tw(cbBg, 0.1, "Quad", "Out",
                        { BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48) })
                end

                row.MouseButton1Click:Connect(function() ToggleState() end)
                row.MouseEnter:Connect(function()
                    Tw(row, 0.1, "Quad", "Out",
                        { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
                end)
                row.MouseLeave:Connect(function()
                    Tw(row, 0.1, "Quad", "Out",
                        { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
                end)

                _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
                table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                    local ns = _G.SILENT_CFG[cfg]
                    if ns == nil then ns = checked end
                    ToggleState(ns)
                end)

                return row
            end

            _G.SILENT_CFG.Keybind = _G.SILENT_CFG.Keybind or Enum.KeyCode.None
            local silentCheck = AddCardSetting(SCheckHolder, "Enable Silent Aim", _G.SILENT_CFG.Enabled, function(v)
                _G.SILENT_CFG.Enabled = v
            end, _G.SILENT_CFG.Keybind, function(k)
                _G.SILENT_CFG.Keybind = k
            end)
            
            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                if silentCheck then
                    local active = _G.SILENT_CFG.Enabled
                    local cbBg = silentCheck:FindFirstChildOfClass("Frame")
                    local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                    if cbCheck then cbCheck.Visible = active end
                    if cbBg then
                        cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                    end

                    local kbBox = silentCheck:FindFirstChild("KeybindBox")
                    local bindLbl = kbBox and kbBox:FindFirstChild("BindLabel")
                    if bindLbl then
                        local keyName = "None"
                        local kb = _G.SILENT_CFG.Keybind
                        if kb then
                            if typeof(kb) == "EnumItem" then
                                keyName = (kb == Enum.KeyCode.None) and "None" or kb.Name
                            else
                                keyName = tostring(kb)
                            end
                        end
                        bindLbl.Text = keyName
                    end
                end
            end)

            AddSilentToggle("Wallbang", "Wallbang")
            AddSilentToggle("Show FOV Circle", "DrawFov")
            AddCardSlider(SSliderHolder, "Hit Chance", 0, 100, _G.SILENT_CFG.HitChance,
                function(v) _G.SILENT_CFG.HitChance = v end)
            AddCardSlider(SSliderHolder, "Silent FOV", 0, 400, _G.SILENT_CFG.FOV, function(v) _G.SILENT_CFG.FOV = v end)
            AddDropdown(SSliderHolder, { "Head", "UpperTorso", "HumanoidRootPart", "Random" }, _G.SILENT_CFG.TargetPart,
                function(v) _G.SILENT_CFG.TargetPart = v end)

            local function BuildInstaKillCard()
                _G.IK_CFG = _G.IK_CFG or { Enabled = false, Mode = "Keybind", Keybind = "G" }
                local IKCard = NewFrame(SilentPage, UDim2.new(0.46, -5, 0, 120), UDim2.new(0.54, 0, 0, 0), PANEL)
                Corner(IKCard, 8); Stroke(IKCard, STROKE, 1)
                local IKTitle = NewLabel(IKCard, "Insta Kill Settings", 13, TEXT, true)
                IKTitle.Size = UDim2.new(1, 0, 0, 30); IKTitle.TextXAlignment = Enum.TextXAlignment.Center
                local IKCheckHolder = NewFrame(IKCard, UDim2.new(1, -16, 0, 80), UDim2.new(0, 8, 0, 32), PANEL, 1)
                Instance.new("UIListLayout", IKCheckHolder).Padding = UDim.new(0, 4)

                local function AddIKToggleWithBind(label, cfg)
                    local row = NewBtn(IKCheckHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
                    Corner(row, 5)
                    local checked = _G.IK_CFG[cfg]
                    local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7),
                        Color3.fromRGB(36, 36, 48))
                    Corner(cbBg, 3); Stroke(cbBg, STROKE2, 1)
                    local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
                    cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = checked
                    local rowLbl = NewLabel(row, label, 13, TEXT)
                    rowLbl.Position = UDim2.new(0, 32, 0, 0)
                    rowLbl.Size = UDim2.new(1, IS_MOBILE and -38 or -96, 1, 0)
                    rowLbl.TextScaled = true
                    local fit = Instance.new("UITextSizeConstraint")
                    fit.MaxTextSize = 13
                    fit.MinTextSize = 8
                    fit.Parent = rowLbl

                    row.MouseButton1Click:Connect(function()
                        checked = not checked; _G.IK_CFG[cfg] = checked; cbCheck.Visible = checked
                        Tw(cbBg, 0.1, "Quad", "Out",
                            { BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48) })
                    end)
                    row.MouseEnter:Connect(function()
                        Tw(row, 0.1, "Quad", "Out",
                            { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
                    end)
                    row.MouseLeave:Connect(function()
                        Tw(row, 0.1, "Quad", "Out",
                            { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
                    end)

                    if not IS_MOBILE then
                        local kbBox = NewBtn(row, UDim2.new(0, 50, 0, 20), UDim2.new(1, -58, 0.5, -10),
                            Color3.fromRGB(45, 45, 55), 1)
                        kbBox.Name = "KeybindBox"
                        Corner(kbBox, 4); Stroke(kbBox, STROKE2, 1)
                        local bindLbl = NewLabel(kbBox, _G.IK_CFG.Keybind, 10, TEXT, false, Enum.TextXAlignment.Center)
                        bindLbl.Size = UDim2.new(1, 0, 1, 0)

                        local waiting = false
                        kbBox.MouseButton1Click:Connect(function()
                            if waiting then return end
                            waiting = true
                            bindLbl.Text = "..."
                            bindLbl.TextColor3 = Color3.new(1, 1, 1)
                            Tw(kbBox, 0.2, "Quad", "Out", { BackgroundColor3 = ACCENT })

                            local conn; conn = UIS.InputBegan:Connect(function(inp, gpe)
                                if gpe or inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                                waiting = false
                                _G.IK_CFG.Keybind = inp.KeyCode.Name
                                bindLbl.Text = inp.KeyCode.Name
                                bindLbl.TextColor3 = TEXT
                                Tw(kbBox, 0.2, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                                if _G.FLUX_UPDATE_KB_HUD then pcall(_G.FLUX_UPDATE_KB_HUD) end
                                conn:Disconnect()
                            end)
                        end)
                    end
                end
                AddIKToggleWithBind("Enable Insta Kill", "Enabled")
                local ddRow = NewFrame(IKCheckHolder, UDim2.new(1, 0, 0, 32), nil, BG, 1)
                local dd = AddDropdown(ddRow, { "Keybind", "Auto Kill" }, _G.IK_CFG.Mode, function(v)
                    _G.IK_CFG.Mode = v
                    NOTIFY("Insta Kill", "Mode: " .. v, 2)
                end)
                dd.Size = UDim2.new(1, 0, 1, 0)
            end

            local function BuildGunsModsCard(parentCol)
                _G.GUN_MODS_CFG = _G.GUN_MODS_CFG or {
                    NoRecoil = false,
                    NoSpread = false,
                    RapidFire = false,
                    Automatic = false,
                    InfiniteAmmo = false
                }

                local GMCard = NewFrame(parentCol or SilentPage, UDim2.new(1, 0, 0, 240), UDim2.new(0, 0, 0, 0), PANEL)
                if not parentCol then
                    GMCard.Size = UDim2.new(0.46, -5, 0, 240); GMCard.Position = UDim2.new(0.54, 0, 0, 0)
                end
                Corner(GMCard, 8); Stroke(GMCard, STROKE, 1)

                local GMTitle = NewLabel(GMCard, "Guns Mods", 13, TEXT, true)
                GMTitle.Size = UDim2.new(1, 0, 0, 30); GMTitle.TextXAlignment = Enum.TextXAlignment.Center

                local GMCheckHolder = NewFrame(GMCard, UDim2.new(1, -16, 0, 200), UDim2.new(0, 8, 0, 32), PANEL, 1)
                Instance.new("UIListLayout", GMCheckHolder).Padding = UDim.new(0, 4)

                local function AddGMToggle(label, cfg)
                    local isLocked = false
                    if IsBronxDuels() and cfg ~= "NoRecoil" then
                        isLocked = true
                    elseif IsDuelist() and cfg == "RapidFire" then
                        isLocked = true
                    end

                    local row = NewBtn(GMCheckHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
                    Corner(row, 5)
                    local checked = not isLocked and _G.GUN_MODS_CFG[cfg]
                    if isLocked then
                        _G.GUN_MODS_CFG[cfg] = false
                    end

                    local cbBg = NewFrame(row, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7),
                        isLocked and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(36, 36, 48))
                    Corner(cbBg, 3); Stroke(cbBg, isLocked and Color3.fromRGB(50, 40, 40) or STROKE2, 1)
                    local cbCheck = NewLabel(cbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
                    cbCheck.Size = UDim2.new(1, 0, 1, 0); cbCheck.Visible = checked

                    local rowLbl = NewLabel(row, label, 13, TEXT)
                    rowLbl.Position = UDim2.new(0, 32, 0, 0)
                    rowLbl.Size = UDim2.new(1, -40, 1, 0)
                    rowLbl.TextScaled = true
                    local gFit = Instance.new("UITextSizeConstraint")
                    gFit.MaxTextSize = 13
                    gFit.MinTextSize = 8
                    gFit.Parent = rowLbl

                    if not isLocked then
                        row.MouseButton1Click:Connect(function()
                            checked = not checked; _G.GUN_MODS_CFG[cfg] = checked; cbCheck.Visible = checked
                            Tw(cbBg, 0.1, "Quad", "Out",
                                { BackgroundColor3 = checked and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48) })
                        end)
                        row.MouseEnter:Connect(function()
                            Tw(row, 0.1, "Quad", "Out",
                                { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
                        end)
                        row.MouseLeave:Connect(function()
                            Tw(row, 0.1, "Quad", "Out",
                                { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
                        end)
                    else
                        row.MouseButton1Click:Connect(function()
                            NOTIFY("Guns Mods", label .. " esta desactivado por riesgo de ban.", 3)
                        end)
                    end
                end

                AddGMToggle("No Recoil", "NoRecoil")
                AddGMToggle("No Spread", "NoSpread")
                AddGMToggle("Rapid Fire", "RapidFire")
                AddGMToggle("Force Automatic", "Automatic")
                AddGMToggle("Infinite Ammo", "InfiniteAmmo")
            end

            if IsMurderVsSheriff() then
                BuildInstaKillCard()
            elseif IsHitmark() or IsBronxDuels() or IsDuelist() then
                (function()
                    local RightCol = NewFrame(SilentPage, UDim2.new(0.45, -5, 1, 0), UDim2.new(0, 0, 0, 0), PANEL, 1)
                    local colLayout = Instance.new("UIListLayout", RightCol)
                    colLayout.Padding = UDim.new(0, 10)
                    colLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    BuildGunsModsCard(RightCol)

                    local function BuildExtrasCard()
                        local EXCard = NewFrame(RightCol, UDim2.new(1, 0, 0, 120), UDim2.new(0, 0, 0, 0), PANEL)
                        Corner(EXCard, 8); Stroke(EXCard, STROKE, 1)

                        local EXTitle = NewLabel(EXCard, "Extras", 13, TEXT, true)
                        EXTitle.Size = UDim2.new(1, 0, 0, 30); EXTitle.TextXAlignment = Enum.TextXAlignment.Center

                        local EXHolder = NewFrame(EXCard, UDim2.new(1, -16, 0, 80), UDim2.new(0, 8, 0, 32), PANEL, 1)

                        local listLayout = Instance.new("UIListLayout", EXHolder)
                        listLayout.Padding = UDim.new(0, 4)
                        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

                        -- 1. Equip KillFX
                        local ddRow1 = NewFrame(EXHolder, UDim2.new(1, 0, 0, 32), nil, PANEL, 1)
                        ddRow1.ZIndex = 5
                        local lbl1 = NewLabel(ddRow1, "Equip KillFX", 13, TEXT)
                        lbl1.Size = UDim2.new(0.4, 0, 1, 0)
                        local ddContainer1 = NewFrame(ddRow1, UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0), PANEL, 1)
                        local currentFX = _G.CURRENT_KILLFX or "None"
                        local dd1 = AddDropdown(ddContainer1,
                            { "None", "Swirl Purple", "Sparks", "Confetti", "Booster", "Virus" }, currentFX, function(v)
                                _G.CURRENT_KILLFX = v
                                if v ~= "None" then
                                    pcall(function()
                                        local Event = game:GetService("ReplicatedStorage").BridgeNet2.dataRemoteEvent
                                        Event:FireServer({ { action = "CurrentKillFX", payload = v }, "\x02" })
                                    end)
                                end
                            end)
                        dd1.Size = UDim2.new(1, 0, 0, 32)
                        dd1.Position = UDim2.new(0, 0, 0.5, -16)

                        -- 2. Visual Material Changer
                        local ddRow2 = NewFrame(EXHolder, UDim2.new(1, 0, 0, 32), nil, PANEL, 1)
                        ddRow2.ZIndex = 4
                        local lbl2 = NewLabel(ddRow2, "Weapon Skin", 13, TEXT)
                        lbl2.Size = UDim2.new(0.4, 0, 1, 0)
                        local ddContainer2 = NewFrame(ddRow2, UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0), PANEL, 1)
                        local matSkins = { "Default", "Neon Cyan", "Neon Pink", "Neon Green", "ForceField Cyan",
                            "ForceField Pink", "Solid Gold", "Glass", "Ice" }
                        local currentMat = _G.CURRENT_VISUAL_MAT or "Default"
                        local dd2 = AddDropdown(ddContainer2, matSkins, currentMat, function(v)
                            _G.CURRENT_VISUAL_MAT = v
                        end)
                        dd2.Size = UDim2.new(1, 0, 0, 32)
                        dd2.Position = UDim2.new(0, 0, 0.5, -16)
                    end
                    if IsHitmark() then
                        BuildExtrasCard()
                    end
                end)()
            end
        else
            local msg = NewLabel(SilentPage, "Silent Aim not available in this game. Use Aimbot.", 13, DIM, true,
                Enum.TextXAlignment.Center)
            msg.Size = UDim2.new(1, 0, 1, 0)
        end
    end)()

    -- BUILD KILL AURA PAGE
    ;(function()
        local KAPage = tabPages[3]
        if IsHitmark() or IsDuelist() then
            -- Column Containers for Horizontal Page Layout
            local LeftCol = NewFrame(KAPage, UDim2.new(0.53, -5, 1, 0), nil, BG, 1)
            LeftCol.LayoutOrder = 1
            local LeftColLayout = Instance.new("UIListLayout", LeftCol)
            LeftColLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftColLayout.Padding = UDim.new(0, 10)

            local RightCol = NewFrame(KAPage, UDim2.new(0.45, -5, 1, 0), nil, BG, 1)
            RightCol.LayoutOrder = 2
            local RightColLayout = Instance.new("UIListLayout", RightCol)
            RightColLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightColLayout.Padding = UDim.new(0, 10)

            local KCard = NewFrame(LeftCol, UDim2.new(1, 0, 0, 218), nil, PANEL)
            KCard.LayoutOrder = 1
            Corner(KCard, 8); Stroke(KCard, STROKE, 1)
            local KTitle = NewLabel(KCard, "Auto Kill Aura", 13, TEXT, true)
            KTitle.Size = UDim2.new(1, 0, 0, 30); KTitle.TextXAlignment = Enum.TextXAlignment.Center

            local KHolder = NewFrame(KCard, UDim2.new(1, -16, 0, 168), UDim2.new(0, 8, 0, 32), PANEL, 1)
            Instance.new("UIListLayout", KHolder).Padding = UDim.new(0, 6)

            _G.KILLAURA_CFG.Keybind = _G.KILLAURA_CFG.Keybind or Enum.KeyCode.None
            local kaCheck = AddCardSetting(KHolder, "Enable Auto Kill Aura", _G.KILLAURA_CFG.Enabled, function(v)
                _G.KILLAURA_CFG.Enabled = v
            end, _G.KILLAURA_CFG.Keybind, function(k)
                _G.KILLAURA_CFG.Keybind = k
            end)
            
            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                if kaCheck then
                    local active = _G.KILLAURA_CFG.Enabled
                    local cbBg = kaCheck:FindFirstChildOfClass("Frame")
                    local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                    if cbCheck then cbCheck.Visible = active end
                    if cbBg then
                        cbBg.BackgroundColor3 = active and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(36, 36, 48)
                    end

                    local kbBox = kaCheck:FindFirstChild("KeybindBox")
                    local bindLbl = kbBox and kbBox:FindFirstChild("BindLabel")
                    if bindLbl then
                        local keyName = "None"
                        local kb = _G.KILLAURA_CFG.Keybind
                        if kb then
                            if typeof(kb) == "EnumItem" then
                                keyName = (kb == Enum.KeyCode.None) and "None" or kb.Name
                            else
                                keyName = tostring(kb)
                            end
                        end
                        bindLbl.Text = keyName
                    end
                end
            end)

            -- Wallbang Toggle
            local wrow = NewBtn(KHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
            Corner(wrow, 5)
            local wcbBg = NewFrame(wrow, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7), Color3.fromRGB(36, 36, 48))
            Corner(wcbBg, 3); Stroke(wcbBg, STROKE2, 1)
            local wcbCheck = NewLabel(wcbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
            wcbCheck.Size = UDim2.new(1, 0, 1, 0); wcbCheck.Visible = _G.KILLAURA_CFG.Wallbang
            local wrowLbl = NewLabel(wrow, "Shoot through Walls (Wallbang)", 13, TEXT)
            wrowLbl.Size = UDim2.new(1, -40, 1, 0); wrowLbl.Position = UDim2.new(0, 35, 0, 0)
            wrowLbl.TextScaled = true
            local wFit = Instance.new("UITextSizeConstraint")
            wFit.MaxTextSize = 13
            wFit.MinTextSize = 8
            wFit.Parent = wrowLbl

            wrow.MouseButton1Click:Connect(function()
                _G.KILLAURA_CFG.Wallbang = not _G.KILLAURA_CFG.Wallbang
                wcbCheck.Visible = _G.KILLAURA_CFG.Wallbang
                Tw(wcbBg, 0.1, "Quad", "Out",
                    {
                        BackgroundColor3 = _G.KILLAURA_CFG.Wallbang and Color3.fromRGB(48, 50, 70) or
                            Color3.fromRGB(36, 36, 48)
                    })
            end)

            -- Range Slider
            AddCardSlider(KHolder, "Kill Aura Radius (Studs)", 10, 1000, _G.KILLAURA_CFG.MaxDist, function(val)
                _G.KILLAURA_CFG.MaxDist = val
            end)

            -- Legit vs Blatant Dropdown
            _G.KILLAURA_CFG.AuraType = _G.KILLAURA_CFG.AuraType or "Legit"
            local ddRowType = NewFrame(KHolder, UDim2.new(1, 0, 0, 32), nil, BG, 1)
            local ddType = AddDropdown(ddRowType, { "Legit", "Blatant", "Tele Kill" }, _G.KILLAURA_CFG.AuraType,
                function(v)
                    _G.KILLAURA_CFG.AuraType = v
                    NOTIFY("Kill Aura", "Type: " .. v, 2)
                end)
            ddType.Size = UDim2.new(1, 0, 1, 0)

            -- [ TRIGGER BOT CARD ]
            local TCard = NewFrame(LeftCol, UDim2.new(1, 0, 0, 120), nil, PANEL)
            TCard.LayoutOrder = 2
            Corner(TCard, 8); Stroke(TCard, STROKE, 1)
            local TTitle = NewLabel(TCard, "Trigger Bot", 13, TEXT, true)
            TTitle.Size = UDim2.new(1, 0, 0, 30); TTitle.TextXAlignment = Enum.TextXAlignment.Center

            local THolder = NewFrame(TCard, UDim2.new(1, -16, 0, 80), UDim2.new(0, 8, 0, 32), PANEL, 1)
            local TLayout = Instance.new("UIListLayout", THolder)
            TLayout.Padding = UDim.new(0, 6)
            TLayout.SortOrder = Enum.SortOrder.LayoutOrder

            -- Checkbox and Keybind
            _G.TRIGGERBOT_CFG.Keybind = _G.TRIGGERBOT_CFG.Keybind or Enum.KeyCode.T
            local triggerCheck = AddCardSetting(THolder, "Enable Trigger Bot", _G.TRIGGERBOT_CFG.Enabled, function(v)
                _G.TRIGGERBOT_CFG.Enabled = v
            end, _G.TRIGGERBOT_CFG.Keybind, function(k)
                _G.TRIGGERBOT_CFG.Keybind = k
            end)
            triggerCheck.LayoutOrder = 1

            -- Dropdown
            _G.TRIGGERBOT_CFG.Mode = _G.TRIGGERBOT_CFG.Mode or "Legit"
            local ddRowTB = NewFrame(THolder, UDim2.new(1, 0, 0, 32), nil, BG, 1)
            ddRowTB.LayoutOrder = 2
            local ddTB = AddDropdown(ddRowTB, { "Legit", "Blatant" }, _G.TRIGGERBOT_CFG.Mode, function(v)
                _G.TRIGGERBOT_CFG.Mode = v
                NOTIFY("Trigger Bot", "Mode: " .. v, 2)
            end)
            ddTB.Size = UDim2.new(1, 0, 1, 0)

            _G.FLUX_UI_UPDATE_FUNCS = _G.FLUX_UI_UPDATE_FUNCS or {}
            table.insert(_G.FLUX_UI_UPDATE_FUNCS, function()
                if triggerCheck then
                    local active = _G.TRIGGERBOT_CFG.Enabled
                    local cbBg = triggerCheck:FindFirstChildOfClass("Frame")
                    local cbCheck = cbBg and cbBg:FindFirstChildOfClass("TextLabel")
                    if cbCheck then cbCheck.Visible = active end
                    if cbBg then
                        cbBg.BackgroundColor3 = active and Color3.fromRGB(48, 50, 70) or Color3.fromRGB(36, 36, 48)
                    end

                    local kbBox = triggerCheck:FindFirstChild("KeybindBox")
                    local bindLbl = kbBox and kbBox:FindFirstChild("BindLabel")
                    if bindLbl then
                        local keyName = "None"
                        local kb = _G.TRIGGERBOT_CFG.Keybind
                        if kb then
                            if typeof(kb) == "EnumItem" then
                                keyName = (kb == Enum.KeyCode.None) and "None" or kb.Name
                            else
                                keyName = tostring(kb)
                            end
                        end
                        bindLbl.Text = keyName
                    end
                end
            end)

            if IsDuelist() then
                local HCard = NewFrame(RightCol, UDim2.new(1, 0, 0, 218), nil, PANEL)
                HCard.LayoutOrder = 1
                Corner(HCard, 8); Stroke(HCard, STROKE, 1)
                local HTitle = NewLabel(HCard, "HitBox Expander", 13, TEXT, true)
                HTitle.Size = UDim2.new(1, 0, 0, 30); HTitle.TextXAlignment = Enum.TextXAlignment.Center

                local HHolder = NewFrame(HCard, UDim2.new(1, -16, 0, 168), UDim2.new(0, 8, 0, 32), PANEL, 1)
                local HLayout = Instance.new("UIListLayout", HHolder)
                HLayout.Padding = UDim.new(0, 6)
                HLayout.SortOrder = Enum.SortOrder.LayoutOrder

                -- 1. Enable Toggle
                local hrow = NewBtn(HHolder, UDim2.new(1, 0, 0, 34), nil, Color3.fromRGB(32, 32, 42), 1)
                hrow.LayoutOrder = 1
                Corner(hrow, 5)
                local hcbBg = NewFrame(hrow, UDim2.new(0, 15, 0, 15), UDim2.new(0, 10, 0.5, -7),
                    Color3.fromRGB(36, 36, 48))
                Corner(hcbBg, 3); Stroke(hcbBg, STROKE2, 1)
                local hcbCheck = NewLabel(hcbBg, "✓", 10, ACCENT, true, Enum.TextXAlignment.Center)
                hcbCheck.Size = UDim2.new(1, 0, 1, 0); hcbCheck.Visible = _G.HITBOX_CFG.Enabled
                if _G.HITBOX_CFG.Enabled then
                    hcbBg.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                end
                local hrowLbl = NewLabel(hrow, "Enable HitBox Expander", 13, TEXT)
                hrowLbl.Size = UDim2.new(1, -40, 1, 0); hrowLbl.Position = UDim2.new(0, 35, 0, 0)
                hrowLbl.TextScaled = true
                local hFit = Instance.new("UITextSizeConstraint")
                hFit.MaxTextSize = 13
                hFit.MinTextSize = 8
                hFit.Parent = hrowLbl

                hrow.MouseButton1Click:Connect(function()
                    _G.HITBOX_CFG.Enabled = not _G.HITBOX_CFG.Enabled
                    hcbCheck.Visible = _G.HITBOX_CFG.Enabled
                    Tw(hcbBg, 0.1, "Quad", "Out",
                        {
                            BackgroundColor3 = _G.HITBOX_CFG.Enabled and Color3.fromRGB(255, 60, 60) or
                                Color3.fromRGB(36, 36, 48)
                        })
                end)
                hrow.MouseEnter:Connect(function()
                    Tw(hrow, 0.1, "Quad", "Out",
                        { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(60, 60, 80) })
                end)
                hrow.MouseLeave:Connect(function()
                    Tw(hrow, 0.1, "Quad", "Out",
                        { BackgroundTransparency = 0.99, BackgroundColor3 = Color3.fromRGB(32, 32, 42) })
                end)

                -- 2. Size Slider
                local sliderRow = AddCardSlider(HHolder, "Hitbox Size", 1, 50, _G.HITBOX_CFG.Size, function(val)
                    _G.HITBOX_CFG.Size = val
                end)
                sliderRow.LayoutOrder = 2

                -- 3. Body Part Dropdown (options: head, uptorso)
                local ddRowPart = NewFrame(HHolder, UDim2.new(1, 0, 0, 32), nil, BG, 1)
                ddRowPart.LayoutOrder = 3
                local ddPart = AddDropdown(ddRowPart, { "head", "UpperTorso" }, _G.HITBOX_CFG.Part, function(v)
                    _G.HITBOX_CFG.Part = v
                    NOTIFY("Hitbox Part", "Part: " .. v, 2)
                end)
                ddPart.Size = UDim2.new(1, 0, 1, 0)
            end
        else
            local msg = NewLabel(KAPage, "Kill Aura not available in this game.", 13, DIM, true,
                Enum.TextXAlignment.Center)
            msg.Size = UDim2.new(1, 0, 1, 0)
        end
    end)()

    local function AddGlass(parent)
        parent.ClipsDescendants = true
        local g = Instance.new("ImageLabel")
        g.Name = "GlassLayer"
        g.Size = UDim2.new(1, 0, 1, 0)
        g.BackgroundTransparency = 1
        g.Image = "rbxassetid://10881905308" -- Glassmorphism texture
        g.ImageTransparency = 1
        g.ScaleType = Enum.ScaleType.Slice
        g.SliceCenter = Rect.new(49, 49, 450, 450)
        g.SliceScale = 0.15
        g.ZIndex = 0
        g.Parent = parent
        return g
    end

    Sidebar.ClipsDescendants = true
    RightBox.ClipsDescendants = true
    local gSide = AddGlass(Sidebar)
    local gRight = AddGlass(RightBox)


    local function UpdateBlur()
        local strength = blurVal / 100
        local glassTarget = blurActive and (1 - strength * 0.6) or 1

        Tw(gSide, 0.1, "Linear", "Out", { ImageTransparency = glassTarget, ImageColor3 = Color3.new(0, 0, 0) })
        Tw(gRight, 0.1, "Linear", "Out", { ImageTransparency = glassTarget, ImageColor3 = Color3.new(0, 0, 0) })

        local panelTrans = blurActive and (strength * 0.7) or 0

        Tw(Root, 0.1, "Linear", "Out", { BackgroundTransparency = 1 }) -- Keep Root transparent to avoid black box
        Tw(Sidebar, 0.1, "Linear", "Out", { BackgroundTransparency = panelTrans })
        Tw(RightBox, 0.1, "Linear", "Out", { BackgroundTransparency = panelTrans })
    end

    ; (function()
        local function GetImageAsset(id)
            if typeof(id) == "string" then
                local cleanId = id:match("%d+")
                if cleanId then
                    return "rbxassetid://" .. cleanId
                end
            elseif typeof(id) == "number" then
                return "rbxassetid://" .. tostring(id)
            end
            return ""
        end

        local previewImageLabel
        UpdatePreview = function()
            local id = _G.CUSTOM_BG_ID
            if previewImageLabel then
                local asset = GetImageAsset(id)
                if asset ~= "" then
                    previewImageLabel.Image = asset
                    previewImageLabel.ImageTransparency = 0
                else
                    previewImageLabel.Image = ""
                end
            end
        end

        UpdateCustomBackground = function()
            local enabled = _G.CUSTOM_BG_ENABLED
            local id = _G.CUSTOM_BG_ID
            local trans = _G.CUSTOM_BG_TRANSPARENCY or 0

            if SidebarBgImage and RightBoxBgImage then
                if enabled and id ~= "" then
                    local asset = GetImageAsset(id)
                    if asset ~= "" then
                        SidebarBgImage.Image = asset
                        SidebarBgImage.ImageTransparency = trans / 100
                        SidebarBgImage.Visible = true

                        RightBoxBgImage.Image = asset
                        RightBoxBgImage.ImageTransparency = trans / 100
                        RightBoxBgImage.Visible = true
                    else
                        SidebarBgImage.Visible = false
                        RightBoxBgImage.Visible = false
                    end
                else
                    SidebarBgImage.Visible = false
                    RightBoxBgImage.Visible = false
                end
            end
            if UpdateBlur then UpdateBlur() end
        end

        -- Custom Background Settings Card (Left Column, below prefCard)
        local customBgCard = NewFrame(uiPage, UDim2.new(0.46, 0, 0, 220), UDim2.new(0, 1, 0, prefHeight + 10), PANEL)
        Corner(customBgCard, 8)
        Stroke(customBgCard, STROKE, 1)

        local customBgTitle = NewLabel(customBgCard, "Background Image", 13, TEXT, true)
        customBgTitle.Name = "SectionTitle"
        customBgTitle.Size = UDim2.new(1, 0, 0, 30)
        customBgTitle.TextXAlignment = Enum.TextXAlignment.Center

        local customBgContent = NewFrame(customBgCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
        local customBgList = Instance.new("UIListLayout", customBgContent)
        customBgList.Padding = UDim.new(0, 6)
        customBgList.SortOrder = Enum.SortOrder.LayoutOrder

        -- TextBox wrapper (defined early to reference in toggle)
        local tbWrap = NewFrame(customBgContent, UDim2.new(1, 0, 0, 30), nil, Color3.fromRGB(15, 15, 20))
        tbWrap.LayoutOrder = 2
        Corner(tbWrap, 5)
        Stroke(tbWrap, STROKE2, 1)

        local idTextBox = Instance.new("TextBox")
        idTextBox.Size = UDim2.new(1, -16, 1, 0)
        idTextBox.Position = UDim2.new(0, 8, 0, 0)
        idTextBox.BackgroundTransparency = 1
        idTextBox.BorderSizePixel = 0
        idTextBox.TextColor3 = TEXT
        idTextBox.PlaceholderColor3 = DIM
        idTextBox.PlaceholderText = "Roblox ID..."
        idTextBox.Text = _G.CUSTOM_BG_ID or ""
        idTextBox.TextSize = 11
        idTextBox.Font = Enum.Font.Gotham
        idTextBox.ClearTextOnFocus = false
        idTextBox.Parent = tbWrap

        -- 1. Enable Toggle
        local enableBgToggle = AddCardSetting(customBgContent, "Enable Background", _G.CUSTOM_BG_ENABLED, function(v)
            _G.CUSTOM_BG_ENABLED = v
            _G.CUSTOM_BG_ID = idTextBox.Text
            UpdatePreview()
            UpdateCustomBackground()
            SaveUI()
        end)
        enableBgToggle.LayoutOrder = 1

        -- 3. Stretched Preview Container (Full Width)
        local previewContainer = NewFrame(customBgContent, UDim2.new(1, 0, 0, 70), nil, Color3.fromRGB(15, 15, 20))
        previewContainer.LayoutOrder = 3
        Corner(previewContainer, 6)
        Stroke(previewContainer, STROKE2, 1)

        previewImageLabel = Instance.new("ImageLabel")
        previewImageLabel.Size = UDim2.new(1, -8, 1, -8)
        previewImageLabel.Position = UDim2.new(0, 4, 0, 4)
        previewImageLabel.BackgroundTransparency = 1
        previewImageLabel.ScaleType = Enum.ScaleType.Crop
        Corner(previewImageLabel, 4)
        previewImageLabel.Parent = previewContainer

        -- Automatic update when focus lost
        idTextBox.FocusLost:Connect(function()
            _G.CUSTOM_BG_ID = idTextBox.Text
            UpdatePreview()
            if _G.CUSTOM_BG_ENABLED then
                UpdateCustomBackground()
            end
            SaveUI()
        end)

        -- 4. Opacity Slider
        local opacitySlider = AddCardSlider(customBgContent, "Background Opacity", 0, 100, _G.CUSTOM_BG_TRANSPARENCY or 0,
            function(v)
                _G.CUSTOM_BG_TRANSPARENCY = v
                UpdateCustomBackground()
                SaveUI()
            end)
        opacitySlider.LayoutOrder = 4
    end)()

    AddCardSetting(bgList.Parent, "Enable Transparency", blurActive, function(v)
        blurActive = v
        UpdateBlur()
        SaveUI()
    end).LayoutOrder = 1

    AddCardSlider(bgList.Parent, "Transparency", 0, 100, blurVal, function(v)
        blurVal = v
        UpdateBlur()
        SaveUI()
    end).LayoutOrder = 3

    ; (function()
        _G.FLUX_SNOW_ACTIVE = false

        local function CreateFlake()
            local f = Instance.new("Frame")
            f.Size = UDim2.new(0, math.random(2, 3), 0, math.random(2, 3))
            f.BackgroundColor3 = Color3.new(1, 1, 1)
            f.BackgroundTransparency = 1 -- Start invisible
            f.BorderSizePixel = 0
            Corner(f, 10)
            f.Parent = SnowHolder
            return f
        end

        local function RunSnow()
            task.spawn(function()
                while _G.FLUX_SNOW_ACTIVE do
                    if getgenv().FLUX_SESSION ~= MySession then break end
                    local f = CreateFlake()
                    local startX = 0.05 + (math.random() * 0.9)
                    f.Position = UDim2.new(startX, 0, 0, 0) -- Start at the very top edge

                    local duration = math.random(4, 7)
                    local drift = (math.random() - 0.5) * 0.1
                    local targetTrans = math.random(3, 6) / 10

                    -- Fade in at the start
                    Tw(f, 0.5, "Linear", "Out", { BackgroundTransparency = targetTrans })

                    -- Fall animation
                    f:TweenPosition(
                        UDim2.new(startX + drift, 0, 0.98, 0),
                        Enum.EasingDirection.In,
                        Enum.EasingStyle.Linear,
                        duration,
                        true,
                        function()
                            -- Fade out at the bottom
                            local t = Tw(f, 0.4, "Linear", "Out", { BackgroundTransparency = 1 })
                            task.wait(0.4)
                            f:Destroy()
                        end
                    )
                    task.wait(0.25)
                end
            end)
        end

        AddCardSetting(bgList.Parent, "Enable Snow", false, function(v)
            _G.FLUX_SNOW_ACTIVE = v
            if v then RunSnow() end
        end).LayoutOrder = 2
    end)()

    -- Panic Button Card
    ; (function()
        local panicCard = NewFrame(uiPage, UDim2.new(0.52, -4, 0, 80), UDim2.new(0.48, 1, 0, 173), PANEL)
        Corner(panicCard, 8)
        Stroke(panicCard, STROKE, 1)

        local panicTitle = NewLabel(panicCard, "Emergency Shutdown", 12, TEXT, true)
        panicTitle.Name = "SectionTitle"
        panicTitle.Size = UDim2.new(1, 0, 0, 30)
        panicTitle.TextXAlignment = Enum.TextXAlignment.Center

        local unloadBtn = NewBtn(panicCard, UDim2.new(1, -16, 0, 36), UDim2.new(0, 8, 0, 34), Color3.fromRGB(36, 36, 48))
        Corner(unloadBtn, 6)
        Stroke(unloadBtn, STROKE2, 1)

        local unloadLbl = NewLabel(unloadBtn, "CLOSE UI & STOP ALL", 11, TEXT, true, Enum.TextXAlignment.Center)
        unloadLbl.Size = UDim2.new(1, 0, 1, 0)

        unloadBtn.MouseButton1Click:Connect(function()
            NOTIFY("System", "Unloading script...", 2)

            -- Set session to nil to instantly terminate all background task while-loops
            getgenv().FLUX_SESSION = nil
            _G.FLUX_SNOW_ACTIVE = false

            -- Disconnect all game and input connections
            if _G.FLUX_CONNS then
                for _, c in pairs(_G.FLUX_CONNS) do
                    pcall(function() c:Disconnect() end)
                end
                _G.FLUX_CONNS = {}
            end

            task.wait(0.3)

            -- Master UNLOAD
            pcall(function() RunService:UnbindFromRenderStep("FluxAimbot") end)
            pcall(function() RunService:UnbindFromRenderStep("ForceFOV_OMEGA") end)
            if FOV_CIRCLE then pcall(function() FOV_CIRCLE:Destroy() end) end

            if _G.ESP_LOOP then
                _G.ESP_LOOP:Disconnect(); _G.ESP_LOOP = nil
            end
            if _G.ESP_CACHE then
                for _, e in pairs(_G.ESP_CACHE) do
                    pcall(function() e.FRM:Destroy() end)
                    pcall(function() e.BOX:Destroy() end)
                    pcall(function() e.FILL:Destroy() end)
                    if e.CHAM then pcall(function() e.CHAM:Destroy() end) end
                    if e.TCHAM then pcall(function() e.TCHAM:Destroy() end) end
                end
                _G.ESP_CACHE = nil
            end

            -- Keybind HUD Cleanup
            if _G.FLUX_KB_HUD_GUI then
                pcall(function() _G.FLUX_KB_HUD_GUI:Destroy() end)
                _G.FLUX_KB_HUD_GUI = nil
            end

            -- Silent Aim Cleanup
            if _G.SILENT_CFG then _G.SILENT_CFG.Enabled = false end
            if silentFovCircle then pcall(function() silentFovCircle:Destroy() end) end

            pcall(function() ESP_HOLDER:Destroy() end)
            pcall(function() NotifySG:Destroy() end)
            pcall(function() SG:Destroy() end)

            -- Cleanup Mobile/Core components
            for _, v in pairs(CoreGui:GetChildren()) do
                if v.Name == "FluxUI" or v.Name == "MobileToggle" or v.Name == "NotifySG" then
                    pcall(function() v:Destroy() end)
                end
            end
            if PG and PG:FindFirstChild("MobileToggle") then
                pcall(function() PG.MobileToggle:Destroy() end)
            end
        end)
    end)()
end

-- Server Content
; (function()
    local srvPage = stPages[2]

    -- Card 1: Server Hop Options
    local hopCard = NewFrame(srvPage, UDim2.new(0.46, 0, 0, 180), UDim2.new(0, 1, 0, 3), PANEL)
    Corner(hopCard, 8)
    Stroke(hopCard, STROKE, 1)

    local hopTitle = NewLabel(hopCard, "Server Hop Options", 12, TEXT, true)
    hopTitle.Name = "SectionTitle"
    hopTitle.Size = UDim2.new(1, 0, 0, 30)
    hopTitle.TextXAlignment = Enum.TextXAlignment.Center

    local hopList = Instance.new("UIListLayout")
    hopList.Padding = UDim.new(0, 4)
    hopList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hopList.Parent = NewFrame(hopCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)

    local function SrvBtn(parent, txt, callback)
        local b = NewBtn(parent, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 0), Color3.fromRGB(36, 36, 48))
        Corner(b, 6)
        Stroke(b, STROKE2, 1)
        local l = NewLabel(b, txt, 11, TEXT, false, Enum.TextXAlignment.Center)
        l.Size = UDim2.new(1, 0, 1, 0)
        b.MouseButton1Click:Connect(function()
            NOTIFY("Server System", "Executing: " .. txt, 2)
            callback()
        end)
        b.MouseEnter:Connect(function() Tw(b, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) }) end)
        b.MouseLeave:Connect(function() Tw(b, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) }) end)
    end

    local function Hop(low)
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local url = "https://games.roblox.com/v1/games/" ..
            game.PlaceId .. "/servers/Public?sortOrder=" .. (low and "Asc" or "Desc") .. "&limit=100"
        local ok, Servers = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
        if ok and Servers and Servers.data then
            for _, s in pairs(Servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    break
                end
            end
        end
    end

    SrvBtn(hopList.Parent, "Rejoin Server", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)

    SrvBtn(hopList.Parent, "Standard Server Hop", function()
        Hop(false)
    end)

    SrvBtn(hopList.Parent, "Low Player Hop", function()
        Hop(true)
    end)

    -- Card 2: Server Information
    local infoCard = NewFrame(srvPage, UDim2.new(0.52, -4, 0, 180), UDim2.new(0.48, 1, 0, 3), PANEL)
    Corner(infoCard, 8)
    Stroke(infoCard, STROKE, 1)

    local infoTitle = NewLabel(infoCard, "Server Information", 12, TEXT, true)
    infoTitle.Name = "SectionTitle"
    infoTitle.Size = UDim2.new(1, 0, 0, 30)
    infoTitle.TextXAlignment = Enum.TextXAlignment.Center

    local infoContent = NewFrame(infoCard, UDim2.new(1, -16, 1, -40), UDim2.new(0, 8, 0, 32), BG, 1)
    local infoList = Instance.new("UIListLayout")
    infoList.Padding = UDim.new(0, 2)
    infoList.Parent = infoContent

    local function InfoRow(label, initial, ratio)
        ratio = ratio or 0.4
        local row = NewFrame(infoContent, UDim2.new(1, 0, 0, 22), nil, BG, 1)
        row.ClipsDescendants = true
        local l = NewLabel(row, label .. ":", 11, DIM)
        l.Size = UDim2.new(ratio, 0, 1, 0)
        local v = NewLabel(row, initial, 10, TEXT, false, Enum.TextXAlignment.Right)
        v.Size = UDim2.new(1 - ratio, 0, 1, 0)
        v.Position = UDim2.new(ratio, 0, 0, 0)
        v.TextScaled = true
        v.TextTruncate = Enum.TextTruncate.AtEnd
        local fit = Instance.new("UITextSizeConstraint")
        fit.MaxTextSize = 10
        fit.MinTextSize = 7
        fit.Parent = v
        return v
    end

    local jobIdVal = InfoRow("JobId", game.JobId, 0.2)
    local playersVal = InfoRow("Players",
        #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers)
    local pingVal = InfoRow("Ping", "0ms")
    local uptimeVal = InfoRow("Time in Server", "0s")

    -- Copy JobId Button
    local copyBtn = NewBtn(infoContent, UDim2.new(1, 0, 0, 28), nil, Color3.fromRGB(40, 40, 52))
    Corner(copyBtn, 6)
    Stroke(copyBtn, STROKE2, 1)
    local copyLbl = NewLabel(copyBtn, "Copy JobId", 11, TEXT, true, Enum.TextXAlignment.Center)
    copyLbl.Size = UDim2.new(1, 0, 1, 0)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(game.JobId)
            NOTIFY("Server Info", "JobId copied to clipboard!", 2)
        end
    end)

    -- Real-time Updates
    task.spawn(function()
        while task.wait(1) and infoCard.Parent do
            if getgenv().FLUX_SESSION ~= MySession then break end
            playersVal.Text = #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            pingVal.Text = ping .. "ms"

            local t = math.floor(workspace.DistributedGameTime)
            local h = math.floor(t / 3600)
            local m = math.floor((t % 3600) / 60)
            local s = t % 60
            uptimeVal.Text = string.format("%02dh %02dm %02ds", h, m, s)
        end
    end)

    -- Card 3: Server Browser (New Premium Feature)
    local function CreateServerBrowser()
        local srvListCard = NewFrame(srvPage, UDim2.new(0.46, 0, 0, 140), UDim2.new(0, 1, 0, 193), PANEL)
        Corner(srvListCard, 8)
        Stroke(srvListCard, STROKE, 1)

        local srvListTitle = NewLabel(srvListCard, "Server Browser", 12, TEXT, true)
        srvListTitle.Name = "SectionTitle"
        srvListTitle.Size = UDim2.new(1, 0, 0, 30)
        srvListTitle.TextXAlignment = Enum.TextXAlignment.Center

        -- Dropdown Frame
        local srvDropdown = NewFrame(srvListCard, UDim2.new(1, -24, 0, 32), UDim2.new(0, 12, 0, 38),
            Color3.fromRGB(32, 32, 44))
        Corner(srvDropdown, 6)
        Stroke(srvDropdown, STROKE2, 1)

        local srvSelLbl = NewLabel(srvDropdown, "Select a server...", 11, TEXT)
        srvSelLbl.Position = UDim2.new(0, 10, 0, 0)
        srvSelLbl.Size = UDim2.new(1, -30, 1, 0)

        local srvArrow = Instance.new("ImageLabel")
        srvArrow.Name = "Arrow"
        srvArrow.BackgroundTransparency = 1
        srvArrow.Size = UDim2.new(0, 12, 0, 12)
        srvArrow.Position = UDim2.new(1, -22, 0.5, -6)
        srvArrow.Image = "rbxassetid://6034818372"
        srvArrow.ImageColor3 = DIM
        srvArrow.Parent = srvDropdown

        local srvDropdownBtn = NewBtn(srvDropdown, UDim2.new(1, 0, 1, 0), nil, BG, 1)

        -- Popup List container (parented to srvDropdown)
        local srvPopup = NewFrame(srvDropdown, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 4), Color3.fromRGB(28, 28, 38))
        srvPopup.ZIndex = 500
        srvPopup.Visible = false
        srvPopup.ClipsDescendants = true
        Corner(srvPopup, 6)
        Stroke(srvPopup, STROKE2, 1)

        local srvScroll = NewScroll(srvPopup, UDim2.new(1, 0, 1, 0), nil, BG, 1)
        local srvListLayout = Instance.new("UIListLayout", srvScroll)
        srvListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local fetchedServers = {}
        local srvOpen = false
        local srvPopH = 120
        local srvOptH = 26

        local function srvClose()
            srvOpen = false
            Tw(srvPopup, 0.15, "Quad", "Out", { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.16, function() srvPopup.Visible = false end)
            Tw(srvArrow, 0.15, "Quad", "Out", { Rotation = 0 })
        end

        local function PopulateServers(listTable)
            for _, c in ipairs(srvPopup:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            if #listTable == 0 then
                srvSelLbl.Text = "No servers found."
                return
            end
            for i, sv in ipairs(listTable) do
                local ob = NewBtn(srvPopup, UDim2.new(1, 0, 0, srvOptH), nil, Color3.fromRGB(45, 45, 60), 1)
                ob.LayoutOrder = i
                ob.ZIndex = 501
                local t = string.format("%d/%d Players | Ping: %d", sv.playing, sv.maxPlayers, sv.ping)
                local ol = NewLabel(ob, t, 11, TEXT)
                ol.Position = UDim2.new(0, 10, 0, 0)
                ol.Size = UDim2.new(1, -10, 1, 0)
                ol.ZIndex = 502

                ob.MouseEnter:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 0.5 }) end)
                ob.MouseLeave:Connect(function() Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 1 }) end)

                ob.MouseButton1Click:Connect(function()
                    srvSelLbl.Text = "Joining..."
                    srvClose()
                    pcall(function()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sv.id,
                            game.Players.LocalPlayer)
                    end)
                end)
            end
            if srvOpen then
                local targetH = math.min(#listTable * srvOptH, srvPopH)
                Tw(srvPopup, 0.15, "Quad", "Out", { Size = UDim2.new(1, 0, 0, targetH) })
            end
        end

        local function fetchServers(sortOrder)
            local Http = game:GetService("HttpService")
            local url = "https://games.roblox.com/v1/games/" ..
                game.PlaceId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
            local ok, res = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
            if ok and res and res.data then
                local list = {}
                for _, s in ipairs(res.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(list, {
                            id = s.id,
                            playing = s.playing,
                            maxPlayers = s.maxPlayers,
                            ping = s.ping or 0
                        })
                    end
                end
            end

            for i, srv in ipairs(fetchedServers) do
                local ob = NewBtn(srvScroll, UDim2.new(1, 0, 0, srvOptH), nil, Color3.fromRGB(45, 45, 60), 1)
                ob.LayoutOrder = i
                ob.ZIndex = 501

                local srvText = string.format("Server #%d (%d/%d) - %dms", i, srv.players, srv.max, srv.ping)
                local ol = NewLabel(ob, srvText, 11, TEXT)
                ol.Position = UDim2.new(0, 10, 0, 0)
                ol.Size = UDim2.new(1, -10, 1, 0)
                ol.ZIndex = 502

                ob.MouseButton1Click:Connect(function()
                    srvSelLbl.Text = string.format("Server #%d (%d/%d)", i, srv.players, srv.max)
                    srvClose()
                    NOTIFY("Server Teleport", "Teleporting to Server #" .. i .. "...", 3)
                    task.wait(0.5)
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                end)

                ob.MouseEnter:Connect(function()
                    Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 0.5 })
                end)
                ob.MouseLeave:Connect(function()
                    Tw(ob, 0.07, "Quad", "Out", { BackgroundTransparency = 1 })
                end)
            end
        end

        local function HandleFilter(sortOrder)
            srvSelLbl.Text = "Fetching servers..."
            srvClose()
            task.spawn(function()
                local success = FetchServers(sortOrder)
                if success then
                    srvSelLbl.Text = "Select a server (" .. #fetchedServers .. " found)"
                    RebuildSrvPopup()
                else
                    srvSelLbl.Text = "Failed to fetch servers!"
                    fetchedServers = {}
                    RebuildSrvPopup()
                end
            end)
        end

        local isCooldown = false

        local function FilterBtn(parent, size, pos, txt, callback)
            local b = NewBtn(parent, size, pos, Color3.fromRGB(36, 36, 48))
            Corner(b, 6)
            Stroke(b, STROKE2, 1)
            local l = NewLabel(b, txt, 11, TEXT, false, Enum.TextXAlignment.Center)
            l.Size = UDim2.new(1, 0, 1, 0)
            b.MouseButton1Click:Connect(function()
                if isCooldown then return end
                callback()
            end)
            b.MouseEnter:Connect(function()
                if not isCooldown then
                    Tw(b, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                end
            end)
            b.MouseLeave:Connect(function()
                Tw(b, 0.1, "Quad", "Out", { BackgroundColor3 = Color3.fromRGB(36, 36, 48) })
            end)
            return b
        end

        local lowBtn, fullBtn

        local function RunFilter(sortOrder)
            if isCooldown then return end
            isCooldown = true

            local lowLbl = lowBtn:FindFirstChildOfClass("TextLabel")
            local fullLbl = fullBtn:FindFirstChildOfClass("TextLabel")

            HandleFilter(sortOrder)

            task.spawn(function()
                for i = 3, 1, -1 do
                    if lowLbl then lowLbl.Text = "Wait (" .. i .. "s)" end
                    if fullLbl then fullLbl.Text = "Wait (" .. i .. "s)" end
                    task.wait(1)
                end
                if lowLbl then lowLbl.Text = "Low Servers" end
                if fullLbl then fullLbl.Text = "Full Servers" end
                isCooldown = false
            end)
        end

        lowBtn = FilterBtn(srvListCard, UDim2.new(0.5, -16, 0, 32), UDim2.new(0, 12, 1, -44), "Low Servers", function()
            RunFilter("Asc")
        end)

        fullBtn = FilterBtn(srvListCard, UDim2.new(0.5, -16, 0, 32), UDim2.new(0.5, 4, 1, -44), "Full Servers",
            function()
                RunFilter("Desc")
            end)

        srvDropdownBtn.MouseButton1Click:Connect(function()
            srvOpen = not srvOpen
            if srvOpen then
                srvPopup.Visible = true

                local targetH = math.min(#fetchedServers * srvOptH, srvPopH)
                if #fetchedServers == 0 then targetH = srvOptH end

                Tw(srvPopup, 0.18, "Quad", "Out", { Size = UDim2.new(1, 0, 0, targetH) })
                Tw(srvArrow, 0.18, "Quad", "Out", { Rotation = 180 })
            else
                srvClose()
            end
        end)

        UIS.InputBegan:Connect(function(inp, gp)
            if not srvOpen or gp then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                task.wait()
                local mx, my = inp.Position.X, inp.Position.Y
                local function hit(f)
                    return mx >= f.AbsolutePosition.X and mx <= f.AbsolutePosition.X + f.AbsoluteSize.X
                        and my >= f.AbsolutePosition.Y and my <= f.AbsolutePosition.Y + f.AbsoluteSize.Y
                end
                if not hit(srvDropdown) and not hit(srvPopup) then srvClose() end
            end
        end)
    end
    CreateServerBrowser()
end)()

-- Entrance Animation
Root.Size = UDim2.new(0, curW, 0, 0)
Tw(Root, 0.28, "Back", "Out", { Size = UDim2.new(0, curW, 0, curH) })

-- Visibility Toggle
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == toggleKey then
        uiVis = not uiVis
        if uiVis then
            Root.Visible = true
            Tw(Root, 0.35, "Back", "Out", { Position = UDim2.new(0.5, -curW / 2, 0.5, -curH / 2) })
        else
            Tw(Root, 0.25, "Quad", "In", { Position = UDim2.new(0.5, -curW / 2, -1.1, 0) })
            task.delay(0.26, function() if not uiVis then Root.Visible = false end end)
            if PICKER_MAIN then
                PICKER_MAIN.Visible = false
                PICKER_OPEN = false
            end
        end
        if _G.FLUX_KB_HUD_SYNC then _G.FLUX_KB_HUD_SYNC() end
    end
end)

-- Apply initial settings after UI is fully built
if ApplyUIPreferences then ApplyUIPreferences() end
-- ══════════════════ AIMBOT ENGINE ══════════════════
FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Color = ACCENT
FOV_CIRCLE.Thickness = 1
FOV_CIRCLE.NumSides = 64
FOV_CIRCLE.Radius = _G.AIMBOT_CFG.FOV
FOV_CIRCLE.Filled = false

local ignoreSilentRay = false

local function IsPositionVisible(origin, targetPos, targetChar, cam)
    local direction = targetPos - origin
    local distance = direction.Magnitude
    local dirUnit = direction.Unit

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = { LP.Character, targetChar, cam }
    rayParams.FilterDescendantsInstances = ignoreList

    local isBronx = IsBronxDuels()
    local currentOrigin = origin
    local remainingDist = distance
    local isVis = false
    local maxSteps = isBronx and 5 or 1

    for step = 1, maxSteps do
        ignoreSilentRay = true
        local res = workspace:Raycast(currentOrigin, dirUnit * remainingDist, rayParams)
        ignoreSilentRay = false

        if not res then
            isVis = true
            break
        end

        local hit = res.Instance
        if hit:IsDescendantOf(targetChar) then
            isVis = true
            break
        end

        -- Bypass non-collidable, transparent, or accessory/tracer/tool parts (only for Bronx Duels)
        if isBronx and (hit.CanCollide == false or hit.Transparency > 0.9 or hit.Name == "Bullet" or hit.Name == "Handle" or hit:IsA("Accessory") or hit:IsA("Tool")) then
            local currentFilter = rayParams.FilterDescendantsInstances
            table.insert(currentFilter, hit)
            rayParams.FilterDescendantsInstances = currentFilter

            currentOrigin = res.Position + dirUnit * 0.01
            remainingDist = (targetPos - currentOrigin).Magnitude
            if remainingDist < 0.05 then
                isVis = true
                break
            end
        else
            break
        end
    end
    return isVis
end

-- [ AIMBOT ENGINE ]
local function GetTarget()
    local cam = workspace.CurrentCamera
    local mousePos = UIS:GetMouseLocation()
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    -- Use center for Camera Aim, Mouse for Mouse Aim
    local refPos = (_G.AIMBOT_CFG.AimMode == "Camera Aim") and screenCenter or mousePos

    local target = nil
    local dist = _G.AIMBOT_CFG.FOV

    local function check(char)
        if not char or char == LP.Character then return end
        if IsIgnoredCharacter(char) then return end
        local targetPartName = _G.AIMBOT_CFG.TargetPart
        local hrp = char:FindFirstChild(targetPartName) or char:FindFirstChild("HumanoidRootPart") or
            char:FindFirstChild("Head")
        if not hrp then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if _G.AIMBOT_CFG.IgnoreDead and hum then
            if hum.Health <= 0.1 or char:GetAttribute("Downed") then return end
        end

        local pos, vis = cam:WorldToViewportPoint(hrp.Position)
        if IsBronxDuels() then
            if pos.Z <= 0 then return end
        else
            if not vis then return end
        end

        local mag = (Vector2.new(pos.X, pos.Y) - refPos).Magnitude
        if mag < dist then
            if _G.AIMBOT_CFG.VisibleCheck then
                if not IsPositionVisible(cam.CFrame.Position, hrp.Position, char, cam) then return end
            end

            local worldDist = (cam.CFrame.Position - hrp.Position).Magnitude
            if worldDist <= _G.AIMBOT_CFG.MaxDist then
                dist = mag
                target = char
            end
        end
    end

    local players = Players:GetPlayers()
    local hasActiveMatch = (_G.ACTIVE_MATCH_PLAYERS and next(_G.ACTIVE_MATCH_PLAYERS) ~= nil)
    for i = 1, #players do
        local p = players[i]
        if p ~= LP then
            if not hasActiveMatch or _G.ACTIVE_MATCH_PLAYERS[p.Name] then
                check(p.Character)
            end
        end
    end

    local bots = _G.BOT_LIST or {}
    for i = 1, #bots do
        check(bots[i])
    end
    return target
end

RunService:BindToRenderStep("FluxAimbot", 2002, function()
    if getgenv().FLUX_SESSION ~= MySession then
        RunService:UnbindFromRenderStep("FluxAimbot")
        return
    end

    local cam = workspace.CurrentCamera
    local mouse = UIS:GetMouseLocation()
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    if _G.AIMBOT_CFG.DrawFov then
        FOV_CIRCLE.Visible = true
        FOV_CIRCLE.Radius = _G.AIMBOT_CFG.FOV
        FOV_CIRCLE.Position = (_G.AIMBOT_CFG.AimMode == "Camera Aim") and center or mouse
        FOV_CIRCLE.Color = ACCENT
    else
        FOV_CIRCLE.Visible = false
    end

    if _G.AIMBOT_CFG.Enabled and isRmbDown then
        local targetChar = GetTarget()
        if targetChar then
            local targetPart = targetChar:FindFirstChild(_G.AIMBOT_CFG.TargetPart) or
                targetChar:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local aimPos = targetPart.Position
                local dist = (cam.CFrame.Position - aimPos).Magnitude

                -- Advanced Dynamic Prediction
                if _G.AIMBOT_CFG.Prediction then
                    local targetVel = targetPart.Velocity
                    local selfVel = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) and
                        LP.Character.HumanoidRootPart.Velocity or Vector3.new(0, 0, 0)
                    local relativeVel = targetVel - selfVel

                    -- Scale lead time by distance
                    local distFactor = dist / 100
                    local predictOffset = relativeVel * (_G.AIMBOT_CFG.PredictionAmount * distFactor)

                    -- Gravity/Drop Compensation
                    local dropComp = Vector3.new(0, (distFactor * distFactor) * 0.15, 0)
                    aimPos = aimPos + predictOffset + dropComp
                end

                local tPos, _ = cam:WorldToViewportPoint(aimPos)
                local tVector = Vector2.new(tPos.X, tPos.Y)

                -- Convert HitChance (0-100) to Smoothing (20-1)
                local s = 21 - (_G.AIMBOT_CFG.HitChance / 5)
                s = math.max(1, s)

                if _G.AIMBOT_CFG.AimMode == "Mouse Aim" then
                    local rcsOffset = _G.AIMBOT_CFG.RCS and Vector2.new(0, _G.AIMBOT_CFG.RCSAmount * 2.5) or
                        Vector2.new(0, 0)
                    local diff = (tVector - mouse) + rcsOffset
                    if mousemoverel then
                        mousemoverel(diff.X / (s * 1.5), diff.Y / (s * 1.5))
                    end
                else
                    -- CAMERA AIM FIX
                    local targetCF = CFrame.lookAt(cam.CFrame.Position, aimPos)
                    if _G.AIMBOT_CFG.RCS then
                        targetCF = targetCF * CFrame.Angles(math.rad(-_G.AIMBOT_CFG.RCSAmount), 0, 0)
                    end

                    if s <= 1.1 then
                        cam.CFrame = targetCF
                    else
                        cam.CFrame = cam.CFrame:Lerp(targetCF, 1 / s)
                    end
                end
            end
        end
    end
end)

-- [ SILENT AIM ENGINE ]
if IsMurderVsSheriff() or IsHitmark() or IsBronxDuels() or IsDuelist() then
    silentFovCircle = Drawing.new("Circle")
    silentFovCircle.Thickness = 1.5
    silentFovCircle.NumSides = 60
    silentFovCircle.Radius = _G.SILENT_CFG.FOV or 150
    silentFovCircle.Filled = false
    silentFovCircle.Visible = false
    silentFovCircle.ZIndex = 999
    silentFovCircle.Transparency = 1
    silentFovCircle.Color = Color3.fromRGB(255, 255, 255)

    local silentFovConn
    silentFovConn = game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().FLUX_SESSION ~= MySession then
            if silentFovCircle then silentFovCircle:Remove() end
            silentFovConn:Disconnect()
            return
        end
        if _G.SILENT_CFG.Enabled and _G.SILENT_CFG.DrawFov then
            local cam = workspace.CurrentCamera
            local pos = UIS:GetMouseLocation()
            if IS_MOBILE and cam then
                pos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            end
            silentFovCircle.Visible = true
            silentFovCircle.Radius = _G.SILENT_CFG.FOV or 150
            silentFovCircle.Position = pos
        else
            silentFovCircle.Visible = false
        end
    end)

    local function GetSilentTarget()
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local refPos = IS_MOBILE and center or UIS:GetMouseLocation()
        local target = nil
        local dist = _G.SILENT_CFG.FOV or 150

        -- PRIORITY: TargetShoots
        local tsFolder = workspace:FindFirstChild("TargetShoots")
        if tsFolder then
            for _, child in pairs(tsFolder:GetChildren()) do
                if child:IsA("BasePart") and child.Name == "TargetShoot" then
                    local pos, vis = cam:WorldToViewportPoint(child.Position)
                    if vis or _G.SILENT_CFG.Wallbang then
                        local mag = (Vector2.new(pos.X, pos.Y) - refPos).Magnitude
                        if mag < dist then
                            local isVisible = true
                            if not _G.SILENT_CFG.Wallbang then
                                isVisible = IsPositionVisible(cam.CFrame.Position, child.Position, child, cam)
                            end

                            if isVisible then
                                dist = mag
                                target = child
                            end
                        end
                    end
                end
            end
        end

        if target then return target end -- Prioritize TargetShoot if found

        local function check(char)
            if not char or char == LP.Character then return end

            local p = Players:GetPlayerFromCharacter(char)
            if p then
                if IsIgnoredPlayer(p) then
                    return
                end
                if IsBronxDuels() or IsDuelist() then
                    -- In Bronx Duels, opponents are in lp.Data.Match.Enemies
                    local enemiesFolder = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Match") and
                        LP.Data.Match:FindFirstChild("Enemies")
                    if enemiesFolder and #enemiesFolder:GetChildren() > 0 then
                        if not enemiesFolder:FindFirstChild(p.Name) then
                            return -- Not an enemy
                        end
                    else
                        -- Fallback to standard team checks or attribute checks
                        if _G.ESP_CFG and _G.ESP_CFG.IgnoreTeam then
                            if p.Team and LP.Team and p.Team == LP.Team then
                                return -- Same team
                            end
                            local myTeam = LP:GetAttribute("DuelsTeam")
                            local theirTeam = p:GetAttribute("DuelsTeam")
                            local myMatch = LP:GetAttribute("DuelsMatchId")
                            local theirMatch = p:GetAttribute("DuelsMatchId")

                            if myMatch and theirMatch and myMatch == theirMatch then
                                if myTeam and theirTeam and myTeam == theirTeam then
                                    return -- Same team
                                end
                            end
                        end
                    end
                else
                    local myTeamFolder = _G.MY_TEAM_CACHE
                    local isTeammate = myTeamFolder and myTeamFolder:FindFirstChild(p.Name)
                    if isTeammate and _G.ESP_CFG and _G.ESP_CFG.IgnoreTeam then
                        return
                    end
                end
            end

            local targetPartName = _G.SILENT_CFG and _G.SILENT_CFG.TargetPart or "Head"
            local hrp = char:FindFirstChild(targetPartName) or char:FindFirstChild("HumanoidRootPart") or
                char:FindFirstChild("Head")
            if not hrp then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.Health <= 0.1 or char:GetAttribute("Downed") then return end
            end

            local pos, vis = cam:WorldToViewportPoint(hrp.Position)
            if IsBronxDuels() or IsDuelist() then
                if pos.Z <= 0 then return end
            else
                if not _G.SILENT_CFG.Wallbang and not vis then return end
            end

            local mag = (Vector2.new(pos.X, pos.Y) - refPos).Magnitude
            if mag < dist then
                if not _G.SILENT_CFG.Wallbang then
                    if not IsPositionVisible(cam.CFrame.Position, hrp.Position, char, cam) then return end
                end

                dist = mag
                target = char
            end
        end

        local players = Players:GetPlayers()
        local hasActiveMatch = (_G.ACTIVE_MATCH_PLAYERS and next(_G.ACTIVE_MATCH_PLAYERS) ~= nil)
        for i = 1, #players do
            local p = players[i]
            if p ~= LP then
                if not hasActiveMatch or _G.ACTIVE_MATCH_PLAYERS[p.Name] then
                    check(p.Character)
                end
            end
        end

        local bots = _G.BOT_LIST or {}
        for i = 1, #bots do
            check(bots[i])
        end
        return target
    end

    -- ═══════════════════════════════════════════════════════
    -- NAMECALL INTERCEPTION SYSTEM (Undetectable Wallbang)
    -- ═══════════════════════════════════════════════════════

    (function()
        local oldNamecall, oldIndex

        -- Cache for target to avoid recalculating every frame
        local cachedTarget = nil
        local cacheExpire = 0
        local isGettingTarget = false

        local function GetCachedTarget()
            if isGettingTarget then return nil end
            isGettingTarget = true
            local now = tick()
            if now > cacheExpire or not cachedTarget then
                local ok, res = pcall(GetSilentTarget)
                isGettingTarget = false
                if ok then
                    cachedTarget = res
                    cacheExpire = now + 0.05 -- 50ms cache
                else
                    warn("Error in GetSilentTarget: " .. tostring(res))
                    return nil
                end
            else
                isGettingTarget = false
            end
            return cachedTarget
        end
        _G.FLUX_GET_CACHED_TARGET = GetCachedTarget

        local function customIndex(self, k)
            local hookActive = (_G.SILENT_CFG and _G.SILENT_CFG.Enabled) or (_G.KILLAURA_ACTIVE_TARGET ~= nil)
            if not checkcaller() and hookActive then
                if typeof(self) == "Instance" and self:IsA("Camera") then
                    if k == "CFrame" or k == "cf" then
                        -- Prevent Aimlock for games that use Raycast (bypasses obfuscation issues with getcallingscript)
                        if IsHitmark() or IsBronxDuels() or IsDuelist() then
                            return oldIndex(self, k)
                        end

                        -- Prevent Aimlock: Do not spoof CFrame if a camera script is asking for it
                        local caller = getcallingscript()
                        if caller then
                            local cName = caller.Name
                            if cName == "CameraModule" or cName == "BaseCamera" or cName == "ClassicCamera" or cName == "CameraUtils" or cName == "ZoomController" or cName == "PlayerModule" then
                                return oldIndex(self, k)
                            end
                        end

                        local target = _G.KILLAURA_ACTIVE_TARGET or GetCachedTarget()
                        if target then
                            local hitPos = nil
                            if target:IsA("BasePart") then
                                hitPos = target.Position
                            else
                                local humT = target:FindFirstChildOfClass("Humanoid")
                                local rootT = humT and humT.RootPart or target:FindFirstChild("Torso") or
                                    target:FindFirstChild("UpperTorso") or target:FindFirstChild("HumanoidRootPart")
                                if rootT then
                                    local tp = target:FindFirstChild(_G.SILENT_CFG.TargetPart)
                                    hitPos = tp and tp.Position or rootT.Position
                                end
                            end

                            if hitPos then
                                local orgCFrame = oldIndex(self, k)
                                local spoofedDir = (hitPos - orgCFrame.Position).Unit
                                return CFrame.new(orgCFrame.Position, orgCFrame.Position + spoofedDir)
                            end
                        end
                    end
                end
            end
            return oldIndex(self, k)
        end

        local function customNamecall(self, ...)
            local method = getnamecallmethod()
            local hookActive = (_G.SILENT_CFG and _G.SILENT_CFG.Enabled) or (_G.KILLAURA_ACTIVE_TARGET ~= nil)

            -- Bypass Bronx Duels Anti-Cheat (AD event)
            if method == "FireServer" and typeof(self) == "Instance" and self.Name == "AD" and not checkcaller() then
                return
            end

            -- Intercept Raycast for Silent Aim & Wallbang
            if hookActive and method == "Raycast" and typeof(self) == "Instance" and self == workspace and not checkcaller() and not ignoreSilentRay then
                local args = table.pack(...)

                -- Usually bullets have a very long direction vector
                if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" and args[2].Magnitude > 25 then
                    local chance = math.random(1, 100)
                    if chance <= (_G.SILENT_CFG.HitChance or 100) then
                        local target = _G.KILLAURA_ACTIVE_TARGET or GetCachedTarget()

                        if target then
                            local hitPos = nil
                            if target:IsA("BasePart") then
                                hitPos = target.Position
                            else
                                local humT = target:FindFirstChildOfClass("Humanoid")
                                local rootT = humT and humT.RootPart or target:FindFirstChild("Torso") or
                                    target:FindFirstChild("UpperTorso") or target:FindFirstChild("HumanoidRootPart")

                                if rootT then
                                    local tp = target:FindFirstChild(_G.SILENT_CFG.TargetPart)
                                    hitPos = tp and tp.Position or rootT.Position
                                end
                            end

                            if hitPos then
                                -- Redirect the ray direction towards the target
                                args[2] = (hitPos - args[1]).Unit * 10000

                                -- Handle Wallbang
                                local doWallbang = (_G.KILLAURA_ACTIVE_TARGET ~= nil) and
                                    (_G.KILLAURA_CFG and _G.KILLAURA_CFG.Wallbang) or
                                    (_G.SILENT_CFG and _G.SILENT_CFG.Wallbang)
                                if doWallbang then
                                    local params = args[3]
                                    local newParams = RaycastParams.new()
                                    newParams.FilterType = Enum.RaycastFilterType.Include
                                    newParams.FilterDescendantsInstances = { target }
                                    if params and typeof(params) == "RaycastParams" then
                                        newParams.IgnoreWater = params.IgnoreWater
                                        newParams.CollisionGroup = params.CollisionGroup
                                    end
                                    args[3] = newParams
                                end
                            end
                        end
                    end
                end

                setnamecallmethod(method)
                return oldNamecall(self, table.unpack(args, 1, args.n))
            end

            setnamecallmethod(method)
            return oldNamecall(self, ...)
        end

        if hookmetamethod then
            local success1, err1 = pcall(function()
                oldIndex = hookmetamethod(game, "__index", function(self, k)
                    return customIndex(self, k)
                end)
            end)
            local success2, err2 = pcall(function()
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    return customNamecall(self, ...)
                end)
            end)
            if not success1 or not success2 then
                local mt = getrawmetatable(game)
                oldNamecall = mt.__namecall
                oldIndex = mt.__index
                setreadonly(mt, false)
                mt.__index = customIndex
                mt.__namecall = customNamecall
                setreadonly(mt, true)
            end
        else
            local mt = getrawmetatable(game)
            oldNamecall = mt.__namecall
            oldIndex = mt.__index
            setreadonly(mt, false)
            mt.__index = customIndex
            mt.__namecall = customNamecall
            setreadonly(mt, true)
        end
    end)()

    _G.FLUX_GET_TARGET_ROOT_ATTACHMENT = function(target)
        if not target then return nil end
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if hrp then
            local att = hrp:FindFirstChild("RootAttachment") or hrp:FindFirstChildOfClass("Attachment")
            if att then return att end
        end
        local torso = target:FindFirstChild("UpperTorso") or target:FindFirstChild("Torso")
        if torso then
            local att = torso:FindFirstChildOfClass("Attachment")
            if att then return att end
        end
        local head = target:FindFirstChild("Head")
        if head then
            local att = head:FindFirstChildOfClass("Attachment")
            if att then return att end
        end
        return nil
    end

    _G.FLUX_GET_SILENT_TARGET_HIT_POSITION = function(target)
        if not target then
            return nil
        end

        if target:IsA("BasePart") then
            return target.Position
        end

        local targetPartName = (_G.SILENT_CFG and _G.SILENT_CFG.TargetPart) or "Head"
        if targetPartName == "Random" then
            local parts = { "Head", "UpperTorso", "HumanoidRootPart" }
            targetPartName = parts[math.random(1, #parts)]
        end

        local targetPart = target:FindFirstChild(targetPartName) or
            target:FindFirstChild("Head") or
            target:FindFirstChild("HumanoidRootPart")

        return targetPart and targetPart.Position or nil
    end

    _G.FLUX_TRY_REDIRECT_VISUALIZE_BULLET = function(oldFireServerFn, remote, ...)
        if not (_G.SILENT_CFG and _G.SILENT_CFG.Enabled and _G.SILENT_CFG.Wallbang) then
            return false
        end

        local target = _G.FLUX_GET_CACHED_TARGET and _G.FLUX_GET_CACHED_TARGET() or nil
        if not target then
            return false
        end

        local attachment = _G.FLUX_GET_TARGET_ROOT_ATTACHMENT(target)
        local hitPos = attachment and _G.FLUX_GET_SILENT_TARGET_HIT_POSITION(target)
        local cam = workspace.CurrentCamera
        if not attachment or not hitPos or not cam then
            return false
        end

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = { LP.Character, target, cam }

        local result = workspace:Raycast(cam.CFrame.Position, hitPos - cam.CFrame.Position, rayParams)
        if not (result and result.Instance) then
            return false
        end

        local args = table.pack(...)
        args[4] = attachment
        args[3] = (hitPos - attachment.WorldPosition).Unit * 1000
        return true, oldFireServerFn(remote, table.unpack(args, 1, args.n))
    end

    _G.FLUX_OLD_FIRESERVER = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
        if checkcaller() or typeof(self) ~= "Instance" then
            return _G.FLUX_OLD_FIRESERVER(self, ...)
        end

        if self.Name == "AD" then
            return
        end

        if self.Name == "VisualizeBullet" then
            local handled, result = _G.FLUX_TRY_REDIRECT_VISUALIZE_BULLET(_G.FLUX_OLD_FIRESERVER, self, ...)
            if handled then
                return result
            end
        end

        if self.Name == "kill" and _G.IK_CFG and _G.IK_CFG.Enabled then
            task.defer(function()
                local fireInstakill = _G.FLUX_FIRE_INSTAKILL
                if type(fireInstakill) == "function" then
                    pcall(fireInstakill, true)
                end
            end)
        end

        return _G.FLUX_OLD_FIRESERVER(self, ...)
    end)

    _G.FLUX_GET_IK_ROOT = function(char)
        return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    end

    _G.FLUX_FIND_IK_ENEMY_FROM_ATTRIBUTES = function(myRoot)
        local myGame = LP:GetAttribute("Game")
        local myTeam = LP:GetAttribute("Team")
        if not myRoot or not myGame or myGame == "nothing" or myGame == "" or myGame == "Lobby" or not myTeam or myTeam == "nothing" then
            return nil
        end

        local closestEnemy = nil
        local closestDist = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and not IsIgnoredPlayer(player) and player:GetAttribute("Game") == myGame and player:GetAttribute("Team") ~= myTeam then
                local enemyRoot = _G.FLUX_GET_IK_ROOT(player.Character)
                if enemyRoot then
                    local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestEnemy = player
                    end
                end
            end
        end

        return closestEnemy
    end

    _G.FLUX_FIND_IK_ENEMY_FROM_RUNNING_GAMES = function(myRoot)
        if not myRoot then
            return nil
        end

        local runningGames = workspace:FindFirstChild("RunningGames")
        if not runningGames then
            return nil
        end

        local myGameFolder = nil
        local myTeamName = nil

        for _, gameFolder in ipairs(runningGames:GetChildren()) do
            local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
            if alivePlayers then
                for _, teamFolder in ipairs(alivePlayers:GetChildren()) do
                    if teamFolder:FindFirstChild(LP.Name) then
                        myGameFolder = gameFolder
                        myTeamName = teamFolder.Name
                        break
                    end
                end
            end
            if myGameFolder then
                break
            end
        end

        if not myGameFolder or not myTeamName then
            return nil
        end

        local alivePlayers = myGameFolder:FindFirstChild("AlivePlayers")
        if not alivePlayers then
            return nil
        end

        local closestEnemy = nil
        local closestDist = math.huge

        for _, teamFolder in ipairs(alivePlayers:GetChildren()) do
            if teamFolder.Name ~= myTeamName then
                for _, child in ipairs(teamFolder:GetChildren()) do
                    local enemyPlayer = Players:FindFirstChild(child.Name)
                    if enemyPlayer and not IsIgnoredPlayer(enemyPlayer) then
                        local enemyRoot = _G.FLUX_GET_IK_ROOT(enemyPlayer.Character)
                        if enemyRoot then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestEnemy = enemyPlayer
                            end
                        end
                    end
                end
            end
        end

        return closestEnemy
    end

    _G.FLUX_CAN_FIRE_IK_ON = function(enemyPlayer)
        if not enemyPlayer or IsIgnoredPlayer(enemyPlayer) then
            return false
        end

        local myGame = LP:GetAttribute("Game")
        local myTeam = LP:GetAttribute("Team")
        local theirGame = enemyPlayer:GetAttribute("Game")
        local theirTeam = enemyPlayer:GetAttribute("Team")
        local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")

        return myGame and theirGame == myGame and theirTeam ~= myTeam and myHum and myHum.Health > 0
    end

    -- [ INSTA KILL - Standalone G keybind, independent of shooting ]
    _G.FLUX_FIRE_INSTAKILL = function(silent)
        if not _G.IK_CFG or not _G.IK_CFG.Enabled then return end

        local myRoot = _G.FLUX_GET_IK_ROOT(LP.Character)
        local closestEnemy = _G.FLUX_FIND_IK_ENEMY_FROM_ATTRIBUTES(myRoot) or
            _G.FLUX_FIND_IK_ENEMY_FROM_RUNNING_GAMES(myRoot)

        if not closestEnemy then
            if not silent then
                NOTIFY("InstaKill", "No enemy found!", 2)
            end
            return
        end

        local ok, result = pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local remotesModule = rs:FindFirstChild("Shared") and rs.Shared:FindFirstChild("Remotes")
            local knife = remotesModule and require(remotesModule).KnifeKill

            if not knife then
                if not silent then
                    NOTIFY("InstaKill", "KnifeKill remote not found!", 2)
                end
                return
            end

            if not _G.FLUX_CAN_FIRE_IK_ON(closestEnemy) then
                if not silent then
                    NOTIFY("InstaKill", "Team/Game check failed!", 2)
                end
                return
            end

            knife:FireServer(closestEnemy)
            if not silent then
                NOTIFY("InstaKill", "Fired on " .. closestEnemy.Name, 2)
            end
        end)

        if not ok and not silent then
            NOTIFY("InstaKill", "Error: " .. tostring(result), 3)
        end
    end

    table.insert(_G.FLUX_CONNS, UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if _G.IK_CFG and _G.IK_CFG.Enabled and _G.IK_CFG.Mode == "Keybind" then
            local keyName = _G.IK_CFG.Keybind or "G"
            if input.KeyCode == Enum.KeyCode[keyName] then
                _G.FLUX_FIRE_INSTAKILL()
            end
        end
    end))

    -- Auto Kill loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if getgenv().FLUX_SESSION ~= MySession then break end
            if _G.IK_CFG and _G.IK_CFG.Enabled and _G.IK_CFG.Mode == "Auto Kill" then
                _G.FLUX_FIRE_INSTAKILL()
            end
        end
    end)
end

-- [ SPEED BOOST & FLY UTILITIES ]
; (function()
    -- Speed Boost connections
    table.insert(_G.FLUX_CONNS, LP.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum and _G.LOCAL_PLAYER_CFG.SpeedEnabled and (IsMurderVsSheriff() or IsDuelist()) then
            if IsDuelist() then
                hum:SetAttribute("ForceSpeed", _G.LOCAL_PLAYER_CFG.Speed)
            else
                hum.WalkSpeed = _G.LOCAL_PLAYER_CFG.Speed
            end
        end
    end))

    task.spawn(function()
        while true do
            task.wait()
            if getgenv().FLUX_SESSION ~= MySession then break end

            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and (IsMurderVsSheriff() or IsDuelist()) then
                if _G.LOCAL_PLAYER_CFG.SpeedEnabled then
                    if IsDuelist() then
                        if hum:GetAttribute("ForceSpeed") ~= _G.LOCAL_PLAYER_CFG.Speed then
                            hum:SetAttribute("ForceSpeed", _G.LOCAL_PLAYER_CFG.Speed)
                        end
                    else
                        if hum.WalkSpeed ~= _G.LOCAL_PLAYER_CFG.Speed then
                            hum.WalkSpeed = _G.LOCAL_PLAYER_CFG.Speed
                        end
                    end
                else
                    if IsDuelist() then
                        if hum:GetAttribute("ForceSpeed") ~= nil then
                            hum:SetAttribute("ForceSpeed", nil)
                        end
                    end
                end
            end
        end
    end)

    -- Player Fly exact logic from UICompleta
    local flyConnection
    local flyPos
    local flyGyro
    local flyVelo

    local function UpdateFlyState()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyGyro then
            pcall(function() flyGyro:Destroy() end)
            flyGyro = nil
        end
        if flyVelo then
            pcall(function() flyVelo:Destroy() end)
            flyVelo = nil
        end

        local char = LP.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end

        if _G.LOCAL_PLAYER_CFG.FlyEnabled then
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root or not humanoid then return end

            if IsHitmark() then
                -- PHYSICAL/VISIBLE BODYVELOCITY FLY FOR HITMARK
                flyGyro = Instance.new("BodyGyro")
                flyGyro.P = 9e4
                flyGyro.D = 1e3
                flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyGyro.CFrame = root.CFrame
                flyGyro.Parent = root

                flyVelo = Instance.new("BodyVelocity")
                flyVelo.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyVelo.Velocity = Vector3.new(0, 0, 0)
                flyVelo.Parent = root

                humanoid.PlatformStand = true

                flyConnection = RunService.Heartbeat:Connect(function()
                    if getgenv().FLUX_SESSION ~= MySession or not _G.LOCAL_PLAYER_CFG.FlyEnabled then
                        if flyConnection then
                            flyConnection:Disconnect(); flyConnection = nil
                        end
                        if flyGyro then
                            pcall(function() flyGyro:Destroy() end); flyGyro = nil
                        end
                        if flyVelo then
                            pcall(function() flyVelo:Destroy() end); flyVelo = nil
                        end
                        if humanoid then humanoid.PlatformStand = false end
                        return
                    end

                    local curChar = LP.Character
                    local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
                    if not curRoot or not curHum or not flyGyro or not flyVelo then return end

                    curHum.PlatformStand = true
                    curHum:ChangeState(Enum.HumanoidStateType.Freefall)

                    local cam = workspace.CurrentCamera
                    local speed = _G.LOCAL_PLAYER_CFG.FlySpeed or 50

                    -- Keyboard inputs
                    local fwd = (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                    local side = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
                    local up = (UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) -
                        (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0)

                    local camCF = cam.CFrame
                    local orientation = CFrame.fromEulerAnglesXYZ(camCF:ToEulerAnglesXYZ())

                    -- Move forward/backward/sideways relative to camera rotation
                    local moveDir = orientation:VectorToWorldSpace(Vector3.new(side, 0, -fwd))

                    -- Move up/down absolutely in world coordinates
                    local finalVelocity = moveDir * speed
                    if up ~= 0 then
                        finalVelocity = finalVelocity + Vector3.new(0, up * speed, 0)
                    end

                    flyGyro.CFrame = orientation
                    flyVelo.Velocity = finalVelocity
                end)
            else
                -- ORIGINAL CFRAME FLY FOR MURDER VS SHERIFF
                flyPos = root.Position
                humanoid.PlatformStand = true

                flyConnection = RunService.Heartbeat:Connect(function()
                    if getgenv().FLUX_SESSION ~= MySession or not _G.LOCAL_PLAYER_CFG.FlyEnabled then
                        if flyConnection then
                            flyConnection:Disconnect()
                            flyConnection = nil
                        end
                        if humanoid then humanoid.PlatformStand = false end
                        return
                    end

                    local curChar = LP.Character
                    local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
                    if not curRoot or not curHum then return end

                    curHum.PlatformStand = true
                    local cam = workspace.CurrentCamera
                    local cf = cam.CFrame.Rotation
                    local speed = (_G.LOCAL_PLAYER_CFG.FlySpeed or 50) / 10
                    local dir = cf:VectorToObjectSpace(curHum.MoveDirection * speed)

                    local direction
                    if dir.Magnitude == 0 then
                        direction = Vector3.new(0, 0, 0)
                    else
                        direction = cf:VectorToWorldSpace(
                            Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude
                        )
                    end

                    flyPos = flyPos + direction
                    curRoot.CFrame = CFrame.new(
                        flyPos,
                        cam.CFrame.Position + (flyPos - cam.CFrame.Position) * 2
                    )

                    curRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    curRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

                    for _, part in pairs(curChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end
        end
    end

    -- Hook up Fly state change listeners
    table.insert(_G.FLUX_CONNS, LP.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if _G.LOCAL_PLAYER_CFG.FlyEnabled then
            UpdateFlyState()
        end
    end))

    -- Detect when configuration values are loaded or changed
    local oldFlyEnabled = _G.LOCAL_PLAYER_CFG.FlyEnabled
    task.spawn(function()
        while true do
            task.wait(0.1)
            if getgenv().FLUX_SESSION ~= MySession then break end
            if _G.LOCAL_PLAYER_CFG.FlyEnabled ~= oldFlyEnabled then
                oldFlyEnabled = _G.LOCAL_PLAYER_CFG.FlyEnabled
                UpdateFlyState()
            end
        end
    end)

    -- Invisibility runner logic
    local function setCharacterTransparency(character, transparency)
        for _, descendant in character:GetDescendants() do
            if descendant:IsA("BasePart") or descendant:IsA("Decal") then
                descendant.Transparency = transparency
            end
        end
    end

    local function UpdateInvisState()
        local active = _G.LOCAL_PLAYER_CFG.InvisEnabled
        local char = LP.Character
        if not char then return end

        if active then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local savedPosition = hrp.CFrame

            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)

            local oldChair = workspace:FindFirstChild("invischair")
            if oldChair then oldChair:Destroy() end

            local seat = Instance.new("Seat")
            seat.Name = "invischair"
            seat.Anchored = false
            seat.CanCollide = false
            seat.Transparency = 1
            seat.Position = Vector3.new(-25.95, 84, 3537.55)
            seat.Parent = workspace

            local weld = Instance.new("Weld")
            weld.Part0 = seat
            weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            weld.Parent = seat

            task.wait()
            seat.CFrame = savedPosition

            setCharacterTransparency(char, 0.5)
        else
            local invisChair = workspace:FindFirstChild("invischair")
            if invisChair then
                invisChair:Destroy()
            end

            setCharacterTransparency(char, 0)
        end
    end

    -- Character added reset for Invisibility
    table.insert(_G.FLUX_CONNS, LP.CharacterAdded:Connect(function(char)
        _G.LOCAL_PLAYER_CFG.InvisEnabled = false
        local invisChair = workspace:FindFirstChild("invischair")
        if invisChair then
            invisChair:Destroy()
        end
        if _G.FLUX_UI_UPDATE_FUNCS then
            for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
        end
    end))

    -- Configuration loader/change detector for Invisibility
    local oldInvisEnabled = _G.LOCAL_PLAYER_CFG.InvisEnabled
    task.spawn(function()
        while true do
            task.wait(0.1)
            if getgenv().FLUX_SESSION ~= MySession then break end
            if _G.LOCAL_PLAYER_CFG.InvisEnabled ~= oldInvisEnabled then
                oldInvisEnabled = _G.LOCAL_PLAYER_CFG.InvisEnabled
                UpdateInvisState()
            end
        end
    end)

    -- Keybind toggling listener
    table.insert(_G.FLUX_CONNS, UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end

        -- Trigger Bot keybind check
        if _G.TRIGGERBOT_CFG and _G.TRIGGERBOT_CFG.Keybind then
            local currentBind = _G.TRIGGERBOT_CFG.Keybind
            local match = false
            if typeof(currentBind) == "EnumItem" then
                if currentBind.EnumType == Enum.KeyCode then
                    match = (inp.KeyCode == currentBind)
                elseif currentBind.EnumType == Enum.UserInputType then
                    match = (inp.UserInputType == currentBind)
                end
            end
            if match and currentBind ~= Enum.KeyCode.None then
                _G.TRIGGERBOT_CFG.Enabled = not _G.TRIGGERBOT_CFG.Enabled
                NOTIFY("Trigger Bot", _G.TRIGGERBOT_CFG.Enabled and "Enabled" or "Disabled", 2)
                if _G.FLUX_UI_UPDATE_FUNCS then
                    for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                end
            end
        end

        -- Silent Aim keybind check
        if _G.SILENT_CFG and _G.SILENT_CFG.Keybind then
            local currentBind = _G.SILENT_CFG.Keybind
            local match = false
            if typeof(currentBind) == "EnumItem" then
                if currentBind.EnumType == Enum.KeyCode then
                    match = (inp.KeyCode == currentBind)
                elseif currentBind.EnumType == Enum.UserInputType then
                    match = (inp.UserInputType == currentBind)
                end
            end
            if match and currentBind ~= Enum.KeyCode.None then
                _G.SILENT_CFG.Enabled = not _G.SILENT_CFG.Enabled
                NOTIFY("Silent Aim", _G.SILENT_CFG.Enabled and "Enabled" or "Disabled", 2)
                if _G.FLUX_UI_UPDATE_FUNCS then
                    for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                end
            end
        end

        -- Kill Aura keybind check
        if _G.KILLAURA_CFG and _G.KILLAURA_CFG.Keybind then
            local currentBind = _G.KILLAURA_CFG.Keybind
            local match = false
            if typeof(currentBind) == "EnumItem" then
                if currentBind.EnumType == Enum.KeyCode then
                    match = (inp.KeyCode == currentBind)
                elseif currentBind.EnumType == Enum.UserInputType then
                    match = (inp.UserInputType == currentBind)
                end
            end
            if match and currentBind ~= Enum.KeyCode.None then
                _G.KILLAURA_CFG.Enabled = not _G.KILLAURA_CFG.Enabled
                NOTIFY("Kill Aura", _G.KILLAURA_CFG.Enabled and "Enabled" or "Disabled", 2)
                if _G.FLUX_UI_UPDATE_FUNCS then
                    for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                end
            end
        end

        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = inp.KeyCode.Name

            -- Speed Boost keybind
            if _G.LOCAL_PLAYER_CFG.SpeedKey ~= "None" and keyName == _G.LOCAL_PLAYER_CFG.SpeedKey then
                if IsMurderVsSheriff() or IsDuelist() then
                    _G.LOCAL_PLAYER_CFG.SpeedEnabled = not _G.LOCAL_PLAYER_CFG.SpeedEnabled
                    local char = LP.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and not _G.LOCAL_PLAYER_CFG.SpeedEnabled then
                        if IsDuelist() then
                            hum:SetAttribute("ForceSpeed", nil)
                        else
                            hum.WalkSpeed = 16
                        end
                    end
                    NOTIFY("Speed Boost", _G.LOCAL_PLAYER_CFG.SpeedEnabled and "Enabled" or "Disabled", 2)
                    if _G.FLUX_UI_UPDATE_FUNCS then
                        for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                    end
                else
                    NOTIFY("Speed Boost", "Only available in supported games!", 3)
                end
            end

            -- Player Fly keybind
            if _G.LOCAL_PLAYER_CFG.FlyKey ~= "None" and keyName == _G.LOCAL_PLAYER_CFG.FlyKey then
                _G.LOCAL_PLAYER_CFG.FlyEnabled = not _G.LOCAL_PLAYER_CFG.FlyEnabled
                UpdateFlyState()
                NOTIFY("Player Fly", _G.LOCAL_PLAYER_CFG.FlyEnabled and "Enabled" or "Disabled", 2)
                if _G.FLUX_UI_UPDATE_FUNCS then
                    for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                end
            end

            -- Invisibility keybind
            if _G.LOCAL_PLAYER_CFG.InvisKey ~= "None" and keyName == _G.LOCAL_PLAYER_CFG.InvisKey then
                _G.LOCAL_PLAYER_CFG.InvisEnabled = not _G.LOCAL_PLAYER_CFG.InvisEnabled
                NOTIFY("Invisibility", _G.LOCAL_PLAYER_CFG.InvisEnabled and "Enabled" or "Disabled", 2)
                if _G.FLUX_UI_UPDATE_FUNCS then
                    for _, f in ipairs(_G.FLUX_UI_UPDATE_FUNCS) do pcall(f) end
                end
                if _G.FLUX_UPDATE_KB_HUD then pcall(_G.FLUX_UPDATE_KB_HUD) end
            end
        end
    end))

    -- Fun Options: Infinite Jump
    table.insert(_G.FLUX_CONNS, UIS.JumpRequest:Connect(function()
        if _G.FUN_CFG and _G.FUN_CFG.InfJump and IsHitmark() then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))

    -- Duelist Exclusive Infinite Jump
    table.insert(_G.FLUX_CONNS, UIS.InputBegan:Connect(function(inp, gpe)
        if inp.KeyCode == Enum.KeyCode.Space then
            if _G.FUN_CFG and _G.FUN_CFG.InfJump and IsDuelist() then
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50,
                        hrp.AssemblyLinearVelocity.Z)
                end
            end
        end
    end))

    -- Fun Options: Gravity Changer
    task.spawn(function()
        while true do
            task.wait(0.1)
            if getgenv().FLUX_SESSION ~= MySession then
                pcall(function() workspace.Gravity = 196.2 end)
                break
            end
            pcall(function()
                if _G.FUN_CFG and _G.FUN_CFG.GravityEnabled and IsHitmark() then
                    workspace.Gravity = _G.FUN_CFG.GravityValue
                else
                    workspace.Gravity = 196.2
                end
            end)
        end
    end)

    -- Fun Options: Spinbot
    task.spawn(function()
        local spinVelo
        while true do
            task.wait(0.1)
            if getgenv().FLUX_SESSION ~= MySession then
                if spinVelo then pcall(function() spinVelo:Destroy() end) end
                break
            end
            pcall(function()
                if _G.FUN_CFG and _G.FUN_CFG.Spinbot and (IsHitmark() or IsDuelist()) then
                    local char = LP.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if not spinVelo or spinVelo.Parent ~= root then
                            if spinVelo then pcall(function() spinVelo:Destroy() end) end
                            spinVelo = Instance.new("BodyAngularVelocity")
                            spinVelo.MaxTorque = Vector3.new(0, 999999, 0)
                            spinVelo.AngularVelocity = Vector3.new(0, _G.FUN_CFG.SpinSpeed / 5, 0)
                            spinVelo.Parent = root
                        else
                            spinVelo.AngularVelocity = Vector3.new(0, _G.FUN_CFG.SpinSpeed / 5, 0)
                        end
                    end
                else
                    if spinVelo then
                        pcall(function() spinVelo:Destroy() end)
                        spinVelo = nil
                    end
                end
            end)
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- GUN MODS ENGINE (HITMARK)
    -- ═══════════════════════════════════════════════════════
    task.spawn(function()
        local u3, u6, u11

        -- 1. Slow scanning loop (1s) to find tables from getgc
        task.spawn(function()
            while true do
                task.wait(1)
                if getgenv().FLUX_SESSION ~= MySession then break end
                if IsHitmark() then
                    if not u3 or not u6 or not u11 then
                        pcall(function()
                            for _, v in ipairs(getgc(true)) do
                                if type(v) == "table" then
                                    if rawget(v, "CurrentWeapons") and rawget(v, "WeaponData") and rawget(v, "WeaponAnimations") then
                                        u11 = v
                                    elseif rawget(v, "MouseDelta") and rawget(v, "InputBegan") and rawget(v, "GamepadDelta") then
                                        u3 = v
                                    elseif rawget(v, "Shake") and rawget(v, "SetFOV") and rawget(v, "Sensitivity") then
                                        u6 = v
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end)

        -- 2. Fast override loop (every frame) for active overrides
        while true do
            task.wait()
            if getgenv().FLUX_SESSION ~= MySession then break end

            if IsHitmark() and u3 and u6 and u11 then
                pcall(function()
                    -- Hook visual camera shake (run once)
                    if not rawget(u6, "_oldShake") then
                        u6._oldShake = u6.Shake
                        u6.Shake = function(self, ...)
                            if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.NoRecoil then
                                return
                            end
                            return u6._oldShake(self, ...)
                        end
                    end

                    -- Hook MouseDelta to remove physical recoil kick (run once)
                    local mt = getmetatable(u3)
                    if not mt then
                        mt = {}
                        setmetatable(u3, mt)
                    end
                    if not rawget(mt, "_oldNewIndex") then
                        mt._oldNewIndex = mt.__newindex or rawset
                        setreadonly(mt, false)
                        mt.__newindex = function(t, k, v)
                            if k == "MouseDelta" and _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.NoRecoil then
                                local caller = debug.info(2, "n")
                                if caller == "firegun" then
                                    return
                                end
                            end
                            return mt._oldNewIndex(t, k, v)
                        end
                    end

                    -- Real-time Active Weapon overrides
                    local current = u11.CurrentWeapon
                    local data = u11.WeaponData

                    if current and type(current) == "table" then
                        -- Handle Infinite Ammo
                        if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.InfiniteAmmo then
                            rawset(current, "ammo", current.clipsize or 16)
                        end
                        -- Handle Force Automatic
                        if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.Automatic then
                            rawset(current, "firemode", "Auto")
                        end
                        -- Handle Rapid Fire
                        if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.RapidFire then
                            rawset(current, "firedelay", 0.05)
                        end
                    end

                    if data and type(data) == "table" then
                        -- Handle No Spread (100% Accuracy)
                        if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.NoSpread then
                            if not rawget(data, "_oldAccuracyMin") then
                                rawset(data, "_oldAccuracyMin", data.AccuracyMin or Vector3.new(0, 0, 0))
                                rawset(data, "_oldAccuracyMax", data.AccuracyMax or Vector3.new(0, 0, 0))
                            end
                            rawset(data, "AccuracyMin", Vector3.new(0, 0, 0))
                            rawset(data, "AccuracyMax", Vector3.new(0, 0, 0))
                        else
                            if rawget(data, "_oldAccuracyMin") then
                                rawset(data, "AccuracyMin", data._oldAccuracyMin)
                                rawset(data, "AccuracyMax", data._oldAccuracyMax)
                            end
                        end
                    end

                    -- Visual Material Changer
                    if _G.CURRENT_VISUAL_MAT and _G.CURRENT_VISUAL_MAT ~= "Default" then
                        local lp = game:GetService("Players").LocalPlayer
                        if lp.Character then
                            local tool = lp.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                for _, part in ipairs(tool:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        local isHandleOrSolid = (part.Name ~= "Handle" or part.Transparency < 1)
                                        if isHandleOrSolid then
                                            local matName = "Plastic"
                                            local clr = Color3.new(1, 1, 1)

                                            local sel = _G.CURRENT_VISUAL_MAT
                                            if sel:match("Neon") then
                                                matName = "Neon"
                                                if sel:match("Cyan") then
                                                    clr = Color3.fromRGB(0, 255, 255)
                                                elseif sel:match("Pink") then
                                                    clr = Color3.fromRGB(255, 50, 150)
                                                elseif sel:match("Green") then
                                                    clr = Color3.fromRGB(50, 255, 50)
                                                end
                                            elseif sel:match("ForceField") then
                                                matName = "ForceField"
                                                if sel:match("Cyan") then
                                                    clr = Color3.fromRGB(0, 255, 255)
                                                elseif sel:match("Pink") then
                                                    clr = Color3.fromRGB(255, 50, 150)
                                                end
                                            elseif sel == "Solid Gold" then
                                                matName = "Foil"
                                                clr = Color3.fromRGB(255, 215, 0)
                                            elseif sel == "Glass" then
                                                matName = "Glass"
                                                clr = Color3.fromRGB(200, 200, 200)
                                            elseif sel == "Ice" then
                                                matName = "Ice"
                                                clr = Color3.fromRGB(150, 200, 255)
                                            end

                                            if part.Material ~= Enum.Material[matName] then
                                                part.Material = Enum.Material[matName]
                                                part.Color = clr
                                            end
                                        end
                                    end
                                    if part:IsA("SpecialMesh") then
                                        local sel = _G.CURRENT_VISUAL_MAT
                                        local vclr = Vector3.new(1, 1, 1)
                                        if sel:match("Cyan") then
                                            vclr = Vector3.new(0, 2, 2)
                                        elseif sel:match("Pink") then
                                            vclr = Vector3.new(2, 0.5, 1.5)
                                        elseif sel:match("Green") then
                                            vclr = Vector3.new(0.5, 2, 0.5)
                                        elseif sel == "Solid Gold" then
                                            vclr = Vector3.new(2, 1.5, 0)
                                        end
                                        part.VertexColor = vclr
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end)()

-- [ KILL AURA ENGINE ]
local lastKaTime = 0

table.insert(_G.FLUX_CONNS, game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().FLUX_SESSION ~= MySession then return end
    if not _G.KILLAURA_CFG or not _G.KILLAURA_CFG.Enabled then return end
    if not (IsHitmark() or IsDuelist()) then return end

    local closestDist = _G.KILLAURA_CFG.MaxDist or 300
    local kaTarget = nil
    local cam = workspace.CurrentCamera
    local lpChar = game.Players.LocalPlayer.Character
    if not lpChar or not lpChar:FindFirstChild("HumanoidRootPart") then return end

    local isBlatantOrTele = (_G.KILLAURA_CFG.AuraType == "Blatant" or _G.KILLAURA_CFG.AuraType == "Tele Kill")

    if IsDuelist() and isBlatantOrTele then
        local inMatch = false
        local enemiesFolder = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Match") and
            LP.Data.Match:FindFirstChild("Enemies")
        if enemiesFolder and #enemiesFolder:GetChildren() > 0 then
            inMatch = true
        else
            local myMatch = LP:GetAttribute("DuelsMatchId")
            if myMatch and myMatch ~= "" and myMatch ~= "Lobby" then
                inMatch = true
            end
        end

        if inMatch and not lpChar:FindFirstChildOfClass("Tool") then
            local backpack = LP:FindFirstChild("Backpack")
            if backpack then
                local gun = backpack:FindFirstChild("Pistol") or backpack:FindFirstChild("Carabine")
                if gun then
                    local hum = lpChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:EquipTool(gun)
                    end
                end
            end
        end
    end

    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and not IsIgnoredPlayer(p) and p.Character then
            local char = p.Character
            if char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and not char:GetAttribute("Downed") then
                local validEnemy = true
                if _G.MY_TEAM_CACHE and _G.MY_TEAM_CACHE:FindFirstChild(p.Name) then
                    validEnemy = false
                end

                if validEnemy then
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                    if hrp then
                        local mag = (hrp.Position - lpChar.HumanoidRootPart.Position).Magnitude
                        local inView = true
                        if _G.KILLAURA_CFG.AuraType == "Legit" then
                            local _, onScreen = cam:WorldToViewportPoint(hrp.Position)
                            if not onScreen then
                                inView = false
                            end
                        end

                        if inView and mag < closestDist then
                            local bypassWall = _G.KILLAURA_CFG.Wallbang or isBlatantOrTele
                            if bypassWall then
                                closestDist = mag
                                kaTarget = char
                            else
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = { lpChar, cam }
                                rayParams.IgnoreWater = true

                                local res = workspace:Raycast(cam.CFrame.Position,
                                    (hrp.Position - cam.CFrame.Position).Unit * mag, rayParams)
                                if not res or res.Instance:IsDescendantOf(char) then
                                    closestDist = mag
                                    kaTarget = char
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if kaTarget then
        if _G.KILLAURA_CFG.AuraType == "Tele Kill" then
            local targetHrp = kaTarget:FindFirstChild("HumanoidRootPart")
            local myHrp = lpChar:FindFirstChild("HumanoidRootPart")
            if targetHrp and myHrp then
                local safeCenter = Vector3.new(1591, 174, -793)
                local isTargetNearSafe = (targetHrp.Position - safeCenter).Magnitude <= 100
                local isMeNearSafe = (myHrp.Position - safeCenter).Magnitude <= 100
                if not isTargetNearSafe and not isMeNearSafe then
                    myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3.5)
                    myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    myHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end

        local delayTime = isBlatantOrTele and 0.01 or ((_G.KILLAURA_CFG.Delay or 100) / 1000)
        if tick() - lastKaTime > delayTime then
            lastKaTime = tick()
            task.spawn(function()
                pcall(function()
                    local targetPart = IsDuelist() and "Head" or _G.SILENT_CFG.TargetPart
                    local hitPart = kaTarget:FindFirstChild(targetPart) or kaTarget:FindFirstChild("Head") or
                        kaTarget:FindFirstChild("HumanoidRootPart")
                    if not hitPart then return end

                    if IsHitmark() then
                        local BridgeNet2 = require(game:GetService("ReplicatedStorage").Shared.BridgeNet2)
                        local Gun2 = BridgeNet2.ClientBridge("Gun2")
                        Gun2:Fire({
                            ["hitType"] = "Hit",
                            ["char"] = kaTarget,
                            ["hitPart"] = hitPart,
                            ["hitPosition"] = hitPart.Position,
                            ["cameraDir"] = cam.CFrame.LookVector,
                            ["cameraPos"] = cam.CFrame.Position,
                            ["timestamp"] = time(),
                            ["hitId"] = tick()
                        })
                    elseif IsDuelist() then
                        local tool = lpChar:FindFirstChildOfClass("Tool")
                        local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and
                            game:GetService("ReplicatedStorage").Events:FindFirstChild("Weapons")
                        if Weapons and tool then
                            local shotsCount = isBlatantOrTele and 6 or 1

                            for i = 1, shotsCount do
                                if kaTarget and kaTarget:FindFirstChild("Humanoid") and kaTarget.Humanoid.Health > 0 then
                                    Weapons:FireServer("Process")
                                    Weapons:FireServer("DamageRequest", kaTarget.Humanoid, nil, nil, hitPart,
                                        hitPart.Position)
                                end
                            end
                        end
                    end
                end)
            end)
        end
    end
end))

-- [ BRONX DUELS / DUELIST SAFE GUN MODS: NO RECOIL HOOK ]
task.spawn(function()
    while task.wait(2) do
        if getgenv().FLUX_SESSION ~= MySession then break end
        if IsBronxDuels() or IsDuelist() then
            pcall(function()
                for _, t in pairs(getgc(true)) do
                    if type(t) == "table" and (rawget(t, "accelerate") or t.accelerate) and (rawget(t, "accelerateXY") or t.accelerateXY) and not rawget(t, "__hooked") then
                        rawset(t, "__hooked", true)
                        local old_accel = t.accelerate
                        local old_accelXY = t.accelerateXY

                        t.accelerate = function(self, ...)
                            if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.NoRecoil then
                                return
                            end
                            return old_accel(self, ...)
                        end

                        t.accelerateXY = function(self, ...)
                            if _G.GUN_MODS_CFG and _G.GUN_MODS_CFG.NoRecoil then
                                return
                            end
                            return old_accelXY(self, ...)
                        end
                    end
                end
            end)
        end
    end
end)

-- [ DUELIST GUN MODS: FAST ATTRIBUTE OVERRIDE ]
task.spawn(function()
    while task.wait() do
        if getgenv().FLUX_SESSION ~= MySession then break end
        if IsDuelist() and _G.GUN_MODS_CFG then
            pcall(function()
                local char = LP.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        -- Infinite Ammo
                        if _G.GUN_MODS_CFG.InfiniteAmmo and tool:GetAttribute("MaxAmmo") then
                            tool:SetAttribute("Ammo", tool:GetAttribute("MaxAmmo") or 999)
                        end

                        -- Rapid Fire is disabled for Duelist as it breaks the gun script

                        -- Force Automatic
                        if _G.GUN_MODS_CFG.Automatic then
                            if tool:GetAttribute("Auto") ~= nil then tool:SetAttribute("Auto", true) end
                            if tool:GetAttribute("Automatic") ~= nil then tool:SetAttribute("Automatic", true) end
                            if tool:GetAttribute("FireMode") then tool:SetAttribute("FireMode", "Auto") end
                        end

                        -- No Spread
                        if _G.GUN_MODS_CFG.NoSpread then
                            if tool:GetAttribute("Spread") then tool:SetAttribute("Spread", 0) end
                            if tool:GetAttribute("MinSpread") then tool:SetAttribute("MinSpread", 0) end
                            if tool:GetAttribute("MaxSpread") then tool:SetAttribute("MaxSpread", 0) end
                        end
                    end
                end
            end)
        end
    end
end)

local WeaponsRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and
    game:GetService("ReplicatedStorage").Events:FindFirstChild("Weapons")
if WeaponsRemote then
    table.insert(_G.FLUX_CONNS, WeaponsRemote.OnClientEvent:Connect(function(action, ...)
        if getgenv().FLUX_SESSION ~= MySession then return end
        if IsDuelist() and action == "Confirm" and _G.WORLD_CFG and _G.WORLD_CFG.KillSoundEnabled then
            local rawId = tostring(_G.WORLD_CFG.KillSoundId):gsub("%D", "")
            if rawId ~= "" then
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. rawId
                sound.Volume = (_G.WORLD_CFG.KillSoundVolume or 100) / 100
                sound.Parent = game:GetService("SoundService")
                sound:Play()
                sound.Ended:Once(function()
                    sound:Destroy()
                end)
                task.delay(10, function()
                    if sound and sound.Parent then sound:Destroy() end
                end)
            end
        end
    end))
end

table.insert(_G.FLUX_CONNS, game:GetService("SoundService").ChildAdded:Connect(function(child)
    if getgenv().FLUX_SESSION ~= MySession then return end
    if IsDuelist() and _G.WORLD_CFG and _G.WORLD_CFG.KillSoundEnabled and child:IsA("Sound") and child.Name:sub(1, 10) == "KillSound_" then
        child:Stop()
        child:Destroy()
    end
end))

-- [ HITBOX EXPANDER ENGINE ]
task.spawn(function()
    local originalProps = {} -- Almacenará { [Part] = { Size = Vector3, Transparency = number, CanCollide = boolean, Massless = boolean, TargetPartName = string } }

    while true do
        task.wait(0.1)
        if getgenv().FLUX_SESSION ~= MySession then
            -- Restaurar todos los tamaños originales al cerrar
            for part, data in pairs(originalProps) do
                pcall(function()
                    part.Size = data.Size
                    part.Transparency = data.Transparency
                    part.CanCollide = data.CanCollide
                    part.Massless = data.Massless
                end)
            end
            break
        end

        -- Limpiar partes destruidas o inválidas de la tabla para evitar fugas de memoria
        for part, _ in pairs(originalProps) do
            if not part or not part.Parent then
                originalProps[part] = nil
            end
        end

        if IsDuelist() and _G.HITBOX_CFG and _G.HITBOX_CFG.Enabled then
            local size = _G.HITBOX_CFG.Size
            local targetPartName = (_G.HITBOX_CFG.Part == "UpperTorso" and "UpperTorso" or "Head")
            local sizeVec = Vector3.new(size, size, size)

            -- Tabla temporal para saber qué partes están activas en este ciclo
            local activeParts = {}

            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= LP and not IsIgnoredPlayer(p) and p.Character then
                    local char = p.Character
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and not char:GetAttribute("Downed") then
                        local isEnemy = true
                        if _G.MY_TEAM_CACHE and _G.MY_TEAM_CACHE:FindFirstChild(p.Name) then
                            isEnemy = false
                        end

                        if isEnemy then
                            local part = char:FindFirstChild(targetPartName)
                            if targetPartName == "UpperTorso" and not part then
                                part = char:FindFirstChild("Torso")
                            end

                            if part and part:IsA("BasePart") then
                                activeParts[part] = true

                                if not originalProps[part] then
                                    originalProps[part] = {
                                        Size = part.Size,
                                        Transparency = part.Transparency,
                                        CanCollide = part.CanCollide,
                                        Massless = part.Massless,
                                        TargetPartName = targetPartName
                                    }
                                end

                                pcall(function()
                                    if part.Size ~= sizeVec then
                                        part.Size = sizeVec
                                    end
                                    if part.CanCollide ~= false then
                                        part.CanCollide = false
                                    end
                                    if part.Transparency ~= 0.5 then
                                        part.Transparency = 0.5
                                    end
                                    if part.Massless ~= true then
                                        part.Massless = true
                                    end
                                end)
                            end
                        end
                    end
                end
            end

            -- Restaurar partes que ya no están activas (por cambio de selección, respawn, etc.)
            for part, data in pairs(originalProps) do
                if not activeParts[part] then
                    pcall(function()
                        part.Size = data.Size
                        part.Transparency = data.Transparency
                        part.CanCollide = data.CanCollide
                        part.Massless = data.Massless
                    end)
                    originalProps[part] = nil
                end
            end
        else
            -- Expander desactivado: restaurar todo
            for part, data in pairs(originalProps) do
                pcall(function()
                    part.Size = data.Size
                    part.Transparency = data.Transparency
                    part.CanCollide = data.CanCollide
                    part.Massless = data.Massless
                end)
            end
            originalProps = {}
        end
    end
end)

-- [ TRIGGER BOT ENGINE ]
local function GetTriggerBotTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local viewportSize = cam.ViewportSize
    if not viewportSize or viewportSize.X < 10 or viewportSize.Y < 10 then return nil end
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    local mode = _G.TRIGGERBOT_CFG and _G.TRIGGERBOT_CFG.Mode or "Legit"
    local fovRadius = (_G.TRIGGERBOT_CFG and _G.TRIGGERBOT_CFG.Fov)
    if not fovRadius then
        fovRadius = (mode == "Blatant") and 120 or 12 -- Large FOV for Blatant silent-trigger, small for Legit
    end
    local bestTarget = nil
    local bestDist = fovRadius

    -- Exclude local character from visibility check
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    params.IgnoreWater = true

    local function checkChar(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0.1 or char:GetAttribute("Downed") then return end

        local hitPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not hitPart then return end

        -- Get screen position of the hitPart
        local screenPos, onScreen = cam:WorldToViewportPoint(hitPart.Position)
        if not onScreen then return end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if dist < bestDist then
            -- Visibility Check using advanced IsPositionVisible function (handles accessories, bullet trails, etc.)
            if IsPositionVisible(cam.CFrame.Position, hitPart.Position, char, cam) then
                bestTarget = char
                bestDist = dist
            end
        end
    end

    -- Loop through players
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            -- Teammate check
            local isTeammate = false
            if IsBronxDuels() or IsDuelist() then
                local enemiesFolder = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Match") and
                    LP.Data.Match:FindFirstChild("Enemies")
                if enemiesFolder and #enemiesFolder:GetChildren() > 0 then
                    if not enemiesFolder:FindFirstChild(p.Name) then
                        isTeammate = true
                    end
                else
                    if p.Team and LP.Team and p.Team == LP.Team then
                        isTeammate = true
                    end
                    local myTeam = LP:GetAttribute("DuelsTeam")
                    local theirTeam = p:GetAttribute("DuelsTeam")
                    local myMatch = LP:GetAttribute("DuelsMatchId")
                    local theirMatch = p:GetAttribute("DuelsMatchId")
                    if myMatch and theirMatch and myMatch == theirMatch then
                        if myTeam and theirTeam and myTeam == theirTeam then
                            isTeammate = true
                        end
                    end
                end
            else
                local myTeamFolder = _G.MY_TEAM_CACHE
                if myTeamFolder and myTeamFolder:FindFirstChild(p.Name) then
                    isTeammate = true
                end
            end

            if not isTeammate and p.Character then
                checkChar(p.Character)
            end
        end
    end

    -- Loop through bots
    local bots = _G.BOT_LIST or {}
    for i = 1, #bots do
        checkChar(bots[i])
    end

    return bestTarget
end

local function FireWeapon()
    if _G.FireBind then
        _G:FireBind("Shoot", true, false)
        task.wait(0.01)
        _G:FireBind("Shoot", false, false)
    elseif mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        task.wait(0.01)
        mouse1release()
    end
end

local isTriggerPressed = false

local function ReleaseTrigger()
    if isTriggerPressed then
        isTriggerPressed = false
        if _G.FireBind then
            _G:FireBind("Shoot", false, false)
        elseif mouse1release then
            mouse1release()
        end
    end
end

local function PressTrigger()
    if not isTriggerPressed then
        isTriggerPressed = true
        if _G.FireBind then
            _G:FireBind("Shoot", true, false)
        elseif mouse1press then
            mouse1press()
        end
    end
end

local function TapTrigger()
    if _G.FireBind then
        _G:FireBind("Shoot", true, false)
        task.wait(0.01)
        _G:FireBind("Shoot", false, false)
    elseif mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        task.wait(0.01)
        mouse1release()
    end
end

local lastTriggerClick = 0
task.spawn(function()
    while task.wait() do
        if getgenv().FLUX_SESSION ~= MySession then
            ReleaseTrigger()
            break
        end
        if _G.TRIGGERBOT_CFG and _G.TRIGGERBOT_CFG.Enabled then
            -- Dynamic weapon override for 100% long range accuracy (no spread, infinite range, no recoil)
            local activeTool = nil
            pcall(function()
                local char = LP.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        activeTool = tool
                        tool:SetAttribute("Range", 9999)
                        tool:SetAttribute("Spread", 0)
                        tool:SetAttribute("MinSpread", 0)
                        tool:SetAttribute("MaxSpread", 0)
                        tool:SetAttribute("Recoil", 0)
                        tool:SetAttribute("AimRecoil", 0)
                    end
                end
            end)

            local targetChar = GetTriggerBotTarget()
            if targetChar and _G.TRIGGERBOT_CFG.Mode == "Legit" and IS_MOBILE and IsDuelist() then
                local char = LP.Character
                if not (char and char:GetAttribute("Aiming") == true) then
                    targetChar = nil
                end
            end

            if targetChar then
                local mode = _G.TRIGGERBOT_CFG.Mode or "Legit"

                if mode == "Legit" then
                    -- Check if active weapon is automatic
                    local isAuto = false
                    if activeTool then
                        isAuto = activeTool:GetAttribute("Automatic") == true
                            or activeTool:GetAttribute("Auto") == true
                            or activeTool:GetAttribute("FireMode") == "Auto"
                            or (_G.GUN_MODS_CFG and _G.GUN_MODS_CFG.Automatic)
                    end

                    if isAuto then
                        PressTrigger()
                    else
                        -- Semi-automatic: tap weapon
                        ReleaseTrigger() -- Make sure we release before tapping again
                        local delay = _G.TRIGGERBOT_CFG.Delay or 0.05
                        if tick() - lastTriggerClick > delay then
                            lastTriggerClick = tick()
                            TapTrigger()
                        end
                    end
                elseif mode == "Blatant" then
                    ReleaseTrigger()
                    -- Blatant mode: instantly hit via remote/process if Duelist or Hitmark, otherwise click fast
                    if IsDuelist() then
                        local tool = activeTool
                        local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and
                            game:GetService("ReplicatedStorage").Events:FindFirstChild("Weapons")
                        if Weapons and tool then
                            local hitPart = targetChar:FindFirstChild("Head") or
                                targetChar:FindFirstChild("HumanoidRootPart")
                            if hitPart and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
                                if tick() - lastTriggerClick > 0.01 then
                                    lastTriggerClick = tick()
                                    local isHead = hitPart.Name == "Head"
                                    local dmgAttr = isHead and "HeadDamage" or "Damage"
                                    local damage = tool:GetAttribute(dmgAttr) or (isHead and 150 or 100)

                                    -- Instant Kill (multiple remote shots paired with Process)
                                    for i = 1, 3 do
                                        Weapons:FireServer("Process")
                                        Weapons:FireServer("DamageRequest", targetChar.Humanoid, damage, isHead, hitPart,
                                            hitPart.Position)
                                    end
                                end
                            end
                        end
                    elseif IsHitmark() then
                        local hitPart = targetChar:FindFirstChild("Head") or
                            targetChar:FindFirstChild("HumanoidRootPart")
                        if hitPart and tick() - lastTriggerClick > 0.01 then
                            lastTriggerClick = tick()
                            local BridgeNet2 = require(game:GetService("ReplicatedStorage").Shared.BridgeNet2)
                            local Gun2 = BridgeNet2.ClientBridge("Gun2")
                            local cam = workspace.CurrentCamera

                            -- Instant Kill (multiple remote shots with unique timestamps/hitIds)
                            for i = 1, 3 do
                                Gun2:Fire({
                                    ["hitType"] = "Hit",
                                    ["char"] = targetChar,
                                    ["hitPart"] = hitPart,
                                    ["hitPosition"] = hitPart.Position,
                                    ["cameraDir"] = cam.CFrame.LookVector,
                                    ["cameraPos"] = cam.CFrame.Position,
                                    ["timestamp"] = time() + (i * 0.001),
                                    ["hitId"] = tick() + i
                                })
                            end
                        end
                    else
                        -- Fallback to fast click if not Duelist or Hitmark
                        local isAuto = false
                        if activeTool then
                            isAuto = activeTool:GetAttribute("Automatic") == true
                                or activeTool:GetAttribute("Auto") == true
                                or activeTool:GetAttribute("FireMode") == "Auto"
                                or (_G.GUN_MODS_CFG and _G.GUN_MODS_CFG.Automatic)
                        end

                        if isAuto then
                            PressTrigger()
                        else
                            ReleaseTrigger()
                            if tick() - lastTriggerClick > 0.01 then
                                lastTriggerClick = tick()
                                TapTrigger()
                            end
                        end
                    end
                end
            else
                -- No target: release trigger immediately
                ReleaseTrigger()
            end
        else
            -- Triggerbot disabled: release trigger immediately
            ReleaseTrigger()
        end
    end
end)

NOTIFY("WH01AM", "AIMBOT & SILENT SYSTEM LOADED!", 4)
print("9901")
