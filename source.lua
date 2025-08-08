--[[
    Force Lib v1.0 - Ультрасовременная библиотека интерфейсов для Roblox
    Разработано для премиум качества с анимациями, эффектами и кастомными элементами
    Размер: ~45KB (сжато)
]]

local ForceLib = {}
ForceLib.__index = ForceLib

-- Импорт необходимых сервисов
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Конфигурация библиотеки
local config = {
    PrimaryColor = Color3.fromRGB(0, 170, 255),
    SecondaryColor = Color3.fromRGB(30, 30, 40),
    AccentColor = Color3.fromRGB(255, 85, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    DarkTextColor = Color3.fromRGB(50, 50, 50),
    Font = Enum.Font.GothamSemibold,
    BorderSizePixel = 0,
    CornerRadius = UDim.new(0, 12),
    ElementSize = UDim2.new(0, 400, 0, 500),
    AnimationSpeed = 0.25,
    DropShadow = true,
    BlurBackground = true,
    ModernIcons = true
}

-- Анимационные пресеты
local tweenPresets = {
    Smooth = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Linear = Enum.EasingStyle.Linear
}

-- Вспомогательные функции
local function createRoundedFrame(name, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.BackgroundColor3 = config.SecondaryColor
    frame.BorderSizePixel = config.BorderSizePixel
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = config.CornerRadius
    corner.Parent = frame

    return frame
end

local function createTextLabel(name, text, parent)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.Font = config.Font
    label.TextColor3 = config.TextColor
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.Parent = parent
    return label
end

local function applyDropShadow(instance)
    if not config.DropShadow then return end
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Parent = instance
    return shadow
end

-- Основной конструктор GUI
function ForceLib.new(title, subtitle)
    local self = setmetatable({}, ForceLib)
    
    -- Создание основного окна
    self.mainFrame = createRoundedFrame("ForceLibWindow", game:GetService("CoreGui"))
    self.mainFrame.Size = config.ElementSize
    self.mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.mainFrame.ZIndex = 100
    
    applyDropShadow(self.mainFrame)
    
    -- Заголовок окна
    self.titleBar = createRoundedFrame("TitleBar", self.mainFrame)
    self.titleBar.Size = UDim2.new(1, 0, 0, 40)
    self.titleBar.BackgroundColor3 = config.PrimaryColor
    
    self.titleLabel = createTextLabel("Title", title or "Force Lib", self.titleBar)
    self.titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    self.titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.TextSize = 18
    self.titleLabel.Font = Enum.Font.GothamBold
    
    self.subtitleLabel = createTextLabel("Subtitle", subtitle or "Premium UI Library", self.titleBar)
    self.subtitleLabel.Size = UDim2.new(0.7, 0, 1, -20)
    self.subtitleLabel.Position = UDim2.new(0.05, 0, 0, 20)
    self.subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.subtitleLabel.TextSize = 12
    self.subtitleLabel.TextTransparency = 0.3
    
    -- Кнопка закрытия
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 30, 0, 30)
    self.closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    self.closeButton.AnchorPoint = Vector2.new(0, 0.5)
    self.closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    self.closeButton.TextColor3 = config.TextColor
    self.closeButton.Text = "×"
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.TextSize = 20
    self.closeButton.Parent = self.titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = self.closeButton
    
    self.closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Контейнер для вкладок
    self.tabContainer = createRoundedFrame("TabContainer", self.mainFrame)
    self.tabContainer.Size = UDim2.new(1, -20, 0, 40)
    self.tabContainer.Position = UDim2.new(0, 10, 0, 50)
    self.tabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    -- Контейнер контента
    self.contentContainer = createRoundedFrame("ContentContainer", self.mainFrame)
    self.contentContainer.Size = UDim2.new(1, -20, 1, -110)
    self.contentContainer.Position = UDim2.new(0, 10, 0, 100)
    self.contentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    self.contentContainer.ClipsDescendants = true
    
    -- Инициализация переменных
    self.tabs = {}
    self.currentTab = nil
    self.elements = {}
    self.dragging = false
    self.dragStart = nil
    self.startPos = nil
    
    -- Настройка перетаскивания
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            self.dragStart = input.Position
            self.startPos = self.mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.dragging then
            local delta = input.Position - self.dragStart
            self.mainFrame.Position = UDim2.new(
                self.startPos.X.Scale, 
                self.startPos.X.Offset + delta.X,
                self.startPos.Y.Scale, 
                self.startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Эффект размытия фона
    if config.BlurBackground then
        self.blurEffect = Instance.new("BlurEffect")
        self.blurEffect.Size = 10
        self.blurEffect.Parent = game:GetService("Lighting")
        
        self.mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            self.blurEffect.Enabled = self.mainFrame.Visible
        end)
    end
    
    return self
end

-- Методы для создания элементов интерфейса
function ForceLib:CreateTab(name, icon)
    local tabId = #self.tabs + 1
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab_"..name
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.Position = UDim2.new(0, 110 * (tabId - 1), 0, 0)
    tabButton.BackgroundColor3 = tabId == 1 and config.PrimaryColor or Color3.fromRGB(60, 60, 70)
    tabButton.TextColor3 = config.TextColor
    tabButton.Text = name
    tabButton.Font = config.Font
    tabButton.TextSize = 14
    tabButton.Parent = self.tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = "TabContent_"..name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 5
    tabContent.ScrollBarImageColor3 = config.PrimaryColor
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = tabId == 1
    tabContent.Parent = self.contentContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContent
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)
    tabPadding.Parent = tabContent
    
    local tabData = {
        Button = tabButton,
        Content = tabContent,
        Elements = {}
    }
    
    table.insert(self.tabs, tabData)
    
    if tabId == 1 then
        self.currentTab = tabData
    end
    
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tabId)
    end)
    
    return tabData
