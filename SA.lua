local CoreGui = game:GetService("CoreGui")
local DynamicHighlightElements = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
if CoreGui:FindFirstChild("CustomInterfaceNoir") then
    CoreGui.CustomInterfaceNoir:Destroy()
end
if CoreGui:FindFirstChild("CEN_CROSSHAIR") then
    CoreGui.CEN_CROSSHAIR:Destroy()
end
if CoreGui:FindFirstChild("CEN_ESP_HOLDER") then
    CoreGui.CEN_ESP_HOLDER:Destroy()
end
for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
    if p.Character and p.Character:FindFirstChild("CEN_CHAM") then
        p.Character.CEN_CHAM:Destroy()
    end
end
local Theme = {
    Background = Color3.fromRGB(15, 15, 17),
    CardBackground = Color3.fromRGB(24, 24, 28),
    Highlight = Color3.fromRGB(245, 40, 135),
    Text = Color3.fromRGB(230, 230, 235),
    MutedText = Color3.fromRGB(140, 140, 145),
    Stroke = Color3.fromRGB(45, 45, 52)
}
local colorPalette = {
    Color3.fromRGB(140, 200, 160),
    Color3.fromRGB(245, 40, 135),
    Color3.fromRGB(215, 155, 175),
    Color3.fromRGB(210, 140, 140),
    Color3.fromRGB(140, 185, 210),
    Color3.fromRGB(165, 150, 210)
}
local SavedData = {
    SizeX = 560,
    SizeY = 390,
    Transparency = 13,
    BackgroundAsset = "rbxassetid://108458500083995",
    UseCustomBackground = true,
    HighlightColor = { 245, 40, 135 },
    BorderOn = true,
    RoseRainOn = false,
    AntiNetworkPause = true,
    InfMoneyUsed = false,
    HideUIKeybind = nil,
    ShowMobileHideBtn = false,
    NotifsEnabled = false,
    NotifsPosition = "Bottom Right"
}
if not isfolder("Rose") then
    pcall(function() makefolder("Rose") end)
end

local function getIcon(id)
    return "rbxassetid://" .. tostring(id)
end

local DualIconsList = {}
local function addDualIcons(titleLabel, iconId, customSize)
    if not iconId then return end
    local bounds
    pcall(function()
        local TextService = game:GetService("TextService")
        bounds = TextService:GetTextSize(titleLabel.Text, titleLabel.TextSize, titleLabel.Font, Vector2.new(9999, 9999))
    end)
    if not bounds then bounds = Vector2.new(titleLabel.TextBounds.X > 0 and titleLabel.TextBounds.X or 100, 20) end

    local padding = 6
    local iconSize = customSize or 18
    local offset = (bounds.X / 2) + padding
    local maxOffset = isMobile and 55 or 999
    offset = math.min(offset, maxOffset)

    local leftIcon = Instance.new("ImageLabel")
    leftIcon.Size = UDim2.new(0, iconSize, 0, iconSize)
    leftIcon.AnchorPoint = Vector2.new(1, 0.5)
    leftIcon.Position = UDim2.new(0.5, -offset, 0.5, 0)
    leftIcon.BackgroundTransparency = 1
    leftIcon.Image = getIcon(iconId)
    leftIcon.ImageColor3 = Theme.Highlight
    leftIcon.ZIndex = titleLabel.ZIndex + 1
    leftIcon.Parent = titleLabel

    local rightIcon = Instance.new("ImageLabel")
    rightIcon.Size = UDim2.new(0, iconSize, 0, iconSize)
    rightIcon.AnchorPoint = Vector2.new(0, 0.5)
    rightIcon.Position = UDim2.new(0.5, offset, 0.5, 0)
    rightIcon.BackgroundTransparency = 1
    rightIcon.Image = getIcon(iconId)
    rightIcon.ImageColor3 = Theme.Highlight
    rightIcon.ZIndex = titleLabel.ZIndex + 1
    rightIcon.Parent = titleLabel

    table.insert(DualIconsList, leftIcon)
    table.insert(DualIconsList, rightIcon)
end

if readfile and isfile and isfile("Rose/NoirUI_Config.json") then
    pcall(function()
        local fileContent = readfile("Rose/NoirUI_Config.json")
        local decoded = HttpService:JSONDecode(fileContent)
        if decoded then
            if decoded.SizeX then SavedData.SizeX = decoded.SizeX end
            if decoded.SizeY then SavedData.SizeY = decoded.SizeY end
            if decoded.Transparency then SavedData.Transparency = decoded.Transparency end
            if decoded.BackgroundAsset then SavedData.BackgroundAsset = decoded.BackgroundAsset end
            if decoded.UseCustomBackground ~= nil then SavedData.UseCustomBackground = decoded.UseCustomBackground end
            if decoded.HighlightColor then SavedData.HighlightColor = decoded.HighlightColor end
            if decoded.BorderOn ~= nil then SavedData.BorderOn = decoded.BorderOn end
            if decoded.RoseRainOn ~= nil then SavedData.RoseRainOn = decoded.RoseRainOn end
            if decoded.AntiNetworkPause ~= nil then SavedData.AntiNetworkPause = decoded.AntiNetworkPause end
            if decoded.InfMoneyUsed ~= nil then SavedData.InfMoneyUsed = decoded.InfMoneyUsed end
            if decoded.HideUIKeybind then SavedData.HideUIKeybind = decoded.HideUIKeybind end
            if decoded.ShowMobileHideBtn ~= nil then SavedData.ShowMobileHideBtn = decoded.ShowMobileHideBtn end
            if decoded.NotifsEnabled ~= nil then SavedData.NotifsEnabled = decoded.NotifsEnabled end
            if decoded.NotifsPosition then SavedData.NotifsPosition = decoded.NotifsPosition end
        end
    end)
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if isMobile then
    local vp = workspace.CurrentCamera.ViewportSize
    SavedData.SizeX = math.min(SavedData.SizeX, vp.X * 0.85, 380)
    SavedData.SizeY = math.min(SavedData.SizeY, vp.Y * 0.85, 290)
end

local function saveConfig()
    if writefile and isfolder and isfolder("Rose") then
        pcall(function()
            writefile("Rose/NoirUI_Config.json", HttpService:JSONEncode(SavedData))
        end)
    end
end
do
    local c = SavedData.HighlightColor
    Theme.Highlight = Color3.fromRGB(c[1], c[2], c[3])
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomInterfaceNoir"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Destroying:Connect(function()
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p.Character then
            local cham = p.Character:FindFirstChild("CEN_CHAM")
            if cham then cham:Destroy() end
        end
    end
    if CoreGui:FindFirstChild("CEN_CROSSHAIR") then CoreGui.CEN_CROSSHAIR:Destroy() end
    if CoreGui:FindFirstChild("CEN_ESP_HOLDER") then CoreGui.CEN_ESP_HOLDER:Destroy() end
end)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, SavedData.SizeX, 0, SavedData.SizeY)
MainFrame.Position = UDim2.new(0.5, -SavedData.SizeX / 2, 0.5, -SavedData.SizeY / 2)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = (SavedData.Transparency / 100)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui
local MainStroke = Instance.new("UIStroke")
MainStroke.Name = "MainStroke"
MainStroke.Color = SavedData.BorderOn and Theme.Highlight or Color3.fromRGB(60, 60, 65)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.15
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame
local MainBackgroundImage = Instance.new("ImageLabel")
MainBackgroundImage.Name = "MainBackgroundImage"
MainBackgroundImage.Size = UDim2.new(1, 0, 1, 0)
MainBackgroundImage.BackgroundTransparency = 1
MainBackgroundImage.Image = SavedData.BackgroundAsset
MainBackgroundImage.ScaleType = Enum.ScaleType.Crop
MainBackgroundImage.ImageTransparency = SavedData.UseCustomBackground and (SavedData.Transparency / 100) or 1
MainBackgroundImage.Visible = SavedData.UseCustomBackground
MainBackgroundImage.ZIndex = 2
MainBackgroundImage.Parent = MainFrame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame
local BackgroundCorner = MainCorner:Clone()
BackgroundCorner.Parent = MainBackgroundImage
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
if isMobile then
    TabContainer.Size = UDim2.new(0, 40, 0, 150)
    TabContainer.Position = UDim2.new(0, -48, 0, 15)
else
    TabContainer.Size = UDim2.new(0, 180, 0, 40)
    TabContainer.Position = UDim2.new(0, 15, 0, -48)
end
TabContainer.BackgroundColor3 = Theme.Background
TabContainer.BackgroundTransparency = MainFrame.BackgroundTransparency
TabContainer.ZIndex = 3
TabContainer.Parent = MainFrame
local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = UDim.new(0, 10)
TabContainerCorner.Parent = TabContainer
local TabContainerStroke = Instance.new("UIStroke")
TabContainerStroke.Color = Theme.Stroke
TabContainerStroke.Thickness = 1
TabContainerStroke.Parent = TabContainer
local TabList = Instance.new("UIListLayout")
TabList.FillDirection = isMobile and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 15)
TabList.Parent = TabContainer
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -30, 1, -30)
PagesContainer.Position = UDim2.new(0, 15, 0, 15)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 3
PagesContainer.ClipsDescendants = true
PagesContainer.Parent = MainFrame
local Pages = {}
local TabButtons = {}
local tabData = {
    { Name = "Main",     Icon = "rbxassetid://121369806625420" },
    { Name = "Misc",     Icon = "rbxassetid://106507089706013" },
    { Name = "Settings", Icon = "rbxassetid://10734950309" }
}
local currentTabIndex = 1
for i, data in ipairs(tabData) do
    local TabBtn = Instance.new("ImageButton")
    TabBtn.Name = data.Name .. "Tab"
    TabBtn.Size = UDim2.new(0, 26, 0, 26)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Image = data.Icon
    TabBtn.ImageColor3 = (i == 1) and Theme.Highlight or Theme.MutedText
    TabBtn.LayoutOrder = i
    TabBtn.ZIndex = 4
    TabBtn.Parent = TabContainer
    TabButtons[data.Name] = TabBtn
    TabBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if currentTabIndex == i then return end
            local cpm = ScreenGui:FindFirstChild("ColorPickerModal", true)
            if cpm then cpm.Visible = false end
            local oldIndex = currentTabIndex
            currentTabIndex = i
            for name, p in pairs(Pages) do
                local pageIndex = 1
                for j, d in ipairs(tabData) do
                    if d.Name == name then
                        pageIndex = j
                        break
                    end
                end
                if name == data.Name then
                    p.Visible = true
                    p.Position = UDim2.new((currentTabIndex > oldIndex) and 1 or -1, 0, 0, 0)
                    TweenService:Create(p, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        { Position = UDim2.new(0, 0, 0, 0) }):Play()
                    TweenService:Create(TabButtons[name], TweenInfo.new(0.2), { ImageColor3 = Theme.Highlight }):Play()
                elseif pageIndex == oldIndex then
                    local tw = TweenService:Create(p,
                        TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        { Position = UDim2.new((currentTabIndex > oldIndex) and -1 or 1, 0, 0, 0) })
                    tw:Play()
                    coroutine.wrap(function()
                        tw.Completed:Wait()
                        if currentTabIndex ~= pageIndex then p.Visible = false end
                    end)()
                    TweenService:Create(TabButtons[name], TweenInfo.new(0.2), { ImageColor3 = Theme.MutedText }):Play()
                else
                    p.Visible = false
                    TweenService:Create(TabButtons[name], TweenInfo.new(0.2), { ImageColor3 = Theme.MutedText }):Play()
                end
            end
        end
    end)
    local Page = Instance.new("Frame")
    Page.Name = data.Name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Page.Parent = PagesContainer
    Pages[data.Name] = Page
end
local SettingsPage = Pages["Settings"]
local MainPage = Pages["Main"]
local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Size = UDim2.new(1, 0, 1, 0)
MainScroll.BackgroundTransparency = 1
MainScroll.BorderSizePixel = 0
MainScroll.ScrollBarThickness = 0
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScroll.ZIndex = 1
MainScroll.Parent = MainPage
local SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.BorderSizePixel = 0
SettingsScroll.ScrollBarThickness = 0
SettingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsScroll.ZIndex = 1
SettingsScroll.Parent = SettingsPage
local showNotif
local function ST_BYPASS_TP(targetPos)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum and hum.SeatPart then
        hum.Sit = false; task.wait(0.05)
    end

    local head = char:FindFirstChild("Head")
    if head then
        head.CanCollide = false
    end

    if hrp then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    end

    task.delay(0.5, function()
        if head then
            head.CanCollide = true
        end
    end)
end
local TP_LOCS = {
    { name = "💰 Dealer", pos = Vector3.new(1614.38, 576.81, -437.72) },
    { name = "🏎️ Car Spawn", pos = Vector3.new(1675.56, 624.04, -487.84) },
    { name = "🔨Pawn Shop", pos = Vector3.new(1373.01, 569.26, -666.02) },
    { name = "🍗Popeyes", pos = Vector3.new(1267.05, 624.06, -612.22) },
    { name = "⛽Gas Station", pos = Vector3.new(1556.20, 623.95, -450.64) },
    { name = "🛡️ Garages", pos = Vector3.new(1639.76, 623.96, 107.34) },
    { name = "🚗 Car Theft", pos = Vector3.new(1661.94, 623.96, 297.74) },
    { name = "🏦 Bank", pos = Vector3.new(2308.18, 623.95, 304.13) },
    { name = "💼Loot Collector", pos = Vector3.new(-1494.52, 623.95, -805.37) },
    { name = "🔫 Gun Shop", pos = Vector3.new(-754.44, 569.42, -1118.61) },
    { name = "Ⓜ️McDonalds", pos = Vector3.new(654.72, 625.37, -1146.55) },
    { name = "🏚️House Rob", pos = Vector3.new(2283.74, 624.18, -1313.25) },
    { name = "🏘️Apartments", pos = Vector3.new(628.75, 524.81, 553.87) },
    { name = "🚓Police Station", pos = Vector3.new(-193.71, 623.95, 956.19) },
    { name = "🧼Money Wash", pos = Vector3.new(226.48, 569.70, -655.62) },
    { name = "👕Clothes Shop", pos = Vector3.new(893.76, 624.87, -796.87) }
}
local selectedTp = TP_LOCS[1]
local tpDropdownOpen = false
local TpCard = Instance.new("Frame")
TpCard.Name = "TpCard"
TpCard.BackgroundColor3 = Theme.CardBackground
TpCard.BackgroundTransparency = 0.15
TpCard.Size = UDim2.new(0.5, -8, 0, 120)
TpCard.Position = UDim2.new(0, 4, 0, 4)
TpCard.ZIndex = 4
TpCard.Parent = MainScroll
local TpCorner = Instance.new("UICorner")
TpCorner.CornerRadius = UDim.new(0, 10)
TpCorner.Parent = TpCard
local TpStroke = Instance.new("UIStroke")
TpStroke.Color = Theme.Stroke
TpStroke.Thickness = 1
TpStroke.Parent = TpCard
local TpTitle = Instance.new("TextLabel")
TpTitle.Size = UDim2.new(1, 0, 0, 22)
TpTitle.Position = UDim2.new(0, 0, 0, 10)
TpTitle.BackgroundTransparency = 1
TpTitle.Text = "Teleports"
TpTitle.TextColor3 = Theme.Text
TpTitle.TextSize = 14
TpTitle.Font = Enum.Font.GothamBold
TpTitle.TextXAlignment = Enum.TextXAlignment.Center
TpTitle.ZIndex = 5
TpTitle.Parent = TpCard
addDualIcons(TpTitle, "84094771691666")
local TpDropBtn = Instance.new("TextButton")
TpDropBtn.Size = UDim2.new(1, -24, 0, 28)
TpDropBtn.Position = UDim2.new(0, 12, 0, 40)
TpDropBtn.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
TpDropBtn.Text = ""
TpDropBtn.ZIndex = 5
TpDropBtn.Parent = TpCard
local TpDropBtnCorner = Instance.new("UICorner")
TpDropBtnCorner.CornerRadius = UDim.new(0, 6)
TpDropBtnCorner.Parent = TpDropBtn
local TpDropBtnStroke = Instance.new("UIStroke")
TpDropBtnStroke.Color = Theme.Stroke
TpDropBtnStroke.Thickness = 1
TpDropBtnStroke.Parent = TpDropBtn
local TpDropLabel = Instance.new("TextLabel")
TpDropLabel.Size = UDim2.new(1, -30, 1, 0)
TpDropLabel.Position = UDim2.new(0, 8, 0, 0)
TpDropLabel.BackgroundTransparency = 1
TpDropLabel.Text = selectedTp.name
TpDropLabel.TextColor3 = Theme.Text
TpDropLabel.TextSize = 11
TpDropLabel.Font = Enum.Font.GothamMedium
TpDropLabel.TextXAlignment = Enum.TextXAlignment.Left
TpDropLabel.TextTruncate = Enum.TextTruncate.AtEnd
TpDropLabel.ZIndex = 6
TpDropLabel.Parent = TpDropBtn
local TpDropArrow = Instance.new("TextLabel")
TpDropArrow.Size = UDim2.new(0, 20, 1, 0)
TpDropArrow.Position = UDim2.new(1, -24, 0, 0)
TpDropArrow.BackgroundTransparency = 1
TpDropArrow.Text = "v"
TpDropArrow.TextColor3 = Theme.MutedText
TpDropArrow.TextSize = 13
TpDropArrow.Font = Enum.Font.GothamBold
TpDropArrow.ZIndex = 6
TpDropArrow.Parent = TpDropBtn
local TpDropList = Instance.new("ScrollingFrame")
TpDropList.Size = UDim2.new(1, -24, 0, 0)
TpDropList.Position = UDim2.new(0, 12, 0, 72)
TpDropList.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
TpDropList.BorderSizePixel = 0
TpDropList.ClipsDescendants = true
TpDropList.ZIndex = 20
TpDropList.Visible = false
TpDropList.ScrollBarThickness = 3
TpDropList.ScrollBarImageColor3 = Theme.Highlight
TpDropList.TopImage = ""
TpDropList.MidImage = ""
TpDropList.BottomImage = ""
TpDropList.CanvasSize = UDim2.new(0, 0, 0, 0)
TpDropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
TpDropList.Parent = TpCard
local TpDropListCorner = Instance.new("UICorner")
TpDropListCorner.CornerRadius = UDim.new(0, 6)
TpDropListCorner.Parent = TpDropList
local TpDropListStroke = Instance.new("UIStroke")
TpDropListStroke.Color = SavedData.BorderOn and Theme.Highlight or Color3.fromRGB(60, 60, 65)
TpDropListStroke.Thickness = 1
TpDropListStroke.Parent = TpDropList
local TpDropListLayout = Instance.new("UIListLayout")
TpDropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpDropListLayout.Parent = TpDropList
for i, loc in ipairs(TP_LOCS) do
    local Item = Instance.new("TextButton")
    Item.Size = UDim2.new(1, 0, 0, 36)
    Item.BackgroundTransparency = 1
    Item.Text = loc.name
    Item.TextColor3 = Theme.MutedText
    Item.TextSize = 12
    Item.Font = Enum.Font.GothamMedium
    Item.TextXAlignment = Enum.TextXAlignment.Left
    Item.LayoutOrder = i
    Item.ZIndex = 21
    Item.AutoButtonColor = false
    Item.Parent = TpDropList
    local ItemPad = Instance.new("UIPadding")
    ItemPad.PaddingLeft = UDim.new(0, 10)
    ItemPad.Parent = Item
    local function selectItem()
        selectedTp = loc
        TpDropLabel.Text = loc.name
        tpDropdownOpen = false
        TpDropArrow.Text = "v"
        TweenService:Create(TpDropList, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, 0) }):Play()
        task.delay(0.18, function() TpDropList.Visible = false end)
        for _, child in ipairs(TpDropList:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = Theme.MutedText
                child.BackgroundTransparency = 1
            end
        end
        Item.TextColor3 = Theme.Highlight
    end
    local touchStartPos = nil
    local SCROLL_THRESHOLD = 10
    Item.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = input.Position
            Item.BackgroundColor3 = Theme.Highlight
            Item.BackgroundTransparency = 0.8
        end
    end)
    Item.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Item.BackgroundTransparency = 1
            if touchStartPos then
                local delta = (input.Position - touchStartPos).Magnitude
                if delta < SCROLL_THRESHOLD then
                    selectItem()
                end
            end
            touchStartPos = nil
        end
    end)
    Item.MouseEnter:Connect(function()
        if selectedTp ~= loc then
            Item.BackgroundColor3 = Theme.Highlight
            TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundTransparency = 0.85 }):Play()
        end
    end)
    Item.MouseLeave:Connect(function()
        TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
    end)
