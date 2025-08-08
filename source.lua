--[[
    ForceLib v1.0 - Ультра-премиум GUI библиотека для Roblox
    Создано с любовью и вниманием к деталям
    Особенности:
    - Идеально закругленные элементы
    - Черно-белая минималистичная тема
    - SVG-стилизованные иконки
    - Плавные анимации
    - Полностью настраиваемые компоненты
    - Оптимизированная производительность
]]

local ForceLib = {}
ForceLib.__index = ForceLib

-- Импортируем необходимые сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Конфигурация библиотеки
ForceLib.Config = {
    Theme = {
        Primary = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(245, 245, 245),
        Disabled = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(0, 200, 0),
        Error = Color3.fromRGB(200, 0, 0)
    },
    Font = Enum.Font.GothamMedium,
    CornerRadius = UDim.new(0, 12),
    ElementSize = UDim2.new(0, 400, 0, 500),
    AnimationSpeed = 0.25,
    DropShadow = true,
    BlurEffect = true
}

-- SVG иконки (упрощенные версии)
ForceLib.Icons = {
    Close = "M12,2C6.47,2,2,6.47,2,12s4.47,10,10,10s10-4.47,10-10S17.53,2,12,2z M17,15.59L15.59,17L12,13.41L8.41,17L7,15.59L10.59,12L7,8.41L8.41,7L12,10.59L15.59,7L17,8.41L13.41,12L17,15.59z",
    Minimize = "M19,13H5v-2h14V13z",
    Maximize = "M19,3H5C3.89,3,3,3.9,3,5v14c0,1.1,0.89,2,2,2h14c1.1,0,2-0.9,2-2V5C21,3.9,20.11,3,19,3z M19,19H5V5h14V19z",
    Settings = "M19.43,12.98c0.04-0.32,0.07-0.64,0.07-0.98s-0.03-0.66-0.07-0.98l2.11-1.65c0.19-0.15,0.24-0.42,0.12-0.64l-2-3.46c-0.12-0.22-0.39-0.3-0.61-0.22l-2.49,1c-0.52-0.4-1.08-0.73-1.69-0.98l-0.38-2.65C14.46,2.18,14.25,2,14,2h-4c-0.25,0-0.46,0.18-0.49,0.42L9.08,5.07c-0.6,0.25-1.17,0.59-1.69,0.98l-2.49-1c-0.23-0.09-0.49,0-0.61,0.22l-2,3.46c-0.13,0.22-0.07,0.49,0.12,0.64l2.11,1.65C4.53,11.34,4.5,11.67,4.5,12s0.03,0.66,0.07,0.98l-2.11,1.65c-0.19,0.15-0.24,0.42-0.12,0.64l2,3.46c0.12,0.22,0.39,0.3,0.61,0.22l2.49-1c0.52,0.4,1.08,0.73,1.69,0.98l0.38,2.65C9.54,21.82,9.75,22,10,22h4c0.25,0,0.46-0.18,0.49-0.42l0.38-2.65c0.61-0.25,1.17-0.59,1.69-0.98l2.49,1c0.23,0.09,0.49,0,0.61-0.22l2-3.46c0.12-0.22,0.07-0.49-0.12-0.64L19.43,12.98z M12,15.5c-1.93,0-3.5-1.57-3.5-3.5s1.57-3.5,3.5-3.5s3.5,1.57,3.5,3.5S13.93,15.5,12,15.5z",
    Info = "M12,2C6.48,2,2,6.48,2,12s4.48,10,10,10s10-4.48,10-10S17.52,2,12,2z M13,17h-2v-6h2V17z M13,9h-2V7h2V9z",
    Warning = "M12,2L1,21h22L12,2z M12,11c-0.55,0-1,0.45-1,1v4c0,0.55,0.45,1,1,1s1-0.45,1-1v-4C13,11.45,12.55,11,12,11z M13,18h-2v-2h2V18z",
    Check = "M9,16.17L4.83,12l-1.42,1.41L9,19L21,7l-1.41-1.41L9,16.17z",
    ArrowRight = "M10 17l5-5-5-5v10z",
    Menu = "M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"
}

-- Вспомогательные функции
local function Create(class, props)
    local instance = Instance.new(class)
    for prop, value in pairs(props) do
        if prop == "Children" then
            for _, child in ipairs(value) do
                child.Parent = instance
            end
        else
            instance[prop] = value
        end
    end
    return instance
end