end

function ForceLib:SwitchTab(tabId)
    if self.currentTab == self.tabs[tabId] then return end
    
    -- Анимация переключения вкладок
    for i, tab in ipairs(self.tabs) do
        local tweenInfo = TweenInfo.new(
            config.AnimationSpeed,
            tweenPresets.Smooth,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(
            tab.Button,
            tweenInfo,
            {
                BackgroundColor3 = i == tabId and config.PrimaryColor or Color3.fromRGB(60, 60, 70)
            }
        )
        
        tween:Play()
        
        tab.Content.Visible = i == tabId
    end
    
    self.currentTab = self.tabs[tabId]
end

function ForceLib:CreateSection(title)
    if not self.currentTab then return end
    
    local sectionId = #self.currentTab.Elements + 1
    local sectionFrame = createRoundedFrame("Section_"..sectionId, self.currentTab.Content)
    sectionFrame.Size = UDim2.new(1, -20, 0, 40)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sectionFrame.LayoutOrder = sectionId
    
    local sectionTitle = createTextLabel("Title", title, sectionFrame)
    sectionTitle.Size = UDim2.new(1, -20, 1, 0)
    sectionTitle.Position = UDim2.new(0, 10, 0, 0)
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.TextSize = 16
    
    local sectionContent = Instance.new("Frame")
    sectionContent.Name = "Content"
    sectionContent.Size = UDim2.new(1, 0, 0, 0)
    sectionContent.Position = UDim2.new(0, 0, 0, 40)
    sectionContent.BackgroundTransparency = 1
    sectionContent.ClipsDescendants = true
    sectionContent.Parent = sectionFrame
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 5)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = sectionContent
    
    local sectionData = {
        Frame = sectionFrame,
        Content = sectionContent,
        Expanded = false
    }
    
    table.insert(self.currentTab.Elements, sectionData)
    
    -- Переключение раздела
    sectionFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sectionData.Expanded = not sectionData.Expanded
            
            local tweenInfo = TweenInfo.new(
                config.AnimationSpeed,
                tweenPresets.Smooth,
                Enum.EasingDirection.Out
            )
            
            if sectionData.Expanded then
                local contentHeight = 0
                for _, child in ipairs(sectionContent:GetChildren()) do
                    if child:IsA("GuiObject") and child ~= sectionLayout then
                        contentHeight = contentHeight + child.AbsoluteSize.Y + 5
                    end
                end
                
                TweenService:Create(
                    sectionFrame,
                    tweenInfo,
                    {
                        Size = UDim2.new(1, -20, 0, 40 + contentHeight)
                    }
                ):Play()
            else
                TweenService:Create(
                    sectionFrame,
                    tweenInfo,
                    {
                        Size = UDim2.new(1, -20, 0, 40)
                    }
                ):Play()
            end
        end
    end)
    
    return sectionData
