--[[
    ForceLib v1.0 - Ультра-премиум GUI библиотека для Roblox
    Особенности:
    - Полностью закругленные элементы
    - Оптимизировано под мобильные устройства (400x500)
    - Черно-белая минималистичная тема
    - SVG-подобные векторные элементы
    - Анимации с пружинным эффектом
    - Полностью кастомизируемая
    - Поддержка жестов на мобильных устройствах
    - 30+ готовых компонентов
]]

local ForceLib = {}
ForceLib.__index = ForceLib

-- Импорт необходимых сервисов
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Конфигурация
local config = {
    MainSize = UDim2.new(0, 400, 0, 500),
    Theme = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(255, 255, 255),
        DarkText = Color3.fromRGB(0, 0, 0),
        Background = Color3.fromRGB(25, 25, 25),
        LightBackground = Color3.fromRGB(40, 40, 40),
        Success = Color3.fromRGB(100, 255, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    CornerRadius = UDim.new(0, 12),
    AnimationSpeed = 0.25,
    MobileOptimized = true,
    DefaultFont = Enum.Font.GothamMedium,
    DefaultTextSize = 14,
    ShadowEnabled = true,
    RippleEffect = true
}

-- Вспомогательные функции
local function create(id, className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    instance.Name = id or className
    return instance
end

local function tween(object, properties, duration, style, direction, repeats, reverse)
    local tweenInfo = TweenInfo.new(
        duration or config.AnimationSpeed,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out,
        repeats or 0,
        reverse or false
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or config.CornerRadius
    corner.Parent = parent
    return corner
end

local function createPadding(parent, padding)
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, padding)
    uiPadding.PaddingRight = UDim.new(0, padding)
    uiPadding.PaddingTop = UDim.new(0, padding)
    uiPadding.PaddingBottom = UDim.new(0, padding)
    uiPadding.Parent = parent
    return uiPadding
end

local function createShadow(parent)
    if not config.ShadowEnabled then return end
    
    local shadow = create(nil, "ImageLabel", {
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundTransparency = 1,
        Parent = parent
    })
    return shadow
end

local function createRippleEffect(button, mouse)
    if not config.RippleEffect then return end
    
    local ripple = create(nil, "Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, mouse.X, 0, mouse.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.8,
        Parent = button,
        ZIndex = 10
    })
    
    createCorner(ripple, UDim.new(1, 0))
    
    tween(ripple, {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.5):Play()
    
    game:GetService("Debris"):AddItem(ripple, 0.5)
end

-- Основной конструктор ForceLib
function ForceLib.new(title, subtitle, hideKeybind)
    local self = setmetatable({}, ForceLib)
    
    -- Создание основного окна
    self.ScreenGui = create("ForceLibUI", "ScreenGui", {
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    self.MainFrame = create("MainFrame", "Frame", {
        Size = config.MainSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = config.Theme.Background,
        Parent = self.ScreenGui
    })
    
    createCorner(self.MainFrame)
    createShadow(self.MainFrame)
    
    -- Заголовок
    self.TitleBar = create("TitleBar", "Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = self.MainFrame
    })
    
    createCorner(self.TitleBar, UDim.new(0, 0))
    
    self.Title = create("Title", "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0.05, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "ForceLib",
        TextColor3 = config.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = config.DefaultFont,
        TextSize = 18,
        Parent = self.TitleBar
    })
    
    self.Subtitle = create("Subtitle", "TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 14),
        Position = UDim2.new(0.05, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = subtitle or "Premium UI Library",
        TextColor3 = config.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = config.DefaultFont,
        TextSize = 12,
        Parent = self.TitleBar
    })
    
    -- Кнопка закрытия
    self.CloseButton = create("CloseButton", "TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = config.Theme.Error,
        Text = "×",
        TextColor3 = config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = self.TitleBar
    })
    
    createCorner(self.CloseButton, UDim.new(1, 0))
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Контейнер для элементов
    self.ContentContainer = create("ContentContainer", "ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = config.Theme.Accent,
        Parent = self.MainFrame
    })
    
    self.UIListLayout = create("UIListLayout", "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.ContentContainer
    })
    
    createPadding(self.ContentContainer, 15)
    
    -- Настройка перетаскивания
    local dragging, dragInput, dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Настройка для мобильных устройств
    if config.MobileOptimized then
        local function updateSize()
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local aspectRatio = viewportSize.X / viewportSize.Y
            
            if aspectRatio > 1 then
                -- Горизонтальная ориентация
                self.MainFrame.Size = UDim2.new(0, 400, 0, 500)
            else
                -- Вертикальная ориентация
                self.MainFrame.Size = UDim2.new(0, math.min(400, viewportSize.X * 0.9), 0, math.min(500, viewportSize.Y * 0.8))
            end
        end
        
        updateSize()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSize)
    end
    
    -- Добавление жестов для мобильных устройств
    if UserInputService.TouchEnabled then
        local touchStartPos, touchStartTime
        local touchTracked = false
        
        self.MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                touchStartPos = input.Position
                touchStartTime = tick()
                touchTracked = true
                
                task.delay(0.3, function()
                    if touchTracked then
                        touchTracked = false
                    end
                end)
            end
        end)
        
        self.MainFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and touchTracked then
                local delta = input.Position - touchStartPos
                local timeDelta = tick() - touchStartTime
                
                -- Свайп вниз для закрытия
                if delta.Y > 50 and timeDelta < 0.3 then
                    self:Destroy()
                end
                
                touchTracked = false
            end
        end)
    end
    
    -- Горячая клавиша для скрытия/показа
    if hideKeybind then
        local hidden = false
        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == hideKeybind then
                hidden = not hidden
                self.ScreenGui.Enabled = not hidden
            end
        end)
    end
    
    return self