end
local totalTpHeight = #TP_LOCS * 36
TpDropBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tpDropdownOpen = not tpDropdownOpen
        if tpDropdownOpen then
            TpDropList.Visible = true
            TpDropArrow.Text = "^"
            local openH = math.min(totalTpHeight, 180)
            TweenService:Create(TpDropList, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, openH) }):Play()
        else
            TpDropArrow.Text = "v"
            TweenService:Create(TpDropList, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, 0) }):Play()
            task.delay(0.18, function() TpDropList.Visible = false end)
        end
    end
end)
local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -24, 0, 28)
TpBtn.Position = UDim2.new(0, 12, 0, 78)
TpBtn.BackgroundColor3 = Theme.Highlight
TpBtn.Text = "Teleport"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.TextSize = 12
TpBtn.Font = Enum.Font.GothamBold
TpBtn.ZIndex = 5
TpBtn.Parent = TpCard
local TpBtnCorner = Instance.new("UICorner")
TpBtnCorner.CornerRadius = UDim.new(0, 8)
TpBtnCorner.Parent = TpBtn
TpBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if ST_BYPASS_TP then
            ST_BYPASS_TP(selectedTp.pos)
            showNotif("Teleports", "Teleported to " .. selectedTp.name)
        end
    end
end)
local MoneyGenCard = Instance.new("Frame")
MoneyGenCard.Name = "MoneyGenCard"
MoneyGenCard.BackgroundColor3 = Theme.CardBackground
MoneyGenCard.BackgroundTransparency = 0.15
MoneyGenCard.Size = UDim2.new(0.5, -8, 0, 210)
MoneyGenCard.Position = UDim2.new(0, 4, 0, 132)
MoneyGenCard.ZIndex = 4
MoneyGenCard.Parent = MainScroll
local MGCorner = Instance.new("UICorner")
MGCorner.CornerRadius = UDim.new(0, 10)
MGCorner.Parent = MoneyGenCard
local MGStroke = Instance.new("UIStroke")
MGStroke.Color = Theme.Stroke
MGStroke.Thickness = 1
MGStroke.Parent = MoneyGenCard
local MGTitle = Instance.new("TextLabel")
MGTitle.Size = UDim2.new(1, 0, 0, 22)
MGTitle.Position = UDim2.new(0, 0, 0, 10)
MGTitle.BackgroundTransparency = 1
MGTitle.Text = "Money Gen"
MGTitle.TextColor3 = Theme.Text
MGTitle.TextSize = 14
MGTitle.Font = Enum.Font.GothamBold
MGTitle.TextXAlignment = Enum.TextXAlignment.Center
MGTitle.ZIndex = 5
MGTitle.Parent = MoneyGenCard
addDualIcons(MGTitle, "111779063111585")
local InfMoneyLabel = Instance.new("TextLabel")
InfMoneyLabel.Size = UDim2.new(1, -75, 0, 18)
InfMoneyLabel.Position = UDim2.new(0, 12, 0, 40)
InfMoneyLabel.BackgroundTransparency = 1
InfMoneyLabel.Text = "Enable Inf Money"
InfMoneyLabel.TextColor3 = Theme.MutedText
InfMoneyLabel.TextSize = 12
InfMoneyLabel.TextTruncate = Enum.TextTruncate.AtEnd
InfMoneyLabel.Font = Enum.Font.GothamMedium
InfMoneyLabel.TextXAlignment = Enum.TextXAlignment.Left
InfMoneyLabel.ZIndex = 5
InfMoneyLabel.Parent = MoneyGenCard
local InfMoneyBtn = Instance.new("TextButton")
InfMoneyBtn.Size = UDim2.new(0, 42, 0, 20)
InfMoneyBtn.Position = UDim2.new(1, -54, 0, 39)
InfMoneyBtn.BackgroundColor3 = Color3.fromRGB(45, 43, 50)
InfMoneyBtn.Text = ""
InfMoneyBtn.ZIndex = 5
InfMoneyBtn.Parent = MoneyGenCard
local InfMoneyBtnCorner = Instance.new("UICorner")
InfMoneyBtnCorner.CornerRadius = UDim.new(1, 0)
InfMoneyBtnCorner.Parent = InfMoneyBtn
local InfMoneyCircle = Instance.new("Frame")
InfMoneyCircle.Size = UDim2.new(0, 14, 0, 14)
InfMoneyCircle.Position = UDim2.new(0, 3, 0.5, -7)
InfMoneyCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfMoneyCircle.ZIndex = 6
InfMoneyCircle.Parent = InfMoneyBtn
local InfMoneyCircleCorner = Instance.new("UICorner")
InfMoneyCircleCorner.CornerRadius = UDim.new(1, 0)
InfMoneyCircleCorner.Parent = InfMoneyCircle
local infMoneyOn = false
local infMoneyUsed = SavedData.InfMoneyUsed
local DEV_GUNS = {
    { name = "10 milly Button",             id = 3508414053 },
    { name = "10 milly Glock 40 Incognito", id = 3508414397 },
    { name = "AR Drum Shell Catcher",       id = 3508414690 },
    { name = "ArpScope",                    id = 3508415690 },
    { name = "Blue Tipped Twin Mag Arp",    id = 3508416106 },
    { name = "G17 Custom Button",           id = 3508416957 },
    { name = "G17 Cyan Beam",               id = 3508417344 },
    { name = "G17 Kriss Vec Button",        id = 3508417750 },
    { name = "G17 Switch",                  id = 3508418338 },
    { name = "G18C",                        id = 3508418926 },
    { name = "G19X Red Button",             id = 3508420311 },
    { name = "G19x Beam w/ Vec",            id = 3508421655 },
    { name = "G20 50rd Silver Button",      id = 3508419259 },
    { name = "Micro Arp",                   id = 3508419955 },
    { name = "Modded Twin Beam Arp",        id = 3508423778 },
    { name = "RedArpShellCatcher",          id = 3508424383 },
    { name = "Two Tone Micro Arp",          id = 3508424084 },
    { name = "Glock26Binary",               id = 3508448467 },
    { name = "Drake",                       id = 3508446735 },
}
local selectedGun = DEV_GUNS[1]
local dropdownOpen = false
local DevGunsCard = Instance.new("Frame")
DevGunsCard.Name = "DevGunsCard"
DevGunsCard.BackgroundColor3 = Theme.CardBackground
DevGunsCard.BackgroundTransparency = 0.15
DevGunsCard.Size = UDim2.new(0.5, -8, 0, 120)
DevGunsCard.Position = UDim2.new(0.5, 4, 0, 4)
DevGunsCard.ZIndex = 4
DevGunsCard.Parent = MainScroll
local DGCorner = Instance.new("UICorner")
DGCorner.CornerRadius = UDim.new(0, 10)
DGCorner.Parent = DevGunsCard
local DGStroke = Instance.new("UIStroke")
DGStroke.Color = Theme.Stroke
DGStroke.Thickness = 1
DGStroke.Parent = DevGunsCard
local DGTitle = Instance.new("TextLabel")
DGTitle.Size = UDim2.new(1, 0, 0, 22)
DGTitle.Position = UDim2.new(0, 0, 0, 10)
DGTitle.BackgroundTransparency = 1
DGTitle.Text = "Dev Guns"
DGTitle.TextColor3 = Theme.Text
DGTitle.TextSize = 14
DGTitle.Font = Enum.Font.GothamBold
DGTitle.TextXAlignment = Enum.TextXAlignment.Center
DGTitle.ZIndex = 5
DGTitle.Parent = DevGunsCard
addDualIcons(DGTitle, "120959690488350", 26)
local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(1, -24, 0, 28)
DropBtn.Position = UDim2.new(0, 12, 0, 40)
DropBtn.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
DropBtn.Text = ""
DropBtn.ZIndex = 5
DropBtn.Parent = DevGunsCard
local DropBtnCorner = Instance.new("UICorner")
DropBtnCorner.CornerRadius = UDim.new(0, 6)
DropBtnCorner.Parent = DropBtn
local DropBtnStroke = Instance.new("UIStroke")
DropBtnStroke.Color = Theme.Stroke
DropBtnStroke.Thickness = 1
DropBtnStroke.Parent = DropBtn
local DropLabel = Instance.new("TextLabel")
DropLabel.Size = UDim2.new(1, -30, 1, 0)
DropLabel.Position = UDim2.new(0, 8, 0, 0)
DropLabel.BackgroundTransparency = 1
DropLabel.Text = selectedGun.name
DropLabel.TextColor3 = Theme.Text
DropLabel.TextSize = 11
DropLabel.Font = Enum.Font.GothamMedium
DropLabel.TextXAlignment = Enum.TextXAlignment.Left
DropLabel.TextTruncate = Enum.TextTruncate.AtEnd
DropLabel.ZIndex = 6
DropLabel.Parent = DropBtn
local DropArrow = Instance.new("TextLabel")
DropArrow.Size = UDim2.new(0, 20, 1, 0)
DropArrow.Position = UDim2.new(1, -24, 0, 0)
DropArrow.BackgroundTransparency = 1
DropArrow.Text = "v"
DropArrow.TextColor3 = Theme.MutedText
DropArrow.TextSize = 13
DropArrow.Font = Enum.Font.GothamBold
DropArrow.ZIndex = 6
DropArrow.Parent = DropBtn
local DropList = Instance.new("ScrollingFrame")
DropList.Size = UDim2.new(1, -24, 0, 0)
DropList.Position = UDim2.new(0, 12, 0, 72)
DropList.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
DropList.BorderSizePixel = 0
DropList.ClipsDescendants = true
DropList.ZIndex = 20
DropList.Visible = false
DropList.ScrollBarThickness = 3
DropList.ScrollBarImageColor3 = Theme.Highlight
DropList.TopImage = ""
DropList.MidImage = ""
DropList.BottomImage = ""
DropList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropList.Parent = DevGunsCard
local DropListCorner = Instance.new("UICorner")
DropListCorner.CornerRadius = UDim.new(0, 6)
DropListCorner.Parent = DropList
local DropListStroke = Instance.new("UIStroke")
DropListStroke.Color = SavedData.BorderOn and Theme.Highlight or Color3.fromRGB(60, 60, 65)
DropListStroke.Thickness = 1
DropListStroke.Parent = DropList
local DropListLayout = Instance.new("UIListLayout")
DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropListLayout.Parent = DropList
for i, gun in ipairs(DEV_GUNS) do
    local Item = Instance.new("TextButton")
    Item.Size = UDim2.new(1, 0, 0, 36)
    Item.BackgroundTransparency = 1
    Item.Text = gun.name
    Item.TextColor3 = Theme.MutedText
    Item.TextSize = 12
    Item.Font = Enum.Font.GothamMedium
    Item.TextXAlignment = Enum.TextXAlignment.Left
    Item.LayoutOrder = i
    Item.ZIndex = 21
    Item.AutoButtonColor = false
    Item.Parent = DropList
    local ItemPad = Instance.new("UIPadding")
    ItemPad.PaddingLeft = UDim.new(0, 10)
    ItemPad.Parent = Item
    local function selectItem()
        selectedGun = gun
        DropLabel.Text = gun.name
        dropdownOpen = false
        DropArrow.Text = "v"
        TweenService:Create(DropList, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, 0) }):Play()
        task.delay(0.18, function() DropList.Visible = false end)
        for _, child in ipairs(DropList:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = Theme.MutedText
                child.BackgroundTransparency = 1
            end
        end
        Item.TextColor3 = Theme.Highlight
    end
    local touchStartPos = nil
    local SCROLL_THRESHOLD = 10
    Item.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = input.Position
            Item.BackgroundColor3 = Theme.Highlight
            Item.BackgroundTransparency = 0.8
        end
    end)
    Item.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Item.BackgroundTransparency = 1
            if touchStartPos then
                local delta = (input.Position - touchStartPos).Magnitude
                if delta < SCROLL_THRESHOLD then
                    selectItem()
                end
            end
            touchStartPos = nil
        end
    end)
    Item.MouseEnter:Connect(function()
        if selectedGun ~= gun then
            Item.BackgroundColor3 = Theme.Highlight
            TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundTransparency = 0.85 }):Play()
        end
    end)
    Item.MouseLeave:Connect(function()
        TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
    end)
end
local totalDropHeight = #DEV_GUNS * 36
DropBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dropdownOpen = not dropdownOpen
        if dropdownOpen then
            DropList.Visible = true
            DropArrow.Text = "^"
            local openH = math.min(totalDropHeight, 180)
            TweenService:Create(DropList, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, openH) }):Play()
        else
            DropArrow.Text = "v"
            TweenService:Create(DropList, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, 0) }):Play()
            task.delay(0.18, function() DropList.Visible = false end)
        end
    end
end)
local GiveGunBtn = Instance.new("TextButton")
GiveGunBtn.Size = UDim2.new(1, -24, 0, 28)
GiveGunBtn.Position = UDim2.new(0, 12, 0, 78)
GiveGunBtn.BackgroundColor3 = Theme.Highlight
GiveGunBtn.Text = "Give Gun"
GiveGunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GiveGunBtn.TextSize = 12
GiveGunBtn.Font = Enum.Font.GothamBold
GiveGunBtn.ZIndex = 5
GiveGunBtn.Parent = DevGunsCard
local GGCorner = Instance.new("UICorner")
GGCorner.CornerRadius = UDim.new(0, 8)
GGCorner.Parent = GiveGunBtn
GiveGunBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local p = game.Players.LocalPlayer
        pcall(function()
            game:GetService("MarketplaceService"):SignalPromptProductPurchaseFinished(p.UserId, selectedGun.id, true)
        end)
        showNotif("Dev Guns", "Gave: " .. selectedGun.name)
    end