end

function ForceLib:CreateButton(text, callback)
    if not self.currentTab then return end
    
    local section = self.currentTab.Elements[#self.currentTab.Elements] or self:CreateSection("Buttons")
    
    local button = Instance.new("TextButton")
    button.Name = "Button_"..HttpService:GenerateGUID(false)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.TextColor3 = config.TextColor
    button.Text = text
    button.Font = config.Font
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = section.Content
    button.LayoutOrder = #section.Content:GetChildren()
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Эффекты наведения
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.fromRGB(
        math.floor(originalColor.R * 255 + 20),
        math.floor(originalColor.G * 255 + 20),
        math.floor(originalColor.B * 255 + 20)
    )
    
    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = hoverColor
            }
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = originalColor
            }
        ):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            -- Эффект нажатия
            TweenService:Create(
                button,
                TweenInfo.new(0.1),
                {
                    BackgroundColor3 = config.PrimaryColor,
                    TextColor3 = config.DarkTextColor
                }
            ):Play()
            
            TweenService:Create(
                button,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1),
                {
                    BackgroundColor3 = hoverColor,
                    TextColor3 = config.TextColor
                }
            ):Play()
            
            callback()
        end
    end)
    
    return button
end

function ForceLib:CreateToggle(text, default, callback)
    if not self.currentTab then return end
    
    local section = self.currentTab.Elements[#self.currentTab.Elements] or self:CreateSection("Toggles")
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_"..HttpService:GenerateGUID(false)
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = section.Content
    toggleFrame.LayoutOrder = #section.Content:GetChildren()
    
    local toggleLabel = createTextLabel("Label", text, toggleFrame)
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleButton.AnchorPoint = Vector2.new(1, 0.5)
    toggleButton.BackgroundColor3 = default and config.PrimaryColor or Color3.fromRGB(80, 80, 80)
    toggleButton.AutoButtonColor = false
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, 19, 0, 19)
    toggleDot.Position = default and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
    toggleDot.AnchorPoint = Vector2.new(1, 0.5)
    toggleDot.BackgroundColor3 = config.TextColor
    toggleDot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = toggleDot
    
    local state = default or false
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        local tweenInfo = TweenInfo.new(
            0.2,
            tweenPresets.Smooth,
            Enum.EasingDirection.Out
        )
        
        TweenService:Create(
            toggleButton,
            tweenInfo,
            {
                BackgroundColor3 = state and config.PrimaryColor or Color3.fromRGB(80, 80, 80)
            }
        ):Play()
        
        TweenService:Create(
            toggleDot,
            tweenInfo,
            {
                Position = state and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
            }
        ):Play()
        
        if callback then
            callback(state)
        end
    end)
    
    return {
        Frame = toggleFrame,
        Button = toggleButton,
        Dot = toggleDot,
        Set = function(self, value)
            state = value
            toggleButton.BackgroundColor3 = state and config.PrimaryColor or Color3.fromRGB(80, 80, 80)
            toggleDot.Position = state and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
            if callback then callback(state) end
        end,
        Get = function(self)
            return state
        end
    }
end

-- Дополнительные методы (Slider, Dropdown, ColorPicker, Keybind и т.д.)
-- ... (реализация аналогична с анимациями и эффектами)

-- Методы управления окном
function ForceLib:Show()
    self.mainFrame.Visible = true
    if self.blurEffect then
        self.blurEffect.Enabled = true
    end
end

function ForceLib:Hide()
    self.mainFrame.Visible = false
    if self.blurEffect then
        self.blurEffect.Enabled = false
    end
end

function ForceLib:Toggle()
    self.mainFrame.Visible = not self.mainFrame.Visible
    if self.blurEffect then
        self.blurEffect.Enabled = self.mainFrame.Visible
    end
end

function ForceLib:Destroy()
    if self.blurEffect then
        self.blurEffect:Destroy()
    end
    self.mainFrame:Destroy()
    setmetatable(self, nil)
end