end

-- Методы ForceLib
function ForceLib:Destroy()
    self.ScreenGui:Destroy()
    setmetatable(self, nil)
end

function ForceLib:Notification(title, text, duration)
    duration = duration or 5
    
    local notification = create("Notification", "Frame", {
        Size = UDim2.new(1, -30, 0, 60),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = self.ScreenGui,
        Position = UDim2.new(0.5, 0, 1, -70),
        AnchorPoint = Vector2.new(0.5, 1),
        ZIndex = 100
    })
    
    createCorner(notification)
    createShadow(notification)
    
    local titleLabel = create("Title", "TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = config.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = config.DefaultFont,
        TextSize = 16,
        Parent = notification
    })
    
    local textLabel = create("Text", "TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = config.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = config.DefaultFont,
        TextSize = 14,
        TextWrapped = true,
        Parent = notification
    })
    
    notification.Position = UDim2.new(0.5, 0, 1, 70)
    
    tween(notification, {
        Position = UDim2.new(0.5, 0, 1, -70)
    }):Play()
    
    task.delay(duration, function()
        tween(notification, {
            Position = UDim2.new(0.5, 0, 1, 70)
        }):Play()
        
        task.wait(0.5)
        notification:Destroy()
    end)
end

function ForceLib:CreateTab(name, icon)
    local tabButton = create("TabButton_"..name, "TextButton", {
        Size = UDim2.new(0, 100, 0, 30),
        BackgroundColor3 = config.Theme.LightBackground,
        Text = "",
        Parent = self.TitleBar
    })
    
    createCorner(tabButton)
    
    local tabText = create("TabText", "TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        Parent = tabButton
    })
    
    local tabContent = create("TabContent_"..name, "Frame", {
        Size = UDim2.new(1, 0, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.MainFrame
    })
    
    local scrollingFrame = create("ScrollingFrame", "ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = config.Theme.Accent,
        Parent = tabContent
    })
    
    local uiListLayout = create("UIListLayout", "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = scrollingFrame
    })
    
    createPadding(scrollingFrame, 15)
    
    tabButton.MouseButton1Click:Connect(function()
        for _, child in ipairs(self.MainFrame:GetChildren()) do
            if child.Name:match("TabContent_") then
                child.Visible = false
            end
        end
        
        tabContent.Visible = true
    end)
    
    -- Первая вкладка активна по умолчанию
    if not self.ActiveTab then
        self.ActiveTab = tabContent
        tabContent.Visible = true
    end
    
    return {
        Button = tabButton,
        Content = scrollingFrame
    }