end)
local STORE_PRODUCTS             = {
    "BasicPrinter", "3DPrinter", "Bomb", "PrinterFilament",
    "USBTP9File", "USBPF9File", "CompactSlideKit", "MetalSprings",
    "PolymerFrameKit", "FrameRailsKit", "HealthPack", "Duffel Bag"
}
local STORE_AMMO                 = {
    { name = "Rifle Ammo",  path = "Brick", pos = Vector3.new(-750.05, 569.42, -1119.16), folder = "GunStoreItems" },
    { name = "Pistol Ammo", path = "Mag",   pos = Vector3.new(-750.59, 569.40, -1115.87), folder = "GunStoreItems" }
}
local STORE_DELIS                = {
    { name = "Money Printer Locator", path = "Money Printer Locator", pos = Vector3.new(1376.16, 569.28, -671.59), folder = "RobberyItems" },
    { name = "Crowbar",               path = "Crowbar",               pos = Vector3.new(1376.16, 569.28, -671.59), folder = "RobberyItems" },
    { name = "Pro Pad",               path = "ProPad",                pos = Vector3.new(1367.56, 569.28, -671.64), folder = "RobberyItems" },
    { name = "Rope Hooks",            path = "RopeHooks",             pos = Vector3.new(1367.89, 569.30, -662.78), folder = "RobberyItems" },
    { name = "Routes Drill",          path = "RoutesDrill",           pos = Vector3.new(1367.84, 569.26, -664.68), folder = "RobberyItems" },
    { name = "ATM Locator",           path = "ATM Locator",           pos = Vector3.new(1367.79, 569.29, -666.90), folder = "RobberyItems" }
}
local STORE_QTYS                 = { 1, 2, 3, 4, 5, 10, 15, 20 }
local ST_SELECTED                = ""
local ST_TYPE                    = ""
local ST_ROB_PATH                = ""
local ST_ROB_POS                 = nil
local ST_FOLDER                  = ""
local ST_AMOUNT                  = 1
local stItemDropOpen             = false
local stQtyDropOpen              = false
local StoreCard                  = Instance.new("Frame")
StoreCard.Name                   = "StoreCard"
StoreCard.BackgroundColor3       = Theme.CardBackground
StoreCard.BackgroundTransparency = 0.15
StoreCard.Size                   = UDim2.new(0.5, -8, 0, 170)
StoreCard.Position               = UDim2.new(0.5, 4, 0, 132)
StoreCard.ZIndex                 = 4
StoreCard.Parent                 = MainScroll
local SCCorner                   = Instance.new("UICorner")
SCCorner.CornerRadius            = UDim.new(0, 10)
SCCorner.Parent                  = StoreCard
local SCStroke                   = Instance.new("UIStroke")
SCStroke.Color                   = Theme.Stroke
SCStroke.Thickness               = 1
SCStroke.Parent                  = StoreCard
local SCTitle                    = Instance.new("TextLabel")
SCTitle.Size                     = UDim2.new(1, 0, 0, 22)
SCTitle.Position                 = UDim2.new(0, 0, 0, 10)
SCTitle.BackgroundTransparency   = 1
SCTitle.Text                     = "Store Item"
SCTitle.TextColor3               = Theme.Text
SCTitle.TextSize                 = 14
SCTitle.Font                     = Enum.Font.GothamBold
SCTitle.TextXAlignment           = Enum.TextXAlignment.Center
SCTitle.ZIndex                   = 5
SCTitle.Parent                   = StoreCard
addDualIcons(SCTitle, "140042757228934")
local function makeStoreDropdown(defaultText, yPos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -24, 0, 30)
    Btn.Position = UDim2.new(0, 12, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.ZIndex = 5
    Btn.Parent = StoreCard
    local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 6); BC.Parent = Btn
    local BS = Instance.new("UIStroke"); BS.Color = Theme.Stroke; BS.Thickness = 1; BS.Parent = Btn
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -30, 1, 0); Lbl.Position = UDim2.new(0, 8, 0, 0)
    Lbl.BackgroundTransparency = 1; Lbl.Text = defaultText
    Lbl.TextColor3 = Theme.MutedText; Lbl.TextSize = 11
    Lbl.Font = Enum.Font.GothamMedium; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextTruncate = Enum.TextTruncate.AtEnd; Lbl.ZIndex = 6; Lbl.Parent = Btn
    local Arr = Instance.new("TextLabel")
    Arr.Size = UDim2.new(0, 20, 1, 0); Arr.Position = UDim2.new(1, -24, 0, 0)
    Arr.BackgroundTransparency = 1; Arr.Text = "v"
    Arr.TextColor3 = Theme.MutedText; Arr.TextSize = 13
    Arr.Font = Enum.Font.GothamBold; Arr.ZIndex = 6; Arr.Parent = Btn
    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(1, -24, 0, 0)
    List.Position = UDim2.new(0, 12, 0, yPos + 34)
    List.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
    List.BorderSizePixel = 0; List.ClipsDescendants = true
    List.ZIndex = 20; List.Visible = false
    List.ScrollBarThickness = 3; List.ScrollBarImageColor3 = Theme.Highlight
    List.TopImage = ""; List.MidImage = ""; List.BottomImage = ""
    List.CanvasSize = UDim2.new(0, 0, 0, 0); List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    List.Parent = StoreCard
    local LC = Instance.new("UICorner"); LC.CornerRadius = UDim.new(0, 6); LC.Parent = List
    local LS = Instance.new("UIStroke"); LS.Color = SavedData.BorderOn and Theme.Highlight or Color3.fromRGB(60, 60, 65); LS.Thickness = 1; LS.Parent =
        List
    local LL = Instance.new("UIListLayout"); LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Parent = List
    return { Btn = Btn, Lbl = Lbl, Arr = Arr, List = List, LS = LS }
end
local D1 = makeStoreDropdown("Choose Item", 40)
local D2 = makeStoreDropdown("Qty: 1", 80)
local function addStoreItem(parent, text, layoutOrder, color, onSelect)
    local Item = Instance.new("TextButton")
    Item.Size = UDim2.new(1, 0, 0, 34); Item.BackgroundTransparency = 1
    Item.Text = text; Item.TextColor3 = color or Theme.MutedText
    Item.TextSize = 11; Item.Font = Enum.Font.GothamMedium
    Item.TextXAlignment = Enum.TextXAlignment.Left
    Item.LayoutOrder = layoutOrder; Item.ZIndex = 21; Item.AutoButtonColor = false
    Item.Parent = parent
    local Pad = Instance.new("UIPadding"); Pad.PaddingLeft = UDim.new(0, 10); Pad.Parent = Item
    local touchStart = nil
    Item.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            touchStart = i.Position
            Item.BackgroundColor3 = Theme.Highlight; Item.BackgroundTransparency = 0.8
        end
    end)
    Item.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            Item.BackgroundTransparency = 1
            if touchStart and (i.Position - touchStart).Magnitude < 10 then
                onSelect()
            end
            touchStart = nil
        end
    end)
    Item.MouseEnter:Connect(function()
        Item.BackgroundColor3 = Theme.Highlight
        TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundTransparency = 0.85 }):Play()
    end)
    Item.MouseLeave:Connect(function()
        TweenService:Create(Item, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
    end)
end
local function addSectionHeader(parent, text, order)
    local Sep = Instance.new("TextLabel")
    Sep.Size = UDim2.new(1, 0, 0, 18); Sep.BackgroundTransparency = 1
    Sep.Text = "  — " .. text .. " —"; Sep.TextColor3 = Theme.Highlight
    Sep.Font = Enum.Font.GothamBold; Sep.TextSize = 10
    Sep.TextXAlignment = Enum.TextXAlignment.Left
    Sep.ZIndex = 22; Sep.LayoutOrder = order; Sep.Parent = parent
end
local closeD1, closeD2
addSectionHeader(D1.List, "AMMO ITEMS", -20)
for i, ammo in ipairs(STORE_AMMO) do
    addStoreItem(D1.List, ammo.name, -10 + i, Theme.Text, function()
        ST_SELECTED = ammo.name; ST_TYPE = "PHYSICAL"; ST_ROB_PATH = ammo.path; ST_ROB_POS = ammo.pos; ST_FOLDER = ammo
            .folder
        D1.Lbl.Text = ammo.name; D1.Lbl.TextColor3 = Theme.Text
        closeD1()
    end)
end
addSectionHeader(D1.List, "SHOP ITEMS", 1)
for i, prod in ipairs(STORE_PRODUCTS) do
    addStoreItem(D1.List, prod, 2 + i, Theme.Text, function()
        ST_SELECTED = prod; ST_TYPE = "SHOP"
        D1.Lbl.Text = prod; D1.Lbl.TextColor3 = Theme.Text
        closeD1()
    end)
end
addSectionHeader(D1.List, "ROBBERY ITEMS", 100)
for i, rob in ipairs(STORE_DELIS) do
    addStoreItem(D1.List, rob.name, 101 + i, Theme.Text, function()
        ST_SELECTED = rob.name; ST_TYPE = "PHYSICAL"; ST_ROB_PATH = rob.path; ST_ROB_POS = rob.pos; ST_FOLDER = rob
            .folder
        D1.Lbl.Text = rob.name; D1.Lbl.TextColor3 = Theme.Text
        closeD1()
    end)
end
for i, qty in ipairs(STORE_QTYS) do
    addStoreItem(D2.List, "x" .. qty, i, Theme.Text, function()
        ST_AMOUNT = qty; D2.Lbl.Text = "Qty: " .. qty; D2.Lbl.TextColor3 = Theme.Text
        closeD2()
    end)
end
local CARD_BASE_H = 170
local D1_OPEN_H = math.min((#STORE_AMMO + #STORE_PRODUCTS + #STORE_DELIS) * 34 + 3 * 18, 200)
local D2_OPEN_H = math.min(#STORE_QTYS * 34, 180)
closeD1 = function()
    stItemDropOpen = false; D1.Arr.Text = "v"
    TweenService:Create(D1.List, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, 0) }):Play()
    task.delay(0.18, function() D1.List.Visible = false end)
end
closeD2 = function()
    stQtyDropOpen = false; D2.Arr.Text = "v"
    TweenService:Create(D2.List, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, 0) }):Play()
    task.delay(0.18, function() D2.List.Visible = false end)
end
D1.Btn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if stQtyDropOpen then closeD2() end
        stItemDropOpen = not stItemDropOpen
        if stItemDropOpen then
            D1.List.Visible = true; D1.Arr.Text = "^"
            TweenService:Create(D1.List, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, D1_OPEN_H) }):Play()
        else
            closeD1()
        end
    end
end)
D2.Btn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if stItemDropOpen then closeD1() end
        stQtyDropOpen = not stQtyDropOpen
        if stQtyDropOpen then
            D2.List.Visible = true; D2.Arr.Text = "^"
            TweenService:Create(D2.List, TweenInfo.new(0.18), { Size = UDim2.new(1, -24, 0, D2_OPEN_H) }):Play()
        else
            closeD2()
        end
    end
end)
local PurchaseBtn = Instance.new("TextButton")
PurchaseBtn.Size = UDim2.new(1, -24, 0, 30)
PurchaseBtn.Position = UDim2.new(0, 12, 0, 122)
PurchaseBtn.BackgroundColor3 = Theme.Highlight
PurchaseBtn.Text = "Purchase"
PurchaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PurchaseBtn.TextSize = 12; PurchaseBtn.Font = Enum.Font.GothamBold
PurchaseBtn.ZIndex = 5; PurchaseBtn.Parent = StoreCard
local PBCorner = Instance.new("UICorner"); PBCorner.CornerRadius = UDim.new(0, 8); PBCorner.Parent = PurchaseBtn
local buyDebounce = false
local function ST_FORCE_HOLD(prompt)
    if not prompt then return end
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait((prompt.HoldDuration or 0) > 0 and (prompt.HoldDuration + 0.05) or 0.2)
        prompt:InputHoldEnd()
    end)
end
PurchaseBtn.InputBegan:Connect(function(inp)
    if not inp or (inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch) then return end
    if buyDebounce then
        showNotif("Store", "Purchase in progress...")
        return
    end
    if ST_SELECTED == "" then
        showNotif("Store", "Select an item first!")
        return
    end
    buyDebounce = true
    task.spawn(function()
        if ST_TYPE == "SHOP" then
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            remote = remote and remote:FindFirstChild("ShopRemote")
            if not remote then
                showNotif("Store", "ShopRemote not found!")
                buyDebounce = false
                return
            end
            for i = 1, ST_AMOUNT do
                remote:FireServer("Purchase", ST_SELECTED)
                showNotif("Store", "Purchased " .. i .. "/" .. ST_AMOUNT .. " " .. ST_SELECTED)
                if i < ST_AMOUNT then task.wait(3) end
            end
        elseif ST_TYPE == "PHYSICAL" then
            local lp = game:GetService("Players").LocalPlayer
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local oldPos = hrp and hrp.Position
            if ST_ROB_POS then
                ST_BYPASS_TP(ST_ROB_POS)
                local itemsF = nil
                local deadline = tick() + 8
                repeat
                    itemsF = workspace:FindFirstChild(ST_FOLDER)
                    if not itemsF or not itemsF:FindFirstChild(ST_ROB_PATH) then
                        task.wait(0.2)
                    end
                until (itemsF and itemsF:FindFirstChild(ST_ROB_PATH)) or tick() > deadline
            end
            local itemsF = workspace:FindFirstChild(ST_FOLDER)
            local targetMdl = itemsF and itemsF:FindFirstChild(ST_ROB_PATH)
            local prompt = nil
            if targetMdl then
                for _, v in ipairs(targetMdl:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        prompt = v
                        break
                    end
                end
            end
            if prompt then
                task.wait(0.6) -- Wait for position sync
                for i = 1, ST_AMOUNT do
                    ST_FORCE_HOLD(prompt)
                    showNotif("Store", "Purchased " .. i .. "/" .. ST_AMOUNT .. " " .. ST_SELECTED)
                    if i < ST_AMOUNT then task.wait(3.2) end
                end
            else
                showNotif("Store", "Item not found! Try again.")
            end
            if oldPos then
                task.wait(2.0)
                ST_BYPASS_TP(oldPos)
                showNotif("Store", "Returned!")
            end
        end
        buyDebounce = false
    end)
end)
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 280, 0, 0)
NotifContainer.Position = UDim2.new(1, -295, 1, -20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.AnchorPoint = Vector2.new(0, 1)
NotifContainer.ZIndex = 50
NotifContainer.Parent = ScreenGui
local NotifList = Instance.new("UIListLayout")
NotifList.FillDirection = Enum.FillDirection.Vertical
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, 6)
NotifList.Parent = NotifContainer
showNotif = function(title, message)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 58)
    notif.BackgroundColor3 = Theme.CardBackground
    notif.BackgroundTransparency = 0.05
    notif.ZIndex = 51
    notif.Parent = NotifContainer
    local nc = Instance.new("UICorner")
    nc.CornerRadius = UDim.new(0, 10)
    nc.Parent = notif
    local ns = Instance.new("UIStroke")
    ns.Color = Theme.Highlight
    ns.Thickness = 1.2
    ns.Parent = notif
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = Theme.Highlight
    accent.BorderSizePixel = 0
    accent.ZIndex = 52
    accent.Parent = notif
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accent
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 16, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 52
    titleLbl.Parent = notif
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0, 18)
    msgLbl.Position = UDim2.new(0, 16, 0, 30)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Theme.MutedText
    msgLbl.TextSize = 11
    msgLbl.Font = Enum.Font.GothamMedium
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.ZIndex = 52
    msgLbl.Parent = notif
    notif.Position = UDim2.new(1, 10, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(4, function()
        local t = TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 0, 0),
            BackgroundTransparency = 1
        })
        t:Play()
        t.Completed:Connect(function() notif:Destroy() end)
    end)
end
local function turnOffInfMoney()
    infMoneyOn = false
    TweenService:Create(InfMoneyCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, 3, 0.5, -7) }):Play()
    TweenService:Create(InfMoneyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { BackgroundColor3 = Color3.fromRGB(45, 43, 50) }):Play()