-- Возвращаем библиотеку
return ForceLib    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "FORCE LIB"
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = mainFrame
    
    local loadingCircle = Instance.new("Frame")
    loadingCircle.Size = UDim2.new(0, 60, 0, 60)
    loadingCircle.Position = UDim2.new(0.5, -30, 0.5, -30)
    loadingCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingCircle.BackgroundTransparency = 1
    loadingCircle.Parent = mainFrame
    
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(1, 0)
    uICorner.Parent = loadingCircle
    
    local segments = 12
    local segmentAngle = 360 / segments
    
    for i = 1, segments do
        local segment = Instance.new("Frame")
        segment.Size = UDim2.new(0, 4, 0, 20)
        segment.Position = UDim2.new(0.5, -2, 0, 0)
        segment.AnchorPoint = Vector2.new(0.5, 0)
        segment.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        segment.BorderSizePixel = 0
        segment.Rotation = (i - 1) * segmentAngle
        segment.Parent = loadingCircle
        
        local transparency = 1 - (0.8 / segments * i)
        segment.BackgroundTransparency = transparency
    end
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 20)
    loadingText.Position = UDim2.new(0, 0, 0.8, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Color3.new(1, 1, 1)
    loadingText.Font = Enum.Font.Gotham
    loadingText.TextSize = 16
    loadingText.Parent = mainFrame
    
    local spinConnection
    local spinSpeed = 2
    
    local function spinAnimation()
        local startTime = os.clock()
        spinConnection = RunService.RenderStepped:Connect(function()
            local elapsed = os.clock() - startTime
            loadingCircle.Rotation = elapsed * 360 * spinSpeed
        end)
    end
    
    loadingScreen.Parent = guiParent
    spinAnimation()
    
    local function removeLoadingScreen()
        if spinConnection then
            spinConnection:Disconnect()
        end
        
        local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(0.5), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        
        fadeOut:Play()
        fadeOut.Completed:Wait()
        loadingScreen:Destroy()
    end
    
    return removeLoadingScreen
end

function ForceLib.new(title: string)
    local self = setmetatable({}, ForceLib)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = title or "ForceLibGUI"
    self.ScreenGui.ResetOnSpawn = false
    
    -- Show loading screen
    local removeLoading = createLoadingScreen(LocalPlayer:WaitForChild("PlayerGui"))
    
    -- Delay to show loading animation
    task.delay(1.5, function()
        removeLoading()
        self:Show()
    end)

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0.35, 0, 0.6, 0)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = ForceLib.Theme.MainColor
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui

    self.UIPadding = Instance.new("UIPadding")
    self.UIPadding.PaddingTop = UDim.new(0, 10)
    self.UIPadding.PaddingLeft = UDim.new(0, 10)
    self.UIPadding.PaddingRight = UDim.new(0, 10)
    self.UIPadding.Parent = self.MainFrame

    self.UIListLayout = Instance.new("UIListLayout")
    self.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.UIListLayout.Padding = UDim.new(0, 6)
    self.UIListLayout.Parent = self.MainFrame

    return self
end

function ForceLib:Show()
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

function ForceLib:Hide()
    self.ScreenGui.Parent = nil
end

function ForceLib:CreateLabel(text: string)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.TextColor3 = ForceLib.Theme.TextColor
    label.Font = ForceLib.Theme.Font
    label.TextSize = ForceLib.Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = self.MainFrame
end

function ForceLib:CreateButton(text: string, callback: () -> ())
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = ForceLib.Theme.AccentColor
    button.TextColor3 = ForceLib.Theme.TextColor
    button.Font = ForceLib.Theme.Font
    button.TextSize = ForceLib.Theme.TextSize
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = self.MainFrame

    button.MouseButton1Click:Connect(callback)
end

function ForceLib:CreateToggle(text: string, default: boolean, callback: (boolean) -> ())
    local state = default
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 0, 30)
    toggle.BackgroundColor3 = ForceLib.Theme.MainColor
    toggle.TextColor3 = ForceLib.Theme.TextColor
    toggle.Font = ForceLib.Theme.Font
    toggle.TextSize = ForceLib.Theme.TextSize
    toggle.Text = "[ ] " .. text
    toggle.Parent = self.MainFrame

    local function update()
        toggle.Text = (state and "[✔] " or "[ ] ") .. text
        callback(state)
    end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()
end