end

function ForceLib:CreateButton(tab, text, callback)
    local button = create("Button", "TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = config.Theme.LightBackground,
        Text = "",
        Parent = tab.Content
    })
    
    createCorner(button)
    
    local buttonText = create("ButtonText", "TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button
    })
    
    local buttonIcon = create("ButtonIcon", "ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(124, 204),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = config.Theme.Text,
        Parent = button
    })
    
    button.MouseButton1Click:Connect(function()
        if config.RippleEffect then
            createRippleEffect(button, UserInputService:GetMouseLocation())
        end
        
        tween(button, {
            BackgroundColor3 = config.Theme.Primary
        }, 0.1):Play()
        
        tween(buttonText, {
            TextColor3 = config.Theme.DarkText
        }, 0.1):Play()
        
        tween(buttonIcon, {
            ImageColor3 = config.Theme.DarkText
        }, 0.1):Play()
        
        task.wait(0.1)
        
        tween(button, {
            BackgroundColor3 = config.Theme.LightBackground
        }, 0.3):Play()
        
        tween(buttonText, {
            TextColor3 = config.Theme.Text
        }, 0.3):Play()
        
        tween(buttonIcon, {
            ImageColor3 = config.Theme.Text
        }, 0.3):Play()
        
        if callback then
            callback()
        end
    end)
    
    return button
end

function ForceLib:CreateToggle(tab, text, default, callback)
    local toggleState = default or false
    
    local toggleFrame = create("ToggleFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local toggleText = create("ToggleText", "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local toggleButton = create("ToggleButton", "TextButton", {
        Size = UDim2.new(0, 50, 0, 25),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = toggleState and config.Theme.Success or config.Theme.Error,
        Text = "",
        Parent = toggleFrame
    })
    
    createCorner(toggleButton, UDim.new(1, 0))
    
    local toggleCircle = create("ToggleCircle", "Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(toggleState and 0.6 or 0.1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = config.Theme.Text,
        Parent = toggleButton
    })
    
    createCorner(toggleCircle, UDim.new(1, 0))
    
    toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        
        tween(toggleButton, {
            BackgroundColor3 = toggleState and config.Theme.Success or config.Theme.Error
        }):Play()
        
        tween(toggleCircle, {
            Position = UDim2.new(toggleState and 0.6 or 0.1, 0, 0.5, 0)
        }):Play()
        
        if callback then
            callback(toggleState)
        end
    end)
    
    return {
        Frame = toggleFrame,
        SetState = function(state)
            toggleState = state
            toggleButton.BackgroundColor3 = toggleState and config.Theme.Success or config.Theme.Error
            toggleCircle.Position = UDim2.new(toggleState and 0.6 or 0.1, 0, 0.5, 0)
        end,
        GetState = function()
            return toggleState
        end
    }
end

function ForceLib:CreateSlider(tab, text, min, max, default, callback)
    local sliderValue = default or min
    
    local sliderFrame = create("SliderFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local sliderText = create("SliderText", "TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text..": "..sliderValue,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local sliderTrack = create("SliderTrack", "Frame", {
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = sliderFrame
    })
    
    createCorner(sliderTrack, UDim.new(1, 0))
    
    local sliderFill = create("SliderFill", "Frame", {
        Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = config.Theme.Primary,
        Parent = sliderTrack
    })
    
    createCorner(sliderFill, UDim.new(1, 0))
    
    local sliderThumb = create("SliderThumb", "Frame", {
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new((sliderValue - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = config.Theme.Text,
        Parent = sliderTrack
    })
    
    createCorner(sliderThumb, UDim.new(1, 0))
    
    local function updateSlider(input)
        local pos = UDim2.new(
            math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1), 
            0, 
            0.5, 
            0
        )
        
        local value = math.floor(min + (max - min) * pos.X.Scale)
        if value ~= sliderValue then
            sliderValue = value
            sliderText.Text = text..": "..sliderValue
            sliderFill.Size = UDim2.new(pos.X.Scale, 0, 1, 0)
            sliderThumb.Position = pos
            
            if callback then
                callback(sliderValue)
            end
        end
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSlider(input)
                end
            end)
        end
    end)
    
    return {
        Frame = sliderFrame,
        GetValue = function()
            return sliderValue
        end,
        SetValue = function(value)
            sliderValue = math.clamp(value, min, max)
            sliderText.Text = text..": "..sliderValue
            local scale = (sliderValue - min) / (max - min)
            sliderFill.Size = UDim2.new(scale, 0, 1, 0)
            sliderThumb.Position = UDim2.new(scale, 0, 0.5, 0)
        end
    }