end
local function runInfMoney()
    local LP = game:GetService("Players").LocalPlayer
    local LS = LP:WaitForChild("leaderstats", 10)
    local CASH = LS and LS:WaitForChild("Cash", 10)
    if not LS or not CASH then
        infMoneyUsed = false
        SavedData.InfMoneyUsed = false
        saveConfig()
        showNotif("Server Error", "Auto rejoining...")
        task.delay(2, function()
            SavedData.InfMoneyUsed = false
            saveConfig()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end)
        turnOffInfMoney()
        return
    end
    if CASH.Value >= 1000000 then
        showNotif("Limit Reached", "You already have 1M!")
        turnOffInfMoney()
        return
    end
    if (CASH.Value + 90000) > 1000000 then
        showNotif("BAN RISK", "Cash would exceed 1M!")
        turnOffInfMoney()
        return
    end
    local RS = game:GetService("ReplicatedStorage")
    local EventNode = RS:FindFirstChild("McDonaldsEvents")
    local Event = EventNode and EventNode:FindFirstChild("iceCreamEvent")
    if not Event then
        showNotif("Error", "iceCreamEvent not found!")
        turnOffInfMoney()
        return
    end
    showNotif("Inf Money", "Activating...")
    local notifRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and
        game:GetService("ReplicatedStorage").Remotes:FindFirstChild("NotificationRemote")
    local notifBlock
    if notifRemote then
        notifBlock = notifRemote.OnClientEvent:Connect(function() end)
    end
    local SG = Instance.new("ScreenGui", game:GetService("CoreGui"))
    SG.Name = "WH_INF_UI"
    SG.IgnoreGuiInset = true
    SG.DisplayOrder = 2147483647
    local BF = Instance.new("Frame", SG)
    BF.Size = UDim2.new(1, 0, 1, 0)
    BF.BackgroundColor3 = Color3.new(0, 0, 0)
    BF.BorderSizePixel = 0
    local MBOX = Instance.new("Frame", BF)
    MBOX.Size = UDim2.new(0, 600, 0, 200)
    MBOX.Position = UDim2.new(0.5, 0, 0.4, 0)
    MBOX.AnchorPoint = Vector2.new(0.5, 0.5)
    MBOX.BackgroundTransparency = 1
    local GI = Instance.new("ImageLabel", MBOX)
    GI.Size = UDim2.new(1, 0, 1, 0)
    GI.BackgroundTransparency = 1
    GI.Image = "rbxassetid://134740452809434"
    GI.ScaleType = Enum.ScaleType.Fit
    local TL = Instance.new("TextLabel", MBOX)
    TL.Size = UDim2.new(1, 0, 1, 0)
    TL.BackgroundTransparency = 1
    TL.Text = "RoseWare"
    TL.TextColor3 = Color3.fromRGB(80, 120, 255)
    TL.Font = Enum.Font.LuckiestGuy
    TL.TextSize = 100
    TL.Visible = (GI.Image == "" or GI.Image == nil)
    local CBOX = Instance.new("Frame", BF)
    CBOX.Size = UDim2.new(0, 450, 0, 80)
    CBOX.Position = UDim2.new(0.5, 0, 0.62, 0)
    CBOX.AnchorPoint = Vector2.new(0.5, 0.5)
    CBOX.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", CBOX).CornerRadius = UDim.new(0, 12)
    local CS = Instance.new("UIStroke", CBOX)
    CS.Color = Theme.Highlight
    CS.Thickness = 3
    local CT = Instance.new("TextLabel", CBOX)
    CT.Size = UDim2.new(1, 0, 1, 0)
    CT.BackgroundTransparency = 1
    CT.Text = "RECEIVED: $0"
    CT.TextColor3 = Color3.new(1, 1, 1)
    CT.Font = Enum.Font.SpecialElite
    CT.TextSize = 35
    local startCash = CASH.Value
    local TOTAL = 900
    local SENT = 0
    local ACTIVE = true
    local conn
    conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not ACTIVE then return end
        for i = 1, 100 do
            if SENT >= TOTAL then
                ACTIVE = false
                if conn then conn:Disconnect() end
                task.spawn(function()
                    local end_time = tick() + 6
                    while tick() < end_time do
                        CT.Text = "TOTAL RECEIVED: $" .. tostring(math.floor(CASH.Value - startCash))
                        task.wait(0.1)
                    end
                    SG:Destroy()
                    if notifBlock then notifBlock:Disconnect() end
                    turnOffInfMoney()
                    showNotif("Inf Money", "Done! Collect your bank.")
                end)
                return
            end
            Event:FireServer("fixedMachine")
            SENT = SENT + 1
        end
        CT.Text = "RECEIVED: $" .. tostring(math.floor(CASH.Value - startCash))
    end)
end
local function handleInfMoneyToggle()
    if infMoneyUsed then
        showNotif("Already Used", "Server hop to use again!")
        return
    end
    infMoneyOn = not infMoneyOn
    local targetPos = infMoneyOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    local targetColor = infMoneyOn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
    TweenService:Create(InfMoneyCircle, TweenInfo.new(0.18), { Position = targetPos }):Play()
    TweenService:Create(InfMoneyBtn, TweenInfo.new(0.18), { BackgroundColor3 = targetColor }):Play()
    if infMoneyOn then
        infMoneyUsed = true
        SavedData.InfMoneyUsed = true
        saveConfig()
        task.spawn(runInfMoney)
    end
end
InfMoneyBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        handleInfMoneyToggle()
    end
end)
local ServerHopBtn = Instance.new("TextButton")
ServerHopBtn.Size = UDim2.new(1, -24, 0, 28)
ServerHopBtn.Position = UDim2.new(0, 12, 0, 72)
ServerHopBtn.BackgroundColor3 = Theme.Highlight
ServerHopBtn.Text = "Server Hop"
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.TextSize = 12
ServerHopBtn.Font = Enum.Font.GothamBold
ServerHopBtn.ZIndex = 5
ServerHopBtn.Parent = MoneyGenCard
local SHCorner = Instance.new("UICorner")
SHCorner.CornerRadius = UDim.new(0, 8)
SHCorner.Parent = ServerHopBtn
ServerHopBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SavedData.InfMoneyUsed = false
        saveConfig()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId)
    end
end)
local InstructionsBox = Instance.new("Frame")
InstructionsBox.Size = UDim2.new(1, -24, 0, 90)
InstructionsBox.Position = UDim2.new(0, 12, 0, 112)
InstructionsBox.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
InstructionsBox.ZIndex = 5
InstructionsBox.Parent = MoneyGenCard
local InstructionsBoxCorner = Instance.new("UICorner")
InstructionsBoxCorner.CornerRadius = UDim.new(0, 6)
InstructionsBoxCorner.Parent = InstructionsBox
local InstructionsBoxStroke = Instance.new("UIStroke")
InstructionsBoxStroke.Color = Theme.Stroke
InstructionsBoxStroke.Thickness = 1
InstructionsBoxStroke.Parent = InstructionsBox
local InstructionsText = Instance.new("TextLabel")
InstructionsText.Size = UDim2.new(1, -14, 1, -10)
InstructionsText.Position = UDim2.new(0, 7, 0, 5)
InstructionsText.BackgroundTransparency = 1
InstructionsText.Text =
"1. Enable Inf Money\n2. Wait for the script to do its thing\n3. Check ur bank\n4. Server hop and repeat the steps"
InstructionsText.TextColor3 = Theme.MutedText
InstructionsText.TextSize = 13
InstructionsText.Font = Enum.Font.GothamMedium
InstructionsText.TextXAlignment = Enum.TextXAlignment.Left
InstructionsText.TextYAlignment = Enum.TextYAlignment.Top
InstructionsText.TextWrapped = true
InstructionsText.ZIndex = 6
InstructionsText.Parent = InstructionsBox
local function createAdaptiveFixedCard(name, positionScale, yIndex, mobileYIndex)
    local Card = Instance.new("Frame")
    Card.Name = name .. "Card"
    Card.BackgroundColor3 = Theme.CardBackground
    Card.BackgroundTransparency = 0.15
    if isMobile then
        local yPos = 4 + (mobileYIndex or 0) * 260
        Card.Size = UDim2.new(1, -8, 0, 250)
        Card.Position = UDim2.new(0, 4, 0, yPos)
    else
        local yPos = 4 + (yIndex or 0) * 260
        Card.Size = UDim2.new(0.5, -8, 0, 250)
        Card.Position = UDim2.new(positionScale, 4, 0, yPos)
    end
    Card.ZIndex = 4
    Card.Parent = SettingsScroll
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Theme.Stroke
    CardStroke.Thickness = 1
    CardStroke.Parent = Card
    return Card
end
local CustomInterfaceCard = createAdaptiveFixedCard("CustomInterface", 0, 0, 0)
local Card1Title = Instance.new("TextLabel")
Card1Title.Size = UDim2.new(1, 0, 0, 22)
Card1Title.Position = UDim2.new(0, 0, 0, 10)
Card1Title.BackgroundTransparency = 1
Card1Title.Text = "Custom Interface"
Card1Title.TextColor3 = Theme.Text
Card1Title.TextSize = 14
Card1Title.Font = Enum.Font.GothamBold
Card1Title.TextXAlignment = Enum.TextXAlignment.Center
Card1Title.ZIndex = 5
Card1Title.Parent = CustomInterfaceCard
addDualIcons(Card1Title, "108407980345110")
local BgToggleLabel = Instance.new("TextLabel")
BgToggleLabel.Size = UDim2.new(0, 150, 0, 18)
BgToggleLabel.Position = UDim2.new(0, 12, 0, 36)
BgToggleLabel.BackgroundTransparency = 1
BgToggleLabel.Text = "Enable Custom Image"
BgToggleLabel.TextColor3 = Theme.MutedText
BgToggleLabel.TextSize = 12
BgToggleLabel.Font = Enum.Font.GothamMedium
BgToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
BgToggleLabel.ZIndex = 5
BgToggleLabel.Parent = CustomInterfaceCard
local BgToggleBtn = Instance.new("TextButton")
BgToggleBtn.Size = UDim2.new(0, 42, 0, 20)
BgToggleBtn.Position = UDim2.new(1, -54, 0, 35)
BgToggleBtn.BackgroundColor3 = SavedData.UseCustomBackground and Theme.Highlight or Color3.fromRGB(45, 43, 50)
BgToggleBtn.Text = ""
BgToggleBtn.ZIndex = 5
BgToggleBtn.Parent = CustomInterfaceCard
local BgToggleCorner = Instance.new("UICorner")
BgToggleCorner.CornerRadius = UDim.new(1, 0)
BgToggleCorner.Parent = BgToggleBtn
local BgToggleCircle = Instance.new("Frame")
BgToggleCircle.Size = UDim2.new(0, 14, 0, 14)
BgToggleCircle.Position = SavedData.UseCustomBackground and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
BgToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BgToggleCircle.ZIndex = 6
BgToggleCircle.Parent = BgToggleBtn
local BgCircleCorner = Instance.new("UICorner")
BgCircleCorner.CornerRadius = UDim.new(1, 0)
BgCircleCorner.Parent = BgToggleCircle
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -50, 0, 16)
SliderLabel.Position = UDim2.new(0, 12, 0, 68)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Interface Transparency"
SliderLabel.TextColor3 = Theme.MutedText
SliderLabel.TextSize = 11
SliderLabel.Font = Enum.Font.GothamMedium
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.ZIndex = 5
SliderLabel.Parent = CustomInterfaceCard
local SliderValueLabel = Instance.new("TextLabel")
SliderValueLabel.Size = UDim2.new(0, 30, 0, 16)
SliderValueLabel.Position = UDim2.new(1, -42, 0, 68)
SliderValueLabel.BackgroundTransparency = 1
SliderValueLabel.Text = tostring(SavedData.Transparency)
SliderValueLabel.TextColor3 = Theme.Highlight
SliderValueLabel.TextSize = 12
SliderValueLabel.Font = Enum.Font.GothamBold
SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
SliderValueLabel.ZIndex = 5
SliderValueLabel.Parent = CustomInterfaceCard
local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, -24, 0, 4)
SliderTrack.Position = UDim2.new(0, 12, 0, 90)
SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 38, 43)
SliderTrack.BorderSizePixel = 0
SliderTrack.ZIndex = 5
SliderTrack.Parent = CustomInterfaceCard
local SliderTrackCorner = Instance.new("UICorner")
SliderTrackCorner.CornerRadius = UDim.new(0, 2)
SliderTrackCorner.Parent = SliderTrack
local initPercent = SavedData.Transparency / 100
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
SliderFill.BackgroundColor3 = Theme.Highlight
SliderFill.BorderSizePixel = 0
SliderFill.ZIndex = 5
SliderFill.Parent = SliderTrack
local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 2)
SliderFillCorner.Parent = SliderFill
local SliderThumb = Instance.new("Frame")
SliderThumb.Size = UDim2.new(0, 14, 0, 14)
SliderThumb.Position = UDim2.new(initPercent, -7, 0.5, -7)
SliderThumb.BackgroundColor3 = Color3.fromRGB(220, 220, 225)
SliderThumb.ZIndex = 6
SliderThumb.Parent = SliderTrack
local ThumbCorner = Instance.new("UICorner")
ThumbCorner.CornerRadius = UDim.new(1, 0)
ThumbCorner.Parent = SliderThumb
local ImagePreviewFrame = Instance.new("Frame")
ImagePreviewFrame.Size = UDim2.new(1, -24, 0, 42)
ImagePreviewFrame.Position = UDim2.new(0, 12, 0, 106)
ImagePreviewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ImagePreviewFrame.ClipsDescendants = true
ImagePreviewFrame.ZIndex = 5
ImagePreviewFrame.Parent = CustomInterfaceCard
local PreviewCorner = Instance.new("UICorner")
PreviewCorner.CornerRadius = UDim.new(0, 6)
PreviewCorner.Parent = ImagePreviewFrame
local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(1, 0, 2.2, 0)
ImagePreview.Position = UDim2.new(0, 0, -0.4, 0)
ImagePreview.BackgroundTransparency = 1
ImagePreview.Image = SavedData.BackgroundAsset
ImagePreview.ScaleType = Enum.ScaleType.Crop
ImagePreview.ImageTransparency = SavedData.UseCustomBackground and 0 or 0.7
ImagePreview.ZIndex = 5
ImagePreview.Parent = ImagePreviewFrame
local IdBox = Instance.new("TextBox")
IdBox.Size = UDim2.new(1, -24, 0, 24)
IdBox.Position = UDim2.new(0, 12, 0, 160)
IdBox.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
IdBox.Text = SavedData.BackgroundAsset
IdBox.TextColor3 = Color3.fromRGB(180, 180, 185)
IdBox.Font = Enum.Font.Code
IdBox.TextSize = 10
IdBox.ClearTextOnFocus = false
IdBox.ClipsDescendants = true
IdBox.TextTruncate = Enum.TextTruncate.AtEnd
IdBox.TextXAlignment = Enum.TextXAlignment.Left
IdBox.ZIndex = 5
IdBox.Parent = CustomInterfaceCard
local IdBoxPadding = Instance.new("UIPadding")
IdBoxPadding.PaddingLeft = UDim.new(0, 6)
IdBoxPadding.PaddingRight = UDim.new(0, 6)
IdBoxPadding.Parent = IdBox
local IdBoxCorner = Instance.new("UICorner")
IdBoxCorner.CornerRadius = UDim.new(0, 6)
IdBoxCorner.Parent = IdBox
local IdBoxStroke = Instance.new("UIStroke")
IdBoxStroke.Color = Theme.Stroke
IdBoxStroke.Thickness = 1
IdBoxStroke.Parent = IdBox
IdBox.Focused:Connect(function() IdBox.Text = "" end)
IdBox.FocusLost:Connect(function()
    local input = IdBox.Text:gsub("%s+", "")
    local validId = input:match("^rbxassetid://%d+$") or (input:match("^%d+$") and "rbxassetid://" .. input)
    if validId then
        SavedData.BackgroundAsset = validId
        if SavedData.UseCustomBackground then MainBackgroundImage.Image = validId end
        ImagePreview.Image = validId
        IdBox.Text = validId
        saveConfig()
    else
        IdBox.Text = SavedData.BackgroundAsset
    end
end)
local function handleBgToggle()
    SavedData.UseCustomBackground = not SavedData.UseCustomBackground
    saveConfig()
    local targetPos = SavedData.UseCustomBackground and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    local targetColor = SavedData.UseCustomBackground and Theme.Highlight or Color3.fromRGB(45, 43, 50)
    TweenService:Create(BgToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = targetPos }):Play()
    TweenService:Create(BgToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { BackgroundColor3 = targetColor }):Play()
    if SavedData.UseCustomBackground then
        MainBackgroundImage.Visible = true
        TweenService:Create(MainBackgroundImage, TweenInfo.new(0.2),
            { ImageTransparency = (SavedData.Transparency / 100) })
            :Play()
        TweenService:Create(ImagePreview, TweenInfo.new(0.2), { ImageTransparency = 0 }):Play()
    else
        TweenService:Create(ImagePreview, TweenInfo.new(0.2), { ImageTransparency = 0.7 }):Play()
        local tween = TweenService:Create(MainBackgroundImage, TweenInfo.new(0.2), { ImageTransparency = 1 })
        tween:Play()
        tween.Completed:Connect(function()
            if not SavedData.UseCustomBackground then MainBackgroundImage.Visible = false end
        end)
    end
end
BgToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        handleBgToggle()
    end
end)
local isDraggingSlider = false
local function updateSlider(inputObject)
    local inputLocation
    if inputObject.UserInputType == Enum.UserInputType.Touch then
        inputLocation = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
    else
        inputLocation = UserInputService:GetMouseLocation()
    end
    local percentage = math.clamp((inputLocation.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
    TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = UDim2.new(percentage, 0, 1, 0)
    }):Play()
    TweenService:Create(SliderThumb, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = UDim2.new(percentage, -7, 0.5, -7)
    }):Play()
    local transparencyValue = math.round(percentage * 100)
    SliderValueLabel.Text = tostring(transparencyValue)
    local finalTransparency = (transparencyValue / 100)
    MainFrame.BackgroundTransparency = finalTransparency
    TabContainer.BackgroundTransparency = finalTransparency
    if SavedData.UseCustomBackground then
        MainBackgroundImage.ImageTransparency = finalTransparency
    end
    SavedData.Transparency = transparencyValue
    saveConfig()