local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or ForceLib.Config.AnimationSpeed,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateSVG(path, color, size)
    local svg = Create("ImageLabel", {
        Size = size or UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. HttpService:GenerateGUID(false),
        ImageColor3 = color or ForceLib.Config.Theme.Accent
    })
    
    -- Здесь должна быть логика рендеринга SVG, но для примера оставим пустым
    return svg
end

-- Основное окно
function ForceLib:CreateWindow(options)
    options = options or {}
    local window = setmetatable({}, ForceLib)
    
    -- Создаем основной экран
    window.ScreenGui = Create("ScreenGui", {
        Name = "ForceLibWindow",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    -- Фоновый блюр (если включен в конфиге)
    if ForceLib.Config.BlurEffect then
        window.Blur = Create("BlurEffect", {
            Parent = game:GetService("Lighting"),
            Size = 24,
            Name = "ForceLibBlur"
        })
    end
    
    -- Основной контейнер
    window.MainFrame = Create("Frame", {
        Parent = window.ScreenGui,
        Size = options.Size or ForceLib.Config.ElementSize,
        Position = options.Position or UDim2.new(0.5, -200, 0.5, -250),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ForceLib.Config.Theme.Primary,
        ClipsDescendants = true,
        Children = {
            Create("UICorner", {
                CornerRadius = ForceLib.Config.CornerRadius
            }),
            Create("UIStroke", {
                Color = ForceLib.Config.Theme.Accent,
                Thickness = 1,
                Transparency = 0.8
            })
        }
    })
    
    -- Тень (если включена в конфиге)
    if ForceLib.Config.DropShadow then
        Create("ImageLabel", {
            Parent = window.MainFrame,
            Name = "Shadow",
            Image = "rbxassetid://1316045217",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.8,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 118, 118),
            Size = UDim2.new(1, 20, 1, 20),
            Position = UDim2.new(0, -10, 0, -10),
            BackgroundTransparency = 1,
            ZIndex = -1
        })
    end
    
    -- Заголовок окна
    window.TitleBar = Create("Frame", {
        Parent = window.MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ForceLib.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Children = {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 12)
            }),
            Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = options.Title or "ForceLib Window",
                TextColor3 = ForceLib.Config.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = ForceLib.Config.Font,
                TextSize = 18
            }),
            Create("TextButton", {
                Name = "Close",
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1,
                Text = "",
                Children = {
                    CreateSVG(ForceLib.Icons.Close, ForceLib.Config.Theme.Text, UDim2.new(0, 24, 0, 24))
                }
            })
        }
    })
    
    -- Контейнер для вкладок
    window.TabContainer = Create("Frame", {
        Parent = window.MainFrame,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })
    
    -- Инициализация вкладок
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Добавляем функционал перетаскивания
    local dragInput, dragStart, startPos
    window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = window.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    
    window.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            window.MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Функционал кнопки закрытия
    window.TitleBar.Close.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- Анимация появления
    window.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    window.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(window.MainFrame, {
        Size = options.Size or ForceLib.Config.ElementSize,
        Position = options.Position or UDim2.new(0.5, -200, 0.5, -250)
    }, 0.5)
    
    return window
end

-- Функционал вкладок
function ForceLib:CreateTab(name, icon)
    local tab = {}
    tab.Name = name or "Tab"
    
    -- Кнопка вкладки
    tab.Button = Create("TextButton", {
        Parent = self.TitleBar,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, #self.Tabs * 100 + 10, 0, 0),
        BackgroundColor3 = ForceLib.Config.Theme.Primary,
        Text = tab.Name,
        TextColor3 = ForceLib.Config.Theme.Text,
        Font = ForceLib.Config.Font,
        TextSize = 14,
        Children = {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 12)
            })
        }
    })
    
    -- Контейнер вкладки
    tab.Container = Create("ScrollingFrame", {
        Parent = self.TabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = ForceLib.Config.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Children = {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
        }
    })
    
    -- Функционал переключения вкладок
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Если это первая вкладка, делаем ее активной
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    return tab
end

function ForceLib:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Container.Visible = false
        Tween(self.CurrentTab.Button, {
            BackgroundColor3 = ForceLib.Config.Theme.Primary
        })
    end
    
    self.CurrentTab = tab
    tab.Container.Visible = true
    Tween(tab.Button, {
        BackgroundColor3 = ForceLib.Config.Theme.Secondary
    })
end