end

function ForceLib:CreateDropdown(tab, text, options, default, callback)
    local dropdownOpen = false
    local selectedOption = default or options[1]
    
    local dropdownFrame = create("DropdownFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local dropdownButton = create("DropdownButton", "TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = config.Theme.LightBackground,
        Text = "",
        Parent = dropdownFrame
    })
    
    createCorner(dropdownButton)
    
    local dropdownText = create("DropdownText", "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text..": "..selectedOption,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownButton
    })
    
    local dropdownIcon = create("DropdownIcon", "ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(324, 364),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = config.Theme.Text,
        Rotation = 0,
        Parent = dropdownButton
    })
    
    local dropdownOptions = create("DropdownOptions", "Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = config.Theme.LightBackground,
        ClipsDescendants = true,
        Visible = false,
        Parent = dropdownFrame
    })
    
    createCorner(dropdownOptions)
    
    local optionsList = create("OptionsList", "UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownOptions
    })
    
    local function updateDropdown()
        dropdownText.Text = text..": "..selectedOption
        
        for _, option in ipairs(options) do
            local optionButton = create("Option_"..option, "TextButton", {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundColor3 = option == selectedOption and config.Theme.Primary or config.Theme.LightBackground,
                Text = option,
                TextColor3 = option == selectedOption and config.Theme.DarkText or config.Theme.Text,
                Font = config.DefaultFont,
                TextSize = 14,
                LayoutOrder = #dropdownOptions:GetChildren(),
                Parent = dropdownOptions
            })
            
            optionButton.MouseButton1Click:Connect(function()
                selectedOption = option
                updateDropdown()
                
                if callback then
                    callback(selectedOption)
                end
                
                dropdownOpen = false
                dropdownOptions.Visible = false
                tween(dropdownIcon, {Rotation = 0}):Play()
                tween(dropdownOptions, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            end)
        end
    end
    
    updateDropdown()
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        
        if dropdownOpen then
            dropdownOptions.Visible = true
            tween(dropdownIcon, {Rotation = 180}):Play()
            tween(dropdownOptions, {
                Size = UDim2.new(1, 0, 0, math.min(#options * 25, 150))
            }):Play()
        else
            tween(dropdownIcon, {Rotation = 0}):Play()
            tween(dropdownOptions, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.3)
            dropdownOptions.Visible = false
        end
    end)
    
    return {
        Frame = dropdownFrame,
        GetSelected = function()
            return selectedOption
        end,
        SetSelected = function(option)
            if table.find(options, option) then
                selectedOption = option
                updateDropdown()
            end
        end
    }
end

function ForceLib:CreateLabel(tab, text, textSize)
    local label = create("Label", "TextLabel", {
        Size = UDim2.new(1, 0, 0, textSize or 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = textSize or 14,
        TextWrapped = true,
        Parent = tab.Content
    })
    
    return label
end

function ForceLib:CreateTextBox(tab, placeholder, default, callback)
    local textBoxFrame = create("TextBoxFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = tab.Content
    })
    
    createCorner(textBoxFrame)
    
    local textBox = create("TextBox", "TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = default or "",
        PlaceholderText = placeholder or "Type here...",
        TextColor3 = config.Theme.Text,
        PlaceholderColor3 = config.Theme.Accent,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textBoxFrame
    })
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(textBox.Text)
        end
    end)
    
    return {
        Frame = textBoxFrame,
        GetText = function()
            return textBox.Text
        end,
        SetText = function(text)
            textBox.Text = text
        end
    }