end
SliderThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)
local UiSettingsCard = createAdaptiveFixedCard("UiSettings", 0.5, 0, 1)
local ToggleTitle = Instance.new("TextLabel")
ToggleTitle.Size = UDim2.new(1, 0, 0, 22)
ToggleTitle.Position = UDim2.new(0, 0, 0, 10)
ToggleTitle.BackgroundTransparency = 1
ToggleTitle.Text = "UI Settings"
ToggleTitle.TextColor3 = Theme.Text
ToggleTitle.TextSize = 14
ToggleTitle.Font = Enum.Font.GothamBold
ToggleTitle.TextXAlignment = Enum.TextXAlignment.Center
ToggleTitle.ZIndex = 5
ToggleTitle.Parent = UiSettingsCard
addDualIcons(ToggleTitle, "108407980345110")
local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, -75, 0, 18)
ToggleLabel.Position = UDim2.new(0, 12, 0, 36)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "UI Border Highlight"
ToggleLabel.TextColor3 = Theme.MutedText
ToggleLabel.TextSize = 12
ToggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.ZIndex = 5
ToggleLabel.Parent = UiSettingsCard
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 42, 0, 20)
ToggleBtn.Position = UDim2.new(1, -54, 0, 35)
ToggleBtn.BackgroundColor3 = SavedData.BorderOn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
ToggleBtn.Text = ""
ToggleBtn.ZIndex = 5
ToggleBtn.Parent = UiSettingsCard
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn
local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
ToggleCircle.Position = SavedData.BorderOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleCircle.ZIndex = 6
ToggleCircle.Parent = ToggleBtn
local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = ToggleCircle
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -24, 0, 1)
Separator.Position = UDim2.new(0, 12, 0, 142)
Separator.BackgroundColor3 = Theme.Stroke
Separator.BorderSizePixel = 0
Separator.ZIndex = 5
Separator.Parent = UiSettingsCard
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(1, -20, 0, 18)
ColorLabel.Position = UDim2.new(0, 12, 0, 152)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Highlight Color"
ColorLabel.TextColor3 = Theme.MutedText
ColorLabel.TextSize = 12
ColorLabel.Font = Enum.Font.GothamMedium
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.ZIndex = 5
ColorLabel.Parent = UiSettingsCard
local ColorContainer = Instance.new("Frame")
ColorContainer.Size = UDim2.new(1, -24, 0, 24)
ColorContainer.Position = UDim2.new(0, 12, 0, 176)
ColorContainer.BackgroundTransparency = 1
ColorContainer.ZIndex = 5
ColorContainer.Parent = UiSettingsCard
local ColorList = Instance.new("UIListLayout")
ColorList.FillDirection = Enum.FillDirection.Horizontal
ColorList.SortOrder = Enum.SortOrder.LayoutOrder
ColorList.Padding = UDim.new(0, 8)
ColorList.Parent = ColorContainer
local strokeOn = SavedData.BorderOn
local function updateGlobalHighlightColor(newColor)
    Theme.Highlight = newColor
    for _, icon in ipairs(DualIconsList) do
        icon.ImageColor3 = newColor
    end
    SliderFill.BackgroundColor3 = newColor
    SliderValueLabel.TextColor3 = newColor
    if strokeOn then
        MainStroke.Color = newColor
        ToggleBtn.BackgroundColor3 = newColor
    end
    if SavedData.UseCustomBackground then
        BgToggleBtn.BackgroundColor3 = newColor
    end
    for name, btn in pairs(TabButtons) do
        if Pages[name].Visible then btn.ImageColor3 = newColor end
    end
    if MainFrame:FindFirstChild("ResizeVisualIndicator") then
        for _, line in ipairs(MainFrame.ResizeVisualIndicator:GetChildren()) do
            if line:IsA("Frame") then line.BackgroundColor3 = newColor end
        end
    end
    if roseRainOn then
        RoseRainBtn.BackgroundColor3 = newColor
    end
    if antiNwOn and AntiNwBtn then
        AntiNwBtn.BackgroundColor3 = newColor
    end
    if infMoneyOn then
        InfMoneyBtn.BackgroundColor3 = newColor
    end
    ServerHopBtn.BackgroundColor3 = newColor
    GiveGunBtn.BackgroundColor3 = newColor
    local targetStrokeColor = strokeOn and newColor or Color3.fromRGB(60, 60, 65)
    DropListStroke.Color = targetStrokeColor
    TpDropListStroke.Color = targetStrokeColor
    D1.LS.Color = targetStrokeColor
    D2.LS.Color = targetStrokeColor
    DropList.ScrollBarImageColor3 = newColor
    PurchaseBtn.BackgroundColor3 = newColor
    TpBtn.BackgroundColor3 = newColor
    TpDropList.ScrollBarImageColor3 = newColor
    D1.List.ScrollBarImageColor3 = newColor
    D2.List.ScrollBarImageColor3 = newColor
    for _, notif in ipairs(NotifContainer:GetChildren()) do
        if notif:IsA("Frame") then
            local ns = notif:FindFirstChildWhichIsA("UIStroke")
            if ns then ns.Color = newColor end
            local acc = notif:FindFirstChild("accent") or notif:FindFirstChildOfClass("Frame")
            if acc and acc.Name ~= "UICorner" then acc.BackgroundColor3 = newColor end
        end
    end
    for _, item in ipairs(DynamicHighlightElements) do
        if item.obj and item.obj.Parent then
            if item.isBorder then
                item.obj[item.prop] = targetStrokeColor
            else
                item.obj[item.prop] = newColor
            end
        end
    end
    SavedData.HighlightColor = { math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255) }
    saveConfig()
end
for i, color in pairs(colorPalette) do
    local ColorOption = Instance.new("TextButton")
    ColorOption.Size = UDim2.new(0, 20, 0, 20)
    ColorOption.BackgroundColor3 = color
    ColorOption.Text = ""
    ColorOption.LayoutOrder = i
    ColorOption.ZIndex = 5
    ColorOption.Parent = ColorContainer
    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(1, 0)
    OptionCorner.Parent = ColorOption
    local OptionStroke = Instance.new("UIStroke")
    OptionStroke.Color = Color3.fromRGB(255, 255, 255)
    OptionStroke.Thickness = (color == Theme.Highlight) and 1.2 or 0
    OptionStroke.Parent = ColorOption
    ColorOption.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            for _, child in ipairs(ColorContainer:GetChildren()) do
                if child:IsA("TextButton") and child:FindFirstChild("UIStroke") then
                    child.UIStroke.Thickness = 0
                end
            end
            OptionStroke.Thickness = 1.2
            updateGlobalHighlightColor(color)
        end
    end)
end
local RoseRainLabel = Instance.new("TextLabel")
RoseRainLabel.Size = UDim2.new(1, -75, 0, 18)
RoseRainLabel.Position = UDim2.new(0, 12, 0, 80)
RoseRainLabel.BackgroundTransparency = 1
RoseRainLabel.Text = "Enable Rose Rain"
RoseRainLabel.TextColor3 = Theme.MutedText
RoseRainLabel.TextSize = 12
RoseRainLabel.TextTruncate = Enum.TextTruncate.AtEnd
RoseRainLabel.Font = Enum.Font.GothamMedium
RoseRainLabel.TextXAlignment = Enum.TextXAlignment.Left
RoseRainLabel.ZIndex = 5
RoseRainLabel.Parent = UiSettingsCard
local RoseRainBtn = Instance.new("TextButton")
RoseRainBtn.Size = UDim2.new(0, 42, 0, 20)
RoseRainBtn.Position = UDim2.new(1, -54, 0, 79)
RoseRainBtn.BackgroundColor3 = SavedData.RoseRainOn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
RoseRainBtn.Text = ""
RoseRainBtn.ZIndex = 5
RoseRainBtn.Parent = UiSettingsCard
local RoseRainBtnCorner = Instance.new("UICorner")
RoseRainBtnCorner.CornerRadius = UDim.new(1, 0)
RoseRainBtnCorner.Parent = RoseRainBtn
local RoseRainCircle = Instance.new("Frame")
RoseRainCircle.Size = UDim2.new(0, 14, 0, 14)
RoseRainCircle.Position = SavedData.RoseRainOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
RoseRainCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RoseRainCircle.ZIndex = 6
RoseRainCircle.Parent = RoseRainBtn
local RoseRainCircleCorner = Instance.new("UICorner")
RoseRainCircleCorner.CornerRadius = UDim.new(1, 0)
RoseRainCircleCorner.Parent = RoseRainCircle
local roseRainOn = SavedData.RoseRainOn
local roseRainConnection = nil
local RoseRainContainer = Instance.new("Frame")
RoseRainContainer.Name = "RoseRainContainer"
RoseRainContainer.Size = UDim2.new(1, 0, 1, 0)
RoseRainContainer.Position = UDim2.new(0, 0, 0, 0)
RoseRainContainer.BackgroundTransparency = 1
RoseRainContainer.ClipsDescendants = true
RoseRainContainer.ZIndex = 6
RoseRainContainer.Parent = MainFrame
local RoseRainCorner = Instance.new("UICorner")
RoseRainCorner.CornerRadius = UDim.new(0, 14)
RoseRainCorner.Parent = RoseRainContainer
local roseEmojis = { "🌹", "🌸", "🌺", "🌷" }
local function spawnRose()
    local rose = Instance.new("TextLabel")
    rose.Size = UDim2.new(0, 14, 0, 14)
    rose.Position = UDim2.new(math.random(3, 93) / 100, 0, -0.01, 0)
    rose.BackgroundTransparency = 1
    rose.Text = roseEmojis[math.random(1, #roseEmojis)]
    rose.TextSize = math.random(9, 13)
    rose.ZIndex = 7
    rose.Parent = RoseRainContainer
    local fallTime = math.random(30, 60) / 10
    local swayAmount = math.random(-12, 12)
    local rotStart = math.random(0, 360)
    local tween = TweenService:Create(rose, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
        Position = UDim2.new(
            rose.Position.X.Scale + swayAmount / 800,
            swayAmount,
            0.97,
            0
        ),
        Rotation = rotStart + math.random(-160, 160),
        TextTransparency = 0.1
    })
    tween:Play()
    tween.Completed:Connect(function()
        rose:Destroy()
    end)
end
local function startRoseRain()
    roseRainConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not ScreenGui.Parent then
            stopRoseRain()
            return
        end
        if math.random(1, 30) == 1 then
            pcall(spawnRose)
        end
    end)
end
local function stopRoseRain()
    if roseRainConnection then
        roseRainConnection:Disconnect()
        roseRainConnection = nil
    end
    for _, child in ipairs(RoseRainContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
            game:GetService("Debris"):AddItem(child, 0.6)
        end
    end
end
local function handleRoseRainToggle()
    roseRainOn = not roseRainOn
    local targetPos = roseRainOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    local targetColor = roseRainOn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
    TweenService:Create(RoseRainCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = targetPos }):Play()
    TweenService:Create(RoseRainBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { BackgroundColor3 = targetColor }):Play()
    if roseRainOn then
        startRoseRain()
    else
        stopRoseRain()
    end
    SavedData.RoseRainOn = roseRainOn
    saveConfig()
end
RoseRainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        handleRoseRainToggle()
    end
end)

AntiNwBtn = Instance.new("TextButton") -- global to save registers
AntiNwBtn.Size = UDim2.new(0, 42, 0, 20)
AntiNwBtn.Position = UDim2.new(1, -54, 0, 109)
AntiNwBtn.BackgroundColor3 = SavedData.AntiNetworkPause and Theme.Highlight or Color3.fromRGB(45, 43, 50)
AntiNwBtn.Text = ""
AntiNwBtn.ZIndex = 5
AntiNwBtn.Parent = UiSettingsCard

do
    local AntiNwLabel = Instance.new("TextLabel")
    AntiNwLabel.Size = UDim2.new(1, -75, 0, 18)
    AntiNwLabel.Position = UDim2.new(0, 12, 0, 110)
    AntiNwLabel.BackgroundTransparency = 1
    AntiNwLabel.Text = "Anti Network Pause"
    AntiNwLabel.TextColor3 = Theme.MutedText
    AntiNwLabel.TextSize = 12
    AntiNwLabel.TextTruncate = Enum.TextTruncate.AtEnd
    AntiNwLabel.Font = Enum.Font.GothamMedium
    AntiNwLabel.TextXAlignment = Enum.TextXAlignment.Left
    AntiNwLabel.ZIndex = 5
    AntiNwLabel.Parent = UiSettingsCard

    local AntiNwBtnCorner = Instance.new("UICorner")
    AntiNwBtnCorner.CornerRadius = UDim.new(1, 0)
    AntiNwBtnCorner.Parent = AntiNwBtn

    local AntiNwCircle = Instance.new("Frame")
    AntiNwCircle.Size = UDim2.new(0, 14, 0, 14)
    AntiNwCircle.Position = SavedData.AntiNetworkPause and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    AntiNwCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AntiNwCircle.ZIndex = 6
    AntiNwCircle.Parent = AntiNwBtn

    local AntiNwCircleCorner = Instance.new("UICorner")
    AntiNwCircleCorner.CornerRadius = UDim.new(1, 0)
    AntiNwCircleCorner.Parent = AntiNwCircle

    antiNwOn = SavedData.AntiNetworkPause -- global

    local function handleAntiNwToggle()
        antiNwOn = not antiNwOn
        local targetPos = antiNwOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetColor = antiNwOn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
        TweenService:Create(AntiNwCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = targetPos }):Play()
        TweenService:Create(AntiNwBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { BackgroundColor3 = targetColor }):Play()

        if antiNwOn then
            pcall(function()
                local np = game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
                if np then np:Destroy() end
            end)
        end

        SavedData.AntiNetworkPause = antiNwOn
        saveConfig()
    end

    AntiNwBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            handleAntiNwToggle()
        end
    end)

    task.spawn(function()
        if antiNwOn then
            pcall(function()
                local np = game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
                if np then np:Destroy() end
            end)
        end
    end)
end

