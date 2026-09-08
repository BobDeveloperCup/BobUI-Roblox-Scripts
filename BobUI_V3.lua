local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {
    WhitelistedUsers = {} 
}

local _isfolder = isfolder or function() return true end
local _makefolder = makefolder or function() end
local _writefile = writefile or function(path, data) warn("File saving not supported on this executor.") end
local _readfile = readfile or function() return "{}" end
local _listfiles = listfiles or function() return {} end
local _delfile = delfile or function() warn("File deletion not supported.") end

local function SafeCopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        warn("Clipboard copying is not supported on your current executor.")
    end
end

local function Create(className, properties)
    local instance = Instance.new(className)
    
    if className == "TextBox" then
        instance.Text = ""
    end
    
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        instance.TextStrokeTransparency = 1 
        instance.BorderSizePixel = 0
    end

    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    
    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") then
        if properties and properties.TextSize and properties.RichText ~= true then
            instance.TextScaled = true
            local constraint = Instance.new("UITextSizeConstraint")
            constraint.MaxTextSize = properties.TextSize
            constraint.MinTextSize = 6
            constraint.Parent = instance
        end
    end
    
    return instance
end

local function BuildSearchIndex(card)
    local parts = {}
    for _, desc in ipairs(card:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if desc.Text and desc.Text ~= "" then
                table.insert(parts, desc.Text:lower())
            end
        end
    end
    return table.concat(parts, " ")
end

local function Tween(instance, properties, duration)
    duration = duration or 0.25
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function AddBounce(button, scaleFactor)
    scaleFactor = scaleFactor or 0.96
    local scaleObj = button:FindFirstChild("UIScale") or Create("UIScale", {Parent = button, Scale = 1})
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = scaleFactor}, 0.15)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = 1}, 0.15)
        end
    end)
    button.MouseLeave:Connect(function()
        Tween(scaleObj, {Scale = 1}, 0.15)
    end)
end

local function MakeDraggable(topbar, object)
    topbar.Active = true
    object.Active = true
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.08)
        end
    end)
end

local Fonts = {
    Regular = Enum.Font.Gotham,
    Bold = Enum.Font.GothamBold,
    Black = Enum.Font.GothamBlack,
    Code = Enum.Font.Code
}

local Themes = {
    Light = {
        Background = Color3.fromRGB(255, 255, 255),
        Card = Color3.fromRGB(245, 245, 248),
        Hover = Color3.fromRGB(230, 230, 235),
        Text = Color3.fromRGB(30, 30, 35),
        SubText = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(255, 105, 180) 
    },
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Card = Color3.fromRGB(35, 35, 35),
        Hover = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(170, 170, 170),
        Border = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(255, 105, 180) 
    }
}

Library.Themes = Themes

function Library:SetTheme(themeInput)
    if type(themeInput) == "string" and Themes[themeInput] then
        Themes.Current = Themes[themeInput]
    elseif type(themeInput) == "table" then
        Themes.Current = themeInput
    end
end

local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    local title = options.Title or "Notification"
    local desc = options.Description or "Information updated."
    local duration = options.Duration or 3

    local Notif = Create("Frame", {Parent = GlobalNotifContainer, BackgroundColor3 = Color3.fromRGB(240, 240, 245), Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 6)})
    local Stroke = Create("UIStroke", {Parent = Notif, Color = Color3.fromRGB(220, 220, 220), Thickness = 1.5, Transparency = 1})

    local TitleText = Create("TextLabel", {Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(30, 30, 35), BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    local DescText = Create("TextLabel", {Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(100, 100, 110), BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 32), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})

    Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0}, 0.3)
    Tween(TitleText, {TextTransparency = 0}, 0.3)
    Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        Tween(Notif, {BackgroundTransparency = 1}, 0.4)
        Tween(Stroke, {Transparency = 1}, 0.4)
        Tween(TitleText, {TextTransparency = 1}, 0.4)
        Tween(DescText, {TextTransparency = 1}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
    end)
end

function Library:SetBorderColor(newColor)
end