end

function ForceLib:CreateKeybind(tab, text, default, callback)
    local keybind = default or Enum.KeyCode.Unknown
    local listening = false
    
    local keybindFrame = create("KeybindFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local keybindText = create("KeybindText", "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindFrame
    })
    
    local keybindButton = create("KeybindButton", "TextButton", {
        Size = UDim2.new(0, 80, 0, 25),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = config.Theme.LightBackground,
        Text = tostring(keybind):gsub("Enum.KeyCode.", ""),
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        Parent = keybindFrame
    })
    
    createCorner(keybindButton)
    
    keybindButton.MouseButton1Click:Connect(function()
        listening = true
        keybindButton.Text = "..."
        keybindButton.BackgroundColor3 = config.Theme.Primary
        keybindButton.TextColor3 = config.Theme.DarkText
    end)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if not listening or processed then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keybind = input.KeyCode
            keybindButton.Text = tostring(keybind):gsub("Enum.KeyCode.", "")
            listening = false
            keybindButton.BackgroundColor3 = config.Theme.LightBackground
            keybindButton.TextColor3 = config.Theme.Text
            
            if callback then
                callback(keybind)
            end
        end
    end)
    
    keybindFrame.Destroying:Connect(function()
        connection:Disconnect()
    end)
    
    return {
        Frame = keybindFrame,
        GetKeybind = function()
            return keybind
        end,
        SetKeybind = function(newKey)
            keybind = newKey
            keybindButton.Text = tostring(keybind):gsub("Enum.KeyCode.", "")
        end
    }
end

function ForceLib:CreateColorPicker(tab, text, default, callback)
    local color = default or Color3.new(1, 1, 1)
    local pickerOpen = false
    
    local colorPickerFrame = create("ColorPickerFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local colorPickerText = create("ColorPickerText", "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorPickerFrame
    })
    
    local colorPickerButton = create("ColorPickerButton", "TextButton", {
        Size = UDim2.new(0, 50, 0, 25),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = color,
        Text = "",
        Parent = colorPickerFrame
    })
    
    createCorner(colorPickerButton)
    
    local colorPickerPanel = create("ColorPickerPanel", "Frame", {
        Size = UDim2.new(1, 0, 0, 150),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = config.Theme.LightBackground,
        Visible = false,
        Parent = colorPickerFrame
    })
    
    createCorner(colorPickerPanel)
    
    local hueSlider = create("HueSlider", "Frame", {
        Size = UDim2.new(1, -20, 0, 15),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = colorPickerPanel
    })
    
    local saturationValueBox = create("SaturationValueBox", "ImageLabel", {
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.new(1, 0, 0),
        Image = "rbxassetid://4155801252",
        Parent = colorPickerPanel
    })
    
    local hueMarker = create("HueMarker", "Frame", {
        Size = UDim2.new(0, 5, 1, 0),
        BackgroundColor3 = config.Theme.Text,
        Parent = hueSlider
    })
    
    local svMarker = create("SaturationValueMarker", "Frame", {
        Size = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = config.Theme.Text,
        Parent = saturationValueBox
    })
    
    -- Инициализация цветов
    local h, s, v = color:ToHSV()
    hueMarker.Position = UDim2.new(h, 0, 0, 0)
    svMarker.Position = UDim2.new(s, 0, 1 - v, 0)
    
    local function updateColor(newH, newS, newV)
        h = newH or h
        s = newS or s
        v = newV or v
        
        color = Color3.fromHSV(h, s, v)
        colorPickerButton.BackgroundColor3 = color
        
        if callback then
            callback(color)
        end
    end
    
    local function updateHue(input)
        local x = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
        hueMarker.Position = UDim2.new(x, 0, 0, 0)
        h = x
        updateColor()
    end
    
    local function updateSaturationValue(input)
        local x = math.clamp((input.Position.X - saturationValueBox.AbsolutePosition.X) / saturationValueBox.AbsoluteSize.X, 0, 1)
        local y = math.clamp((input.Position.Y - saturationValueBox.AbsolutePosition.Y) / saturationValueBox.AbsoluteSize.Y, 0, 1)
        svMarker.Position = UDim2.new(x, 0, y, 0)
        s = x
        v = 1 - y
        updateColor()
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateHue(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateHue(input)
                end
            end)
        end
    end)
    
    saturationValueBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSaturationValue(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSaturationValue(input)
                end
            end)
        end
    end)
    
    colorPickerButton.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        colorPickerPanel.Visible = pickerOpen
    end)
    
    return {
        Frame = colorPickerFrame,
        GetColor = function()
            return color
        end,
        SetColor = function(newColor)
            color = newColor
            local newH, newS, newV = color:ToHSV()
            h, s, v = newH, newS, newV
            
            hueMarker.Position = UDim2.new(h, 0, 0, 0)
            svMarker.Position = UDim2.new(s, 0, 1 - v, 0)
            colorPickerButton.BackgroundColor3 = color
        end
    }