local function handleBorderToggle()
    strokeOn = not strokeOn
    local targetPos = strokeOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    local targetColor = strokeOn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
    local targetStrokeColor = strokeOn and Theme.Highlight or Color3.fromRGB(60, 60, 65)
    TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = targetPos }):Play()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { BackgroundColor3 = targetColor }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
    TweenService:Create(TpDropListStroke, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
    TweenService:Create(D1.LS, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
    TweenService:Create(D2.LS, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
    TweenService:Create(DropListStroke, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
    for _, item in ipairs(DynamicHighlightElements) do
        if item.isBorder and item.obj and item.obj.Parent then
            TweenService:Create(item.obj, TweenInfo.new(0.18), { [item.prop] = targetStrokeColor }):Play()
        end
    end
    SavedData.BorderOn = strokeOn
    saveConfig()
end

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        handleBorderToggle()
    end
end)

;(function()
local NotificationsCard = createAdaptiveFixedCard("Notifications", 0.5, 1, 2)
local NotifCardTitle = Instance.new("TextLabel")
NotifCardTitle.Size = UDim2.new(1, 0, 0, 22)
NotifCardTitle.Position = UDim2.new(0, 0, 0, 10)
NotifCardTitle.BackgroundTransparency = 1
NotifCardTitle.Text = "Notifications"
NotifCardTitle.TextColor3 = Theme.Text
NotifCardTitle.TextSize = 14
NotifCardTitle.Font = Enum.Font.GothamBold
NotifCardTitle.TextXAlignment = Enum.TextXAlignment.Center
NotifCardTitle.ZIndex = 5
NotifCardTitle.Parent = NotificationsCard
addDualIcons(NotifCardTitle, "108407980345110")

local EnNotifLabel = Instance.new("TextLabel")
EnNotifLabel.Size = UDim2.new(1, -75, 0, 18)
EnNotifLabel.Position = UDim2.new(0, 12, 0, 45)
EnNotifLabel.BackgroundTransparency = 1
EnNotifLabel.Text = "Enable Notifications"
EnNotifLabel.TextColor3 = Theme.MutedText
EnNotifLabel.TextSize = 12
EnNotifLabel.TextTruncate = Enum.TextTruncate.AtEnd
EnNotifLabel.Font = Enum.Font.GothamMedium
EnNotifLabel.TextXAlignment = Enum.TextXAlignment.Left
EnNotifLabel.ZIndex = 5
EnNotifLabel.Parent = NotificationsCard

local EnNotifBtn = Instance.new("TextButton")
EnNotifBtn.Size = UDim2.new(0, 42, 0, 20)
EnNotifBtn.Position = UDim2.new(1, -54, 0, 44)
EnNotifBtn.BackgroundColor3 = SavedData.NotifsEnabled and Theme.Highlight or Color3.fromRGB(45, 43, 50)
EnNotifBtn.Text = ""
EnNotifBtn.ZIndex = 5
EnNotifBtn.Parent = NotificationsCard
local ENB_Corner = Instance.new("UICorner")
ENB_Corner.CornerRadius = UDim.new(1, 0)
ENB_Corner.Parent = EnNotifBtn
local ENB_Circle = Instance.new("Frame")
ENB_Circle.Size = UDim2.new(0, 14, 0, 14)
ENB_Circle.Position = SavedData.NotifsEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
ENB_Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ENB_Circle.ZIndex = 6
ENB_Circle.Parent = EnNotifBtn
local ENB_CircleCorner = Instance.new("UICorner")
ENB_CircleCorner.CornerRadius = UDim.new(1, 0)
ENB_CircleCorner.Parent = ENB_Circle

EnNotifBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SavedData.NotifsEnabled = not SavedData.NotifsEnabled
        saveConfig()
        local tPos = SavedData.NotifsEnabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local tCol = SavedData.NotifsEnabled and Theme.Highlight or Color3.fromRGB(45, 43, 50)
        TweenService:Create(ENB_Circle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position=tPos}):Play()
        TweenService:Create(EnNotifBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundColor3=tCol}):Play()
    end
end)

local PosDropBtn = Instance.new("TextButton")
PosDropBtn.Size = UDim2.new(1, -24, 0, 28)
PosDropBtn.Position = UDim2.new(0, 12, 0, 85)
PosDropBtn.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
PosDropBtn.Text = ""
PosDropBtn.ZIndex = 5
PosDropBtn.Parent = NotificationsCard
local PosDropCorner = Instance.new("UICorner"); PosDropCorner.CornerRadius = UDim.new(0, 6); PosDropCorner.Parent = PosDropBtn
local PosDropStroke = Instance.new("UIStroke"); PosDropStroke.Color = Theme.Stroke; PosDropStroke.Thickness = 1; PosDropStroke.Parent = PosDropBtn

local PosDropLabel = Instance.new("TextLabel")
PosDropLabel.Size = UDim2.new(1, -30, 1, 0); PosDropLabel.Position = UDim2.new(0, 8, 0, 0)
PosDropLabel.BackgroundTransparency = 1; PosDropLabel.Text = SavedData.NotifsPosition
PosDropLabel.TextColor3 = Theme.MutedText; PosDropLabel.TextSize = 11
PosDropLabel.Font = Enum.Font.GothamMedium; PosDropLabel.TextXAlignment = Enum.TextXAlignment.Left; PosDropLabel.ZIndex = 6; PosDropLabel.Parent = PosDropBtn

local PosDropArr = Instance.new("TextLabel")
PosDropArr.Size = UDim2.new(0, 20, 1, 0); PosDropArr.Position = UDim2.new(1, -24, 0, 0)
PosDropArr.BackgroundTransparency = 1; PosDropArr.Text = "v"; PosDropArr.TextColor3 = Theme.MutedText
PosDropArr.TextSize = 13; PosDropArr.Font = Enum.Font.GothamBold; PosDropArr.ZIndex = 6; PosDropArr.Parent = PosDropBtn

local PosDropList = Instance.new("ScrollingFrame")
PosDropList.Size = UDim2.new(1, -24, 0, 0); PosDropList.Position = UDim2.new(0, 12, 0, 117)
PosDropList.BackgroundColor3 = Color3.fromRGB(13, 12, 15); PosDropList.BorderSizePixel = 0
PosDropList.ClipsDescendants = true; PosDropList.ZIndex = 20; PosDropList.Visible = false
PosDropList.ScrollBarThickness = 3; PosDropList.ScrollBarImageColor3 = Theme.Highlight
PosDropList.CanvasSize = UDim2.new(0, 0, 0, 0); PosDropList.AutomaticCanvasSize = Enum.AutomaticSize.Y; PosDropList.Parent = NotificationsCard
local PDL_Corner = Instance.new("UICorner"); PDL_Corner.CornerRadius = UDim.new(0, 6); PDL_Corner.Parent = PosDropList
local PDL_Stroke = Instance.new("UIStroke"); PDL_Stroke.Color = Theme.Highlight; PDL_Stroke.Thickness = 1; PDL_Stroke.Parent = PosDropList
local PDL_Layout = Instance.new("UIListLayout"); PDL_Layout.SortOrder = Enum.SortOrder.LayoutOrder; PDL_Layout.Parent = PosDropList

local posOptions = {"Top Right", "Top Left", "Bottom Right", "Bottom Left"}
local posDropOpen = false
for i, opt in ipairs(posOptions) do
    local Item = Instance.new("TextButton")
    Item.Size = UDim2.new(1, 0, 0, 32); Item.BackgroundTransparency = 1; Item.Text = opt
    Item.TextColor3 = (opt == SavedData.NotifsPosition) and Theme.Highlight or Theme.MutedText
    Item.TextSize = 11; Item.Font = Enum.Font.GothamMedium; Item.TextXAlignment = Enum.TextXAlignment.Left
    Item.ZIndex = 21; Item.AutoButtonColor = false; Item.Parent = PosDropList
    local ItemPad = Instance.new("UIPadding"); ItemPad.PaddingLeft = UDim.new(0, 10); ItemPad.Parent = Item
    
    Item.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            SavedData.NotifsPosition = opt; saveConfig()
            PosDropLabel.Text = opt
            for _, c in ipairs(PosDropList:GetChildren()) do
                if c:IsA("TextButton") then c.TextColor3 = Theme.MutedText end
            end
            Item.TextColor3 = Theme.Highlight
            posDropOpen = false; PosDropArr.Text = "v"
            TweenService:Create(PosDropList, TweenInfo.new(0.18), {Size = UDim2.new(1, -24, 0, 0)}):Play()
            task.delay(0.18, function() PosDropList.Visible = false end)
            
            -- Update NotifContainer position dynamically
            if NotifContainer then
                if SavedData.NotifsPosition == "Top Right" then
                    NotifContainer.Position = UDim2.new(1, -295, 0, 20)
                    NotifContainer.AnchorPoint = Vector2.new(0, 0)
                    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
                elseif SavedData.NotifsPosition == "Top Left" then
                    NotifContainer.Position = UDim2.new(0, 15, 0, 20)
                    NotifContainer.AnchorPoint = Vector2.new(0, 0)
                    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
                elseif SavedData.NotifsPosition == "Bottom Left" then
                    NotifContainer.Position = UDim2.new(0, 15, 1, -20)
                    NotifContainer.AnchorPoint = Vector2.new(0, 1)
                    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
                else -- Bottom Right
                    NotifContainer.Position = UDim2.new(1, -295, 1, -20)
                    NotifContainer.AnchorPoint = Vector2.new(0, 1)
                    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
                end
            end
        end
    end)
end

PosDropBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        posDropOpen = not posDropOpen
        if posDropOpen then
            PosDropList.Visible = true; PosDropArr.Text = "^"
            TweenService:Create(PosDropList, TweenInfo.new(0.18), {Size = UDim2.new(1, -24, 0, #posOptions*32)}):Play()
        else
            PosDropArr.Text = "v"
            TweenService:Create(PosDropList, TweenInfo.new(0.18), {Size = UDim2.new(1, -24, 0, 0)}):Play()
            task.delay(0.18, function() PosDropList.Visible = false end)
        end
    end
end)
end)()

local UiControlsCard = createAdaptiveFixedCard("UiControls", 0, 1, 3)
UiControlsCard.Size = UDim2.new(0.5, -8, 0, 130)
UiControlsCard.Position = UDim2.new(0, 4, 0, 262)
local UiControlsTitle = Instance.new("TextLabel")
UiControlsTitle.Size = UDim2.new(1, 0, 0, 22)
UiControlsTitle.Position = UDim2.new(0, 0, 0, 10)
UiControlsTitle.BackgroundTransparency = 1
UiControlsTitle.Text = "UI Controls"
UiControlsTitle.TextColor3 = Theme.Text
UiControlsTitle.TextSize = 14
UiControlsTitle.Font = Enum.Font.GothamBold
UiControlsTitle.TextXAlignment = Enum.TextXAlignment.Center
UiControlsTitle.ZIndex = 5
UiControlsTitle.Parent = UiControlsCard
addDualIcons(UiControlsTitle, "110988172427562")
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(0, 150, 0, 18)
KeybindLabel.Position = UDim2.new(0, 12, 0, 45)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = isMobile and "Show Floating Toggle" or "Hide UI Keybind"
KeybindLabel.TextColor3 = Theme.MutedText
KeybindLabel.TextSize = 12
KeybindLabel.Font = Enum.Font.GothamMedium
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.ZIndex = 5
KeybindLabel.Parent = UiControlsCard

if isMobile then
    local MobileToggleBtn = Instance.new("TextButton")
    MobileToggleBtn.Size = UDim2.new(0, 42, 0, 20)
    MobileToggleBtn.Position = UDim2.new(1, -54, 0, 44)
    MobileToggleBtn.BackgroundColor3 = SavedData.ShowMobileHideBtn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
    MobileToggleBtn.Text = ""
    MobileToggleBtn.ZIndex = 5
    MobileToggleBtn.Parent = UiControlsCard
    local MTB_Corner = Instance.new("UICorner")
    MTB_Corner.CornerRadius = UDim.new(1, 0)
    MTB_Corner.Parent = MobileToggleBtn
    local MTB_Circle = Instance.new("Frame")
    MTB_Circle.Size = UDim2.new(0, 14, 0, 14)
    MTB_Circle.Position = SavedData.ShowMobileHideBtn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    MTB_Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MTB_Circle.ZIndex = 6
    MTB_Circle.Parent = MobileToggleBtn
    local MTB_CircleCorner = Instance.new("UICorner")
    MTB_CircleCorner.CornerRadius = UDim.new(1, 0)
    MTB_CircleCorner.Parent = MTB_Circle
    
    MobileToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            SavedData.ShowMobileHideBtn = not SavedData.ShowMobileHideBtn
            saveConfig()
            local targetPos = SavedData.ShowMobileHideBtn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            local targetColor = SavedData.ShowMobileHideBtn and Theme.Highlight or Color3.fromRGB(45, 43, 50)
            TweenService:Create(MTB_Circle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = targetPos }):Play()
            TweenService:Create(MobileToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundColor3 = targetColor }):Play()
            local mfb = ScreenGui:FindFirstChild("MobileFloatingButton")
            if mfb then mfb.Visible = SavedData.ShowMobileHideBtn end
        end
    end)
else
    local KeybindBtn = Instance.new("TextButton")
    KeybindBtn.Size = UDim2.new(0, 70, 0, 24)
    KeybindBtn.Position = UDim2.new(1, -82, 0, 42)
    KeybindBtn.BackgroundColor3 = Color3.fromRGB(45, 43, 50)
    KeybindBtn.Text = SavedData.HideUIKeybind or "None"
    KeybindBtn.TextColor3 = Theme.Text
    KeybindBtn.TextSize = 12
    KeybindBtn.Font = Enum.Font.GothamBold
    KeybindBtn.ZIndex = 5
    KeybindBtn.Parent = UiControlsCard
    local KBCorner = Instance.new("UICorner")
    KBCorner.CornerRadius = UDim.new(0, 4)
    KBCorner.Parent = KeybindBtn
    local isBinding = false
    KeybindBtn.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isBinding then
            isBinding = true
            KeybindBtn.Text = "..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(i, gp)
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    local kName = i.KeyCode.Name
                    if kName == "Escape" or kName == "Unknown" then
                        SavedData.HideUIKeybind = nil
                        KeybindBtn.Text = "None"
                    else
                        SavedData.HideUIKeybind = kName
                        KeybindBtn.Text = kName
                    end
                    saveConfig()
                    isBinding = false
                    conn:Disconnect()
                end
            end)
        end
    end)
end
local CloseUIBtn = Instance.new("TextButton")
CloseUIBtn.Size = UDim2.new(1, -24, 0, 28)
CloseUIBtn.Position = UDim2.new(0, 12, 0, 85)
CloseUIBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseUIBtn.Text = "Close UI (Double Click)"
CloseUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseUIBtn.TextSize = 12
CloseUIBtn.Font = Enum.Font.GothamBold
CloseUIBtn.ZIndex = 5
CloseUIBtn.Parent = UiControlsCard
local CCorner = Instance.new("UICorner")
CCorner.CornerRadius = UDim.new(0, 4)
CCorner.Parent = CloseUIBtn
local lastClick = 0
CloseUIBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastClick < 0.4 then
            if ScreenGui then ScreenGui:Destroy() end
        else
            lastClick = now
            CloseUIBtn.Text = "Click Again!"
            delay(0.4, function()
                if CloseUIBtn.Parent then CloseUIBtn.Text = "Close UI (Double Click)" end
            end)
        end
    end
end)
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Name = "ResizeBtn"
ResizeBtn.Size = UDim2.new(0, 30, 0, 30)
ResizeBtn.Position = UDim2.new(1, -30, 1, -30)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text = ""
ResizeBtn.ZIndex = 11
ResizeBtn.Parent = MainFrame
local ResizeIndicator = Instance.new("Frame")
ResizeIndicator.Name = "ResizeVisualIndicator"
ResizeIndicator.Size = UDim2.new(0, 16, 0, 16)
ResizeIndicator.Position = UDim2.new(1, -21, 1, -21)
ResizeIndicator.BackgroundTransparency = 1
ResizeIndicator.ClipsDescendants = false
ResizeIndicator.ZIndex = 10
ResizeIndicator.Parent = MainFrame
local linePositions = {
    { Size = UDim2.new(0, 4, 0, 2),  Pos = UDim2.new(1, -4, 1, -2) },
    { Size = UDim2.new(0, 8, 0, 2),  Pos = UDim2.new(1, -8, 1, -6) },
    { Size = UDim2.new(0, 12, 0, 2), Pos = UDim2.new(1, -12, 1, -10) }
}
for _, data in ipairs(linePositions) do
    local Line = Instance.new("Frame")
    Line.Size = data.Size
    Line.Position = data.Pos
    Line.BackgroundColor3 = Theme.Highlight
    Line.BorderSizePixel = 0
    Line.Rotation = -45
    Line.ZIndex = 10
    Line.Parent = ResizeIndicator
    local LineCorner = Instance.new("UICorner")
    LineCorner.CornerRadius = UDim.new(1, 0)
    LineCorner.Parent = Line
end
local isResizing = false
local startMousePos, startSize
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        startMousePos = Vector2.new(input.Position.X, input.Position.Y)
        startSize = MainFrame.AbsoluteSize
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isResizing then
            isResizing = false
            SavedData.SizeX = MainFrame.AbsoluteSize.X
            SavedData.SizeY = MainFrame.AbsoluteSize.Y
            saveConfig()
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentMousePos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentMousePos - startMousePos
        local minWidth = isMobile and 300 or 480
        local minHeight = isMobile and 220 or 350
        local newWidth = math.clamp(startSize.X + delta.X, minWidth, 900)
        local newHeight = math.clamp(startSize.Y + delta.Y, minHeight, 650)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input.Position.Y - gui.AbsolutePosition.Y < 40 and not isResizing then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and not isResizing then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            TweenService:Create(gui, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Position = targetPos }):Play()
        end
    end)
end
MakeDraggable(MainFrame);
(function()
    local BottomDragHandle = Instance.new("Frame")
    BottomDragHandle.Name = "BottomDragHandle"
    BottomDragHandle.Size = UDim2.new(0, 240, 0, 34)
    BottomDragHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    BottomDragHandle.Position = UDim2.new(0.5, 0, 1, 8)
    BottomDragHandle.BackgroundTransparency = 1
    BottomDragHandle.BorderSizePixel = 0
    BottomDragHandle.ZIndex = 10
    BottomDragHandle.Parent = MainFrame
    local VisibleBar = Instance.new("Frame")
    VisibleBar.Size = UDim2.new(0, 180, 0, 4)
    VisibleBar.AnchorPoint = Vector2.new(0.5, 0.5)
    VisibleBar.Position = UDim2.new(0.5, 0, 0.5, 0)
    VisibleBar.BackgroundColor3 = Theme.Highlight
    VisibleBar.BorderSizePixel = 0
    VisibleBar.Parent = BottomDragHandle
    local DragHandleCorner = Instance.new("UICorner")
    DragHandleCorner.CornerRadius = UDim.new(1, 0)
    DragHandleCorner.Parent = VisibleBar
    table.insert(DynamicHighlightElements, { obj = VisibleBar, prop = "BackgroundColor3" })
    local draggingHandle = false
    local dragInputHandle, dragStartHandle, startPosHandle
    BottomDragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not isResizing then
                draggingHandle = true
                dragStartHandle = input.Position
                startPosHandle = MainFrame.Position
                TweenService:Create(VisibleBar, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    { Size = UDim2.new(0, 210, 0, 6) }):Play()
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        draggingHandle = false
                        TweenService:Create(VisibleBar,
                            TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                            { Size = UDim2.new(0, 180, 0, 4) }):Play()
                    end
                end)
            end
        end
    end)
    BottomDragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInputHandle = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputHandle and draggingHandle and not isResizing then
            local delta = input.Position - dragStartHandle
            local targetPos = UDim2.new(
                startPosHandle.X.Scale, startPosHandle.X.Offset + delta.X,
                startPosHandle.Y.Scale, startPosHandle.Y.Offset + delta.Y
            )
            TweenService:Create(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Position = targetPos }):Play()
        end
    end)
end)()

