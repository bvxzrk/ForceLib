--!strict
-- ForceLib.lua - Enhanced UI Library with Loading Animation

local ForceLib = {}
ForceLib.__index = ForceLib

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

ForceLib.Theme = {
    MainColor = Color3.fromRGB(25, 25, 25),
    AccentColor = Color3.fromRGB(0, 170, 255),
    TextColor = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham,
    TextSize = 16,
}

-- Loading animation function
local function createLoadingScreen(guiParent)
    local loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "ForceLibLoadingScreen"
    loadingScreen.ResetOnSpawn = false
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingScreen.DisplayOrder = 999
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = loadingScreen
    
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