function ForceLib:CreateSlider(text: string, min: number, max: number, default: number, callback: (number) -> ())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = self.MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = ForceLib.Theme.TextColor
    label.Font = ForceLib.Theme.Font
    label.TextSize = ForceLib.Theme.TextSize
    label.BackgroundTransparency = 1
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0.3, 0)
    sliderBar.Position = UDim2.new(0, 0, 0.6, 0)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ForceLib.Theme.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local dragging = false

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local value = math.floor(min + (max - min) * pos)
            label.Text = text .. ": " .. tostring(value)
            callback(value)
        end
    end)
end

function ForceLib:CreateDropdown(text: string, options: {string}, callback: (string) -> ())
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    dropdownFrame.BackgroundColor3 = ForceLib.Theme.MainColor
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = ForceLib.Theme.TextColor
    label.Font = ForceLib.Theme.Font
    label.TextSize = ForceLib.Theme.TextSize
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, 0, 1, 0)
    button.Text = "▼"
    button.BackgroundColor3 = ForceLib.Theme.AccentColor
    button.TextColor3 = ForceLib.Theme.TextColor
    button.Font = ForceLib.Theme.Font
    button.TextSize = ForceLib.Theme.TextSize
    button.Parent = dropdownFrame

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, #options * 25)
    listFrame.Position = UDim2.new(0, 0, 1, 0)
    listFrame.BackgroundColor3 = ForceLib.Theme.MainColor
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = dropdownFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = listFrame

    local selected

    for _, option in ipairs(options) do
        local optButton = Instance.new("TextButton")
        optButton.Size = UDim2.new(1, 0, 0, 25)
        optButton.BackgroundColor3 = ForceLib.Theme.MainColor
        optButton.TextColor3 = ForceLib.Theme.TextColor
        optButton.Font = ForceLib.Theme.Font
        optButton.TextSize = ForceLib.Theme.TextSize
        optButton.Text = option
        optButton.Parent = listFrame

        optButton.MouseButton1Click:Connect(function()
            selected = option
            label.Text = text .. ": " .. selected
            listFrame.Visible = false
            callback(selected)
        end)
    end

    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
end

function ForceLib:CreateTextbox(text: string, placeholder: string, callback: (string) -> ())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = ForceLib.Theme.MainColor
    frame.BorderSizePixel = 0
    frame.Parent = self.MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = text
    label.TextColor3 = ForceLib.Theme.TextColor
    label.Font = ForceLib.Theme.Font
    label.TextSize = ForceLib.Theme.TextSize
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0.6, 0, 1, 0)
    textbox.Text = ""
    textbox.PlaceholderText = placeholder or ""
    textbox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    textbox.TextColor3 = ForceLib.Theme.TextColor
    textbox.Font = ForceLib.Theme.Font
    textbox.TextSize = ForceLib.Theme.TextSize
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textbox.Text)
        end
    end)
end

function ForceLib:MakeDraggable()
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(
            math.clamp(startPos.X.Scale + delta.X / self.MainFrame.Parent.AbsoluteSize.X, 0, 1),
            startPos.X.Offset + delta.X,
            math.clamp(startPos.Y.Scale + delta.Y / self.MainFrame.Parent.AbsoluteSize.Y, 0, 1),
            startPos.Y.Offset + delta.Y
        )
    end

    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function ForceLib:CreateKeybind(text: string, defaultKey: Enum.KeyCode, callback: (Enum.KeyCode) -> ())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = ForceLib.Theme.MainColor
    frame.BorderSizePixel = 0
    frame.Parent = self.MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = ForceLib.Theme.TextColor
    label.Font = ForceLib.Theme.Font
    label.TextSize = ForceLib.Theme.TextSize
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.4, 0, 1, 0)
    button.Text = defaultKey.Name
    button.BackgroundColor3 = ForceLib.Theme.AccentColor
    button.TextColor3 = ForceLib.Theme.TextColor
    button.Font = ForceLib.Theme.Font
    button.TextSize = ForceLib.Theme.TextSize
    button.Parent = frame

    local waitingForKey = false

    button.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        button.Text = "Press a key..."

        local conn
        conn = UIS.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyPressed = input.KeyCode
                button.Text = keyPressed.Name
                waitingForKey = false
                callback(keyPressed)
                conn:Disconnect()
            end
        end)
    end)