if isMobile then
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Name = "MobileFloatingButton"
    FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
    FloatingBtn.Position = UDim2.new(0, 20, 0.5, -22)
    FloatingBtn.BackgroundColor3 = Theme.CardBackground
    FloatingBtn.BackgroundTransparency = 0.2
    FloatingBtn.Text = ""
    FloatingBtn.Visible = SavedData.ShowMobileHideBtn
    FloatingBtn.ZIndex = 100
    FloatingBtn.Parent = ScreenGui
    local FBCorner = Instance.new("UICorner")
    FBCorner.CornerRadius = UDim.new(1, 0)
    FBCorner.Parent = FloatingBtn
    local FBStroke = Instance.new("UIStroke")
    FBStroke.Color = Theme.Highlight
    FBStroke.Thickness = 1.5
    FBStroke.Parent = FloatingBtn
    local FBIcon = Instance.new("ImageLabel")
    FBIcon.Size = UDim2.new(0, 24, 0, 24)
    FBIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
    FBIcon.BackgroundTransparency = 1
    FBIcon.Image = "rbxassetid://108407980345110"
    FBIcon.ImageColor3 = Theme.Text
    FBIcon.Parent = FloatingBtn
    
    local fDrag, fInput, fStart, fPos
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            fDrag = true
            fStart = input.Position
            fPos = FloatingBtn.Position
            local clickTime = tick()
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fDrag = false
                    if tick() - clickTime < 0.25 and (input.Position - fStart).Magnitude < 10 then
                        MainFrame.Visible = not MainFrame.Visible
                    end
                    conn:Disconnect()
                end
            end)
        end
    end)
    FloatingBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            fInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == fInput and fDrag then
            local delta = input.Position - fStart
            FloatingBtn.Position = UDim2.new(
                fPos.X.Scale, fPos.X.Offset + delta.X,
                fPos.Y.Scale, fPos.Y.Offset + delta.Y
            )
        end
    end)
end

if SavedData.RoseRainOn then
    startRoseRain()
end
local ESP_CFG = {
    Enabled  = false,
    MaxDist  = 500,
    Boxes    = { Enabled = false, Color = Color3.new(1, 1, 1), Animated = false },
    Corners  = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Filled   = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0), Alpha = 0.25 },
    Names    = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Health   = { Enabled = false, Bar = false, Text = false, Dynamic = false, Color1 = Color3.fromRGB(0, 255, 0), Color2 = Color3.fromRGB(255, 0, 0) },
    Weapons  = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Dist     = { Enabled = false, Color = Color3.new(1, 1, 1) },
    Chams    = { Enabled = false, Color1 = Color3.fromRGB(119, 120, 255), Color2 = Color3.new(0, 0, 0), Thermal = false },
    FontSize = 12,
    Font     = Enum.Font.GothamBold,
}
local CROSSHAIR_CFG = {
    Enabled = false,
    Style = "Dot",
    Color = Color3.fromRGB(255, 255, 255),
    Size = 24,
    Thickness = 2,
    OutlineColor = Color3.fromRGB(0, 0, 0),
}
local RENDER_CROSSHAIR
local function InitESPEngine()
    local ESP_HOLDER = Instance.new("ScreenGui")
    ESP_HOLDER.Name = "CEN_ESP_HOLDER"
    ESP_HOLDER.IgnoreGuiInset = true
    ESP_HOLDER.DisplayOrder = 2147483645
    ESP_HOLDER.Parent = CoreGui
    local ESP_CACHE = {}
    local function MK_ESP(p)
        local E = {
            FRM = Instance.new("Frame", ESP_HOLDER),
            BOX = Instance.new("Frame"),
            BOX_GRAD = Instance.new("UIGradient"),
            OUT = Instance.new("UIStroke"),
            NAME = Instance.new("TextLabel"),
            DIST = Instance.new("TextLabel"),
            WEAP = Instance.new("TextLabel"),
            BAR_BG = Instance.new("Frame"),
            BAR_FL = Instance.new("Frame"),
            BAR_GRAD = Instance.new("UIGradient"),
            HEALTH_TXT = Instance.new("TextLabel"),
            CORNERS = {},
            CHAM = nil
        }
        E.FRM.BackgroundTransparency = 1
        E.FRM.Size = UDim2.new(1, 0, 1, 0)
        E.FRM.ZIndex = 0
        E.BOX.Parent = E.FRM
        E.BOX.BackgroundTransparency = 1
        E.BOX.BorderSizePixel = 0
        E.BOX_GRAD.Parent = E.BOX
        E.BOX_GRAD.Enabled = false
        E.OUT.Parent = E.BOX
        E.OUT.Color = Color3.new(1, 1, 1)
        E.OUT.Thickness = 1.5
        local function MK_C(parent)
            local f = Instance.new("Frame", parent)
            f.BorderSizePixel = 0
            local str = Instance.new("UIStroke", f)
            str.Color = Color3.new(0, 0, 0)
            str.Thickness = 1
            str.Transparency = 0.5
            return f
        end
        for i = 1, 8 do
            E.CORNERS[i] = MK_C(E.FRM)
        end
        local function _SAFE_FONT(lbl, sz)
            if typeof(ESP_CFG.Font) == "Font" then
                lbl.FontFace = ESP_CFG.Font
            else
                lbl.Font = (typeof(ESP_CFG.Font) == "EnumItem") and ESP_CFG.Font or Enum.Font.GothamBold
            end
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
        ESP_CACHE[p] = E
        return E
    end
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LPLR = Players.LocalPlayer
    local function UPD_ESP()
        for _, p in pairs(Players:GetPlayers()) do
            pcall(function()
                if p == LPLR then return end
                local E = ESP_CACHE[p] or MK_ESP(p)
                local C = workspace:FindFirstChild(p.Name) or p.Character
                if not C or not C:FindFirstChild("HumanoidRootPart") then
                    if E.CHAM then
                        E.CHAM:Destroy(); E.CHAM = nil
                    end
                    E.FRM.Visible = false
                    return
                end
                local H = C:FindFirstChild("HumanoidRootPart")
                local HUM = C:FindFirstChildOfClass("Humanoid")
                local healthVal = C:FindFirstChild("Health")
                local curHP, maxHP
                if healthVal and healthVal:IsA("NumberValue") then
                    curHP = healthVal.Value
                    maxHP = HUM and (HUM.MaxHealth > 0 and HUM.MaxHealth or 100) or 100
                elseif HUM then
                    curHP = HUM.Health
                    maxHP = HUM.MaxHealth > 0 and HUM.MaxHealth or 100
                else
                    curHP = 0; maxHP = 100
                end
                local isAlive = curHP > 0
                if C and isAlive then
                    if ESP_CFG.Chams.Enabled then
                        if not E.CHAM or E.CHAM.Parent ~= C then
                            if E.CHAM then pcall(function() E.CHAM:Destroy() end) end
                            E.CHAM = Instance.new("Highlight")
                            E.CHAM.Name = "CEN_CHAM"
                            E.CHAM.Adornee = C
                            E.CHAM.Parent = C
                            E.CHAM.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        E.CHAM.FillColor = ESP_CFG.Chams.Color1
                        E.CHAM.OutlineColor = ESP_CFG.Chams.Color2
                        E.CHAM.OutlineTransparency = 0
                        if ESP_CFG.Chams.Thermal then
                            E.CHAM.FillTransparency = 0.6 + math.sin(tick() * 5) * 0.3
                        else
                            E.CHAM.FillTransparency = 0.5
                        end
                    elseif E.CHAM then
                        E.CHAM:Destroy()
                        E.CHAM = nil
                    end
                else
                    if E.CHAM then
                        E.CHAM:Destroy(); E.CHAM = nil
                    end
                end
                if ESP_CFG.Enabled and H and isAlive then
                    local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(H.Position)
                    local dist = (workspace.CurrentCamera.CFrame.Position - H.Position).Magnitude
                    if vis and dist <= ESP_CFG.MaxDist then
                        E.FRM.Visible = true
                        local top_pos = workspace.CurrentCamera:WorldToViewportPoint(H.Position + Vector3.new(0, 2.5, 0))
                        local bot_pos = workspace.CurrentCamera:WorldToViewportPoint(H.Position - Vector3.new(0, 3.5, 0))
                        local s_y = math.abs(bot_pos.Y - top_pos.Y)
                        local s_x = s_y * 0.55
                        local x, y = pos.X - s_x / 2, top_pos.Y
                        local box_en = ESP_CFG.Boxes.Enabled
                        local corn_en = ESP_CFG.Corners.Enabled
                        local fill_en = ESP_CFG.Filled.Enabled
                        E.BOX.Visible = (box_en or fill_en)
                        E.BOX.Position = UDim2.new(0, x, 0, y)
                        E.BOX.Size = UDim2.new(0, s_x, 0, s_y)
                        E.OUT.Enabled = box_en and not corn_en
                        E.OUT.Color = ESP_CFG.Boxes.Color
                        E.BOX.BackgroundTransparency = fill_en and (1 - ESP_CFG.Filled.Alpha) or 1
                        E.BOX_GRAD.Enabled = fill_en
                        E.BOX_GRAD.Color = ColorSequence.new(ESP_CFG.Filled.Color1, ESP_CFG.Filled.Color2)
                        if ESP_CFG.Boxes.Animated and (fill_en or box_en) then
                            E.BOX_GRAD.Rotation = (tick() * 100) % 360
                        end
                        for i = 1, 8 do E.CORNERS[i].Visible = corn_en end
                        if corn_en then
                            local clr = ESP_CFG.Corners.Color
                            local thk = 1.5; local len = s_x / 4
                            E.CORNERS[1].Position = UDim2.new(0, x, 0, y); E.CORNERS[1].Size = UDim2.new(0, len, 0, thk)
                            E.CORNERS[2].Position = UDim2.new(0, x, 0, y); E.CORNERS[2].Size = UDim2.new(0, thk, 0, len)
                            E.CORNERS[3].Position = UDim2.new(0, x + s_x - len, 0, y); E.CORNERS[3].Size = UDim2.new(0,
                                len, 0, thk)
                            E.CORNERS[4].Position = UDim2.new(0, x + s_x - thk, 0, y); E.CORNERS[4].Size = UDim2.new(0,
                                thk, 0, len)
                            E.CORNERS[5].Position = UDim2.new(0, x, 0, y + s_y - thk); E.CORNERS[5].Size = UDim2.new(0,
                                len, 0, thk)
                            E.CORNERS[6].Position = UDim2.new(0, x, 0, y + s_y - len); E.CORNERS[6].Size = UDim2.new(0,
                                thk, 0, len)
                            E.CORNERS[7].Position = UDim2.new(0, x + s_x - len, 0, y + s_y - thk); E.CORNERS[7].Size =
                                UDim2.new(0, len, 0, thk)
                            E.CORNERS[8].Position = UDim2.new(0, x + s_x - thk, 0, y + s_y - len); E.CORNERS[8].Size =
                                UDim2.new(0, thk, 0, len)
                            for i = 1, 8 do E.CORNERS[i].BackgroundColor3 = clr end
                        end
                        local function SET_F(lbl, sz)
                            if typeof(ESP_CFG.Font) == "Font" then
                                lbl.FontFace = ESP_CFG.Font
                            else
                                lbl.Font = ESP_CFG
                                    .Font
                            end
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
                        if ESP_CFG.Health.Dynamic then
                            E.BAR_FL.BackgroundColor3 = Color3.fromHSV(hp_per * 0.35, 1, 1)
                            E.BAR_GRAD.Enabled = false
                        elseif ESP_CFG.Health.Bar then
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
                        E.FRM.Visible = false
                    end
                else
                    if E then E.FRM.Visible = false end
                end
            end)
        end
    end
    local espConn; espConn = RunService.RenderStepped:Connect(function()
        if not ScreenGui.Parent then
            espConn:Disconnect()
            return
        end
        UPD_ESP()
    end)
    Players.PlayerRemoving:Connect(function(p)
        if ESP_CACHE[p] then
            ESP_CACHE[p].FRM:Destroy()
            ESP_CACHE[p] = nil
        end
    end)
end
InitESPEngine()
local function InitCrosshairEngine()
    local CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "CEN_CROSSHAIR"
    CrosshairGui.IgnoreGuiInset = true
    CrosshairGui.DisplayOrder = 2147483646
    CrosshairGui.Parent = CoreGui
    local CrosshairObjects = {}
    local function ClearCrosshair()
        for _, obj in ipairs(CrosshairObjects) do
            obj:Destroy()
        end
        CrosshairObjects = {}
    end
    RENDER_CROSSHAIR = function()
        ClearCrosshair()
        if not CROSSHAIR_CFG.Enabled then return end
        local settings = CROSSHAIR_CFG
        local center = UDim2.new(0.5, 0, 0.5, 0)
        local function makeFrame(name, size, pos, color, radius)
            local f = Instance.new("Frame")
            f.Name = name
            f.Size = size
            f.Position = pos
            f.BackgroundColor3 = color
            f.BorderSizePixel = 0
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.ZIndex = 999999
            f.Parent = CrosshairGui
            if radius then
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, radius)
                c.Parent = f
            end
            table.insert(CrosshairObjects, f)
            return f
        end
        local style = settings.Style
        local s = settings.Size
        local color = settings.Color
        local thick = settings.Thickness or 2
        if style == "Dot" then
            makeFrame("Dot", UDim2.fromOffset(s, s), center, color, 999)
        elseif style == "Circle" then
            makeFrame("CircleOuter", UDim2.fromOffset(s + 2, s + 2), center, settings.OutlineColor or Color3.new(0, 0, 0),
                999)
            makeFrame("CircleInner", UDim2.fromOffset(s, s), center, color, 999)
        elseif style == "X" then
            local a = makeFrame("DiagA", UDim2.fromOffset(thick, s), center, color)
            a.Rotation = 45
            local b = makeFrame("DiagB", UDim2.fromOffset(thick, s), center, color)
            b.Rotation = -45
        elseif style == "Cross" then
            local gap = 4
            makeFrame("Top", UDim2.fromOffset(thick, s / 2), UDim2.new(0.5, 0, 0.5, -(s / 4 + gap)), color)
            makeFrame("Bottom", UDim2.fromOffset(thick, s / 2), UDim2.new(0.5, 0, 0.5, (s / 4 + gap)), color)
            makeFrame("Left", UDim2.fromOffset(s / 2, thick), UDim2.new(0.5, -(s / 4 + gap), 0.5, 0), color)
            makeFrame("Right", UDim2.fromOffset(s / 2, thick), UDim2.new(0.5, (s / 4 + gap), 0.5, 0), color)
        end
    end