function Library:CreateWindow(options)
    local hubName = "SpectraHub"
    local subText = "Made By BobDeveloperCup"
    local sphTextToggle = false
    local sphWords = "ZX"
    local sphImage = nil
    local topbarLogo = nil
    local logoSize = 32
    local sphIconSize = 26

    local activeTheme = Themes.Light
    if type(options) == "table" then
        if options.Theme then
            if type(options.Theme) == "string" and Themes[options.Theme] then
                activeTheme = Themes[options.Theme]
            elseif type(options.Theme) == "table" then
                activeTheme = options.Theme
            end
        end

        hubName = options.Title or hubName
        subText = options.Subtitle or subText
        
        activeTheme = {
            Background = options.BackgroundColor or activeTheme.Background,
            Card = options.CardColor or activeTheme.Card,
            Hover = activeTheme.Hover,
            Text = options.TextColor or activeTheme.Text,
            SubText = options.SubTextColor or activeTheme.SubText,
            Border = options.BorderColor or activeTheme.Border,
            Accent = options.AccentColor or activeTheme.Accent
        }

        if options.SphereText ~= nil then sphTextToggle = options.SphereText end
        if options.SphereWords ~= nil then
            local wordList = string.split(tostring(options.SphereWords), " ")
            sphWords = #wordList > 2 and (wordList[1] .. " " .. wordList[2]) or tostring(options.SphereWords)
        end
        sphImage = options.SphereImage
        topbarLogo = options.Logo
        logoSize = options.LogoSize or 32
        sphIconSize = options.SphereIconSize or 26
    elseif type(options) == "string" then
        hubName = options
    end

    local uniqueID = HttpService:GenerateGUID(false)
    local ScreenGui = Create("ScreenGui", {
        Name = "SpectraHub_UI_" .. uniqueID,
        Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local Window = {
        CurrentTab = nil,
        Tabs = {},
        AllCards = {},
        CurrentTransparency = 0,
        ConfigElements = {},
        CurrentTheme = activeTheme,
        ThemeObjects = {}
    }

    local function RegTheme(instance, property, role, stateFunc)
        if not instance then return end
        table.insert(Window.ThemeObjects, {
            Instance = instance,
            Property = property,
            Role = role,
            StateFunc = stateFunc
        })
        local val = stateFunc and stateFunc(Window.CurrentTheme) or Window.CurrentTheme[role]
        if val then
            instance[property] = val
        end
    end

    function Window:SetTheme(themeInput)
        local targetTheme = nil
        if type(themeInput) == "string" then
            targetTheme = Themes[themeInput]
        elseif type(themeInput) == "table" then
            targetTheme = themeInput
        end

        if not targetTheme then return end
        Window.CurrentTheme = targetTheme

        for i = #Window.ThemeObjects, 1, -1 do
            local item = Window.ThemeObjects[i]
            if item.Instance and item.Instance.Parent then
                local targetColor = item.StateFunc and item.StateFunc(targetTheme) or targetTheme[item.Role]
                if targetColor then
                    Tween(item.Instance, {[item.Property] = targetColor}, 0.25)
                end
            else
                table.remove(Window.ThemeObjects, i)
            end
        end
    end

    local NotifContainer = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -340, 0, 10),
        ZIndex = 200,
        Active = false
    })
    Create("UIListLayout", {Parent = NotifContainer, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
    GlobalNotifContainer = NotifContainer

    local function SendPremiumNotification()
        local Notif = Create("Frame", {Parent = NotifContainer, BackgroundColor3 = Window.CurrentTheme.Card, Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
        Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 6)})
        local Stroke = Create("UIStroke", {Parent = Notif, Thickness = 1.5, Transparency = 1, Color = Window.CurrentTheme.Border})

        RegTheme(Notif, "BackgroundColor3", "Card")
        RegTheme(Stroke, "Color", "Border")

        local LockIcon = Create("ImageLabel", {Parent = Notif, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 15, 0.5, -12), Image = "rbxassetid://6031082533", ImageColor3 = Color3.fromRGB(255, 215, 0), ImageTransparency = 1, ZIndex = 202})
        local TitleText = Create("TextLabel", {Parent = Notif, Text = "ACCESS DENIED", Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 15), Size = UDim2.new(1, -60, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
        local DescText = Create("TextLabel", {Parent = Notif, Text = 'This Is For <font color="#FFD700"><b>Whitelisted Users</b></font>', RichText = true, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Window.CurrentTheme.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 32), Size = UDim2.new(1, -60, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
        
        RegTheme(TitleText, "TextColor3", "SubText")
        RegTheme(DescText, "TextColor3", "Text")

        local Shine = Create("Frame", {Parent = Notif, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.8, BorderSizePixel = 0, Size = UDim2.new(0, 20, 2, 0), Position = UDim2.new(-0.2, 0, -0.5, 0), Rotation = 25, ZIndex = 203})

        Tween(Notif, {BackgroundTransparency = 0}, 0.3)
        Tween(Stroke, {Transparency = 0}, 0.3)
        Tween(LockIcon, {ImageTransparency = 0}, 0.3)
        Tween(TitleText, {TextTransparency = 0}, 0.3)
        Tween(DescText, {TextTransparency = 0}, 0.3)

        local shineTween = TweenService:Create(Shine, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(1.2, 0, -0.5, 0)})
        task.delay(0.2, function() shineTween:Play() end)

        task.delay(4, function()
            Tween(Notif, {BackgroundTransparency = 1}, 0.4)
            Tween(Stroke, {Transparency = 1}, 0.4)
            Tween(LockIcon, {ImageTransparency = 1}, 0.4)
            Tween(TitleText, {TextTransparency = 1}, 0.4)
            Tween(DescText, {TextTransparency = 1}, 0.4)
            task.wait(0.4)
            Notif:Destroy()
        end)
    end

    local InfoOverlay = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 150, Visible = false, Active = true})
    local InfoCard = Create("Frame", {Parent = InfoOverlay, BackgroundColor3 = Window.CurrentTheme.Card, Size = UDim2.new(0, 360, 0, 280), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 151, BackgroundTransparency = 1, ClipsDescendants = true})
    Create("UICorner", {Parent = InfoCard, CornerRadius = UDim.new(0, 8)})
    local InfoCardStroke = Create("UIStroke", {Parent = InfoCard, Color = Window.CurrentTheme.Border, Thickness = 1.5, Transparency = 1})
    local InfoScale = Create("UIScale", {Parent = InfoCard, Scale = 0})

    RegTheme(InfoCard, "BackgroundColor3", "Card")
    RegTheme(InfoCardStroke, "Color", "Border")

    local InfoHeader = Create("Frame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), ZIndex = 152})
    local InfoTitle = Create("TextLabel", {Parent = InfoHeader, Text = "Feature Info", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Window.CurrentTheme.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 152})
    local InfoCloseBtn = Create("TextButton", {Parent = InfoHeader, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), ZIndex = 152, TextTransparency = 1})
    AddBounce(InfoCloseBtn)

    RegTheme(InfoTitle, "TextColor3", "Text")
    RegTheme(InfoCloseBtn, "TextColor3", "SubText")

    local InfoScroll = Create("ScrollingFrame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -60), Position = UDim2.new(0, 20, 0, 50), CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Window.CurrentTheme.Accent, BorderSizePixel = 0, ZIndex = 152})
    RegTheme(InfoScroll, "ScrollBarImageColor3", "Accent")

    local InfoLayout = Create("UIListLayout", {Parent = InfoScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    local InfoDesc = Create("TextLabel", {Parent = InfoScroll, Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
    RegTheme(InfoDesc, "TextColor3", "SubText")

    local InfoExampleBox = Create("Frame", {Parent = InfoScroll, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 152})
    Create("UICorner", {Parent = InfoExampleBox, CornerRadius = UDim.new(0, 6)})
    local InfoExStroke = Create("UIStroke", {Parent = InfoExampleBox, Color = Window.CurrentTheme.Border, Thickness = 1})
    local InfoExampleText = Create("TextLabel", {Parent = InfoExampleBox, Text = "", Font = Enum.Font.Code, TextSize = 12, TextColor3 = Window.CurrentTheme.Accent, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 10), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
    Create("UIPadding", {Parent = InfoExampleBox, PaddingBottom = UDim.new(0, 10)})

    RegTheme(InfoExampleBox, "BackgroundColor3", "Background")
    RegTheme(InfoExStroke, "Color", "Border")
    RegTheme(InfoExampleText, "TextColor3", "Accent")

    InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() InfoScroll.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 10) end)

    local function OpenInfoWindow(data)
        InfoTitle.Text = data.Title or "Information"
        InfoDesc.Text = data.Description or "No description provided."
        if data.Example then
            InfoExampleText.Text = data.Example
            InfoExampleBox.Visible = true
        else
            InfoExampleBox.Visible = false
        end
        InfoOverlay.Visible = true
        Tween(InfoOverlay, {BackgroundTransparency = 0.4}, 0.3)
        Tween(InfoCard, {BackgroundTransparency = 0}, 0.3)
        Tween(InfoCardStroke, {Transparency = 0.3}, 0.3)
        Tween(InfoScale, {Scale = 1}, 0.3)
        Tween(InfoTitle, {TextTransparency = 0}, 0.3)
        Tween(InfoCloseBtn, {TextTransparency = 0}, 0.3)
        Tween(InfoDesc, {TextTransparency = 0}, 0.3)
        if data.Example then Tween(InfoExampleText, {TextTransparency = 0}, 0.3) end
    end

    InfoCloseBtn.MouseButton1Click:Connect(function()
        Tween(InfoOverlay, {BackgroundTransparency = 1}, 0.3)
        Tween(InfoCard, {BackgroundTransparency = 1}, 0.3)
        Tween(InfoCardStroke, {Transparency = 1}, 0.3)
        Tween(InfoScale, {Scale = 0}, 0.3)
        Tween(InfoTitle, {TextTransparency = 1}, 0.3)
        Tween(InfoCloseBtn, {TextTransparency = 1}, 0.3)
        Tween(InfoDesc, {TextTransparency = 1}, 0.3)
        if InfoExampleBox.Visible then Tween(InfoExampleText, {TextTransparency = 1}, 0.3) end
        task.wait(0.3)
        InfoOverlay.Visible = false
    end)

    local function AddInfoIcon(parent, pos, data)
        if not data then return end
        local Btn = Create("TextButton", {Parent = parent, Text = "?", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Window.CurrentTheme.SubText, BackgroundColor3 = Window.CurrentTheme.Hover, Size = UDim2.new(0, 16, 0, 16), Position = pos, AutoButtonColor = false, ZIndex = 5})
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
        AddBounce(Btn)

        RegTheme(Btn, "TextColor3", "SubText")
        RegTheme(Btn, "BackgroundColor3", "Hover")

        Btn.MouseEnter:Connect(function() Tween(Btn, {TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Accent}, 0.2) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {TextColor3 = Window.CurrentTheme.SubText, BackgroundColor3 = Window.CurrentTheme.Hover}, 0.2) end)
        Btn.MouseButton1Click:Connect(function() OpenInfoWindow(data) end)
    end

    local MainFrame = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(0, 650, 0, 420), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, BackgroundTransparency = 1, Active = true})
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.8})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    local MainStroke = Create("UIStroke", {Parent = MainFrame, Color = Window.CurrentTheme.Border, Thickness = 1.5})
    
    RegTheme(MainFrame, "BackgroundColor3", "Background")
    RegTheme(MainStroke, "Color", "Border")

    Tween(MainScale, {Scale = 1}, 0.5)
    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)

    local BottomDragHitbox = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 350, 0, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 145,
        Active = true
    })

    local FloatingBottomBar = Create("Frame", {
        Parent = BottomDragHitbox,
        BackgroundColor3 = Window.CurrentTheme.Card,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        ZIndex = 146
    })
    Create("UICorner", {Parent = FloatingBottomBar, CornerRadius = UDim.new(0, 3)})
    local BottomBarStroke = Create("UIStroke", {
        Parent = FloatingBottomBar, 
        Color = Window.CurrentTheme.Border, 
        Thickness = 1.2, 
        Transparency = 0
    })

    RegTheme(FloatingBottomBar, "BackgroundColor3", "Card")
    RegTheme(BottomBarStroke, "Color", "Border")

    MakeDraggable(BottomDragHitbox, MainFrame)

    RunService.RenderStepped:Connect(function()
        if MainFrame and MainFrame.Visible then
            BottomDragHitbox.Visible = true
            local currentScale = MainScale.Scale
            local frameHeight = 420 * currentScale
            local frameWidth = 650 * currentScale
            
            BottomDragHitbox.Position = UDim2.new(
                MainFrame.Position.X.Scale,
                MainFrame.Position.X.Offset,
                MainFrame.Position.Y.Scale,
                MainFrame.Position.Y.Offset + (frameHeight / 2) + 20
            )
            BottomDragHitbox.Size = UDim2.new(0, frameWidth * 0.6, 0, 30 * currentScale)
            FloatingBottomBar.Size = UDim2.new(1, 0, 0, 6 * currentScale)
            FloatingBottomBar.Position = UDim2.new(0, 0, 0.5, -(3 * currentScale))
        else
            BottomDragHitbox.Visible = false
        end
    end)

    local TopBar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Window.CurrentTheme.Background, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 0), Active = true})
    MakeDraggable(TopBar, MainFrame)
    
    local titleOffsetX = 15
    if topbarLogo then
        Create("ImageLabel", {
            Parent = TopBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, logoSize, 0, logoSize),
            Position = UDim2.new(0, 8, 0.5, -(logoSize / 2)),
            Image = topbarLogo,
            ScaleType = Enum.ScaleType.Fit
        })
        titleOffsetX = 8 + logoSize + 8
    end

    local TitleContainer = Create("Frame", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, titleOffsetX, 0, 0)})
    local Title = Create("TextLabel", {Parent = TitleContainer, Text = hubName, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Window.CurrentTheme.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left})
    local Subtitle = Create("TextLabel", {Parent = TitleContainer, Text = subText, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left})

    RegTheme(Title, "TextColor3", "Text")
    RegTheme(Subtitle, "TextColor3", "SubText")

    local SearchBar = Create("Frame", {Parent = TopBar, BackgroundColor3 = Window.CurrentTheme.Card, Size = UDim2.new(0, 250, 0, 26), Position = UDim2.new(0, 180, 0.5, -13)})
    Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
    local SearchStroke = Create("UIStroke", {Parent = SearchBar, Color = Window.CurrentTheme.Border, Thickness = 1})
    local SearchIcon = Create("ImageLabel", {Parent = SearchBar, BackgroundTransparency = 1, Image = "rbxassetid://6031154871", ImageColor3 = Window.CurrentTheme.SubText, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7)})
    local SearchInput = Create("TextBox", {Parent = SearchBar, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, PlaceholderText = "Search..", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})

    RegTheme(SearchBar, "BackgroundColor3", "Card")
    RegTheme(SearchStroke, "Color", "Border")
    RegTheme(SearchIcon, "ImageColor3", "SubText")
    RegTheme(SearchInput, "TextColor3", "Text")

    local CloseBtn = Create("TextButton", {Parent = TopBar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -35, 0, 0)})
    local MinBtn = Create("TextButton", {Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -65, 0, 0)})

    RegTheme(CloseBtn, "TextColor3", "SubText")
    RegTheme(MinBtn, "TextColor3", "SubText")

    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Window.CurrentTheme.Background, BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40), Active = true})
    local TabSearchBox = Create("TextBox", {Parent = Sidebar, BackgroundColor3 = Window.CurrentTheme.Card, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 5), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, PlaceholderText = "Search tabs...", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    Create("UIPadding", {Parent = TabSearchBox, PaddingLeft = UDim.new(0, 8)})
    Create("UICorner", {Parent = TabSearchBox, CornerRadius = UDim.new(0, 6)})
    local TabSearchStroke = Create("UIStroke", {Parent = TabSearchBox, Color = Window.CurrentTheme.Border, Thickness = 1})

    RegTheme(TabSearchBox, "BackgroundColor3", "Card")
    RegTheme(TabSearchBox, "TextColor3", "Text")
    RegTheme(TabSearchStroke, "Color", "Border")

    local TabContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, -15, 1, -40), Position = UDim2.new(0, 10, 0, 40), ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local Divider = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Window.CurrentTheme.Border, BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -40), Position = UDim2.new(0, 160, 0, 40)})
    RegTheme(Divider, "BackgroundColor3", "Border")

    local ContentArea = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -165, 1, -40), Position = UDim2.new(0, 165, 0, 40), Active = true})

    local Sphere = Create("ImageButton", {Parent = ScreenGui, BackgroundColor3 = Window.CurrentTheme.Background, BackgroundTransparency = 0.2, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, AutoButtonColor = false, ImageTransparency = 1, ClipsDescendants = true})
    Create("UICorner", {Parent = Sphere, CornerRadius = UDim.new(0, 25)})
    local SphereStroke = Create("UIStroke", {Parent = Sphere, Color = Window.CurrentTheme.Border, Thickness = 2})

    RegTheme(Sphere, "BackgroundColor3", "Background")
    RegTheme(SphereStroke, "Color", "Border")

    local SphereImageLabel = Create("ImageLabel", {Parent = Sphere, BackgroundTransparency = 1, Size = UDim2.new(0, sphIconSize, 0, sphIconSize), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Image = sphImage or "", ImageTransparency = 1, Visible = (not sphTextToggle and sphImage ~= nil)})
    local SphereTextLabel = Create("TextLabel", {Parent = Sphere, Text = sphWords, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Window.CurrentTheme.Accent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextTransparency = 1, Visible = sphTextToggle})
    RegTheme(SphereTextLabel, "TextColor3", "Accent")
    MakeDraggable(Sphere, Sphere)

    function Window:SetTransparency(val)
        Window.CurrentTransparency = val
        if MainFrame.Visible then
            Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
            Tween(FloatingBottomBar, {BackgroundTransparency = val > 0 and 0.2 or 0}, 0.3)
        end
    end

    MinBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0}, 0.4)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.4)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.4)
        Tween(BottomBarStroke, {Transparency = 1}, 0.4)
        task.wait(0.3)
        MainFrame.Visible = false
        BottomDragHitbox.Visible = false
        Sphere.Visible = true
        Tween(Sphere, {Size = UDim2.new(0, 50, 0, 50)}, 0.4)
        
        if not sphTextToggle and sphImage then
            Tween(SphereImageLabel, {ImageTransparency = 0}, 0.4)
        elseif sphTextToggle then
            Tween(SphereTextLabel, {TextTransparency = 0}, 0.4)
        end
    end)

    Sphere.MouseButton1Click:Connect(function()
        Tween(Sphere, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        if not sphTextToggle and sphImage then Tween(SphereImageLabel, {ImageTransparency = 1}, 0.3) end
        if sphTextToggle then Tween(SphereTextLabel, {TextTransparency = 1}, 0.3) end
        
        task.wait(0.2)
        Sphere.Visible = false
        MainFrame.Visible = true
        BottomDragHitbox.Visible = true
        Tween(MainScale, {Scale = 1}, 0.4)
        Tween(MainFrame, {BackgroundTransparency = Window.CurrentTransparency}, 0.4)
        Tween(FloatingBottomBar, {BackgroundTransparency = Window.CurrentTransparency > 0 and 0.2 or 0}, 0.4)
        Tween(BottomBarStroke, {Transparency = 0}, 0.4)
    end)

    local Popup = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 100, Visible = false, Active = true})
    local PopupCard = Create("Frame", {Parent = Popup, BackgroundColor3 = Window.CurrentTheme.Card, Size = UDim2.new(0, 320, 0, 160), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 101, BackgroundTransparency = 1, ClipsDescendants = false})
    Create("UICorner", {Parent = PopupCard, CornerRadius = UDim.new(0, 8)})
    local PopupScale = Create("UIScale", {Parent = PopupCard, Scale = 0.8})
    local PopupStroke = Create("UIStroke", {Parent = PopupCard, Color = Window.CurrentTheme.Border, Thickness = 1, Transparency = 1})
    local PopupTitle = Create("TextLabel", {Parent = PopupCard, Text = "Exit Application", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Window.CurrentTheme.Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 25), ZIndex = 102, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center})
    local PopupText = Create("TextLabel", {Parent = PopupCard, Text = "Are you sure you want to close SpectraHub? Unsaved configurations might be lost.", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 55), ZIndex = 102, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true})
    local YesBtn = Create("TextButton", {Parent = PopupCard, Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Window.CurrentTheme.Accent, Size = UDim2.new(0, 125, 0, 36), Position = UDim2.new(0.5, 10, 0, 105), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
    Create("UICorner", {Parent = YesBtn, CornerRadius = UDim.new(0, 6)})
    AddBounce(YesBtn)
    local NoBtn = Create("TextButton", {Parent = PopupCard, Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Hover, Size = UDim2.new(0, 125, 0, 36), Position = UDim2.new(0.5, -135, 0, 105), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
    Create("UICorner", {Parent = NoBtn, CornerRadius = UDim.new(0, 6)})
    AddBounce(NoBtn)

    RegTheme(PopupCard, "BackgroundColor3", "Card")
    RegTheme(PopupStroke, "Color", "Border")
    RegTheme(PopupTitle, "TextColor3", "Text")
    RegTheme(PopupText, "TextColor3", "SubText")
    RegTheme(YesBtn, "BackgroundColor3", "Accent")
    RegTheme(NoBtn, "BackgroundColor3", "Hover")
    RegTheme(NoBtn, "TextColor3", "Text")

    CloseBtn.MouseButton1Click:Connect(function()
        Popup.Visible = true
        Tween(Popup, {BackgroundTransparency = 0.5}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 0}, 0.3)
        Tween(PopupScale, {Scale = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 0}, 0.3)
        Tween(PopupTitle, {TextTransparency = 0}, 0.3)
        Tween(PopupText, {TextTransparency = 0}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
    end)

    YesBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(MainScale, {Scale = 0.8}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.3)
        Tween(BottomBarStroke, {Transparency = 1}, 0.3)

        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then Tween(desc, {TextTransparency = 1}, 0.3) if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then Tween(desc, {ImageTransparency = 1}, 0.3)
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("UIStroke") then Tween(desc, {Transparency = 1}, 0.3) end
        end
        task.wait(0.35)
        ScreenGui:Destroy()
    end)

    NoBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupScale, {Scale = 0.8}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        task.wait(0.3)
        Popup.Visible = false
    end)

    TabSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = TabSearchBox.Text:lower()
        for _, tabInfo in ipairs(Window.Tabs) do
            if query == "" or string.find(tabInfo.Txt.Text:lower(), query) then
                tabInfo.Button.Visible = true
            else
                tabInfo.Button.Visible = false
            end
        end
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        if query == "" then
            for _, data in ipairs(Window.AllCards) do
                data.Card.Parent = data.OrigParent
                data.Card.Visible = true
            end
        else
            if not Window.CurrentTab or not Window.CurrentTab.CurrentPage then return end
            local activeLeft = Window.CurrentTab.CurrentPage.LeftCol
            local activeRight = Window.CurrentTab.CurrentPage.RightCol
            local placeLeft = true
            
            for _, data in ipairs(Window.AllCards) do
                local card = data.Card
                if data.Tab == Window.CurrentTab then
                    if not data.SearchIndex then
                        data.SearchIndex = BuildSearchIndex(card)
                    end
                    local match = string.find(data.SearchIndex, query, 1, true)
                    if match then
                        card.Parent = placeLeft and activeLeft or activeRight
                        placeLeft = not placeLeft
                        card.Visible = true
                    else
                        card.Visible = false
                    end
                else
                    card.Parent = data.OrigParent
                    card.Visible = true
                end
            end
        end
    end)

    function Window:CreateTab(tabName, isDefault, isLocked)
        local isWhitelisted = false
        local player = game:GetService("Players").LocalPlayer
        if player then
            for _, allowedUser in ipairs(Library.WhitelistedUsers) do
                if player.Name == allowedUser or player.DisplayName == allowedUser then
                    isWhitelisted = true
                    break
                end
            end
        end

        local TabBtn = Create("TextButton", {Parent = TabContainer, Text = "", BackgroundColor3 = Window.CurrentTheme.Hover, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false})
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        AddBounce(TabBtn, 0.98)
        local Indicator = Create("Frame", {
            Name = "Indicator", 
            Parent = TabBtn, 
            BackgroundColor3 = isLocked and Color3.fromRGB(255, 215, 0) or Window.CurrentTheme.Accent, 
            Size = UDim2.new(0, 3, 0, 0), 
            Position = UDim2.new(0, 0, 0.5, 0), 
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0 
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        local Txt = Create("TextLabel", {Parent = TabBtn, Text = tabName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})

        local TabConfig = {Button = TabBtn, Content = nil, Indicator = Indicator, Txt = Txt, Pages = {}, CurrentPage = nil}

        RegTheme(TabBtn, "BackgroundColor3", "Hover", function(t) return Window.CurrentTab == TabConfig and t.Hover or t.Background end)
        RegTheme(Indicator, "BackgroundColor3", "Accent", function(t) return isLocked and Color3.fromRGB(255, 215, 0) or t.Accent end)
        RegTheme(Txt, "TextColor3", "Text", function(t) return Window.CurrentTab == TabConfig and t.Text or t.SubText end)

        if isLocked then
            Create("ImageLabel", {Parent = TabBtn, Image = "rbxassetid://6031082533", ImageColor3 = Color3.fromRGB(255, 215, 0), BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7)})
        end

        local TabContent = Create("Frame", {Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        TabConfig.Content = TabContent
        local PageNav = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
        Create("UIListLayout", {Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 15), VerticalAlignment = Enum.VerticalAlignment.Center})
        local PageContainer = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35)})

        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then
                SendPremiumNotification()
                return
            end

            if Window.CurrentTab == TabConfig then return end
            
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Tween(Window.CurrentTab.Txt, {TextColor3 = Window.CurrentTheme.SubText}, 0.2)
                Window.CurrentTab.Content.Visible = false
            end
            
            Window.CurrentTab = TabConfig
            TabConfig.Content.Visible = true
            
            TabConfig.Content.Position = UDim2.new(0, 0, 0, 15)
            Tween(TabConfig.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)

            Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 18)}, 0.3)
            Tween(Txt, {TextColor3 = Window.CurrentTheme.Text}, 0.2)

            if #TabConfig.Pages > 0 then
                local firstPage = TabConfig.Pages[1]
                if TabConfig.CurrentPage ~= firstPage then
                    if TabConfig.CurrentPage then
                        Tween(TabConfig.CurrentPage.Btn, {TextColor3 = Window.CurrentTheme.SubText}, 0)
                        Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0)
                        TabConfig.CurrentPage.Scroll.Visible = false
                    end
                    TabConfig.CurrentPage = firstPage
                    firstPage.Scroll.Visible = true
                    
                    firstPage.Scroll.Position = UDim2.new(0, 5, 0, 15)
                    Tween(firstPage.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)

                    Tween(firstPage.Btn, {TextColor3 = Window.CurrentTheme.Text}, 0)
                    Tween(firstPage.Highlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0)
                end
            end
        end)

        function TabConfig:CreatePage(pageName)
            local PageBtn = Create("TextButton", {Parent = PageNav, Text = pageName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
            local PageHighlight = Create("Frame", {Parent = PageBtn, BackgroundColor3 = Window.CurrentTheme.Accent, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1})
            local PageScroll = Create("ScrollingFrame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 2, ScrollBarImageColor3 = Window.CurrentTheme.SubText, Visible = false, BorderSizePixel = 0})

            local PageObj = {Scroll = PageScroll, Btn = PageBtn, Highlight = PageHighlight, Left = true, LeftCol = nil, RightCol = nil}

            RegTheme(PageBtn, "TextColor3", "Text", function(t) return TabConfig.CurrentPage == PageObj and t.Text or t.SubText end)
            RegTheme(PageHighlight, "BackgroundColor3", "Accent")
            RegTheme(PageScroll, "ScrollBarImageColor3", "SubText")

            local LeftColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0)})
            local RightColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)})
            PageObj.LeftCol = LeftColumn
            PageObj.RightCol = RightColumn

            local L_Layout = Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            local R_Layout = Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            
            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)
            R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)

            table.insert(TabConfig.Pages, PageObj)

            PageBtn.MouseButton1Click:Connect(function()
                if TabConfig.CurrentPage == PageObj then return end
                if TabConfig.CurrentPage then
                    Tween(TabConfig.CurrentPage.Btn, {TextColor3 = Window.CurrentTheme.SubText}, 0.2)
                    Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                    TabConfig.CurrentPage.Scroll.Visible = false
                end
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                
                PageObj.Scroll.Position = UDim2.new(0, 5, 0, 20)
                Tween(PageObj.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)

                Tween(PageBtn, {TextColor3 = Window.CurrentTheme.Text}, 0.2)
                Tween(PageHighlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.3)
            end)

            if #TabConfig.Pages == 1 and not isLocked then
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageBtn.TextColor3 = Window.CurrentTheme.Text
                PageHighlight.Size = UDim2.new(1, 0, 0, 2)
                PageHighlight.BackgroundTransparency = 0
            end

            function PageObj:CreateSection(sectionName)
                local targetColumn = PageObj.Left and LeftColumn or RightColumn
                PageObj.Left = not PageObj.Left

                local SectionContainer = Create("Frame", {Parent = targetColumn, BackgroundColor3 = Window.CurrentTheme.Card, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 8)})
                local SecStroke = Create("UIStroke", {Parent = SectionContainer, Color = Window.CurrentTheme.Border, Thickness = 1})
                
                RegTheme(SectionContainer, "BackgroundColor3", "Card")
                RegTheme(SecStroke, "Color", "Border")

                table.insert(Window.AllCards, {
                    Card = SectionContainer,
                    OrigParent = targetColumn,
                    Tab = TabConfig,
                    Page = PageObj,
                    SearchIndex = nil 
                })
                
                local Title = Create("TextLabel", {Parent = SectionContainer, Text = sectionName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Window.CurrentTheme.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                RegTheme(Title, "TextColor3", "Text")

                local ItemContainer = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
                Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
                Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

                local Elements = {}

                function Elements:AddCopyButton(name, copyText, infoData)
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
                    local BtnStroke = Create("UIStroke", {Parent = Btn, Color = Window.CurrentTheme.Border, Thickness = 1})

                    RegTheme(Btn, "BackgroundColor3", "Background")
                    RegTheme(Btn, "TextColor3", "Text")
                    RegTheme(BtnStroke, "Color", "Border")

                    AddBounce(Btn)
                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Window.CurrentTheme.Hover}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Window.CurrentTheme.Background}, 0.2) end)
                    
                    Btn.MouseButton1Click:Connect(function()
                        SafeCopyToClipboard(copyText)
                        local oldText = Btn.Text
                        Btn.Text = "Copied to Clipboard!"
                        Tween(Btn, {TextColor3 = Window.CurrentTheme.Accent, BackgroundColor3 = Window.CurrentTheme.Hover}, 0.2)
                        task.wait(1.5)
                        if Btn.Parent then
                            Btn.Text = oldText
                            Tween(Btn, {TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Background}, 0.2)
                        end
                    end)
                    AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
                end

                function Elements:AddButton(name, callback, infoData)
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
                    local BtnStroke = Create("UIStroke", {Parent = Btn, Color = Window.CurrentTheme.Border, Thickness = 1})

                    RegTheme(Btn, "BackgroundColor3", "Background")
                    RegTheme(Btn, "TextColor3", "Text")
                    RegTheme(BtnStroke, "Color", "Border")

                    AddBounce(Btn)
                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Window.CurrentTheme.Hover}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Window.CurrentTheme.Background}, 0.2) end)
                    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)

                    AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
                end

                function Elements:AddToggle(name, default, callback, infoData)
                    local state = default or false
                    local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    
                    local TogLabel = Create("TextLabel", {Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    RegTheme(TogLabel, "TextColor3", "SubText")

                    local Lever = Create("TextButton", {Parent = TogFrame, Text = "", BackgroundColor3 = state and Window.CurrentTheme.Accent or Window.CurrentTheme.Hover, Size = UDim2.new(0, 28, 0, 16), Position = UDim2.new(1, -38, 0.5, -8), AutoButtonColor = false})
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    local LeverStroke = Create("UIStroke", {Parent = Lever, Color = Window.CurrentTheme.Border, Thickness = 1})
                    AddBounce(Lever)

                    RegTheme(Lever, "BackgroundColor3", "Accent", function(t) return state and t.Accent or t.Hover end)
                    RegTheme(LeverStroke, "Color", "Border")
                    
                    local Knob = Create("Frame", {Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 12, 0, 12), Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), BorderSizePixel = 0})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = Knob, Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Transparency = 0.8})

                    local function internalSet(val)
                        state = val
                        Tween(Lever, {BackgroundColor3 = state and Window.CurrentTheme.Accent or Window.CurrentTheme.Hover}, 0.25)
                        Tween(Knob, {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.25)
                        if callback then callback(state) end
                    end

                    Lever.MouseButton1Click:Connect(function() internalSet(not state) end)
                    AddInfoIcon(TogFrame, UDim2.new(1, -62, 0.5, -8), infoData)
                    
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return state end }
                end

                function Elements:AddSlider(name, min, max, default, callback, infoData)
                    local val = default or min
                    local SliFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
                    
                    local SliLabel = Create("TextLabel", {Parent = SliFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local ValTxt = Create("TextLabel", {Parent = SliFrame, Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 15), Position = UDim2.new(1, -40, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
                    
                    RegTheme(SliLabel, "TextColor3", "SubText")
                    RegTheme(ValTxt, "TextColor3", "Text")

                    local TrackBase = Create("Frame", {Parent = SliFrame, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 25)})
                    Create("UICorner", {Parent = TrackBase, CornerRadius = UDim.new(0, 3)})
                    local TrackStroke = Create("UIStroke", {Parent = TrackBase, Color = Window.CurrentTheme.Border, Thickness = 1})

                    RegTheme(TrackBase, "BackgroundColor3", "Background")
                    RegTheme(TrackStroke, "Color", "Border")

                    local Fill = Create("Frame", {Parent = TrackBase, BackgroundColor3 = Window.CurrentTheme.Accent, Size = UDim2.new((val-min)/(max-min), 0, 1, 0)})
                    Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 3)})
                    local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(0, 6)})

                    RegTheme(Fill, "BackgroundColor3", "Accent")

                    local function internalSet(v)
                        val = math.clamp(v, min, max)
                        ValTxt.Text = tostring(val)
                        Tween(Fill, {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}, 0.1)
                        if callback then callback(val) end
                    end

                    local dragging = false
                    local function Update(input)
                        local pos = math.clamp((input.Position.X - TrackBase.AbsolutePosition.X) / TrackBase.AbsoluteSize.X, 0, 1)
                        internalSet(math.floor(min + ((max - min) * pos)))
                    end

                    Knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
                    AddInfoIcon(SliFrame, UDim2.new(1, -65, 0, 0), infoData)

                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return val end }
                end

                function Elements:AddDropdown(name, options, isMulti, callback, infoData)
                    local selected = isMulti and {} or (options[1] or nil)
                    local dropped = false
                    local optionButtons = {}
                    local maxVisible = math.min(#options, 3)
                    local listHeight = maxVisible * 25
                    
                    local DropFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), ClipsDescendants = true})
                    local DropLabel = Create("TextLabel", {Parent = DropFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    RegTheme(DropLabel, "TextColor3", "SubText")

                    local MainBtn = Create("TextButton", {Parent = DropFrame, Text = isMulti and "Select Options..." or "Select...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left})
                    Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 6)})
                    local MainBtnStroke = Create("UIStroke", {Parent = MainBtn, Color = Window.CurrentTheme.Border, Thickness = 1})
                    AddBounce(MainBtn, 0.98)

                    RegTheme(MainBtn, "BackgroundColor3", "Background")
                    RegTheme(MainBtn, "TextColor3", "Text")
                    RegTheme(MainBtnStroke, "Color", "Border")

                    local Arrow = Create("TextLabel", {Parent = MainBtn, Text = "▼", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -28, 0, 0)})
                    RegTheme(Arrow, "TextColor3", "SubText")

                    local SearchBox = Create("TextBox", {Parent = DropFrame, PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Hover, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false})
                    Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 6)})
                    local SearchBoxStroke = Create("UIStroke", {Parent = SearchBox, Color = Window.CurrentTheme.Border, Thickness = 1})

                    RegTheme(SearchBox, "BackgroundColor3", "Hover")
                    RegTheme(SearchBox, "TextColor3", "Text")
                    RegTheme(SearchBoxStroke, "Color", "Border")

                    local ListFrame = Create("ScrollingFrame", {Parent = DropFrame, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 0, listHeight), Position = UDim2.new(0, 10, 0, 78), CanvasSize = UDim2.new(0, 0, 0, #options * 25), ScrollBarThickness = 2, ScrollBarImageColor3 = Window.CurrentTheme.SubText, BorderSizePixel = 0})
                    Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 6)})
                    local ListFrameStroke = Create("UIStroke", {Parent = ListFrame, Color = Window.CurrentTheme.Border, Thickness = 1})
                    local DList = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

                    RegTheme(ListFrame, "BackgroundColor3", "Background")
                    RegTheme(ListFrameStroke, "Color", "Border")

                    local function UpdateText()
                        if isMulti then
                            local txt = ""
                            for _, v in pairs(selected) do txt = txt .. v .. ", " end
                            MainBtn.Text = txt == "" and "Select Options..." or txt:sub(1, -3)
                        else
                            MainBtn.Text = selected or "Select..."
                        end
                    end

                    local function internalSet(v)
                        selected = v
                        UpdateText()
                        for _, btn in ipairs(optionButtons) do
                            local isSel = isMulti and (table.find(selected, btn.Text) ~= nil) or (selected == btn.Text)
                            Tween(btn, {TextColor3 = isSel and Window.CurrentTheme.Text or Window.CurrentTheme.SubText}, 0.2)
                            Tween(btn:FindFirstChild("Frame"), {Size = isSel and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)}, 0.2)
                        end
                        if callback then callback(selected) end
                    end

                    for _, opt in pairs(options) do
                        local isInitialSelected = (not isMulti and selected == opt)
                        local OptBtn = Create("TextButton", {Parent = ListFrame, Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = isInitialSelected and Window.CurrentTheme.Text or Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), AutoButtonColor = false})
                        local Check = Create("Frame", {Parent = OptBtn, BackgroundColor3 = Window.CurrentTheme.Accent, Size = isInitialSelected and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.8})
                        table.insert(optionButtons, OptBtn)
                        
                        RegTheme(OptBtn, "TextColor3", "Text", function(t)
                            local isSel = isMulti and (table.find(selected, opt) ~= nil) or (selected == opt)
                            return isSel and t.Text or t.SubText
                        end)
                        RegTheme(Check, "BackgroundColor3", "Accent")

                        OptBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                if table.find(selected, opt) then
                                    table.remove(selected, table.find(selected, opt))
                                else
                                    table.insert(selected, opt)
                                end
                                internalSet(selected)
                            else
                                internalSet(opt)
                                dropped = false
                                Tween(Arrow, {Rotation = 0}, 0.3)
                                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                                SearchBox.Visible = false
                            end
                        end)
                    end
                    UpdateText()

                    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local q = SearchBox.Text:lower()
                        for _, btn in ipairs(optionButtons) do
                            btn.Visible = (q == "" or string.find(btn.Text:lower(), q) ~= nil)
                        end
                    end)

                    DList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        ListFrame.CanvasSize = UDim2.new(0, 0, 0, DList.AbsoluteContentSize.Y)
                        if dropped then
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, listHeight)
                            local newOpenHeight = 50 + 32 + dynamicHeight
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newOpenHeight)}, 0.1)
                        end
                    end)

                    MainBtn.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        if dropped then
                            SearchBox.Visible = true
                            SearchBox.Text = ""
                            Tween(Arrow, {Rotation = 180}, 0.3)
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, listHeight)
                            local newOpenHeight = 50 + 32 + dynamicHeight
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newOpenHeight)}, 0.3)
                        else
                            SearchBox.Visible = false
                            Tween(Arrow, {Rotation = 0}, 0.3)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                        end
                    end)
                    AddInfoIcon(DropFrame, UDim2.new(1, -25, 0, 0), infoData)

                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return selected end }
                end

                function Elements:AddTextbox(name, placeholder, callback, infoData)
                    local TxtFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
                    local TxtLabel = Create("TextLabel", {Parent = TxtFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local Input = Create("TextBox", {Parent = TxtFrame, PlaceholderText = placeholder or "Type here...", Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.Text, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                    Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 6)})
                    local InputStroke = Create("UIStroke", {Parent = Input, Color = Window.CurrentTheme.Border, Thickness = 1})

                    RegTheme(TxtLabel, "TextColor3", "SubText")
                    RegTheme(Input, "BackgroundColor3", "Background")
                    RegTheme(Input, "TextColor3", "Text")
                    RegTheme(InputStroke, "Color", "Border")

                    local function internalSet(v)
                        Input.Text = tostring(v)
                        if callback then callback(v) end
                    end

                    Input.FocusLost:Connect(function() internalSet(Input.Text) end)
                    AddInfoIcon(TxtFrame, UDim2.new(1, -25, 0, 0), infoData)
                    
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return Input.Text end }
                end

                function Elements:AddColorPicker(name, defaultColor, callback, infoData)
                    local color = defaultColor or Color3.fromRGB(255, 255, 255)
                    local h, s, v_hsv = color:ToHSV()
                    local dropped = false
                    
                    local CFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true})
                    local CLabel = Create("TextLabel", {Parent = CFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Window.CurrentTheme.SubText, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local DisplayBtn = Create("TextButton", {Parent = CFrame, Text = "", BackgroundColor3 = color, Size = UDim2.new(0, 30, 0, 16), Position = UDim2.new(1, -40, 0.5, -8), AutoButtonColor = false})
                    Create("UICorner", {Parent = DisplayBtn, CornerRadius = UDim.new(0, 6)})
                    local DisplayBtnStroke = Create("UIStroke", {Parent = DisplayBtn, Color = Window.CurrentTheme.Border, Thickness = 1})
                    AddBounce(DisplayBtn)

                    RegTheme(CLabel, "TextColor3", "SubText")
                    RegTheme(DisplayBtnStroke, "Color", "Border")

                    local PickerArea = Create("Frame", {Parent = CFrame, BackgroundColor3 = Window.CurrentTheme.Background, Size = UDim2.new(1, -20, 0, 140), Position = UDim2.new(0, 10, 0, 35)})
                    Create("UICorner", {Parent = PickerArea, CornerRadius = UDim.new(0, 6)})
                    local PickerAreaStroke = Create("UIStroke", {Parent = PickerArea, Color = Window.CurrentTheme.Border, Thickness = 1})

                    RegTheme(PickerArea, "BackgroundColor3", "Background")
                    RegTheme(PickerAreaStroke, "Color", "Border")

                    local PickerClose = Create("TextButton", {Parent = PickerArea, Text = "X", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Window.CurrentTheme.SubText, BackgroundColor3 = Window.CurrentTheme.Hover, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -22, 0, 4), ZIndex = 50, AutoButtonColor = false})
                    Create("UICorner", {Parent = PickerClose, CornerRadius = UDim.new(0, 4)})
                    local PickerCloseStroke = Create("UIStroke", {Parent = PickerClose, Color = Window.CurrentTheme.Border, Thickness = 1})
                    AddBounce(PickerClose)

                    RegTheme(PickerClose, "BackgroundColor3", "Hover")
                    RegTheme(PickerClose, "TextColor3", "SubText")
                    RegTheme(PickerCloseStroke, "Color", "Border")
                    
                    PickerClose.MouseEnter:Connect(function() Tween(PickerClose, {TextColor3 = Color3.fromRGB(255, 60, 60)}, 0.2) end)
                    PickerClose.MouseLeave:Connect(function() Tween(PickerClose, {TextColor3 = Window.CurrentTheme.SubText}, 0.2) end)
                    PickerClose.MouseButton1Click:Connect(function() dropped = false Tween(CFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.3) end)

                    local SVMap = Create("TextButton", {Parent = PickerArea, Text = "", BackgroundColor3 = Color3.fromHSV(h, 1, 1), Size = UDim2.new(1, -45, 0, 90), Position = UDim2.new(0, 10, 0, 10), AutoButtonColor = false, Active = true})
                    Create("UICorner", {Parent = SVMap, CornerRadius = UDim.new(0, 6)})
                    local SVMapStroke = Create("UIStroke", {Parent = SVMap, Color = Window.CurrentTheme.Border, Thickness = 1})
                    RegTheme(SVMapStroke, "Color", "Border")

                    local WhiteGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 2})
                    Create("UIGradient", {Parent = WhiteGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Rotation = 0})
                    Create("UICorner", {Parent = WhiteGrad, CornerRadius = UDim.new(0, 6)})

                    local BlackGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), ZIndex = 3})
                    Create("UIGradient", {Parent = BlackGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Rotation = 90})
                    Create("UICorner", {Parent = BlackGrad, CornerRadius =Sou um modelo de linguagem. Isso está além das minhas habiliades.