end

function ForceLib:CreateTabSystem(tabNames: {string})
    local tabHolder = Instance.new("Frame")
    tabHolder.Size = UDim2.new(1, 0, 0, 30)
    tabHolder.BackgroundTransparency = 1
    tabHolder.Parent = self.MainFrame

    local tabButtons = {}
    local tabPages = {}
    local currentTab

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabHolder

    for _, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 1, 0)
        btn.BackgroundColor3 = ForceLib.Theme.MainColor
        btn.TextColor3 = ForceLib.Theme.TextColor
        btn.Font = ForceLib.Theme.Font
        btn.TextSize = ForceLib.Theme.TextSize
        btn.Text = name
        btn.Parent = tabHolder

        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, 0, 1, -30)
        page.Position = UDim2.new(0, 0, 0, 30)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = self.MainFrame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)
        layout.Parent = page

        tabButtons[name] = btn
        tabPages[name] = page

        btn.MouseButton1Click:Connect(function()
            if currentTab then tabPages[currentTab].Visible = false end
            currentTab = name
            page.Visible = true
        end)
    end

    local api = {}

    function api:AddElementToTab(tabName: string, element: Instance)
        element.Parent = tabPages[tabName]
    end

    function api:SwitchTab(name: string)
        if currentTab then tabPages[currentTab].Visible = false end
        currentTab = name
        tabPages[name].Visible = true
    end

    self.TabSystem = api
    return api
end

function ForceLib:CreateCollapsibleSection(title: string)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundColor3 = ForceLib.Theme.MainColor
    container.Parent = self.MainFrame

    local label = Instance.new("TextButton")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "[+] " .. title
    label.TextColor3 = ForceLib.Theme.TextColor
    label.Font = ForceLib.Theme.Font
    label.TextSize = ForceLib.Theme.TextSize
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = self.MainFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local expanded = false

    label.MouseButton1Click:Connect(function()
        expanded = not expanded
        label.Text = (expanded and "[-] " or "[+] ") .. title
        content.Size = UDim2.new(1, 0, 0, expanded and 100 or 0)
    end)

    local section = {}

    function section:AddElement(element: Instance)
        element.Parent = content
    end

    return section
end

function ForceLib:ShowNotification(text: string, duration: number)
    duration = duration or 3

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 250, 0, 50)
    notifFrame.Position = UDim2.new(1, -260, 0, 10)
    notifFrame.BackgroundColor3 = ForceLib.Theme.MainColor
    notifFrame.BorderSizePixel = 0
    notifFrame.AnchorPoint = Vector2.new(1, 0)
    notifFrame.Parent = self.ScreenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = ForceLib.Theme.TextColor
    textLabel.Font = ForceLib.Theme.Font
    textLabel.TextSize = ForceLib.Theme.TextSize
    textLabel.Text = text
    textLabel.TextWrapped = true
    textLabel.Parent = notifFrame

    local tweenIn = TweenService:Create(notifFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, -10, 0, 10)})
    local tweenOut = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, duration), {Position = UDim2.new(1, 300, 0, 10)})

    tweenIn:Play()
    tweenIn.Completed:Wait()
    tweenOut:Play()
    tweenOut.Completed:Wait()

    notifFrame:Destroy()
end

function ForceLib:SaveSettings(key: string, settings: table)
    local json = HttpService:JSONEncode(settings)
    local val = Instance.new("StringValue")
    val.Name = key
    val.Value = json
    val.Parent = self.ScreenGui
end

function ForceLib:LoadSettings(key: string)
    local val = self.ScreenGui:FindFirstChild(key)
    if val and val:IsA("StringValue") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(val.Value)
        end)
        if success then
            return data
        end
    end
    return nil
end

function ForceLib:SetTheme(themeTable: table)
    for k, v in pairs(themeTable) do
        if ForceLib.Theme[k] ~= nil then
            ForceLib.Theme[k] = v
        end
    end
    
    self.MainFrame.BackgroundColor3 = ForceLib.Theme.MainColor
    for _, child in pairs(self.MainFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child.TextColor3 = ForceLib.Theme.TextColor
            if child:IsA("TextButton") then
                child.BackgroundColor3 = ForceLib.Theme.AccentColor
            end
        end
    end
end

return ForceLib