end
InitCrosshairEngine()
local function InitVisualsUI()
    local MiscPage = Pages["Misc"]
    local MiscScroll = Instance.new("ScrollingFrame")
    MiscScroll.Size = UDim2.new(1, 0, 1, 0)
    MiscScroll.BackgroundTransparency = 1
    MiscScroll.BorderSizePixel = 0
    MiscScroll.ScrollBarThickness = 0
    MiscScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    MiscScroll.ZIndex = 1
    MiscScroll.Parent = MiscPage
    local ColorPickerModal = Instance.new("Frame")
    ColorPickerModal.Name = "ColorPickerModal"
    ColorPickerModal.Size = UDim2.new(0, 200, 0, 220)
    ColorPickerModal.Position = UDim2.new(0.5, -100, 0.5, -110)
    ColorPickerModal.BackgroundColor3 = Theme.CardBackground
    ColorPickerModal.BackgroundTransparency = 0.05
    ColorPickerModal.ZIndex = 100
    ColorPickerModal.Visible = false
    ColorPickerModal.Parent = MainFrame
    local PickerCorner = Instance.new("UICorner")
    PickerCorner.CornerRadius = UDim.new(0, 10)
    PickerCorner.Parent = ColorPickerModal
    local PickerStroke = Instance.new("UIStroke")
    PickerStroke.Color = Theme.Stroke
    PickerStroke.Thickness = 1.5
    PickerStroke.Parent = ColorPickerModal
    local PickerTitle = Instance.new("TextLabel")
    PickerTitle.Size = UDim2.new(1, 0, 0, 30)
    PickerTitle.BackgroundTransparency = 1
    PickerTitle.Text = "Select Color"
    PickerTitle.TextColor3 = Theme.Text
    PickerTitle.Font = Enum.Font.GothamBold
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
    ClosePickerBtn.BackgroundColor3 = Theme.Highlight
    ClosePickerBtn.Text = "Confirm"
    ClosePickerBtn.TextColor3 = Color3.new(1, 1, 1)
    ClosePickerBtn.Font = Enum.Font.GothamBold
    ClosePickerBtn.TextSize = 12
    ClosePickerBtn.ZIndex = 101
    ClosePickerBtn.Parent = ColorPickerModal
    local ClosePickerCorner = Instance.new("UICorner")
    ClosePickerCorner.CornerRadius = UDim.new(0, 6)
    ClosePickerCorner.Parent = ClosePickerBtn
    table.insert(DynamicHighlightElements, { obj = ClosePickerBtn, prop = "BackgroundColor3" })
    local ActiveColorCallback = nil
    local isPicking = false
    PaletteFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isPicking = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isPicking = false
        end
    end)
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not MainFrame.Visible then
            ColorPickerModal.Visible = false
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
    UserInputService.InputChanged:Connect(function(input)
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
    local function createAdaptiveFixedCard(parent, name, positionScale, height, yOffset, iconId)
        local Card = Instance.new("Frame")
        Card.Name = name .. "Card"
        Card.BackgroundColor3 = Theme.CardBackground
        Card.BackgroundTransparency = 0.15
        Card.Size = UDim2.new(0.5, -8, 0, height or 400)
        Card.Position = UDim2.new(positionScale, 4, 0, yOffset or 4)
        Card.ZIndex = 4
        Card.Parent = parent
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 10)
        CardCorner.Parent = Card
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Theme.Stroke
        CardStroke.Thickness = 1
        CardStroke.Parent = Card
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 22)
        Title.Position = UDim2.new(0, 0, 0, 10)
        Title.BackgroundTransparency = 1
        Title.Text = name
        Title.TextColor3 = Theme.Text
        Title.TextSize = 14
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Center
        Title.ZIndex = 5
        Title.Parent = Card
        addDualIcons(Title, iconId)
        local InnerArea = Instance.new("Frame")
        InnerArea.Size = UDim2.new(1, -10, 1, -40)
        InnerArea.Position = UDim2.new(0, 5, 0, 35)
        InnerArea.BackgroundTransparency = 1
        InnerArea.BorderSizePixel = 0
        InnerArea.ZIndex = 5
        InnerArea.Parent = Card
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = InnerArea
        return Card, InnerArea
    end
    local function ADD_UI_TOGGLE(parent, text, defaultVal, callback, colorObj, layoutOrder)
        local FRM = Instance.new("Frame")
        FRM.Size = UDim2.new(1, -10, 0, 24)
        FRM.BackgroundTransparency = 1
        FRM.LayoutOrder = layoutOrder
        FRM.ZIndex = 5
        FRM.Parent = parent
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, colorObj and -100 or -65, 1, 0)
        Lbl.Position = UDim2.new(0, 5, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Theme.MutedText
        Lbl.TextSize = 12
        Lbl.TextTruncate = Enum.TextTruncate.AtEnd
        Lbl.Font = Enum.Font.GothamMedium
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 5
        Lbl.Parent = FRM
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 42, 0, 20)
        Btn.Position = UDim2.new(1, -50, 0, 2)
        Btn.BackgroundColor3 = defaultVal and Theme.Highlight or Color3.fromRGB(45, 43, 50)
        Btn.Text = ""
        Btn.ZIndex = 5
        Btn.Parent = FRM
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(1, 0)
        BtnCorner.Parent = Btn
        local Circ = Instance.new("Frame")
        Circ.Size = UDim2.new(0, 14, 0, 14)
        Circ.Position = defaultVal and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Circ.BackgroundColor3 = Color3.new(1, 1, 1)
        Circ.ZIndex = 6
        Circ.Parent = Btn
        local CircCorner = Instance.new("UICorner")
        CircCorner.CornerRadius = UDim.new(1, 0)
        CircCorner.Parent = Circ
        local state = defaultVal
        Btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                state = not state
                local tPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                local tCol = state and Theme.Highlight or Color3.fromRGB(45, 43, 50)
                TweenService:Create(Circ, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    { Position = tPos }):Play()
                TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    { BackgroundColor3 = tCol }):Play()
                callback(state)
            end
        end)
        if colorObj then
            local ColBtn = Instance.new("TextButton")
            ColBtn.Size = UDim2.new(0, 18, 0, 18)
            ColBtn.Position = UDim2.new(1, -75, 0.5, -9)
            ColBtn.BackgroundColor3 = colorObj.get()
            ColBtn.Text = ""
            ColBtn.ZIndex = 6
            ColBtn.Parent = FRM
            local cC = Instance.new("UICorner")
            cC.CornerRadius = UDim.new(1, 0)
            cC.Parent = ColBtn
            local cS = Instance.new("UIStroke")
            cS.Color = Theme.Stroke
            cS.Thickness = 1
            cS.Parent = ColBtn
            ColBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    OpenPicker(function(nc)
                        ColBtn.BackgroundColor3 = nc
                        colorObj.set(nc)
                    end)
                end
            end)
        end
    end
    local function ADD_SLIDER(parent, text, min, max, defaultVal, callback, layoutOrder)
        local FRM = Instance.new("Frame")
        FRM.Size = UDim2.new(1, -10, 0, 40)
        FRM.BackgroundTransparency = 1
        FRM.LayoutOrder = layoutOrder
        FRM.ZIndex = 5
        FRM.Parent = parent
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -70, 0, 14)
        Lbl.Position = UDim2.new(0, 5, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Theme.MutedText
        Lbl.TextSize = 12
        Lbl.Font = Enum.Font.GothamMedium
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 5
        Lbl.Parent = FRM
        local ValLbl = Instance.new("TextLabel")
        ValLbl.Size = UDim2.new(0, 50, 0, 14)
        ValLbl.Position = UDim2.new(1, -55, 0, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = tostring(defaultVal)
        ValLbl.TextColor3 = Theme.Highlight
        ValLbl.TextSize = 12
        ValLbl.Font = Enum.Font.GothamBold
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        ValLbl.ZIndex = 5
        ValLbl.Parent = FRM
        table.insert(DynamicHighlightElements, { obj = ValLbl, prop = "TextColor3" })
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -10, 0, 4)
        Track.Position = UDim2.new(0, 5, 0, 24)
        Track.BackgroundColor3 = Color3.fromRGB(45, 43, 50)
        Track.BorderSizePixel = 0
        Track.ZIndex = 5
        Track.Parent = FRM
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Highlight
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 6
        Fill.Parent = Track
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        table.insert(DynamicHighlightElements, { obj = Fill, prop = "BackgroundColor3" })
        local Thumb = Instance.new("Frame")
        Thumb.Size = UDim2.new(0, 12, 0, 12)
        Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        Thumb.Position = UDim2.new(1, 0, 0.5, 0)
        Thumb.BackgroundColor3 = Color3.new(1, 1, 1)
        Thumb.ZIndex = 7
        Thumb.Parent = Fill
        Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
        local isDragging = false
        local function UpdateSlider(input)
            local pos = input.Position.X
            if input.UserInputType == Enum.UserInputType.Touch then pos = input.Position.X end
            local pct = math.clamp((pos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            TweenService:Create(Fill, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = UDim2.new(pct, 0, 1, 0)
            }):Play()
            local val = math.floor(min + (max - min) * pct)
            ValLbl.Text = tostring(val)
            callback(val)
        end
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                UpdateSlider(input)
            end
        end)
        Thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)
    end
    local function ADD_DROPDOWN(parent, text, options, defaultVal, callback, layoutOrder)
        local FRM = Instance.new("Frame")
        FRM.Size = UDim2.new(1, -10, 0, 55)
        FRM.BackgroundTransparency = 1
        FRM.LayoutOrder = layoutOrder
        FRM.ZIndex = 15
        FRM.Parent = parent
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -10, 0, 16)
        Lbl.Position = UDim2.new(0, 5, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Theme.MutedText
        Lbl.TextSize = 12
        Lbl.Font = Enum.Font.GothamMedium
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 15
        Lbl.Parent = FRM
        local DropBtn = Instance.new("TextButton")
        DropBtn.Size = UDim2.new(1, -10, 0, 30)
        DropBtn.Position = UDim2.new(0, 5, 0, 20)
        DropBtn.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
        DropBtn.Text = ""
        DropBtn.ZIndex = 15
        DropBtn.Parent = FRM
        Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", DropBtn).Color = Theme.Stroke
        local DropLabel = Instance.new("TextLabel")
        DropLabel.Size = UDim2.new(1, -30, 1, 0)
        DropLabel.Position = UDim2.new(0, 8, 0, 0)
        DropLabel.BackgroundTransparency = 1
        DropLabel.Text = defaultVal
        DropLabel.TextColor3 = Theme.Text
        DropLabel.TextSize = 11
        DropLabel.Font = Enum.Font.GothamMedium
        DropLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropLabel.TextTruncate = Enum.TextTruncate.AtEnd
        DropLabel.ZIndex = 16
        DropLabel.Parent = DropBtn
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(1, -24, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "v"
        Arrow.TextColor3 = Theme.MutedText
        Arrow.TextSize = 13
        Arrow.Font = Enum.Font.GothamBold
        Arrow.ZIndex = 16
        Arrow.Parent = DropBtn
        local DropList = Instance.new("ScrollingFrame")
        DropList.Size = UDim2.new(1, -10, 0, 0)
        DropList.Position = UDim2.new(0, 5, 0, 54)
        DropList.BackgroundColor3 = Color3.fromRGB(13, 12, 15)
        DropList.BorderSizePixel = 0
        DropList.ClipsDescendants = true
        DropList.ZIndex = 50
        DropList.Visible = false
        DropList.ScrollBarThickness = 3
        DropList.ScrollBarImageColor3 = Theme.Highlight
        DropList.TopImage = ""; DropList.MidImage = ""; DropList.BottomImage = ""
        DropList.CanvasSize = UDim2.new(0, 0, 0, 0)
        DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
        DropList.Parent = FRM
        table.insert(DynamicHighlightElements, { obj = DropList, prop = "ScrollBarImageColor3" })
        local DLCorner = Instance.new("UICorner")
        DLCorner.CornerRadius = UDim.new(0, 6)
        DLCorner.Parent = DropList
        local DLStroke = Instance.new("UIStroke")
        local targetStrokeColor = SavedData.BorderOn and Theme.Highlight or Color3.fromRGB(60, 60, 65)
        DLStroke.Color = targetStrokeColor
        DLStroke.Thickness = 1
        DLStroke.Parent = DropList
        table.insert(DynamicHighlightElements, { obj = DLStroke, prop = "Color", isBorder = true })
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = DropList
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local dropdownOpen = false
        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 34)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = opt
            OptBtn.TextColor3 = Theme.MutedText
            OptBtn.TextSize = 11
            OptBtn.Font = Enum.Font.GothamMedium
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
            OptBtn.ZIndex = 51
            OptBtn.AutoButtonColor = false
            OptBtn.Parent = DropList
            local Pad = Instance.new("UIPadding")
            Pad.PaddingLeft = UDim.new(0, 10)
            Pad.Parent = OptBtn
            local touchStart = nil
            OptBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    touchStart = input.Position
                    OptBtn.BackgroundColor3 = Theme.Highlight
                    OptBtn.BackgroundTransparency = 0.8
                end
            end)
            OptBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    OptBtn.BackgroundTransparency = 1
                    if touchStart and (input.Position - touchStart).Magnitude < 10 then
                        DropLabel.Text = opt
                        callback(opt)
                        dropdownOpen = false
                        DropList.Visible = false
                        DropList.Size = UDim2.new(1, -10, 0, 0)
                    end
                    touchStart = nil
                end
            end)
            OptBtn.MouseEnter:Connect(function()
                OptBtn.BackgroundColor3 = Theme.Highlight
                TweenService:Create(OptBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.85 }):Play()
            end)
            OptBtn.MouseLeave:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
            end)
        end
        DropBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dropdownOpen = not dropdownOpen
                if dropdownOpen then
                    DropList.Visible = true
                    local listHeight = math.min(#options * 34, 136)
                    DropList.Size = UDim2.new(1, -10, 0, listHeight)
                else
                    DropList.Visible = false
                    DropList.Size = UDim2.new(1, -10, 0, 0)
                end
            end
        end)
    end
    local PlayerVisualsCard, PVC_Scroll = createAdaptiveFixedCard(MiscScroll, "Player Visuals", 0, 380, nil,
        "80273926746623")
    ADD_UI_TOGGLE(PVC_Scroll, "Enable ESP", ESP_CFG.Enabled, function(v) ESP_CFG.Enabled = v end, nil, 1)
    ADD_UI_TOGGLE(PVC_Scroll, "Bounding Boxes", ESP_CFG.Boxes.Enabled, function(v) ESP_CFG.Boxes.Enabled = v end,
        { get = function() return ESP_CFG.Boxes.Color end, set = function(c) ESP_CFG.Boxes.Color = c end }, 2)
    ADD_UI_TOGGLE(PVC_Scroll, "Corner Boxes", ESP_CFG.Corners.Enabled, function(v) ESP_CFG.Corners.Enabled = v end,
        { get = function() return ESP_CFG.Corners.Color end, set = function(c) ESP_CFG.Corners.Color = c end }, 3)
    ADD_UI_TOGGLE(PVC_Scroll, "Filled Boxes", ESP_CFG.Filled.Enabled, function(v) ESP_CFG.Filled.Enabled = v end,
        { get = function() return ESP_CFG.Filled.Color1 end, set = function(c) ESP_CFG.Filled.Color1 = c end }, 4)
    ADD_UI_TOGGLE(PVC_Scroll, "Names", ESP_CFG.Names.Enabled, function(v) ESP_CFG.Names.Enabled = v end,
        { get = function() return ESP_CFG.Names.Color end, set = function(c) ESP_CFG.Names.Color = c end }, 5)
    ADD_UI_TOGGLE(PVC_Scroll, "Health Bar", ESP_CFG.Health.Bar, function(v) ESP_CFG.Health.Bar = v end, nil, 6)
    ADD_UI_TOGGLE(PVC_Scroll, "Dynamic Health", ESP_CFG.Health.Dynamic, function(v) ESP_CFG.Health.Dynamic = v end, nil,
        7)
    ADD_UI_TOGGLE(PVC_Scroll, "Distance", ESP_CFG.Dist.Enabled, function(v) ESP_CFG.Dist.Enabled = v end,
        { get = function() return ESP_CFG.Dist.Color end, set = function(c) ESP_CFG.Dist.Color = c end }, 8)
    ADD_UI_TOGGLE(PVC_Scroll, "Weapons", ESP_CFG.Weapons.Enabled, function(v) ESP_CFG.Weapons.Enabled = v end,
        { get = function() return ESP_CFG.Weapons.Color end, set = function(c) ESP_CFG.Weapons.Color = c end }, 9)
    ADD_UI_TOGGLE(PVC_Scroll, "Chams", ESP_CFG.Chams.Enabled, function(v) ESP_CFG.Chams.Enabled = v end,
        { get = function() return ESP_CFG.Chams.Color1 end, set = function(c) ESP_CFG.Chams.Color1 = c end }, 10)
    local CrosshairCard, CC_Scroll = createAdaptiveFixedCard(MiscScroll, "Crosshair", 0.5, 220, nil, "75168271421358")
    ADD_UI_TOGGLE(CC_Scroll, "Enable Crosshair", CROSSHAIR_CFG.Enabled,
        function(v)
            CROSSHAIR_CFG.Enabled = v; RENDER_CROSSHAIR()
        end,
        {
            get = function() return CROSSHAIR_CFG.Color end,
            set = function(c)
                CROSSHAIR_CFG.Color = c; RENDER_CROSSHAIR()
            end
        }, 1)
    ADD_DROPDOWN(CC_Scroll, "Crosshair Style", { "Dot", "Circle", "X", "Cross", "Skull" }, CROSSHAIR_CFG.Style,
        function(v)
            CROSSHAIR_CFG.Style = v
            RENDER_CROSSHAIR()
        end, 2)
    ADD_SLIDER(CC_Scroll, "Crosshair Size", 4, 60, CROSSHAIR_CFG.Size, function(v)
        CROSSHAIR_CFG.Size = v
        RENDER_CROSSHAIR()
    end, 3)
    local PVS_Card, PVS_Scroll = createAdaptiveFixedCard(MiscScroll, "Player Visual Settings", 0.5, 340, 232,
        "138144736940989")
    ADD_UI_TOGGLE(PVS_Scroll, "Animated Boxes", ESP_CFG.Boxes.Animated, function(v) ESP_CFG.Boxes.Animated = v end, nil,
        1)
    ADD_UI_TOGGLE(PVS_Scroll, "Fullbright", false, function(v)
        if game:GetService("Lighting") then
            game:GetService("Lighting").Brightness = v and 2 or 1
            game:GetService("Lighting").OutdoorAmbient = v and Color3.new(1, 1, 1) or Color3.fromRGB(127, 127, 127)
        end
    end, nil, 2)
    ADD_UI_TOGGLE(PVS_Scroll, "Dynamic Health Text", ESP_CFG.Health.Dynamic, function(v) ESP_CFG.Health.Dynamic = v end,
        nil, 3)
    ADD_UI_TOGGLE(PVS_Scroll, "Thermal Chams", ESP_CFG.Chams.Thermal, function(v) ESP_CFG.Chams.Thermal = v end, nil, 4)
    ADD_DROPDOWN(PVS_Scroll, "Text Font", { "GothamBold", "Gotham", "Code", "Roboto", "Arcade", "SciFi" }, "GothamBold",
        function(v)
            local fontEnum = Enum.Font[v]
            if fontEnum then
                ESP_CFG.Font = fontEnum
            end
        end, 5)
    ADD_SLIDER(PVS_Scroll, "Text Size", 8, 24, ESP_CFG.FontSize, function(v) ESP_CFG.FontSize = v end, 6)
    ADD_SLIDER(PVS_Scroll, "Max Render Distance", 100, 5000, ESP_CFG.MaxDist, function(v) ESP_CFG.MaxDist = v end, 7)
end
InitVisualsUI()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and SavedData.HideUIKeybind and input.KeyCode.Name == SavedData.HideUIKeybind then
        MainFrame.Visible = not MainFrame.Visible
        if ColorPickerModal then
            ColorPickerModal.Visible = false
        end
    end
end)
