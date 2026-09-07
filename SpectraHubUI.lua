local SpectraHub = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(topbar, frame)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function SpectraHub:Create(options)
    local WindowSettings = {
        Title = options.Title or "SpectraHub",
        CloseConfirmation = options.CloseConfirmation or false,
        Notifications = true,
        Transparency = options.Transparency or 0,
        Theme = options.Theme or {
            Background = Color3.fromRGB(20, 20, 20),
            Topbar = Color3.fromRGB(30, 30, 30),
            Sidebar = Color3.fromRGB(25, 25, 25),
            Accent = Color3.fromRGB(123, 44, 191),
            Text = Color3.fromRGB(255, 255, 255),
            Element = Color3.fromRGB(35, 35, 35),
            Hover = Color3.fromRGB(45, 45, 45)
        }
    }

    local SpectraUI = Create("ScreenGui", {
        Name = "SpectraHub",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local parentUi = game:GetService("CoreGui")
    local success = pcall(function() SpectraUI.Parent = parentUi end)
    if not success then
        SpectraUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = SpectraUI,
        BackgroundColor3 = WindowSettings.Theme.Background,
        BackgroundTransparency = WindowSettings.Transparency,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = WindowSettings.Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 40)
    })
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 8)})
    Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = WindowSettings.Theme.Topbar,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BorderSizePixel = 0
    })

    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = WindowSettings.Title,
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    MakeDraggable(Topbar, MainFrame)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = WindowSettings.Theme.Sidebar,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40),
        BorderSizePixel = 0
    })

    local CategoryLayout = Create("UIListLayout", {
        Parent = Sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    Create("UIPadding", {
        Parent = Sidebar,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40)
    })

    local MinimizedIcon = Create("ImageButton", {
        Name = "MinimizedIcon",
        Parent = SpectraUI,
        BackgroundColor3 = WindowSettings.Theme.Accent,
        Position = UDim2.new(0.5, -25, 0.5, -25),
        Size = UDim2.new(0, 50, 0, 50),
        Visible = false,
        AutoButtonColor = false
    })
    Create("UICorner", {Parent = MinimizedIcon, CornerRadius = UDim.new(1, 0)})
    MakeDraggable(MinimizedIcon, MinimizedIcon)

    local NotifContainer = Create("Frame", {
        Name = "NotificationContainer",
        Parent = SpectraUI,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(0, 1)
    })
    Create("UIListLayout", {
        Parent = NotifContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    local Controls = Create("Frame", {
        Name = "Controls",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 70, 1, 0)
    })

    local SearchBox = Create("TextBox", {
        Parent = Topbar,
        BackgroundColor3 = WindowSettings.Theme.Element,
        Position = UDim2.new(1, -230, 0.5, -12),
        Size = UDim2.new(0, 150, 0, 24),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 12
    })
    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})

    local MinimizeBtn = Create("TextButton", {
        Parent = Controls,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 20
    })

    local CloseBtn = Create("TextButton", {
        Parent = Controls,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 80, 80),
        TextSize = 16
    })

    local ConfirmationModal = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 100
    })
    local ConfirmBox = Create("Frame", {
        Parent = ConfirmationModal,
        BackgroundColor3 = WindowSettings.Theme.Topbar,
        Position = UDim2.new(0.5, -100, 0.5, -50),
        Size = UDim2.new(0, 200, 0, 100),
        ZIndex = 101
    })
    Create("UICorner", {Parent = ConfirmBox, CornerRadius = UDim.new(0, 8)})
    Create("TextLabel", {
        Parent = ConfirmBox,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "Close Hub?",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 14,
        ZIndex = 102
    })
    local ConfirmYes = Create("TextButton", {
        Parent = ConfirmBox,
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(0, 85, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "Yes",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        ZIndex = 102
    })
    Create("UICorner", {Parent = ConfirmYes, CornerRadius = UDim.new(0, 4)})
    local ConfirmNo = Create("TextButton", {
        Parent = ConfirmBox,
        BackgroundColor3 = WindowSettings.Theme.Element,
        Position = UDim2.new(0, 105, 0, 60),
        Size = UDim2.new(0, 85, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "No",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 12,
        ZIndex = 102
    })
    Create("UICorner", {Parent = ConfirmNo, CornerRadius = UDim.new(0, 4)})

    ConfirmYes.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        SpectraUI:Destroy()
    end)
    ConfirmNo.MouseButton1Click:Connect(function()
        ConfirmationModal.Visible = false
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        if WindowSettings.CloseConfirmation then
            ConfirmationModal.Visible = true
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            task.wait(0.3)
            SpectraUI:Destroy()
        end
    end)

    local function ToggleMinimize()
        if MainFrame.Visible then
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            task.wait(0.3)
            MainFrame.Visible = false
            MinimizedIcon.Visible = true
            Tween(MinimizedIcon, {Size = UDim2.new(0, 50, 0, 50)}, 0.2)
        else
            Tween(MinimizedIcon, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            MinimizedIcon.Visible = false
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.3)
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
    MinimizedIcon.MouseButton1Click:Connect(ToggleMinimize)

    local ElementsRegistry = {}

    SearchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            local text = SearchBox.Text:lower()
            for _, item in pairs(ElementsRegistry) do
                if item.Category.Searchable then
                    if text == "" then
                        item.Instance.Visible = true
                        item.Label.Text = item.RawText
                    else
                        if item.RawText:lower():find(text) then
                            item.Instance.Visible = true
                            local highlighted = item.RawText:gsub("(?i)(" .. text .. ")", '<font color="#ffff00">%1</font>')
                            item.Label.RichText = true
                            item.Label.Text = highlighted
                        else
                            item.Instance.Visible = false
                        end
                    end
                end
            end
        end
    end)

    local GUI = {}
    local CurrentCategory = nil

    function GUI:ToggleNotifications(state)
        WindowSettings.Notifications = state
    end

    function GUI:Notify(title, message, duration)
        if not WindowSettings.Notifications then return end
        duration = duration or 3
        local notif = Create("Frame", {
            Parent = NotifContainer,
            BackgroundColor3 = WindowSettings.Theme.Topbar,
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(1, 300, 0, 0)
        })
        Create("UICorner", {Parent = notif, CornerRadius = UDim.new(0, 6)})
        
        Create("Frame", {
            Parent = notif,
            BackgroundColor3 = WindowSettings.Theme.Accent,
            Size = UDim2.new(0, 4, 1, 0),
            BorderSizePixel = 0
        })

        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = WindowSettings.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 25),
            Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.Gotham,
            Text = message,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })

        Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(duration)
        local out = Tween(notif, {Position = UDim2.new(1, 300, 0, 0)}, 0.3)
        out.Completed:Connect(function() notif:Destroy() end)
    end

    function GUI:CreateCategory(name, options)
        options = options or {}
        local whitelist = options.Whitelist
        if whitelist then
            local allowed = false
            for _, id in pairs(whitelist) do
                if LocalPlayer.UserId == id then
                    allowed = true
                    break
                end
            end
            if not allowed then return nil end
        end

        local CategoryObj = {
            Name = name,
            Searchable = options.Searchable ~= false
        }

        local CatBtn = Create("TextButton", {
            Parent = Sidebar,
            BackgroundColor3 = WindowSettings.Theme.Element,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = WindowSettings.Theme.Text,
            TextSize = 14,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = CatBtn, CornerRadius = UDim.new(0, 4)})

        local PageContainer = Create("ScrollingFrame", {
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            Visible = false
        })
        Create("UIPadding", {
            Parent = PageContainer,
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        local PageLayout = Create("UIListLayout", {
            Parent = PageContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageContainer.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        CatBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = WindowSettings.Theme.Element}, 0.2)
                end
            end
            Tween(CatBtn, {BackgroundColor3 = WindowSettings.Theme.Accent}, 0.2)
            PageContainer.Visible = true
        end)

        if not CurrentCategory then
            CurrentCategory = CategoryObj
            PageContainer.Visible = true
            CatBtn.BackgroundColor3 = WindowSettings.Theme.Accent
        end

        function CategoryObj:CreatePage(pageName)
            local PageObj = {}
            local SectionLabel = Create("TextLabel", {
                Parent = PageContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = pageName,
                TextColor3 = WindowSettings.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            function PageObj:CreateButton(btnOpts)
                local btn = Create("TextButton", {
                    Parent = PageContainer,
                    BackgroundColor3 = btnOpts.Color or WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = btnOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
                
                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = btn,
                    Label = btn,
                    RawText = btnOpts.Text
                })

                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = WindowSettings.Theme.Hover}, 0.2) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = btnOpts.Color or WindowSettings.Theme.Element}, 0.2) end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, {Size = UDim2.new(1, -4, 0, 31)}, 0.1).Completed:Connect(function()
                        Tween(btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                    end)
                    if btnOpts.Callback then btnOpts.Callback() end
                    if btnOpts.Notify then GUI:Notify("Button Clicked", btnOpts.Text) end
                end)
            end

            function PageObj:CreateToggle(tglOpts)
                local state = tglOpts.Default or false
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 6)})
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = tglOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local switch = Create("Frame", {
                    Parent = frame,
                    BackgroundColor3 = state and WindowSettings.Theme.Accent or Color3.fromRGB(60, 60, 60),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.new(0, 35, 0, 20)
                })
                Create("UICorner", {Parent = switch, CornerRadius = UDim.new(1, 0)})
                local circle = Create("Frame", {
                    Parent = switch,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, state and 17 or 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                Create("UICorner", {Parent = circle, CornerRadius = UDim.new(1, 0)})
                local btn = Create("TextButton", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = frame,
                    Label = lbl,
                    RawText = tglOpts.Text
                })

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(switch, {BackgroundColor3 = state and WindowSettings.Theme.Accent or Color3.fromRGB(60, 60, 60)}, 0.2)
                    Tween(circle, {Position = UDim2.new(0, state and 17 or 2, 0.5, -8)}, 0.2)
                    if tglOpts.Callback then tglOpts.Callback(state) end
                    if tglOpts.Notify then GUI:Notify("Toggle Changed", tglOpts.Text .. " is now " .. tostring(state)) end
                end)
            end

            function PageObj:CreateSlider(sldOpts)
                local val = sldOpts.Default or sldOpts.Min
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 6)})
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sldOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local valLbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 5),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(val),
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                local bg = Create("Frame", {
                    Parent = frame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 8)
                })
                Create("UICorner", {Parent = bg, CornerRadius = UDim.new(1, 0)})
                local fill = Create("Frame", {
                    Parent = bg,
                    BackgroundColor3 = WindowSettings.Theme.Accent,
                    Size = UDim2.new(math.clamp((val - sldOpts.Min) / (sldOpts.Max - sldOpts.Min), 0, 1), 0, 1, 0)
                })
                Create("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})
                local trigger = Create("TextButton", {
                    Parent = bg,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = frame,
                    Label = lbl,
                    RawText = sldOpts.Text
                })

                local dragging = false
                local function update(input)
                    local perc = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    local step = sldOpts.Step or 1
                    local rawVal = sldOpts.Min + (perc * (sldOpts.Max - sldOpts.Min))
                    val = math.floor(rawVal / step + 0.5) * step
                    valLbl.Text = tostring(val)
                    Tween(fill, {Size = UDim2.new(perc, 0, 1, 0)}, 0.1)
                    if sldOpts.Callback then sldOpts.Callback(val) end
                end

                trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end)
            end

            function PageObj:CreateKeybind(keyOpts)
                local currentKey = nil
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 6)})
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = keyOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local btn = Create("TextButton", {
                    Parent = frame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    Position = UDim2.new(1, -80, 0.5, -12),
                    Size = UDim2.new(0, 70, 0, 24),
                    Font = Enum.Font.GothamBold,
                    Text = "None",
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 12
                })
                Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})
                
                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = frame,
                    Label = lbl,
                    RawText = keyOpts.Text
                })

                btn.MouseButton1Click:Connect(function()
                    btn.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Delete then
                                currentKey = nil
                                btn.Text = "None"
                            else
                                currentKey = input.KeyCode
                                btn.Text = currentKey.Name
                            end
                            if keyOpts.Callback then keyOpts.Callback(currentKey) end
                            conn:Disconnect()
                        end
                    end)
                end)
            end

            function PageObj:CreateDropdown(dropOpts)
                local isOpen = false
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 6)})
                local btn = Create("TextButton", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    Text = ""
                })
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = dropOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local icon = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 20, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = "+",
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 16
                })
                local list = Create("ScrollingFrame", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 1, -35),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2
                })
                local layout = Create("UIListLayout", {
                    Parent = list,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = frame,
                    Label = lbl,
                    RawText = dropOpts.Text
                })

                local function refresh()
                    local count = 0
                    for _, child in pairs(list:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, option in pairs(dropOpts.Options) do
                        count = count + 1
                        local optBtn = Create("TextButton", {
                            Parent = list,
                            BackgroundColor3 = WindowSettings.Theme.Element,
                            Size = UDim2.new(1, 0, 0, 30),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            TextSize = 12
                        })
                        optBtn.MouseButton1Click:Connect(function()
                            lbl.Text = dropOpts.Text .. " : " .. option
                            isOpen = false
                            Tween(frame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
                            Tween(icon, {Rotation = 0}, 0.2)
                            if dropOpts.Callback then dropOpts.Callback(option) end
                        end)
                    end
                    list.CanvasSize = UDim2.new(0, 0, 0, count * 30)
                end
                refresh()

                btn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local contentHeight = math.min(layout.AbsoluteContentSize.Y + 35, 150)
                        Tween(frame, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.2)
                        Tween(icon, {Rotation = 45}, 0.2)
                    else
                        Tween(frame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
                        Tween(icon, {Rotation = 0}, 0.2)
                    end
                end)
            end

            return PageObj
        end
        return CategoryObj
    end
    return GUI
end
return SpectraHub