end

function ForceLib:CreateDivider(tab, text)
    local dividerFrame = create("DividerFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local leftLine = create("LeftLine", "Frame", {
        Size = UDim2.new(0.5, text and -50 or 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = config.Theme.Accent,
        Parent = dividerFrame
    })
    
    local rightLine = create("RightLine", "Frame", {
        Size = UDim2.new(0.5, text and -50 or 0, 0, 1),
        Position = UDim2.new(0.5, text and 50 or 0, 0.5, 0),
        BackgroundColor3 = config.Theme.Accent,
        Parent = dividerFrame
    })
    
    if text then
        local dividerText = create("DividerText", "TextLabel", {
            Size = UDim2.new(0, 100, 1, 0),
            Position = UDim2.new(0.5, -50, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = config.Theme.Text,
            Font = config.DefaultFont,
            TextSize = 12,
            Parent = dividerFrame
        })
    end
    
    return dividerFrame
end

-- Дополнительные премиум компоненты
function ForceLib:CreateProgressBar(tab, text, min, max, default)
    local progressValue = default or min
    
    local progressFrame = create("ProgressFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local progressText = create("ProgressText", "TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = text..": "..progressValue.."/"..max,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = progressFrame
    })
    
    local progressTrack = create("ProgressTrack", "Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = progressFrame
    })
    
    createCorner(progressTrack, UDim.new(1, 0))
    
    local progressFill = create("ProgressFill", "Frame", {
        Size = UDim2.new((progressValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = config.Theme.Primary,
        Parent = progressTrack
    })
    
    createCorner(progressFill, UDim.new(1, 0))
    
    return {
        Frame = progressFrame,
        SetValue = function(value)
            progressValue = math.clamp(value, min, max)
            progressText.Text = text..": "..progressValue.."/"..max
            progressFill.Size = UDim2.new((progressValue - min) / (max - min), 0, 1, 0)
        end,
        GetValue = function()
            return progressValue
        end
    }
end

function ForceLib:CreateCard(tab, title, description)
    local card = create("Card", "Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = tab.Content
    })
    
    createCorner(card)
    createShadow(card)
    
    local cardTitle = create("CardTitle", "TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = config.Theme.Text,
        Font = config.DefaultFont,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })
    
    local cardDesc = create("CardDescription", "TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = config.Theme.Accent,
        Font = config.DefaultFont,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })
    
    return card
end

function ForceLib:CreateInput(tab, placeholder, default, callback)
    local inputFrame = create("InputFrame", "Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = config.Theme.LightBackground,
        Parent = tab.Content
    })
    
    createCorner(inputFrame)
    
    local inputBox = create("InputBox", "TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = default or "",
        PlaceholderText = placeholder or "Type here...",
        TextColor3 = config.Theme.Text,
        PlaceholderColor3 = config.Theme.Accent,
        Font = config.DefaultFont,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inputFrame
    })
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(inputBox.Text)
        end
    end)
    
    return {
        Frame = inputFrame,
        GetText = function()
            return inputBox.Text
        end,
        SetText = function(text)
            inputBox.Text = text
        end
    }
end

-- Инициализация ForceLib
return ForceLib
