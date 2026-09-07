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
            Background = Color3.fromRGB(12, 12, 12),
            Topbar = Color3.fromRGB(18, 18, 18),
            Sidebar = Color3.fromRGB(18, 18, 18),
            Accent = Color3.fromRGB(0, 210, 85),
            Text = Color3.fromRGB(245, 245, 245),
            Element = Color3.fromRGB(24, 24, 24),
            Hover = Color3.fromRGB(32, 32, 32),
            Border = Color3.fromRGB(38, 38, 38)
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
        Position = UDim2.new(0.5, -350, 0.5, -225),
        Size = UDim2.new(0, 700, 0, 450),
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = MainFrame, Color = WindowSettings.Theme.Border, Thickness = 1})

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = WindowSettings.Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0
    })
    Create("UIStroke", {Parent = Topbar, Color = WindowSettings.Theme.Border, Thickness = 1})

    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = WindowSettings.Title,
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TitleAccent = Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = WindowSettings.Theme.Accent,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0
    })

    MakeDraggable(Topbar, MainFrame)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = WindowSettings.Theme.Sidebar,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(0, 180, 1, -45),
        BorderSizePixel = 0
    })
    Create("UIStroke", {Parent = Sidebar, Color = WindowSettings.Theme.Border, Thickness = 1})

    local CategoryLayout = Create("UIListLayout", {
        Parent = Sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    Create("UIPadding", {
        Parent = Sidebar,
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15)
    })

    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 45),
        Size = UDim2.new(1, -180, 1, -45)
    })

    local MinimizedIcon = Create("ImageButton", {
        Name = "MinimizedIcon",
        Parent = SpectraUI,
        BackgroundColor3 = WindowSettings.Theme.Element,
        Position = UDim2.new(0.5, -25, 0.5, -25),
        Size = UDim2.new(0, 50, 0, 50),
        Visible = false,
        AutoButtonColor = false
    })
    Create("UICorner", {Parent = MinimizedIcon, CornerRadius = UDim.new(1, 0)})
    Create("UIStroke", {Parent = MinimizedIcon, Color = WindowSettings.Theme.Accent, Thickness = 2})
    local MiniDot = Create("Frame", {
        Parent = MinimizedIcon,
        BackgroundColor3 = WindowSettings.Theme.Accent,
        Position = UDim2.new(0.5, -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12)
    })
    Create("UICorner", {Parent = MiniDot, CornerRadius = UDim.new(1, 0)})
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
        Position = UDim2.new(1, -90, 0, 0),
        Size = UDim2.new(0, 90, 1, 0)
    })

    local SearchBox = Create("TextBox", {
        Parent = Topbar,
        BackgroundColor3 = WindowSettings.Theme.Element,
        Position = UDim2.new(1, -260, 0.5, -15),
        Size = UDim2.new(0, 160, 0, 30),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 12
    })
    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = SearchBox, Color = WindowSettings.Theme.Border, Thickness = 1})

    local MinimizeBtn = Create("TextButton", {
        Parent = Controls,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 45, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 20
    })

    local CloseBtn = Create("TextButton", {
        Parent = Controls,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 0),
        Size = UDim2.new(0, 45, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 85, 85),
        TextSize = 14
    })

    local ConfirmationModal = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 100
    })
    local ConfirmBox = Create("Frame", {
        Parent = ConfirmationModal,
        BackgroundColor3 = WindowSettings.Theme.Background,
        Position = UDim2.new(0.5, -125, 0.5, -60),
        Size = UDim2.new(0, 250, 0, 120),
        ZIndex = 101
    })
    Create("UICorner", {Parent = ConfirmBox, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = ConfirmBox, Color = WindowSettings.Theme.Border, Thickness = 1})
    Create("TextLabel", {
        Parent = ConfirmBox,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Font = Enum.Font.GothamBold,
        Text = "Close Interface?",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 14,
        ZIndex = 102
    })
    local ConfirmYes = Create("TextButton", {
        Parent = ConfirmBox,
        BackgroundColor3 = Color3.fromRGB(255, 85, 85),
        Position = UDim2.new(0, 15, 0, 70),
        Size = UDim2.new(0, 100, 0, 35),
        Font = Enum.Font.GothamBold,
        Text = "Confirm",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        ZIndex = 102
    })
    Create("UICorner", {Parent = ConfirmYes, CornerRadius = UDim.new(0, 4)})
    local ConfirmNo = Create("TextButton", {
        Parent = ConfirmBox,
        BackgroundColor3 = WindowSettings.Theme.Element,
        Position = UDim2.new(0, 135, 0, 70),
        Size = UDim2.new(0, 100, 0, 35),
        Font = Enum.Font.GothamBold,
        Text = "Cancel",
        TextColor3 = WindowSettings.Theme.Text,
        TextSize = 12,
        ZIndex = 102
    })
    Create("UICorner", {Parent = ConfirmNo, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = ConfirmNo, Color = WindowSettings.Theme.Border, Thickness = 1})

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
            Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.3)
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
                            local highlighted = item.RawText:gsub("(?i)(" .. text .. ")", '<font color="#00d255">%1</font>')
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
            BackgroundColor3 = WindowSettings.Theme.Background,
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(1, 300, 0, 0)
        })
        Create("UICorner", {Parent = notif, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = notif, Color = WindowSettings.Theme.Border, Thickness = 1})
        
        Create("Frame", {
            Parent = notif,
            BackgroundColor3 = WindowSettings.Theme.Accent,
            Size = UDim2.new(0, 3, 1, 0),
            BorderSizePixel = 0
        })

        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = WindowSettings.Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 30),
            Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.Gotham,
            Text = message,
            TextColor3 = Color3.fromRGB(170, 170, 170),
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
            BackgroundColor3 = WindowSettings.Theme.Background,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Enum.Font.GothamBold,
            Text = "  " .. name,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = CatBtn, CornerRadius = UDim.new(0, 4)})

        local PageContainer = Create("ScrollingFrame", {
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = WindowSettings.Theme.Accent,
            Visible = false
        })
        Create("UIPadding", {
            Parent = PageContainer,
            PaddingTop = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 15)
        })
        local PageLayout = Create("UIListLayout", {
            Parent = PageContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageContainer.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
        end)

        CatBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = WindowSettings.Theme.Background}, 0.2)
                    Tween(btn, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
                end
            end
            Tween(CatBtn, {BackgroundColor3 = WindowSettings.Theme.Element}, 0.2)
            Tween(CatBtn, {TextColor3 = WindowSettings.Theme.Accent}, 0.2)
            PageContainer.Visible = true
        end)

        if not CurrentCategory then
            CurrentCategory = CategoryObj
            PageContainer.Visible = true
            CatBtn.BackgroundColor3 = WindowSettings.Theme.Element
            CatBtn.TextColor3 = WindowSettings.Theme.Accent
        end

        function CategoryObj:CreatePage(pageName)
            local PageObj = {}
            local SectionLabel = Create("TextLabel", {
                Parent = PageContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = string.upper(pageName),
                TextColor3 = WindowSettings.Theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            function PageObj:CreateButton(btnOpts)
                local btn = Create("TextButton", {
                    Parent = PageContainer,
                    BackgroundColor3 = btnOpts.Color or WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 38),
                    Font = Enum.Font.Gotham,
                    Text = btnOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = btn, Color = WindowSettings.Theme.Border, Thickness = 1})
                
                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = btn,
                    Label = btn,
                    RawText = btnOpts.Text
                })

                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = WindowSettings.Theme.Hover}, 0.2) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = btnOpts.Color or WindowSettings.Theme.Element}, 0.2) end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, {Size = UDim2.new(1, -2, 0, 36)}, 0.1).Completed:Connect(function()
                        Tween(btn, {Size = UDim2.new(1, 0, 0, 38)}, 0.1)
                    end)
                    if btnOpts.Callback then btnOpts.Callback() end
                    if btnOpts.Notify then GUI:Notify("Ação Executada", btnOpts.Text) end
                end)
            end

            function PageObj:CreateToggle(tglOpts)
                local state = tglOpts.Default or false
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Background,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = tglOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local switchBox = Create("Frame", {
                    Parent = frame,
                    BackgroundColor3 = state and WindowSettings.Theme.Accent or WindowSettings.Theme.Element,
                    Position = UDim2.new(1, -20, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20)
                })
                Create("UICorner", {Parent = switchBox, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = switchBox, Color = WindowSettings.Theme.Border, Thickness = 1})
                
                local check = Create("TextLabel", {
                    Parent = switchBox,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "✓",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextTransparency = state and 0 or 1
                })

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
                    Tween(switchBox, {BackgroundColor3 = state and WindowSettings.Theme.Accent or WindowSettings.Theme.Element}, 0.2)
                    Tween(check, {TextTransparency = state and 0 or 1}, 0.2)
                    if tglOpts.Callback then tglOpts.Callback(state) end
                    if tglOpts.Notify then GUI:Notify("Status Atualizado", tglOpts.Text .. " -> " .. tostring(state)) end
                end)
            end

            function PageObj:CreateSlider(sldOpts)
                local val = sldOpts.Default or sldOpts.Min
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Background,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45)
                })
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sldOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local valLbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(val),
                    TextColor3 = WindowSettings.Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                local bg = Create("Frame", {
                    Parent = frame,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 0, 6)
                })
                Create("UICorner", {Parent = bg, CornerRadius = UDim.new(1, 0)})
                Create("UIStroke", {Parent = bg, Color = WindowSettings.Theme.Border, Thickness = 1})
                
                local fill = Create("Frame", {
                    Parent = bg,
                    BackgroundColor3 = WindowSettings.Theme.Accent,
                    Size = UDim2.new(math.clamp((val - sldOpts.Min) / (sldOpts.Max - sldOpts.Min), 0, 1), 0, 1, 0)
                })
                Create("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})
                local trigger = Create("TextButton", {
                    Parent = bg,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, -10),
                    Size = UDim2.new(1, 0, 1, 20),
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

            function PageObj:CreateColorPicker(colorOpts)
                local currentColor = colorOpts.Default or Color3.fromRGB(255, 255, 255)
                local h, s, v = Color3.toHSV(currentColor)
                local isOpen = false

                local container = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    ClipsDescendants = true
                })
                local mainArea = Create("Frame", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                local lbl = Create("TextLabel", {
                    Parent = mainArea,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = colorOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local colorBox = Create("TextButton", {
                    Parent = mainArea,
                    BackgroundColor3 = currentColor,
                    Position = UDim2.new(1, -26, 0.5, -8),
                    Size = UDim2.new(0, 26, 0, 16),
                    Text = ""
                })
                Create("UICorner", {Parent = colorBox, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = colorBox, Color = WindowSettings.Theme.Border, Thickness = 1})

                local pickerArea = Create("Frame", {
                    Parent = container,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 0, 110)
                })
                Create("UICorner", {Parent = pickerArea, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = pickerArea, Color = WindowSettings.Theme.Border, Thickness = 1})

                local function CreateSlider(yPos, gradientColors, onUpdate)
                    local bg = Create("Frame", {
                        Parent = pickerArea,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = UDim2.new(0, 10, 0, yPos),
                        Size = UDim2.new(1, -20, 0, 14)
                    })
                    Create("UICorner", {Parent = bg, CornerRadius = UDim.new(0, 4)})
                    Create("UIGradient", {
                        Parent = bg,
                        Color = ColorSequence.new(gradientColors)
                    })
                    local marker = Create("Frame", {
                        Parent = bg,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 4, 1, 4),
                        Position = UDim2.new(0, 0, 0, -2)
                    })
                    Create("UIStroke", {Parent = marker, Color = Color3.fromRGB(0, 0, 0), Thickness = 1})
                    local trigger = Create("TextButton", {
                        Parent = bg,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = ""
                    })
                    local drag = false
                    local function update(input)
                        local perc = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                        marker.Position = UDim2.new(perc, -2, 0, -2)
                        onUpdate(perc)
                    end
                    trigger.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            drag = true; update(input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
                    end)
                    return marker
                end

                local hueMarker = CreateSlider(15, {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }, function(val)
                    h = 1 - val; currentColor = Color3.fromHSV(h, s, v)
                    colorBox.BackgroundColor3 = currentColor
                    if colorOpts.Callback then colorOpts.Callback(currentColor) end
                end)
                hueMarker.Position = UDim2.new(1 - h, -2, 0, -2)

                local satMarker = CreateSlider(45, {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
                }, function(val)
                    s = val; currentColor = Color3.fromHSV(h, s, v)
                    colorBox.BackgroundColor3 = currentColor
                    if colorOpts.Callback then colorOpts.Callback(currentColor) end
                end)
                satMarker.Position = UDim2.new(s, -2, 0, -2)

                local valMarker = CreateSlider(75, {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1))
                }, function(val)
                    v = val; currentColor = Color3.fromHSV(h, s, v)
                    colorBox.BackgroundColor3 = currentColor
                    if colorOpts.Callback then colorOpts.Callback(currentColor) end
                end)
                valMarker.Position = UDim2.new(v, -2, 0, -2)

                table.insert(ElementsRegistry, {
                    Category = CategoryObj,
                    Instance = container,
                    Label = lbl,
                    RawText = colorOpts.Text
                })

                colorBox.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Tween(container, {Size = UDim2.new(1, 0, 0, isOpen and 150 or 30)}, 0.2)
                end)
            end

            function PageObj:CreateDropdown(dropOpts)
                local isOpen = false
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = frame, Color = WindowSettings.Theme.Border, Thickness = 1})
                
                local btn = Create("TextButton", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    Text = ""
                })
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -40, 0, 38),
                    Font = Enum.Font.Gotham,
                    Text = dropOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local icon = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 20, 0, 38),
                    Font = Enum.Font.GothamBold,
                    Text = "+",
                    TextColor3 = WindowSettings.Theme.Accent,
                    TextSize = 16
                })
                local list = Create("ScrollingFrame", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 38),
                    Size = UDim2.new(1, 0, 1, -38),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = WindowSettings.Theme.Accent
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
                            Text = "  " .. option,
                            TextColor3 = Color3.fromRGB(180, 180, 180),
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0
                        })
                        optBtn.MouseButton1Click:Connect(function()
                            lbl.Text = dropOpts.Text .. " : " .. option
                            isOpen = false
                            Tween(frame, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
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
                        local contentHeight = math.min(layout.AbsoluteContentSize.Y + 38, 160)
                        Tween(frame, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.2)
                        Tween(icon, {Rotation = 45}, 0.2)
                    else
                        Tween(frame, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
                        Tween(icon, {Rotation = 0}, 0.2)
                    end
                end)
            end

            function PageObj:CreateKeybind(keyOpts)
                local currentKey = nil
                local frame = Create("Frame", {
                    Parent = PageContainer,
                    BackgroundColor3 = WindowSettings.Theme.Background,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                local lbl = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = keyOpts.Text,
                    TextColor3 = WindowSettings.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local btn = Create("TextButton", {
                    Parent = frame,
                    BackgroundColor3 = WindowSettings.Theme.Element,
                    Position = UDim2.new(1, -80, 0.5, -13),
                    Size = UDim2.new(0, 80, 0, 26),
                    Font = Enum.Font.GothamBold,
                    Text = "None",
                    TextColor3 = WindowSettings.Theme.Accent,
                    TextSize = 11
                })
                Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = btn, Color = WindowSettings.Theme.Border, Thickness = 1})
                
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

            return PageObj
        end
        return CategoryObj
    end
    return GUI
end
return SpectraHub