-- Элементы интерфейса
function ForceLib:CreateButton(tab, options)
    options = options or {}
    local button = {}
    
    button.Instance = Create("TextButton", {
        Parent = tab.Container,
        Size = UDim2.new(1, -20, 0, 40),
        BackgroundColor3 = ForceLib.Config.Theme.Secondary,
        Text = options.Text or "Button",
        TextColor3 = ForceLib.Config.Theme.Text,
        Font = ForceLib.Config.Font,
        TextSize = 14,
        AutoButtonColor = false,
        LayoutOrder = #tab.Container:GetChildren(),
        Children = {
            Create("UICorner", {
                CornerRadius = ForceLib.Config.CornerRadius
            }),
            Create("UIStroke", {
                Color = ForceLib.Config.Theme.Accent,
                Thickness = 1,
                Transparency = 0.8
            })
        }
    })
    
    -- Анимации наведения
    button.Instance.MouseEnter:Connect(function()
        Tween(button.Instance, {
            BackgroundColor3 = Color3.fromRGB(
                ForceLib.Config.Theme.Secondary.R * 255 + 20,
                ForceLib.Config.Theme.Secondary.G * 255 + 20,
                ForceLib.Config.Theme.Secondary.B * 255 + 20
            )
        })
    end)
    
    button.Instance.MouseLeave:Connect(function()
        Tween(button.Instance, {
            BackgroundColor3 = ForceLib.Config.Theme.Secondary
        })
    end)
    
    button.Instance.MouseButton1Down:Connect(function()
        Tween(button.Instance, {
            BackgroundColor3 = Color3.fromRGB(
                ForceLib.Config.Theme.Secondary.R * 255 - 20,
                ForceLib.Config.Theme.Secondary.G * 255 - 20,
                ForceLib.Config.Theme.Secondary.B * 255 - 20
            )
        })
    end)
    
    button.Instance.MouseButton1Up:Connect(function()
        Tween(button.Instance, {
            BackgroundColor3 = ForceLib.Config.Theme.Secondary
        })
        if options.Callback then
            options.Callback()
        end
    end)
    
    -- Обновляем размер канваса
    tab.Container.CanvasSize = UDim2.new(0, 0, 0, #tab.Container:GetChildren() * 50)
    
    return button
end

function ForceLib:CreateToggle(tab, options)
    options = options or {}
    local toggle = {}
    toggle.Value = options.Default or false
    
    toggle.Instance = Create("Frame", {
        Parent = tab.Container,
        Size = UDim2.new(1, -20, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Container:GetChildren(),
        Children = {
            Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = options.Text or "Toggle",
                TextColor3 = ForceLib.Config.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = ForceLib.Config.Font,
                TextSize = 14
            }),
            Create("Frame", {
                Name = "Toggle",
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -50, 0.5, -12.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = ForceLib.Config.Theme.Secondary,
                Children = {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 12)
                    }),
                    Create("Frame", {
                        Name = "Indicator",
                        Size = UDim2.new(0, 21, 0, 21),
                        Position = UDim2.new(0, 2, 0.5, -10.5),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = ForceLib.Config.Theme.Accent,
                        Children = {
                            Create("UICorner", {
                                CornerRadius = UDim.new(0, 10)
                            })
                        }
                    })
                }
            })
        }
    })
    
    -- Обновляем состояние
    local function Update()
        Tween(toggle.Instance.Toggle.Indicator, {
            Position = toggle.Value and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
            BackgroundColor3 = toggle.Value and ForceLib.Config.Theme.Success or ForceLib.Config.Theme.Accent
        })
        
        Tween(toggle.Instance.Toggle, {
            BackgroundColor3 = toggle.Value and Color3.fromRGB(
                ForceLib.Config.Theme.Secondary.R * 255 + 30,
                ForceLib.Config.Theme.Secondary.G * 255 + 30,
                ForceLib.Config.Theme.Secondary.B * 255 + 30
            ) or ForceLib.Config.Theme.Secondary
        })
    end
    
    Update()
    
    -- Обработка клика
    toggle.Instance.Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle.Value = not toggle.Value
            Update()
            if options.Callback then
                options.Callback(toggle.Value)
            end
        end
    end)
    
    -- Обновляем размер канваса
    tab.Container.CanvasSize = UDim2.new(0, 0, 0, #tab.Container:GetChildren() * 50)
    
    return toggle
end

-- Другие элементы (Slider, Dropdown, TextBox, Label, Keybind и т.д.) могут быть добавлены аналогично

-- Функция уничтожения
function ForceLib:Destroy()
    if self.Blur then
        self.Blur:Destroy()
    end
    self.ScreenGui:Destroy()
end

return ForceLib
